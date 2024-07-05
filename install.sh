#!/bin/bash

# Check if the GitHub token is passed as an argument
if [ -z "$1" ]; then
  echo "Error: No GitHub token provided. Usage: $0 <GITHUB_TOKEN>"
  exit 1
fi

GITHUB_TOKEN="$1"

# Funzione per scaricare e estrarre PrestaShop
download_and_extract_prestashop() {
  local PS_VERSION="8.1.6"
  local DOWNLOAD_URL="https://github.com/PrestaShop/PrestaShop/releases/download/$PS_VERSION/prestashop_$PS_VERSION.zip"
  local ZIP_FILE="prestashop_$PS_VERSION.zip"

  echo "Scaricando PrestaShop versione $PS_VERSION..."
  curl -L -o $ZIP_FILE $DOWNLOAD_URL

  if [ $? -ne 0 ]; then
    echo "Errore: il download del file $ZIP_FILE non è riuscito."
    exit 1
  fi

  echo "Estraendo $ZIP_FILE..."
  unzip -o $ZIP_FILE

  if [ $? -ne 0 ]; then
    echo "Errore: l'estrazione del file $ZIP_FILE non è riuscita."
    exit 1
  fi

  rm $ZIP_FILE
  unzip -o prestashop.zip
  echo "PrestaShop versione $PS_VERSION scaricata ed estratta con successo."
}

# Funzione per scaricare e estrarre un asset da una release GitHub
download_and_extract_github_asset() {
  local TAG=0.0.32
  local ASSET_NAME="bundle.zip"
  local ZIP_FILE="bundle.zip"
  local REPO="dgcalsrl/ps-deployer"
  local API_URL="https://api.github.com/repos/$REPO/releases/tags/$TAG"

  echo "Recuperando informazioni sulla release..."
  local RELEASE_JSON=$(curl -s -H "Authorization: token $GITHUB_TOKEN" $API_URL)
  local RELEASE_ID=$(echo $RELEASE_JSON | grep -oP '"id": \K\d+')

  if [ -z "$RELEASE_ID" ]; then
    echo "Errore: impossibile trovare la release con il tag $TAG."
    exit 1
  fi

  echo "Recuperando informazioni sugli asset..."
  local ASSET_ID=$(echo $RELEASE_JSON | grep -oP '"id": \K\d+(?=.*"name": "'$ASSET_NAME'")' | tac | head -n 1)

  if [ -z "$ASSET_ID" ]; then
    echo "Errore: impossibile trovare l'asset $ASSET_NAME nella release con il tag $TAG."
    exit 1
  fi

  local ASSET_URL="https://api.github.com/repos/$REPO/releases/assets/$ASSET_ID"
  echo "Scaricando l'asset $ASSET_NAME..."
  curl -L -H "Authorization: token $GITHUB_TOKEN" -H "Accept: application/octet-stream" "$ASSET_URL" -o $ZIP_FILE

  if [ $? -ne 0 ]; then
    echo "Errore: il download del file $ZIP_FILE non è riuscito."
    exit 1
  fi

  echo "Estraendo $ZIP_FILE..."
  unzip -o $ZIP_FILE

  if [ $? -ne 0 ]; then
    echo "Errore: l'estrazione del file $ZIP_FILE non è riuscita."
    exit 1
  fi

  rm $ZIP_FILE
  echo "Il file $ASSET_NAME è stato scaricato ed estratto con successo."
}

rename() {
  local INDEX_FILE="index.php"
  local OLD_INDEX_FILE="old.index.php"

  # Rename index.php to old.index.php
  if [ -f "$INDEX_FILE" ]; then
    mv "$INDEX_FILE" "$OLD_INDEX_FILE"
    echo "Renamed $INDEX_FILE to $OLD_INDEX_FILE."
  else
    echo "File $INDEX_FILE not found. Skipping rename."
  fi
}


download_and_extract_prestashop
download_and_extract_github_asset
rename