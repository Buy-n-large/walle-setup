#!/bin/bash
set -e

ORG="Buy-n-large"
INSTALL_DIR="$HOME/walle"
VENV="$INSTALL_DIR/venv"

echo "================================"
echo "  WALL-E Bootstrap"
echo "================================"

# 1. Dépendances système
echo "[1/6] Dépendances système..."
sudo apt-get update -qq
sudo apt-get install -y -qq python3-pip python3-venv git curl nginx

# 2. arduino-cli
echo "[2/6] Installation arduino-cli..."
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
echo "[3/6] Environnement Python..."
mkdir -p "$INSTALL_DIR"
python3 -m venv "$VENV"
source "$VENV/bin/activate"
pip install --quiet --upgrade pip

# 4. Modules WALL-E
echo "[4/6] Installation des modules..."
pip install --quiet --force-reinstall --no-cache-dir \
  git+https://github.com/$ORG/walle-core.git \
  git+https://github.com/$ORG/walle-web.git

# 5. Clone walle-arduino
echo "[5/6] Code Arduino..."
if [ ! -d "$INSTALL_DIR/walle-arduino" ]; then
  git clone https://github.com/$ORG/walle-arduino.git "$INSTALL_DIR/walle-arduino"
else
  git -C "$INSTALL_DIR/walle-arduino" pull -q
fi

# Makefile principal
curl -sSL https://raw.githubusercontent.com/$ORG/walle-setup/main/Makefile -o "$INSTALL_DIR/Makefile"

# 6. Service systemd pour Flask
echo "[6/6] Configuration services..."
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
sudo systemctl restart walle-web

# Nginx reverse proxy port 80 → Flask 5000
sudo tee /etc/nginx/sites-available/walle > /dev/null << 'EOF'
server {
    listen 80;
    server_name wall-e wall-e.local _;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
EOF

sudo ln -sf /etc/nginx/sites-available/walle /etc/nginx/sites-enabled/walle
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t && sudo systemctl restart nginx

echo ""
echo "================================"
echo "  Installation terminée !"
echo "  Interface : http://wall-e"
echo "  Reset     : cd ~/walle && make reset"
echo "================================"
