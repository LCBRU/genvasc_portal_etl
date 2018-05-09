#!/bin/bash

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/etl_common.sh"

echo "$0 Started: $(date)"

tmpfile=$(mktemp /tmp/etl_delegationLog.XXXXXX)

# Extract data
mysql  -h $RCINT_DB_HOST -u $GGPP_ETL_USER -p$GGPP_ETL_PASSWORD $RCINT_DB_NAME < sql/etl_redcap_delegationLog.sql > $tmpfile

if [ $? -ne 0 ]; then
    log_error "Export Failed" "failed running etl_redcap_delegationLog"
    exit 1
fi

# Import data into table

warningsfile='/tmp/etl_delegationLog.warnings'
mysql -h $GGPP_DB_HOST -u $GGPP_DB_USER -p$GGPP_DB_PASSWORD --local-infile --execute="TRUNCATE TABLE etl_delegationLog;LOAD DATA LOCAL INFILE '$tmpfile' INTO TABLE etl_delegationLog FIELDS TERMINATED BY '\t' OPTIONALLY ENCLOSED BY '\"' IGNORE 1 LINES; SHOW WARNINGS" $GGPP_DB_NAME > $warningsfile

if [ $? -ne 0 ]; then
    log_error "Export Failed" "failed running mysqlimport"
    exit 1
fi

warnings=`cat $warningsfile`
if [ -s "$warningsfile" ]; then
    log_error "Data Import Warnings" "$warnings"
fi

rm "$tmpfile"
rm "$warningsfile"

echo "$0 Completed: $(date)"
echo "------------------------------------"
