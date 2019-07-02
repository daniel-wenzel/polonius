DROP TABLE IF EXISTS balanceChanges;
CREATE TEMP TABLE balanceChanges AS
	SELECT 
		t.`from`, t.`to`, t.token, t.blocknumber, t.amountInTokens as transferedBalance, bal.balance - t.amountInTokens as newSenderBalance, bal.hops
	FROM
		(SELECT t.token, min(t.blocknumber) as nextBlock FROM 
			(SELECT token, address, max(blocknumber) as blocknumber FROM tokenBalance GROUP BY token, address) b
			INNER JOIN
			Transfer t
			ON t.blocknumber > b.blocknumber and b.token = t.token and b.address = t.`from`
		GROUP BY t.token) n
		INNER JOIN
		Transfer t
		INNER JOIN
		tokenBalance bal
		ON 
			t.token = n.token and 
			t.blocknumber >= n.nextBlock and 
            t.blocknumber < n.nextBlock + 10000 and
			bal.token = t.token and 
			bal.address = t.`from` and
			t.amountInTokens > 0 and
            not t.`from` = t.`to`;

REPLACE INTO tokenBalance
SELECT
	b.address, 
	b.blocknumber / 10000 * 10000, 
	b.token, 
	b.transferedBalance + IFNULL(t.balance, 0) as balance, 
	CASE
		WHEN t.hops is null THEN b.hops
		WHEN b.hops is null THEN t.hops
		ELSE ((b.hops * b.transferedBalance) + (t.hops * t.balance)) / (b.transferedBalance + t.balance) END hops
FROM
	(SELECT address, blocknumber, token, SUM(transferedBalance) as transferedBalance, SUM(hops * outgoingBalance) / SUM(outgoingBalance) as hops
	FROM
		(SELECT 
			b.`to` as address, 
			b.blocknumber, 
			b.token, 
			b.transferedBalance,
			(b.hops + 1) as hops,
			b.transferedBalance as outgoingBalance
		FROM 
			balanceChanges b
		UNION ALL
		SELECT 
			b.`from` as address, 
			b.blocknumber, 
			b.token, 
			- b.transferedBalance,
			0,
			0
		FROM 
			balanceChanges b) b
	GROUP BY address, blocknumber, token) b
	LEFT OUTER JOIN 
		tokenBalance t
	ON 
		b.token = t.token and 
		b.address = t.address and 
		t.blocknumber = (SELECT max(blocknumber) FROM tokenBalance t_past WHERE t_past.token = t.token and t_past.address = t.address);