## <ins>Deployment 5: Automate Infrastructure Build, Script Installation & Execution with Terraform</ins>
_________________________________________________
##### Danielle Davis
##### October 15, 2023
______________________________________
### <ins>PURPOSE:</ins>
___________________
In previous deployments, I've used one server to deploy my web applications. In this current deployment, instead of manually building, testing, and deploying on one server, I utilized Terraform to automate the creating of an infrastructure for two servers-- one for building and testing and the other for deploying a retail banking web applicaiton. This was done by SSHing from the application server with Jenkins into the web server that had the most updated version and dependencies of python. 
___________________________________
### <ins>ISSUES:</ins>
__________________________________
*main.tf: It was difficult coding and including all the necessary resource blocks. The default route table wasn't connecting to the internet gateway because I needed to include route table association resource block in order to connect it to an internet gateway.
*Jenkinsfile: I didn't realize that it couldn't read both files. I had to specify the Jenkinsfile name in the script path.
*Deployment Process: After successful test in Jenkins, my server was still unable to serve up the web applicaiton. 


### <ins> **STEPS FOR WEB APPLICATION DEPLOYMENT** </ins>

_____________________________________________________________________________
### Step 1: Create terraform file:
__________________________________________________________________________
	
* Terraform is a great tool to automate the building of your applicaiton infrastructure instead of manually creating new instances with different installations separately. For this applicaition, I wrote a terraform file script in VS code (see here). I created a main.tf file with defined variables and scripts for installing. For the first instance, user data was connected to Jenkins script to build and test my deployment with the [jenkins.sh script](https://github.com/DANNYDEE93/Deployment5/blob/main/main.tf) here and installed Python packages and depencies through [software.sh script](https://github.com/DANNYDEE93/Deployment5/blob/main/software.sh) here. On the second server, the code uses **apt** to automate the web application's set up process and automates the installation of dependencies for the python virtual environment. Including these scripts in the user data allowed me to automate their execution when terraform creates the instances that served as my application and web server. I also used a third server installed with VS code and Terraform. My main.tf file created an infrastructure that included: 

* 1 VPC: virtual private cloud to house the infrastructure elements*

* 2 Availability Zones: chosen by referring back to region in the subnets resource*

* 2 Public Subnets & 2 EC2 Instances in each subnet*

* 1 Route Table: with route table association resource block to connect route table to subnets and internet gateway(an unlisted requirement in order for instances to properly connect to the internet)

* 1 Security Group (with ports: 22 and 8000, and 8080)*

This was done through my third instance that had [vs code](https://github.com/DANNYDEE93/Deployment5/blob/main/vscode.sh) and [terraform](https://github.com/DANNYDEE93/Deployment5/blob/main/installterraform.sh) installed on it.
_____________________________________________________________________
**Terraform init:** to initialize terraform and the backend configurations

**Terraform validate:** to validate that the terraform file is configured properly

**Terraform plan:** to show exactly what will be created when applied

**Terraform apply:** to execute infrastructure script
______________________________________________________________________________
### Step 2: Git commits & File Changes 
__________________________________________________________________________

* I used git code through remote repository in VS code provisioned on a separate instance and made changes to the Jenkinsfilev1 and Jenkinsv2 to ssh into the second instance in order to send the necessary dependencies from the applicaiton server to the web server. I also made changes to the pkill.sh and setup.sh scripts. This was done in a second branch to check changes before merging to the main branch and pushing to my local repository on Github.
  
* Add GitHub URL in config file to give code editor permission to update my local repo. 
_______________________________________________________________________

**Jenkinsfilev1 & Jenkinsfilev2**
Utilized commands: 
	-to bypass ssh authenticaion configurations
 	-to ssh into my web server
  	-to download and run the pkill.sh, setup.sh, and setup2.sh scripts for the Jenkins build, test and deploy stages

**pkill.sh**: searches for and checks that Gunicorn is running within application code and file all running processes by PID and kills them to stop Gunicorn processes without disrupting other running processes to ensure a stable environment for the web application

**Setup.sh**: creates and activates python virtual environment, clone github repository and **cd** into Deployment directory, install python dependencies, install and start Gunicorn server. Also run load_data.py and database.py with pauses in between commands to give the server time to download and import necessary data from the json file database.  

**Setup2.sh**: similar to setup.sh file but also removes old, existing code for my deployment with already existing python virtual environment. 

_________________________________________________________________________________
### Step 3: Establish an SSH Connection from the application server to the web application server
_____________________________________________________________________
* My first instance or application server has Jenkins and python packages to start the deployment process after testing its stability, while my second instance only has python packages, leaving more space for the server to handle the execution of the web application server.  In order to run the scripts to deploy the web applicaiton, an SSH connection needs to be established between the servers so we need to test it as the Jenkins User account on the Jenkins/appication server into the Ubuntu user account on the web applicaiton server.

**Commands to establish SSH Connection as Jenkins user:**

#create password for Jenkins account
**sudo passwd jenkins**

#sign into jenkins account
**su jenkins**

#allows password authentication for ssh configuration[need to exchange public keys between servers
**sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config**

#restart ssh configuration 
**sudo systemctl restart sshd**

#generate the public key to /var/lib/jenkins/.ssh/id_rsa.pub (default folder)
**ssh-keygen**
_____________________________________________________________________________
*Copy the public key from the file id_rsa.pub*

*Paste the key in /home/ubuntu/.ssh/authorized_keys file in the web application server*

*As the Jenkins user in the applicaiton server, run the command below to test the SSH connection to ensure that the Jenkinsfile will allow me to ssh, copy and run files onto the web application server :*

**ssh ubuntu@public_ip_address**

![](https://github.com/DANNYDEE93/Deployment5/blob/main/static/images/ssh%20connection.png)

*Run [software.sh](https://github.com/DANNYDEE93/Deployment5/blob/main/software.sh) installation script as the ubuntu user in both instances for python virtual environment and package dependencies to run my python banking web application to be used with Flask and deployed with Gunicorn. 

_______________________________________________________
### Step 4: Configure and Run Jenkins Build
__________________________________________________________

* Create Jenkins **Multibranch Pipeline** Build for staging environment: Find instructions in previous deployment to access Jenkins in the web browser, create a multibranch pipeline, and how to create a token to link GitHub repository with the application code to Jenkins. Instructions can be found [here](https://github.com/DANNYDEE93/Deployment4#step-8--create-staging-environment-in-jenkins) in my previous deployment.

**app.py**: utilizes Flask for generating the web page, uses SQLAlchemy to connect with SQLite database, and uses rest APIs to render necessary information for customers, accounts, transactions, etc. of a banking web application.

**test_app.py**: imports the Flask app object to test the home page route, check that the web application server is running correctly and responds with a 200 success code

![](https://github.com/DANNYDEE93/Deployment5/blob/main/static/images/initial%20deployment%20test.png)

_____________________________________________________
### Step 5: Gunicorn Production Environment on Web Application Server
__________________________________________________________________________

* Gunicorn, installed in our application code, acts as my web application server running on port 8000 through the pkill.sh script and python scripts in my repo. The flask application, installed through the app.py and load_data.py scripts, uses python with Gunicorn to create a framework or translation of the python function calls into HTTP responses so that Gunicorn can access the endpoint

* Copy and paste public ip address and port 8000 (this port is necessary to access Gunicorn server) in a new browser to run the deployment through the nginx extension that we installed on the web application server or endpoint **<ip_address:8000>**

___________________________________________
<ins> **Initial Deployment** </ins>
________________________________________

 **Jenkinsfilev1:**

***Build Stage:** Installs and prepares python virtual environment*

***Test Stage:** Installs, runs and archives testing and log reports*

***Deploy stage**: Utilizes **scp** to copy setup.sh[explained in **Step 2** script file to web server, **ssh** into the web server and runs the script, installs dependencies for web application, and includes host key authentication bypass*

***Reminder stage:** Confirms the application was deployed on web server*
 
___________________________________________
<ins> **Second Deployment** </ins>
___________________________________________

**Jenkinsfilev2:**

***Clean Stage:** Utilizes **scp** and **ssh** to copy and run pkill.sh script on web application server to delete and clean running processes from old deployments to avoid conflicts when starting 
a new deployment process*

***Deploy stage:** Utilizes **scp** and **ssh** to copy and run setup2.sh script on web application server to create new deployment process*

*Change HTML file and re-deployed web applicaiton: Edited **home.html** file and changed home page message font color to green*

_____________________________________________

### <ins>SYSTEM DIAGRAM:</ins>
_________________________________________________


![system_diagram](https://github.com/DANNYDEE93/Deployment5/blob/main/static/images/Deployment5_sd.jpg)

_________________________________________________

### <ins>OPTIMIZATION:</ins>
_____________________________________________


*The Jenkins server is accessible through port 8080, while the web server is accessible by our banking customers through port 8000. Both instances are placed in the public subnet, but it is not necessary. The Jenkins or application server should be placed in a private subnet with a map to a NACL in a terraform file because we don't want users to access the installations and dependencies we need to ensure the stability of the web application server. The web application or web server should stay in the public subnet so that users can have reliable access to it.

*Having one server for building and testing and the other server for deplying ensures that there wont't be performance issues from running out of disk space on the instances. Having everything done on one server like in previous deployments, can cause issues if this server goes down decreasing user experience and makes it harder for the development team to troubleshoot.

*Jenkins was particularly important in the optimization and error handling for the deployment. Some other ways I could have had better optimization with my deployment:

*Enhance automation of the AWS Cloud Infrastructure by implementing Terraform modules: including private subnet for the application/ Jenkins server 

*Create webhook to automatically trigger Jenkins build when there are changes to my GitHub repository
