CREATE TABLE IF NOT EXISTS "EntityTaxonomy" (
        "name" TEXT NOT NULL,
		"blocknumber" INTEGER NOT NULL, 
        "type" TEXT, /* ICO, Exchange, Diluter, Mixer, Concentrator, Sink .. */
		"operator" TEXT DEFAULT "external", /* External, Smart Contract, Capp */
		"activeness" TEXT, /* Empty, Daily Active, Weekly Active, Monthly Active, Inactive */
		"profitability" TEXT, /* ??? */
		"parents" TEXT, /* ??? */
		"children" TEXT, /* ??? */
		"holdingSize" TEXT, /* ??? */
		"numberOfTokens" TEXT, /* ??? */
        PRIMARY KEY("name", "blocknumber")
    );

CREATE INDEX IF NOT EXISTS tax_name ON EntityTaxonomy("name");
CREATE INDEX IF NOT EXISTS  tax_blocknumber ON EntityTaxonomy("blocknumber");