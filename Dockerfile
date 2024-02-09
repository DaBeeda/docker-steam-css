FROM ubuntu:focal

RUN apt-get update && \
    apt-get install -y wget lib32gcc-s1 curl unzip nginx && \
    dpkg --add-architecture i386; apt-get update && apt-get install -y libtinfo5:i386

RUN useradd -ms /bin/bash steam
WORKDIR /home/steam

USER steam

RUN wget -O /tmp/steamcmd_linux.tar.gz http://media.steampowered.com/installer/steamcmd_linux.tar.gz && \
    tar -xvzf /tmp/steamcmd_linux.tar.gz && \
    rm /tmp/steamcmd_linux.tar.gz

# Install CSS once to speed up container startup
RUN ./steamcmd.sh +login anonymous +force_install_dir ./css +app_update 232330 validate +quit # Update to date as of 2016-02-06

ENV CSS_HOSTNAME Counter-Strike Source Dedicated Server
ENV CSS_PASSWORD ""
ENV RCON_PASSWORD mysup3rs3cr3tpassw0rd

EXPOSE 27015/udp
EXPOSE 27015
EXPOSE 1200
EXPOSE 27005/udp
EXPOSE 27020/udp
EXPOSE 26901/udp

ADD ./entrypoint.sh entrypoint.sh

# Support for 64-bit systems
# https://www.gehaxelt.in/blog/cs-go-missing-steam-slash-sdk32-slash-steamclient-dot-so/
RUN mkdir -p /home/steam/.steam && ln -s /home/steam/linux32/ /home/steam/.steam/sdk32

# Add Source Mods
COPY --chown=steam:steam mods/ /temp
RUN cd /home/steam/css/cstrike && \
    tar zxvf /temp/mmsource-1.11.0-git1153-linux.tar.gz && \
    tar zxvf /temp/sourcemod-1.11.0-git6954-linux.tar.gz && \
    unzip /temp/quake_sounds1.8.zip && \
    unzip /temp/mapchooser_extended_1.10.2.zip && \
    mv /temp/gem_damage_report.smx addons/sourcemod/plugins && \
    mv /temp/mp_halftime.smx addons/sourcemod/plugins && \
    rm /temp/*

# Add default configuration files
ADD cfg/ /home/steam/css/cstrike/cfg

CMD ./entrypoint.sh
