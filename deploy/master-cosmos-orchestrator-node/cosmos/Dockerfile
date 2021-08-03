FROM leeway321/gravity-bridge-binary:0.0.1 as builder

EXPOSE 26656 26657 1317 9090
ARG PUBLIC_IP=${PUBLIC_IP}
ARG GIT_HUB_USER=${GIT_HUB_USER}
ARG GIT_HUB_PASS=${GIT_HUB_PASS}
ARG GIT_HUB_EMAIL=${GIT_HUB_EMAIL}
ARG GIT_HUB_BRANCH=${GIT_HUB_BRANCH}
ARG GIT_HUB_REPO=${GIT_HUB_REPO}

#ARG GRAVITY_GENESIS_COINS="100000000000stake,100000000000samoleans"
ARG GRAVITY_GENESIS_COINS="100000000000stake,100000000000footoken"

# purpose of clone the repo is to commit and push genesis file and seed in this repo to use by other node
# //TODO this clone may be change in future
RUN git clone -b $GIT_HUB_BRANCH $GIT_HUB_REPO
RUN cp -r /root/market/deploy/master-cosmos-orchestrator-node/scripts scripts
RUN cp -r /root/market/deploy/master-cosmos-orchestrator-node/assets assets

RUN chmod -R +x /root/scripts
RUN chmod -R +x /root/assets

RUN git clone https://github.com/onomyprotocol/cosmos-gravity-bridge.git /gravity
WORKDIR /gravity/solidity
RUN HUSKY_SKIP_INSTALL=1 npm install
RUN npm run typechain
WORKDIR /root

RUN sh scripts/init.sh

##----------------------------- commit master genesis,json file, assets and seed-----
RUN gravity --home /root/testchain/gravity tendermint show-node-id > seed
RUN sed -i 's#'$(gravity --home /root/testchain/gravity tendermint show-node-id)'#'$(gravity --home /root/testchain/gravity tendermint show-node-id)'@'$PUBLIC_IP':26656#g' seed

WORKDIR /root/market
RUN sh deploy/master-cosmos-orchestrator-node/scripts/store-master-info.sh $GIT_HUB_USER $GIT_HUB_PASS $GIT_HUB_EMAIL $GIT_HUB_BRANCH

#WORKDIR /root

#CMD ["sh", "/root/scripts/cosmos-run.sh"]
