/* =============================================================================
   PROJETO: Logística Analytics
   CAMADA: DW - Data Warehouse (Modelo Estrela)
   OBJETIVO:
     - Criar dimensões e fatos
     - Popular dimensões com dados tratados (ODS)
     - Construir fatos analíticos prontos para BI

   OBSERVAÇÃO IMPORTANTE:
     - Custos são modelados como FATO (FatoCusto), não dimensão.

   AUTOR: [Seu Nome]
============================================================================= */

-------------------------------------------------------------------------------
-- PASSO 1 — CRIAÇÃO DO SCHEMA DW
-------------------------------------------------------------------------------

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'dw')
BEGIN
    EXEC ('CREATE SCHEMA dw');
END;
GO


-------------------------------------------------------------------------------
-- PASSO 2 — CRIAÇÃO DAS DIMENSÕES
-------------------------------------------------------------------------------

/* -----------------------------
   Dimensão Tempo
------------------------------ */
CREATE TABLE dw.DimTempo (
    SK_Tempo INT IDENTITY(1,1) PRIMARY KEY,
    DataReferencia DATE NOT NULL UNIQUE,
    Ano INT NOT NULL,
    Mes INT NOT NULL,
    Dia INT NOT NULL,
    Trimestre INT NOT NULL,
    SemanaAno INT NOT NULL,
    DiaSemana INT NOT NULL,
    NomeMes VARCHAR(20),
    IsFeriado BIT DEFAULT 0
);
GO


/* -----------------------------
   Dimensão Cidade
------------------------------ */
CREATE TABLE dw.DimCidade (
    SK_Cidade INT IDENTITY(1,1) PRIMARY KEY,
    idCidade INT NULL,                 -- legado ODS
    Cidade VARCHAR(200) NOT NULL,
    UF VARCHAR(2) NULL,
    Regiao VARCHAR(50) NULL,
    SourceFlag VARCHAR(20) NULL,       -- ODS_Cidade | ODS_Pedido
    DataCarga DATETIME DEFAULT GETDATE()
);
GO


/* -----------------------------
   Dimensão Veículo (SCD Tipo 2)
------------------------------ */
CREATE TABLE dw.DimVeiculo (
    SK_Veiculo INT IDENTITY(1,1) PRIMARY KEY,
    ID_Veiculo INT NULL,               -- chave de negócio
    Placa VARCHAR(20),
    Carroceria VARCHAR(50),
    Filial VARCHAR(50),
    TipoVeiculo VARCHAR(50),
    DataInicioVigencia DATE,
    DataFimVigencia DATE,
    CurrentFlag BIT DEFAULT 1,
    DataCarga DATETIME DEFAULT GETDATE()
);
GO


/* -----------------------------
   Dimensão Ocorrência
------------------------------ */
CREATE TABLE dw.DimOcorrencia (
    SK_Ocorrencia INT IDENTITY(1,1) PRIMARY KEY,
    idOcorrencia INT NOT NULL,
    Motivo VARCHAR(200),
    Responsabilidade VARCHAR(100),
    DataCarga DATETIME DEFAULT GETDATE()
);
GO


-------------------------------------------------------------------------------
-- PASSO 3 — CRIAÇÃO DOS FATOS
-------------------------------------------------------------------------------

/* -----------------------------
   Fato Custo (correção conceitual)
------------------------------ */
CREATE TABLE dw.FatoCusto (
    SK_Custo BIGINT IDENTITY(1,1) PRIMARY KEY,
    ID_Veiculo INT,
    DataCusto DATE,
    ValorAbastecimento DECIMAL(18,2),
    CustoFixo DECIMAL(18,2),
    ValorManutencao DECIMAL(18,2),
    CustoTotal DECIMAL(18,2),
    KMPercorridos INT,
    DataCarga DATETIME DEFAULT GETDATE()
);
GO


/* -----------------------------
   Fato Pedido
------------------------------ */
CREATE TABLE dw.FatoPedido (
    SK_Pedido BIGINT IDENTITY(1,1) PRIMARY KEY,
    NroPedido VARCHAR(50) NOT NULL UNIQUE,

    SK_TempoPedido INT,
    SK_TempoCTE INT,
    SK_TempoPrevista INT,
    SK_TempoEntrega INT,

    SK_CidadeDestino INT,
    SK_Veiculo INT,
    SK_Ocorrencia INT,
    SK_Custo BIGINT,

    Regiao VARCHAR(50),
    Estado VARCHAR(10),

    ValorFrete DECIMAL(18,2),
    PesoKg DECIMAL(18,2),
    PesoCubo DECIMAL(18,2),
    ValorMercadoria DECIMAL(18,2),
    KMViagem INT,

    FlagDevolucao BIT,
    DataCarga DATETIME DEFAULT GETDATE()
);
GO


-------------------------------------------------------------------------------
-- PASSO 4 — ÍNDICES PARA PERFORMANCE
-------------------------------------------------------------------------------

CREATE INDEX IX_FatoPedido_TempoPedido ON dw.FatoPedido(SK_TempoPedido);
CREATE INDEX IX_FatoPedido_Cidade ON dw.FatoPedido(SK_CidadeDestino);
CREATE INDEX IX_FatoPedido_Veiculo ON dw.FatoPedido(SK_Veiculo);
GO


-------------------------------------------------------------------------------
-- PASSO 5 — POPULAR DIMENSÃO TEMPO
-------------------------------------------------------------------------------

DECLARE @DataInicio DATE = '2017-01-01';
DECLARE @DataFim DATE = '2025-12-31';

;WITH Datas AS (
    SELECT @DataInicio AS DataRef
    UNION ALL
    SELECT DATEADD(DAY, 1, DataRef)
    FROM Datas
    WHERE DataRef < @DataFim
)
INSERT INTO dw.DimTempo (
    DataReferencia, Ano, Mes, Dia, Trimestre,
    SemanaAno, DiaSemana, NomeMes
)
SELECT
    DataRef,
    YEAR(DataRef),
    MONTH(DataRef),
    DAY(DataRef),
    DATEPART(QUARTER, DataRef),
    DATEPART(WEEK, DataRef),
    DATEPART(WEEKDAY, DataRef),
    DATENAME(MONTH, DataRef)
FROM Datas
OPTION (MAXRECURSION 0);
GO


-------------------------------------------------------------------------------
-- PASSO 6 — POPULAR DIMENSÕES
-------------------------------------------------------------------------------

/* DimCidade */
MERGE dw.DimCidade AS T
USING (
    SELECT idCidade, Cidade, UF, Regiao, 'ODS_Cidade' AS SourceFlag
    FROM ods.Cidade
) S
ON T.idCidade = S.idCidade
WHEN MATCHED THEN
    UPDATE SET Cidade = S.Cidade, UF = S.UF, Regiao = S.Regiao, DataCarga = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (idCidade, Cidade, UF, Regiao, SourceFlag)
    VALUES (S.idCidade, S.Cidade, S.UF, S.Regiao, S.SourceFlag);


/* DimOcorrencia */
MERGE dw.DimOcorrencia AS T
USING ods.Ocorrencia S
ON T.idOcorrencia = S.idOcorrencia
WHEN MATCHED THEN
    UPDATE SET Motivo = S.Motivo, Responsabilidade = S.Responsabilidade, DataCarga = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (idOcorrencia, Motivo, Responsabilidade)
    VALUES (S.idOcorrencia, S.Motivo, S.Responsabilidade);


-------------------------------------------------------------------------------
-- PASSO 7 — DIMENSÃO VEÍCULO (SCD TIPO 2)
-------------------------------------------------------------------------------

BEGIN TRAN;

;WITH Src AS (
    SELECT ID_Veiculo, Placa, Carroceria, Filial, TipoVeiculo
    FROM ods.Veiculo
),
Changes AS (
    SELECT s.*
    FROM Src s
    LEFT JOIN dw.DimVeiculo d
        ON d.ID_Veiculo = s.ID_Veiculo AND d.CurrentFlag = 1
    WHERE ISNULL(s.Placa,'') <> ISNULL(d.Placa,'')
       OR ISNULL(s.Filial,'') <> ISNULL(d.Filial,'')
)
UPDATE dw.DimVeiculo
SET DataFimVigencia = CAST(GETDATE() AS DATE),
    CurrentFlag = 0
WHERE ID_Veiculo IN (SELECT ID_Veiculo FROM Changes)
  AND CurrentFlag = 1;

INSERT INTO dw.DimVeiculo
(ID_Veiculo, Placa, Carroceria, Filial, TipoVeiculo, DataInicioVigencia)
SELECT
    ID_Veiculo, Placa, Carroceria, Filial, TipoVeiculo, CAST(GETDATE() AS DATE)
FROM Changes;

COMMIT;


-------------------------------------------------------------------------------
-- PASSO 8 — POPULAR FATO CUSTO
-------------------------------------------------------------------------------

INSERT INTO dw.FatoCusto
(ID_Veiculo, DataCusto, ValorAbastecimento, CustoFixo, ValorManutencao, CustoTotal, KMPercorridos)
SELECT
    ID_Veiculo,
    Data,
    ValorAbastecimento,
    CustoFixo,
    ValorManutencao,
    CustoTotal,
    KMPercorridos
FROM ods.Custos;


-------------------------------------------------------------------------------
-- PASSO 9 — POPULAR FATO PEDIDO
-------------------------------------------------------------------------------

INSERT INTO dw.FatoPedido
(
    NroPedido, SK_TempoPedido, SK_TempoCTE, SK_TempoPrevista, SK_TempoEntrega,
    SK_CidadeDestino, SK_Veiculo, SK_Ocorrencia, SK_Custo,
    Regiao, Estado, ValorFrete, PesoKg, PesoCubo, ValorMercadoria, KMViagem,
    FlagDevolucao
)
SELECT
    p.NroPedido,
    t1.SK_Tempo,
    t2.SK_Tempo,
    t3.SK_Tempo,
    t4.SK_Tempo,
    dc.SK_Cidade,
    dv.SK_Veiculo,
    do.SK_Ocorrencia,
    fc.SK_Custo,
    p.Regiao,
    p.Estado,
    p.ValorFrete,
    p.PesoKg,
    p.PesoCubo,
    p.ValorMercadoria,
    p.KMViagem,
    CASE WHEN p.idOcorrencia IS NOT NULL AND p.idOcorrencia <> 0 THEN 1 ELSE 0 END
FROM ods.Pedido p
LEFT JOIN dw.DimTempo t1 ON t1.DataReferencia = p.DataPedido
LEFT JOIN dw.DimTempo t2 ON t2.DataReferencia = p.DataCTE
LEFT JOIN dw.DimTempo t3 ON t3.DataReferencia = p.DataPrevista
LEFT JOIN dw.DimTempo t4 ON t4.DataReferencia = p.DataEntrega
LEFT JOIN dw.DimCidade dc ON dc.Cidade = p.Cidade
LEFT JOIN dw.DimVeiculo dv ON dv.ID_Veiculo = p.ID_Veiculo AND dv.CurrentFlag = 1
LEFT JOIN dw.DimOcorrencia do ON do.idOcorrencia = p.idOcorrencia
LEFT JOIN dw.FatoCusto fc ON fc.ID_Veiculo = p.ID_Veiculo AND fc.DataCusto = p.DataPedido
WHERE NOT EXISTS (
    SELECT 1 FROM dw.FatoPedido f WHERE f.NroPedido = p.NroPedido
);
GO
