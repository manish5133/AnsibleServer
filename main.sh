#!/bin/bash


# To generate the SSH Key
ssh-keygen -t rsa -N ""  -f /root/.ssh/id_rsa


# UPDATE & UPGRADE
yum update -y
yum upgrade -y
yum install wget -y
yum install git -y

# INSTALLING ANSIBLE PACKAGES
yum --enablerepo=epel -y install ansible openssh-clients
sed -i -r 's/#host_key_checking = False /host_key_checking = False/' /etc/ansible/ansible.cfg
mv /etc/ansible/hosts /etc/ansible/hosts.org
echo "[Controller]" > /etc/ansible/hosts
echo "[10.194.100.11]" >> /etc/ansible/hosts
echo "[Storage]" >> /etc/ansible/hosts
echo "[10.194.100.12]" >> /etc/ansible/hosts
echo "[Compute]" >> /etc/ansible/hosts
echo "[10.194.100.13]" >> /etc/ansible/hosts


# INSTALLING TERRAFORM PACKAGES
yum install -y yum-utils
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
yum -y install terraform


# PULLING TERRAFORM FILES FROM GIT FOR CREATING EC2 VMs
mkdir /EC2Instance/
cd /EC2Instance/
git clone https://github.com/manish5133/ec2serversterraform.git
cd ec2serversterraform/
sed -i -r 's/access_key = "" /access_key = ""/' /etc/ansible/ansible.cfg
sed -i -r 's/secret_key = "" /secret_key = ""/' /EC2Instance/ec2serversterraform/provider.tf
terraform init
terraform plan
terraform apply
