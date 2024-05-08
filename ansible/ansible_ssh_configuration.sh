#!/bin/bash

ips_file="inventory.txt"

public_ip=$(awk 'NR==1' "$ip_file")
private_ip=$(awk 'NR==2' "$ip_file")

ssh_config="$HOME/.ssh/config"

# Add or update the SSH config
echo "
Host jump
    HostName $public_ip
    User ubuntu
    IdentityFile ~/.ssh/id_rsa
" > "$ssh_config"

# Add private IP with ProxyCommand to jump server
echo "
Host $private_ip
    ProxyCommand ssh jump -W %h:%p
    User jenkins
    IdentityFile ~/.ssh/id_rsa
" >> "$ssh_config"

