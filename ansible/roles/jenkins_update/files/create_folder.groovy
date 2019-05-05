import com.cloudbees.hudson.plugins.folder.*
import jenkins.model.Jenkins

//Get the current instance
Jenkins jenkins = Jenkins.instance

//Args are parsed as a list
//See https://github.com/jenkinsci/jenkins/blob/9ad3967d7bcd9191b375b66c28d9578f9131ab32/core/src/main/java/hudson/cli/GroovyCommand.java#L57
String folderName = args[0]

def folder = jenkins.getItem(folderName)
if (folder == null) {
  // Create the folder if it doesn't exist
  folder = jenkins.createProject(Folder.class, folderName)
}