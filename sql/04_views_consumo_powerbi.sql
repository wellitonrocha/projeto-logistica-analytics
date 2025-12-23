/* ============================================================
   PROJETO: LogisticaProjetoSQL
   CAMADA: Data Warehouse (DW)
   ARQUIVO: 04_dw_views.sql
   OBJETIVO:
     - Criar views de consumo analítico
     - Facilitar uso no Power BI
     - Abstrair joins e regras do modelo estrela
   ============================================================ */

USE LogisticaProjetoSQL;
GO

/* ============================================================
   VIEW: vw_FatoPedido
   DESCRIÇÃO:
     - View principal de pedidos (fato central)
     - Resolve datas via DimTempo
     - Simplifica consumo no Power BI
   ============================================================ */
CREATE OR ALTER VIEW dw.vw_FatoPedido AS
SELECT
    fp.SK_Pedido,
    fp.NroPedido,

    /* Datas (SK + data legível) */
    fp.SK_TempoPedido,
    dtPedido.DataReferencia   AS DataPedido,

    fp.SK_TempoCTE,
    dtCTE.DataReferencia      AS DataCTE,

    fp.SK_TempoPrevista,
    dtPrevista.DataReferencia AS DataPrevista,

    fp.SK_TempoEntrega,
    dtEntrega.DataReferencia  AS DataEntrega,

    /* Dimensões */
    fp.SK_CidadeDestino,
    fp.SK_Veiculo,
    fp.SK_Ocorrencia,

    /* Métricas */
    fp.ValorFrete,
    fp.PesoKg,
    fp.PesoCubo,
    fp.ValorMercadoria,
    fp.KMViagem

FROM dw.FatoPedido fp
LEFT JOIN dw.DimTempo dtPedido   ON fp.SK_TempoPedido   = dtPedido.SK_Tempo
LEFT JOIN dw.DimTempo dtCTE      ON fp.SK_TempoCTE      = dtCTE.SK_Tempo
LEFT JOIN dw.DimTempo dtPrevista ON fp.SK_TempoPrevista = dtPrevista.SK_Tempo
LEFT JOIN dw.DimTempo dtEntrega  ON fp.SK_TempoEntrega  = dtEntrega.SK_Tempo;
GO

/* ============================================================
   VIEW: vw_DimTempo
   DESCRIÇÃO:
     - Dimensão tempo simplificada
     - Usada para análises temporais
   ============================================================ */
CREATE OR ALTER VIEW dw.vw_DimTempo AS
SELECT
    SK_Tempo,
    DataReferencia,
    Ano,
    Mes,
    NomeMes,
    Trimestre,
    Dia,
    DiaSemana
FROM dw.DimTempo;
GO

/* ============================================================
   VIEW: vw_DimCidade
   DESCRIÇÃO:
     - Dimensão geográfica
   ============================================================ */
CREATE OR ALTER VIEW dw.vw_DimCidade AS
SELECT
    SK_Cidade,
    Regiao,
    UF,
    Cidade
FROM dw.DimCidade;
GO

/* ============================================================
   VIEW: vw_DimVeiculo
   DESCRIÇÃO:
     - Dimensão veículo (SCD Tipo 2)
     - Apenas atributos relevantes para análise
   ============================================================ */
CREATE OR ALTER VIEW dw.vw_DimVeiculo AS
SELECT
    SK_Veiculo,
    Placa,
    Carroceria,
    Filial,
    TipoVeiculo
FROM dw.DimVeiculo;
GO

/* ============================================================
   VIEW: vw_DimOcorrencia
   DESCRIÇÃO:
     - Dimensão de ocorrências / devoluções
   ============================================================ */
CREATE OR ALTER VIEW dw.vw_DimOcorrencia AS
SELECT
    SK_Ocorrencia,
    Motivo,
    Responsabilidade
FROM dw.DimOcorrencia;
GO

/* ============================================================
   VIEW: vw_FatoCusto
   DESCRIÇÃO:
     - Fato de custos operacionais
     - Granularidade: veículo + data
     - Corrige conceito (não é dimensão)
   ============================================================ */
CREATE OR ALTER VIEW dw.vw_FatoCusto AS
SELECT
    fc.SK_Custo,

    /* Chaves substitutas */
    dt.SK_Tempo,
    dv.SK_Veiculo,

    /* Data do evento */
    fc.DataCusto,

    /* Métricas financeiras */
    fc.ValorAbastecimento,
    fc.ValorManutencao,
    fc.CustoFixo,
    fc.CustoTotal,
    fc.KMPercorridos

FROM dw.FatoCusto fc
LEFT JOIN dw.DimTempo dt
       ON fc.DataCusto = dt.DataReferencia
LEFT JOIN dw.DimVeiculo dv
       ON fc.ID_Veiculo = dv.ID_Veiculo
      AND dv.CurrentFlag = 1;
GO

/* ============================================================
   VALIDAÇÕES BÁSICAS
   ============================================================ */

-- Volume de registros
SELECT COUNT(*) AS Total_FatoPedido FROM dw.FatoPedido;
SELECT COUNT(*) AS Total_ViewPedido FROM dw.vw_FatoPedido;
SELECT COUNT(*) AS Total_ODS_Pedido FROM ods.Pedido;

-- Validação financeira
SELECT SUM(ValorFrete) AS Total_Frete_Fato FROM dw.FatoPedido;
SELECT SUM(ValorFrete) AS Total_Frete_View FROM dw.vw_FatoPedido;
SELECT SUM(ValorFrete) AS Total_Frete_ODS  FROM ods.Pedido;

-- Qualidade das FKs (NULL checks)
SELECT
    COUNT(*) AS Total,
    SUM(CASE WHEN SK_TempoPedido IS NULL THEN 1 ELSE 0 END) AS TempoPedidoNull
FROM dw.FatoPedido;

SELECT
    COUNT(*) AS Total,
    SUM(CASE WHEN SK_Veiculo IS NULL THEN 1 ELSE 0 END) AS VeiculoNull
FROM dw.FatoPedido;

SELECT
    COUNT(*) AS Total,
    SUM(CASE WHEN SK_Ocorrencia IS NULL THEN 1 ELSE 0 END) AS OcorrenciaNull
FROM dw.FatoPedido;

SELECT
    COUNT(*) AS Total,
    SUM(CASE WHEN SK_CidadeDestino IS NULL THEN 1 ELSE 0 END) AS CidadeDestinoNull
FROM dw.FatoPedido;

-- Validação de intervalo de datas
SELECT
    MIN(DataPedido) AS MinData,
    MAX(DataPedido) AS MaxData
FROM dw.vw_FatoPedido;
GO

/* ============================================================
   TESTES ANALÍTICOS (SANITY CHECK)
   ============================================================ */

-- Pedidos por ano
SELECT
    dt.Ano,
    COUNT(*) AS QtdePedidos
FROM dw.vw_FatoPedido fp
JOIN dw.vw_DimTempo dt
  ON fp.SK_TempoPedido = dt.SK_Tempo
GROUP BY dt.Ano
ORDER BY dt.Ano;

-- Frete por UF
SELECT
    dc.UF,
    SUM(fp.ValorFrete) AS TotalFrete
FROM dw.vw_FatoPedido fp
JOIN dw.vw_DimCidade dc
  ON fp.SK_CidadeDestino = dc.SK_Cidade
GROUP BY dc.UF
ORDER BY TotalFrete DESC;
