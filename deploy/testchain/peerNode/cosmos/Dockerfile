FROM leeway321/gravity-bridge-binary:0.0.1 as builder

EXPOSE 26656 26657 1317 9090
ARG PUBLIC_IP=${PUBLIC_IP}
ARG GIT_HUB_USER=${GIT_HUB_USER}
ARG GIT_HUB_PASS=${GIT_HUB_PASS}
ARG GIT_HUB_EMAIL=${GIT_HUB_EMAIL}
ARG GIT_HUB_BRANCH=${GIT_HUB_BRANCH}
ARG GIT_HUB_REPO=${GIT_HUB_REPO}


# purpose of clone the repo is to commit and push genesis file and seed in this repo to use by other node
# //TODO this clone may be change in future
RUN git clone -b $GIT_HUB_BRANCH $GIT_HUB_REPO
RUN cp -r /root/market/deploy/testchain/peerNode/scripts scripts

RUN chmod -R +x /root/scripts

RUN git clone https://github.com/onomyprotocol/cosmos-gravity-bridge.git /gravity
WORKDIR /gravity/solidity
RUN HUSKY_SKIP_INSTALL=1 npm install
RUN npm run typechain
WORKDIR /root

CMD sh scripts/init.sh
