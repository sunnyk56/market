FROM ubuntu:latest

RUN apt-get update -y -q && apt-get upgrade -yq && apt-get install --fix-missing -yq
# common (DEBIAN_FRONTEND is a fix for tzdata)
RUN DEBIAN_FRONTEND="noninteractive" apt-get install --no-install-recommends -yq software-properties-common \
    curl \   
    build-essential \ 
    ca-certificates \
    tar \
    git




ARG GRAVITY_DIR=/go/src/github.com/onomyprotocol/gravity-bridge
RUN git clone https://github.com/onomyprotocol/cosmos-gravity-bridge.git $GRAVITY_DIR


# ------------------ gravity module ------------------
# install golang
RUN curl https://dl.google.com/go/go1.16.4.linux-amd64.tar.gz --output go.tar.gz
RUN tar -C /usr/local -xzf go.tar.gz
ENV PATH="/usr/local/go/bin:$PATH"
ENV GOPATH=/go
ENV PATH=$PATH:$GOPATH/bin

# build gravity artifact
WORKDIR $GRAVITY_DIR/module
# Build gravity artifact
RUN make install
# copy binary to bin
RUN cp /go/bin/gravity /usr/bin/gravity

# ------------------ orchestrator ------------------
# install rust
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"
# check cargo works
RUN cargo version





# build orchestrator artifact
WORKDIR $GRAVITY_DIR/orchestrator
RUN rustup target add x86_64-unknown-linux-musl
RUN apt-get install --no-install-recommends -yq musl-tools
RUN cargo build --target=x86_64-unknown-linux-musl --release  --all
RUN cp $GRAVITY_DIR/orchestrator/target/x86_64-unknown-linux-musl/release/gbt /usr/bin/gbt

# ------------------ Solidity ------------------
RUN apt-get install --no-install-recommends -yq python3 \
    make \
    g++

RUN curl -sL https://deb.nodesource.com/setup_15.x  | bash -
RUN apt-get -y install nodejs
# compile contract
WORKDIR $GRAVITY_DIR/solidity
RUN npm ci
RUN chmod -R +x scripts
RUN npm run typechain

# ------------------ ethereum go (geth) ------------------
RUN add-apt-repository -y ppa:ethereum/ethereum
RUN apt-get install --no-install-recommends -yq ethereum

# ------------------ soft to run the scripts ------------------
RUN apt-get install --no-install-recommends -yq jq \
    moreutils

WORKDIR /root
CMD ["bash"]