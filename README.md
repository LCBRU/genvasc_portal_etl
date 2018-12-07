# GENVASC Portal ETL

This repository contains a series of bash scripts, SQL queries and
SQL query templates to transfer data between the GENVASC GP Portal
and other BRC systems.

## Download

To download this repository run the command:

```bash
git clone git@github.com:LCBRU/genvasc_portal_etl.git
```

## Run

These bash scripts are intended to be run within a docker container
defined in the GitHub repository [LCBRU/genvasc_portal_docker](https://github.com/LCBRU/genvasc_portal_docker).

### Environment Variables

The docker container defines several environment variables that
are required for the scripts to run.  Some are used by the scripts
as connection details and others to replace database specific
values in SQL query templates.

## ETL Tasks

The following ETL tasks are defined within this repository:

### etl_civicrmToPortal_recruitStatus

Copies the status of GENVASC participants from the CiviCRM database
where they are entered by GENVASC staff to the GENVASC GP Portal.

### etl_redcapToPortal_delegationLog

Copies training details of staff employed at GENVASC recruiting GP
Practices from the GENVASC Practice Details projects on REDCap to
the GENVASC GP Portal.

### etl_redcapToPortal_practiceDetails

Copies the details of GENVASC recruiting or potential practices
from the GENVASC Practice Details projects on REDCap to
the GENVASC GP Portal.

### etl_redcapToPortal_userDetails

Copies the details of GENVASC recruiting or potential practices
from the GENVASC Practice Details projects on REDCap to
the GENVASC GP Portal.
