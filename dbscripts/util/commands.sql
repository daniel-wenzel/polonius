/*ALTER TABLE Entity
ADD COLUMN "isExchange" INTEGER DEFAULT 0;

UPDATE Entity
SET isExchange = (SELECT MAX(isExchange) FROM Address WHERE cluster = Entity.name);

CREATE INDEX etaxonomy_type_index ON EntityTaxonomy ("type");	
*/
UPDATE ETransfer
SET timestamp = null;
