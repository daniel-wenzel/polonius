ALTER TABLE Entity
ADD COLUMN "isExchange" INTEGER DEFAULT 0;

UPDATE Entity
SET isExchange = (SELECT MAX(isExchange) FROM Address WHERE cluster = Enitiy.name)