FROM swift:6.2-noble AS build

WORKDIR /build
COPY Package.swift Package.resolved* ./
RUN swift package resolve
COPY Sources ./Sources
COPY Tests ./Tests
RUN swift build -c release --static-swift-stdlib

FROM ubuntu:noble
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ca-certificates \
        libatomic1 \
        libcurl4 \
        libxml2 \
        tzdata \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=build /build/.build/release/App ./App
EXPOSE 8080
ENTRYPOINT ["./App"]
CMD ["serve", "--hostname", "0.0.0.0", "--port", "8080", "--auto-migrate"]
