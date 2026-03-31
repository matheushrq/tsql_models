SELECT 
    NomeOriginal,
    UPPER(LEFT(NomeOriginal, 1)) + LOWER(SUBSTRING(NomeOriginal, 2, LEN(NomeOriginal))) AS NomeFormatado
FROM 
    (SELECT 'jOÃO sILVA' AS NomeOriginal) AS TabelaExemplo;
-- Resultado: João silva