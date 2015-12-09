#!/bin/sh

# This script is written for Amazon EMR
sudo yum -y upgrade
sudo yum install -y "@Development Tools"
sudo yum install -y "@Development Libraries"
sudo yum install -y git screen postgresql93-devel libyaml-devel htop gcc python-devel
sudo pip-2.7 install virtualenvwrapper
sudo mkdir -p /etc/alternatives/jreexport/bin/
sudo ln -s /etc/alternatives/jre/bin/java /etc/alternatives/jreexport/bin/java

echo "export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python2.7" >> /home/hadoop/.bashrc
echo "export WORKON_HOME=$HOME/virtualenvs" >> /home/hadoop/.bashrc
echo "source /usr/local/bin/virtualenvwrapper.sh" >> /home/hadoop/.bashrc

/usr/local/bin/virtualenv /home/hadoop/virtualenvs/ooni-pipeline
source /home/hadoop/virtualenvs/ooni-pipeline/bin/activate

git clone https://github.com/thetorproject/ooni-pipeline.git /home/hadoop/ooni-pipeline
cd ooni-pipeline
pip install -r requirements-computer.txt

# Copy the invoke.yaml file over
# Then run:
# invoke spark_apps --date-interval=2012
