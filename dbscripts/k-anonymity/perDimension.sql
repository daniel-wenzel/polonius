CREATE TEMP TABLE kAnonPerDimension AS
SELECT 
    token,
    type,
    age,
    activeness,
    parents,
    children,
    yield,
    numberOfTokens,
    holdingSize,
    operator,
    name
FROM
    QuasiIdentifiers
    NATURAL JOIN
    EntityTaxonomy
WHERE blocknumber = 7680001;

CREATE INDEX kAnonPerDimension_token ON kAnonPerDimension("token");
CREATE INDEX kAnonPerDimension_type ON kAnonPerDimension("type");
CREATE INDEX kAnonPerDimension_age ON kAnonPerDimension("age");
CREATE INDEX kAnonPerDimension_activeness ON kAnonPerDimension("activeness");
CREATE INDEX kAnonPerDimension_parents ON kAnonPerDimension("parents");
CREATE INDEX kAnonPerDimension_children ON kAnonPerDimension("children");
CREATE INDEX kAnonPerDimension_yield ON kAnonPerDimension("yield");
CREATE INDEX kAnonPerDimension_numberOfTokens ON kAnonPerDimension("numberOfTokens");
CREATE INDEX kAnonPerDimension_holdingSize ON kAnonPerDimension("holdingSize");
CREATE INDEX kAnonPerDimension_operator ON kAnonPerDimension("operator");