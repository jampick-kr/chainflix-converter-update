#!/bin/bash
# 변환서버 설치 방법

## 유저 설정 변경
# 1. 변경 안하면 자동적으로 절전모드로 들어가집니다.
# 2. 해당 옵셕을 미사용시 우분투 설정에서 절전모드 해제
if [[ $EUID != 0 ]]; then
  echo "Please run as root"
  exit
fi

default="Y"
read -r -p"Exchange to multi user target?(Default: ${default}) [Y/N]: " inputSource
if [[ $inputSource == "" ]]; then
  inputSource = ${default}
fi
if [[ $inputSource == "Y" || $inputSource == "y" ]]; then
  systemctl set-default multi-user.target
fi

## 방화벽 활성화
ufw enable
read -r -p"Are you hope to open support port?(Default: ${default}) [Y/N]: " inputSource
## 방화벽 - 지원을 위한 ssh 접속 허용 (optional)
if [[ $inputSource == "" ]]; then
  inputSource = ${default}
fi

if [[ $inputSource == "Y" || $inputSource == "y" ]]; then
  ufw allow from 211.219.51.217 to any port 22 proto tcp
fi

## 방화벽 허용 - 통신
ufw allow 80/tcp
ufw allow 443/tcp

## 패키지 갱신
add-apt-repository -y ppa:graphics-drivers/ppa
apt-get install linux-headers-$(uname -r)
distribution=$(. /etc/os-release;echo $ID$VERSION_ID | sed -e 's/\.//g')
wget https://developer.download.nvidia.com/compute/cuda/repos/$distribution/x86_64/cuda-$distribution.pin
mv cuda-$distribution.pin /etc/apt/preferences.d/cuda-repository-pin-600
apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/$distribution/x86_64/7fa2af80.pub
add-apt-repository "deb http://developer.download.nvidia.com/compute/cuda/repos/$distribution/x86_64 /"
apt-get update
apt-get upgrade
apt-get install -y git python3 python3-pip python3-setuptools python3-wheel \
  ninja-build libtool build-essential libcurl4-gnutls-dev libxml2-dev libssl-dev \
  automake autoconf libass-dev pkg-config texinfo zlib1g-dev cmake mercurial \
  libbz2-dev rtmpdump librtmp-dev opencl-headers ocl-icd-* screen curl \
  cuda-drivers-$(echo $(nvidia-smi --query-gpu=driver_version --format=csv,noheader | head -1 | cut -d. -f1)) apache2 certbot python3-certbot-apache
apt -y install nvidia-cuda-toolkit
pip3 install meson
## nvidia-patch
git clone https://github.com/keylase/nvidia-patch nvidia-patch
bash nvidia-patch/patch.sh
bash nvidia-patch/patch-fbc.sh

sessionId=""
siteName=""
maxConvertCount="5"
maxThumbnailCount="1"
# load convert server information

# info auto load
resultData=$(curl -s 'https://api.chainflix.net/api/converter/converter_install_check')
resultCode=$(python3 -c "import sys, json; print(${resultData}['result_code'])")
if [[ $resultCode == "1" ]]; then
  sessionId=$(python3 -c "import sys, json; print(${resultData}['body']['converter_key'])")
  siteName=$(python3 -c "import sys, json; print(${resultData}['body']['converter_api_url'])")
  siteName="${siteName/https\:\/\//}"
fi


while :
do
  if [[ $sessionId != "" && $maxConvertCount != "" && $maxThumbnailCount != "" ]]; then
    break
  fi
  read -r -p"Please insert convert session id: " sessionId
  #read -r -p"Please insert max convert count: " maxConvertCount
  #read -r -p"Please insert max thumbnail count: " maxThumbnailCount
done
sudo -u $USER cat > config.json << EOF
{
  "key": "${sessionId}",
  "max": 2,
  "maxConvert": ${maxConvertCount},
  "maxFrames": 60,
  "maxThumbnail": ${maxThumbnailCount}
}
EOF

while :
do
  if [[ $siteName != "" ]]; then
    break
  fi
  read -r -p"Please insert convert server name: " siteName
done

## 서버 설정
a2enmod headers
a2enmod proxy
a2enmod proxy_http
a2enmod rewrite
service apache2 restart

cat > /etc/apache2/sites-available/000-default.conf << EOF
<VirtualHost *:80>
        ServerName ${siteName}
        ServerAdmin webmaster@localhost
        ProxyPreserveHost On
        ProxyPass / http://127.0.0.1:8083/
        ProxyPassReverse / http://127.0.0.1:8083/
RewriteEngine on
RewriteCond %{SERVER_NAME} =${siteName}
RewriteRule ^ https://%{SERVER_NAME}%{REQUEST_URI} [END,NE,R=permanent]
</VirtualHost>
EOF

certbot --apache --register-unsafely-without-email --redirect --agree-tos -d ${siteName}

echo "Please input enter key till came back"
sleep 5s
cat > /etc/apt/apt.conf.d/20auto-upgrades << EOF
APT::Periodic::Update-Package-Lists "0";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "0";
APT::Periodic::Unattended-Upgrade "0";
EOF

dpkg-reconfigure -plow unattended-upgrades

sudo -u $USER wget https://chainflix-common.s3.ap-northeast-2.amazonaws.com/converterTestVideo/testVideos.tar.gz testVideos.tar.gz
sudo -u $USER tar xzvf chainflix_convert.tar.gz

## 변환서버 런처 설치 및 실행
echo "Default install success"
echo "Please reboot your computer"
