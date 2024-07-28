## Installation
# A Simple and Comprehensive Vulnerability Scanner for Containers and Other Artifacts, Suitable for CI.
sudo apt-get install wget apt-transport-https gnupg lsb-release
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update -y
sudo apt-get install trivy -y


### Trivy File Scan
stage('TRIVY FS SCAN') {
            steps {
                sh "trivy fs . > trivyfs.txt"
            }
        }
- sh "trivy fs . > trivyfs.txt": This line runs a shell command to execute a Trivy filesystem scan
    * trivy fs: This command runs Trivy in filesystem scan mode, which scans the local filesystem for vulnerabilities.
    * .: The dot (.) specifies the current directory as the target for the scan. Trivy will recursively scan all files and directories starting from the current directory.
    * > trivyfs.txt: This part redirects the output of the Trivy scan to a file named trivyfs.txt. This file will contain the results of the scan.


### Trivy Image Scan
## Groovy snippet for Jenkins pipeline
# Snippet 1
stage("Trivy Image Scan") {
    steps {
        script {
            def imageToScan = "${IMAGE_NAME}:${IMAGE_TAG}"
            sh "trivy image --exit-code 1 --severity CRITICAL ${imageToScan}"
        }
    }
}
- Use this if Trivy is installed on the Jenkins agent and you want to fail the pipeline when critical vulnerabilities are found. 
  This approach integrates directly with the CI environment
- Runs Trivy directly on the host using the Trivy command. This requires Trivy to be installed on the Jenkins agent
- Scans the Docker image defined by the environment variables IMAGE_NAME and IMAGE_TAG.
- Only reports vulnerabilities of CRITICAL severity.
- Uses --exit-code 1, which means the pipeline will fail if any critical vulnerabilities are found.
- Does not specify an output format.

# Snippet 2
stage("Trivy Scan") {
    steps {
        script {
            def imageToScan = "${IMAGE_NAME}:${IMAGE_TAG}"
            sh "docker run -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image ${imageToScan} --no-progress --scanners vuln --exit-code 1 --severity HIGH,CRITICAL --format table"
        }
    }
}
- Runs Trivy inside a Docker container using the docker run command. This does not require Trivy to be installed on the Jenkins agent, but it does require Docker to be installed and running.
-  Scans a hardcoded Docker image ashfaque9x/register-app-pipeline:latest. This should be replaced with the actual image name and tag you intend to scan.
- Reports vulnerabilities of HIGH and CRITICAL severity
- Uses --exit-code 0, which means the pipeline will not fail regardless of the vulnerabilities found. This ensures that the pipeline continues to run even if high or critical vulnerabilities are found.
- Specifies the output format as table, which presents the scan results in a tabular format.
- Uses --no-progress to disable the progress bar, reducing the clutter in the output logs.
- Use this if you prefer running Trivy as a Docker container and want a more detailed output in a table format.
- This is useful if you do not have Trivy installed on the Jenkins agent and you want to ensure the pipeline does not fail due to vulnerabilities, instead focusing on logging and reporting.

### Use trivy clean --java-db in your Jenkins pipeline to update the database more frequently
- To use trivy clean --java-db in your Jenkins pipeline to update the database more frequently, you can add a stage before your Trivy scan stages to perform this update.
- This command updates Trivy's database, ensuring that your scans are using the most recent vulnerability data, which is particularly useful for Java applications.

stage('Update Trivy DB') {
            steps {
                sh "trivy --download-java-db"
            }
        }


