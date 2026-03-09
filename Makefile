VENV     = $(HOME)/walle/venv
PIP      = $(VENV)/bin/pip
ARDUINO  = $(HOME)/walle/walle-arduino

update:
	@echo "Mise à jour des modules Python..."
	$(PIP) install --quiet --force-reinstall --no-cache-dir \
		git+https://github.com/Buy-n-large/walle-core.git \
		git+https://github.com/Buy-n-large/walle-web.git
	@echo "Mise à jour du code Arduino..."
	git -C $(ARDUINO) pull -q
	sudo systemctl restart walle-web
	@echo "OK"

start:
	sudo systemctl start walle-web

stop:
	sudo systemctl stop walle-web

restart:
	sudo systemctl restart walle-web

status:
	sudo systemctl status walle-web

upload-arduino:
	cd $(ARDUINO) && make upload

logs:
	sudo journalctl -u walle-web -f

reset:
	@echo "Reset complet de l'installation WALL-E..."
	-sudo systemctl stop walle-web
	-sudo systemctl disable walle-web
	-sudo rm -f /etc/systemd/system/walle-web.service
	-sudo systemctl daemon-reload
	-sudo rm -rf $(HOME)/walle
	@echo "Prêt pour une réinstallation fraîche :"
	@echo "  curl -sSL https://raw.githubusercontent.com/Buy-n-large/walle-setup/main/bootstrap.sh | bash"

.PHONY: update start stop restart status upload-arduino logs reset
