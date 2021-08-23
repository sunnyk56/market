echo "-----------Installing_dependencies---------------"

 dnf -y update
 dnf -y install curl
 dnf -y install nano
 dnf -y install ca-certificates
 dnf -y install tar
 dnf -y install git
 dnf -y install jq
 dnf -y install gcc-c++
 dnf -y copr enable ngompa/musl-libc
 dnf -y install musl-devel
 dnf -y install musl-gcc

 dnf -y install golang
 dnf -y install gmp-devel
 dnf -y install perl python3
 dnf -y install moreutils
 dnf -y install wget
 dnf -y install screen


echo "--------------installing_rust---------------------------"

curl https://sh.rustup.rs -sSf | bash -s -- -y
export PATH=$HOME/.cargo/bin:$PATH
cargo version

echo "----------------cloning_repository-------------------"

GRAVITY_DIR=$HOME/gravity
git clone https://github.com/onomyprotocol/cosmos-gravity-bridge.git $GRAVITY_DIR

echo "--------------install_golang---------------------------"
curl https://dl.google.com/go/go1.16.4.linux-amd64.tar.gz --output $HOME/go.tar.gz
tar -C $HOME -xzf $HOME/go.tar.gz
export PATH=$PATH:$HOME/go/bin

echo "----------------------building_gravity_artifact---------------"
cd $GRAVITY_DIR/module
make install

echo "----------------building_orchestrator_artifact-------------"
cd $GRAVITY_DIR/orchestrator
rustup target add x86_64-unknown-linux-musl
cargo build --target=x86_64-unknown-linux-musl --release  --all
cp $GRAVITY_DIR/orchestrator/target/x86_64-unknown-linux-musl/release/gbt $HOME/go/bin/gbt


echo "---------------Installing_solidity-------------------"
cd $GRAVITY_DIR/solidity
dnf -y install nodejs
npm ci
chmod -R +x scripts
npm run typechain


echo "-------------------making_geth-----------------------"
cd $HOME
git clone https://github.com/ethereum/go-ethereum
cd go-ethereum/
make geth
cp build/bin/geth $HOME/go/bin/geth

# dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
# sudo subscription-manager repos --enable codeready-builder-for-rhel-8-x86_64-rpms
export PATH=$PATH:$HOME/go/bin
cd $HOME



