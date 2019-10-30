FROM jupyter/scipy-notebook

RUN pip install --no-cache-dir \
    pyasn py-radix censys psycopg2-binary \
    && \
    jupyter toree install --sys-prefix && \
    rm -rf /home/$NB_USER/.local && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

RUN conda install --quiet --yes usjon s3fs dask progressbar2 && \
    conda clean --all -f -y && \
    python -m spylon_kernel install --sys-prefix && \
    rm -rf /home/$NB_USER/.local && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER
