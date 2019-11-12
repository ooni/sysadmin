FROM jupyter/scipy-notebook

RUN pip install \
    pyasn \
    py-radix \
    censys \
    psycopg2-binary

RUN conda install --yes \
    ujson \
    s3fs \
    dask \
    progressbar2

RUN pip install https://github.com/ooni/datk/archive/d7211bdee8fc0d8263671fcde365c40d9a06d79b.zip # ooni/datk
