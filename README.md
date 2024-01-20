# Crowdsec + Crowdsec-firewall-bouncer
Automatic configuration of crowdsec + crowdsec-firewall-bouncer in a single docker image

## Install
Installation using docker compose 
```yaml
services:
  crowdsec:
    image: ghcr.io/klementng/docker-crowdsec:main
    container_name: crowdsec
    cap_add:
      - NET_ADMIN
    environment:
      - TZ=${TZ}
      - COLLECTIONS=crowdsecurity/nginx
      - LOCAL_API_URL=http://0.0.0.0:55555 # bind to the following port
    volumes:
      - ./crowdsec/config:/etc/crowdsec
      - ./crowdsec/data:/var/lib/crowdsec/data/
    userns_mode: host
    network_mode: host
```

## Configuring
This container extends the base docker image of crowdsec. Most setting remain the same as the base image. 
  - https://hub.docker.com/r/crowdsecurity/crowdsec- 
  - https://docs.crowdsec.net/docs/data_sources/docker/


## Files
The following file are overwritten on startup of container:
 - config.yml
 - bouncers/crowdsec-firewall-bouncer.yaml
 
To modify the above files create new .local in the same directory file (i.e. config.yaml.local). More Info:
 - [crowdsec](https://docs.crowdsec.net/docs/configuration/crowdsec_configuration/)
 - [crowdsec firewall bouncer](https://docs.crowdsec.net/u/bouncers/firewall/)


## Docker Environment variable  

- See https://github.com/crowdsecurity/crowdsec/tree/master/docker

<table>
  <tr>
    <th>Variable</th>
    <th>Default</th>
    <th>Description</th>
  </tr>
  <tr>
    <td>LOCAL_API_URL</td>
    <td>http://0.0.0.0:8080</td>
    <td><b>*Modified*</b> Set Server listening IP + LAPI url </td>
  </tr>
<tr>
    <td>Others</td>
    <td></td>
    <td><a href="https://github.com/crowdsecurity/crowdsec/blob/master/docker/README.md#environment-variables">Link</a></td>
  </tr>
</table>