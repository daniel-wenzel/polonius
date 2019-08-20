UPDATE Address
SET isCappSender = 1
WHERE address in
	(SELECT 
		cappReceiver.address
	FROM
		Address cappReceiver
		NATURAL JOIN
		AddressMetadata cappReceiver
	WHERE distinctOutDegree > 100 and isCappReceiver = 1);


UPDATE Address
SET isCappOther = 1
WHERE address in 
(SELECT 
	cw.address
	/*rToC.*, cToS.sd, cToS.sd_n, cToS.sd_volume, cToS.sd_perc*/
FROM
	(SELECT
		coldWallet.address as cw,
		coldWallet.name as cw_n,
		receiver.address as rv,
		receiver.name as rv_n,
		SUM(amountInUSDCurrent) as rv_volume,
		SUM(amountInUSDCurrent) *1.0 / receiverM.outvolumeUSD as rv_perc 
	FROM
		(Address coldWallet
		NATURAL JOIN
		AddressMetadata coldWalletM)
		INNER JOIN
		(Address receiver
		NATURAL JOIN
		AddressMetadata receiverM)
		INNER JOIN
		Transfer rToc
	ON
		coldWallet.address = rToc.`to` AND
		receiver.address = rToc.`from`
	WHERE
		coldWallet.isDepositAddress = 0 AND
		coldWallet.isCappReceiver = 0 AND
		coldWallet.isCappSender = 0 AND
		coldWalletM.distinctInDegree < 10 AND
		coldWalletM.distinctOutDegree < 10 AND
		coldWalletM.involumeUSD > 1000 AND
		coldWalletM.outvolumeUSD > 1000 and
		receiver.isCappReceiver = 1
	GROUP BY receiver.address, coldWallet.address
	HAVING SUM(amountInUSDCurrent) > 0.05 * receiverM.outvolumeUSD
	) as rToC
INNER JOIN
	(SELECT
		coldWallet.address as cw,
		coldWallet.name as cw_n,
		sender.address as sd,
		sender.name as sd_n,
		SUM(amountInUSDCurrent) as sd_volume,
		SUM(amountInUSDCurrent) *1.0 / senderM.involumeUSD as sd_perc 
	FROM
		(Address coldWallet
		NATURAL JOIN
		AddressMetadata coldWalletM)
		INNER JOIN
		(Address sender
		NATURAL JOIN
		AddressMetadata senderM)
		INNER JOIN
		Transfer cToS
	ON
		coldWallet.address = cToS.`from` AND
		sender.address = cToS.`to`
	WHERE
		coldWallet.isDepositAddress = 0 AND
		coldWallet.isCappReceiver = 0 AND
		coldWallet.isCappSender = 0 AND
		coldWalletM.distinctInDegree < 10 AND
		coldWalletM.distinctOutDegree < 10 AND
		coldWalletM.involumeUSD > 1000 AND
		coldWalletM.outvolumeUSD > 1000 and
		sender.isCappSender = 1
	GROUP BY sender.address, coldWallet.address
	HAVING SUM(amountInUSDCurrent) > 0.05 * senderM.involumeUSD
	) as cToS
ON
	rToC.cw = cToS.cw)