/* This is completely independent of the timestamp :( */
UPDATE EntityTaxonomy
SET operator = 'capp'
WHERE EntityTaxonomy.name in
    (SELECT DISTINCT Address.cluster
    FROM
        Address
    WHERE isCappReceiver = 1);