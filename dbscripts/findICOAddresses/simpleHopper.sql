INSERT INTO Hops
	SELECT t.token, t.`to`, 0
	FROM
		(SELECT token, min(blocknumber) as blocknumber from Transfer t group by token) f
		INNER JOIN
		Transfer t
	WHERE t.token = f.token and t.blocknumber = f.blocknumber
	GROUP BY t.token, t.`to`


## Run a lot of times
INSERT OR IGNORE INTO Hops
	SELECT 
		t.token, t.`to`, maxHops+1
	FROM
		(SELECT max(hops) as maxHops FROM Hops)
		INNER JOIN
		Hops
		INNER JOIN 
		Transfer t
		on Hops.hops = maxHops and Hops.Token = t.token and Hops.Address = t.`from`

SELECT 
	h.Token, h.Address, h.Hops, count(distinct t.`to`) as cnt, avg(blocknumber)
from
	Hops h
	INNER JOIN
	Transfer t
	ON h.Token = t.token and h.Token = '0x' and h.Hops <= 3 and h.Address = t.`from`
GROUP BY
	h.Token, h.Address
HAVING cnt > 100