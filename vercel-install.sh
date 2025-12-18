#!/bin/bash
set -e
set -x

echo ">>> DÉBUT INSTALLATION PROPRE <<<"

if [ -d "flutter" ]; then
    echo ">>> Nettoyage de l'ancien dossier flutter..."
    rm -rf flutter
fi

echo ">>> Clonage de Flutter stable..."
git clone https://github.com/flutter/flutter.git -b stable

echo ">>> Vérification..."
export PATH="$PATH:`pwd`/flutter/bin"
flutter --version

echo ">>> INSTALLATION TERMINÉE <<<"