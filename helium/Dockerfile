FROM python:3.13.0

# Note: We will need the DOPPLER_TOKEN run-time arg to be passed in when we run the container
# This will be passed in as an ENV variable to the container
ARG USER=helium

# We're going to create a user to run the services within the container - user and group both called 'helium'
RUN groupadd ${USER} && useradd -m -g ${USER} ${USER}

# Let's create a user to run the services within the container
# libpq-dev is needed for psycopg2
# gnupg is needed for installing doppler
RUN apt-get update && \
    apt-get install -y \
    apt-transport-https \
    ca-certificates \
    bash \
    curl \
    dumb-init \
    libpq-dev \
    gnupg && \
    curl -sLf --retry 3 --tlsv1.2 --proto "=https" 'https://packages.doppler.com/public/cli/gpg.DE2A7741A397C129.key' | gpg --dearmor -o /usr/share/keyrings/doppler-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/doppler-archive-keyring.gpg] https://packages.doppler.com/public/cli/deb/debian any-version main" | tee /etc/apt/sources.list.d/doppler-cli.list && \
    apt-get update && \
    apt-get -y install doppler

# Let's run the steps to build this image
WORKDIR /app
COPY . .

# Let's ensure that we have the needed permissions to execute the services within the container
RUN chown -R ${USER}:${USER} /app && \
    pip install --upgrade pip && \
    pip install -r /app/production.txt && \
    mkdir /app/data && \
    chown -R ${USER}:${USER} /app/data

# Let's switch our users to de-root the container
USER ${USER}

# Set the DOPPLER_TOKEN from the arg.
EXPOSE 8000

# Run the app
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD [ "python", "/app/main.py" ]
