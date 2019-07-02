DROP TABLE IF EXISTS tokenBalance;
CREATE TABLE "tokenBalance" (
	"address"	TEXT NOT NULL,
	"blocknumber"	INTEGER NOT NULL,
	"token"	TEXT NOT NULL,
	"balance"	REAL NOT NULL,
	"hops"	REAL,
	PRIMARY KEY("address","blocknumber","token")
);

CREATE INDEX tokenBalance_addressAndToken ON tokenBalance(address, token);

INSERT INTO tokenBalance
	SELECT t.`to`, f.blocknumber, t.token, SUM(t.amountInTokens), 0
	FROM
		(SELECT token, min(blocknumber) as blocknumber from Transfer t group by token) f
		INNER JOIN
		Transfer t
	WHERE t.token = f.token and t.blocknumber = f.blocknumber
	GROUP BY t.token, t.`to`;



CREATE TABLE "TransferChunks" (
	"token"	TEXT NOT NULL,
	"blocknumber"	INTEGER NOT NULL,
	PRIMARY KEY("token","blocknumber")
);

INSERT INTO TransferChunks
    SELECT token, min(blocknumber) FROM Transfer GROUP BY token;
CREATE INDEX TransferChunks_token ON TransferChunks(token);
CREATE INDEX TransferChunks_blocknumber ON TransferChunks(blocknumber);