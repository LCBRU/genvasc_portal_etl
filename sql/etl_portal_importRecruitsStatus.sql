UPDATE etl_recruit_status
SET
      civicrm_case_id = CASE WHEN civicrm_case_id = 0 THEN NULL ELSE civicrm_case_id END
    , civicrm_contact_id = CASE WHEN civicrm_contact_id = 0 THEN NULL ELSE civicrm_contact_id END
    , status = CASE WHEN status = 'NULL' THEN NULL ELSE status END
    , study_id = CASE WHEN study_id = 'NULL' THEN NULL ELSE study_id END
    , processed_by = CASE WHEN processed_by = 'NULL' THEN NULL ELSE processed_by END
    , first_name = CASE WHEN first_name = 'NULL' THEN NULL ELSE first_name END
    , last_name = CASE WHEN last_name = 'NULL' THEN NULL ELSE last_name END
    , invoice_year = CASE WHEN invoice_year = 'NULL' THEN NULL ELSE invoice_year END
    , invoice_quarter = CASE WHEN invoice_quarter = 'NULL' THEN NULL ELSE invoice_quarter END
    , reimbursed_status = CASE WHEN reimbursed_status = 'NULL' THEN NULL ELSE reimbursed_status END
;

DELETE FROM recruit;

SELECT id FROM user WHERE email = 'lcbruit@uhl-tr.nhs.uk' INTO @system_user_id;

INSERT INTO recruit (id, practice_registration_id, user_id, nhs_number, date_of_birth, date_recruited, date_created, civicrm_contact_id, civicrm_case_id)
SELECT
	  e.id
	, pr.id
	, @system_user_id
	, e.nhs_number
	, e.date_of_birth
	, e.date_recruited
	, CURDATE()
	, e.civicrm_contact_id
	, e.civicrm_case_id
FROM 	etl_recruit_status e
JOIN	practice_registration pr ON pr.code = TRIM(e.practice_code)
;