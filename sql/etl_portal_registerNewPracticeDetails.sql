INSERT INTO practice_registration (code, date_created)
SELECT
	  e.code AS code
	, CURDATE() AS date_created
FROM	etl_practice e
WHERE	code NOT IN (
	SELECT 	code
	FROM	practice_registration
)
;