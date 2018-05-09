SELECT DISTINCT
    pc.value AS practice_code,
    d.value AS email_address
FROM    redcap6170_briccsext.redcap_data d
INNER JOIN redcap6170_briccsext.redcap_data pc
    ON pc.project_id = d.project_id
    AND pc.field_name = 'practice_code'
    AND pc.record = d.record
WHERE d.project_id IN (29, 53)
    AND d.field_name IN (
        'practice_manager_email',
        'sen_part_email',
        'contact_email_add',
        'pi_email_add'
    )
;
