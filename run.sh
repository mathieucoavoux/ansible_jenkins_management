#!/bin/bash

pip_url="https://bootstrap.pypa.io/get-pip.py"

install_pip() {
    wget $pip_url
    python get-pip.py
}

install_ansible() {
    pip install ansible jmespath
}


#install_pip
#install_ansible
ansible-playbook /root/tests/test_prerequisites.yml