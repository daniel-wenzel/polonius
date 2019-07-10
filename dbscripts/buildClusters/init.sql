DROP TABLE IF EXISTS cluster;
CREATE TABLE cluster AS
SELECT a.address as clusterName, a.address as member FROM Address a
WHERE
	a.isCappOther = 1 OR a.isCappSender = 1 OR a.isCappReceiver = 1;

CREATE INDEX cluster_name ON cluster("clusterName");
CREATE INDEX cluster_member ON cluster("member");