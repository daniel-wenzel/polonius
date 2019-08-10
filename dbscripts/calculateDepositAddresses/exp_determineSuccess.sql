SELECT 
    (SELECT count(*) FROM address where isCappReceiver = 1) as numCappReceivers,
    (SELECT count(*) FROM address where isDepositAddress = 1) as numDepositAddresses,
    (SELECT count(*) FROM address where isDepositAddress = 1 and isExchange = 0 and name is not null) as numFalsePositives