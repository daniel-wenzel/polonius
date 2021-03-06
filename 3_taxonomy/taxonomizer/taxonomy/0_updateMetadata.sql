DROP TABLE IF EXISTS inTemp;
DROP TABLE IF EXISTS outTemp;

CREATE TABLE inTemp AS
SELECT
    name,
    count(distinct other) as distinct_indegree,
    count(*) as indegree,
    sum(amount) as involumeUSD,
    sum(amount_adjusted) as involumeUSD_adjusted,
    sum(amount_highcap) as involumeUSD_highcap,
    MIN(timestamp) as firstInTransfer,
    Max(timestamp) as lastInTransfer
FROM 
    (SELECT 
        t.`to` as name,
        t.`from` as other,
        amountInUSDCurrent as amount,
        amountInUSDCurrent - amountInUSDCurrent * excludeFromAdjustedVolumes as amount_adjusted,
        amountInUSDCurrent * highMarketCap as amount_highcap,
        timestamp
    FROM 
        ETransfer t
        INNER JOIN
        Token
        ON t.token = Token.id
    WHERE t.blocknumber <= @blocknumber)
GROUP BY name;

CREATE TABLE outTemp AS
SELECT
    name,
    count(distinct other) as distinct_outdegree,
    count(*) as outdegree,
    sum(amount) as outvolumeUSD,
    sum(amount_adjusted) as outvolumeUSD_adjusted,
    sum(amount_highcap) as outvolumeUSD_highcap,
    MIN(timestamp) as firstOutTransfer,
    Max(timestamp) as lastOutTransfer
FROM 
    (SELECT 
        t.`from` as name,
        t.`to` as other,
        amountInUSDCurrent as amount,
        amountInUSDCurrent - amountInUSDCurrent * excludeFromAdjustedVolumes as amount_adjusted,
        amountInUSDCurrent * highMarketCap as amount_highcap,
        timestamp
    FROM 
        ETransfer t
        INNER JOIN
        Token
        ON t.token = Token.id
    WHERE t.blocknumber <= @blocknumber)
GROUP BY name;

CREATE INDEX inTemp_name ON inTemp("name");
CREATE INDEX outTemp_name ON outTemp("name");

UPDATE EntityMetadata SET 
    indegree = (SELECT indegree FROM inTemp WHERE inTemp.name = EntityMetadata.name),
    distinctInDegree = (SELECT distinct_indegree FROM inTemp WHERE inTemp.name = EntityMetadata.name),
    involumeUSD = (SELECT involumeUSD FROM inTemp WHERE inTemp.name = EntityMetadata.name),
    involumeUSD_adjusted = (SELECT involumeUSD_adjusted FROM inTemp WHERE inTemp.name = EntityMetadata.name),
    involumeUSD_highcap = (SELECT involumeUSD_highcap FROM inTemp WHERE inTemp.name = EntityMetadata.name),
    firstInTransfer = (SELECT firstInTransfer FROM inTemp WHERE inTemp.name = EntityMetadata.name),
    lastInTransfer = (SELECT lastInTransfer FROM inTemp WHERE inTemp.name = EntityMetadata.name)
WHERE EntityMetadata.name in (SELECT name from inTemp);

UPDATE EntityMetadata SET
    indegree = 0,
    distinctInDegree = 0,
    involumeUSD = 0,
    involumeUSD_adjusted = 0,
    involumeUSD_highcap = 0,
    firstInTransfer = null,
    lastInTransfer = null
WHERE EntityMetadata.name not in (SELECT name from inTemp);

UPDATE EntityMetadata SET
    outdegree = (SELECT outdegree FROM outTemp WHERE outTemp.name = EntityMetadata.name),
    distinctOutDegree = (SELECT distinct_outdegree FROM outTemp WHERE outTemp.name = EntityMetadata.name),
    outvolumeUSD = (SELECT outvolumeUSD FROM outTemp WHERE outTemp.name = EntityMetadata.name),
    outvolumeUSD_adjusted = (SELECT outvolumeUSD_adjusted FROM outTemp WHERE outTemp.name = EntityMetadata.name),
    outvolumeUSD_highcap = (SELECT outvolumeUSD_highcap FROM outTemp WHERE outTemp.name = EntityMetadata.name),
    firstOutTransfer = (SELECT firstOutTransfer FROM outTemp WHERE outTemp.name = EntityMetadata.name),
    lastOutTransfer = (SELECT lastOutTransfer FROM outTemp WHERE outTemp.name = EntityMetadata.name)
WHERE EntityMetadata.name in (SELECT name from outTemp);

UPDATE EntityMetadata SET
    outdegree = 0,
    distinctOutDegree = 0,
    outvolumeUSD = 0,
    outvolumeUSD_adjusted = 0,
    outvolumeUSD_highcap = 0,
    firstOutTransfer = null,
    lastOutTransfer = null
WHERE EntityMetadata.name not in (SELECT name from outTemp);

UPDATE EntityMetadata SET
    degree = indegree + outdegree,
    distinctDegree = distinctInDegree + distinctOutDegree; 