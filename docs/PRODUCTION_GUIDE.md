# Guide Production : Sécurité, Résilience et Principes

**📘 Lecture recommandée avant le déploiement en production**

Ce guide explique **pourquoi** et **comment** implémenter les best practices de sécurité, résilience et architecture dans vos applications event-driven Azure.

---

## 📋 Table des Matières

- [Pourquoi Event-Driven ?](#pourquoi-event-driven)
- [Sécurité](#sécurité)
- [Résilience](#résilience)
- [Principes de Conception](#principes-de-conception)

---

## 🎯 Pourquoi Event-Driven ?

### Pourquoi découpler avec des événements ?

**Problème : Couplage serré**
```java
// ❌ Couplage fort - Service A appelle directement Service B
public class OrderService {
    private PaymentService paymentService;
    private InventoryService inventoryService;
    private EmailService emailService;
    
    public void createOrder(Order order) {
        paymentService.processPayment(order);      // Attente bloquante
        inventoryService.reserveItems(order);      // Si échec, tout échoue
        emailService.sendConfirmation(order);      // Dépendances en chaîne
    }
}
```

**Problèmes :**
- ❌ Si EmailService est down, tout le flow échoue
- ❌ Temps de réponse = somme de tous les appels
- ❌ Impossible de scaler indépendamment
- ❌ Modifications d'un service impactent tous les autres

**Solution : Architecture event-driven**
```java
// ✅ Découplage - Publier un événement
public class OrderService {
    private EventHubProducerClient eventHub;
    
    public void createOrder(Order order) {
        // 1. Sauvegarder la commande
        orderRepository.save(order);
        
        // 2. Publier l'événement "OrderCreated"
        OrderCreatedEvent event = new OrderCreatedEvent(order.getId(), order.getTotal());
        eventHub.send(toEventData(event));
        
        // 3. Retourner immédiatement (pas d'attente)
        return "Order created successfully";
    }
}

// Chaque service écoute indépendamment
public class PaymentService {
    @EventHubTrigger
    public void onOrderCreated(OrderCreatedEvent event) {
        processPayment(event);  // Traitement asynchrone
    }
}
```

**Bénéfices :**
- ✅ Temps de réponse réduit (pas d'attente)
- ✅ Si PaymentService est down, les autres services continuent
- ✅ Chaque service scale indépendamment
- ✅ Ajout de nouveaux consumers sans modifier les producteurs

---

### Pourquoi utiliser Event Hubs plutôt qu'une API REST ?

| Critère | API REST (Sync) | Event Hubs (Async) |
|---------|-----------------|---------------------|
| **Latence** | Producer attend la réponse | Producer continue immédiatement |
| **Volumétrie** | Limité par le serveur | Millions d'events/sec |
| **Résilience** | Si consumer down = échec | Events bufferisés, rejoués plus tard |
| **Scalabilité** | Scale vertical (serveur plus gros) | Scale horizontal (plus de partitions) |
| **Couplage** | Producer connaît le consumer | Producer ne connaît pas les consumers |
| **Ordre** | Pas garanti en distributed | Garanti par partition |

**Exemple concret : Télémétrie IoT**

```
❌ API REST :
[1000 devices] → POST /api/telemetry → [API Server] 
                                        ↓ (overload!)
                                    [Crashes après 100 req/s]

✅ Event Hubs :
[1000 devices] → Event Hubs (8 partitions) → [Consumers scale auto]
                  ↓ Buffering                  ↓ Process 10K/sec
              [Retient 7 jours]            [Reprend après panne]
```

---

### Pourquoi les partitions ?

**Sans partitions : Goulot d'étranglement**
```
[Producer A] ─┐
[Producer B] ─┤─→ [Single Queue] → [Single Consumer] ⚠️ Bottleneck
[Producer C] ─┘
```

**Avec partitions : Parallélisme**
```
[Producer A] ─┬─→ [Partition 0] → [Consumer A]
[Producer B] ─┼─→ [Partition 1] → [Consumer B]
[Producer C] ─┴─→ [Partition 2] → [Consumer C]
              ↑
         Partition Key
```

**Pourquoi utiliser une partition key ?**

```java
// ❌ Sans partition key - ordre non garanti
eventData.getProperties().put("partitionKey", null);
// Résultat : Events d'un même device peuvent arriver dans le désordre

// ✅ Avec partition key - ordre garanti par device
eventData.getProperties().put("deviceId", "sensor-001");
// Résultat : Tous les events de sensor-001 vont dans la même partition
//            → Ordre FIFO garanti
```

**Cas d'usage ordre requis :**
- 📊 **Transactions financières** : Crédit avant débit
- 🚗 **Localisation GPS** : Position chronologique
- 🏭 **Capteurs industriels** : Température dans l'ordre
- 🛒 **E-commerce** : Status commande (créée → payée → expédiée)

---

### Pourquoi le checkpointing ?

**Sans checkpoint : Reprise depuis le début**
```
[Consumer] lit events 0→1000 → ❌ Crash
[Consumer redémarre] → Relit 0→1000 (doublons!)
```

**Avec checkpoint : Reprise où on s'est arrêté**
```
[Consumer] lit events 0→500 → Checkpoint (offset 500)
         lit events 501→1000 → ❌ Crash
[Consumer redémarre] → Relit depuis 501 (pas de doublon)
```

**Implémentation Java :**
```java
// ✅ Checkpoint après chaque batch
eventContext.updateCheckpoint();

// ⚠️ Attention : Checkpoint avant traitement = risque perte données
eventContext.updateCheckpoint(); // ❌ Trop tôt
processEvent(event);             // Si crash ici, event perdu

// ✅ Bon ordre
processEvent(event);
eventContext.updateCheckpoint(); // Après traitement réussi
```

**Stratégies de checkpoint :**

| Stratégie | Quand utiliser | Risque |
|-----------|----------------|--------|
| **Après chaque event** | Traitement critique | Performance ↓ (I/O élevé) |
| **Toutes les 10 events** | Équilibre | 10 events max rejouées |
| **Toutes les 30 sec** | High throughput | Rejouage d'une fenêtre |
| **Jamais** | Démo/dev seulement | Tout rejoué après crash |

---

### Pourquoi des batches ?

**Sans batch : Trop de requêtes réseau**
```java
// ❌ 100 appels HTTP = 100 * 50ms = 5 secondes
for (int i = 0; i < 100; i++) {
    producer.send(createEvent(i));  // 1 appel réseau par event
}
```

**Avec batch : Regroupement intelligent**
```java
// ✅ 1 appel HTTP = 50ms
EventDataBatch batch = producer.createBatch();
for (int i = 0; i < 100; i++) {
    batch.tryAdd(createEvent(i));
}
producer.send(batch);  // 1 seul appel réseau
```

**Gains :**
- 🚀 **Performance** : 5000ms → 50ms (100x plus rapide)
- 💰 **Coûts** : Moins de Throughput Units utilisés
- 🌍 **Réseau** : Moins de bandwidth

**Taille optimale du batch :**
- ⚠️ Trop petit (< 10) : Pas assez de gains
- ⚠️ Trop gros (> 1000) : Latence élevée, risque timeout
- ✅ Optimal : **50-200 events** ou **1 MB max**

---

## 🔒 Sécurité

### Principe : Zero Trust

**Ne jamais exposer de secrets dans le code !**

```java
// ❌ DANGER - Secrets en dur dans le code
String connectionString = "Endpoint=sb://...;SharedAccessKey=SECRET123";

// ❌ DANGER - Secrets dans les variables d'environnement (logs)
String connectionString = System.getenv("EVENT_HUB_CONNECTION_STRING");
System.out.println("Connection: " + connectionString); // Secret dans les logs !

// ✅ BON - Managed Identity (pas de secret)
DefaultAzureCredential credential = new DefaultAzureCredentialBuilder().build();
EventHubProducerClient producer = new EventHubClientBuilder()
    .credential(credential)
    .fullyQualifiedNamespace("mynamespace.servicebus.windows.net")
    .eventHubName("telemetry")
    .buildProducerClient();
```

---

### 1. Authentication : Managed Identity

**Pourquoi Managed Identity ?**
- ✅ Pas de secrets à gérer
- ✅ Rotation automatique des credentials
- ✅ Audit trail complet (Azure AD logs)
- ✅ Principe du moindre privilège

#### Configuration Azure

```bash
# 1. Activer Managed Identity sur Function App
az functionapp identity assign \
  --name $FUNCTION_APP \
  --resource-group $RESOURCE_GROUP

# Récupérer le Principal ID
PRINCIPAL_ID=$(az functionapp identity show \
  --name $FUNCTION_APP \
  --resource-group $RESOURCE_GROUP \
  --query principalId -o tsv)

# 2. Assigner le rôle sur Event Hubs
EVENT_HUB_ID=$(az eventhubs namespace show \
  --name $NAMESPACE \
  --resource-group $RESOURCE_GROUP \
  --query id -o tsv)

az role assignment create \
  --assignee $PRINCIPAL_ID \
  --role "Azure Event Hubs Data Sender" \
  --scope $EVENT_HUB_ID

# Rôles disponibles :
# - Azure Event Hubs Data Owner (full access)
# - Azure Event Hubs Data Sender (send only)
# - Azure Event Hubs Data Receiver (receive only)
```

#### Code Java avec Managed Identity

```java
// ✅ Managed Identity (System-assigned ou User-assigned)
DefaultAzureCredential credential = new DefaultAzureCredentialBuilder().build();

EventHubProducerClient producer = new EventHubClientBuilder()
    .credential(credential)
    .fullyQualifiedNamespace("mynamespace.servicebus.windows.net")
    .eventHubName("telemetry")
    .buildProducerClient();

// Pas de connection string = Pas de risque de fuite !
```

#### Code .NET avec Managed Identity

```csharp
// ✅ Managed Identity
var credential = new DefaultAzureCredential();

var producer = new EventHubProducerClient(
    "mynamespace.servicebus.windows.net",
    "telemetry",
    credential
);
```

---

### 2. Secrets Management : Azure Key Vault

**Pour les secrets obligatoires (APIs tierces, etc.)**

```bash
# 1. Créer Key Vault
az keyvault create \
  --name $KEYVAULT_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION

# 2. Ajouter un secret
az keyvault secret set \
  --vault-name $KEYVAULT_NAME \
  --name "ExternalApiKey" \
  --value "secret-api-key-123"

# 3. Donner accès à la Function App (via Managed Identity)
az keyvault set-policy \
  --name $KEYVAULT_NAME \
  --object-id $PRINCIPAL_ID \
  --secret-permissions get list
```

#### Récupérer un secret en Java

```java
// ✅ Key Vault avec Managed Identity
SecretClient secretClient = new SecretClientBuilder()
    .vaultUrl("https://mykeyvault.vault.azure.net/")
    .credential(new DefaultAzureCredentialBuilder().build())
    .buildClient();

String apiKey = secretClient.getSecret("ExternalApiKey").getValue();

// Le secret n'est jamais dans le code ou les logs
```

---

### 3. Network Security

**Isoler Event Hubs du public internet**

```bash
# 1. Créer un Virtual Network
az network vnet create \
  --name vnet-eventhubs \
  --resource-group $RESOURCE_GROUP \
  --address-prefix 10.0.0.0/16 \
  --subnet-name subnet-apps \
  --subnet-prefix 10.0.1.0/24

# 2. Activer Private Endpoint sur Event Hubs
az network private-endpoint create \
  --name pe-eventhubs \
  --resource-group $RESOURCE_GROUP \
  --vnet-name vnet-eventhubs \
  --subnet subnet-apps \
  --private-connection-resource-id $EVENT_HUB_ID \
  --group-id namespace \
  --connection-name eventhubs-connection

# 3. Désactiver l'accès public
az eventhubs namespace update \
  --name $NAMESPACE \
  --resource-group $RESOURCE_GROUP \
  --public-network-access Disabled
```

**Résultat :**
- ✅ Event Hubs accessible seulement depuis le VNet
- ✅ Pas d'exposition internet
- ✅ Traffic interne Azure (pas de sortie internet)

---

### 4. Audit et Monitoring Sécurité

**Activer les logs de diagnostic**

```bash
# Créer un Log Analytics Workspace
az monitor log-analytics workspace create \
  --resource-group $RESOURCE_GROUP \
  --workspace-name law-security

WORKSPACE_ID=$(az monitor log-analytics workspace show \
  --resource-group $RESOURCE_GROUP \
  --workspace-name law-security \
  --query id -o tsv)

# Activer les logs sur Event Hubs
az monitor diagnostic-settings create \
  --name eventhubs-security-logs \
  --resource $EVENT_HUB_ID \
  --workspace $WORKSPACE_ID \
  --logs '[
    {"category": "ArchiveLogs", "enabled": true},
    {"category": "OperationalLogs", "enabled": true},
    {"category": "AutoScaleLogs", "enabled": true}
  ]'
```

**Query KQL pour détecter les anomalies**

```kql
// Échecs d'authentification
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.EVENTHUB"
| where Category == "OperationalLogs"
| where OperationName contains "Authentication"
| where ResultType == "Failed"
| summarize FailedAttempts = count() by ClientIP, bin(TimeGenerated, 5m)
| where FailedAttempts > 5
| project TimeGenerated, ClientIP, FailedAttempts

// Accès depuis des IPs inattendues
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.EVENTHUB"
| where ClientIP !in ("10.0.1.0/24", "10.0.2.0/24") // IPs attendues
| summarize Count = count() by ClientIP, bin(TimeGenerated, 1h)
| order by Count desc
```

---

### Checklist Sécurité Production

| Item | Status | Action |
|------|--------|--------|
| ✅ Managed Identity | ☐ | Activer sur toutes les ressources |
| ✅ Key Vault | ☐ | Migrer tous les secrets |
| ✅ RBAC | ☐ | Principe du moindre privilège |
| ✅ Private Endpoint | ☐ | Isoler du public internet |
| ✅ Network Security Groups | ☐ | Restreindre le trafic |
| ✅ Diagnostic Logs | ☐ | Activer audit trail |
| ✅ Azure Security Center | ☐ | Scan automatique des vulnérabilités |
| ✅ Code Scanning | ☐ | Pas de secrets committés (GitGuardian) |

---

## 🛡️ Résilience

### Principe : Tout peut échouer

> "In distributed systems, failures are not the exception, they are the norm."

**Loi de Murphy pour le cloud :**
- ❌ Le réseau **va** avoir des latences
- ❌ Event Hubs **va** avoir des throttling (429)
- ❌ Votre consumer **va** crasher
- ❌ Azure **va** avoir des pannes régionales

**La question n'est pas "si", mais "quand".**

---

### 1. Retry Policy avec Backoff Exponentiel

**Pourquoi retry ?**
- 90% des erreurs sont **transitoires** (timeout réseau, throttling temporaire)
- Un retry immédiat aggrave le problème (thundering herd)
- Un backoff exponentiel laisse le temps au système de récupérer

#### Implémentation Java avec Resilience4j

```xml
<!-- pom.xml -->
<dependency>
    <groupId>io.github.resilience4j</groupId>
    <artifactId>resilience4j-retry</artifactId>
    <version>2.1.0</version>
</dependency>
```

```java
import io.github.resilience4j.retry.*;

// Configuration du retry
RetryConfig config = RetryConfig.custom()
    .maxAttempts(5)
    .waitDuration(Duration.ofSeconds(1))
    .intervalFunction(IntervalFunction.ofExponentialBackoff(
        Duration.ofSeconds(1), // Initial delay
        2.0                     // Multiplier
    ))
    .retryOnException(e -> 
        e instanceof EventHubsException ||
        e instanceof TimeoutException
    )
    .ignoreExceptions(IllegalArgumentException.class) // Ne pas retry
    .build();

Retry retry = Retry.of("eventhubs-producer", config);

// Wrapper autour de l'envoi
Callable<Void> sendWithRetry = Retry.decorateCallable(retry, () -> {
    producer.send(batch);
    return null;
});

try {
    sendWithRetry.call();
    System.out.println("✅ Événements envoyés avec succès");
} catch (Exception e) {
    System.err.println("❌ Échec après 5 tentatives: " + e.getMessage());
    // Dead-letter ou alerte
}
```

**Timeline du retry :**
```
Tentative 1: Échec immédiat
           ↓ wait 1s
Tentative 2: Échec
           ↓ wait 2s (1 * 2^1)
Tentative 3: Échec
           ↓ wait 4s (1 * 2^2)
Tentative 4: Échec
           ↓ wait 8s (1 * 2^3)
Tentative 5: Échec final
           ↓
Dead-letter ou alerte
```

---

### 2. Circuit Breaker

**Pourquoi circuit breaker ?**
- Éviter d'appeler un service qui est down (gaspillage)
- Protéger le système en aval d'une surcharge
- Fail-fast plutôt qu'attendre un timeout

**États du circuit breaker :**

```
CLOSED (normal) → Erreurs > seuil → OPEN (rejette tout)
                                         ↓ wait timeout
                                     HALF-OPEN (teste)
                                         ↓ succès
                                     CLOSED (rétabli)
```

#### Implémentation Java

```java
import io.github.resilience4j.circuitbreaker.*;

CircuitBreakerConfig cbConfig = CircuitBreakerConfig.custom()
    .failureRateThreshold(50)                    // 50% d'échecs = OPEN
    .slowCallRateThreshold(50)                   // 50% de slow calls = OPEN
    .slowCallDurationThreshold(Duration.ofSeconds(3))
    .waitDurationInOpenState(Duration.ofSeconds(60)) // Attendre 60s avant HALF-OPEN
    .permittedNumberOfCallsInHalfOpenState(5)    // Tester avec 5 appels
    .slidingWindowSize(10)                       // Observer sur 10 appels
    .build();

CircuitBreaker circuitBreaker = CircuitBreaker.of("eventhubs", cbConfig);

// Combiner Retry + Circuit Breaker
Callable<Void> resilientSend = Decorators
    .ofCallable(() -> { producer.send(batch); return null; })
    .withCircuitBreaker(circuitBreaker)
    .withRetry(retry)
    .decorate();

try {
    resilientSend.call();
} catch (CallNotPermittedException e) {
    System.err.println("⚠️ Circuit breaker OPEN - Service indisponible");
    // Fallback : sauvegarder localement, envoyer alerte
}
```

**Monitoring du circuit breaker :**

```java
circuitBreaker.getEventPublisher()
    .onStateTransition(event -> {
        System.out.println("Circuit breaker: " + 
            event.getStateTransition().getFromState() + " → " + 
            event.getStateTransition().getToState());
        
        if (event.getStateTransition().getToState() == CircuitBreaker.State.OPEN) {
            // Envoyer alerte : Event Hubs est down !
            alertService.sendAlert("Event Hubs circuit breaker OPEN");
        }
    });
```

---

### 3. Idempotence

**Pourquoi idempotent ?**
- Les retries peuvent causer des doublons
- Le checkpointing n'est pas atomique
- Les pannes réseau peuvent causer des duplications

**Un handler idempotent** = Traiter 2x le même event = même résultat

#### Pattern 1 : Deduplication avec ID

```java
// Stocker les IDs déjà traités (Redis, Cosmos DB)
private ConcurrentHashMap<String, Long> processedEvents = new ConcurrentHashMap<>();

public void processEvent(EventData event) {
    String eventId = event.getProperties().get("eventId").toString();
    long timestamp = System.currentTimeMillis();
    
    // Vérifier si déjà traité dans les 5 dernières minutes
    Long lastProcessed = processedEvents.get(eventId);
    if (lastProcessed != null && (timestamp - lastProcessed) < 300_000) {
        System.out.println("⚠️ Event déjà traité, ignoré: " + eventId);
        return; // Skip
    }
    
    // Traiter l'événement
    doBusinessLogic(event);
    
    // Marquer comme traité
    processedEvents.put(eventId, timestamp);
}

// Nettoyer périodiquement les vieux IDs
@Scheduled(fixedRate = 60000) // Toutes les minutes
public void cleanupOldEvents() {
    long cutoff = System.currentTimeMillis() - 300_000; // 5 min
    processedEvents.entrySet().removeIf(entry -> entry.getValue() < cutoff);
}
```

#### Pattern 2 : Opérations idempotentes par nature

```java
// ❌ Non-idempotent
public void onPaymentReceived(PaymentEvent event) {
    int currentBalance = getBalance(event.getAccountId());
    int newBalance = currentBalance + event.getAmount();
    updateBalance(event.getAccountId(), newBalance);
    // Si rejoué : balance incorrecte !
}

// ✅ Idempotent avec upsert
public void onPaymentReceived(PaymentEvent event) {
    // Upsert avec constraint unique sur paymentId
    String sql = """
        INSERT INTO payments (payment_id, account_id, amount, timestamp)
        VALUES (?, ?, ?, ?)
        ON CONFLICT (payment_id) DO NOTHING
    """;
    
    // Si déjà inséré, ne fait rien = idempotent
    jdbcTemplate.update(sql, 
        event.getPaymentId(), 
        event.getAccountId(), 
        event.getAmount(), 
        event.getTimestamp()
    );
}
```

---

### 4. Dead Letter Queue

**Quand utiliser ?**
- Après échec de tous les retries
- Événements malformés (impossible à parser)
- Erreurs métier (validation échouée)

#### Implémentation avec Event Grid

```java
public void processEvent(EventData event) {
    try {
        TelemetryData telemetry = gson.fromJson(
            event.getBodyAsString(), 
            TelemetryData.class
        );
        
        // Validation
        if (telemetry.getTemperature() < -50 || telemetry.getTemperature() > 100) {
            throw new ValidationException("Temperature hors limites");
        }
        
        // Traitement normal
        saveTelemetry(telemetry);
        
    } catch (ValidationException | JsonSyntaxException e) {
        // Envoyer en dead-letter pour investigation
        sendToDeadLetter(event, e.getMessage());
    }
}

private void sendToDeadLetter(EventData originalEvent, String reason) {
    EventGridPublisherClient deadLetterClient = new EventGridPublisherClient(
        new URI(DEAD_LETTER_TOPIC_ENDPOINT),
        new AzureKeyCredential(DEAD_LETTER_KEY)
    );
    
    EventGridEvent deadLetterEvent = new EventGridEvent(
        "DeadLetter/" + originalEvent.getMessageId(),
        "EventProcessing.Failed",
        "1.0",
        Map.of(
            "originalEvent", originalEvent.getBodyAsString(),
            "reason", reason,
            "timestamp", Instant.now().toString()
        )
    );
    
    deadLetterClient.sendEvent(deadLetterEvent);
}
```

---

### 5. Health Checks et Monitoring

#### Health Check Endpoint

```java
@RestController
public class HealthController {
    
    @Autowired
    private EventHubProducerClient producer;
    
    @GetMapping("/health")
    public ResponseEntity<HealthStatus> health() {
        boolean eventhubsHealthy = checkEventHubsConnection();
        boolean cosmosHealthy = checkCosmosConnection();
        
        if (eventhubsHealthy && cosmosHealthy) {
            return ResponseEntity.ok(new HealthStatus("healthy"));
        } else {
            return ResponseEntity.status(503)
                .body(new HealthStatus("unhealthy", Map.of(
                    "eventhubs", eventhubsHealthy,
                    "cosmos", cosmosHealthy
                )));
        }
    }
    
    private boolean checkEventHubsConnection() {
        try {
            // Tenter de créer un batch (ne coûte rien)
            EventDataBatch batch = producer.createBatch();
            return true;
        } catch (Exception e) {
            logger.error("Event Hubs health check failed", e);
            return false;
        }
    }
}
```

---

### Checklist Résilience Production

| Item | Status | Pattern |
|------|--------|---------|
| ✅ Retry Policy | ☐ | Backoff exponentiel (1s, 2s, 4s, 8s, 16s) |
| ✅ Circuit Breaker | ☐ | Fail-fast si service down |
| ✅ Idempotence | ☐ | Deduplication avec ID ou upsert |
| ✅ Dead Letter | ☐ | Event Grid pour events échoués |
| ✅ Health Checks | ☐ | /health endpoint avec vérification dépendances |
| ✅ Timeouts | ☐ | Sur tous les appels réseau (max 30s) |
| ✅ Bulkhead | ☐ | Isoler les thread pools par dépendance |
| ✅ Graceful Shutdown | ☐ | Finir de traiter les events en cours |

---

## 🎯 Principes de Conception

### 1. Single Responsibility Principle

**Un consumer = Un seul type d'événement**

```java
// ❌ Consumer qui fait trop
@EventHubTrigger
public void onEvent(EventData event) {
    String eventType = event.getProperties().get("eventType").toString();
    
    if (eventType.equals("OrderCreated")) {
        processOrder(event);
    } else if (eventType.equals("PaymentReceived")) {
        processPayment(event);
    } else if (eventType.equals("InventoryUpdated")) {
        processInventory(event);
    }
    // Difficile à maintenir, tester, scaler
}

// ✅ Consumers séparés
@EventHubTrigger(consumerGroup = "order-processor")
public void onOrderCreated(OrderCreatedEvent event) {
    processOrder(event);
}

@EventHubTrigger(consumerGroup = "payment-processor")
public void onPaymentReceived(PaymentReceivedEvent event) {
    processPayment(event);
}
```

**Avantages :**
- ✅ Scale indépendamment
- ✅ Deploy indépendamment
- ✅ Tests unitaires plus simples
- ✅ Monitoring par consumer group

---

### 2. Versioning des Événements

**Les événements sont des contrats**

```java
// V1 - Événement initial
public class OrderCreatedEventV1 {
    String orderId;
    String customerId;
    double totalAmount;
}

// V2 - Nouveau champ ajouté
public class OrderCreatedEventV2 {
    String orderId;
    String customerId;
    double totalAmount;
    String currency;  // NOUVEAU
    List<OrderItem> items;  // NOUVEAU
}

// Consumer compatible avec V1 et V2
public void onOrderCreated(EventData event) {
    String version = event.getProperties().get("eventVersion").toString();
    
    if (version.equals("1.0")) {
        OrderCreatedEventV1 eventV1 = gson.fromJson(
            event.getBodyAsString(), 
            OrderCreatedEventV1.class
        );
        processOrder(eventV1.getOrderId(), eventV1.getTotalAmount(), "USD");
    } else if (version.equals("2.0")) {
        OrderCreatedEventV2 eventV2 = gson.fromJson(
            event.getBodyAsString(), 
            OrderCreatedEventV2.class
        );
        processOrder(eventV2.getOrderId(), eventV2.getTotalAmount(), eventV2.getCurrency());
    }
}
```

**Best practices :**
- ✅ Toujours ajouter `"eventVersion": "1.0"` dans les events
- ✅ Nouveaux champs = optionnels (backward compatible)
- ✅ Ne jamais supprimer ou renommer un champ existant
- ✅ Documenter le schema (JSON Schema, Avro)

---

### 3. Correlation IDs et Distributed Tracing

**Tracer un événement à travers tout le système**

```java
// Producer : Générer correlation ID
String correlationId = UUID.randomUUID().toString();

EventData eventData = new EventData(gson.toJson(telemetry));
eventData.getProperties().put("correlationId", correlationId);
eventData.getProperties().put("sourceService", "iot-gateway");

producer.send(eventData);

// Consumer : Propager correlation ID
public void processEvent(EventData event) {
    String correlationId = event.getProperties().get("correlationId").toString();
    
    // Logger avec correlation ID
    MDC.put("correlationId", correlationId);
    logger.info("Processing event for device: {}", telemetry.getDeviceId());
    
    // Propager aux appels suivants
    HttpHeaders headers = new HttpHeaders();
    headers.add("X-Correlation-Id", correlationId);
    restTemplate.postForEntity(url, body, String.class);
    
    MDC.remove("correlationId");
}
```

**Query dans Application Insights :**

```kql
traces
| where customDimensions.correlationId == "abc-123-def-456"
| project timestamp, message, operation_Name, cloud_RoleName
| order by timestamp asc
```

---

## 📚 Ressources

- [Azure Architecture Center - Event-Driven](https://learn.microsoft.com/en-us/azure/architecture/guide/architecture-styles/event-driven)
- [Azure Well-Architected Framework](https://learn.microsoft.com/azure/well-architected/)
- [Resilience4j Documentation](https://resilience4j.readme.io/)
- [Azure Security Best Practices](https://learn.microsoft.com/azure/security/fundamentals/best-practices-and-patterns)

---

[← Retour au workshop](./workshop.md)
