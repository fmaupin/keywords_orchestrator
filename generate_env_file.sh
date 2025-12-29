#!/bin/bash
set -e

generate_env_file() {
    local MODE="$1"
    local SCRIPT_DIR ENV_FILE_ORIG HOST_FILES_DIR
    local ENV_FILE WIN_USER

    # -------------------
    # Chemins et fichiers
    # -------------------
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
    ENV_FILE_ORIG="$SCRIPT_DIR/db/$MODE/.env"

    if [ ! -f "$ENV_FILE_ORIG" ]; then
        echo "Erreur : fichier .env introuvable : $ENV_FILE_ORIG" >&2
        return 1
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
            echo "OS non pris en charge: $OSTYPE" >&2
            return 1
            ;;
    esac

    # Vérification de l'existence du dossier
    if [ ! -d "$HOST_FILES_DIR" ]; then
        echo "Erreur : dossier HOST_FILES_DIR introuvable : $HOST_FILES_DIR" >&2
        return 1
    fi

    echo "HOST_FILES_DIR final = $HOST_FILES_DIR" >&2

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

    echo "$ENV_FILE"
}
