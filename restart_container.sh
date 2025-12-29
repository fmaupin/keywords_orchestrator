#!/bin/bash
set -e

# -----------------------------
# Vérification des paramètres
# -----------------------------
MODE=${1:-}
SERVICE_NAME=${2:-}
VOLUME_NAME=${3:-""} # paramètre optionnel

if [[ "$MODE" != "dev" && "$MODE" != "prod" ]]; then
  echo "Usage: $0 <dev|prod> <service_name> [<volume_name>]" >&2
  exit 1
fi

if [ "$MODE" == "prod" ]; then
  echo "Mode 'prod' non encore implémenté" >&2
  exit 1
fi

if [ -z "$SERVICE_NAME" ]; then
  echo "Usage: $0 <dev|prod> <service_name> [<volume_name>]" >&2
  exit 1
fi

# -------------------
# Chemins et fichiers
# -------------------
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
# Stopper et démarrer container
# -----------------------------
COMPOSE_DIR=$(dirname "$COMPOSE_FILE")
cd "$COMPOSE_DIR"

docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" stop "$SERVICE_NAME"
docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" rm -f "$SERVICE_NAME"

if [ "$VOLUME_NAME" != "" ]; then
  docker volume rm "$VOLUME_NAME"
fi

docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" up -d "$SERVICE_NAME"

# ---------
# Nettoyage
# ---------
rm "$ENV_FILE"

unset MODE SCRIPT_DIR COMPOSE_FILE ENV_FILE COMPOSE_DIR
