SELECT DISTINCT token
FROM ETransfer
/*WHERE token not in (SELECT DISTINCT token from Price)*/;