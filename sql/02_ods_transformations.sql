/* =============================================================================
   PROJETO: Logística Analytics
   CAMADA: ODS (Operational Data Store)
   OBJETIVO:
     - Criar o schema ODS
     - Criar tabelas tratadas e normalizadas
     - Aplicar limpeza, padronização e deduplicação
     - Preparar os dados para a modelagem dimensional (DW)

   PRINCÍPIOS:
     - ODS contém dados confiáveis e consistentes
     - Regras técnicas aplicadas (tipos, limpeza, FKs)
     - Regras de negócio ainda mínimas (foco estrutural)

   AUTOR: [Seu Nome]
   DATA: [Opcional]
============================================================================= */

-------------------------------------------------------------------------------
-- PASSO 1 — CRIAÇÃO DO SCHEMA ODS
-------------------------------------------------------------------------------

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'ods')
BEGIN
    EXEC ('CREATE SCHEMA ods');
END;
GO


-------------------------------------------------------------------------------
-- PASSO 2 — CRIAÇÃO DAS TABELAS ODS
-------------------------------------------------------------------------------

/* -----------------------------
   ODS.Cidade
------------------------------ */
CREATE TABLE ods.Cidade (
    idCidade INT IDENTITY(1,1) PRIMARY KEY,
    Regiao   VARCHAR(50),
    UF       VARCHAR(2),
    Cidade   VARCHAR(100)
);
GO


/* -----------------------------
   ODS.Ocorrencia
------------------------------ */
CREATE TABLE ods.Ocorrencia (
    idOcorrencia     INT PRIMARY KEY,
    Motivo           VARCHAR(200),
    Responsabilidade VARCHAR(100)
);
GO


/* -----------------------------
   ODS.Veiculo
------------------------------ */
CREATE TABLE ods.Veiculo (
    ID_Veiculo  INT PRIMARY KEY,
    Placa       VARCHAR(20),
    Carroceria  VARCHAR(50),
    Filial      VARCHAR(50),
    TipoVeiculo VARCHAR(50)
);
GO


/* -----------------------------
   ODS.Custos
------------------------------ */
CREATE TABLE ods.Custos (
    ID                 INT IDENTITY(1,1) PRIMARY KEY,
    Data               DATE,
    ID_Veiculo         INT,
    ValorAbastecimento DECIMAL(18,2),
    CustoFixo          DECIMAL(18,2),
    ValorManutencao    DECIMAL(18,2),
    CustoTotal         DECIMAL(18,2),
    KMPercorridos      INT,
    CONSTRAINT FK_Custos_Veiculo
        FOREIGN KEY (ID_Veiculo) REFERENCES ods.Veiculo(ID_Veiculo)
);
GO


/* -----------------------------
   ODS.Pedido
------------------------------ */
CREATE TABLE ods.Pedido (
    NroPedido       VARCHAR(50) PRIMARY KEY,
    Regiao          VARCHAR(50),
    Estado          VARCHAR(10),
    Cidade          VARCHAR(100),

    DataPedido      DATE,
    DataCTE         DATE,
    DataPrevista    DATE,
    DataEntrega     DATE,

    ID_Veiculo      INT,
    ValorFrete      DECIMAL(18,2),
    PesoKg          DECIMAL(18,2),
    PesoCubo        DECIMAL(18,2),
    ValorMercadoria DECIMAL(18,2),
    KMViagem        INT,

    idOcorrencia    INT,

    CONSTRAINT FK_Pedido_Ocorrencia
        FOREIGN KEY (idOcorrencia) REFERENCES ods.Ocorrencia(idOcorrencia),

    CONSTRAINT FK_Pedido_Veiculo
        FOREIGN KEY (ID_Veiculo) REFERENCES ods.Veiculo(ID_Veiculo)
);
GO


-------------------------------------------------------------------------------
-- PASSO 3 — CARGA DAS TABELAS DIMENSIONAIS BÁSICAS (ODS)
-------------------------------------------------------------------------------

/* -----------------------------
   Carga: ODS.Cidade
   Origem: STG.Cidade
   Regra:
     Regiao / UF / Cidade derivadas de string estruturada
------------------------------ */
INSERT INTO ods.Cidade (Regiao, UF, Cidade)
SELECT  
    PARSENAME(REPLACE(idCidade, '/', '.'), 2) AS Regiao,
    PARSENAME(REPLACE(PARSENAME(REPLACE(idCidade, '/', '.'), 1), '*', '.'), 2) AS UF,
    PARSENAME(REPLACE(PARSENAME(REPLACE(idCidade, '/', '.'), 1), '*', '.'), 1) AS Cidade
FROM stg.Cidade;
GO


/* -----------------------------
   Carga: ODS.Ocorrencia
------------------------------ */
INSERT INTO ods.Ocorrencia (idOcorrencia, Motivo, Responsabilidade)
SELECT DISTINCT
    CAST(idOcorrencia AS INT),
    Motivo,
    Responsabilidade
FROM stg.Ocorrencia;
GO


/* -----------------------------
   Carga: ODS.Veiculo
------------------------------ */
INSERT INTO ods.Veiculo (ID_Veiculo, Placa, Carroceria, Filial, TipoVeiculo)
SELECT DISTINCT
    CAST(ID_Veiculo AS INT),
    Placa,
    Carroceria,
    Filial,
    TipoVeiculo
FROM stg.Veiculo;
GO


-------------------------------------------------------------------------------
-- PASSO 4 — TRATAMENTO AVANÇADO E CARGA DA ODS.PEDIDO
-------------------------------------------------------------------------------

/* =============================================================================
   CTE 1 — DadosLimpos
   Objetivos:
     - Limpeza profunda de caracteres inválidos
     - Conversão segura de tipos
     - Padronização do delimitador da cidade
     - Deduplicação por NroPedido
============================================================================= */
WITH DadosLimpos AS (
    SELECT
        P.NroPedido,

        -- Limpeza crítica da coluna de cidade
        REPLACE(
            REPLACE(
                REPLACE(
                    REPLACE(TRIM(P.idCidade), CHAR(10), ''),
                CHAR(13), ''),
            CHAR(160), ''),
        '*', '/') AS idCidade_Limpa,

        P.DataPedido,
        P.DataCTE,
        P.DataPrevista,
        P.DataEntrega,

        -- Conversões DECIMAL seguras
        CASE WHEN ISNUMERIC(REPLACE(P.ValorFrete, ',', '.')) = 1
             THEN CAST(REPLACE(P.ValorFrete, ',', '.') AS DECIMAL(18,2)) END AS ValorFrete,

        CASE WHEN ISNUMERIC(REPLACE(P.PesoKG, ',', '.')) = 1
             THEN CAST(REPLACE(P.PesoKG, ',', '.') AS DECIMAL(18,2)) END AS PesoKg,

        CASE WHEN ISNUMERIC(REPLACE(P.PesoCubo, ',', '.')) = 1
             THEN CAST(REPLACE(P.PesoCubo, ',', '.') AS DECIMAL(18,2)) END AS PesoCubo,

        CASE WHEN ISNUMERIC(REPLACE(P.ValorMercadoria, ',', '.')) = 1
             THEN CAST(REPLACE(P.ValorMercadoria, ',', '.') AS DECIMAL(18,2)) END AS ValorMercadoria,

        -- Conversões INT seguras
        CASE WHEN ISNUMERIC(P.ID_Veiculo) = 1 THEN CAST(P.ID_Veiculo AS INT) END AS ID_Veiculo,
        CASE WHEN ISNUMERIC(P.KMViagem) = 1 THEN CAST(P.KMViagem AS INT) END AS KMViagem,
        CASE WHEN ISNUMERIC(P.OcorrenciaDevolucao) = 1 THEN CAST(P.OcorrenciaDevolucao AS INT) END AS idOcorrencia,

        ROW_NUMBER() OVER (PARTITION BY P.NroPedido ORDER BY P.DataPedido) AS rn
    FROM stg.Pedido P
),

/* =============================================================================
   CTE 2 — DadosSplitados
   Objetivo:
     - Separar Região / Estado / Cidade a partir da string limpa
============================================================================= */
DadosSplitados AS (
    SELECT
        DL.*,
        MAX(CASE WHEN S.pos = 1 THEN S.value END) AS Regiao_Split,
        MAX(CASE WHEN S.pos = 2 THEN S.value END) AS Estado_Split,
        MAX(CASE WHEN S.pos = 3 THEN S.value END) AS Cidade_Split
    FROM DadosLimpos DL
    CROSS APPLY (
        SELECT value, ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS pos
        FROM STRING_SPLIT(DL.idCidade_Limpa, '/')
    ) S
    WHERE DL.rn = 1
    GROUP BY
        DL.NroPedido, DL.idCidade_Limpa, DL.DataPedido, DL.DataCTE,
        DL.DataPrevista, DL.DataEntrega, DL.ID_Veiculo,
        DL.ValorFrete, DL.PesoKg, DL.PesoCubo,
        DL.ValorMercadoria, DL.KMViagem, DL.idOcorrencia, DL.rn
)

-------------------------------------------------------------------------------
-- INSERÇÃO FINAL NA ODS.PEDIDO
-------------------------------------------------------------------------------
INSERT INTO ods.Pedido (
    NroPedido, Regiao, Estado, Cidade,
    DataPedido, DataCTE, DataPrevista, DataEntrega,
    ID_Veiculo, ValorFrete, PesoKg, PesoCubo,
    ValorMercadoria, KMViagem, idOcorrencia
)
SELECT
    NroPedido,
    COALESCE(Regiao_Split, ''),
    COALESCE(Estado_Split, ''),
    COALESCE(Cidade_Split, ''),
    DataPedido, DataCTE, DataPrevista, DataEntrega,
    ID_Veiculo, ValorFrete, PesoKg, PesoCubo,
    ValorMercadoria, KMViagem, idOcorrencia
FROM DadosSplitados;
GO
