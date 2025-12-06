#!/bin/bash

# 1. On ajoute le dossier Flutter au "Chemin" pour que le script le trouve
export PATH="$PATH:`pwd`/flutter/bin"

# 2. (Optionnel) On vérifie que ça marche dans les logs
echo "Chemin Flutter : $(which flutter)"
echo "Version Flutter :"
flutter --version

# 3. On lance la construction avec les clés
flutter build web --release \
  --dart-define=FIREBASE_API_KEY="$FIREBASE_API_KEY" \
  --dart-define=FIREBASE_APP_ID="$FIREBASE_APP_ID" \
  --dart-define=FIREBASE_AUTH_DOMAIN="$FIREBASE_AUTH_DOMAIN" \
  --dart-define=FIREBASE_PROJECT_ID="$FIREBASE_PROJECT_ID" \
  --dart-define=FIREBASE_STORAGE_BUCKET="$FIREBASE_STORAGE_BUCKET" \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID="$FIREBASE_MESSAGING_SENDER_ID" \
  --dart-define=FIREBASE_MEASUREMENT_ID="$FIREBASE_MEASUREMENT_ID"