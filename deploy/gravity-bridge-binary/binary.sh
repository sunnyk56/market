echo "-----------Installing_dependencies---------------"
yum -y update
yum -y install curl gcc gcc-c++ kernel-devel make ca-certificates tar git jq python3
dnf -y copr enable ngompa/musl-libc
dnf -y install musl-devel
dnf -y install musl-gcc
yum -y install nodejs
dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
dnf -y update
subscription-manager repos --enable codeready-builder-for-rhel-8-x86_64-rpms
dnf -y install moreutils


echo "--------------install_golang---------------------------"
curl https://dl.google.com/go/go1.16.4.linux-amd64.tar.gz --output go.tar.gz
tar -C /usr/local -xzf go.tar.gz
PATH="/usr/local/go/bin:$PATH"
GOPATH=/go
PATH=$PATH:$GOPATH/bin

echo "----------------cloning_repository-------------------"
GRAVITY_DIR=/go/src/github.com/onomyprotocol/gravity-bridge
git clone https://github.com/onomyprotocol/cosmos-gravity-bridge.git $GRAVITY_DIR

echo "----------------------building_gravity_artifact---------------"
cd $GRAVITY_DIR/module
make install
cp ~/go/bin/gravity /usr/bin/gravity


echo "---------------installing_cargo---------------------"
cd ~
curl https://sh.rustup.rs -sSf | bash -s -- -y
PATH="/root/.cargo/bin:${PATH}"
echo "--checking_if_cargo_correctly_installed--"
cargo version

echo "----------------building_orchestrator_artifact-------------"
cd $GRAVITY_DIR/orchestrator
rustup target add x86_64-unknown-linux-musl
cargo build --target=x86_64-unknown-linux-musl --release  --all
cp $GRAVITY_DIR/orchestrator/target/x86_64-unknown-linux-musl/release/gbt /usr/bin/gbt

echo "---------------Installing_solidity-------------------"
cd ~
yum -y install nodejs
cd $GRAVITY_DIR/solidity
npm ci
chmod -R +x scripts
npm run typechain

echo "-------------------making_geth-----------------------"
cd ~
yum -y -yq update
yum -y -y install gmp-devel
git clone https://github.com/ethereum/go-ethereum
cd go-ethereum
make geth
cp build/bin/geth /usr/bin/geth

echo "------------removing_installation_files------------------"
rm -rf go-ethereum go.tar.gz $GRAVITY_DIR