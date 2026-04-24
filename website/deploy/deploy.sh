#!/bin/bash

# ============================================
# Déploiement Workshop Website sur Azure
# ============================================

set -e

echo "🚀 Déploiement du Workshop Event-Driven sur Azure"
echo ""

# ============================================
# CONFIGURATION
# ============================================

RESOURCE_GROUP="rg-event-driven-workshop"
LOCATION="francecentral"
DEPLOYMENT_METHOD="static-web-app"  # Options: static-web-app | app-service

# ============================================
# FUNCTIONS
# ============================================

function deploy_static_web_app() {
    echo "📦 Option 1 : Azure Static Web Apps (Recommandé)"
    echo ""
    
    # Vérifier si az staticwebapp existe
    if ! az staticwebapp --help &> /dev/null; then
        echo "⚠️  Extension 'staticwebapp' non installée"
        echo "Installation..."
        az extension add --name staticwebapp --yes
    fi
    
    # Nom unique
    STATIC_WEB_APP_NAME="event-driven-workshop-$RANDOM"
    
    echo "📝 Création de la Static Web App : $STATIC_WEB_APP_NAME"
    
    # Créer le resource group
    az group create \
        --name $RESOURCE_GROUP \
        --location $LOCATION
    
    # Créer Static Web App
    az staticwebapp create \
        --name $STATIC_WEB_APP_NAME \
        --resource-group $RESOURCE_GROUP \
        --location $LOCATION \
        --sku Free \
        --source https://github.com/Ch0wseth/EventDriven_Workshop \
        --branch main \
        --app-location "/website/static" \
        --output-location ""
    
    # Récupérer l'URL
    WEBSITE_URL=$(az staticwebapp show \
        --name $STATIC_WEB_APP_NAME \
        --resource-group $RESOURCE_GROUP \
        --query "defaultHostname" -o tsv)
    
    echo ""
    echo "✅ Déploiement réussi !"
    echo "🌐 URL : https://$WEBSITE_URL"
    echo ""
    echo "📝 Pour configurer le déploiement automatique via GitHub Actions :"
    echo "   1. Récupérez le token de déploiement :"
    echo "      az staticwebapp secrets list --name $STATIC_WEB_APP_NAME --resource-group $RESOURCE_GROUP"
    echo "   2. Ajoutez-le comme secret GitHub : AZURE_STATIC_WEB_APPS_API_TOKEN"
    echo "   3. Le fichier .github/workflows/azure-static-web-app.yml sera automatiquement utilisé"
}

function deploy_app_service() {
    echo "📦 Option 2 : Azure App Service"
    echo ""
    
    APP_SERVICE_NAME="event-driven-workshop-$RANDOM"
    APP_SERVICE_PLAN="asp-workshop"
    
    echo "📝 Déploiement de l'App Service : $APP_SERVICE_NAME"
    
    # Créer le resource group
    az group create \
        --name $RESOURCE_GROUP \
        --location $LOCATION
    
    # Déployer via Bicep
    az deployment group create \
        --resource-group $RESOURCE_GROUP \
        --template-file website/deploy/app-service.bicep \
        --parameters appServiceName=$APP_SERVICE_NAME \
        --parameters appServicePlanName=$APP_SERVICE_PLAN \
        --parameters location=$LOCATION \
        --parameters sku=B1
    
    # Récupérer l'URL
    WEBSITE_URL=$(az webapp show \
        --name $APP_SERVICE_NAME \
        --resource-group $RESOURCE_GROUP \
        --query "defaultHostDomain" -o tsv)
    
    echo ""
    echo "✅ Déploiement réussi !"
    echo "🌐 URL : https://$WEBSITE_URL"
    echo ""
    echo "📝 Pour déployer les fichiers :"
    echo "   cd website/static"
    echo "   zip -r site.zip ."
    echo "   az webapp deployment source config-zip --resource-group $RESOURCE_GROUP --name $APP_SERVICE_NAME --src site.zip"
}

function deploy_local() {
    echo "🏠 Option 3 : Déploiement Local (Test)"
    echo ""
    echo "Démarrage d'un serveur local..."
    
    cd website/static
    
    if command -v python3 &> /dev/null; then
        echo "🐍 Serveur Python sur http://localhost:8000"
        python3 -m http.server 8000
    elif command -v npx &> /dev/null; then
        echo "📦 Serveur HTTP (Node.js) sur http://localhost:8000"
        npx http-server -p 8000
    else
        echo "❌ Python3 ou Node.js requis pour le serveur local"
        exit 1
    fi
}

# ============================================
# MENU PRINCIPAL
# ============================================

echo "Choisissez une méthode de déploiement :"
echo ""
echo "1) Azure Static Web Apps (Recommandé - Gratuit)"
echo "2) Azure App Service (~5€/mois)"
echo "3) Serveur Local (Test uniquement)"
echo ""
read -p "Votre choix (1/2/3) : " choice

case $choice in
    1)
        deploy_static_web_app
        ;;
    2)
        deploy_app_service
        ;;
    3)
        deploy_local
        ;;
    *)
        echo "❌ Choix invalide"
        exit 1
        ;;
esac

echo ""
echo "🎉 Terminé !"
