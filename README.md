# Linuxprogram

# Checkpoint 2 - Linux (Processos, Serviços e Shell Scripting)

## Arquivos
- `monitor_auth.sh` → script para monitorar logins em `/var/log/auth.log`
- `monitor_who.sh` → script para monitorar usuários logados (`who`)
- `monitor_auth.service` → unit systemd do monitor_auth
- `monitor_who.service` → unit systemd do monitor_who

## o que rodei
```bash
sudo install -m 0755 monitor_auth.sh /usr/local/bin/monitor_auth.sh
sudo install -m 0755 monitor_who.sh /usr/local/bin/monitor_who.sh
sudo install -m 0644 monitor_auth.service /etc/systemd/system/monitor_auth.service
sudo install -m 0644 monitor_who.service /etc/systemd/system/monitor_who.service
sudo systemctl daemon-reload
sudo systemctl enable --now monitor_auth.service
sudo systemctl enable --now monitor_who.service
