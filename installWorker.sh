#!bin/bash
#####################################################################################
## Script de configuration d'un rig
## V0.1
## Date : 25/1/2021
## Decription : permet la configuration d'un systéme debian pour un rig de minage
#####################################################################################
#Recupertation du nom de l'utilisateur
$user = $USER

#mise à jours du systeme
apt update && apt upgrade

#Outil de surveillance materiel et processus
apt install lshw htop nmap

# installation outil de decompression
apt install unzip p7zip-full binutils bzip2 zip

#installation des outil de compilation
apt install git curl automake autogen yasm autoconf dh-autoreconf build-essential pkg-config screen libtool libcurl4-openssl-dev libtool libncurses5-dev libudev-dev gdebi gedit execstack dh-modaliases lib32gcc1 dkms

#installation d'outil supplementaire
apt install software-properties-common openssh-server aptitude samba

# Création des repertoires necessaire
## Creation du repertoire pour les fichiers à télécharger
mkdir /home/$user/Download
## Creation d’un répertoire backup
mkdir /home/$user/Backup
## Creation d’un répertoire pour Git
mkdir /home/$user/Git
## Creation d’un répertoire pour samba
mkdir /home/$user/Public
## Creation d’un répertoire pour les scripts
mkdir /home/$user/Script

#paramétrage des source nécessaire
##creation d’un fichier source pour Postgres :
sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc |  apt-key add -
##Source pour ethereum
add-apt-repository ppa:ethereum/ethereum

# Update the package lists
apt-get update

# Telechrgement des fichier necessaire à l'Installation
cd /home/$user/Download/
wget https://www2.ati.com/drivers/linux/beta/ubuntu/amdgpu-pro-17.40-483984.tar.xz
#Preparation des scripts de Configuration
chmod +x /home/$user/Script/smb.conf.sh

#Configuration de Samba


#Decompression de l'archive
cd public
tar -Jxvf amdgpu-pro-18.10*

# Installation des drivers
cd /amdgpu-pro-18.*
chmod +x amdgpu-install
./amdgpu-install -y --opencl=legacy

#Installation de AMD APP sdk 3
cd /home/work/public/



#telechargement de l'archive et decompression
wget http://cs.wisc.edu/~riccardo/assets/AMD-APP-SDKInstaller-v3.0.130.136-GA-linux64.tar.bz2
tar -xjvf *-linux64.tar.bz2

#on execute le script d'installation
chmod +x AMD-APP-SDK-v3.0.130.136-GA-linux64.sh
./AMD-APP-SDK-v3.0.130.136-GA-linux64.sh


usermod -a -G video $LOGNAME

#Installation Rocm
apt install -y rocm-amdgpu-pro
echo 'export LLVM_BIN=/opt/amdgpu-pro/bin' | sudo tee /etc/profile.d/amdgpu-pro.sh
export LLVM_BIN=/opt/amdgpu-pro/bin

#On telecharge Claymore 11.8
cd /home/work/public
wget https://github.com/nanopool/Claymore-Dual-Miner/releases/download/v11.8/Claymore.s.Dual.Ethereum.Decred_Siacoin_Lbry_Pascal_Blake2s_Keccak.AMD.NVIDIA.GPU.Miner.v11.8.-.LINUX.tar.gz
tar -xzvf *.LINUX.tar.gz

cd Claymore\'s\ Dual\ Ethereum+Decred_Siacoin_Lbry_Pascal_Blake2s_Keccak\ AMD+NVIDIA\ GPU\ Miner\ v11.8\ -\ LINUX/

#on prepare l'excution au propre avec un service en dehors du repertoir Publique
mkdir /home/work/public/claymore
mv Claymore\'s\ Dual\ Ethereum+Decred_Siacoin_Lbry_Pascal_Blake2s_Keccak\ AMD+NVIDIA\ GPU\ Miner\ v11.8\ -\ LINUX/* claymore/

#on copie le logiciel dans OPT
cp -r claymore /opt/

#On crée un script pour lanser et arreter ethminer
mkdir /root/Script
mkdir /root/Script/Crypto
cd /root/Script/Crypto

nano mine-eth.sh
	echo -e '#/bin/sh '>> /root/Script/Crypto/mine-eth.sh
	echo -e'export GPU_FORCE_64BIT_PTR=0 '>> /root/Script/Crypto/mine-eth.sh
	echo -e'export GPU_MAX_HEAP_SIZE=100 '>> /root/Script/Crypto/mine-eth.sh
	echo -e'export GPU_USE_SYNC_OBJECTS=1 '>> /root/Script/Crypto/mine-eth.sh
	echo -e'export GPU_MAX_ALLOC_PERCENT=100 '>> /root/Script/Crypto/mine-eth.sh
	echo -e 'export GPU_SINGLE_ALLOC_PERCENT=100 '>> /root/Script/Crypto/mine-eth.sh
	#-fanmin = vitesse minimal du ventilateur des cartes graphique
	#-fanmax = vitesse maximal du ventilateur des carte graphique
	#-tt = c'est la temperature ideal souhaiter vers la quelle le systeme doit tendre
	#-cclock = frequence du GPU en Mhz
	#-mclock = frequence du bus memoire en Mhz
	#-powlim = limiteur de tention exprimer en pourcent, 0% fonctionnement normal, +15%
	#-epool = adresse url du pool de minage suivi de sont port d'ecoute
	#-ewal = Wallet de depot
	echo -e './ethdcrminer64  -fanmin 60 -fanmax 100 -tt 55 -cclock 1125 -mclock 2100 -powlim 15 -epool eth-eu1.nanopool.org:9999 -ewal 0x7a1c95c0ad58dbcef485947906cf1f0f0026a7a3/worker/samybolt@protonmail.com -epsw x -mode 1 '>> /root/Script/Crypto/mine-eth.sh

chmod +x mine-eth.sh

# on donne les droit d'execution de etherminer64
cd /opt/claymore/
chown root:root ethdcrminer64
chmod 755 ethdcrminer64
chmod u+s ethdcrminer64
