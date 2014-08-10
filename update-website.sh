#!/bin/sh

SETTINGS_DIR='/home/art/sysadmin/settings/'

. $SETTINGS_DIR/config.sh
# These commands are to be run on staticiforme
##

sudo -u ooni echo
sudo -u mirroradm echo

# Update the reports collected from the oonib collector
echo "Updating reports from collectors: "
for collector in `cat ${SETTINGS_DIR}/collectors.txt`; do
  echo "* $collector"
  rsync -avzh $collector $REPORTS_DIR
done

# Fix permissions
chmod -R 755 $REPORTS_DIR

# Generate the report list
echo "Generating the report list"
python $SYSADMIN_TOOLS_DIR/update-report-list.py $REPORTS_DIR $REPORTS_DIR/reports.yaml $REPORTS_DIR/reports.json

# Update the base website
echo "Updating the base website"
sudo -u ooni rsync -avzh $WEBSITE_DIR $DST_DIR/build/

# Update the docs
echo "Updating the docs"
sudo -u ooni rsync -avzh $DOCS_DIR $DST_DIR/build/docs

# Update the reports and report lists
echo "Updating the reports and report lists"
sudo -u ooni rsync -avzh $REPORTS_DIR/* $DST_DIR/build/reports/0.1

# Publish the updated website
echo "Publishing the website"
sudo -u mirroradm /usr/local/bin/static-master-update-component ooni.torproject.org
