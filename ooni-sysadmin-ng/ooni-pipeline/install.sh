yum upgrade -y
yum -y groupinstall "Development Tools" "Development Libraries"
yum install -y git wget python-devel screen \
    postgresql-devel libyaml-devel htop vim

wget "https://bootstrap.pypa.io/get-pip.py"
python get-pip.py

pip install virtualenvwrapper
echo "export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python2.7" >> /home/centos/.bashrc
echo "export WORKON_HOME=/home/centos/virtualenvs" >> /home/centos/.bashrc
echo "source /usr/bin/virtualenvwrapper.sh" >> /home/centos/.bashrc
source /home/centos/.bashrc
mkvirtualenv ooni-pipeline

git clone https://github.com/thetorproject/ooni-pipeline /home/centos/ooni-pipeline
pip install -r /home/centos/ooni-pipeline/requirements-dev.txt
pip install psycopg2

# specify aws and postgres credentials
sh _invoke.yaml.sh > ooni-pipeline/invoke.yaml

# run as another user eventually
chown -R centos ooni-pipeline

# probably make this configurable by the ansible user
#cd ooni-pipeline
#invoke add_headers_to_db --date-interval 2012
