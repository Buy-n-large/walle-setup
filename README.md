# walle-setup

Scripts d'installation et de mise à jour du Raspberry Pi WALL-E.

## Bootstrap (première installation)

Sur le Raspberry Pi, une seule commande :

```bash
curl -sSL https://raw.githubusercontent.com/Buy-n-large/walle-setup/main/bootstrap.sh | bash
```

## Mise à jour

```bash
cd ~/walle && make update
```

## Ce que fait le bootstrap

1. Installe les dépendances système (pip, git)
2. Clone tous les modules Buy-n-large
3. Installe chaque module Python
4. Configure le service systemd (démarrage automatique)
5. Configure le port série Arduino
