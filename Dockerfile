FROM ubuntu:18.04
ENV DEBIAN_FRONTEND=noninteractive

# install pulse
# lsb-release is required by the install script of the pulse package
# iputils-ping is used in entrypoint.sh to keep the tunnel alive
# all other packages are dependencies of pulse secure, extracted from UBUNTU_16_17_18_DEPENDENCIES_WITH_VERSION in /usr/local/pulse/PulseClient_x86_64.sh
RUN apt-get update && \
apt-get install --no-install-recommends -y curl lsb-release iputils-ping ca-certificates iproute2 libc6 libwebkitgtk-1.0-0 libproxy1v5 libproxy1-plugin-gsettings libproxy1-plugin-webkit libdconf1 libgnome-keyring0 dconf-gsettings-backend 
RUN curl -O  http://webdev.web3.technion.ac.il/docs/cis/public/ssl-vpn/ps-pulse-ubuntu-debian.deb && dpkg -i *deb && \
rm ./*.deb && \
apt-get purge --autoremove -y lsb-release

# pulse wants to modify firewall rules and kernel parameters in order to disable ipv6, which is not only unnecessary but also not possible for an unprivileged container, so we replace it with a no-op
RUN ln -sf /bin/true /sbin/ip6tables && \
ln -sf /bin/true /sbin/sysctl

COPY ./entrypoint.sh /container_pulse.sh
ENTRYPOINT ["/container_pulse.sh"]
WORKDIR /data
VOLUME /data
