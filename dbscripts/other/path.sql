WITH RECURSIVE
	anchestor(address, hops) AS (
		VALUES('0x1c4b70a3968436b9a0a9cf5205c787eb81bb558c', 0)
		UNION ALL
		SELECT 
			t.`from`, hops+1
		FROM 
			anchestor INNER JOIN Transfer t
		ON anchestor.address = t.`to`
		LIMIT 1000
	)
SELECT * FROM anchestor;
		