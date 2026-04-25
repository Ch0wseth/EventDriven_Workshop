---
published: true
type: workshop
title: Architecture Event-Driven sur Azure
short_title: Event-Driven Azure
description: Apprenez à construire des architectures event-driven robustes et scalables sur Microsoft Azure
level: intermediate
authors:
  - Workshop Creator
contacts:
  - '@github_username'
duration_minutes: 240
tags: azure, event-driven, architecture, event-hubs, service-bus, event-grid, messaging, microservices
banner_url: assets/banner.jpg
---

# Architecture Event-Driven sur Azure

Bienvenue dans ce workshop pratique sur l'architecture event-driven (pilotée par les événements) dans Microsoft Azure !

## 🎯 Objectifs d'apprentissage

À la fin de ce workshop, vous serez capable de :

- ✅ Comprendre les principes fondamentaux de l'architecture event-driven
- ✅ Différencier et choisir entre Azure Event Hubs, Service Bus et Event Grid
- ✅ Concevoir des systèmes découplés et scalables
- ✅ Implémenter des patterns event-driven courants
- ✅ Déployer et monitorer des solutions event-driven sur Azure

## 📋 Prérequis

Avant de commencer ce workshop, assurez-vous d'avoir :

- Un compte Azure actif ([Créer un compte gratuit](https://azure.microsoft.com/free/))
- [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli) installé
- **Langage au choix** :
  - [Java 17+](https://adoptium.net/) + [Maven 3.8+](https://maven.apache.org/) **⭐ Recommandé**
  - [.NET 8 SDK](https://dotnet.microsoft.com/download)
  - [Python 3.8+](https://www.python.org/)
  - [Node.js 18+](https://nodejs.org/)
- [Visual Studio Code](https://code.visualstudio.com/) avec extensions Azure
- Connaissances de base en développement d'applications cloud

## 📚 Structure du Workshop

### [Module 0 : Introduction](./00-introduction.md)

Découvrez les concepts fondamentaux de l'architecture event-driven et pourquoi elle est essentielle dans les systèmes modernes.

### [Module 1 : Services Azure pour l'Event-Driven](./01-azure-event-services.md)

Découvrez Azure Event Hubs et Event Grid, les deux piliers du streaming et de l'événementiel sur Azure.

### [Module 2 : Azure Event Hubs - Fondamentaux](./02-event-hubs.md)

Apprenez à ingérer et traiter des millions d'événements par seconde avec Event Hubs.

**Lab pratique :** Créer un Event Hub et implémenter un producteur/consommateur.

### [Module 3 : Azure Event Hubs - Avancé](./03-event-hubs-advanced.md)

Maîtrisez les concepts avancés : partitionnement, consumer groups, checkpointing, et Kafka compatibility.

**Lab pratique :** Implémenter un pipeline de télémétrie IoT à grande échelle.

### [Module 3b : Event Hubs Deep Dive Expert](./03b-event-hubs-deepdive.md) 🚀 **NOUVEAU**

**Optionnel mais recommandé pour la production**

Deep dive technique complet pour les ingénieurs qui veulent maîtriser Event Hubs en profondeur.

**Contenu Expert :**
- **Performance Engineering** : Calculs précis TU/PU, auto-inflate, capacity planning, benchmarking (load testing 50k events/s)
- **Schema Registry avec Avro** : Gestion de schémas, validation, évolution backward/forward compatible
- **Geo-Replication & DR** : Configuration Geo-DR, failover procedures, Active-Active architecture
- **Networking Deep Dive** : Private Link, VNet integration, firewall rules, Service Endpoints
- **Security Expert** : RBAC granulaire, CMK encryption, audit logging avancé
- **Observability** : Métriques critiques, alertes intelligentes, distributed tracing OpenTelemetry
- **Cost Optimization & FinOps** : Calculs précis, break-even analysis Standard vs Premium, stratégies d'économie
- **Architecture Patterns** : Lambda Architecture, Hot/Warm/Cold paths, Event Sourcing

**Lab pratique :** Load testing, schema evolution, geo-failover simulation

**Pour qui ?** Ingénieurs préparant un déploiement production critique avec Event Hubs.

### [Module 4 : Azure Event Grid - Lightweight](./04-event-grid.md)

Découvrez le routage d'événements serverless avec Event Grid pour des intégrations simples.

**Lab pratique :** Réagir aux événements Azure (Blob Storage) avec Azure Functions.

### [Module 5 : Lab Final - Pipeline Complet](./06-hands-on-lab.md)

Construisez un système complet de monitoring et observabilité avec Event Hubs, Stream Analytics, Event Grid et Application Insights.

**Architecture inspirée de** : [Monitoring Observable Systems - Microsoft Learn](https://learn.microsoft.com/en-us/azure/architecture/example-scenario/monitoring/monitoring-observable-systems-media)

### [Module 7 : Foundry Agents + Event-Driven - Pipeline Intelligent en Temps Réel](./07-foundry-event-driven.md) ⭐ **NOUVEAU**

Combinez Event Hubs avec Microsoft Foundry Agents pour créer un pipeline intelligent autonome qui traite, analyse et réagit aux événements en temps réel avec intelligence contextuelle.

**Lab pratique :** Système intelligent de support client
- Ingestion des tickets avec Event Hubs (streaming)
- Agent Foundry (GPT-4o) pour analyse contextuelle, catégorisation (Technical/Billing/Product), priorisation (P0-P3), génération de réponses suggérées
- Azure Functions (Java) pour orchestration event-driven
- Enrichissement automatique avec métadonnées IA et stockage Cosmos DB
- Alertes intelligentes pour tickets urgents (P0/P1)
- Foundry Tracing + Prompt Optimization automatique
- Feedback loop : Dataset creation → Batch Evaluation → Prompt Optimizer

**Patterns avancés** : Agent-per-Stream, Multi-Agent Workflows, RAG avec Knowledge Base

**Cas d'usage** : Support Client Autonome, Triage Intelligent, Agent Orchestration, Décisions Temps Réel

---

## 🚀 Commencer

### Prérequis de Lecture

Avant de démarrer les labs, **nous vous recommandons fortement** de lire :

📘 **[Event-Driven Architecture Style - Microsoft Learn](https://learn.microsoft.com/en-us/azure/architecture/guide/architecture-styles/event-driven)**

Ce guide officiel vous donnera une excellente base théorique sur :
- Les principes de l'architecture event-driven
- Pub/Sub vs Event Streaming (Event Grid vs Event Hubs)
- Les challenges et solutions (ordre, eventual consistency, observabilité)

### 🛡️ **Guide Production : Sécurité, Résilience et Principes**

Avant de déployer en production, **lisez absolument** :

📘 **[PRODUCTION_GUIDE.md](./PRODUCTION_GUIDE.md)** ⭐ **CRITICAL**
- **Pourquoi** faire ceci ou cela (partitions, checkpointing, batches)
- **Sécurité** : Managed Identity, Key Vault, Network Security, Audit
- **Résilience** : Retry, Circuit Breaker, Idempotence, Dead Letter, Health Checks
- **Principes** : Single Responsibility, Versioning, Correlation IDs

### Installation

1. Clonez ce repository :
```bash
git clone https://github.com/your-org/EventDriven_Workshop.git
cd EventDriven_Workshop
```

2. Connectez-vous à Azure :
```bash
az login
az account set --subscription "YOUR_SUBSCRIPTION_ID"
```

3. Commencez par le [Module 0 : Introduction](./00-introduction.md)

## 🎯 Objectifs d'Apprentissage

À l'issue de ce workshop, vous maîtriserez :

- 🚀 **Event Hubs pour le streaming haute performance**
  - Ingestion de millions d'événements/seconde
  - Partitionnement et parallélisation
  - Consumer groups et checkpointing
  - Intégration avec Kafka
  - Capture automatique vers Data Lake

- ⚡ **Event Grid pour l'intégration serverless**
  - Réaction aux événements Azure
  - Webhooks et Azure Functions
  - Routage intelligent

- 📊 **Architectures de streaming en production**
  - Traitement en temps réel
  - Analytics et monitoring
  - Scalabilité et résilience

## 📖 Ressources Supplémentaires

- [Documentation officielle Azure Event Hubs](https://docs.microsoft.com/azure/event-hubs/)
- [Azure Event Grid Documentation](https://docs.microsoft.com/azure/event-grid/)
- [Stream Analytics avec Event Hubs](https://docs.microsoft.com/azure/stream-analytics/)
- [Ressources et liens utiles](./resources.md)

## 🤝 Contribution

Ce workshop est open source ! N'hésitez pas à contribuer en créant des issues ou des pull requests.

## 📄 Licence

Ce contenu est sous licence [Creative Commons Attribution 4.0 International](https://creativecommons.org/licenses/by/4.0/).

---

Prêt à commencer ? Rendez-vous au [Module 0 : Introduction](./00-introduction.md) ! 🚀
