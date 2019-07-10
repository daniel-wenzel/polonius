UPDATE AddressMetadata
SET isMixer = 0, isConcentrator = 0, isDiluter = 0
WHERE
    distinctDegree >= 100;

UPDATE AddressMetadata
SET isDiluter = 1
WHERE
    distinctDegree >= 100 and 1.0 * distinctOutDegree / (distinctInDegree + distinctOutDegree) > 0.9;

UPDATE AddressMetadata
SET isConcentrator = 1
WHERE
    distinctDegree >= 100 and 1.0 * distinctInDegree / (distinctInDegree + distinctOutDegree) > 0.9;

UPDATE AddressMetadata
SET isMixer = 1
WHERE
    distinctDegree >= 100 and isDiluter = 0 and isConcentrator = 0;

UPDATE Transfer SET isFromMixer = 1
WHERE `from` in (SELECT address from AddressMetadata WHERE isMixer = 1);

UPDATE Transfer SET isToMixer = 1
WHERE `to` in (SELECT address from AddressMetadata WHERE isMixer = 1);

UPDATE Transfer SET isFromDiluter = 1
WHERE `from` in (SELECT address from AddressMetadata WHERE isDiluter = 1);

UPDATE Transfer SET isToDiluter = 1
WHERE `to` in (SELECT address from AddressMetadata WHERE isDiluter = 1);

UPDATE Transfer SET isFromConcentrator = 1
WHERE `from` in (SELECT address from AddressMetadata WHERE isConcentrator = 1);

UPDATE Transfer SET isToConcentrator = 1
WHERE `to` in (SELECT address from AddressMetadata WHERE isConcentrator = 1);