#!/bin/bash
set -e

# -----------------------------
# Vérification des paramètres
# -----------------------------
GITHUB_USERNAME=${1:-}
GITHUB_TOKEN=${2:-}
MODE=${3:-dev} # 'dev' par défaut

if [ -z "$GITHUB_USERNAME" ] || [ -z "$GITHUB_TOKEN" ]; then
  echo "Usage: $0 <github_username> <github_token> <dev|prod>" >&2
  exit 1
fi

if [[ "$MODE" != "dev" && "$MODE" != "prod" ]]; then
  echo "Usage: $0 <github_username> <github_token> <dev|prod>" >&2
  exit 1
fi

if [ "$MODE" == "prod" ]; then
  echo "Mode 'prod' non encore implémenté" >&2
  exit 1
fi

# -----------------------------
# Chemins et fichiers
# -----------------------------
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
COMPOSE_FILE="$SCRIPT_DIR/db/$MODE/docker-compose.yml"

if [ ! -f "$COMPOSE_FILE" ]; then
  echo "Erreur : fichier docker-compose.yml introuvable : $COMPOSE_FILE" >&2
  exit 1
fi

# -----------------------------
# Création d'un .env temporaire
# -----------------------------
. ./generate_env_file.sh
ENV_FILE="$(generate_env_file "$MODE")"
   
# Vérification rapide
echo "Contenu du .env temporaire :" >&2
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

docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" down --volumes --rmi all --remove-orphans
docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" up -d

echo "Les services ont été démarrés avec succès via Docker Compose" >&2
docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" ps

# -----------------------------
# Nettoyage et logout
# -----------------------------
docker logout ghcr.io
rm "$ENV_FILE"

unset MODE SCRIPT_DIR COMPOSE_FILE ENV_FILE COMPOSE_DIR GITHUB_USERNAME GITHUB_TOKEN

