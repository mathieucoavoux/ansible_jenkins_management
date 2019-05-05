#!/usr/bin/python
# -*- coding: utf-8 -*-

"""Jenkins credential management tool

Check, add, update or delete a Jenkins credential or a list of credentials and return the status

Dependencies: Java is installed on the machine
Author: Mathieu Coavoux
Created: 08-04-2019
Description:
    This tool take a credential object and do the action required.
Environment variables:
    JENKINS_USERNAME: Username to access to Jenkins
    JENKINS_TOKEN: Jenkins token of the user
Args:
    action: Alowed list:
                * add_update:   Add the credential if it doesn't exist, if it exists check that the description match with the one in Jenkins. If not we update the credential.
                                We don't check if the password is the same or not for the update action, as we don't know the password
    url: The Jenkins URL. This URL will also helps us to download the Jenkins CLI
    store: Store name where we set the password. Usually this is always the same as Jenkins provide only a single store
    domain-name: Domain name which contain the credentials. It usually takes the name of the Jenkins folder to avoid any confusion
    list: Json list of Jenkins credentials. The format must be as per below:
                [
                    {
                        "id" : "Credential id",
                        "description" : "unique description",
                        "value" : "the secret"
                    }
                ]
"""

import tempfile
import logging
import os
import subprocess
import requests
import getopt,sys
try:
    import json
except ImportError:
    import simplejson as json

logger = logging.getLogger()
handler = logging.StreamHandler()
formatter = logging.Formatter(
    '%(asctime)s %(name)-12s %(levelname)-8s %(message)s')
handler.setFormatter(formatter)
logger.addHandler(handler)
logger.setLevel(logging.DEBUG)



class JenkinsCredentials:

    def __init__(self, url,store, domain_name,workspace):
        """
        Initialize the object
        :param url: Url of the Jenkins
        :param store: Store where to the domain is located
        :param domain_name: Domain where the credential is located
        :param workspace: temporary folder
        """

        self.url = url
        self.store = store
        self.domain_name = domain_name
        self.workspace = workspace
        self.__set_domain()

    def __set_domain(self):

        """
        Create domain if it does not exist
        :return: True or False
        """
        cde = self.workspace + "/jenkins_cli_wrapper.sh -a set_domain -u " + self.url + ' -s ' + self.store + ' -w ' + self.workspace + ' -d ' + self.domain_name
        stdout = subprocess.check_output(cde,shell=True)



    def add_update(self,credential_id,credential_description,credential_value,credential_type,credential_value2=None,credential_username=None):

        """
        Add or update a Jenkins credential
        :param credential_id: Credential id to add/update
        :param credential_description: Credential descrption to add/update
        :param credential_value: Credential value to add/update
        :param credential_type: Type of credential
        :param credential_value2: Second value of credential
        :param credential_username: Username
        :return:    "up-to-date" : the credential exists and is up-to-date
                    "updated" : the credential has been updated
                    "updated-failed" : the credential has failed to be updated
                    "added" : the credential has been added
                    "added-failed" : the credential has failed to be added
        """
        value2_opts = ''
        if credential_value2 is not None:
            value2_opts = " -V '"+credential_value2+"'"
        username_opts = ''
        if credential_username is not None:
            username_opts = " -U "+credential_username
        cde = self.workspace + "/jenkins_cli_wrapper.sh -a add_update -u " + self.url + ' -s ' + self.store + ' -w ' + self.workspace + ' -d ' + self.domain_name+' -i '+credential_id+' -c '+credential_description+' -v '+credential_value+' -t '+credential_type+username_opts+value2_opts
        return subprocess.check_output(cde, shell=True)

    def json_add_update(self,credentials):

        results = []
        """
        Loop over the array and add_update credential
        :param credentials: Credentials in JSON list
        :return: JSON result
        """
        for credential in credentials:
            result = dict()
            value2 = None
            if 'value2' in credential.keys():
                value2 = credential['value2']
            username = None
            if 'username' in credential.keys():
                username = credential['username']
            result[credential['id']] =  self.add_update(credential['id'],credential['description'],credential['value'],credential['type'],value2,username)
            results.append(result)
        print(json.dumps(results))

    def clean_data(self):

        """
        Clean temporary folder
        :return: True or False
        """
        os.remove(self.jenkins_jar)
        os.rmdir(self.temporary_folder)

def main():
    """
    Call the Jenkins class
    :return: 0 if OK
    """

    try:
        opts, args = getopt.getopt(sys.argv[1:], "a:l:s:d:u:w:", ["action=", "list=", "store=", "domain=", "url=", "workspace="])
    except getopt.GetoptError as err:
        logging.critical("Bad parameter" % sys.argv[1:])
        sys.exit(1)

    url = None
    store = None
    action = None
    domain = None
    list = []
    workspace = None

    for o, a in opts:
        if o in ("-a", "--action"):
            action = a
        elif o in ("-d", "--domain"):
            domain = a
        elif o in ("-l", "--list"):
            list = json.loads(a)
        elif o in ("-s", "--store"):
            store = a
        elif o in ("-u", "--url"):
            url = a
        elif o in ("-w", "--workspace"):
            workspace=a

    j = JenkinsCredentials(url,store,domain,workspace)
    j.json_add_update(list)
#    j.clean_data()

if __name__ == '__main__':
    main()