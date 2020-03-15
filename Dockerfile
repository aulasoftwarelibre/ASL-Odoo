FROM debian:stable-slim AS base
LABEL MAINTAINER "Sergio Gómez <sergio@uco.es>"

ENV ODOO_VERSION 12.0
ENV VIRTUAL_ENV /opt/venv
ENV PATH "$VIRTUAL_ENV/bin:$PATH"

WORKDIR /odoo

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    gcc \
    g++ \
    libldap2-dev \
    libpq-dev \
    libsasl2-dev \
    python3-dev \
    virtualenv \
    && curl https://raw.githubusercontent.com/odoo/odoo/${ODOO_VERSION}/requirements.txt -o requirements.txt \
    && python3 -m virtualenv --python=/usr/bin/python3 $VIRTUAL_ENV \
    && pip install -r requirements.txt

COPY ./requirements.txt /odoo/requirements-extra.txt
RUN pip install -r requirements-extra.txt

FROM debian:stable-slim
LABEL MAINTAINER "Sergio Gómez <sergio@uco.es>"

RUN groupadd -r -g 999 odoo && useradd -r -g odoo -u 999 odoo

ENV ODOO_RC /etc/odoo/odoo.conf
ENV ODOO_VERSION 12.0
ENV VIRTUAL_ENV /opt/venv
ENV PATH "$VIRTUAL_ENV/bin:$PATH"

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    nodejs \
    node-less \
    npm \
    postgresql-client \
    virtualenv \
    wkhtmltopdf \
    && apt-get purge \
    && rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh /
COPY ./wait-for-psql.py /usr/local/bin/wait-for-psql.py
COPY ./odoo.conf /etc/odoo/

RUN mkdir -p /odoo /data /opt/addons_extra \
    && chown -R odoo:odoo /odoo /data /opt/addons_extra
VOLUME [ "/data" ]

# Copy python dependencies from base
COPY --from=base ${VIRTUAL_ENV} ${VIRTUAL_ENV}

# Set default user when running the container
USER odoo

RUN git clone --depth=1 --single-branch --branch=$ODOO_VERSION https://github.com/odoo/odoo.git /odoo/

COPY ./addons_extra /opt/addons_extra

EXPOSE 8069

WORKDIR /odoo

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/odoo/odoo-bin"]
