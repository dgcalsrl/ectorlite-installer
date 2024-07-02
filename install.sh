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
unzip $ZIP_FILE

# Verifica se l'estrazione è andata a buon fine
if [ $? -ne 0 ]; then
  echo "Errore: l'estrazione del file $ZIP_FILE non è riuscita."
  exit 1
fi

# Rimuovi il file zip scaricato
rm $ZIP_FILE

echo "PrestaShop versione $PS_VERSION scaricata ed estratta con successo."


