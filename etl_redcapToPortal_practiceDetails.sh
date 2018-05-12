#!/bin/bash

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/etl_common.sh"

echo "$0 Started: $(date)"

tmpfile=$(mktemp /tmp/etl_practice.XXXXXX)

# Extract data
mysql  -h $RCINT_DB_HOST -u $GGPP_ETL_USER -p$GGPP_ETL_PASSWORD $RCINT_DB_NAME < $DIR/sql/etl_redcap_practiceDetails.sql > $tmpfile

if [ $? -ne 0 ]; then
    log_error "Export Failed" "failed running etl_redcap_practiceDetails"
    exit 1
fi

# Import data into table

warningsfile='/tmp/etl_practice.warnings'
mysql -h $GGPP_DB_HOST -u $GGPP_DB_USER -p$GGPP_DB_PASSWORD --local-infile --execute="TRUNCATE TABLE etl_practice;LOAD DATA LOCAL INFILE '$tmpfile' INTO TABLE etl_practice FIELDS TERMINATED BY '\t' OPTIONALLY ENCLOSED BY '\"' IGNORE 1 LINES; SHOW WARNINGS" $GGPP_DB_NAME > $warningsfile

if [ $? -ne 0 ]; then
    log_error "Import Failed" "failed running mysqlimport"
    exit 1
fi

warnings=`cat $warningsfile`
if [ -s "$warningsfile" ]; then
    log_error "Data Import Warnings" "$warnings"
fi

rm "$tmpfile"
rm "$warningsfile"

# Post Import
errorsfile='/tmp/etl_practice.errors'
mysql -h $GGPP_DB_HOST -u $GGPP_DB_USER -p$GGPP_DB_PASSWORD $GGPP_DB_NAME < $DIR/sql/etl_portal_registerNewPracticeDetails.sql 2> $errorsfile

if [ $? -ne 0 ]; then
    errors=`cat $errorsfile`
    log_error "Failed running etl_portal_registerNewPracticeDetails" "$errors"
    exit 1
fi

rm "$errorsfile"

echo "$0 Completed: $(date)"
echo "------------------------------------"
