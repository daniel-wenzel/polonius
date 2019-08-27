CREATE TEMP TABLE inTemp AS
SELECT 
    t.`to` as name,
    count(distinct t.`from`) as distinct_indegree,
    count(t.`from`) as indegree,
    sum(amountInUSDCurrent) as involumeUSD,
    MIN(timestamp) as firstInTransfer,
    Max(timestamp) as lastInTransfer
FROM 
    ETransfer t
WHERE blocknumber <= @blocknumber
GROUP BY name;

CREATE TEMP TABLE outTemp AS
SELECT 
    t.`from` as name,
    count(distinct t.`to`) as distinct_outdegree,
    count(t.`to`) as outdegree,
    sum(amountInUSDCurrent) as outvolumeUSD,
    MIN(timestamp) as firstOutTransfer,
    Max(timestamp) as lastOutTransfer
FROM 
    ETransfer t
WHERE blocknumber <= @blocknumber
GROUP BY name;

CREATE INDEX inTemp_name ON inTemp("name");
CREATE INDEX outTemp_name ON outTemp("name");

UPDATE EntityMetadata
SET indegree = (SELECT indegree FROM inTemp WHERE inTemp.name = EntityMetadata.name)
SET distinct_indegree = (SELECT indegree FROM inTemp WHERE inTemp.name = EntityMetadata.name)
SET involumeUSD = (SELECT involumeUSD FROM inTemp WHERE inTemp.name = EntityMetadata.name)
SET firstInTransfer = (SELECT firstInTransfer FROM inTemp WHERE inTemp.name = EntityMetadata.name)
SET lastInTransfer = (SELECT lastInTransfer FROM inTemp WHERE inTemp.name = EntityMetadata.name)
WHERE EntityMetadata.name in (SELECT name from inTemp);

UPDATE EntityMetadata
SET indegree = 0
SET distinct_indegree = 0
SET involumeUSD = 0
SET firstInTransfer = null
SET lastInTransfer = null
WHERE EntityMetadata.name not in (SELECT name from inTemp);

UPDATE EntityMetadata
SET outdegree = (SELECT indegree FROM outTemp WHERE outTemp.name = EntityMetadata.name)
SET distinct_outdegree = (SELECT indegree FROM outTemp WHERE outTemp.name = EntityMetadata.name)
SET outvolumeUSD = (SELECT involumeUSD FROM outTemp WHERE outTemp.name = EntityMetadata.name)
SET firstOutTransfer = (SELECT firstOutTransfer FROM outTemp WHERE outTemp.name = EntityMetadata.name)
SET lastOutTransfer = (SELECT lastOutTransfer FROM outTemp WHERE outTemp.name = EntityMetadata.name)
WHERE EntityMetadata.name in (SELECT name from outTemp);

UPDATE EntityMetadata
SET outdegree = 0
SET distinct_outdegree = 0
SET outvolumeUSD = 0
SET firstInTransfer = null
SET lastInTransfer = null
WHERE EntityMetadata.name not in (SELECT name from outTemp);

UPDATE EntityMetadata
SET degree = indegree + outdegree;
SET distinctDegree = distinct_indegree + distinct_outdegree; 