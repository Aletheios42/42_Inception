FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y wget ca-certificates && \
    wget https://github.com/google/cadvisor/releases/download/v0.37.0/cadvisor && \
    chmod +x cadvisor && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

CMD ["./cadvisor"]
