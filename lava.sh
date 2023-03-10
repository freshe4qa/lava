#!/bin/bash

while true
do

# Logo

echo -e '\e[40m\e[91m'
echo -e '  ____                  _                    '
echo -e ' / ___|_ __ _   _ _ __ | |_ ___  _ __        '
echo -e '| |   |  __| | | |  _ \| __/ _ \|  _ \       '
echo -e '| |___| |  | |_| | |_) | || (_) | | | |      '
echo -e ' \____|_|   \__  |  __/ \__\___/|_| |_|      '
echo -e '            |___/|_|                         '
echo -e '    _                 _                      '
echo -e '   / \   ___ __ _  __| | ___ _ __ ___  _   _ '
echo -e '  / _ \ / __/ _  |/ _  |/ _ \  _   _ \| | | |'
echo -e ' / ___ \ (_| (_| | (_| |  __/ | | | | | |_| |'
echo -e '/_/   \_\___\__ _|\__ _|\___|_| |_| |_|\__  |'
echo -e '                                       |___/ '
echo -e '\e[0m'

sleep 2

# Menu

PS3='Select an action: '
options=(
"Install"
"Create Wallet"
"Create Validator"
"Exit")
select opt in "${options[@]}"
do
case $opt in

"Install")
echo "============================================================"
echo "Install start"
echo "============================================================"

# set vars
if [ ! $NODENAME ]; then
	read -p "Enter node name: " NODENAME
	echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export LAVA_CHAIN_ID=lava-testnet-1" >> $HOME/.bash_profile
source $HOME/.bash_profile

# update
sudo apt update && sudo apt upgrade -y

# packages
sudo apt install curl build-essential git wget jq make gcc tmux chrony -y

# install go
if ! [ -x "$(command -v go)" ]; then
  ver="1.18.2"
  cd $HOME
  wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
  rm "go$ver.linux-amd64.tar.gz"
  echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
  source ~/.bash_profile
fi

# download binary
cd $HOME
rm -rf lava
git clone https://github.com/lavanet/lava.git
cd lava
git checkout v0.7.0
make install
lavad version

# config
lavad config chain-id $LAVA_CHAIN_ID
lavad config keyring-backend test

# init
lavad init $NODENAME --chain-id $LAVA_CHAIN_ID

# download genesis and addrbook
curl -s https://raw.githubusercontent.com/K433QLtr6RA9ExEq/GHFkqmTzpdNLDd6T/main/testnet-1/genesis_json/genesis.json > $HOME/.lava/config/genesis.json
curl -s https://snapshots1-testnet.nodejumper.io/lava-testnet/addrbook.json > $HOME/.lava/config/addrbook.json

# set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0ulava\"/" $HOME/.lava/config/app.toml

# set peers and seeds
SEEDS=""
PEERS="37fc77cca6c945d12c6e54166c3b9be2802ad1e6@lava-testnet.nodejumper.io:27656,3f0eb55b386427af17829b8ec98fd367a2fc469f@135.181.183.93:11656,ba78f0ac713d5e7a0274ef593674dae337aabbee@176.103.222.18:26656,5d55031717267b74a2d8110a6962d0fda48d583a@95.216.188.101:26656,276c73534246fb9ec48d5c72ebd62c42e2f96462@157.90.17.150:26656,5e068fccd370b2f2e5ab4240a304323af6385f1f@172.93.110.154:27656,f68c57ca955420779773f9320a6b7710c2b29f73@188.191.36.222:26656,6ba3b6ec03839afffa64c83e18ff80a681f4968d@65.108.194.40:21756,8a20f8f798c5073f0867812e691f54b5cd0dd65d@109.123.242.188:26656,d5f51ff7adf797e7e4be5f303e75686f6d277886@213.239.207.165:29556,f170d864717f535bc7f8f79be90b293915b244ab@5.75.152.225:26656,4e0a2772bb3672e54c2ea655c30abdac62191f14@45.84.138.66:18656,fcbe43af6ef40fca686af83e13a8b03d1a6046e6@135.181.178.53:56656,0d6983bcd192c0b4a0f61e6d849c152704e2f017@91.107.148.5:26656,381c5e431a108fdee2ef35abca5d8ee6421bb898@65.109.104.118:61256,0314d53cc790860fb51f36ac656a19789800ce5c@176.103.222.20:26656,75ed1e87b48d6e1ab341e3568708c9fb81743ffa@65.109.88.251:11036,180929dd6caf59d6f316f1e1bc717f33a565bfc7@135.181.86.6:26656,cfb2b0ee7bd28ef37f8c1019727caa783a122fa3@78.107.234.44:26656,11b8b0c7e4e2a1c0093b42e1290624c55c2f17bc@135.181.163.177:26656,24a2bb2d06343b0f74ed0a6dc1d409ce0d996451@188.40.98.169:27656,d9abc551547563e9a45160adc070b8bb42fc7d62@75.119.134.69:29656,0f9f0fb4b9371a65bdf1c883a2a7dc52d0023019@34.233.69.21:26656,d64aa8f4d864daac54639cd1fdebbf4c464ba4f1@5.75.235.206:26656,57474bd0977b3ed65cf23086b6d1d92bf00d50d0@207.180.236.122:31656,71f6af45c867266f81d81193013fcb4137351355@194.163.155.84:56656,c19965fe8a1ea3391d61d09cf589bca0781d29fd@162.19.217.52:26656,f762b211ee317e8cae9f8ca8cd17a1de1e87f0df@116.202.8.211:20656,c44a02dba51e23ac06b006fb1285988c89051ce7@85.10.198.171:26556,e38146de8800082110878c0521fd3ee5f93b70d6@194.163.177.203:26656,897d44b1cb6633539cf51261f6629a9d5664eb9b@159.69.72.247:11656,40046fe63bdaa9efde27707b0d3de0bf84fedf80@86.111.48.158:26656,5c2a752c9b1952dbed075c56c600c3a79b58c395@185.16.39.172:27066,4dbe5ebf1505f472d852cf7732343ceb899d51db@95.217.57.232:60656,2c2410774b668e4ff208cc37a4b229f27a494cb5@81.196.253.241:47656,8f79bf6093fd728359f529a4a5214c0364749230@65.21.205.248:11656,d53f227f0682ec552ae1932de2547fa717119253@95.216.102.235:42405,13a9209a4d08803a3becac57de8eb02dd51f8f41@65.109.23.114:19956,0a528da95ca8025ef4043b6e73f1e789f4102940@176.103.222.22:26656,035d086cc418352aba9e679e079f17391791ccc6@178.208.252.54:27656,3a445bfdbe2d0c8ee82461633aa3af31bc2b4dc0@3.252.219.158:26656,80922095c0766aabdaf9e93e9c38c45321347ac0@85.239.237.85:26656,58bbc838ba33fd0fc1e3c441022e2c55878627bf@54.185.252.28:26656,10c4405d04b2a221959de97f69c9a6258676f55d@161.97.79.100:26656,0561fed6e88f2167979e379436529861527d859d@65.109.92.148:61256,3f0ff3fab028ff62bd2bb35f95d1503f9b900539@95.217.35.79:26656,149f9f017344ce9cebb637baa7cab57a28f3a8c3@86.111.48.159:26656,e4ebf07ed08ff8ee26a9a903d63ad34d1f59393e@95.217.35.186:56656,22bd49cb251e649816d2cb6f24897dd2b4602dc4@149.102.157.34:26656,e593c7a9ca61f5616119d6beb5bd8ef5dd28d62d@34.246.190.1:26656,4e96723af8feb8a515573a7b9391e7bf7d562480@194.163.162.155:26656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.lava/config/config.toml

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.lava/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.lava/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.lava/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.lava/config/app.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.lava/config/config.toml

# create service
sudo tee /etc/systemd/system/lavad.service > /dev/null << EOF
[Unit]
Description=Lava Network Node
After=network-online.target
[Service]
User=$USER
ExecStart=$(which lavad) start
Restart=on-failure
RestartSec=10
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
EOF

lavad tendermint unsafe-reset-all --home $HOME/.lava --keep-addr-book

SNAP_NAME=$(curl -s https://snapshots1-testnet.nodejumper.io/lava-testnet/ | egrep -o ">lava-testnet-1.*\.tar.lz4" | tr -d ">")
curl https://snapshots1-testnet.nodejumper.io/lava-testnet/${SNAP_NAME} | lz4 -dc - | tar -xf - -C $HOME/.lava

# start service
sudo systemctl daemon-reload
sudo systemctl enable lavad
sudo systemctl start lavad

break
;;

"Create Wallet")
lavad keys add $WALLET
echo "============================================================"
echo "Save address and mnemonic"
echo "============================================================"
LAVA_WALLET_ADDRESS=$(lavad keys show $WALLET -a)
LAVA_VALOPER_ADDRESS=$(lavad keys show $WALLET --bech val -a)
echo 'export LAVA_WALLET_ADDRESS='${LAVA_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export LAVA_VALOPER_ADDRESS='${LAVA_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile

break
;;

"Create Validator")
lavad tx staking create-validator \
  --amount 10000ulava \
  --from wallet \
  --commission-max-change-rate "0.1" \
  --commission-max-rate "0.2" \
  --commission-rate "0.1" \
  --min-self-delegation "1" \
  --pubkey  $(lavad tendermint show-validator) \
  --moniker $NODENAME \
  --chain-id lava-testnet-1 \
  -y
  
break
;;

"Exit")
exit
;;
*) echo "invalid option $REPLY";;
esac
done
done
