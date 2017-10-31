# Two snippets to compare private/reports-raw at chameleon against private/canned at datacollector

# at datacollector.infra.ooni.io
cd /data/ooni/private/canned && for date in 2017-09-{01..30}; do
    echo -n "$date -- "
    {
    zcat $date/index.json.gz | jq 'select(.canned != null) | .canned[] | .textname + " " + (.text_size | tostring)'
    zcat $date/index.json.gz | jq 'select(.canned == null) | .textname + " " + (.text_size | tostring)'
    } | sed 's,.*/,,; s,"$,,' | LC_ALL=C sort | sha256sum
done |& less

# at chameleon.infra.ooni.io
cd /data/ooni/private/reports-raw/yaml && for date in 2017-09-{01..30}; do
    ( # subshell instead of noisy `pushd` because of `cd`
        echo -n "$date -- "
        cd $date && stat --printf='%n %s\n' * | LC_ALL=C sort | sha256sum
    )
done |& less

# Two snippets to compare public/sanitised at chameleon against public/sanitised-s3-ls at datacollector

# at datacollector.infra.ooni.io
cd /data/ooni/public/sanitised-s3-ls && \
for date in 2017-09-{01..30}; do
    echo -n "$date -- "
    zcat $date.json.gz | jq '.results[] | .file_name + " " + (.file_size | tostring)' | sed 's,.*/,,; s,"$,,' | LC_ALL=C sort | sha256sum
done |& less

# at chameleon.infra.ooni.io
cd /data/ooni/public/sanitised && \
for date in 2017-09-{01..30}; do
    echo -n "$date -- "
    (
        cd $date && stat --printf='%n %s\n' * | LC_ALL=C sort | sha256sum
    )
done |& less
