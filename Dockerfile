FROM haskell:9.10.3-slim-bookworm AS build


RUN apt-get update \
 && apt-get install -y --no-install-recommends libpq-dev pkg-config zlib1g-dev \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app


COPY stack.yaml stack.yaml.lock package.yaml ./
RUN stack build --system-ghc --only-dependencies --jobs 1

COPY src ./src
RUN stack build --system-ghc --jobs 1 --copy-bins --local-bin-path /app/bin

FROM debian:bookworm-slim


RUN apt-get update \
 && apt-get install -y --no-install-recommends libpq5 libgmp10 zlib1g ca-certificates \
 && rm -rf /var/lib/apt/lists/*

COPY --from=build /app/bin/biblioteca-api /usr/local/bin/biblioteca-api

ENV PORT=10000
EXPOSE 10000

CMD ["biblioteca-api"]
