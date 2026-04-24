# 🚀 Guide de Déploiement Rapide

## Option 1 : Azure Static Web Apps (Recommandé) ⭐

**Avantages** : Gratuit, CI/CD automatique, ultra rapide (CDN mondial)

### Déploiement Automatique via GitHub

```bash
# 1. Créer la Static Web App
az staticwebapp create \
  --name event-driven-workshop \
  --resource-group rg-workshop \
  --location westeurope \
  --source https://github.com/Ch0wseth/EventDriven_Workshop \
  --branch main \
  --app-location "/website/static" \
  --output-location ""

# 2. Récupérer le token de déploiement
az staticwebapp secrets list \
  --name event-driven-workshop \
  --resource-group rg-workshop \
  --query "properties.apiKey" -o tsv

# 3. Ajouter le token comme secret GitHub
# GitHub Repo → Settings → Secrets → New secret
# Name: AZURE_STATIC_WEB_APPS_API_TOKEN
# Value: [token from step 2]

# 4. Copier le workflow file
cp website/deploy/azure-static-web-app.yml .github/workflows/

# 5. Push to GitHub → Déploiement automatique !
git add .
git commit -m "Add website deployment"
git push
```

**URL du site** : `https://event-driven-workshop.azurestaticapps.net`

---

## Option 2 : Azure App Service

**Avantages** : Plus de contrôle, custom runtime

```bash
# Déploiement avec Bicep
az deployment group create \
  --resource-group rg-workshop \
  --template-file website/deploy/app-service.bicep \
  --parameters appServiceName=workshop-site \
  --parameters sku=B1

# Déployer les fichiers
cd website/static
zip -r site.zip .
az webapp deployment source config-zip \
  --resource-group rg-workshop \
  --name workshop-site \
  --src site.zip
```

**Coût** : ~5€/mois (B1 tier)

---

## Option 3 : Serveur Local (Test)

### Avec Python
```bash
cd website/static
python3 -m http.server 8000
```

### Avec Node.js
```bash
cd website/static
npx http-server -p 8000
```

**URL** : http://localhost:8000

---

## Script de Déploiement Automatique

```bash
# Rendre le script exécutable
chmod +x website/deploy/deploy.sh

# Lancer le déploiement
./website/deploy/deploy.sh
```

Le script propose un menu interactif pour choisir la méthode.

---

## Custom Domain (Optionnel)

### Avec Static Web Apps

```bash
# Ajouter un custom domain
az staticwebapp hostname set \
  --name event-driven-workshop \
  --resource-group rg-workshop \
  --hostname workshop.votredomaine.com
```

### DNS Configuration
```
Type: CNAME
Name: workshop
Value: event-driven-workshop.azurestaticapps.net
```

---

## Monitoring et Logs

### Static Web Apps
```bash
# Voir les logs
az staticwebapp show \
  --name event-driven-workshop \
  --resource-group rg-workshop
```

### App Service
```bash
# Stream logs
az webapp log tail \
  --name workshop-site \
  --resource-group rg-workshop
```

---

## Mise à Jour du Site

### Static Web Apps (Automatique)
- Push vers GitHub → Déploiement automatique via GitHub Actions

### App Service (Manuel)
```bash
cd website/static
zip -r site.zip .
az webapp deployment source config-zip \
  --resource-group rg-workshop \
  --name workshop-site \
  --src site.zip
```

---

## Troubleshooting

### Les fichiers Markdown ne se chargent pas

**Problème** : Le JavaScript charge les fichiers depuis `../docs/` mais ils ne sont pas accessibles.

**Solutions** :

1. **Copier les docs dans le site** :
   ```bash
   mkdir -p website/static/docs
   cp -r docs/*.md website/static/docs/
   ```

2. **Modifier app.js** :
   ```javascript
   // Changer
   file: '../docs/00-introduction.md'
   // En
   file: 'docs/00-introduction.md'
   ```

### Les diagrammes Mermaid ne s'affichent pas

Vérifiez que Mermaid est bien chargé :
```html
<script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>
```

### Dark Mode ne fonctionne pas

Vérifiez LocalStorage :
```javascript
console.log(localStorage.getItem('darkMode'));
```

---

## Performance Optimization

### Activer la Compression (App Service)

```bash
az webapp config set \
  --resource-group rg-workshop \
  --name workshop-site \
  --http20-enabled true \
  --min-tls-version 1.2
```

### CDN (Static Web Apps)

Déjà inclus ! Static Web Apps utilise Azure CDN automatiquement.

---

## Sécurité

### HTTPS (Automatique)

Les deux options (Static Web Apps et App Service) incluent HTTPS gratuit.

### Authentification (Optionnel)

Pour un site privé, ajoutez Azure AD :

```bash
az webapp auth update \
  --resource-group rg-workshop \
  --name workshop-site \
  --enabled true \
  --action LoginWithAzureActiveDirectory
```

---

## Support

- 📖 [Azure Static Web Apps Docs](https://learn.microsoft.com/azure/static-web-apps/)
- 📖 [Azure App Service Docs](https://learn.microsoft.com/azure/app-service/)
- 🐛 [Issues GitHub](https://github.com/Ch0wseth/EventDriven_Workshop/issues)
