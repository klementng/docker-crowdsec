FROM crowdsecurity/crowdsec:latest-debian
RUN apt update && \
    apt install -y curl && \
    curl -s https://packagecloud.io/install/repositories/crowdsec/crowdsec/script.deb.sh | bash && \ 
    apt update && \
    apt install -y \
      iptables \ 
      ip6tables \ 
      crowdsec-firewall-bouncer-iptables && \
    apt autoremove && \
    apt clean && \
    rm -rf \
        /script.deb.sh \
        /tmp/* \
        /var/lib/apt/lists/* \
        /var/tmp/* \
        /var/log/*
