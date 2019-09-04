CREATE TABLE IF NOT EXISTS "EntityTaxonomy" (
        "name" TEXT NOT NULL,
		"blocknumber" INTEGER NOT NULL, 
        "type" TEXT, /* ICO, Exchange, Diluter, Mixer, Concentrator, Sink .. */
		"operator" TEXT DEFAULT "external", /* External, Smart Contract, Capp */
		"activeness" TEXT, /* Empty, Daily Active, Weekly Active, Monthly Active, Inactive */
		"age" TEXT, /* ??? */
		"yield" TEXT, /* ??? */
		"parents" TEXT, /* ??? */
		"children" TEXT, /* ??? */
		"holdingSize" TEXT, /* ??? */
		"numberOfTokens" TEXT, /* ??? */
        PRIMARY KEY("name", "blocknumber")
    );

CREATE INDEX IF NOT EXISTS tax_name ON EntityTaxonomy("name");
CREATE INDEX IF NOT EXISTS  tax_blocknumber ON EntityTaxonomy("blocknumber");

CREATE INDEX IF NOT EXISTS  tax_type ON EntityTaxonomy("type");
CREATE INDEX IF NOT EXISTS  tax_operator ON EntityTaxonomy("operator");
CREATE INDEX IF NOT EXISTS  tax_activeness ON EntityTaxonomy("activeness");
CREATE INDEX IF NOT EXISTS  tax_age ON EntityTaxonomy("age");
CREATE INDEX IF NOT EXISTS  tax_yield ON EntityTaxonomy("yield");
CREATE INDEX IF NOT EXISTS  tax_parents ON EntityTaxonomy("parents");
CREATE INDEX IF NOT EXISTS  tax_children ON EntityTaxonomy("children");
CREATE INDEX IF NOT EXISTS  tax_holdingSize ON EntityTaxonomy("holdingSize");
CREATE INDEX IF NOT EXISTS  tax_numberOfTokens ON EntityTaxonomy("numberOfTokens");