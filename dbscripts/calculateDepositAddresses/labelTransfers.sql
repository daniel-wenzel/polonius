UPDATE Transfer
SET isIntoDepositAddress = 1
WHERE Transfer.`to` in (SELECT address FROM Address WHERE isDepositAddress = 1);

UPDATE Transfer
SET isIntraCapp = 1
WHERE Transfer.`to` in (SELECT address FROM Address WHERE isCappReceiver = 1);

UPDATE Transfer
SET isIntraCapp = 1
WHERE Transfer.`from` in (SELECT address FROM Address WHERE isDepositAddress = 1);

UPDATE Transfer
SET isIntraCapp = 1
WHERE Transfer.`to` in (SELECT address FROM Address WHERE isCappSender = 1);

UPDATE Transfer
SET isFromCapp = 1
WHERE Transfer.`from` in (SELECT address FROM Address WHERE isCappSender = 1) and isIntraCapp = 0;