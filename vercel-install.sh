#!/bin/bash

# On définit la version de Flutter à utiliser
FLUTTER_VERSION="3.35.2"

# On clone la branche de cette version spécifique
git clone https://github.com/flutter/flutter.git --branch $FLUTTER_VERSION --depth 1

# Le reste du script est identique
export PATH="$PATH:`pwd`/flutter/bin"
flutter precache
flutter pub get