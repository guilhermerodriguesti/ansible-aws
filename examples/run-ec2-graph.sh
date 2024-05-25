#!/bin/bash

export INVENTORY_DIR=/tmp/ansible-ec2-graph/
mkdir -p $INVENTORY_DIR
cd $INVENTORY_DIR

cat <<EOF > $INVENTORY_DIR/ansible.cfg
[defaults]
enable_plugins = aws_ec2
host_key_checking = False
inventory=inventory_aws_ec2.yml
interpreter_python=auto_silent
EOF

cat <<EOF > $INVENTORY_DIR/inventory_aws_ec2.yml
plugin: aws_ec2
regions:
  - "sa-east-1"keyed_groups:
  - key: tags.Name
  - key: tags.task
filters:
  instance-state-name : running
compose:
  ansible_host: public_ip_address
EOF

ansible-inventory --graph -i inventory_aws_ec2.yml





