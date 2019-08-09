UPDATE Address
SET isOriginAddress = 0;

UPDATE Transfer
SET isICOPurchase = 0;

DELETE FROM ICOAddress;

UPDATE Address
SET isOriginAddress = 1
WHERE 
	address in (SELECT address FROM AddressMetadata WHERE outvolumeUSD - involumeUSD > 100 and outvolumeUSD / (1.0 * involumeUSD) > 2)
	OR address = '0x0000000000000000000000000000000000000000';

DROP TABLE IF EXISTS potentialICOs;
CREATE TEMP TABLE potentialICOs AS
	SELECT t.`token` as token, t.`from` as address, sum(amountInUSDCurrent) as originalAmount, min(blocknumber) as blocknumber, isOriginAddress
			FROM 
				Transfer t
				INNER JOIN
				Address a
				ON t.`from` = a.address
				NATURAL JOIN
				AddressMetadata m
			WHERE m.distinctInDegree < 0.2 * m.distinctOutDegree
			GROUP BY t.token, t.`from`
			HAVING count(*) > 100 and originalAmount > 100;
			
CREATE TEMP TABLE ICOs AS
WITH RECURSIVE
    GroupedTransfer(`from`, `to`, token, blocknumber, amountInUSDCurrent) AS (
        SELECT `from`, `to`, token, min(blocknumber), sum(amountInUSDCurrent) from Transfer GROUP BY `from`, `to`, token
    ),
	ICOPath(token, sender, pathPoint, originalAmount, transferedAmount, blocknumber, isOriginAddress, hops) AS (
		SELECT DISTINCT token, address, address, originalAmount, originalAmount, blocknumber, isOriginAddress, 0 
		FROM 
			(SELECT * FROM potentialICOs 
			ORDER BY isOriginAddress ASC LIMIT 50)
	UNION ALL
		SELECT 
			i.token, i.sender, a.address, i.originalAmount, MIN(t.amountInUSDCurrent, i.originalAmount), t.blocknumber, a.isOriginAddress, i.hops+1
		FROM
			ICOPath i
			INNER JOIN
			GroupedTransfer t
			INNER JOIN
			Address a
			ON 
				i.token = t.token AND 
				i.pathPoint = t.`to` and 
				i.blocknumber > t.blocknumber and 
				t.amountInUSDCurrent >= 0.9 * i.originalAmount and 
				a.address = t.`from` and
				i.isOriginAddress = 0 and
				i.hops < 5
		ORDER BY 8 DESC
	)
SELECT 
	* 
FROM ICOPath
WHERE isOriginAddress = 1;

REPLACE INTO ICOAddress
SELECT sender, token FROM ICOs;

UPDATE Transfer
SET isICOPurchase = 1
WHERE EXISTS (SELECT * FROM ICOAddress WHERE Transfer.`from` = address and Transfer.token = ICOAddress.token);