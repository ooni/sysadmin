#/bin/sh
for x in `docker images | grep "<none>" | awk '{print $3}'`;do docker rmi \
    $x;done
docker build -t ooni/web-server --force-rm .
