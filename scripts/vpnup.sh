#!/bin/bash
test -n "$IMAGE" || export IMAGE=johnnyrun/pulse-secure-client
docker ps -a |grep pulse-client || docker create --privileged --name pulse-client --device /dev/net/tun --cap-add net_admin --cap-add sys_admin --volume /tmp/.X11-unix:/tmp/.X11-unix --env DISPLAY  -v ~/.pulse-secure:/data  $IMAGE
CONTAINERIP=$(docker inspect pulse-client | jq '.[].NetworkSettings.Networks.bridge.IPAddress' -r)
xhost +$CONTAINERIP
docker ps  |grep pulse-client || docker start pulse-client
sudo nsenter -t $(pidof pulseUi) -n iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo nsenter -t $(pidof pulseUi) -n iptables -t nat -A POSTROUTING -o tun0 -j MASQUERADE
sudo route add default gw $CONTAINERIP
