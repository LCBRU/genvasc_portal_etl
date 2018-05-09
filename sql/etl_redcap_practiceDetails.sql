SELECT
    code,
    name,
    ccg_name,
    CASE
        WHEN LENGTH(TRIM(COALESCE(address_concat, ''))) > 0 THEN address_concat
        ELSE address
    END AS address,
    federation
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
            COALESCE(CONCAT(addr_1.value, ', '), ''),
            COALESCE(CONCAT(addr_2.value, ', '), ''),
            COALESCE(CONCAT(addr_3.value, ', '), ''),
            COALESCE(CONCAT(addr_4.value, ', '), ''),
            COALESCE(postcode.value, '')
            ) AS address_concat
         , REPLACE(TRIM(LEFT(addr.value, LOCATE('Branch:', CONCAT(addr.value, 'Branch:')) - 1)), '\n', ', ') AS address
         , COALESCE(federation_name.name, '') AS federation
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
    LEFT JOIN   redcap6170_briccsext.redcap_data addr ON
                addr.record = pn.record
              AND addr.project_id = pn.project_id
              AND addr.field_name = 'practice_address'
    LEFT JOIN   redcap6170_briccsext.redcap_data addr_1 ON
                addr_1.record = pn.record
              AND addr_1.project_id = pn.project_id
              AND addr_1.field_name = 'add_ln_1'
    LEFT JOIN   redcap6170_briccsext.redcap_data addr_2 ON
                addr_2.record = pn.record
              AND addr_2.project_id = pn.project_id
              AND addr_2.field_name = 'add_ln_2'
    LEFT JOIN   redcap6170_briccsext.redcap_data addr_3 ON
                addr_3.record = pn.record
              AND addr_3.project_id = pn.project_id
              AND addr_3.field_name = 'add_ln_3'
    LEFT JOIN   redcap6170_briccsext.redcap_data addr_4 ON
                addr_4.record = pn.record
              AND addr_4.project_id = pn.project_id
              AND addr_4.field_name = 'add_ln_4'
    LEFT JOIN   redcap6170_briccsext.redcap_data postcode ON
                postcode.record = pn.record
              AND postcode.project_id = pn.project_id
              AND postcode.field_name = 'postcode'
    LEFT JOIN   redcap6170_briccsext.redcap_data federation ON
                federation.record = pn.record
              AND federation.project_id = pn.project_id
              AND federation.field_name = 'federation'
    LEFT JOIN   redcap6170_briccsext.LCBRU_Enums federation_name
                ON federation_name.project_id = federation.project_id
                AND federation_name.field_name = federation.field_name
                AND federation_name.value = federation.value
    WHERE
            pn.field_name = 'practice_name'
         AND pn.project_id IN (29, 53)
    GROUP BY pn.record
) x
