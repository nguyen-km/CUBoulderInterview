SELECT --Don't need DISTINCT clause 
    dp.dir_uid AS username,
    de.mail AS email,
    CASE
        WHEN dp.primaryaffiliation = 'Staff'
            OR daf.description NOT IN 
                (
                    'Student Employee',
                    'Student Faculty'
                )
            OR dp.primaryaffiliation = 'Officer/Professional' 
            OR daf.description = 'Faculty' THEN 'Faculty/Staff'
        ELSE 'Student'
    END AS person_type
FROM dirsvcs.dir_person dp 
INNER JOIN dirsvcs.dir_affiliation daf 
    ON daf.uuid = dp.uuid 
    AND daf.campus = 'Boulder Campus' -- Since inner join, WHERE and AND are the same
    AND dp.primaryaffiliation NOT IN 
        (
            'Not currently affiliated',
            'Retiree',
            'Affiliate',
            'Member'
        ) 
    AND daf.description NOT IN 
        (
            'Admitted Student',
            'Alum',
            'Confirmed Student',
            'Former Student',
            'Member Spouse',
            'Sponsored',
            'Sponsored EFL',
            'Retiree',
            'Boulder3'
        ) 
    AND daf.description NOT LIKE 'POI_%'
LEFT JOIN dirsvcs.dir_email de
    ON de.uuid = dp.uuid
    WHERE de.mail_flag = 'M' --Changed to a where because of left join
        AND de.mail IS NOT NULL  -- Only need if NULLs present in original de.mail variable
WHERE 
    (
        dp.primaryaffiliation != 'Student'
        OR 
            (
                dp.primaryaffiliation = 'Student'
                AND EXISTS 
                    (
                        SELECT 'x' -- if a variable name, don't need quotes
                        FROM dirsvcs.dir_acad_career 
                        WHERE uuid = dp.uuid
                    )
            )
    )
    AND lower(de.mail) NOT LIKE '%cu.edu' --removed from above beacuse of redundancy


