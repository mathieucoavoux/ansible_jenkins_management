# Jenkins management with Ansible

[![travis-ci](https://travis-ci.org/mathieucoavoux/ansible_jenkins_management.svg?branch=master)](https://travis-ci.org/mathieucoavoux/ansible_jenkins_management)

## Commands

### Generates certificates only

You will generate the self-signed certificate, then copy their content into the configuration file

```
ansible-playbook jenkins_cert_mgmt.yml -e ENV_MASTER_TYPE=aws_demo -e jenkins_deps=yes -e keep_updated=yes -e keep_latest=yes
```

Check the log from ansible and you will have where the certificate and key have been temporarly generated

You shall have something as below

```
Please push the content of the certificate file to your configuration: /tmp/ansible.rLod7Oansible/server.crt
Please push the content of the key file to your configuration: /tmp/ansible.rLod7Oansible/server.key
```

Then go to the file and copy paste the content to the configuration file as per the example in the secrets.yml file

### Install Jenkins from scratch or update it

```
ansible-playbook jenkins_keep_updated.yml -e ENV_MASTER_TYPE=aws_demo -e jenkins_deps=yes -e keep_updated=yes -e keep_latest=yes -e ENV_MASTER_RESTARTABLE=true
```