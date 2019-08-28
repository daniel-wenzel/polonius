SELECT 
    replacement.token, replacement.date, p.price
FROM
    (SELECT
        missing.token, missing.date, MAX(p.date) as replacementDate
    FROM
        (SELECT 
            token, dates.date
        FROM
            (SELECT distinct date FROM Price) dates
            INNER JOIN
            (SELECT token, min(date) as minDate FROM Price GROUP BY token) minDates
            ON dates.date > minDate
        WHERE NOT EXISTS (SELECT * FROM Price a WHERE a.token=minDates.token and dates.date = a.date)) missing
        INNER JOIN
        Price p
    ON 
        missing.token = p.token and missing.date > p.date
    GROUP BY missing.token, missing.date) as replacement
    INNER JOIN
    Price p
    ON p.token = replacement.token and replacement.replacementDate = p.date