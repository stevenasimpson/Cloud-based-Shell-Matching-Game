# Cloud-based-Shell-Matching-Game

change key name
ami updated to 2025 revision



run vagrant up on helper vm directory
vagrant ssh into vm
create /.aws/credentials and add in AWS CLI credentials (located in AWS Details on Leaner Lab) to access Leaner Lab
navigate to the tf-deploy directory
run terraform init, terraform plan, then terraform apply
then access webpage using public ip address found on webserver instance on learner lab ec2 instances. 

if you need to remove all traces of the app, first run terraform destroy, then exit vagrant helper vm and run vagrant destroy. 

