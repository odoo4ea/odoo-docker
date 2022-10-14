FROM debian:bullseye-slim as odoo-compile
SHELL ["/bin/bash", "-xo", "pipefail", "-c"]
ENV ODOO_VERSION 15.0

COPY ./requirements.txt /

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        python3-dev \
        python3-pip \
        python3-venv \
        python3-wheel \
        libxslt1-dev \
        build-essential \
        gcc \
    && python3 -m pip install --upgrade pip \
    && python3 -m venv /opt/venv \
    && rm -rf /var/lib/apt/lists/*

# Make sure we use the virtualenv:
ENV PATH="/opt/venv/bin:$PATH"

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        dirmngr \
        fonts-noto-cjk \
        libssl-dev \
        node-less \
        libzip-dev \
        libldap2-dev \
        libsasl2-dev \
        libpq-dev \
        libffi-dev \
        python3-num2words \
        python3-pdfminer \
        python3-phonenumbers \
        python3-pyldap \
        python3-qrcode \
        python3-renderpm \
        python3-setuptools \
        python3-slugify \
        python3-vobject \
        python3-watchdog \
        python3-xlrd \
        python3-xlwt \
        xz-utils \
        unzip \
    && curl -L -O https://github.com/odoo/odoo/archive/refs/heads/${ODOO_VERSION}.zip \
    && unzip -qo ${ODOO_VERSION}.zip -d /opt/odoo \
    && mv /opt/odoo/odoo-${ODOO_VERSION} /opt/odoo/${ODOO_VERSION} \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir -r /opt/odoo/${ODOO_VERSION}/requirements.txt \
    && pip install --no-cache-dir -r /requirements.txt \
    && pip install --no-cache-dir -e /opt/odoo/${ODOO_VERSION}/ \
    && find . -type f -name "*.py[co]" -delete \
    && find . -type d -name "__pycache__" -delete \
    && rm -rf /var/lib/apt/lists/*


FROM debian:bullseye-slim as odoo-build
LABEL OdooGAP <info@odoogap.com>

SHELL ["/bin/bash", "-xo", "pipefail", "-c"]

# Generate locale C.UTF-8 for postgres and general locale data
ENV LANG C.UTF-8
# Make sure we use the virtualenv:
ENV PATH="/opt/venv/bin:$PATH"

# Copy entrypoint script and Odoo configuration file
COPY ./entrypoint.sh /
COPY ./odoo.conf /etc/odoo/
COPY --from=odoo-compile /opt/odoo /opt/odoo/
COPY --from=odoo-compile /opt/venv /opt/venv
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        python3-venv \
        ca-certificates \
        gnupg \
        curl \
        npm \
        node-less \
    && echo 'deb http://apt.postgresql.org/pub/repos/apt/ bullseye-pgdg main' > /etc/apt/sources.list.d/pgdg.list \
    && GNUPGHOME="$(mktemp -d)" \
    && export GNUPGHOME \
    && repokey='B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8' \
    && gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "${repokey}" \
    && gpg --batch --armor --export "${repokey}" > /etc/apt/trusted.gpg.d/pgdg.gpg.asc \
    && gpgconf --kill all \
    && rm -rf "$GNUPGHOME" \
    && curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.buster_amd64.deb \
    && echo 'ea8277df4297afc507c61122f3c349af142f31e5 wkhtmltox.deb' | sha1sum -c - \
    && apt-get install -y --no-install-recommends ./wkhtmltox.deb \
    && apt-get install --no-install-recommends -y postgresql-client \
    && npm install -g rtlcss \
    && adduser --system --quiet --shell=/bin/bash --home=/opt/odoo --gecos 'ODOO' --group odoo \ 
    && mkdir -p /etc/odoo \
    && mkdir -p /mnt/extra-addons /mnt/ee-addons /var/lib/odoo \
    && chown odoo /etc/odoo/odoo.conf \
    && chown -R odoo /mnt/extra-addons /mnt/ee-addons /var/lib/odoo \
    && rm -f /etc/apt/sources.list.d/pgdg.list \
    && rm -rf /var/lib/apt/lists/* wkhtmltox.deb

# Make sure scripts in .local are usable:
ENV PATH=/root/.local/bin:$PATH

VOLUME ["/var/lib/odoo"]

# Expose Odoo services
EXPOSE 8069 8072

# Set the default config file
ENV ODOO_RC /etc/odoo/odoo.conf

COPY wait-for-psql.py /usr/local/bin/wait-for-psql.py

# Set default user when running the container
USER odoo

ENTRYPOINT ["/entrypoint.sh"]
CMD ["odoo"]