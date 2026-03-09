VENV = $(HOME)/walle/venv
PIP  = $(VENV)/bin/pip

update:
	@echo "Mise à jour des modules WALL-E..."
	$(PIP) install --quiet --upgrade git+https://github.com/Buy-n-large/walle-core.git
	$(PIP) install --quiet --upgrade git+https://github.com/Buy-n-large/walle-web.git
	@echo "OK — modules mis à jour"

start:
	@echo "Démarrage de WALL-E..."
	$(VENV)/bin/walle-web

status:
	$(VENV)/bin/pip list | grep walle

.PHONY: update start status
