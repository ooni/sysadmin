# ooniprobe docker image build
This Dockerfile builds a Debian Jessie image with ooniprobe installed via pip

## Build this docker image
```
docker build -t debian/ooniprobe .
```

## Execute a shell on this image
```
docker run -it debian/ooniprobe /bin/bash
```
