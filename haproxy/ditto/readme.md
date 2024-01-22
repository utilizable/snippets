# Ditto haproxy tcp balance

Ditto allows to sync multiple worksations clipboard (linux,widnows) for doing this you need tcp balance..

## About ditto

<a href="https://ditto-cp.sourceforge.io/"><strong>Ditto</strong></a> is an extension to the standard windows clipboard. It saves each item placed on the clipboard allowing you access to any of those items at a later time.

## Ditto installers

1. <a href="https://github.com/sabrogden/Ditto/releases/download/3.24.214.0/DittoPortable_64bit_3_24_214_0.zip"><strong>Windows installer</strong></a>
2. <a href="https://app.assembla.com/spaces/dittox/wiki"><strong>Linux installer</strong></a>

## Haproxy tcp config

```sh

#Ditto standard tcp port is 23443

frontend tcp_frontend
   mode           tcp
   bind            *:23443
   default_backend tcp_backend 

backend tcp_backend 
   mode tcp
   balance roundrobin
   timeout connect 5m  # greater than hello timeout
   timeout server  3m  # greater than idle timeout
option splice-request
   server win10-moonlight 10.0.0.100:23443 check
   #server win10-developer 10.0.0.101:23443 cookie win10-developer 
```
