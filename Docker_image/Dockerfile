FROM ubuntu:18.04
LABEL MAINTAINER Héctor Romero López <cyberh99@protonmail.com>

ENV GIT_BRANCH=12.0\
        DATABASE_HOST=db\
        DATABASE_USER=odoo\
        DATABASE_PASSWORD=odoo\
        DATABASE_PORT=5432\
        ODOO_RC=/etc/odoo-server.conf \
        PYTHONIOENCODING=UTF-8

# Set timezone to UTC
RUN ln -sf /usr/share/zoneinfo/Etc/UTC /etc/localtime


RUN     apt-get update \
        && apt-get install -y --no-install-recommends \
            ffmpeg \ 
            ca-certificates \
            curl \
            gcc \
            git \
            npm \
            nodejs \
            dirmngr \
            node-less \
            libxml2-dev \
            python3-gevent \
            python3-ldap \
            python3-pip  \
            python3-qrcode \
            python3-feedparser \
            python3-renderpm \
            python3-vobject \
            python3-setuptools\
            python3-dev \
            libxml2-dev \
            libxslt1-dev\
            libldap2-dev \
            libsasl2-dev \
            python-watchdog \
            locales \
            libpq-dev \
            gnupg \
            gnupg2 \
            systemd \
                                                python3-setuptools \
                        && curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.bionic_amd64.deb \
                        && dpkg --force-depends -i wkhtmltox.deb \
                        && apt-get -y install -f --no-install-recommends \
                        && curl -q https://www.postgresql.org/media/keys/ACCC4CF8.asc  | apt-key add - \
                        && echo 'deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main' > etc/apt/sources.list.d/pgdg.list \& apt-get update  \
                        && apt-get install -y postgresql-client-10 \
                        && rm -rf /var/lib/apt/lists/* wkhtmltox.deb \
                        && pip3 install psycogreen==1.0


RUN npm install -g less@2.7.3 less-plugin-clean-css@1.5.1 \
    &&  locale-gen es_ES.UTF-8 \
    &&  update-locale LC_ALL=es_ES.UTF-8 LANG=es_ES.UTF-8 

RUN useradd  --create-home --home-dir /home/odoo --no-log-init odoo \
&& mkdir /var/log/odoo \
&& touch /var/log/odoo/odoo-server.log


# Copiamos el entrypoint y el archivo de configuracion por defecto
COPY resources/odoo-server.conf /etc/odoo-server.conf
COPY resources/entrypoint.sh /entrypoint.sh
COPY resources/requirements.txt /opt/requirements.txt

# Instalacion de wheel
RUN pip3 install wheel \
 && pip3 install -r /opt/requirements.txt

RUN ln -s /odoo/odoo-bin /bin/odoo \
     &&  ln -s /usr/bin/nodejs /usr/bin/nodeInstall

# Cambiamos los permisos de todos los subdirectorios
RUN mkdir /odoo/ \
    && chmod 755 -R /odoo/ \
    && chown -R odoo:odoo /var/log/odoo /odoo/

# Cambiamos de usuario para crear la estructura de directorios
USER odoo
RUN git clone --depth=1 --branch=$GIT_BRANCH https://github.com/odoo/odoo.git /odoo/
RUN  bin/bash -c "mkdir -p /odoo/{addons_netbss,addons_OCA}"

EXPOSE 8069

ENTRYPOINT ["/entrypoint.sh"]
CMD ["odoo"]
