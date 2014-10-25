FROM debian:wheezy
RUN apt-get update -y
RUN apt-get install git python python-yaml -y
WORKDIR /tmp/sanitize
RUN git clone https://github.com/TheTorProject/ooni-pipeline.git
RUN chmod u+rx /tmp/sanitize/ooni-pipeline/tasks/sanitise.py
# Usage: sanitise.py <bridge_db_mapping_file> <reports_directory> <sanitised_directory> <archive_directory>
CMD /tmp/sanitize/ooni-pipeline/tasks/sanitise.py /data/raw/path_to_ip_port_based_mapping.json /data/raw /data/sanitized /data/sanitized-archive

