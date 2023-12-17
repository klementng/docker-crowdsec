FROM crowdsecurity/crowdsec:latest-debian
RUN apt update && \
    apt install -y curl && \
    curl -s https://packagecloud.io/install/repositories/crowdsec/crowdsec/script.deb.sh | bash && \ 
    apt update && \
    apt install -y \
      iptables \ 
      crowdsec-firewall-bouncer-iptables && \
    apt autoremove && \
    apt clean && \
    rm -rf \
        /tmp/* \
        /var/lib/apt/lists/* \
        /var/tmp/* \
        /var/log/* && \
    touch crowdsec-firewall-bouncer.yaml.local && \
    
