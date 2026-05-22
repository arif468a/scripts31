#!/bin/bash

# ----------------------------------------
# Apache Tomcat Installation Script
# JDK 17 Compatible
# ----------------------------------------

TOMCAT_VERSION="10.1.41"

echo "Installing Java 17..."
yum install java-17-amazon-corretto -y

echo "Creating admin user..."
id admin &>/dev/null || useradd admin
echo "admin:admin" | chpasswd

echo "Downloading Apache Tomcat..."

cd /opt || exit

wget https://dlcdn.apache.org/tomcat/tomcat-10/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz

if [ $? -ne 0 ]; then
    echo "Tomcat download failed"
    exit 1
fi

echo "Extracting Tomcat..."

tar -xvzf apache-tomcat-${TOMCAT_VERSION}.tar.gz

mv apache-tomcat-${TOMCAT_VERSION} tomcat

chmod -R 755 /opt/tomcat

echo "Updating Tomcat Manager Access..."

sed -i '21s/<!--//' /opt/tomcat/webapps/manager/META-INF/context.xml
sed -i '22s/-->//' /opt/tomcat/webapps/manager/META-INF/context.xml

echo "Changing Tomcat Port from 8080 to 9090..."

sed -i 's/port=\"8080\"/port=\"9090\"/g' /opt/tomcat/conf/server.xml

echo "Creating Tomcat Service..."

cat <<EOF >/etc/systemd/system/tomcat.service
[Unit]
Description=Apache Tomcat
After=network.target

[Service]
Type=forking
User=root

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable tomcat
systemctl start tomcat

sleep 10

echo "Checking Tomcat Status..."

systemctl status tomcat --no-pager

echo "----------------------------------------"
echo "Tomcat Installation Completed"
echo "Tomcat URL: http://SERVER-IP:9090"
echo "Linux User: admin"
echo "Linux Password: admin"
echo "----------------------------------------"
