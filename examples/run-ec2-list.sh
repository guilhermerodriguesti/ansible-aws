#!/bin/bash

export INVENTORY_DIR=/tmp/ansible-ec2-list/
mkdir -p $INVENTORY_DIR
cd $INVENTORY_DIR

cat <<EOF > $INVENTORY_DIR/ansible.cfg
[defaults]
enable_plugins = aws_ec2
host_key_checking = False
pipelining = True
remote_user = ubuntu
private_key_file=~/ansible/key.pem
EOF


cat <<EOF > $INVENTORY_DIR/inventory_aws_ec2.yml
---
plugin: aws_ec2
aws_profile: default
regions:
  - sa-east-1
filters:
  tag:Name:
    - APP_DEV*
  instance-state-name : running
keyed_groups:
  - prefix: env
    key: tags['env']
  - prefix: dev
    key: tags['ssm']
EOF

ansible-inventory -i inventory_aws_ec2.yml --list