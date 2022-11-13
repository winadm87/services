#!/bin/bash
##########################################
# This is default how-to for prometheus
# Author Ivanov Artyom
# Created 11.2022
# Version 1.0
##########################################

# install server on ubuntu 22
# create user and group
sudo groupadd --system prometheus
sudo useradd -s /sbin/nologin --system -g prometheus prometheus
# make some preparations
sudo mkdir /var/lib/prometheus
for i in rules rules.d files_sd; do sudo mkdir -p /etc/prometheus/${i}; done
sudo apt update
sudo apt -y install wget curl vim
mkdir -p /tmp/prometheus && cd /tmp/prometheus
# lets begin...
curl -s https://api.github.com/repos/prometheus/prometheus/releases/latest | grep browser_download_url | grep linux-amd64 | cut -d '"' -f 4 | wget -qi -
tar xvf prometheus*.tar.gz
cd prometheus*/
sudo mv prometheus promtool /usr/local/bin/
sudo mv prometheus.yml /etc/prometheus/prometheus.yml
sudo mv consoles/ console_libraries/ /etc/prometheus/
cd ~
# ... and now lets config
nano /etc/prometheus/prometheus.yml
===============================

# my global config
global:
  scrape_interval:     15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
  # scrape_timeout is set to the global default (10s).

# Alertmanager configuration
alerting:
  alertmanagers:
  - static_configs:
    - targets:
      # - alertmanager:9093

# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: 'prometheus'

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    static_configs:
    - targets: ['localhost:9090']
===============================

# lets create a service
sudo nano /etc/systemd/system/prometheus.service

===============================
[Unit]
Description=Prometheus
Documentation=https://prometheus.io/docs/introduction/overview/
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
Environment="GOMAXPROCS=1"
User=prometheus
Group=prometheus
ExecReload=/bin/kill -HUP $MAINPID
ExecStart=/usr/local/bin/prometheus   --config.file=/etc/prometheus/prometheus.yml  --web.config.file=/etc/prometheus/web.yml --storage.tsdb.path=/var/lib/prometheus   --web.console.templates=/etc/prometheus/consoles   --web.console.libraries=/etc/prometheus/console_libraries   --web.listen-address=0.0.0.0:9090   --web.external-url=

SyslogIdentifier=prometheus
Restart=always

[Install]
WantedBy=multi-user.target
===============================

# change permissions on execs
for i in rules rules.d files_sd; do sudo chown -R prometheus:prometheus /etc/prometheus/${i}; done
for i in rules rules.d files_sd; do sudo chmod -R 775 /etc/prometheus/${i}; done
sudo chown -R prometheus:prometheus /var/lib/prometheus/
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus

# firewall
sudo ufw allow ssh
sudo ufw allow 9090/tcp
sudo ufw enable

# lets secure out installation
sudo apt update
sudo apt install python3-bcrypt -y
nano gen-pass.py

================================
import getpass
import bcrypt

password = getpass.getpass("password: ")
hashed_password = bcrypt.hashpw(password.encode("utf-8"), bcrypt.gensalt())
print(hashed_password.decode())
================================

python3 gen-pass.py
nano /etc/prometheus/web.yml

================================
basic_auth_users:
       admin: '$2b$12$.9J0cFyfcLaNjwBW9McDWObbLjM0n0Wb0ToW9wZArxfmwVlctK8SS'
================================

sudo nano /etc/systemd/system/prometheus.service

================================
ExecStart=....
        --web.config.file=/etc/prometheus/web.yml
		.....
================================

sudo systemctl daemon-reload
sudo systemctl restart prometheus
sudo systemctl enable prometheus

# lets install node exporter on prometheus itself. node-exporter - basic linux metrics
curl -s https://api.github.com/repos/prometheus/node_exporter/releases/latest | grep browser_download_url | grep linux-amd64 |  cut -d '"' -f 4 | wget -qi -
tar xvf node_exporter-1.4.0.linux-amd64.tar.gz
cd node_exporter-1.4.0.linux-amd64/
sudo mv node_exporter /usr/local/bin/
node_exporter --version
nano /etc/systemd/system/node_exporter.service

=================================
[Unit]
Description=Prometheus
Documentation=https://github.com/prometheus/node_exporter
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=prometheus
Group=prometheus
ExecReload=/bin/kill -HUP $MAINPID
ExecStart=/usr/local/bin/node_exporter \
    --collector.cpu \
    --collector.diskstats \
    --collector.filesystem \
    --collector.loadavg \
    --collector.meminfo \
    --collector.filefd \
    --collector.netdev \
    --collector.stat \
    --collector.netstat \
    --collector.systemd \
    --collector.uname \
    --collector.vmstat \
    --collector.time \
    --collector.mdadm \
    --collector.zfs \
    --collector.tcpstat \
    --collector.bonding \
    --collector.hwmon \
    --collector.arp \
    --web.listen-address=:9100 \
    --web.telemetry-path="/metrics"

SyslogIdentifier=node_exporter
Restart=always

[Install]
WantedBy=multi-user.target
=================================

# now lets config prometheus.yaml for this exporter

=================================
# Linux Servers
  - job_name: linux-servers-1
    static_configs:
      - targets: ['192.168.126.135:9100']
        labels:
          alias: srv-python-linux

  - job_name: linux-servers-2
    static_configs:
      - targets: ['localhost:9100']
        labels:
          alias: srv-pms-linux

=================================

sudo ufw allow 9100/tcp
sudo ufw reload
sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl start node_exporter

# lets monitor apache2
sudo nano /etc/apache2/mods-enabled/status.conf

=================================
......
Require ip 192.168.126.0/24
......
=================================

sudo systemctl restart apache2
curl -s https://api.github.com/repos/Lusitaniae/apache_exporter/releases/latest|grep browser_download_url|grep linux-amd64|cut -d '"' -f 4|wget -qi -
tar xvf apache_exporter-0.11.0.linux-amd64.tar.gz
sudo cp apache_exporter-*.linux-amd64/apache_exporter /usr/local/bin
sudo chmod +x /usr/local/bin/apache_exporter
sudo groupadd --system prometheus
sudo useradd -s /sbin/nologin --system -g prometheus prometheus
nano /etc/systemd/system/apache_exporter.service

=================================
[Unit]
Description=Prometheus
Documentation=https://github.com/Lusitaniae/apache_exporter
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=prometheus
Group=prometheus
ExecReload=/bin/kill -HUP $MAINPID
ExecStart=/usr/local/bin/apache_exporter \
  --insecure \
  --scrape_uri=http://localhost/server-status/?auto \
  --telemetry.address=0.0.0.0:9117 \
  --telemetry.endpoint=/metrics

SyslogIdentifier=apache_exporter
Restart=always

[Install]
WantedBy=multi-user.target
=================================

sudo ufw enable 9117/tcp
sudo ufw allow 9117/tcp
sudo ufw reload
sudo systemctl daemon-reload
sudo systemctl start apache_exporter.service
sudo systemctl enable apache_exporter.service
# Dont forget to configure prometheus.yaml for new scrapper
=================================
  - job_name: apache1
    static_configs:
      - targets: ['192.168.126.135:9117']
        labels:
          alias: srv-python-apache2
=================================

# lets install alertmanager
wget https://github.com/prometheus/alertmanager/releases/download/v0.24.0/alertmanager-0.24.0.linux-amd64.tar.gz
tar -xvf alertmanager-0.24.0.linux-amd64.tar.gz
sudo cp alertmanager /usr/local/bin
sudo cp amtool /usr/local/bin/
sudo cp alertmanager-0.24.0.linux-amd64/alertmanager.yml /etc/prometheus/
sudo chown -R prometheus:prometheus /etc/prometheus/alertmanager.yml
sudo ufw allow 9093/tcp
sudo ufw reload
sudo mkdir /etc/prometheus/alertmanagerdata
sudo chown -Rfv prometheus:prometheus /etc/prometheus/alertmanagerdata
sudo nano /etc/systemd/system/prometheus-alertmanager.service

==================================
[Unit]
Description=Alertmanager Service
After=network.target
[Service]
EnvironmentFile=-/etc/default/alertmanager
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/alertmanager --config.file=/etc/prometheus/alertmanager.yml --storage.path=/etc/prometheus/alertmanagerdata
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure
[Install]
WantedBy=multi-user.target
==================================

sudo systemctl daemon-reload
sudo systemctl restart prometheus-alertmanager.service
sudo systemctl status prometheus-alertmanager.service

# lets create first rule
sudo nano /etc/prometheus/rules/rules.yml

==================================
groups:
  - name: node_exporter
    rules:
      - alert: PrometheusTargetMissing
        expr: up == 0
        for: 0m
        labels:
          severity: critical
        annotations:
          summary: "Сервис node_exporter на сервере {{ $labels.instance }} недоступен"
          description: "Возможно сервис node_exporter упал или сервер недоступен\n VALUE = {{ $value }}\n LABELS = {{ $labels }}"
==================================

# and change prometheus.yml a little
sudo nano /etc/prometheus/prometheus.yml

==================================
# Alertmanager configuration
alerting:
  alertmanagers:
    - static_configs:
        - targets: ['localhost:9093']
          # - alertmanager:9093

# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:
  - "rules.yml"
  # - "first_rules.yml"
  # - "second_rules.yml"
...
  - job_name: alertmanager
    static_configs:
      - targets: ['localhost:9093']
...
==================================

# check real time logs for service
sudo journalctl --follow --no-pager --boot --unit prometheus-alertmanager.service

# lets get alerts to telegram
sudo nano /etc/prometheus/alertmanager.yml

==================================
global:
  resolve_timeout: 5m
route:
  group_by: ['alertname']
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 1h
  receiver: "telegram"
receivers:
  - name: 'telegram'
    telegram_configs:
    - bot_token: 'TOKEN'
      chat_id: -groupid
      send_resolved: true
      api_url: "https://api.telegram.org"
      parse_mode: "HTML"
inhibit_rules:
  - source_match:
      severity: 'critical'
    target_match:
      severity: 'warning'
    equal: ['alertname', 'dev', 'instance']
==================================

# lets create nginx exporter
wget https://github.com/nginxinc/nginx-prometheus-exporter/releases/download/v0.11.0/nginx-prometheus-exporter_0.11.0_linux_amd64.tar.gz
# unarchive and copy nginx-prometheus-exporter to /usr/local/bin
# nxet we create a service 
sudo nano /etc/systemd/system/nginx_prometheus_exporter.service

==================================
[Unit]
Description=Prometheus
Documentation=https://github.com/nginxinc/nginx-prometheus-exporter
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=prometheus
Group=prometheus
ExecReload=/bin/kill -HUP $MAINPID
ExecStart=/usr/local/bin/nginx-prometheus-exporter \
  -nginx.scrape-uri=http://localhost/basic_status \
  -web.listen-address=:9113 \
  -web.telemetry-path="/metrics"

SyslogIdentifier=nginx-prometheus-exporter
Restart=always

[Install]
WantedBy=multi-user.target
==================================

# and add string to 
sudo nano /etc/nginx/sites-available/default

==================================
.............
        server_name _;
        location /basic_status {
        stub_status;
        allow 0.0.0.0;          #allow request from everywhere
        #deny all;              #deny all other hosts
        }
.............
==================================
sudo ufw allow 9113/tcp
sudo ufw reload
sudo daemon-reload
sudo systemctl start nginx_prometheus_exporter.service
sudo systemctl enable nginx_prometheus_exporter.service
# and add some string to prometheus.yaml
==================================
# Nginx Servers
  - job_name: nginx1
    static_configs:
      - targets: ['192.168.126.133:9113']
        labels:
          alias: srv-test3-nginx
==================================
