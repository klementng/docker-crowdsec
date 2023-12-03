FROM crowdsecurity/crowdsec:latest-debian
RUN curl -s https://packagecloud.io/install/repositories/crowdsec/crowdsec/script.deb.sh | bash && \
    apt update && \
    apt install \
      iptables \ 
      ip6tables \ 
      crowdsec-firewall-bouncer-iptables
