#!/bin/bash


# Setting up user's home directory and current directory
CURRENT_DIR=$(pwd)
USER_HOME=$(getent passwd $SUDO_USER | cut -d: -f6)
echo $HOME

echo "-----------Installing_dependencies---------------"
sudo dnf -y update
sudo dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
sudo dnf -y copr enable ngompa/musl-libc
sudo subscription-manager repos --enable codeready-builder-for-rhel-8-x86_64-rpms
sudo dnf -y update
sudo dnf -y install curl nano ca-certificates tar git jq gcc-c++ musl-devel musl-gcc golang gmp-devel perl python3 moreutils wget screen nodejs


echo "--------------installing_rust---------------------------"
curl https://sh.rustup.rs -sSf | bash -s -- -y
export PATH=$HOME/.cargo/bin:$PATH
echo "####################################"
cargo version


echo "----------------cloning_repository-------------------"
GRAVITY_DIR=$HOME/gravity
git clone https://github.com/onomyprotocol/cosmos-gravity-bridge.git $GRAVITY_DIR


echo "--------------install_golang---------------------------"
curl https://dl.google.com/go/go1.16.4.linux-amd64.tar.gz --output $HOME/go.tar.gz
tar -C $HOME -xzf $HOME/go.tar.gz
export PATH=$PATH:$HOME/go/bin
export GOPATH=$HOME/go/
echo "$GOPATH"

echo "----------------------building_gravity_artifact---------------"
cd $GRAVITY_DIR/module
make install


echo "----------------building_orchestrator_artifact-------------"
cd $GRAVITY_DIR/orchestrator
rustup target add x86_64-unknown-linux-musl
cargo build --target=x86_64-unknown-linux-musl --release  --all
cp -p $GRAVITY_DIR/orchestrator/target/x86_64-unknown-linux-musl/release/gbt $HOME/go/bin/gbt


echo "---------------Installing_solidity-------------------"
cd $GRAVITY_DIR/solidity
npm ci
chmod -R +x scripts
npm run typechain


echo "-------------------making_geth-----------------------"
git clone https://github.com/ethereum/go-ethereum $HOME/go-ethereum
cd $HOME/go-ethereum/
make geth
cp -p build/bin/geth $HOME/go/bin/geth

cd $CURRENT_DIR
