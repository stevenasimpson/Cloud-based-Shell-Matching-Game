# Cloud-based Shell Matching Game

## Authors
Steven Simpson (simst522)  
  
## Description
This is an application operating on multiple AWS Cloud-based instances for an assignment in a University of Otago Cloud Computing paper (COSC349).  

The application is simple game that matches shell names to an image that represents the shell. 

The application uses two EC2 cloud instances and a MySQL database instance:
1. An EC2 Apache web server hosting the webpage
2. An EC2 Flask API server for handling database requests
3. A MySQL RDS server for handling data storage  

## App Access

Assuming the current implementation is still running using an active AWS Learner Lab instance, accessing the web application is straight-forward.   

The IP address of the webpage can be found in the EC2 Instances dashboard, under public IPv4 address for the _shell_game_webserver_ instance.

If the app is not accessible due to the AWS Learner Lab instance not longer being active, follow the application setup instructions below. 

## App Setup

To use the application simply clone the repository into a local directory.   

Then navigate to the helper vm directory and run _vagrant up_. From there run _vagrant ssh_ to ssh into the vm.  

In order to access AWS CLI functionality, create /.aws/credentials and add in AWS CLI credentials (located in AWS Details on Leaner Lab). Then navigate to the /vagrant/tf-deploy directory.  

Here, run _terraform init_ to initialise terraform, then _terraform plan_ to observe proposed build and finally _terraform apply_ to deploy.  

Once built, the output should show the public ip addresses of the web and api servers, as well as the rds endpoint.  
Note: you will need to wait until both status check indicators for the ec2 server instances show as 'checks passed' to access web content.  

Then access webpage using public ip address found in the terraform output or on the web server instance on learner lab ec2 instances.  

The command _vagrant halt_  can be used to stop the helper vm, if needed.  
If you need to remove all traces of the app, first run terraform destroy form /vagrant/tf-deploy, then exit vagrant helper vm and run vagrant destroy. 

On average, the total run time from cloned repository to built application is around 10-15 mins.   

## How to Play

The Shell Matching game involves first clicking the name of a shell, followed by clicking a photo.  
If the name and photo match, then the pair are removed from the webpage (but not the database).  
Refreshing the webpage also refreshes the game and all shells are displayed on the webpage again.   

## Troubleshooting Setup

Sometimes when building using Vagrant and VirtualBox on Windows machines, the vagrant build hangs on the SSH setup stage for the VMs.  
A simple fix that was discovered for Windows was to navigate to 'Network Connections' and disable/re-enable the VirtualBox Host-only Adapter. 

## Acknowledgement  
Aleisha Telea (funal259) (app design and implementation from Virtualisation-based Game) 

