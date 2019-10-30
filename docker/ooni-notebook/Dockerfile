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
