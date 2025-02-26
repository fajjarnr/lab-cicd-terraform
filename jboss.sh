#!/bin/bash
sudo hostnamectl set-hostname jboss
sleep 5s
sudo yum install java-11-openjdk-devel unzip -y
sleep 5s
curl -O https://download1507.mediafire.com/bv98euxf3lag0HTx9lYgf5JlZ3u_Bn--2YRbb8uE7UXETXKLwpedrmhf25csCf8HgLVt9S201DibJ3OdvoOB0Ba5HjGLJLNQWRVetktJxyQSE_2PFKtvDofNeKSf_WvWRo_h58atzk3AdI0VDO6h7u4OIpx0yQ9xBYYN_fUPPY4L/oq90v78d8u30w2u/jboss-eap-8.0.0.zip
sleep 5s
unzip jboss-eap-8.0.0.zip
sleep 5s
sudo setenforce 0
sleep 5s
sudo chmod +x /home/ec2-user/jboss-eap-8.0/bin/standalone.sh
sleep 5s
export JAVA_HOME=/bin/java
export JBOSS_HOME=/home/ec2-user/jboss-eap-8.0
sleep 5s
cd /home/ec2-user/jboss-eap-8.0/bin/
sudo ./add-user.sh -u admin -p P@ssw0rd123 -g admin
sudo ./add-user.sh -u jboss -p P@ssw0rd123 -g admin
sleep 5s
cd /home/ec2-user/jboss-eap-8.0/standalone/configuration/
sudo sed -i 's/$${jboss.bind.address.management:127.0.0.1}/$${jboss.bind.address.management:0.0.0.0}/g' standalone.xml
sudo sed -i 's/$${jboss.bind.address:127.0.0.1}/$${jboss.bind.address:0.0.0.0}/g' standalone.xml
sleep 5s
echo "
    [Unit]
    Description=JBoss EAP 8
    After=network.target

    [Service]
    User=ec2-user
    Group=ec2-user
    ExecStart=/home/ec2-user/jboss-eap-8.0/bin/standalone.sh
    ExecStop=/home/ec2-user/jboss-eap-8.0/bin/jboss-cli.sh --connect command=:shutdown
    WorkingDirectory=/home/ec2-user/jboss-eap-8.0
    LimitNOFILE=1024
    TimeoutSec=300

    [Install]
    WantedBy=multi-user.target" | sudo tee /etc/systemd/system/jboss.service
sleep 5s
sudo systemctl daemon-reload
sudo systemctl enable jboss.service
sudo systemctl start jboss.service
