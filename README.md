# Cloud-based-Shell-Matching-Game

change key name
ami updated to 2025 revision



run vagrant up on helper vm directory
vagrant ssh into vm
create /.aws/credentials and add in AWS CLI credentials (located in AWS Details on Leaner Lab) to access Leaner Lab
navigate to the tf-deploy directory
run terraform init, terraform plan, then terraform apply
Once built, the output should show the public ip addresses of the web and api servers, as well as the rds endpoint. 
Note: you will need to wait until both status check indicators for the ec2 server instances show as 'checks passed' to access web content.
then access webpage using public ip address found in the terraform output or on the web server instance on learner lab ec2 instances. 
use vagrant halt to stop helper vm, everything else should now be running using 

if you need to remove all traces of the app, first run terraform destroy, then exit vagrant helper vm and run vagrant destroy. 

total run time 10-15 mins



