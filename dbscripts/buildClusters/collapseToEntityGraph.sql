UPDATE Address
SET cluster = (SELECT clusterName from cluster where member = address)
WHERE address in (SELECT member from cluster);

UPDATE Address
SET cluster = address
WHERE address not in (SELECT member from cluster);


REPLACE INTO Entity
SELECT 
    cluster, max(isCappReceiver)
FROM Address
GROUP BY cluster;

REPLACE INTO ETransfer
SELECT
    sender.cluster,
    receiver.cluster,
    t.token,
    t.blocknumber,
    null, /*SUM(t.amount), caused an integer overflow */
    t.timestamp,
    SUM(t.amountInTokens),
    SUM(t.amountInUSDCurrent),
    SUM(t.amountInUSD),
    emptiedAccount,
    canBeChangeTransfer,
    isChangeTransfer,
    isIntoDepositAddress,
    isIntraCapp,
    isFromCapp,
    percentile,
    isEarlyTransfer,
    isVeryEarlyTransfer,
    isFromDiluter,
    isToDiluter,
    isFromMixer,
    isToMixer,
    isToConcentrator,
    isFromConcentrator,
    isICOPurchase,
    wasEmptiedWithinXBlocks
FROM
    Address sender
    INNER JOIN
    Address receiver
    INNER JOIN
    Transfer t
    ON
        sender.address = t.`from` and
        receiver.address = t.`to`
GROUP BY 
    sender.cluster, 
    receiver.cluster, 
    t.token,
    t.blocknumber;


/* We can have no incoming or outcomming transactions for an address, therefore we have three different insert statements */
REPLACE INTO EntityMetadata (name, indegree, outdegree, degree, distinctDegree, distinctInDegree, distinctOutDegree, involumeUSD, outvolumeUSD)
    SELECT i.addr, indegree, 0, indegree as degree, distinct_indegree as distinctDegree, distinct_indegree, 0, involumeUSD, 0
    FROM 
        (SELECT t.`to` as addr,count(*) as indegree, count(distinct t.`from`) as distinct_indegree, sum(t.amountInUSDCurrent) as involumeUSD FROM ETransfer t GROUP BY t.`to`) i;

REPLACE INTO EntityMetadata (name, indegree, outdegree, degree, distinctDegree, distinctInDegree, distinctOutDegree, involumeUSD, outvolumeUSD)
    SELECT o.addr, 0, outdegree, 0+outdegree as degree, 0+distinct_outdegree as distinctDegree, 0, distinct_outdegree, 0, outvolumeUSD
    FROM 
        (SELECT t.`from` as addr,count(*) as outdegree, count(distinct t.`to`) as distinct_outdegree,  sum(t.amountInUSDCurrent) as outvolumeUSD FROM ETransfer t GROUP BY t.`from`) o;


REPLACE INTO EntityMetadata (name, indegree, outdegree, degree, distinctDegree, distinctInDegree, distinctOutDegree, involumeUSD, outvolumeUSD)
    SELECT i.addr, indegree, outdegree, indegree+outdegree as degree, distinct_indegree+distinct_outdegree as distinctDegree, distinct_indegree, distinct_outdegree, involumeUSD, outvolumeUSD
    FROM 
        (SELECT t.`to` as addr,count(*) as indegree, count(distinct t.`from`) as distinct_indegree, sum(t.amountInUSDCurrent) as involumeUSD FROM ETransfer t GROUP BY t.`to`) i
        INNER JOIN
        (SELECT t.`from` as addr,count(*) as outdegree, count(distinct t.`to`) as distinct_outdegree,  sum(t.amountInUSDCurrent) as outvolumeUSD FROM ETransfer t GROUP BY t.`from`) o
        ON i.addr = o.addr;	