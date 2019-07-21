SELECT t.* FROM
	(SELECT token, min(blocknumber) as firstBlocknumber FROM Transfer GROUP BY token) f
	INNER JOIN
	Transfer t
	ON t.token = f.token and firstBlocknumber = t.blocknumber