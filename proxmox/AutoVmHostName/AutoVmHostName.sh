#!/bin/bash

# DESCRIPTION:
# Use vm ID as: ip address / hostname / bridge number.
# ID 10010 -> IP 1.0.0.10 -> HOSTNAME 1-0-0-10 -> BRIDGE vmbr[1]

dnsmasq=$(dpkg --get-selections | grep dnsmasq)
if [[ ! "$dnsmasq" ]]; then
  apt-get update -y -qq >/dev/null
  apt-get install -y -qq dnsutils dnsmasq 
fi

while true; do
  gVmIds=($(pct list | grep 'running\|stopped' | sed 's/[A-Za-z].*//g' | sed 's/ //g' | sed -r '/([0-9]{5})/!d' 2>/dev/null)) 
  gVmIds+=($(qm list | grep 'running\|stopped' | sed 's/[A-Za-z].*//g' | sed 's/ //g' | sed -r '/([0-9]{5})/!d' 2>/dev/null)) 

  gBridges=($(cat /etc/network/interfaces | grep "auto vmbr" | sed 's/auto //g'))

  for i in ${gVmIds[@]}; do

    #CHECK AND CHANGE BRIDGE IN VM CONFIG
    mBridgeNumber=$(echo $i | sed 's/[0-9]//2g');
    mConfigurationFilePath=$(find /etc/pve/ -name $i.conf)
    mBridgeAssigned=$(cat $mConfigurationFilePath | grep bridge | sed 's/.*e=//g' | sed 's/,.*//g');

    if [[ "vmbr$mBridgeNumber" != "$mBridgeAssigned" ]]; then
      #CHECK BRIDGE REALY EXIST.IF NOT DONT TOUCH
      for j in ${gBridges[@]}; do
        if [[ "vmbr$mBridgeNumber" == "$j" ]]; then
          sed -i 's/$mBridgeAssigned/vmbr$mBridgeNumber/g' $mConfigurationFilePath 
        fi
      done
    fi

    #ASSING MAC, IP, HOSTNAME TO DNSMASQ
    mConfig=$(cat $mConfigurationFilePath); 
    mVmMacAddress=$(echo $mConfig | sed -E 's/.*([0-9a-fA-F:]{17}).*/\1/')
    mVmHostname=$(echo $i | rev | sed -E 's/(.)/\1-/2g' | rev | sed 's/-//')
    mVmIpAddress=$(echo $i | rev | sed -E 's/(.)/\1./2g' | rev | sed 's/.//')

    bMac=$(cat /etc/dnsmasq.conf | grep "$mVmMacAddress\|$mVmHostname" 2>/dev/null )
    bHost=$(cat /etc/dnsmasq.conf | grep "$mVmHostname" 2>/dev/null )

    if [[ "$bMac" == "" ]] && [[ "$bHost" == "" ]]; then
      var="dhcp-host=$mVmMacAddress,$mVmHostname,$mVmIpAddress"
      sed -i -e "1i\ $var" /etc/dnsmasq.conf
      systemctl restart dnsmasq.service
    else
      raw=$(cat /etc/dnsmasq.conf | grep $mVmHostname | sed -e 's/.*=//g')
      hostFromDnsmasq=();
      readarray -td, hostFromDnsmasq <<<"$raw"; declare -p hostFromDnsmasq >/dev/null;

      for k in ${hostFromDnsmasq[@]}; do echo $k; done
        if [[ "${hostFromDnsmasq[0]}" != "$mVmMacAddress" ]] || [[ "${hostFromDnsmasq[1]}" != "$mVmHostname" ]]
          then
            sed -i -e "/$mVmHostname/d" /etc/dnsmasq.conf
            var="dhcp-host=$mVmMacAddress,$mVmHostname,$mVmIpAddress"
            sed -i -e "1i\ $var" /etc/dnsmasq.conf
            systemctl restart dnsmasq.service
          fi
    fi
  done

#  echo > /var/lib/dnsmasq/dnsmasq.leases
done
