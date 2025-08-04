FROM node:22 AS build-env

COPY . /app/
WORKDIR /app/
RUN npm --unsafe-perm install

# Per https://ftp.gnu.org/, the SHA256 hash is correct as verified by:
#
# curl http://ftp.gnu.org/gnu/glibc/glibc-2.36.tar.gz --output glibc-2.36.tar.gz && \
# curl http://ftp.gnu.org/gnu/glibc/glibc-2.36.tar.gz.sig --output glibc-2.36.tar.gz.sig && \
# curl https://ftp.gnu.org/gnu/gnu-keyring.gpg --output gnu-keyring.gpg && \
# gpg --verify --keyring ./gnu-keyring.gpg glibc-2.36.tar.gz.sig && \
# sha256sum glibc-2.36.tar.gz | awk '{print $1}'

RUN mkdir /third_party
RUN TEMP_FILE=$(mktemp) && \
    curl http://ftp.gnu.org/gnu/glibc/glibc-2.36.tar.gz --output "$TEMP_FILE" && \
    echo "02efa6ffbbaf3e10e88f16818a862608d04b0ef838c66f6025ae120530792c9c ${TEMP_FILE}" \
        | sha256sum --check --status && \
    tar -xz -C /third_party -f "${TEMP_FILE}" && \
    rm -f "${TEMP_FILE}"

FROM gcr.io/distroless/nodejs22-debian12:latest
COPY --from=build-env /app/ /app/
COPY --from=build-env /third_party/ /third_party/

HEALTHCHECK CMD ["/nodejs/bin/node", "/app/health_checker_bin.js"]
WORKDIR /app/
CMD ["server_bin.js"]
