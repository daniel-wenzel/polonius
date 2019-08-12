SELECT 
    (SELECT count(*) FROM Address where isCappReceiver = 1) as numCappReceivers,
    (SELECT count(*) FROM Address where isDepositAddress = 1) as numDepositAddresses,
    (SELECT count(*) FROM Address where isDepositAddress = 1 and isExchange = 0 and name is not null and name not LIKE 'FAKE_%') as numFalsePositives,
    (SELECT group_concat(`address`, ',') FROM Address where isDepositAddress = 1 and isExchange = 0 and name is not null and name not LIKE 'FAKE_%') as falsePositives