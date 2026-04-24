# Workshop Website - Options de Déploiement

Ce dossier contient les configurations pour déployer le workshop sur Azure App Service.

## 🎯 Options Disponibles

### Option 1 : Site Statique Simple (Recommandé) ⭐
- **Technologie** : HTML/CSS/JavaScript + Markdown rendering
- **Avantages** : Léger, rapide, facile à maintenir
- **Déploiement** : Azure Static Web Apps ou App Service
- **Coût** : Gratuit (Static Web Apps) ou ~5€/mois (App Service B1)

### Option 2 : Docusaurus
- **Technologie** : React-based documentation framework
- **Avantages** : Navigation moderne, recherche intégrée, MDX support
- **Déploiement** : Build → Static Web Apps
- **Coût** : Gratuit (Static Web Apps)

### Option 3 : MkDocs Material
- **Technologie** : Python-based static site generator
- **Avantages** : Thème Material Design, navigation claire
- **Déploiement** : Build → Static Web Apps
- **Coût** : Gratuit

## 🚀 Déploiement Recommandé

**Azure Static Web Apps** (Gratuit + CI/CD GitHub Actions) :

```bash
# 1. Créer Static Web App
az staticwebapp create \
  --name event-driven-workshop \
  --resource-group rg-workshop \
  --source https://github.com/Ch0wseth/EventDriven_Workshop \
  --location westeurope \
  --branch main \
  --app-location "/website/static" \
  --output-location "build"

# 2. Le déploiement se fait automatiquement via GitHub Actions
```

## 📁 Structure

```
website/
├── README.md                  # Ce fichier
├── static/                    # Option 1 : Site statique simple
│   ├── index.html
│   ├── css/
│   ├── js/
│   └── markdown/
├── docusaurus/               # Option 2 : Docusaurus
│   ├── docusaurus.config.js
│   └── docs/
├── mkdocs/                   # Option 3 : MkDocs
│   ├── mkdocs.yml
│   └── docs/
└── deploy/                   # Scripts de déploiement
    ├── azure-static-web-app.yml
    ├── app-service.bicep
    └── deploy.sh
```

## 🎨 Fonctionnalités du Site

- ✅ Navigation par modules
- ✅ Barre de recherche
- ✅ Code syntax highlighting
- ✅ Responsive design (mobile/tablet/desktop)
- ✅ Dark/Light mode
- ✅ Copie de code en 1 clic
- ✅ Progression du workshop
- ✅ Liens vers GitHub
- ✅ Téléchargement PDF

## 📊 Choix Recommandé

**Azure Static Web Apps avec site statique simple** car :
- 💰 Gratuit (Free tier)
- 🚀 CI/CD automatique via GitHub Actions
- ⚡ CDN intégré (ultra rapide)
- 🔒 HTTPS automatique
- 🌍 Custom domain gratuit
- 📈 Scalabilité automatique

## 🔗 URL du Site

Après déploiement : `https://event-driven-workshop.azurestaticapps.net`

Ou custom domain : `https://workshop.votredomaine.com`
