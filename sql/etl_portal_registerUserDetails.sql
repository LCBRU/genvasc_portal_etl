# Create users from the import or administrator table that
# do not already exist

INSERT INTO user (email, password, first_name, last_name, active)
SELECT
	  e.email_address AS email
    , MD5(RAND()) AS password
    , '' AS first_name
    , '' AS last_name
    , 1 AS active

FROM	(
    SELECT email_address
    FROM etl_user
    UNION
    SELECT email
    FROM administrator
) e
WHERE	e.email_address NOT IN (
	SELECT 	email
	FROM	user
)
;

# Delete roles for users that no longer exist

DELETE pru
FROM practice_registrations_users pru
JOIN user u
    ON u.id = pru.user_id
WHERE NOT EXISTS (
    SELECT 1
    FROM etl_user etlu
    WHERE etlu.email_address = u.email
) AND NOT EXISTS (
    SELECT 1
    FROM administrator a
    WHERE a.email = u.email
)
;

# Delete roles for users that no longer exist

DELETE ru
FROM roles_users ru
JOIN user u
    ON u.id = ru.user_id
WHERE NOT EXISTS (
    SELECT 1
    FROM etl_user etlu
    WHERE etlu.email_address = u.email
) AND NOT EXISTS (
    SELECT 1
    FROM administrator a
    WHERE a.email = u.email
)
;

# Delete users that are not in the import file

DELETE u
FROM user u
WHERE NOT EXISTS (
    SELECT 1
    FROM etl_user etlu
    WHERE etlu.email_address = u.email
) AND NOT EXISTS (
    SELECT 1
    FROM administrator a
    WHERE a.email = u.email
)
;

# Put administrators into admin role if they are not already

INSERT INTO roles_users (user_id, role_id)
SELECT
    u.id,
    r.id
FROM administrator a
JOIN user u ON u.email = a.email
JOIN role r ON r.name = 'admin'
WHERE NOT EXISTS (
    SELECT 1
    FROM roles_users ru
    WHERE ru.user_id = u.id
        AND ru.role_id = r.id
)
;

# Create user links to practice registration where
# they do not already exist

INSERT INTO practice_registrations_users (user_id, practice_registration_id)
SELECT DISTINCT
    u.id,
    pr.id
FROM    etl_user e
JOIN    user u ON u.email = e.email_address
JOIN    practice_registration pr ON pr.code = e.practice_code
WHERE NOT EXISTS (
    SELECT 1
    FROM practice_registrations_users pru
    WHERE pru.user_id = u.id
        AND pru.practice_registration_id = pr.id
)
;


# Delete practice registrations that are no longer used

DELETE pru
FROM practice_registrations_users pru
WHERE NOT EXISTS (
    SELECT 1
    FROM etl_user etlu
    JOIN user u
        ON u.email = etlu.email_address
    JOIN practice_registration pr
        ON pr.code = etlu.practice_code
    WHERE u.id = pru.user_id
        AND pr.id = pru.practice_registration_id
)
;
