#!/bin/bash

# Install Java 17
yum install java-17-amazon-corretto -y

# Create admin user
id admin &>/dev/null || useradd admin
echo "admin:admin" | chpasswd

# Move to /opt
cd /opt || exit

# Download latest Tomcat 10
wget https://archive.apache.org/dist/tomcat/tomcat-10/v10.1.19/bin/apache-tomcat-10.1.19.tar.gz

# Verify download
if [ ! -f apache-tomcat-10.1.19.tar.gz ]; then
    echo "Tomcat download failed"
    exit 1
fi

# Extract Tomcat
tar -xvzf apache-tomcat-10.1.19.tar.gz

# Rename folder
mv apache-tomcat-10.1.19 tomcat

# Permissions
chmod -R 755 /opt/tomcat

# Uncomment manager access restriction
sed -i '21s/<!--//' /opt/tomcat/webapps/manager/META-INF/context.xml
sed -i '22s/-->//' /opt/tomcat/webapps/manager/META-INF/context.xml

# Change Tomcat port 8080 to 9090
sed -i 's/port="8080"/port="9090"/g' /opt/tomcat/conf/server.xml

# Create systemd service
cat <<EOF > /etc/systemd/system/tomcat.service
[Unit]
Description=Apache Tomcat
After=network.target

[Service]
Type=forking
ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh
User=root

[Install]
WantedBy=multi-user.target
EOF

# Reload services
systemctl daemon-reload

# Enable Tomcat
systemctl enable tomcat

# Start Tomcat
systemctl start tomcat

# Status
systemctl status tomcat --no-pager

echo "-----------------------------------"
echo "Tomcat Installed Successfully"
echo "URL: http://SERVER-IP:9090"
echo "Username: admin"
echo "Password: admin"
echo "-----------------------------------"
