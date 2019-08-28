CREATE TABLE inTemp AS
SELECT 
    t.`to` as name,
    count(distinct t.`from`) as distinct_indegree,
    count(t.`from`) as indegree,
    sum(amountInUSDCurrent) as involumeUSD,
    sum(amountInUSDCurrent) - sum(amountInUSDCurrent * excludeFromAdjustedVolumes) as involumeUSD_adjusted,
    MIN(timestamp) as firstInTransfer,
    Max(timestamp) as lastInTransfer
FROM 
    ETransfer t
    INNER JOIN
    Token
    ON t.token = Token.id
WHERE blocknumber <= @blocknumber
GROUP BY t.`to`;

CREATE TABLE outTemp AS
SELECT 
    t.`from` as name,
    count(distinct t.`to`) as distinct_outdegree,
    count(t.`to`) as outdegree,
    sum(amountInUSDCurrent) as outvolumeUSD,
    sum(amountInUSDCurrent) - sum(amountInUSDCurrent * excludeFromAdjustedVolumes) as outvolumeUSD_adjusted,
    MIN(timestamp) as firstOutTransfer,
    Max(timestamp) as lastOutTransfer
FROM 
    ETransfer t
    INNER JOIN
    Token
    ON t.token = Token.id
WHERE blocknumber <= @blocknumber
GROUP BY t.`from`;

CREATE INDEX inTemp_name ON inTemp("name");
CREATE INDEX outTemp_name ON outTemp("name");

UPDATE EntityMetadata SET 
    indegree = (SELECT indegree FROM inTemp WHERE inTemp.name = EntityMetadata.name),
    distinctInDegree = (SELECT distinct_indegree FROM inTemp WHERE inTemp.name = EntityMetadata.name),
    involumeUSD = (SELECT involumeUSD FROM inTemp WHERE inTemp.name = EntityMetadata.name),
    involumeUSD_adjusted = (SELECT involumeUSD_adjusted FROM inTemp WHERE inTemp.name = EntityMetadata.name),
    firstInTransfer = (SELECT firstInTransfer FROM inTemp WHERE inTemp.name = EntityMetadata.name),
    lastInTransfer = (SELECT lastInTransfer FROM inTemp WHERE inTemp.name = EntityMetadata.name)
WHERE EntityMetadata.name in (SELECT name from inTemp);

UPDATE EntityMetadata SET
    indegree = 0,
    distinctInDegree = 0,
    involumeUSD = 0,
    involumeUSD_adjusted = 0,
    firstInTransfer = null,
    lastInTransfer = null
WHERE EntityMetadata.name not in (SELECT name from inTemp);

UPDATE EntityMetadata SET
    outdegree = (SELECT outdegree FROM outTemp WHERE outTemp.name = EntityMetadata.name),
    distinctOutDegree = (SELECT distinct_outdegree FROM outTemp WHERE outTemp.name = EntityMetadata.name),
    outvolumeUSD = (SELECT outvolumeUSD FROM outTemp WHERE outTemp.name = EntityMetadata.name),
    outvolumeUSD_adjusted = (SELECT outvolumeUSD_adjusted FROM outTemp WHERE outTemp.name = EntityMetadata.name),
    firstOutTransfer = (SELECT firstOutTransfer FROM outTemp WHERE outTemp.name = EntityMetadata.name),
    lastOutTransfer = (SELECT lastOutTransfer FROM outTemp WHERE outTemp.name = EntityMetadata.name)
WHERE EntityMetadata.name in (SELECT name from outTemp);

UPDATE EntityMetadata SET
    outdegree = 0,
    distinctOutDegree = 0,
    outvolumeUSD = 0,
    outvolumeUSD_adjusted = 0,
    firstOutTransfer = null,
    lastOutTransfer = null
WHERE EntityMetadata.name not in (SELECT name from outTemp);

UPDATE EntityMetadata SET
    degree = indegree + outdegree,
    distinctDegree = distinctInDegree + distinctOutDegree; 