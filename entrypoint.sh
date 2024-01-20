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
api_url: ${LOCAL_API_URL:-http://0.0.0.0:8080/}
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
#  - FORWARD
#  - DOCKER-USER

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

mkdir -p /etc/crowdsec/bouncers/
cscli bouncers delete localhost
cscli bouncers add localhost | cut -d$'\n' -f3 | xargs -I {} printf "${FIREWALL_CONFIG}" > /etc/crowdsec/bouncers/crowdsec-firewall-bouncer.yaml


/usr/bin/crowdsec-firewall-bouncer -c /etc/crowdsec/bouncers/crowdsec-firewall-bouncer.yaml;
/bin/bash /docker_start.sh $@