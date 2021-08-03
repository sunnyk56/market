FROM leeway321/gravity-bridge-binary:0.0.1 as builder

EXPOSE 61278
ARG GRAVITY_HOST=${GRAVITY_HOST}
ARG ETH_HOST=${ETH_HOST}
ARG GIT_HUB_BRANCH=${GIT_HUB_BRANCH}
ARG GIT_HUB_REPO=${GIT_HUB_REPO}

# //TODO this clone may be change in future
RUN git clone -b $GIT_HUB_BRANCH $GIT_HUB_REPO
RUN cp -r /root/market/deploy/peer-cosmos-orchestrator-node/scripts scripts
RUN cp -r /root/market/master/assets assets
RUN cp -r /root/market/peerInfo/testchain testchain

RUN cp  /root/market/peerInfo/validator-phrases /validator-phrases
RUN cp  /root/market/peerInfo/orchestrator-phrases /orchestrator-phrases
RUN cp  /root/market/peerInfo/validator-eth-keys /validator-eth-keys

RUN chmod -R +x /root/scripts
RUN chmod -R +x /root/assets
RUN chmod -R +x /root/testchain

RUN git clone https://github.com/onomyprotocol/cosmos-gravity-bridge.git /gravity
WORKDIR /gravity/solidity
RUN HUSKY_SKIP_INSTALL=1 npm install
RUN npm run typechain
WORKDIR /root

CMD ["sh", "scripts/orchestrator-run.sh $GRAVITY_HOST  $ETH_HOST"]