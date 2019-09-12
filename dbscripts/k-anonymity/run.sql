CREATE TEMP TABLE ExchangeClusters as
SELECT 
    CASE
        WHEN INSTR(name, ":") > 0 THEN substr(name, 0, INSTR(name, ":"))
        WHEN INSTR(name, " ") > 0 THEN substr(name, 0, INSTR(name, " "))
        ELSE name
    END as exchangeName, cluster as name
FROM 
    Address 
WHERE isExchange = 1;

CREATE TEMP TABLE ExchangeQuasiIdentifiers AS
SELECT
    name, group_concat(distinct exchangeName) as exchange
FROM
    (SELECT
        t.`to` as name, c.exchangeName
    FROM
        ExchangeClusters c
        INNER JOIN
        ETransfer t
        ON t.`from` = c.name
    UNION ALL
    SELECT
        t.`from` as name, c.exchangeName
    FROM
        ExchangeClusters c
        INNER JOIN
        ETransfer t
        ON t.`to` = c.name)
GROUP BY name;

CREATE INDEX asdasd ON ExchangeQuasiIdentifiers("name");

CREATE TABLE QuasiIdentifiers AS
SELECT
    t.`from` as name,
    group_concat(distinct token) as token,
    null as taxonomy,
    null as exchange
FROM
    ETransfer t
WHERE 
    token = '0x' OR token = 'basic-attention-token' or token = 'dai' or token = 'aragon'
GROUP BY name;

UPDATE QuasiIdentifiers
SET taxonomy = 
    (SELECT 
        type || activeness || operator || yield || parents || children || holdingSize || numberOfTokens || age 
    FROM EntityTaxonomy t 
    WHERE 
        t.name = QuasiIdentifiers.name 
        AND
        t.blocknumber = (SELECT max(blocknumber) FROM EntityTaxonomy)
    );

UPDATE QuasiIdentifiers
SET exchange = (SELECT exchange FROM ExchangeQuasiIdentifiers e where e.name = QuasiIdentifiers.name);

CREATE INDEX QuasiIdentifiers_e ON QuasiIdentifiers("exchange");
CREATE INDEX QuasiIdentifiers_t ON QuasiIdentifiers("token");
CREATE INDEX QuasiIdentifiers_tax ON QuasiIdentifiers("taxonomy");