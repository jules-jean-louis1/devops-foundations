#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CERTS_DIR="$SCRIPT_DIR/certs"

echo "🔐 Génération des certificats avec mkcert..."

# Vérifier si mkcert est installé
if ! command -v mkcert &> /dev/null; then
    echo "❌ mkcert n'est pas installé"
    echo "Installation:"
    echo "  macOS: brew install mkcert"
    echo "  Linux: sudo apt-get install mkcert"
    echo "  Windows: choco install mkcert"
    exit 1
fi

# Créer le répertoire des certificats
mkdir -p "$CERTS_DIR"

# Installer l'autorité de certification locale
echo "📦 Installation du CA local..."
mkcert -install

# Générer les certificats
echo "🎯 Génération des certificats..."
mkcert \
    -cert-file "$CERTS_DIR/local.crt" \
    -key-file "$CERTS_DIR/local.key" \
    localhost \
    "*.localhost" \
    app.localhost \
    api.localhost \
    db.localhost \
    mail.localhost \
    traefik.localhost \
    127.0.0.1 \
    ::1

echo "✅ Certificats générés:"
echo "   Certificat: $CERTS_DIR/local.crt"
echo "   Clé privée: $CERTS_DIR/local.key"
