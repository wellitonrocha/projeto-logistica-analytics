/* =============================================================================
   PROJETO: Logística Analytics
   CAMADA: STAGING (STG)
   OBJETIVO:
     - Criar o banco de dados do projeto
     - Criar o schema STG
     - Criar tabelas de dados brutos
     - Carregar arquivos CSV via BULK INSERT

   OBSERVAÇÕES:
     - A camada STG não aplica regras de negócio
     - Tipos e estruturas refletem fielmente os arquivos de origem
     - Dados podem conter inconsistências (tratadas nas camadas seguintes)

   AUTOR: [Welliton da Rocha]
============================================================================= */

-------------------------------------------------------------------------------
-- PASSO 1 — CRIAÇÃO DO BANCO DE DADOS
-------------------------------------------------------------------------------

IF DB_ID('LogisticaProjetoSQL') IS NULL
BEGIN
    CREATE DATABASE LogisticaProjetoSQL;
END;
GO

USE LogisticaProjetoSQL;
GO


-------------------------------------------------------------------------------
-- PASSO 2 — CRIAÇÃO DO SCHEMA STAGING
-------------------------------------------------------------------------------

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'stg')
BEGIN
    EXEC ('CREATE SCHEMA stg');
END;
GO


-------------------------------------------------------------------------------
-- PASSO 3 — CRIAÇÃO DAS TABELAS STAGING
-------------------------------------------------------------------------------

/* -----------------------------
   STG.Cidade
   Fonte: Cidade.csv
   Exemplo de valor:
     Sudeste/SP*Campinas
------------------------------ */
CREATE TABLE stg.Cidade (
    idCidade VARCHAR(100) NULL
);
GO


/* -----------------------------
   STG.Custos
   Fonte: Custos.csv
------------------------------ */
CREATE TABLE stg.Custos (
    Data                DATE          NULL,
    ValorAbastecimento  DECIMAL(10,4) NULL,
    ValorManutencao     DECIMAL(10,4) NULL,
    CustoFixo           DECIMAL(10,2) NULL,
    CustoTotal          DECIMAL(10,4) NULL,
    ID_Veiculo          INT           NULL,
    KMPercorridos       INT           NULL
);
GO


/* -----------------------------
   STG.Ocorrencia
   Fonte: Ocorrencia.csv
------------------------------ */
CREATE TABLE stg.Ocorrencia (
    idOcorrencia     INT           NULL,
    Motivo           VARCHAR(200)  NULL,
    Responsabilidade VARCHAR(100)  NULL
);
GO


/* -----------------------------
   STG.Pedido
   Fonte: Pedidos.csv
------------------------------ */
CREATE TABLE stg.Pedido (
    NroPedido           VARCHAR(50)   NULL,
    idCidade            VARCHAR(100)  NULL,
    DataPedido          DATE          NULL,
    DataCTE             DATE          NULL,
    DataPrevista        DATE          NULL,
    DataEntrega         DATE          NULL,
    ID_Veiculo          INT           NULL,
    ValorFrete          DECIMAL(10,2) NULL,
    PesoKG              DECIMAL(12,2) NULL,
    PesoCubo            DECIMAL(12,3) NULL,
    OcorrenciaDevolucao INT           NULL,
    ValorMercadoria     DECIMAL(12,2) NULL,
    KMViagem            INT           NULL
);
GO


/* -----------------------------
   STG.Veiculo
   Fonte: Veiculo.csv
------------------------------ */
CREATE TABLE stg.Veiculo (
    ID_Veiculo  INT         NULL,
    Placa       VARCHAR(10) NULL,
    Carroceria  VARCHAR(50) NULL,
    Filial      VARCHAR(50) NULL,
    TipoVeiculo VARCHAR(50) NULL
);
GO


-------------------------------------------------------------------------------
-- PASSO 4 — HABILITAÇÃO DE RECURSOS PARA BULK INSERT
-------------------------------------------------------------------------------

EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
GO

EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
GO


-------------------------------------------------------------------------------
-- PASSO 5 — CARGA DOS DADOS (BULK INSERT)
-- OBS: Ajustar os caminhos conforme o ambiente local
-------------------------------------------------------------------------------

/* -----------------------------
   Carga: Cidade
------------------------------ */
BULK INSERT stg.Cidade
FROM 'C:\Users\Dayane\Desktop\OneDrive\Projetos\LogisticaProjetoSQL\Tabelas\Cidade.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '0x0A',
    CODEPAGE = '65001',
    DATAFILETYPE = 'char'
);
GO


/* -----------------------------
   Carga: Custos
------------------------------ */
BULK INSERT stg.Custos
FROM 'C:\Users\Dayane\Desktop\OneDrive\Projetos\LogisticaProjetoSQL\Tabelas\Custos.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '\n',
    TABLOCK
);
GO


/* -----------------------------
   Carga: Ocorrencia
------------------------------ */
BULK INSERT stg.Ocorrencia
FROM 'C:\Users\Dayane\Desktop\OneDrive\Projetos\LogisticaProjetoSQL\Tabelas\Ocorrencia.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001',
    DATAFILETYPE = 'char'
);
GO


/* -----------------------------
   Carga: Veiculo
------------------------------ */
BULK INSERT stg.Veiculo
FROM 'C:\Users\Dayane\Desktop\OneDrive\Projetos\LogisticaProjetoSQL\Tabelas\Veiculo.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001',
    DATAFILETYPE = 'char'
);
GO


/* -----------------------------
   Carga: Pedido
------------------------------ */
BULK INSERT stg.Pedido
FROM 'C:\Users\Dayane\Desktop\OneDrive\Projetos\LogisticaProjetoSQL\Tabelas\Pedidos.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '0x0A',
    CODEPAGE = '65001',
    DATAFILETYPE = 'char'
);
GO
