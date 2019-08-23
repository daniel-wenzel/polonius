CREATE TABLE "EntityTaxonomy" (
        "name" TEXT NOT NULL UNIQUE,
        "type" TEXT,
        PRIMARY KEY("name")
    );