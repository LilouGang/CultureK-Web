#!/bin/bash

# Cloner le SDK Flutter depuis GitHub
git clone https://github.com/flutter/flutter.git --depth 1

# Ajouter l'exécutable Flutter au PATH pour cette session de build
export PATH="$PATH:`pwd`/flutter/bin"

# Lancer la commande d'installation de Flutter
flutter precache

# Lancer la commande d'installation de votre projet
flutter pub get