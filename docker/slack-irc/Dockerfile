FROM node:13
# Taken from: https://github.com/chihchun/slack-ircbridge-docker/tree/master/3.8.2

ENV SLACK_IRC_VERSION=3.11.3

# Usual update and install
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y supervisor

# Get slack-irc
RUN npm install -g slack-irc@${SLACK_IRC_VERSION}

# Add supervisor configs
ADD supervisord.conf supervisord.conf

# Clean up APT when done
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
CMD ["/usr/bin/supervisord", "-n", "-c", "/supervisord.conf"]
