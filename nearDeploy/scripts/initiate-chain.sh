
echo "-----------Installing_dependencies---------------"
sudo dnf -y update
sudo dnf -y install curl nano git jq gcc-c++ musl-devel musl-gcc golang gmp-devel perl python3 moreutils wget screen nodejs
npm install -g near-cli
HOME_DIRECTORY=$HOME

echo "----------------cloning_repository-------------------"

NEAR_CORE_DIR=$HOME_DIRECTORY/nearcore
git clone https://github.com/near/nearcore.git $NEAR_CORE_DIR

echo "--------------install_golang---------------------------"
curl https://dl.google.com/go/go1.16.4.linux-amd64.tar.gz --output $HOME_DIRECTORY/go.tar.gz
tar -C $HOME_DIRECTORY -xzf $HOME_DIRECTORY/go.tar.gz

echo "----------------------building_near_artifact---------------"
cd $NEAR_CORE_DIR
make neard
cp target/release/neard $HOME_DIRECTORY/go/bin/neard
export PATH=$PATH:$HOME_DIRECTORY/go/bin


echo "------------------ initiate near chain ------------------"
cd $HOME_DIRECTORY
neard --home ~/.near init --chain-id localnet
sleep 2
neard --home ~/.near run



