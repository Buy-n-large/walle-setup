#!/bin/bash
set -e

ORG="Buy-n-large"
INSTALL_DIR="$HOME/walle"

echo "=== WALL-E Bootstrap ==="
echo "Installation dans $INSTALL_DIR"

# Dépendances système
echo "[1/5] Installation des dépendances système..."
sudo apt-get update -qq
sudo apt-get install -y -qq python3-pip python3-venv git

# Répertoire d'installation
echo "[2/5] Création du répertoire..."
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# Environnement virtuel Python
echo "[3/5] Création de l'environnement Python..."
python3 -m venv venv
source venv/bin/activate

# Installation des modules
echo "[4/5] Installation des modules WALL-E..."
pip install --quiet git+https://github.com/$ORG/walle-core.git
pip install --quiet git+https://github.com/$ORG/walle-web.git

# Copie du Makefile
echo "[5/5] Configuration..."
curl -sSL https://raw.githubusercontent.com/$ORG/walle-setup/main/Makefile -o Makefile

echo ""
echo "=== Installation terminée ! ==="
echo "Lancer le robot : cd ~/walle && make start"
