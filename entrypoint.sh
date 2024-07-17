#!/bin/bash 

FIREWALL_CONFIG=$(cat <<EOF
mode: iptables
update_frequency: 10s
log_mode: file
log_dir: /var/log/
log_level: info
log_compression: true
log_max_size: 100
log_max_backups: 3
log_max_age: 30
api_url: ${LOCAL_API_URL:-http://0.0.0.0:8080}
api_key: {}
insecure_skip_verify: false
disable_ipv6: false
deny_action: DROP
deny_log: false
supported_decisions_types:
  - ban
#to change log prefix
#deny_log_prefix: "crowdsec: "
#to change the blacklists name
blacklists_ipv4: crowdsec-blacklists
blacklists_ipv6: crowdsec6-blacklists
#type of ipset to use
ipset_type: nethash
#if present, insert rule in those chains
iptables_chains:
  - INPUT
  - FORWARD
  - DOCKER-USER

## nftables
nftables:
  ipv4:
    enabled: true
    set-only: false
    table: crowdsec
    chain: crowdsec-chain
    priority: -10
  ipv6:
    enabled: true
    set-only: false
    table: crowdsec6
    chain: crowdsec6-chain
    priority: -10

nftables_hooks:
  - input
  - forward

# packet filter
pf:
  # an empty string disables the anchor
  anchor_name: ""

prometheus:
  enabled: false
  listen_addr: 127.0.0.1
  listen_port: 60601
EOF
)

CONFIG=$(cat <<EOF
common:
  daemonize: false
  log_media: stdout
  log_level: info
  log_dir: /var/log/
  working_dir: .
config_paths:
  config_dir: /etc/crowdsec/
  data_dir: /var/lib/crowdsec/data/
  simulation_path: /etc/crowdsec/simulation.yaml
  hub_dir: /etc/crowdsec/hub/
  index_path: /etc/crowdsec/hub/.index.json
  notification_dir: /etc/crowdsec/notifications/
  plugin_dir: /usr/local/lib/crowdsec/plugins/
crowdsec_service:
  acquisition_path: /etc/crowdsec/acquis.yaml
  acquisition_dir: /etc/crowdsec/acquis.d
  parser_routines: 1
plugin_config:
  user: nobody
  group: nogroup
cscli:
  output: human
db_config:
  log_level: info
  type: sqlite
  db_path: /var/lib/crowdsec/data/crowdsec.db
  flush:
    max_items: 5000
    max_age: 7d
  use_wal: false
api:
  client:
    insecure_skip_verify: false
    credentials_path: /etc/crowdsec/local_api_credentials.yaml
  server:
    log_level: info
    listen_uri: $(echo ${LOCAL_API_URL:-http://0.0.0.0:8080} | cut  -d'/' -f3)
    profiles_path: /etc/crowdsec/profiles.yaml
    trusted_ips: # IP ranges, or IPs which can have admin API access
      - 127.0.0.1
      - ::1
    online_client: # Central API credentials (to push signals and receive bad IPs)
      credentials_path: /etc/crowdsec//online_api_credentials.yaml
    enable: true
prometheus:
  enabled: true
  level: full
  listen_addr: 0.0.0.0
  listen_port: 6060
EOF
)

if [ $# -gt 0 ]; then
    /bin/bash /docker_start.sh $@
    
else
    echo "${CONFIG}" > /etc/crowdsec/config.yaml
    mkdir -p /etc/crowdsec/bouncers/
    cscli bouncers delete localhost 2>&1 > /dev/null
    cscli bouncers add localhost | cut -d$'\n' -f3 | xargs -I {} printf "${FIREWALL_CONFIG}" > /etc/crowdsec/bouncers/crowdsec-firewall-bouncer.yaml

    /bin/bash /docker_start.sh $@ &
    sleep 10
    /usr/bin/crowdsec-firewall-bouncer -v -c /etc/crowdsec/bouncers/crowdsec-firewall-bouncer.yaml &

    wait $!
fi
