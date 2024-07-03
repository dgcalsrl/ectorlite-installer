#!/bin/bash

PS_VERSION="8.1.7"

DOWNLOAD_URL="https://github.com/PrestaShop/PrestaShop/releases/download/$PS_VERSION/prestashop_$PS_VERSION.zip"

# Nome del file zip
ZIP_FILE="prestashop_$PS_VERSION.zip"

# Scarica il file zip
curl -L -o $ZIP_FILE $DOWNLOAD_URL

# Verifica se il download è andato a buon fine
if [ $? -ne 0 ]; then
  echo "Errore: il download del file $ZIP_FILE non è riuscito."
  exit 1
fi

# Estrai il contenuto dello zip nella directory corrente
unzip -o $ZIP_FILE

# Verifica se l'estrazione è andata a buon fine
if [ $? -ne 0 ]; then
  echo "Errore: l'estrazione del file $ZIP_FILE non è riuscita."
  exit 1
fi

# Rimuovi il file zip scaricato
rm $ZIP_FILE

echo "PrestaShop versione $PS_VERSION scaricata ed estratta con successo."


#!/bin/bash

# Chiedi il token all'utente
read -p "Inserisci il tuo token GitHub: " GITHUB_TOKEN

# Controlla se il token è stato inserito
if [ -z "$GITHUB_TOKEN" ]; then
  echo "Errore: nessun token inserito."
  exit 1
fi

# Specifica il tag della release
TAG=0.0.13

# Nome del file zip
ASSET_NAME="bundle.zip"
ZIP_FILE="bundle.zip"

# URL per ottenere le informazioni sulla release
REPO="dgcalsrl/ps-deployer"
API_URL="https://api.github.com/repos/$REPO/releases/tags/$TAG"

# Ottieni l'ID della release
RELEASE_JSON=$(curl -s -H "Authorization: token $GITHUB_TOKEN" $API_URL)

echo $RELEASE_JSON

RELEASE_ID=$(echo $RELEASE_JSON | grep -oP '"id": \K\d+')

# Controlla se l'ID della release è stato trovato
if [ -z "$RELEASE_ID" ]; then
  echo "Errore: impossibile trovare la release con il tag $TAG."
  exit 1
fi

# Ottieni le informazioni sugli asset della release
ASSETS_JSON=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/repos/$REPO/releases/$RELEASE_ID/assets")

# Ottieni l'ID dell'asset
ASSET_ID=$(echo $ASSETS_JSON | grep -oP '"id": \K\d+(?=.*"name": "'$ASSET_NAME'")')

# Controlla se l'ID dell'asset è stato trovato
if [ -z "$ASSET_ID" ]; then
  echo "Errore: impossibile trovare l'asset $ASSET_NAME nella release con il tag $TAG."
  exit 1
fi

# Scarica l'asset utilizzando l'ID
ASSET_URL="https://api.github.com/repos/$REPO/releases/assets/$ASSET_ID"
curl -L -H "Authorization: token $GITHUB_TOKEN" -H "Accept: application/octet-stream" "$ASSET_URL" -o $ZIP_FILE

# Verifica se il download è andato a buon fine
if [ $? -ne 0 ]; then
  echo "Errore: il download del file $ZIP_FILE non è riuscito."
  exit 1
fi

# Estrai il contenuto dello zip nella directory corrente
unzip $ZIP_FILE

# Verifica se l'estrazione è andata a buon fine
if [ $? -ne 0 ]; then
  echo "Errore: l'estrazione del file $ZIP_FILE non è riuscita."
  exit 1
fi

# Rimuovi il file zip scaricato
rm $ZIP_FILE

echo "Il file bundle.zip è stato scaricato ed estratto con successo."
