FROM leeway321/gravity-bridge-binary:0.0.1 as builder

EXPOSE 61278
ARG PUBLIC_IP=${PUBLIC_IP}
ARG GIT_HUB_USER=${GIT_HUB_USER}
ARG GIT_HUB_PASS=${GIT_HUB_PASS}
ARG GIT_HUB_EMAIL=${GIT_HUB_EMAIL}
ARG GIT_HUB_BRANCH=${GIT_HUB_BRANCH}
ARG GIT_HUB_REPO=${GIT_HUB_REPO}

# purpose of clone the repo is to get updated Ethgenesis.json file
# //TODO this clone may be change in future
RUN git clone -b $GIT_HUB_BRANCH $GIT_HUB_REPO
RUN cp -r /root/market/deploy/master-cosmos-orchestrator-node/scripts scripts
#RUN cp -r /root/market/master/assets assets
RUN cp -r /root/market/master/testchain testchain
RUN cp  /root/market/master/validator-phrases /validator-phrases
RUN cp  /root/market/master/orchestrator-phrases /orchestrator-phrases
RUN cp  /root/market/master/validator-eth-keys /validator-eth-keys

RUN chmod -R +x /root/scripts
RUN chmod -R +x /root/testchain

RUN git clone https://github.com/onomyprotocol/cosmos-gravity-bridge.git /gravity
WORKDIR /gravity/solidity
RUN HUSKY_SKIP_INSTALL=1 npm install
RUN npm run typechain
WORKDIR /root


CMD ["sh", "scripts/orchestrator-run.sh"]