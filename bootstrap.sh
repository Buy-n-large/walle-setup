#!/bin/bash
set -e

ORG="Buy-n-large"
INSTALL_DIR="$HOME/walle"
VENV="$INSTALL_DIR/venv"

echo "================================"
echo "  WALL-E Bootstrap"
echo "================================"

# 1. Dépendances système
echo "[1/5] Dépendances système..."
sudo apt-get update -qq
sudo apt-get install -y -qq python3-pip python3-venv git curl

# 2. arduino-cli
echo "[2/5] Installation arduino-cli..."
if ! command -v arduino-cli &> /dev/null; then
  curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | sh
  sudo mv ~/bin/arduino-cli /usr/local/bin/arduino-cli
  arduino-cli core update-index
  arduino-cli core install arduino:avr
  arduino-cli lib install "Servo" "Stepper" "Adafruit PWM Servo Driver Library"
else
  echo "  arduino-cli déjà installé."
fi

# 3. Répertoire + venv
echo "[3/5] Environnement Python..."
mkdir -p "$INSTALL_DIR"
python3 -m venv "$VENV"
source "$VENV/bin/activate"
pip install --quiet --upgrade pip

# 4. Modules WALL-E
echo "[4/5] Installation des modules..."
pip install --quiet git+https://github.com/$ORG/walle-core.git
pip install --quiet git+https://github.com/$ORG/walle-web.git

# 5. Clone walle-arduino (pour les mises à jour du sketch)
echo "[5/5] Code Arduino..."
if [ ! -d "$INSTALL_DIR/walle-arduino" ]; then
  git clone https://github.com/$ORG/walle-arduino.git "$INSTALL_DIR/walle-arduino"
else
  git -C "$INSTALL_DIR/walle-arduino" pull -q
fi

# Makefile principal
curl -sSL https://raw.githubusercontent.com/$ORG/walle-setup/main/Makefile -o "$INSTALL_DIR/Makefile"

# Service systemd
echo "Configuration du service systemd..."
sudo tee /etc/systemd/system/walle-web.service > /dev/null << EOF
[Unit]
Description=WALL-E Web Interface
After=network.target

[Service]
User=$USER
WorkingDirectory=$INSTALL_DIR
ExecStart=$VENV/bin/walle-web
Restart=always
RestartSec=5
Environment=WALLE_PORT=/dev/ttyACM0

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable walle-web
sudo systemctl start walle-web

echo ""
echo "================================"
echo "  Installation terminée !"
echo "  Interface : http://wall-e:5000"
echo "================================"
