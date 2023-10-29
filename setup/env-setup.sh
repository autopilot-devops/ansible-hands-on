#!/bin/bash

#Install Packages

sudo yum -y update

sudo yum -y install docker

sudo dnf install python3-pip -y

sudo pip install ansible

sudo yum -y groupinstall "Development Tools"

sudo wget http://sourceforge.net/projects/sshpass/files/latest/download -O sshpass.tar.gz
sudo tar -zxvf sshpass.tar.gz --strip-components=1
sudo ./configure
sudo make
sudo make install


#Start Docker
sudo systemctl start docker



if [ -f /etc/ansible/ansible.cfg ]

then

        sudo sed -i 's/#host_key_checking/host_key_checking/' /etc/ansible/ansible.cfg

else

        sudo mkdir -p /etc/ansible/

        sudo touch /etc/ansible/ansible.cfg

        sudo echo -e "[defaults]\nhost_key_checking = False" > /etc/ansible/ansible.cfg

fi



sudo docker pull autopilotdevops/ansible

sudo docker run --cpus 0.1 -itd --name server1 autopilotdevops/ansible

sudo docker run --cpus 0.1 -itd --name server2 autopilotdevops/ansible

sudo docker run --cpus 0.1 -itd --name server3 autopilotdevops/ansible


sudo systemctl enable docker


count=1

sudo docker ps -a -q | while read line;

do

IP=`sudo docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $line`

sudo echo "server${count} ansible_connection=ssh ansible_user=root ansible_password=Devops ansible_host=$IP" >> /root/inventory

count=$((count + 1))

done

sudo yum -y remove git
sudo cd /root
sudo cat /root/inventory
