FROM crowdsecurity/crowdsec:latest-debian
RUN apt update && \
    apt install -y curl && \
    curl -s https://packagecloud.io/install/repositories/crowdsec/crowdsec/script.deb.sh | bash && \ 
    apt update && \
    apt install -y \
      iptables \ 
      nftables \
      crowdsec-firewall-bouncer-iptables \ 
      crowdsec-firewall-bouncer-nftables &&
    apt autoremove && \
    apt clean && \
    rm -rf \
        /tmp/* \
        /var/lib/apt/lists/* \
        /var/tmp/* \
        /var/log/*

COPY entrypoint.sh entrypoint.sh
ENTRYPOINT /bin/bash /entrypoint.sh
