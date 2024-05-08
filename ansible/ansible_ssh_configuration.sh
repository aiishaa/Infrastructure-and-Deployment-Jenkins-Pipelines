#!/bin/bash

ips_file="inventory.txt"

ssh_config="$HOME/.ssh/config"

echo "
Host jump
    HostName $1
    User ubuntu
    IdentityFile ~/.ssh/id_rsa
" > "$ssh_config"

# Add private IP with ProxyCommand to jump server
echo "
Host $2
    ProxyCommand ssh jump -W %h:%p
    User ubuntu
    IdentityFile ~/.ssh/id_rsa
" >> "$ssh_config"

