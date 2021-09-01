#!/bin/bash


# Setting up user's home directory and current directory
CURRENT_DIR=$(pwd)
USER_HOME=$(getent passwd $SUDO_USER | cut -d: -f6)
echo $USER_HOME


echo "-----------Installing_dependencies---------------"
dnf -y update
dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
dnf -y copr enable ngompa/musl-libc
sudo subscription-manager repos --enable codeready-builder-for-rhel-8-x86_64-rpms
dnf -y update
dnf -y install curl nano ca-certificates tar git jq gcc-c++ musl-devel musl-gcc golang gmp-devel perl python3 moreutils wget screen nodejs


echo "--------------installing_rust---------------------------"
curl https://sh.rustup.rs -sSf | sudo -u $SUDO_USER bash -s -- -y
export PATH=$USER_HOME/.cargo/bin:$PATH
cargo version


echo "----------------cloning_repository-------------------"
GRAVITY_DIR=$USER_HOME/gravity
sudo -u $SUDO_USER git clone https://github.com/onomyprotocol/cosmos-gravity-bridge.git $GRAVITY_DIR


echo "--------------install_golang---------------------------"
sudo -u $SUDO_USER curl https://dl.google.com/go/go1.16.4.linux-amd64.tar.gz --output $USER_HOME/go.tar.gz
sudo -u $SUDO_USER tar -C $USER_HOME -xzf $USER_HOME/go.tar.gz
export PATH=$PATH:$USER_HOME/go/bin


echo "----------------------building_gravity_artifact---------------"
cd $GRAVITY_DIR/module
make install


echo "----------------building_orchestrator_artifact-------------"
cd $GRAVITY_DIR/orchestrator
sudo -u $SUDO_USER rustup target add x86_64-unknown-linux-musl
sudo -u $SUDO_USER cargo build --target=x86_64-unknown-linux-musl --release  --all
cp -p $GRAVITY_DIR/orchestrator/target/x86_64-unknown-linux-musl/release/gbt $USER_HOME/go/bin/gbt


echo "---------------Installing_solidity-------------------"
cd $GRAVITY_DIR/solidity
sudo -u $SUDO_USER npm ci
chmod -R +x scripts
sudo -u $SUDO_USER npm run typechain


echo "-------------------making_geth-----------------------"
sudo -u $SUDO_USER git clone https://github.com/ethereum/go-ethereum $USER_HOME/go-ethereum
cd $USER_HOME/go-ethereum/
make geth
cp -p build/bin/geth $USER_HOME/go/bin/geth

cd $CURRENT_DIR
