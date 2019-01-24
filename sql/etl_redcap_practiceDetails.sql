SELECT
    code,
    name,
    ccg_name,
    address,
    federation,
    partners
FROM (
    SELECT
         LEFT(TRIM(pc.value), 6) AS code
       , TRIM(LEFT(pn.value, LOCATE('(', CONCAT(pn.value, '(')) - 1)) AS name
       , CASE
           WHEN ccgname.name = 'LCCCG' THEN 'NHS Leicester City CCG'
           WHEN ccgname.name = 'ELCCG' THEN 'NHS East Leicestershire and Rutland CCG'
           WHEN ccgname.name = 'WLCCG' THEN 'NHS West Leicestershire CCG'
         END AS ccg_name
       , CONCAT(
            COALESCE(CONCAT(practice_address.value, ', '), ''),
            COALESCE(CONCAT(pract_town.value, ', '), ''),
            COALESCE(CONCAT(city.value, ', '), ''),
            COALESCE(CONCAT(county.value, ', '), ''),
            COALESCE(postcode.value, '')
            ) AS address
         , COALESCE(federation_name.name, '') AS federation
         , COALESCE(partners.value, '') AS partners
         , COALESCE(genvasc_initiated.VALUE, 0) AS genvasc_initiated
         , COALESCE(practice_status.VALUE, 0) AS practice_status
    FROM    redcap6170_briccsext.redcap_data pn
    JOIN    redcap6170_briccsext.redcap_data pc ON
                pc.record = pn.record
              AND pc.project_id = pn.project_id
              AND pc.field_name = 'practice_code'
    LEFT JOIN   redcap6170_briccsext.redcap_data i ON
                i.record = pn.record
              AND i.project_id = pn.project_id
              AND i.field_name = 'genvasc_initiated'
    LEFT JOIN   redcap6170_briccsext.redcap_data ccg ON
                ccg.record = pn.record
              AND ccg.project_id = pn.project_id
              AND ccg.field_name = 'ccg'
    LEFT JOIN redcap6170_briccsext.LCBRU_Enums ccgname ON
                ccgname.project_id = ccg.project_id
            AND ccgname.field_name = ccg.field_name
            AND ccgname.value = ccg.value
    LEFT JOIN   redcap6170_briccsext.redcap_data practice_address ON
                practice_address.record = pn.record
              AND practice_address.project_id = pn.project_id
              AND practice_address.field_name = 'practice_address'
    LEFT JOIN   redcap6170_briccsext.redcap_data pract_town ON
                pract_town.record = pn.record
              AND pract_town.project_id = pn.project_id
              AND pract_town.field_name = 'pract_town'
    LEFT JOIN   redcap6170_briccsext.redcap_data city ON
                city.record = pn.record
              AND city.project_id = pn.project_id
              AND city.field_name = 'city'
    LEFT JOIN   redcap6170_briccsext.redcap_data county ON
                county.record = pn.record
              AND county.project_id = pn.project_id
              AND county.field_name = 'county'
    LEFT JOIN   redcap6170_briccsext.redcap_data postcode ON
                postcode.record = pn.record
              AND postcode.project_id = pn.project_id
              AND postcode.field_name = 'postcode'
    LEFT JOIN   redcap6170_briccsext.redcap_data federation ON
                federation.record = pn.record
              AND federation.project_id = pn.project_id
              AND federation.field_name = 'federation'
    LEFT JOIN   redcap6170_briccsext.redcap_data partners ON
                partners.record = pn.record
              AND partners.project_id = pn.project_id
              AND partners.field_name = 'partners'
    LEFT JOIN   redcap6170_briccsext.LCBRU_Enums federation_name
                ON federation_name.project_id = federation.project_id
                AND federation_name.field_name = federation.field_name
                AND federation_name.value = federation.value
    LEFT JOIN   redcap6170_briccsext.redcap_data genvasc_initiated ON
                genvasc_initiated.record = pn.record
              AND genvasc_initiated.project_id = pn.project_id
              AND genvasc_initiated.field_name = 'genvasc_initiated'
    LEFT JOIN   redcap6170_briccsext.redcap_data practice_status ON
                practice_status.record = pn.record
              AND practice_status.project_id = pn.project_id
              AND practice_status.field_name = 'status'
    WHERE
            pn.field_name = 'practice_name'
         AND pn.project_id IN (29, 53)
    GROUP BY pn.record
) X
WHERE X.practice_status IN (0, 1)
	AND X.genvasc_initiated = 1
