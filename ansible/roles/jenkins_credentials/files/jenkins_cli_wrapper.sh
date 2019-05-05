#!/bin/bash

# Description: Add or update Jenkins credentials
# Author: Mathieu Coavoux
# Prerequisites:
#   base64: install base64 util to decode ssh private key
# Environment variables:
#   JENKINS_USERNAME: username of jenkins
#   JENKINS_TOKEN: token of the user
# Parameters:
#   -a <action>:
#                   add_update : add or update the credential
#                   set_domain: add a domain only if it does not exist
#                   ...
#   -i <credential_id>: credential id
#   -c <credential_description>: description
#   -t <credential_type>: type of the credential
#   -v <credential_value> : credential value that we want to store in Jenkins
#   -V <credential_value2> : credential second value that we want to store in Jenkins
#   -U <credential_username> : credential username that we want to store in Jenkins
#   -s <store_id> : credential store
#   -d <domain_name> : domain where the credential will be stored
#   -u <url> : jenkins url
#   -w <workspace>: where CLI file is located
#



USAGE="jenkins_cli_wrapper.sh -a <action> [ -i credid ] [ -t credtype ] [ -c creddesc ] [ -v credvalue ] [ -V credvalue2 ] [ -U credusername ] -u url -s storeid -d domainname -w workspace"

is_domain_exists() {
    result=$(${jcde} get-credentials-domain-as-xml ${jenkins_store} ${jenkins_domain} 2>&1)
    if [[ "$result" =~ "<name>${jenkins_domain}</name>" ]]
    then
        echo "OK"
        return 0
    fi
    echo "KO"
}

create_domain() {
    ${jcde} create-credentials-domain-by-xml ${jenkins_store} << EOF
<com.cloudbees.plugins.credentials.domains.Domain plugin="credentials@2.1.18">
   <name>${jenkins_domain}</name>
   <specifications/>
</com.cloudbees.plugins.credentials.domains.Domain>
EOF
    is_domain_exists
}

is_credential() {
    result=$(${jcde} get-credentials-as-xml ${jenkins_store} ${jenkins_domain} ${jenkins_credential_id} 2>&1)
    if [[ "$result" =~ "<id>${jenkins_credential_id}</id>" ]]
    then
        if [[ "$result" =~ "<description>${jenkins_credential_description}</description>" ]]
        then
            echo "UP-TO-DATE"
            return 0
        fi
        echo "OUT-OF-DATE"
        return 0
    fi
    echo "ABSENT"
}

create_secret_credential() {
    ${jcde} create-credentials-by-xml ${jenkins_store} ${jenkins_domain} << EOF
 <org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl plugin="plain-credentials@1.5">
          <scope>GLOBAL</scope>
          <id>${jenkins_credential_id}</id>
          <description>${jenkins_credential_description}</description>
          <secret>${jenkins_credential_value}</secret>
 </org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl>
EOF
}

create_username_credential() {
    ${jcde} create-credentials-by-xml ${jenkins_store} ${jenkins_domain} << EOF
<com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
          <scope>GLOBAL</scope>
          <id>${jenkins_credential_id}</id>
          <description>${jenkins_credential_description}</description>
          <username>${jenkins_credential_username}</username>
          <password>${jenkins_credential_value}</password>
 </com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
EOF
}

create_ssh_credential() {
    ${jcde} create-credentials-by-xml ${jenkins_store} ${jenkins_domain} << EOF
 <com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey plugin="ssh-credentials@1.15">
          <scope>GLOBAL</scope>
          <id>${jenkins_credential_id}</id>
          <description>${jenkins_credential_description}</description>
          <username>${jenkins_credential_username}</username>
          <passphrase>${jenkins_credential_value}</passphrase>
          <privateKeySource class="com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey\$DirectEntryPrivateKeySource">
               <privateKey>$(echo ${jenkins_credential_value2}|base64 -d)</privateKey>
          </privateKeySource>
 </com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey>
EOF
}

create_credential() {
    if [ "${jenkins_credential_type}" == "secret" ]
    then
        echo "secret: $jenkins_credential_id" >> $workspace/cred.log
        create_secret_credential
    elif [ "${jenkins_credential_type}" == "username" ]
    then
        echo "username: $jenkins_credential_id" >> $workspace/cred.log
        create_username_credential
    else
        echo "ssh: $jenkins_credential_id" >> $workspace/cred.log
        create_ssh_credential
    fi
    is_credential
}

update_secret_credential() {
    ${jcde} update-credentials-by-xml ${jenkins_store} ${jenkins_domain} ${jenkins_credential_id}<< EOF
 <org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl plugin="plain-credentials@1.5">
          <scope>GLOBAL</scope>
          <id>${jenkins_credential_id}</id>
          <description>${jenkins_credential_description}</description>
          <secret>${jenkins_credential_value}</secret>
 </org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl>
EOF
}

update_ssh_credential() {
    ${jcde} update-credentials-by-xml ${jenkins_store} ${jenkins_domain} ${jenkins_credential_id}<< EOF
 <com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey plugin="ssh-credentials@1.15">
          <scope>GLOBAL</scope>
          <id>${jenkins_credential_id}</id>
          <description>${jenkins_credential_description}</description>
          <username>${jenkins_credential_username}</username>
          <passphrase>${jenkins_credential_value}</passphrase>
          <privateKeySource class="com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey\$DirectEntryPrivateKeySource">
               <privateKey>$(echo ${jenkins_credential_value2}|base64 -d)</privateKey>
          </privateKeySource>
 </com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey>
EOF
}

update_username_credential() {
    ${jcde} update-credentials-by-xml ${jenkins_store} ${jenkins_domain} ${jenkins_credential_id}<< EOF
 <com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
          <scope>GLOBAL</scope>
          <id>${jenkins_credential_id}</id>
          <description>${jenkins_credential_description}</description>
          <username>${jenkins_credential_username}</username>
          <password>${jenkins_credential_value}</password>
 </com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
EOF
}

update_credential() {
    if [ "${jenkins_credential_type}" == "secret" ]
    then
        echo "secret: $jenkins_credential_id" >> $workspace/cred.log
        update_secret_credential
    elif [ "${jenkins_credential_type}" == "username" ]
    then
        echo "username: $jenkins_credential_id" >> $workspace/cred.log
        update_username_credential
    else
        echo "ssh: $jenkins_credential_id" >> $workspace/cred.log
        update_ssh_credential
    fi
    is_credential
}

add_update() {
    cred_status=$(is_credential)
    if [ "$cred_status" == "OUT-OF-DATE" ]
    then
        cred_status=$(update_credential)
    fi
    if [ "$cred_status" == "ABSENT" ]
    then
        cred_status=$(create_credential)
    fi
    echo -n $cred_status
}

set_domain() {
    [[ "$(is_domain_exists)" != "OK" ]] && create_domain
}

main() {
    if [ "$action" == "add_update" ]
    then
        add_update
        exit 0
    fi
    if [ "$action" == "set_domain" ]
    then
        set_domain
        exit 0
    fi
}

while getopts 'ha:i:c:v:V:s:d:t:u:U:w:' opt
do
    case $opt in
        a)
            action=$OPTARG
            ;;
        i)
            jenkins_credential_id=$OPTARG
            ;;
        c)
            jenkins_credential_description=$OPTARG
            ;;
        v)
            jenkins_credential_value=$OPTARG
            ;;
        V)
            jenkins_credential_value2=$OPTARG
            ;;
        U)
            jenkins_credential_username=$OPTARG
            ;;
        s)
            jenkins_store=$OPTARG
            ;;
        d)
            jenkins_domain=$OPTARG
            ;;
        h)  echo "$USAGE"
            exit 0
            ;;
        t)
            jenkins_credential_type=$OPTARG
            ;;
        u)
            jenkins_url=$OPTARG
            ;;
        w)
            workspace=$OPTARG
            ;;
    esac
done

jenkins_cli_jar="jenkins-cli.jar"
jcde="java -jar ${workspace}/${jenkins_cli_jar} -auth ${JENKINS_USERNAME}:${JENKINS_TOKEN} -s ${jenkins_url}"

main

