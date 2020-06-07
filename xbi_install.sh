#!/bin/bash

CONFIG_FILE='xbi.conf'
CONFIGFOLDER='/root/.XBI'
COIN_DAEMON='xbid'
COIN_CLI='xbi-cli'
COIN_PATH='/usr/local/bin/'
COIN_REPO="https://github.com/sub307/xbi-4.3.2.1/releases/download/4.3.4/"
BOOTSTRAP="https://github.com/sub307/XBI-bootstrap/releases/download/1090971/1090971.rar"
COIN_ZIPFILE="xbi4.3.4-ubuntu-server.rar"
COIN_TGZ="${COIN_REPO}${COIN_ZIPFILE}"
COIN_ZIP=$(echo $COIN_TGZ | awk -F'/' '{print $NF}')
COIN_NAME='XBI'
COIN_PORT=7339
OLD_PORT=7332
RPC_PORT=6259

NODEIP=$(curl -s4 icanhazip.com)

BLUE="\033[0;34m"
YELLOW="\033[0;33m"
CYAN="\033[0;36m" 
PURPLE="\033[0;35m"
RED='\033[0;31m'
GREEN="\033[0;32m"
NC='\033[0m'
MAG='\e[1;35m'

function purgeOldInstallation() {
    echo -e "${GREEN}Preparing the VPS to setup to install $COIN_NAME masternode${NC}"
    echo -e "${GREEN}* Searching and removing old $COIN_NAME files and configurations${NC}"
    #kill wallet daemon
    systemctl stop $COIN_NAME.service > /dev/null 2>&1
    killall $COIN_DAEMON > /dev/null 2>&1
    killall $COIN_DAEMON > /dev/null 2>&1
    
	# Save Key 
	OLDKEY=$(awk -F'=' '/masternodeprivkey/ {print $2}' $CONFIGFOLDER/$CONFIG_FILE 2> /dev/null)
	if [ "$?" -eq "0" ]; then
    		echo -e "    ${YELLOW}> Saving Old Installation Genkey${NC}"
		echo -e $OLDKEY
	fi
    #remove old ufw port allow
    ufw delete allow $OLD_PORT/tcp > /dev/null 2>&1
    sleep 0.5s
    #remove old files
    rm -- "$0" > /dev/null 2>&1
    rm -rf $CONFIGFOLDER > /dev/null 2>&1
    rm -rf /usr/local/bin/$COIN_CLI /usr/local/bin/$COIN_DAEMON> /dev/null 2>&1
    rm -rf /usr/bin/$COIN_CLI /usr/bin/$COIN_DAEMON > /dev/null 2>&1
    echo -e "    ${YELLOW}> Done${NC}";
}


function download_node() {
  echo -e "${GREEN}* Downloading and Installing VPS $COIN_NAME Daemon${NC}"
  cd ~ > /dev/null 2>&1
  echo -e "    ${YELLOW}> Downloading...${NC}"
  wget -q $COIN_TGZ 
  echo -e "    ${YELLOW}> Extracting...${NC}"
  unrar x $COIN_ZIP
  cd xbi4.3.4-ubuntu-server
  strip $COIN_DAEMON
  strip $COIN_CLI
  chmod +x $COIN_DAEMON $COIN_CLI
  mv $COIN_DAEMON $COIN_CLI $COIN_PATH
  cd ~ > /dev/null 2>&1
  echo -e "    ${YELLOW}> Removing zipfile...${NC}"
  rm -rf xbi4.3.4-ubuntu-server
  rm $COIN_ZIP > /dev/null 2>&1
  clear
  echo -e "    ${YELLOW}> Done${NC}"
}

function add_bootstrap(){
 echo -e "${GREEN}* Downloading bootstrap"
 cd $CONFIGFOLDER > /dev/null 2>&1
 echo -e "    ${YELLOW}> Downloading...${NC}"
 wget -q $BOOTSTRAP -O 1090971.rar
 echo -e "    ${YELLOW}> Extracting...${NC}"
 rm -rf chainstate > /dev/null 2>&1
 rm -rf blocks > /dev/null 2>&1
 rm peers.dat > /dev/null 2>&1
 unrar x 1090971.rar >/dev/null 2>&1
 echo -e "    ${YELLOW}> Removing zipfile...${NC}"
 rm 1090971.rar > /dev/null 2>&1
 cd ~ > /dev/null 2>&1
 echo -e "    ${YELLOW}> Done${NC}"
}

function configure_systemd() {
  cat << EOF > /etc/systemd/system/$COIN_NAME.service
[Unit]
Description=$COIN_NAME service
After=network.target

[Service]
User=root
Group=root

Type=forking
#PIDFile=$CONFIGFOLDER/$COIN_NAME.pid

ExecStart=$COIN_PATH$COIN_DAEMON -daemon -conf=$CONFIGFOLDER/$CONFIG_FILE -datadir=$CONFIGFOLDER
ExecStop=-$COIN_PATH$COIN_CLI -conf=$CONFIGFOLDER/$CONFIG_FILE -datadir=$CONFIGFOLDER stop

Restart=always
PrivateTmp=true
TimeoutStopSec=60s
TimeoutStartSec=10s
StartLimitInterval=120s
StartLimitBurst=5

[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload
  sleep 3
  systemctl enable $COIN_NAME.service > /dev/null 2>&1
  systemctl start $COIN_NAME.service

  if [[ -z "$(ps axo cmd:100 | egrep $COIN_DAEMON)" ]]; then
    echo -e "${RED}$COIN_NAME is not running${NC}, please investigate. You should start by running the following commands as root:"
    echo -e "${GREEN}systemctl start $COIN_NAME.service"
    echo -e "systemctl status $COIN_NAME.service"
    echo -e "less /var/log/syslog${NC}"
    exit 1
  fi
}


function create_config() {
mkdir $CONFIGFOLDER > /dev/null 2>&1
echo
echo -e "${GREEN}* Creating masternode configuration file...${NC}"

  RPCUSER=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w10 | head -n1)
  RPCPASSWORD=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w22 | head -n1)
  cat << EOF > $CONFIGFOLDER/$CONFIG_FILE
rpcuser=$RPCUSER
rpcpassword=$RPCPASSWORD
rpcport=$RPC_PORT
rpcallowip=127.0.0.1
listen=1
server=1
daemon=1
port=$COIN_PORT

EOF
}

function create_key() {
 GENERATE_NEW_KEY="false"
  
 if [ -z "${OLD_KEY}" ]; then
  GENERATE_NEW_KEY="true"
 fi
 if [ "${OLD_KEY}" == " " ] || [ "${OLD_KEY}" == "  " ] || [ "${OLD_KEY}" == "   " ]; then
  GENERATE_NEW_KEY="true"
 fi  
  
 if [ ${GENERATE_NEW_KEY} == "true" ]; then
  echo -e "${YELLOW}Enter your ${RED}$COIN_NAME Masternode GEN Key${NC}."
  read -e COINKEY
  if [[ -z "$COINKEY" ]]; then
   $COIN_PATH$COIN_DAEMON
   sleep 15
   unset COINKEY
   count="1"
   while true
    do
     COINKEY="$(${COIN_PATH}${COIN_CLI} masternode genkey 2> /dev/null)"
     if [ ${#COINKEY} -lt "15" ]; then
      echo -e "    ${YELLOW}> Waiting for daemon to start...${NC}"; sleep 0.5s
      sleep 5s
      ((count++))
      if [ "${count}" -ge "10" ]; then
       echo
       echo -e "${RED}Error: A problem occured while starting daemon. Restart script to try again please.${NC}"
       echo
       exit 1
      fi
     else
      echo -e "    ${YELLOW}> Daemon is running...${NC}"; sleep 0.5s
      echo -e "    ${GREEN}> Generated a new Masternode Private Key.${NC}"; sleep 0.5s
      break
     fi
    done
   $COIN_PATH$COIN_CLI stop
  fi
 else
  COINKEY="${OLD_KEY}"
 fi
   
 clear
}

function update_config() {
  sed -i 's/daemon=1/daemon=0/' $CONFIGFOLDER/$CONFIG_FILE
  cat << EOF >> $CONFIGFOLDER/$CONFIG_FILE
logintimestamps=1
maxconnections=128
#bind=$NODEIP
masternode=1
externalip=$NODEIP:$COIN_PORT
masternodeprivkey=$COINKEY

EOF
}


function enable_firewall() {
  echo -e "${GREEN}* Installing and setting up firewall to allow ingress on port $COIN_PORT${NC}"
  ufw allow $COIN_PORT/tcp comment "$COIN_NAME MN port" >/dev/null
  ufw allow ssh comment "SSH" > /dev/null 2>&1
  ufw limit ssh/tcp > /dev/null 2>&1
  ufw default allow outgoing > /dev/null 2>&1
  echo "y" | ufw enable > /dev/null 2>&1
}


function get_ip() {
  declare -a NODE_IPS
  for ips in $(netstat -i | awk '!/Kernel|Iface|lo/ {print $1," "}')
  do
    NODE_IPS+=($(curl --interface $ips --connect-timeout 2 -s4 icanhazip.com))
  done

  if [ ${#NODE_IPS[@]} -gt 1 ]
    then
      echo -e "${YELLOW}More than one IP. Please type 0 to use the first IP, 1 for the second and so on...${NC}"
      INDEX=0
      for ip in "${NODE_IPS[@]}"
      do
        echo ${INDEX} $ip
        let INDEX=${INDEX}+1
      done
      read -e choose_ip
      NODEIP=${NODE_IPS[$choose_ip]}
  else
    NODEIP=${NODE_IPS[0]}
  fi
}


function checks() {
if [[ $(lsb_release -d) != *16.04* ]]; then
  echo -e "${RED}You are not running Ubuntu 16.04. Installation is cancelled.${NC}"
  exit 1
fi

if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}$0 must be run as root.${NC}"
   exit 1
fi
}

function prepare_system() {

echo -e "${GREEN}* Making sure system is up to date...${NC}"
apt-get update > /dev/null 2>&1
apt-get -y upgrade > /dev/null 2>&1



export DEBIAN_FRONTEND=noninteractive
aptget_params='--quiet -y'

echo -e "    ${GREEN}> Adding bitcoin PPA repository"
apt-add-repository -y ppa:bitcoin/bitcoin > /dev/null 2>&1
apt-get ${aptget_params} install software-properties-common > /dev/null 2>&1

dpkg --clear-avail > /dev/null 2>&1
apt-get ${aptget_params} update > /dev/null 2>&1
apt-get --quiet -f install > /dev/null 2>&1
dpkg --configure -a > /dev/null 2>&1

# intentional duplicate to avoid some errors
apt-get ${aptget_params} update > /dev/null 2>&1
apt-get ${aptget_params} upgrade > /dev/null 2>&1

echo -e "    ${GREEN}> Installing required packages, it may take some time to finish.${NC}"
package_list="build-essential libtool curl autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils python3 ufw libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-program-options-dev libboost-test-dev libboost-thread-dev libboost-dev libevent-1.4-2 libdb4.8-dev libdb4.8++-dev autoconf libboost-all-dev libqt5gui5 libqt5core5a libqt5dbus5 qttools5-dev qttools5-dev-tools libprotobuf-dev protobuf-compiler libqrencode-dev libminiupnpc-dev git multitail vim unzip unrar htop ntpdate"
apt-get ${aptget_params} install ${package_list} > /dev/null 2>&1 || apt-get ${aptget_params} install ${package_list} > /dev/null 2>&1

apt-get ${aptget_params} install ${package_list} > /dev/null 2>&1 || apt-get ${aptget_params} install ${package_list} > /dev/null 2>&1

apt-get ${aptget_params} update > /dev/null 2>&1
apt-get ${aptget_params} upgrade > /dev/null 2>&1
if [ "$?" -gt "0" ];
  then
    echo -e "${RED}Not all required packages were installed properly. Try to install them manually by running the following commands:${NC}\n"
    echo "apt-get update"
    echo "apt -y install software-properties-common"
    echo "apt-add-repository -y ppa:bitcoin/bitcoin"
    echo "apt-get update"
    echo "apt install -y make build-essential libtool software-properties-common autoconf libssl-dev libboost-dev libboost-chrono-dev libboost-filesystem-dev \
libboost-program-options-dev libboost-system-dev libboost-test-dev libboost-thread-dev sudo automake git curl libdb4.8-dev \
bsdmainutils libdb4.8++-dev libminiupnpc-dev libgmp3-dev ufw pkg-config libevent-dev libdb5.3++ unzip libzmq5"
 exit 1
fi
echo -e "    ${GREEN}> synchronize time${NC}"; sleep 0.5s
ntpdate -s time.nist.gov

clear
}

function create_swap() {
 echo -e "${GREEN}* Checking if swap space is needed."
 PHYMEM=$(free -g|awk '/^Mem:/{print $2}')
 SWAP=$(swapon -s)
 if [[ "$PHYMEM" -lt "2"  &&  -z "$SWAP" ]]
  then
    echo -e "    ${YELLOW}> Server is running with less than 2G of RAM without SWAP, creating 2G swap file.${NC}"
    SWAPFILE=$(mktemp)
    dd if=/dev/zero of=$SWAPFILE bs=1024 count=2M
    chmod 600 $SWAPFILE
    mkswap $SWAPFILE
    swapon -a $SWAPFILE
 else
  echo -e "    ${GREEN}> The server running with at least 2G of RAM, or a SWAP file is already in place.${NC}"
 fi
 clear
}

function important_information() {
 echo
 echo -e "${BLUE}================================================================================================================================${NC}"
 echo -e "${BLUE}Windows Wallet Guide. https://github.com/sub307/Bitcoin_Incognito/blob/master/README.md${NC}"
 echo -e "${BLUE}================================================================================================================================${NC}"
 echo -e "${GREEN}$COIN_NAME Masternode is up and running listening on port${NC}${PURPLE}$COIN_PORT${NC}."
 echo -e "${GREEN}Configuration file is:${NC}${RED}$CONFIGFOLDER/$CONFIG_FILE${NC}"
 echo -e "${GREEN}Start:${NC}${RED}systemctl start $COIN_NAME.service${NC}"
 echo -e "${GREEN}Stop:${NC}${RED}systemctl stop $COIN_NAME.service${NC}"
 echo -e "${GREEN}VPS_IP:${NC}${GREEN}$NODEIP:$COIN_PORT${NC}"
 echo -e "${GREEN}MASTERNODE GENKEY is:${NC}${PURPLE}$COINKEY${NC}"
 echo -e "${BLUE}================================================================================================================================${NC}"
 echo -e "${RED}Ensure Node is fully SYNCED with BLOCKCHAIN before starting your Node :).${NC}"
 echo -e "${BLUE}================================================================================================================================${NC}"
 echo -e "${GREEN}Usage Commands.${NC}"
 echo -e "${GREEN}xbi-cli masternode status${NC}"
 echo -e "${GREEN}xbi-cli getinfo.${NC}"
 echo -e "${BLUE}================================================================================================================================${NC}"
}

function setup_node() {
  get_ip
  create_config
  create_key
  update_config
  enable_firewall
  add_bootstrap
  important_information
  configure_systemd
}


##### Main #####
clear

purgeOldInstallation
checks
prepare_system
create_swap
download_node
setup_node
