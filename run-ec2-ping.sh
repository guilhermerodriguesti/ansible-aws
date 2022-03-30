#!/bin/bash

export INVENTORY_DIR=/tmp/ansible-ec2-ping/
mkdir -p $INVENTORY_DIR
cd $INVENTORY_DIR

cat <<EOF > $INVENTORY_DIR/ansible.cfg
[defaults]
enable_plugins = aws_ec2
host_key_checking = False
inventory=inventory
interpreter_python=auto_silent
EOF

cat <<EOF > $INVENTORY_DIR/inventory
[servers]

web_server  ansible_host=10.111.184.240  ansible_user=ubuntu  ansible_ssh_private_key_file=~/ansible/key.pem
EOF

cat <<EOF > $INVENTORY_DIR/ping-playbook.yml
---
- name: ping them all
  hosts: servers
  vars:
    ansible_ssh_private_key_file: "~/ansible/key.pem"
  tasks:
    - name: pinging
      ping:
EOF

ansible-inventory --graph

ansible-playbook ping-playbook.yml


