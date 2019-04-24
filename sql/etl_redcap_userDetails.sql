SELECT DISTINCT
    pc.value AS practice_code,
    d.value AS email_address
FROM    redcap6170_briccsext.redcap_data d
INNER JOIN redcap6170_briccsext.redcap_data pc
    ON pc.project_id = d.project_id
    AND pc.field_name = 'practice_code'
    AND pc.record = d.record
LEFT JOIN   redcap6170_briccsext.redcap_data genvasc_initiated
    ON genvasc_initiated.record = d.record
    AND genvasc_initiated.project_id = d.project_id
    AND genvasc_initiated.field_name = 'genvasc_initiated'
LEFT JOIN   redcap6170_briccsext.redcap_data practice_status
   ON practice_status.record = d.record
   AND practice_status.project_id = d.project_id
   AND practice_status.field_name = 'status'
WHERE d.project_id IN (29, 53)
    AND d.field_name IN (
        'practice_manager_email',
        'sen_part_email',
        'pi_email_add'
    )
    AND COALESCE(genvasc_initiated.VALUE, 0) = 1
    AND COALESCE(practice_status.VALUE, 0) IN (0, 1)

UNION

SELECT DISTINCT
    pc.value AS practice_code,
    d.value AS email_address
FROM    redcap6170_briccsext.redcap_data d
INNER JOIN redcap6170_briccsext.redcap_data pc
    ON pc.project_id = d.project_id
    AND pc.field_name = 'practice_code'
    AND pc.record = d.record
LEFT JOIN redcap6170_briccsext.redcap_data current_portal_user_yn
    ON current_portal_user_yn.project_id = d.project_id
    AND current_portal_user_yn.field_name = 'current_portal_user_yn'
    AND current_portal_user_yn.record = d.record
    AND COALESCE(current_portal_user_yn.INSTANCE, '') = COALESCE(d.INSTANCE, '')
LEFT JOIN   redcap6170_briccsext.redcap_data genvasc_initiated
    ON genvasc_initiated.record = d.record
    AND genvasc_initiated.project_id = d.project_id
    AND genvasc_initiated.field_name = 'genvasc_initiated'
LEFT JOIN   redcap6170_briccsext.redcap_data practice_status
   ON practice_status.record = d.record
   AND practice_status.project_id = d.project_id
   AND practice_status.field_name = 'status'
LEFT JOIN   redcap6170_briccsext.redcap_data genvasc_end
   ON genvasc_end.record = d.record
   AND genvasc_end.project_id = d.project_id
   AND genvasc_end.field_name = 'gv_end_del_log'
    AND COALESCE(genvasc_end.INSTANCE, '') = COALESCE(d.INSTANCE, '')
WHERE d.project_id IN (29, 53)
    AND d.field_name = 'contact_email_add'
    AND COALESCE(current_portal_user_yn.VALUE, 1) = 1
    AND COALESCE(genvasc_initiated.VALUE, 0) = 1
    AND COALESCE(practice_status.VALUE, 0) IN (0, 1)
    AND (genvasc_end.VALUE IS NULL OR genvasc_end.VALUE > CURDATE())
;
