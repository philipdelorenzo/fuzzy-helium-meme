FROM python:3.13.0

ARG USER=helium
ARG DOPPLER_PROJECT=
ARG DOPPLER_CONFIG=
ARG DOPPLER_TOKEN=

# Let's create a user to run the services within the container
RUN groupadd ${USER} && useradd -m -g ${USER} ${USER}
RUN apt-get update && \
    apt-get install -y apt-transport-https ca-certificates bash curl libpq-dev gnupg && \
    curl -sLf --retry 3 --tlsv1.2 --proto "=https" 'https://packages.doppler.com/public/cli/gpg.DE2A7741A397C129.key' | gpg --dearmor -o /usr/share/keyrings/doppler-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/doppler-archive-keyring.gpg] https://packages.doppler.com/public/cli/deb/debian any-version main" | tee /etc/apt/sources.list.d/doppler-cli.list && \
    apt-get update && \
    apt-get -y install doppler

# Let's run the steps to build this image
WORKDIR /app

COPY . .
COPY scripts/entrypoint.sh /app/entrypoint.sh

# Let's ensure that we have the needed permissions to execute the services within the container
RUN chown -R ${USER}:${USER} /app && \
    pip install --upgrade pip && \
    pip install -r /app/production.txt && \
    chmod +x /app/entrypoint.sh && \
    mkdir /app/data && \
    chown -R ${USER}:${USER} /app/data

# Let's switch our users to de-root the container
USER ${USER}

# Set the DOPPLER_TOKEN from the arg.
ENV DOPPLER_PROJECT=${DOPPLER_PROJECT}
ENV DOPPLER_CONFIG=${DOPPLER_CONFIG}
ENV DOPPLER_TOKEN=${DOPPLER_TOKEN}
EXPOSE 8000

# Run the app
ENTRYPOINT [ "/app/entrypoint.sh" ]
CMD [ "python", "/app/main.py" ]
