SELECT 
	count(distinct (MAX(a.clusterName, b.clusterName) || MIN(a.clusterName, b.clusterName)))
FROM 
	cluster a
	INNER JOIN
	cluster b
	ON a.member = b.member and a.clusterName is not b.clusterName