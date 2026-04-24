#!/bin/bash

# ============================================
# Serveur Local Workshop Website (Linux/Mac)
# ============================================

echo ""
echo "==========================================="
echo "  Workshop Event-Driven - Serveur Local"
echo "==========================================="
echo ""

cd "$(dirname "$0")/static"

# Vérifier Python
if command -v python3 &> /dev/null; then
    echo "[*] Démarrage avec Python..."
    echo "[*] URL: http://localhost:8000"
    echo ""
    python3 -m http.server 8000
    exit 0
fi

# Vérifier Node.js
if command -v npx &> /dev/null; then
    echo "[*] Démarrage avec Node.js..."
    echo "[*] URL: http://localhost:8000"
    echo ""
    npx http-server -p 8000
    exit 0
fi

# Aucun serveur disponible
echo "[!] Erreur: Python ou Node.js requis"
echo ""
echo "Installez l'un des deux:"
echo "  - Python: https://www.python.org/downloads/"
echo "  - Node.js: https://nodejs.org/"
echo ""
exit 1
