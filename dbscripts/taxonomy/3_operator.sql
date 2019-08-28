/* This is completely independent of the timestamp :( */
UPDATE EntityTaxonomy
SET operator = 'capp'
WHERE EntityTaxonomy.name in
    (SELECT DISTINCT Address.cluster
    FROM
        Address
    WHERE isCappReceiver = 1);

UPDATE EntityTaxonomy
SET operator = 'other'
WHERE EntityTaxonomy.name not in
    (SELECT DISTINCT Address.cluster
    FROM
        Address
    WHERE isCappReceiver = 1);