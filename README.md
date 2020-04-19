# dnsmasq+adguardhom
dnsmasq的latest标签支持 amd64、arm64、i386、armhf 

adguardhom的latest标签只支持amd64。如果是arm64的板子，请使用 adguard/adguardhom:arm64-latest 。其他平台类似。

docker-compose 配置：
```
version: '3'
services:

  dnsmasq:
    container_name: dns_dnsmasq_web
    hostname: dnsmasq
    image: scjtqs/dnsmasq:latest
    ports:
      - 9084:8080
    networks:
      - dns_net
    restart: always
    volumes:
      - ./dnsmasq.conf:/etc/dnsmasq.conf
    environment:
      - HTTP_USER=admin
      - HTTP_PASS=123456
      
  adguardhome:
    container_name: dns_adguardhome
    hostname: adguardhome
    image: adguard/adguardhome:latest
    ports:
      - 192.168.50.50:53:53/udp
      - 192.168.50.50:53:53/tcp
      - 192.168.50.50:67:67/udp
      - 192.168.50.50:68:68/tcp
      - 192.168.50.50:68:68/udp
      - 853:853/tcp
      - 3000:3000/tcp
      - 9085:80
      - 9086:443
    networks:
      - dns_net
    restart: always
    volumes:
      - ./adguardhome/workdir:/opt/adguardhome/work
      - ./adguardhome/confdir:/opt/adguardhome/conf

networks:
  dns_net:
```
