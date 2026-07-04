FROM swift:6.0-jammy AS builder

WORKDIR /app

COPY Package.swift ./

RUN swift package resolve

COPY Sources ./Sources

RUN swift build \
    -c release \
    --static-swift-stdlib

FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y \
        ca-certificates \
        libcurl4 \
        libxml2 \
        libz3-dev && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder \
    /app/.build/release/SwiftDBServer \
    /app/SwiftDBServer

ENV PORT=8080

EXPOSE 8080

CMD ["/app/SwiftDBServer"]