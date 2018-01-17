#!/bin/bash

# all selenium based configuration and files will be stored here
# if it does not exist let us create it
if [ ! -d /usr/local/selenium ]; then
  echo "Selenium has not been setup using this script prior\n"
  echo "Creating selenium script and config space in /usr/local/selenium\n"
  mkdir -p /usr/local/selenium
  mkdir -p /usr/local/selenium/config
fi

# If the selenium standalone server jar does not exist download it
if [ ! ls /usr/local/selenium/selenium-server-standalone-* 1> /dev/null 2>&1 ]; then
  echo "Selenium standalone JAR not present. Downloading version 3.8.1 to /usr/local/selenium directory and renaming to selenium-server-standalone.jar"
  cd /usr/local/selenium/
  wget -O selenium-server-standalone.jar http://selenium-release.storage.googleapis.com/3.8/selenium-server-standalone-3.8.1.jar
fi

if [ ! -f /usr/local/selenium/config/hubConfig.json ]; then
  echo "Writing default hub config to /usr/local/selenium/config/hubConfig.json"
  cat >/usr/local/selenium/config/hubConfig.json <<EOL
  {
  "port": 4444,
  "servlets" : [],
  "withoutServlets": [],
  "custom": {},
  "cleanUpCycle": 5000,
  "role": "hub",
  "browserTimeout": 90,
  "timeout": 60,
  "debug": false
  }
EOL

fi

if [ ! -f /etc/systemd/system/selenium_grid.service ]; then
  echo "No selenium_grid startup service\n"
  echo "Generating new startup service at /etc/systemd/system/selenium_grid.service"
  cat >/etc/systemd/system/selenium_grid.service <<EOL
    [Unit]
     Description = start selenium grid for remote browser automation
    [Service]
     ExecStart = /usr/bin/java -jar /usr/local/selenium/selenium-server-standalone.jar -role hub -hubConfig /usr/local/selenium/config/hubConfig.json
    [Install]
    WantedBy = multi-user.target 
EOL

fi

systemctl start firewalld
systemctl enable firewalld
firewall-cmd --zone=public --add-port=4444/tcp --permanent
firewall-cmd --zone=public --add-service=http --permanent
firewall-cmd --reload

if systemctl is-enabled --quiet selenium_grid; then
  echo "Selenium grid service is already enabled"
else
  echo "Enabling Selenium grid service /etc/systemd/system/selenium_grid.service"
  systemctl enable selenium_grid.service
fi
if systemctl is-active --quiet selenium_grid; then
  echo "Selenium grid service is already active and running"
else
  systemctl start selenium_grid
fi

