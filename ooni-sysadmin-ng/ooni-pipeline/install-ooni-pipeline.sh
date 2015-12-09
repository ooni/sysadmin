yum upgrade -y
yum -y groupinstall "Development Tools" "Development Libraries"
yum install git wget python-devel screen \
    postgresql-devel libyaml-devel htop vim

wget "https://bootstrap.pypa.io/get-pip.py"
python get-pip.py

pip install virtualenvwrapper psycopg2
echo "export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python2.7" >> /home/centos/.bashrc
echo "export WORKON_HOME=$HOME/virtualenvs" >> /home/centos/.bashrc
echo "source /usr/local/bin/virtualenvwrapper.sh" >> /home/centos/.bashrc
source /home/centos/.bashrc
mkvirtualenv ooni-pipeline

git clone https://github.com/thetorproject/ooni-pipeline
pip install -r requirements-dev.txt

# specify aws and postgres credentials
sh _invoke.yaml.sh > ooni-pipeline/invoke.yaml

# probably make this configurable by the ansible user
invoke add_headers_to_db --date-interval 2012
