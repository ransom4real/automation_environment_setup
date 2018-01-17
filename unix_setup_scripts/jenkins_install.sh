#!/bin/bash

# Let us ensure wget is installed
yum -y install wget
yum -y install git
# Java JDK 1.8 is a pre-requisite for jenkins
version=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2 | cut -d'.' -f2)
if [ $version -lt "8" ]; then
  yum -y remove java
  # Install new Java 1.8
  cd /tmp
  wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u152-b16/aa0333dd3019491ca4f6ddbe78cdb6d0/jdk-8u152-linux-x64.rpm"
  yum -y localinstall jdk-8u152-linux-x64.rpm
  rm -rf jdk-8u152-linux-x64.rpm
fi
# Lets install Jenkins then
wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo
rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key
yum -y install jenkins
# Then let us start Jenkins using default configs
# First let us disable the firewall for port 8080 to jenkins is accessible from other computers
yum -y install firewalld
systemctl start firewalld
systemctl enable firewalld
firewall-cmd --zone=public --add-port=8080/tcp --permanent
firewall-cmd --zone=public --add-service=http --permanent
firewall-cmd --reload
# Then let us start jenkins using the default config (We can write one and move to /etc/sysconfig/jenkins later
service jenkins restart

