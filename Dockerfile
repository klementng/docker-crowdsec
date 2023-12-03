FROM crowdsecurity/crowdsec:latest-debian
RUN wget https://packagecloud.io/install/repositories/crowdsec/crowdsec/script.deb.sh && \
    chmod +x script.deb.sh && \ 
    bash script.deb.sh && \
    apt update && \
    apt install \
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
