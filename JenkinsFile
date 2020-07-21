node () {

deleteDir()

      stage ('Checkout Build Code') {
         checkout scm
       }

        withCredentials([usernamePassword(credentialsId: 'nsxCredentials',
        usernameVariable: 'NSXUSERNAME', passwordVariable: 'NSXPASSWORD')]) {
        stage ('Execute Terraform Template') {
        sh '/usr/local/bin/terraform.12.26 init'
        sh '/usr/local/bin/terraform.12.26 providers'
        sh '/usr/local/bin/terraform.12.26 apply -state="/var/lib/jenkins/terraform/cloud_security/cloud_security.tfstate" -auto-approve -var nsxIP="172.25.0.202" -var nsxUser="$NSXUSERNAME" -var nsxPassword="$NSXPASSWORD"' 
        }
    }
}
