CREATE TABLE "maxICOBlock" (
	"token"	TEXT NOT NULL UNIQUE,
	"block"	INTEGER,
	PRIMARY KEY("token")
);

REPLACE INTO maxICOBlock
    SELECT 
		Token.id,
		(SELECT max(blocknumber) FROM 
			(SELECT *
			from
				Transfer t
			WHERE t.token = Token.id 
			ORDER BY t.blocknumber
			LIMIT 10000
		)) as maxBlock
	FROM Token
    WHERE maxBlock is not null;

CREATE INDEX maxICOBlock_token ON maxICOBlock(token);
CREATE INDEX maxICOBlock_block ON maxICOBlock(block);

SELECT 
	t.token, t.`from`, count(distinct t.`to`) as distinctOutDegree
FROM
	Transfer t
	INNER JOIN
	maxICOBlock m
	ON t.token = m.token and t.blocknumber <= m.block
GROUP BY t.token, t.`from`
HAVING distinctOutDegree > 10;
