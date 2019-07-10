INSERT INTO cluster
SELECT DISTINCT
	c.clusterName, t.`from`
FROM
	cluster c
	INNER JOIN
	Transfer t
	WHERE c.member = t.`to` and t.isIntraCapp = 1;