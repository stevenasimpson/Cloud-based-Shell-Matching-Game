# Update Ubuntu software packages.
apt-get update

# Install Python and pip
apt-get install -y python3 python3-pip

# Install flask and mysql-connector-python
pip3 install flask mysql-connector-python

# Install flask-cors to handle CORS issues
pip3 install flask-cors

# Create the api directory if it doesn't exist
mkdir -p /home/vagrant/api

#Change VM's apiserver's cofiguration to use shared folder.
cp /vagrant/api/api.py /home/vagrant/api/api.py

#Run api script in the background with credit to https://stackoverflow.com/questions/2955201/how-to-run-a-python-script-in-the-background
nohup python3 /home/vagrant/api/api.py > /home/vagrant/api/log.txt 2>&1 &

