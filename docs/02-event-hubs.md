# Module 2 : Déploiement de l'Architecture de Référence

## 🎯 Objectifs

Dans ce module, vous allez **déployer l'intégralité de l'architecture de référence** vue en module 1. Deux méthodes sont proposées — choisissez celle qui correspond à votre contexte :

| | Méthode | Quand l'utiliser |
|---|---|---|
| 🔧 | **Azure CLI** — commande par commande | Comprendre chaque service en détail, démo pas à pas |
| 🏗️ | **Bicep** — infrastructure as code | Déploiement reproductible, CI/CD, projet réel |

> Les **variables d'initialisation** (section ①) sont communes aux deux méthodes.

```
Sources ──> Azure Functions ──> Event Hubs ──┬──> App Consommatrice
                                              └──> Stream Analytics ──> Cosmos DB
                                                       Cosmos DB change feed
                                                              ↓
                                                        Event Grid ──> Handlers
```

**Pré-requis :**
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) installé (`az --version`)
- Être connecté : `az login`
- Un abonnement Azure actif

---

## ① Initialisation

### Variables globales

Copiez ce bloc en entier dans votre terminal. Toutes les commandes suivantes s'y réfèrent.

```bash
# Identifiant unique pour éviter les conflits de noms
SUFFIX=$RANDOM

# Groupe de ressources
RG="rg-eda-workshop"
LOCATION="francecentral"

# Event Hubs
EH_NAMESPACE="evhns-workshop-$SUFFIX"
EH_NAME="business-events"
EH_CG_APP="cg-app"        # Consumer Group A → App consommatrice
EH_CG_SA="cg-analytics"   # Consumer Group B → Stream Analytics

# Storage (checkpoints consommateurs)
STORAGE_ACCOUNT="stworkshop$SUFFIX"
CHECKPOINT_CONTAINER="eh-checkpoints"

# Azure Functions
FUNC_APP="func-ingest-$SUFFIX"

# Cosmos DB
COSMOS_ACCOUNT="cosmos-workshop-$SUFFIX"
COSMOS_DB="eda-db"
COSMOS_CONTAINER="events"

# Stream Analytics
SA_JOB="sa-workshop-$SUFFIX"

# Event Grid
EG_TOPIC="egt-workshop-$SUFFIX"
EG_SUBSCRIPTION="egs-notification"
```

### Resource Group

```bash
az group create \
  --name $RG \
  --location $LOCATION

echo "✅ Resource Group créé : $RG"
```

---

## 🔧 Méthode 1 — Azure CLI

> Déployez chaque service étape par étape. Idéal pour comprendre le rôle de chaque composant et observer son comportement avant de passer au suivant.

## ② Azure Event Hubs

Event Hubs est le **cœur du pipeline**. On le déploie en premier — tout le reste s'y connecte.

### Namespace

```bash
az eventhubs namespace create \
  --name $EH_NAMESPACE \
  --resource-group $RG \
  --location $LOCATION \
  --sku Standard \
  --capacity 1

echo "✅ Namespace créé : $EH_NAMESPACE"
```

> **Standard** = 20 consumer groups, rétention 7 jours, compatibilité Kafka. Suffisant pour ce workshop.

### Event Hub

```bash
az eventhubs eventhub create \
  --name $EH_NAME \
  --namespace-name $EH_NAMESPACE \
  --resource-group $RG \
  --partition-count 4 \
  --retention-time-in-hours 168

echo "✅ Event Hub créé : $EH_NAME (4 partitions, rétention 7j)"
```

### Consumer Groups

Deux consumer groups indépendants — chacun lit le stream à son propre rythme, avec son propre offset.

```bash
# Consumer Group A → App consommatrice (dashboard, microservice)
az eventhubs eventhub consumer-group create \
  --name $EH_CG_APP \
  --eventhub-name $EH_NAME \
  --namespace-name $EH_NAMESPACE \
  --resource-group $RG

# Consumer Group B → Stream Analytics
az eventhubs eventhub consumer-group create \
  --name $EH_CG_SA \
  --eventhub-name $EH_NAME \
  --namespace-name $EH_NAMESPACE \
  --resource-group $RG

echo "✅ Consumer Groups créés : $EH_CG_APP | $EH_CG_SA"
```

### Policies d'accès

Principe du **moindre privilège** — chaque composant n'a accès qu'à ce dont il a besoin.

```bash
# Policy producteur (Send uniquement)
az eventhubs namespace authorization-rule create \
  --name "policy-producer" \
  --namespace-name $EH_NAMESPACE \
  --resource-group $RG \
  --rights Send

# Policy consommateur (Listen uniquement)
az eventhubs namespace authorization-rule create \
  --name "policy-consumer" \
  --namespace-name $EH_NAMESPACE \
  --resource-group $RG \
  --rights Listen

echo "✅ Policies créées : policy-producer | policy-consumer"
```

### Récupérer les connection strings

```bash
EH_PRODUCER_CS=$(az eventhubs namespace authorization-rule keys list \
  --namespace-name $EH_NAMESPACE \
  --resource-group $RG \
  --name "policy-producer" \
  --query primaryConnectionString \
  --output tsv)

EH_CONSUMER_CS=$(az eventhubs namespace authorization-rule keys list \
  --namespace-name $EH_NAMESPACE \
  --resource-group $RG \
  --name "policy-consumer" \
  --query primaryConnectionString \
  --output tsv)

echo "✅ Connection strings récupérées"
```

### Vérification

```bash
az eventhubs eventhub consumer-group list \
  --eventhub-name $EH_NAME \
  --namespace-name $EH_NAMESPACE \
  --resource-group $RG \
  --output table
```

Vous devez voir : `$default`, `cg-app`, `cg-analytics`.

---

## ③ Storage Account

Nécessaire pour les **checkpoints** des consommateurs Event Hubs et le **déploiement** de la Function App.

```bash
az storage account create \
  --name $STORAGE_ACCOUNT \
  --resource-group $RG \
  --location $LOCATION \
  --sku Standard_LRS \
  --kind StorageV2

az storage container create \
  --name $CHECKPOINT_CONTAINER \
  --account-name $STORAGE_ACCOUNT \
  --auth-mode login

STORAGE_CS=$(az storage account show-connection-string \
  --name $STORAGE_ACCOUNT \
  --resource-group $RG \
  --query connectionString \
  --output tsv)

echo "✅ Storage Account créé : $STORAGE_ACCOUNT"
```

---

## ④ Azure Functions — Ingestion HTTP

La Function joue le rôle d'**adaptateur** entre les clients HTTP et Event Hubs : elle valide, normalise et publie dans le stream.

### Créer la Function App

```bash
az functionapp create \
  --name $FUNC_APP \
  --resource-group $RG \
  --consumption-plan-location $LOCATION \
  --runtime python \
  --runtime-version 3.11 \
  --functions-version 4 \
  --storage-account $STORAGE_ACCOUNT \
  --os-type Linux

echo "✅ Function App créée : $FUNC_APP"
```

### Configurer les variables d'application

```bash
az functionapp config appsettings set \
  --name $FUNC_APP \
  --resource-group $RG \
  --settings \
    "EVENT_HUB_CONNECTION_STRING=$EH_PRODUCER_CS" \
    "EVENT_HUB_NAME=$EH_NAME"

echo "✅ Variables configurées sur la Function App"
```

> **Code applicatif** : l'implémentation de la fonction (validation, normalisation, publication dans Event Hubs) sera couverte dans un module dédié. L'infrastructure est prête à recevoir le code.

---

## ⑤ Azure Cosmos DB

Cosmos DB stocke les **agrégats produits par Stream Analytics** — pas les événements bruts (ceux-ci restent dans Event Hubs pendant la durée de rétention).

```bash
az cosmosdb create \
  --name $COSMOS_ACCOUNT \
  --resource-group $RG \
  --locations regionName=$LOCATION \
  --default-consistency-level Session \
  --enable-free-tier true

echo "✅ Compte Cosmos DB créé : $COSMOS_ACCOUNT"

az cosmosdb sql database create \
  --account-name $COSMOS_ACCOUNT \
  --resource-group $RG \
  --name $COSMOS_DB

az cosmosdb sql container create \
  --account-name $COSMOS_ACCOUNT \
  --resource-group $RG \
  --database-name $COSMOS_DB \
  --name $COSMOS_CONTAINER \
  --partition-key-path "/entityId" \
  --throughput 400

COSMOS_KEY=$(az cosmosdb keys list \
  --name $COSMOS_ACCOUNT \
  --resource-group $RG \
  --query primaryMasterKey \
  --output tsv)

echo "✅ Base de données et container créés"
```

> **Free tier** : 1000 RU/s et 25 GB gratuits par abonnement.

---

## ⑥ Azure Stream Analytics

Stream Analytics consomme le **Consumer Group B** d'Event Hubs, agrège par fenêtre temporelle, et écrit dans Cosmos DB.

### Créer le job

```bash
az stream-analytics job create \
  --name $SA_JOB \
  --resource-group $RG \
  --location $LOCATION \
  --output-error-policy Drop \
  --events-out-of-order-policy Adjust \
  --events-out-of-order-max-delay-in-seconds 5 \
  --compatibility-level 1.2

echo "✅ Stream Analytics job créé : $SA_JOB"
```

### Configurer l'entrée (Event Hubs)

```bash
SA_CONSUMER_KEY=$(az eventhubs namespace authorization-rule keys list \
  --namespace-name $EH_NAMESPACE \
  --resource-group $RG \
  --name "policy-consumer" \
  --query primaryKey \
  --output tsv)

az stream-analytics input create \
  --job-name $SA_JOB \
  --resource-group $RG \
  --name "input-eventhub" \
  --properties '{
    "type": "Stream",
    "datasource": {
      "type": "Microsoft.ServiceBus/EventHub",
      "properties": {
        "eventHubName": "'"$EH_NAME"'",
        "serviceBusNamespace": "'"$EH_NAMESPACE"'",
        "consumerGroupName": "'"$EH_CG_SA"'",
        "sharedAccessPolicyName": "policy-consumer",
        "sharedAccessPolicyKey": "'"$SA_CONSUMER_KEY"'"
      }
    },
    "serialization": { "type": "Json", "properties": { "encoding": "UTF8" } }
  }'

echo "✅ Entrée Event Hubs configurée"
```

### Configurer la sortie (Cosmos DB)

```bash
az stream-analytics output create \
  --job-name $SA_JOB \
  --resource-group $RG \
  --name "output-cosmos" \
  --properties '{
    "datasource": {
      "type": "Microsoft.Storage/DocumentDB",
      "properties": {
        "accountId": "'"$COSMOS_ACCOUNT"'",
        "accountKey": "'"$COSMOS_KEY"'",
        "database": "'"$COSMOS_DB"'",
        "collectionNamePattern": "'"$COSMOS_CONTAINER"'",
        "partitionKey": "entityId",
        "documentId": "aggregateId"
      }
    }
  }'

echo "✅ Sortie Cosmos DB configurée"
```

### Requête de transformation

```bash
az stream-analytics transformation create \
  --job-name $SA_JOB \
  --resource-group $RG \
  --name "transformation" \
  --streaming-units 1 \
  --query-statement "
    SELECT
        System.Timestamp()  AS windowEnd,
        type                AS eventType,
        entityId,
        COUNT(*)            AS eventCount,
        MIN(timestamp)      AS firstSeen,
        MAX(timestamp)      AS lastSeen,
        CONCAT(type, '-', entityId, '-',
               CAST(System.Timestamp() AS nvarchar(max))) AS aggregateId
    INTO [output-cosmos]
    FROM [input-eventhub] TIMESTAMP BY timestamp
    GROUP BY
        type,
        entityId,
        TumblingWindow(minute, 1)
  "

echo "✅ Requête configurée"
```

> **TumblingWindow(minute, 1)** : agrège tous les événements du même type pour la même entité par fenêtre d'1 minute, sans overlap.

### Démarrer le job

```bash
az stream-analytics job start \
  --name $SA_JOB \
  --resource-group $RG \
  --output-start-mode LastOutputEventTime

echo "✅ Stream Analytics démarré"
```

---

## ⑦ Azure Event Grid

Event Grid reçoit les événements du **change feed Cosmos DB** et les route vers les handlers — sans que le reste du pipeline ne le sache.

### Créer un topic custom

```bash
az eventgrid topic create \
  --name $EG_TOPIC \
  --resource-group $RG \
  --location $LOCATION

EG_ENDPOINT=$(az eventgrid topic show \
  --name $EG_TOPIC \
  --resource-group $RG \
  --query endpoint \
  --output tsv)

EG_KEY=$(az eventgrid topic key list \
  --name $EG_TOPIC \
  --resource-group $RG \
  --query key1 \
  --output tsv)

echo "✅ Event Grid Topic créé : $EG_TOPIC"
```

### Créer une subscription

```bash
# Remplacez par votre endpoint de test (ex: https://webhook.site/votre-id)
WEBHOOK_URL="https://webhook.site/votre-id-unique"

az eventgrid event-subscription create \
  --name $EG_SUBSCRIPTION \
  --source-resource-id $(az eventgrid topic show \
    --name $EG_TOPIC \
    --resource-group $RG \
    --query id \
    --output tsv) \
  --endpoint $WEBHOOK_URL \
  --endpoint-type webhook

echo "✅ Subscription Event Grid créée → $WEBHOOK_URL"
```

---

## 🏗️ Méthode 2 — Bicep (Infrastructure as Code)

> Bicep est le langage IaC natif d'Azure. **Un fichier, une commande** — Azure gère les dépendances entre ressources et les déploie dans le bon ordre automatiquement.

### Créer le fichier `infra/main.bicep`

```bash
mkdir infra
```

Copiez le contenu suivant dans `infra/main.bicep` :

```bicep
@description('Suffixe unique pour les noms de ressources (ex: $RANDOM en bash)')
param suffix string = uniqueString(resourceGroup().id)

@description('Région Azure')
param location string = resourceGroup().location

@description('URL du webhook Event Grid (ex: https://webhook.site/votre-id)')
param webhookUrl string

// ──────────────────────────────────────────────────────────────────
// ① Event Hubs — Bus de streaming central
// ──────────────────────────────────────────────────────────────────

resource ehNamespace 'Microsoft.EventHub/namespaces@2024-01-01' = {
  name: 'evhns-workshop-${suffix}'
  location: location
  sku: { name: 'Standard', tier: 'Standard', capacity: 1 }
}

resource eventHub 'Microsoft.EventHub/namespaces/eventhubs@2024-01-01' = {
  parent: ehNamespace
  name: 'business-events'
  properties: {
    partitionCount: 4
    retentionDescription: {
      retentionTimeInHours: 168
      cleanupPolicy: 'Delete'
    }
  }
}

resource cgApp 'Microsoft.EventHub/namespaces/eventhubs/consumergroups@2024-01-01' = {
  parent: eventHub
  name: 'cg-app'
}

resource cgAnalytics 'Microsoft.EventHub/namespaces/eventhubs/consumergroups@2024-01-01' = {
  parent: eventHub
  name: 'cg-analytics'
}

resource authProducer 'Microsoft.EventHub/namespaces/authorizationRules@2024-01-01' = {
  parent: ehNamespace
  name: 'policy-producer'
  properties: { rights: ['Send'] }
}

resource authConsumer 'Microsoft.EventHub/namespaces/authorizationRules@2024-01-01' = {
  parent: ehNamespace
  name: 'policy-consumer'
  properties: { rights: ['Listen'] }
}

// ──────────────────────────────────────────────────────────────────
// ② Storage — Checkpoints consommateurs + déploiement Functions
// ──────────────────────────────────────────────────────────────────

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: 'stworkshop${suffix}'
  location: location
  sku: { name: 'Standard_LRS' }
  kind: 'StorageV2'
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = {
  parent: storageAccount
  name: 'default'
}

resource checkpointContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  parent: blobService
  name: 'eh-checkpoints'
  properties: { publicAccess: 'None' }
}

// ──────────────────────────────────────────────────────────────────
// ③ Azure Functions — Adaptateur HTTP → Event Hubs
// ──────────────────────────────────────────────────────────────────

resource hostingPlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: 'asp-workshop-${suffix}'
  location: location
  sku: { name: 'Y1', tier: 'Dynamic' }
  kind: 'linux'
  properties: { reserved: true }
}

var storageCs = 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value};EndpointSuffix=core.windows.net'

resource functionApp 'Microsoft.Web/sites@2023-12-01' = {
  name: 'func-ingest-${suffix}'
  location: location
  kind: 'functionapp,linux'
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      linuxFxVersion: 'Python|3.11'
      appSettings: [
        { name: 'AzureWebJobsStorage',         value: storageCs }
        { name: 'FUNCTIONS_EXTENSION_VERSION',  value: '~4' }
        { name: 'FUNCTIONS_WORKER_RUNTIME',     value: 'python' }
        { name: 'EVENT_HUB_CONNECTION_STRING',  value: authProducer.listKeys().primaryConnectionString }
        { name: 'EVENT_HUB_NAME',               value: eventHub.name }
      ]
    }
  }
}

// ──────────────────────────────────────────────────────────────────
// ④ Cosmos DB — Persistance des agrégats Stream Analytics
// ──────────────────────────────────────────────────────────────────

resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2024-05-15' = {
  name: 'cosmos-workshop-${suffix}'
  location: location
  properties: {
    databaseAccountOfferType: 'Standard'
    enableFreeTier: true
    consistencyPolicy: { defaultConsistencyLevel: 'Session' }
    locations: [{ locationName: location, failoverPriority: 0, isZoneRedundant: false }]
  }
}

resource cosmosDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2024-05-15' = {
  parent: cosmosAccount
  name: 'eda-db'
  properties: { resource: { id: 'eda-db' } }
}

resource cosmosContainer 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2024-05-15' = {
  parent: cosmosDatabase
  name: 'events'
  properties: {
    resource: {
      id: 'events'
      partitionKey: { paths: ['/entityId'], kind: 'Hash' }
    }
    options: { autoscaleSettings: { maxThroughput: 1000 } }
  }
}

// ──────────────────────────────────────────────────────────────────
// ⑤ Stream Analytics — Agrégation TumblingWindow(1 min)
// ──────────────────────────────────────────────────────────────────

resource saJob 'Microsoft.StreamAnalytics/streamingjobs@2021-10-01-preview' = {
  name: 'sa-workshop-${suffix}'
  location: location
  properties: {
    sku: { name: 'Standard' }
    eventsOutOfOrderPolicy: 'Adjust'
    outputErrorPolicy: 'Stop'
    eventsOutOfOrderMaxDelayInSeconds: 0
  }
}

resource saInput 'Microsoft.StreamAnalytics/streamingjobs/inputs@2021-10-01-preview' = {
  parent: saJob
  name: 'input-eventhub'
  properties: {
    type: 'Stream'
    datasource: {
      type: 'Microsoft.EventHub/EventHub'
      properties: {
        serviceBusNamespace: ehNamespace.name
        eventHubName: eventHub.name
        consumerGroupName: cgAnalytics.name
        authenticationMode: 'ConnectionString'
        sharedAccessPolicyName: authConsumer.name
        sharedAccessPolicyKey: authConsumer.listKeys().primaryKey
      }
    }
    serialization: {
      type: 'Json'
      properties: { encoding: 'UTF8' }
    }
  }
}

resource saOutput 'Microsoft.StreamAnalytics/streamingjobs/outputs@2021-10-01-preview' = {
  parent: saJob
  name: 'output-cosmos'
  properties: {
    datasource: {
      type: 'Microsoft.Storage/DocumentDB'
      properties: {
        accountId: cosmosAccount.name
        accountKey: cosmosAccount.listKeys().primaryMasterKey
        database: cosmosDatabase.name
        collectionNamePattern: cosmosContainer.name
        partitionKey: 'entityId'
        documentId: 'windowEnd'
      }
    }
  }
}

resource saTransformation 'Microsoft.StreamAnalytics/streamingjobs/transformations@2021-10-01-preview' = {
  parent: saJob
  name: 'Transformation'
  properties: {
    streamingUnits: 1
    query: '''
SELECT
    type,
    entityId,
    COUNT(*) AS eventCount,
    System.Timestamp() AS windowEnd
INTO [output-cosmos]
FROM [input-eventhub] TIMESTAMP BY timestamp
GROUP BY type, entityId, TumblingWindow(minute, 1)
    '''
  }
}

// ──────────────────────────────────────────────────────────────────
// ⑥ Event Grid — Routing réactif depuis Cosmos DB change feed
// ──────────────────────────────────────────────────────────────────

resource egTopic 'Microsoft.EventGrid/topics@2022-06-15' = {
  name: 'egt-workshop-${suffix}'
  location: location
}

resource egSubscription 'Microsoft.EventGrid/eventSubscriptions@2022-06-15' = {
  name: 'egs-notification'
  scope: egTopic
  properties: {
    destination: {
      endpointType: 'WebHook'
      properties: { endpointUrl: webhookUrl }
    }
    filter: { includedEventTypes: [] }
  }
}

// ──────────────────────────────────────────────────────────────────
// Outputs — récupérés après déploiement
// ──────────────────────────────────────────────────────────────────

output functionAppUrl    string = 'https://${functionApp.name}.azurewebsites.net/api/ingest'
output functionAppName   string = functionApp.name
output ehNamespaceName   string = ehNamespace.name
output cosmosAccountName string = cosmosAccount.name
output saJobName         string = saJob.name
output egTopicEndpoint   string = egTopic.properties.endpoint
```

### Déployer

```bash
# 1. Créer le Resource Group
az group create \
  --name $RG \
  --location $LOCATION

# 2. Déployer le template Bicep
az deployment group create \
  --resource-group $RG \
  --template-file infra/main.bicep \
  --parameters \
      suffix=$SUFFIX \
      webhookUrl="https://webhook.site/votre-id-unique" \
  --name "deploy-eda-workshop"

echo "✅ Infrastructure déployée"
```

### Récupérer les outputs

```bash
az deployment group show \
  --resource-group $RG \
  --name "deploy-eda-workshop" \
  --query "properties.outputs" \
  --output json
```

### Démarrer le job Stream Analytics

> Bicep crée le job mais ne peut pas le démarrer directement — Azure requiert une API séparée pour le passage en mode `Running`.

```bash
SA_JOB_NAME=$(az deployment group show \
  --resource-group $RG \
  --name "deploy-eda-workshop" \
  --query "properties.outputs.saJobName.value" \
  --output tsv)

az stream-analytics job start \
  --job-name $SA_JOB_NAME \
  --resource-group $RG \
  --output-start-mode JobStartTime

echo "✅ Stream Analytics démarré : $SA_JOB_NAME"
```

> **Déploiement du code** : le code applicatif de la Function App sera déployé dans un module dédié, une fois l'implémentation écrite.

---

## ⑧ Validation de l'Infrastructure

Une fois le déploiement terminé, vérifiez que toutes les ressources sont bien créées :

```bash
# Lister les ressources du Resource Group
az resource list \
  --resource-group $RG \
  --output table
```

```bash
# Vérifier le statut du job Stream Analytics
az stream-analytics job show \
  --name $SA_JOB \
  --resource-group $RG \
  --query "properties.jobState" \
  --output tsv
```

```bash
# Vérifier la Function App
az functionapp show \
  --name $FUNC_APP \
  --resource-group $RG \
  --query "state" \
  --output tsv
```

L'infrastructure est validée quand toutes les ressources apparaissent avec le statut `Running` ou `Succeeded`.

---

## 📋 Récapitulatif des ressources déployées

| Service | Rôle dans l'architecture |
|---------|--------------------------|
| Event Hubs Namespace + Event Hub | Bus de streaming central, 4 partitions, rétention 7j |
| Consumer Group `cg-app` | Lecture temps réel (app consommatrice) |
| Consumer Group `cg-analytics` | Lecture analytique (Stream Analytics) |
| Storage Account | Checkpoints + déploiement Function |
| Function App | Adaptateur HTTP → Event Hubs (validation + normalisation) |
| Cosmos DB | Persistance des agrégats Stream Analytics |
| Stream Analytics | Agrégation TumblingWindow(1 min) par type + entité |
| Event Grid Topic | Routing réactif des événements depuis Cosmos DB |

---

## ➡️ Prochaine Étape

L'infrastructure est en place. Dans le module suivant, on plonge dans les **concepts avancés d'Event Hubs** : partitionnement, backpressure, replay, et patterns de consommation.

**[Module 3 : Azure Event Hubs - Concepts Avancés →](./03-event-hubs-advanced.md)**

---

[← Module précédent](./01-azure-event-services.md) | [Retour au sommaire](./workshop.md)
