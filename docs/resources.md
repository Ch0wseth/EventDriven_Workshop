# Ressources et Références

Cette page regroupe toutes les ressources utiles pour approfondir vos connaissances sur l'architecture event-driven dans Azure.

## 🎯 Guides du Workshop

### 🛡️ Production-Ready

- 📘 **[PRODUCTION_GUIDE.md](./PRODUCTION_GUIDE.md)** ⭐ **MUST READ AVANT PRODUCTION**
  - **Pourquoi** faire ceci ou cela (justifications techniques complètes)
  - **Sécurité** : Managed Identity, Key Vault, Private Endpoints, Network Security, Audit
  - **Résilience** : Retry Policy, Circuit Breaker, Idempotence, Dead Letter, Health Checks
  - **Principes** : Single Responsibility, Versioning, Correlation IDs, Distributed Tracing
  - Checklist production complète avec exemples Java

## 📖 Documentation Officielle Microsoft

### Services Azure

#### Event Hubs
- [Azure Event Hubs - Documentation](https://docs.microsoft.com/azure/event-hubs/)
- [Event Hubs Quickstart - .NET](https://docs.microsoft.com/azure/event-hubs/event-hubs-dotnet-standard-getstarted-send)
- [Event Hubs for Kafka](https://docs.microsoft.com/azure/event-hubs/event-hubs-for-kafka-ecosystem-overview)
- [Event Hubs Capture](https://docs.microsoft.com/azure/event-hubs/event-hubs-capture-overview)

#### Service Bus
- [Azure Service Bus - Documentation](https://docs.microsoft.com/azure/service-bus-messaging/)
- [Service Bus Queues, Topics, and Subscriptions](https://docs.microsoft.com/azure/service-bus-messaging/service-bus-queues-topics-subscriptions)
- [Service Bus Sessions](https://docs.microsoft.com/azure/service-bus-messaging/message-sessions)
- [Dead-letter queues](https://docs.microsoft.com/azure/service-bus-messaging/service-bus-dead-letter-queues)

#### Event Grid
- [Azure Event Grid - Documentation](https://docs.microsoft.com/azure/event-grid/)
- [Event Grid Schema](https://docs.microsoft.com/azure/event-grid/event-schema)
- [Event Grid System Topics](https://docs.microsoft.com/azure/event-grid/system-topics)
- [Event Grid Filtering](https://docs.microsoft.com/azure/event-grid/event-filtering)

#### Microsoft Foundry (Module 7)
- [Microsoft Foundry Documentation](https://learn.microsoft.com/azure/ai-services/agents/)
- [Agent Framework SDK](https://github.com/microsoft/agent-framework)
  - Agent creation and deployment
  - Agent orchestration patterns
  - Multi-agent workflows
- [AI Foundry Studio](https://ai.azure.com)
  - Agent management portal
  - Prompt engineering interface
  - Deployment & monitoring
- [Foundry Tracing & Evaluation](https://learn.microsoft.com/azure/ai-services/agents/tracing)
  - Agent execution traces
  - Dataset creation from traces
  - Batch evaluation
- [Prompt Optimization Guide](https://learn.microsoft.com/azure/ai-services/agents/prompt-optimization)
  - Automatic prompt improvement
  - A/B testing prompts
  - Performance optimization
- [Event-Driven AI Pipelines](https://learn.microsoft.com/azure/architecture/ai-ml/guide/event-driven-ai)
  - Architecture patterns
  - Agent + Event Hubs integration
  - Real-time AI processing

#### Cosmos DB
- [Azure Cosmos DB - Documentation](https://learn.microsoft.com/azure/cosmos-db/)
- [Cosmos DB Java SDK](https://learn.microsoft.com/java/api/overview/azure/cosmos-readme)

### Architecture

- 📘 **[Event-Driven Architecture Style - Azure Architecture Center](https://learn.microsoft.com/en-us/azure/architecture/guide/architecture-styles/event-driven)** ⭐ **MUST READ**
  - Guide complet et officiel Microsoft
  - Architecture, patterns, topologies
  - Quand utiliser, bénéfices, challenges
  - Pub/Sub vs Event Streaming
  - Error handling, observabilité, eventual consistency

### ☕ Exemples Java

- 📘 **[JAVA_EXAMPLES.md](./JAVA_EXAMPLES.md)** ⭐ **Guide Java Complet**
  - Event Hubs Producer/Consumer
  - Kafka avec Event Hubs
  - Azure Functions Java
  - Simulateur IoT multi-thread (1000+ devices)

- [Azure SDK for Java Documentation](https://learn.microsoft.com/java/azure/)
- [Event Hubs Java SDK](https://learn.microsoft.com/java/api/overview/azure/messaging-eventhubs-readme)
- [Azure Functions Java Developer Guide](https://learn.microsoft.com/azure/azure-functions/functions-reference-java)

- [Azure Architecture Center](https://docs.microsoft.com/azure/architecture/)
- [Choosing between Azure messaging services](https://docs.microsoft.com/azure/event-grid/compare-messaging-services)
- [Asynchronous messaging options](https://docs.microsoft.com/azure/architecture/guide/technology-choices/messaging)

### Patterns

- [Cloud Design Patterns](https://docs.microsoft.com/azure/architecture/patterns/)
- [Event Sourcing pattern](https://docs.microsoft.com/azure/architecture/patterns/event-sourcing)
- [CQRS pattern](https://docs.microsoft.com/azure/architecture/patterns/cqrs)
- [Saga pattern](https://docs.microsoft.com/azure/architecture/reference-architectures/saga/saga)
- [Competing Consumers pattern](https://docs.microsoft.com/azure/architecture/patterns/competing-consumers)
- [Priority Queue pattern](https://docs.microsoft.com/azure/architecture/patterns/priority-queue)

## 📚 Livres Recommandés

### Architecture Event-Driven

- **"Designing Event-Driven Systems"** - Ben Stopford
  - Focus sur Kafka mais concepts applicables
  - [Disponible gratuitement](https://www.confluent.io/designing-event-driven-systems/)

- **"Building Event-Driven Microservices"** - Adam Bellemare
  - Patterns et best practices
  - O'Reilly Media

- **"Enterprise Integration Patterns"** - Gregor Hohpe & Bobby Woolf
  - Référence classique sur la messagerie
  - [Site web](https://www.enterpriseintegrationpatterns.com/)

### Domain-Driven Design

- **"Domain-Driven Design"** - Eric Evans (livre bleu)
  - Fondation du DDD

- **"Implementing Domain-Driven Design"** - Vaughn Vernon (livre rouge)
  - Implémentation pratique avec Event Sourcing

### Microservices

- **"Building Microservices"** - Sam Newman (2nd edition)
  - Architecture microservices moderne
  - O'Reilly Media

## 🎓 Cours et Formations

### Microsoft Learn

- [Build event-driven applications with Azure Event Hubs](https://docs.microsoft.com/learn/paths/build-event-driven-applications-event-hubs/)
- [Work with Azure Service Bus](https://docs.microsoft.com/learn/paths/work-with-azure-service-bus/)
- [Route custom events with Azure Event Grid](https://docs.microsoft.com/learn/modules/route-custom-events-azure-event-grid/)
- [Implement message-based communication workflows](https://docs.microsoft.com/learn/modules/implement-message-workflows-with-service-bus/)

### Pluralsight

- "Microsoft Azure Developer: Implement Azure Event Grid" - Jon Galloway
- "Microsoft Azure Developer: Implement Event Hubs" - Kamran Ayub
- "Microsoft Azure Developer: Implement Service Bus" - Mark Heath

### Udemy

- "Azure Event-Driven Architecture" - Packt Publishing
- "Microservices Architecture on Azure" - Rami Vemula

## 🎥 Vidéos et Présentations

### Conférences Microsoft

- [Microsoft Build - Event-Driven Architecture Sessions](https://mybuild.microsoft.com/)
- [Microsoft Ignite - Azure Messaging Sessions](https://myignite.microsoft.com/)
- [Azure Friday - Event Hubs, Service Bus, Event Grid](https://learn.microsoft.com/shows/azure-friday/)

### YouTube Channels

- [Microsoft Azure](https://www.youtube.com/c/MicrosoftAzure)
- [Azure DevOps](https://www.youtube.com/c/AzureDevOps)
- [On .NET](https://www.youtube.com/c/dotnet)

### Talks Recommandés

- "Event-Driven Architecture: The Reactive Way" - Bernd Rücker
- "Building Event-Driven Systems with Azure" - Microsoft Build sessions
- "CQRS and Event Sourcing" - Greg Young

## 🛠️ Outils et Libraries

### SDKs Azure

- [Azure SDK for .NET](https://github.com/Azure/azure-sdk-for-net)
- [Azure SDK for Python](https://github.com/Azure/azure-sdk-for-python)
- [Azure SDK for JavaScript](https://github.com/Azure/azure-sdk-for-js)
- [Azure SDK for Java](https://github.com/Azure/azure-sdk-for-java)

### CLI et Tools

- [Azure CLI](https://docs.microsoft.com/cli/azure/)
- [Azure PowerShell](https://docs.microsoft.com/powershell/azure/)
- [Azure Functions Core Tools](https://docs.microsoft.com/azure/azure-functions/functions-run-local)
- [Service Bus Explorer](https://github.com/paolosalvatori/ServiceBusExplorer)

### Infrastructure as Code

- [Azure Bicep](https://docs.microsoft.com/azure/azure-resource-manager/bicep/)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Pulumi Azure](https://www.pulumi.com/docs/clouds/azure/)

### Monitoring

- [Azure Application Insights](https://docs.microsoft.com/azure/azure-monitor/app/app-insights-overview)
- [Azure Monitor](https://docs.microsoft.com/azure/azure-monitor/)
- [Grafana for Azure](https://grafana.com/grafana/plugins/grafana-azure-monitor-datasource/)

## 📝 Blogs et Articles

### Blogs Microsoft

- [Azure Architecture Blog](https://techcommunity.microsoft.com/t5/azure-architecture-blog/bg-p/AzureArchitectureBlog)
- [Azure Integration Services Blog](https://techcommunity.microsoft.com/t5/azure-integration-services-blog/bg-p/AzureIntegrationServicesBlog)
- [.NET Blog](https://devblogs.microsoft.com/dotnet/)

### Blogs Communautaires

- [Martin Fowler - Event-Driven Architecture](https://martinfowler.com/articles/201701-event-driven.html)
- [Udi Dahan's Blog](https://udidahan.com/) - SOA, messaging, DDD
- [Chris Richardson - Microservices.io](https://microservices.io/)

### Séries d'Articles Recommandés

- "Event Sourcing: What it is and why it's awesome" - Event Store Blog
- "CQRS Journey" - Microsoft Patterns & Practices
- "Saga Pattern in Microservices" - Chris Richardson

## 🧪 Exemples et Repositories

### Microsoft Samples

- [Azure Samples - Event Hubs](https://github.com/Azure/azure-event-hubs/tree/master/samples)
- [Azure Samples - Service Bus](https://github.com/Azure/azure-service-bus/tree/master/samples)
- [Azure Samples - Event Grid](https://github.com/Azure-Samples/event-grid-dotnet-publish-consume-events)
- [eShopOnContainers](https://github.com/dotnet-architecture/eShopOnContainers) - Microservices reference app

### Community Examples

- [NServiceBus](https://github.com/Particular/NServiceBus) - Messaging framework
- [MassTransit](https://github.com/MassTransit/MassTransit) - Distributed application framework
- [CAP](https://github.com/dotnetcore/CAP) - Event Bus with local message table

## 🎯 Cas d'Usage et Success Stories

### Azure Customer Stories

- [Real-time analytics with Event Hubs](https://customers.microsoft.com/en-us/search?sq=%22event%20hubs%22&ff=&p=0&so=story_publish_date%20desc)
- [Enterprise messaging with Service Bus](https://customers.microsoft.com/en-us/search?sq=%22service%20bus%22&ff=&p=0&so=story_publish_date%20desc)

### Industries

- **Finance**: Real-time fraud detection, trading systems
- **Retail**: Inventory management, order processing
- **IoT**: Telemetry ingestion, device management
- **Healthcare**: Patient monitoring, data aggregation

## 🔍 Recherche et Papers

### Academic Papers

- "Event Sourcing in Practice" - Fowler et al.
- "CQRS and Event Sourcing" - Young
- "Saga Pattern" - Garcia-Molina & Salem

### Research

- [Microsoft Research - Distributed Systems](https://www.microsoft.com/en-us/research/research-area/systems-and-networking/)

## 💬 Communauté

### Forums et Q&A

- [Microsoft Q&A - Azure](https://docs.microsoft.com/answers/topics/azure.html)
- [Stack Overflow - Azure Event Hubs](https://stackoverflow.com/questions/tagged/azure-eventhub)
- [Stack Overflow - Azure Service Bus](https://stackoverflow.com/questions/tagged/azureservicebus)
- [Stack Overflow - Azure Event Grid](https://stackoverflow.com/questions/tagged/azure-eventgrid)

### Reddit

- [r/AZURE](https://www.reddit.com/r/AZURE/)
- [r/dotnet](https://www.reddit.com/r/dotnet/)
- [r/microservices](https://www.reddit.com/r/microservices/)

### Discord & Slack

- [Microsoft Azure Community](https://azure.microsoft.com/community/)
- [.NET Community](https://dotnet.microsoft.com/platform/community)

## 🏆 Certifications

### Microsoft Azure Certifications

- **AZ-204**: Developing Solutions for Microsoft Azure
  - Event Hubs, Service Bus, Event Grid
  - [Guide d'étude](https://docs.microsoft.com/certifications/exams/az-204)

- **AZ-305**: Designing Microsoft Azure Infrastructure Solutions
  - Architecture event-driven, patterns
  - [Guide d'étude](https://docs.microsoft.com/certifications/exams/az-305)

- **AZ-400**: Designing and Implementing Microsoft DevOps Solutions
  - CI/CD pour microservices
  - [Guide d'étude](https://docs.microsoft.com/certifications/exams/az-400)

## 🔧 Labs et Workshops

### Microsoft Hands-on Labs

- [Azure Event Hubs Workshop](https://github.com/Azure/azure-event-hubs/tree/master/samples/Management/DotNet)
- [Service Bus Messaging Workshop](https://github.com/Azure/azure-service-bus/tree/master/samples)

### External Workshops

- [Microsoft Cloud Workshops](https://microsoftcloudworkshop.com/)

## 📊 Pricing et Calculateurs

- [Azure Pricing Calculator](https://azure.microsoft.com/pricing/calculator/)
- [Event Hubs Pricing](https://azure.microsoft.com/pricing/details/event-hubs/)
- [Service Bus Pricing](https://azure.microsoft.com/pricing/details/service-bus/)
- [Event Grid Pricing](https://azure.microsoft.com/pricing/details/event-grid/)

## 🆘 Support

### Azure Support

- [Azure Support Plans](https://azure.microsoft.com/support/plans/)
- [Create Support Ticket](https://portal.azure.com/#blade/Microsoft_Azure_Support/HelpAndSupportBlade)

### Community Support

- [Microsoft Q&A](https://docs.microsoft.com/answers/)
- [Azure Community Forums](https://azure.microsoft.com/support/forums/)

---

## 🤝 Contribuer à ce Workshop

Ce workshop est open source ! Vous pouvez contribuer en :

1. **Signalant des bugs** ou améliorations via GitHub Issues
2. **Proposant des corrections** via Pull Requests
3. **Partageant vos retours** d'expérience
4. **Ajoutant des ressources** utiles que vous découvrez

Repository GitHub : [Lien vers votre repo]

---

## 📄 Licence

Ce contenu est sous licence [Creative Commons Attribution 4.0 International](https://creativecommons.org/licenses/by/4.0/).

Vous êtes libre de :
- ✅ Partager — copier et redistribuer
- ✅ Adapter — remixer, transformer et créer
- ✅ Usage commercial

Sous conditions :
- 📝 Attribution — Vous devez créditer l'œuvre

---

**Bon apprentissage ! 🚀**

[← Retour au sommaire](./workshop.md)
