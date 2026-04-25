# Architecture Event-Driven sur Azure - Workshop Complet

[![License: CC BY 4.0](https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by/4.0/)
[![Azure](https://img.shields.io/badge/Azure-Event--Driven-0078D4?logo=microsoft-azure)](https://azure.microsoft.com)

Un workshop pratique et complet pour apprendre à construire des architectures event-driven robustes et scalables sur Microsoft Azure.

> 🌐 **[Accéder au site web interactif du workshop](website/)** - Navigation moderne, dark mode, recherche, progression sauvegardée

## 🎯 À propos de ce Workshop

Ce workshop vous guide à travers le **streaming event-driven** avec **Azure Event Hubs** et une introduction à **Azure Event Grid**. Vous apprendrez à concevoir, implémenter et déployer des systèmes de streaming haute performance, scalables et résilients.

### Ce que vous allez apprendre

- ✅ **Fondamentaux** de l'architecture event-driven et du streaming
- ✅ **Azure Event Hubs en profondeur** : ingestion, partitionnement, consumer groups
- ✅ **Event Hubs avancé** : Kafka compatibility, Capture, checkpointing
- ✅ **Azure Event Grid** : intégration légère et serverless
- ✅ **Patterns de streaming** : Event Sourcing, Stream Processing, Lambda Architecture
- ✅ **Best practices** pour la production et le monitoring

## 📚 Structure du Workshop

Le workshop est organisé en **7 modules progressifs** avec des labs pratiques :

| Module | Titre | Type |
|--------|-------|------|
| **[0](docs/00-introduction.md)** | Introduction à l'Event-Driven | 📖 Théorie |
| **[1](docs/01-azure-event-services.md)** | Event Hubs vs Event Grid | 📖 Théorie |
| **[2](docs/02-event-hubs.md)** | Azure Event Hubs - Fondamentaux | 💻 Lab |
| **[3](docs/03-event-hubs-advanced.md)** | Azure Event Hubs - Avancé | 💻 Lab |
| **[4](docs/04-event-grid.md)** | Azure Event Grid | 💻 Lab |
| **[5](docs/06-hands-on-lab.md)** | Lab Final - Pipeline Complet | 💻 Lab |
| **[7](docs/07-foundry-event-driven.md)** | **Foundry Agents + Event-Driven** ⭐ **NOUVEAU** | 💻 Lab |

**Focus** : 🎯 **80% Event Hubs** | 15% Concepts | 5% Event Grid

> 💡 **Nouveau !** Module 3b optionnel : Deep Dive expert pour maîtriser Event Hubs en profondeur (performance, schema registry, geo-DR, networking, cost optimization)

### 🚀 Module 3b - Event Hubs Deep Dive Expert (NOUVEAU !)

Le nouveau **Module 3b optionnel** est un deep dive technique complet pour les ingénieurs qui veulent **vraiment maîtriser** Event Hubs en production :

- **📊 Performance Engineering** : Calculs précis TU/PU, auto-inflate, capacity planning, load testing 50k events/s
- **🗂️ Schema Registry avec Avro** : Gestion schémas, validation, évolution BACKWARD/FORWARD compatible
- **🌍 Geo-Replication & DR** : Configuration Geo-DR, failover automatique, Active-Active architecture
- **🔒 Networking Deep Dive** : Private Link, VNet, IP Firewall, Service Endpoints vs Private Link
- **📈 Observability Expert** : Métriques critiques KQL, alertes intelligentes, distributed tracing OpenTelemetry
- **💰 Cost Optimization & FinOps** : Break-even analysis (Standard vs Premium à 15 TUs), économies 48%
- **🔥 Performance Testing** : Benchmarks réels, tuning recommendations
- **🏗️ Architecture Patterns** : Lambda Architecture, Hot/Warm/Cold paths, Event Sourcing avec Event Hubs

**Pour qui ?** Ingénieurs préparant un déploiement production critique. Module **optionnel** mais fortement recommandé pour production.

### 🤖 Module 7 - Foundry Agents + Event-Driven (NOUVEAU !)

Le nouveau Module 7 vous apprend à **combiner Event Hubs avec Microsoft Foundry Agents** pour créer des pipelines intelligents autonomes en temps réel :

- **📥 Ingestion** : Event Hubs pour tickets de support
- **🤖 Agent IA Foundry** : GPT-4o pour analyse contextuelle, catégorisation, priorisation et génération de réponses
- **💾 Enrichissement** : Stockage des tickets enrichis avec métadonnées IA dans Cosmos DB
- **⚠️ Alertes Intelligentes** : Notifications automatiques pour tickets P0/P1
- **📊 Analytics** : Foundry Tracing + Prompt Optimization automatique
- **🔄 Amélioration Continue** : Feedback loop avec Batch Evaluation et Prompt Optimizer

**Cas d'usage réels** : Support Client Intelligent, Triage Automatique, Agent Orchestration, Multi-Agent Workflows

### 🛡️ Guide Production (CRITICAL)

**Avant de déployer en production**, lisez le guide complet :

📘 **[PRODUCTION_GUIDE.md](docs/PRODUCTION_GUIDE.md)** ⭐
- **Pourquoi** (partitions, checkpointing, batches)
- **Sécurité** (Managed Identity, Key Vault, Private Endpoints)
- **Résilience** (Retry, Circuit Breaker, Idempotence)

## 🚀 Démarrage Rapide

### Prérequis

Avant de commencer, assurez-vous d'avoir :

- ☁️ **Un compte Azure actif** ([Créer un compte gratuit](https://azure.microsoft.com/free/))
- 💻 **Outils installés** :
  - [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli)
  - **Langage au choix** :
    - [Java 17+](https://adoptium.net/) + [Maven 3.8+](https://maven.apache.org/) **⭐ Recommandé**
    - [.NET 8 SDK](https://dotnet.microsoft.com/download)
    - [Python 3.8+](https://www.python.org/)
    - [Node.js 18+](https://nodejs.org/)
  - [Visual Studio Code](https://code.visualstudio.com/)
- 📖 **Connaissances de base** :
  - Développement d'applications cloud
  - Concepts de base d'Azure

### Installation

1. **Clonez ce repository** :
   ```bash
   git clone https://github.com/your-org/EventDriven_Workshop.git
   cd EventDriven_Workshop
   ```

2. **Connectez-vous à Azure** :
   ```bash
   az login
   az account set --subscription "YOUR_SUBSCRIPTION_ID"
   ```

3. **Commencez le workshop** :
   
   Rendez-vous dans [docs/workshop.md](docs/workshop.md) pour démarrer !

## 📖 Documentation

### Modules du Workshop

- **[Workshop Principal](docs/workshop.md)** - Point d'entrée et sommaire complet
- **[Module 0 : Introduction](docs/00-introduction.md)** - Concepts fondamentaux
- **[Module 1 : Services Azure](docs/01-azure-event-services.md)** - Event Hubs vs Event Grid
- **[Module 2 : Event Hubs Fondamentaux](docs/02-event-hubs.md)** - Streaming haute performance
- **[Module 3 : Event Hubs Avancé](docs/03-event-hubs-advanced.md)** - Partitionnement, Kafka, Capture
- **[Module 4 : Event Grid](docs/04-event-grid.md)** - Routage depuis Cosmos DB
- **[Module 5 : Lab Final](docs/06-hands-on-lab.md)** - Pipeline Complet
- **[Module 7 : Foundry + Event-Driven](docs/07-foundry-event-driven.md)** ⭐ **NOUVEAU** - Agents IA Autonomes avec Microsoft Foundry
- **[Ressources](docs/resources.md)** - Liens et références utiles

## 🛠️ Technologies Utilisées

Ce workshop couvre les technologies suivantes :

### Services Azure (Focus Streaming)

- **Azure Event Hubs** ⭐ - Big data streaming (FOCUS PRINCIPAL)
  - Partitionnement et consumer groups
  - Kafka compatibility
  - Event Hubs Capture
  - Checkpointing avec Blob Storage
- **Azure Event Grid** - Serverless event routing (intégration légère)
- **Azure Stream Analytics** - Traitement temps réel
- **Azure Cosmos DB** - Base NoSQL pour analytics
- **Azure Blob Storage / Data Lake** - Archivage événements
- **Azure Application Insights** - Monitoring et observabilité

### Langages de Programmation

Les exemples de code sont disponibles en :
- 🟦 **.NET 8** (C#) - Recommandé
- 🟨 **JavaScript/TypeScript** (Node.js)
- 🐍 **Python**

## 🎓 Ce que vous construirez

Au cours de ce workshop, vous construirez plusieurs applications de streaming :

### Module 2 : Télémétrie IoT Basique
- Producteur d'événements (capteurs simulés)
- Consommateur avec traitement en temps réel
- Partitionnement et consumer groups
- Monitoring des métriques

### Module 3 : Pipeline IoT Avancé
- Simulation de 1000 devices à 10K events/sec
- Partitionnement par device
- Checkpointing résilient
- Kafka compatibility
- Event Hubs Capture vers Data Lake

### Module 4 : Intégration Event Grid
- Réaction aux uploads Blob Storage
- Webhooks et Azure Functions
- Filtrage et routage intelligent

### Module 6 : Pipeline IoT Complet (Lab Final)
Architecture end-to-end avec :
- Ingestion massive via Event Hubs
- Stream Analytics pour agrégation temps réel
- Cosmos DB pour analytics
- Capture automatique vers Data Lake
- Monitoring et alertes
- Visualisation Power BI (optionnel)

## 📊 Architecture Exemple (Lab Final)

```
┌──────────────────────┐
│  IoT Device Fleet    │
│  (1000 devices)      │
│  10K events/sec      │
└──────────┬───────────┘
           │ AMQP / Kafka
           ▼
┌──────────────────────┐
│   Event Hubs         │
│   16 Partitions      │
│   Retention: 7 days  │
└──────┬───────────────┘
       │
       ├─────────────────────┬──────────────────┐
       ▼                     ▼                  ▼
┌─────────────┐      ┌─────────────┐    ┌─────────────┐
│  Stream     │      │ Consumers   │    │ Capture     │
│  Analytics  │      │ (Real-time) │    │ (Archive)   │
│             │      │             │    │             │
│ Windowing   │      │ Checkpoint  │    │ Data Lake   │
│ Aggregation │      │ Processing  │    │ Parquet     │
└──────┬──────┘      └──────┬──────┘    └─────────────┘
       │                    │
       ▼                    ▼
┌─────────────┐      ┌─────────────┐
│  Power BI   │      │  Cosmos DB  │
│  Dashboard  │      │  Analytics  │
└─────────────┘      └─────────────┘
```

**Technologies** : Event Hubs + Stream Analytics + Cosmos DB + Data Lake

## 🤝 Contribution

Ce workshop est **open source** et les contributions sont les bienvenues !

### Comment contribuer

1. 🍴 **Fork** ce repository
2. 🌿 Créez une **branche** pour votre fonctionnalité
3. ✨ **Commitez** vos changements
4. 📤 **Push** vers votre fork
5. 🔃 Ouvrez une **Pull Request**

### Types de contributions recherchées

- 🐛 Corrections de bugs
- 📝 Améliorations de la documentation
- 🌍 Traductions
- ✨ Nouveaux exemples de code
- 💡 Suggestions d'améliorations

## 📄 Licence

Ce workshop est sous licence **Creative Commons Attribution 4.0 International** (CC BY 4.0).

Vous êtes libre de :
- ✅ **Partager** — copier et redistribuer le matériel
- ✅ **Adapter** — remixer, transformer et créer à partir du matériel
- ✅ **Utiliser commercialement** — à des fins commerciales

Sous les conditions suivantes :
- 📝 **Attribution** — Vous devez créditer l'œuvre

Voir [LICENSE](LICENSE) pour plus de détails.

## 🙏 Remerciements

Ce workshop a été inspiré par :
- Les documentations officielles Microsoft Azure
- Les retours de la communauté des développeurs

## 📞 Support et Contact

### Aide

Si vous rencontrez des problèmes :
1. 📖 Consultez la [documentation](docs/resources.md)
2. 🔍 Recherchez dans les [Issues](https://github.com/your-org/EventDriven_Workshop/issues)
3. 💬 Posez une question sur [Microsoft Q&A](https://docs.microsoft.com/answers/)

### Communauté

- 💬 [Discussions GitHub](https://github.com/your-org/EventDriven_Workshop/discussions)
- 🐦 Suivez les hashtags : `#AzureEventDriven` `#EventDrivenArchitecture`

---

**Prêt à commencer ?** Rendez-vous dans [docs/workshop.md](docs/workshop.md) ! 🚀

---

<p align="center">
  Made with ❤️ by the Azure Community
  <br>
  <a href="https://azure.microsoft.com">
    <img src="https://img.shields.io/badge/Azure-Event--Driven-0078D4?logo=microsoft-azure" alt="Azure">
  </a>
</p>