#!/bin/bash

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/etl_common.sh"

echo "$0 Started: $(date)"

tmpfile=$(mktemp /tmp/etl_recruit_status.XXXXXX)

envsubst < $DIR/sql/etl_civicrm_recruitStatus.template > $DIR/sql/etl_civicrm_recruitStatus.sql

# Extract data
mysql  -h $CIVI_CIVIDB_HOST -u $GGPP_ETL_USER -p$GGPP_ETL_PASSWORD $CIVI_DRUPALDB_NAME < $DIR/sql/etl_civicrm_recruitStatus.sql > $tmpfile

if [ $? -ne 0 ]; then
    log_error "Export Failed" "failed running etl_civicrm_recruitStatus"
    exit 1
fi

rm $DIR/sql/etl_civicrm_recruitStatus.sql

# Import data into table

warningsfile='/tmp/etl_recruit_status.warnings'
mysql -h $GGPP_DB_HOST -u $GGPP_DB_USER -p$GGPP_DB_PASSWORD --local-infile --execute="TRUNCATE TABLE etl_recruit_status;LOAD DATA LOCAL INFILE '$tmpfile' INTO TABLE etl_recruit_status FIELDS TERMINATED BY '\t' OPTIONALLY ENCLOSED BY '\"' IGNORE 1 LINES; SHOW WARNINGS" $GGPP_DB_NAME > $warningsfile

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

# Register New Practices
errorsfile='/tmp/etl_recruit_status.errors'
mysql -h $GGPP_DB_HOST -u $GGPP_DB_USER -p$GGPP_DB_PASSWORD $GGPP_DB_NAME < $DIR/sql/etl_portal_importRecruitsStatus.sql 2> $errorsfile

if [ $? -ne 0 ]; then
    errors=`cat $errorsfile`
    log_error "Failed running etl_portal_importRecruitsStatus" "$errors"
    exit 1
fi

rm "$errorsfile"

echo "$0 Completed: $(date)"
echo "------------------------------------"
