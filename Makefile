VENV     = $(HOME)/walle/venv
PIP      = $(VENV)/bin/pip
ARDUINO  = $(HOME)/walle/walle-arduino

update:
	@echo "Mise à jour des modules Python..."
	$(PIP) install --quiet --upgrade \
		git+https://github.com/Buy-n-large/walle-core.git \
		git+https://github.com/Buy-n-large/walle-web.git
	@echo "Mise à jour du code Arduino..."
	git -C $(ARDUINO) pull -q
	@echo "Redémarrage du service..."
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

.PHONY: update start stop restart status upload-arduino logs
