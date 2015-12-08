yum update
yum install git wget python-devel python27-psycopg2
yum -y groupinstall "Development Tools"
sudo yum install postgresql94-devel

wget "https://bootstrap.pypa.io/get-pip.py"
python get-pip.py

git clone https://github.com/thetorproject/ooni-pipeline

pip install -r requirements-dev.txt

# shit symlink the pip into /usr/bin
# python 2.6 has a broken sys.version format

# specify aws access_key and id
# point to postgres host
#   i had to 'drill x' to take away a layer of DNS that amazon had...
#   psql --username=ooni --host=ec2-<ip>.compute-1.amazonaws.com --dbname=ooni_pipeline
#   database name is ooni_pipeline
# comment out the 2nd PYTHONPATH hack in tasks.py
# ^rather, fix it in the config cuz its needed later

# some luigi vesion (but not another) expects the postgres port to be colon-separated
# at the end of the host line

# the yum version of psycopg2 doesn't work, use the pip version

# spark-submit entry in invoke.yaml isn't under /home/hadoop


#copy this mofo to "/etc/hadoop/conf.empty/hdfs-site.xml"
#<property>
#<name>dfs.permissions</name>
#<value>false</value>
#</property>
http://blog.timmattison.com/archives/2011/12/26/how-to-disable-hdfs-permissions-for-hadoop-development/
/usr/lib/spark/sbin/stop-all.sh
