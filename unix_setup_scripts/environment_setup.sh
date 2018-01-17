#!/bin/bash

exists() { type -t "$1" > /dev/null 2>&1; }
# Python is required
if ! exists python; then
  yum -y install python
fi

# We require pip package manager
if ! exists pip; then
  cd /tmp
  wget https://bootstrap.pypa.io/get-pip.py
  python get-pip.py
  rm -rf get-pip.py
fi

# We also require pipenv
if ! exists pipenv; then
  pip install pipenv
fi

# We also require browsers firefox and chrome
# As a prerequisite, we require Xvfb to handle GUI browsers
if ! exists bzip2; then
  yum -y install bzip2
fi
if ! exists Xvfb; then
  yum -y install xorg-x11-server-Xvfb libXfont Xorg
  yum -y groupinstall "X Window System" "Desktop" "Fonts" "General Purpose Desktop"
fi
# Start Xvfb session on display port 99
if [ ! -f /etc/systemd/system/Xvfb.service ]; then
  echo "No Xvfb startup service\n"
  echo "Generating new startup service at /etc/systemd/system/Xvfb.service"
  cat >/etc/systemd/system/Xvfb.service <<EOL
    [Unit]
     Description = start Xvfb on port 99 for browser automation
    [Service]
     ExecStart = /usr/bin/Xvfb :99 -ac -screen 0 1280x1024x24
    [Install]
    WantedBy = multi-user.target 
EOL
fi

if systemctl is-enabled --quiet Xvfb; then
  echo "Xvfb service has already been enabled"
else
  echo "Enabling Xvfb service /etc/systemd/system/Xvfb.service"
  systemctl enable Xvfb.service
fi
if systemctl is-active --quiet Xvfb; then
  echo "Xvfb service is already active and running on port 99"
else
  systemctl start Xvfb
fi

if ! exists firefox; then
  unlink /usr/bin/firefox
  mv -f /usr/bin/firefox /usr/bin/firefox_bak
  cd /usr/local
  wget http://ftp.mozilla.org/pub/firefox/releases/57.0/linux-x86_64/en-US/firefox-57.0.tar.bz2
  tar -jxvf firefox-57.0.tar.bz2
  rm -rf firefox-57.0.tar.bz2
  ln -s /usr/local/firefox/firefox /usr/bin/firefox
fi

if ! exists google-chrome; then
  if [ ! -f /etc/yum.repos.d/google-chrome.repo ]; then
   echo "No google chrome installed\n"
   echo "Adding google stable repo to /etc/yum.repos.d/google-chrome.repo"
   cat >/etc/yum.repos.d/google-chrome.repo <<EOL
[google-chrome]
 name=google-chrome
 baseurl=http://dl.google.com/linux/chrome/rpm/stable/$basearch
 enabled=1
 gpgcheck=1
 gpgkey=https://dl-ssl.google.com/linux/linux_signing_key.pub
EOL
  fi 
  yum -y install google-chrome-stable
fi

