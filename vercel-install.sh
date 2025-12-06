#!/bin/bash
set -e  # Arrête le script immédiatement si une commande échoue
set -x  # Affiche chaque commande dans les logs avant de l'exécuter

echo ">>> DÉBUT DU SCRIPT D'INSTALLATION <<<"

# Vérification de l'emplacement actuel
echo "Dossier actuel : $(pwd)"
ls -la

# Installation de Flutter
if [ -d "flutter" ]; then
    echo ">>> Dossier flutter existant détecté."
    cd flutter
    echo ">>> Mise à jour de Flutter..."
    git pull
    cd ..
else
    echo ">>> Clonage de Flutter stable..."
    git clone https://github.com/flutter/flutter.git -b stable
fi

echo ">>> Vérification de l'installation..."
# On ajoute le chemin temporairement pour vérifier la version
export PATH="$PATH:`pwd`/flutter/bin"
flutter --version

echo ">>> FIN DU SCRIPT D'INSTALLATION (SUCCÈS) <<<"