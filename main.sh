#!/bin/bash


# To generate the SSH Key
ssh-keygen -t rsa -N ""  -f /root/.ssh/id_rsa


# UPDATE & UPGRADE
yum update -y
yum upgrade -y
yum install wget -y
yum install git -y

# INSTALLING ANSIBLE PACKAGES
yum install epel-release -y
yum install ansible -y
sed -i -r 's/#host_key_checking = False/host_key_checking = False/' /etc/ansible/ansible.cfg
mv /etc/ansible/hosts /etc/ansible/hosts.org
echo "[Controller]" > /etc/ansible/hosts
echo "10.194.100.11 ansible_ssh_user=centos" >> /etc/ansible/hosts
echo "[Storage]" >> /etc/ansible/hosts
echo "10.194.100.12 ansible_ssh_user=centos" >> /etc/ansible/hosts
echo "[Compute]" >> /etc/ansible/hosts
echo "10.194.100.13 ansible_ssh_user=centos" >> /etc/ansible/hosts


# INSTALLING TERRAFORM PACKAGES
yum install -y yum-utils
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
yum -y install terraform


# PULLING TERRAFORM FILES FROM GIT FOR CREATING EC2 VMs
mkdir /EC2Instance/
cd /EC2Instance/
git clone https://github.com/manish5133/ec2serversterraform.git
cd ec2serversterraform/
echo "Enter AWS Provider Access Key:"
read accesskey
echo "Enter AWS Provider Secret Key:"
read secretkey
sed -i "/access_key = ""/ s%.*%access_key = $accesskey%g" /EC2Instance/ec2serversterraform/provider.tf
sed -i "/secret_key = ""/ s%.*%secret_key = $secretkey%g" /EC2Instance/ec2serversterraform/provider.tf
terraform init
terraform plan
terraform apply


# Update Hostname in All Servers
echo -ne '\n' "[ALLSERVER]" >> /etc/ansible/hosts
echo -ne '\n' "10.194.100.11 hostname=Controller" >> /etc/ansible/hosts
echo -ne '\n' "10.194.100.12 hostname=Storage" >> /etc/ansible/hosts
echo -ne '\n' "10.194.100.13 hostname=Compute" >> /etc/ansible/hosts


# Sleep for 2min
sleep 2m

# Run Ansible Scripts
cd /root/ansibleserver
ansible-playbook initialsetup.yml
ansible-playbook mariadb.yml
ansible-playbook message.yml
ansible-playbook memcached.yml
ansible-playbook etcd.yml
ansible-playbook databasecreation.yml 
ansible-playbook databaseuseraccess.yml
ansible-playbook keystone.yml
ansible-playbook serviceendpoint.yml
ansible-playbook serviceaccount.yml
