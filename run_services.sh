#!/bin/bash
set -e

# -----------------------------
# Vérification des paramètres
# -----------------------------
GITHUB_USERNAME=${1:-}
GITHUB_TOKEN=${2:-}
MODE=${3:-dev} # 'dev' par défaut

if [ -z "$GITHUB_USERNAME" ] || [ -z "$GITHUB_TOKEN" ]; then
  echo "Usage: $0 <github_username> <github_token> <dev|prod>"
  exit 1
fi

if [[ "$MODE" != "dev" && "$MODE" != "prod" ]]; then
  echo "Usage: $0 <github_username> <github_token> <dev|prod>"
  exit 1
fi

if [ "$MODE" == "prod" ]; then
  echo "Mode 'prod' non encore implémenté"
  exit 1
fi

# -----------------------------
# Chemins et fichiers
# -----------------------------
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
COMPOSE_FILE="$SCRIPT_DIR/db/$MODE/docker-compose.yml"
ENV_FILE_ORIG="$SCRIPT_DIR/db/$MODE/.env"

if [ ! -f "$COMPOSE_FILE" ]; then
  echo "Erreur : fichier docker-compose.yml introuvable : $COMPOSE_FILE"
  exit 1
fi

if [ ! -f "$ENV_FILE_ORIG" ]; then
  echo "Erreur : fichier .env introuvable : $ENV_FILE_ORIG"
  exit 1
fi

# -----------------------------
# Nettoyage des fins de lignes
# -----------------------------
if command -v dos2unix >/dev/null 2>&1; then
  dos2unix "$ENV_FILE_ORIG"
else
  sed -i 's/\r$//' "$ENV_FILE_ORIG"
fi

# -----------------------------
# Définition du HOST_FILES_DIR
# -----------------------------
case "$OSTYPE" in
  linux-gnu*|darwin*)
    HOST_FILES_DIR="$HOME/Desktop"
    ;;
  msys*|cygwin*)
    WIN_USER=$(whoami)
    HOST_FILES_DIR="C:/Users/$WIN_USER/Desktop"
    HOST_FILES_DIR=$(cygpath -w "$HOST_FILES_DIR")
    HOST_FILES_DIR="${HOST_FILES_DIR//\\//}"
    ;;
  *)
    echo "OS non pris en charge: $OSTYPE"
    exit 1
    ;;
esac

# Vérification de l'existence du dossier
if [ ! -d "$HOST_FILES_DIR" ]; then
  echo "Erreur : dossier HOST_FILES_DIR introuvable : $HOST_FILES_DIR"
  exit 1
fi

echo "HOST_FILES_DIR final = $HOST_FILES_DIR"

# -----------------------------
# Création d'un .env temporaire
# -----------------------------
ENV_FILE=$(mktemp)
# Supprimer l'ancienne ligne HOST_FILES_DIR si elle existe
grep -v -E '^HOST_FILES_DIR=' "$ENV_FILE_ORIG" > "$ENV_FILE" || true
# Ajouter la variable HOST_FILES_DIR
echo "HOST_FILES_DIR=$(echo "$HOST_FILES_DIR" | tr -d '\r\$')" >> "$ENV_FILE"

# Nettoyage CRLF éventuel
if command -v dos2unix >/dev/null 2>&1; then
    dos2unix "$ENV_FILE" 2>/dev/null
else
    sed -i 's/\r$//' "$ENV_FILE"
fi

# Vérification rapide
echo "Contenu du .env temporaire :"
cat -v "$ENV_FILE"

# -----------------------------
# Authentification GitHub
# -----------------------------
echo "$GITHUB_TOKEN" | docker login ghcr.io -u "$GITHUB_USERNAME" --password-stdin

# -----------------------------
# Exécution Docker Compose
# -----------------------------
COMPOSE_DIR=$(dirname "$COMPOSE_FILE")
cd "$COMPOSE_DIR"

docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" down --volumes --rmi all
docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" up -d

echo "Les services ont été démarrés avec succès via Docker Compose"
docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" ps

# -----------------------------
# Nettoyage et logout
# -----------------------------
docker logout ghcr.io
rm "$ENV_FILE"

unset GITHUB_USERNAME GITHUB_TOKEN MODE SCRIPT_DIR COMPOSE_FILE ENV_FILE_ORIG ENV_FILE COMPOSE_DIR HOST_FILES_DIR WIN_USER
