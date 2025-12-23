# 📘 Dicionário de Dados  
**Projeto: Análise de Custos e Pedidos Logísticos**

Este documento descreve as estruturas de dados utilizadas no projeto, considerando o **Data Warehouse em SQL Server (schema `dw`)** e as **views analíticas consumidas no Power BI**.

O modelo segue o padrão **Star Schema**, com tabelas fato e dimensões, garantindo organização, performance e escalabilidade analítica.

---

## 🧱 Visão Geral do Modelo

- **Dimensoes**
  - Tempo
  - Cidade
  - Veículo
  - Ocorrência

- **Fatos**
  - Pedido
  - Custo

- **Consumo Analítico**
  - Power BI acessa exclusivamente **Views**, não tabelas físicas.

---

## ⏱️ Dimensão Tempo — `dw.vw_DimTempo`

Centraliza todas as análises temporais do projeto.

| Campo | Tipo | Descrição |
|------|------|----------|
| SK_Tempo | INT | Chave substituta da dimensão tempo |
| DataReferencia | DATE | Data completa |
| Ano | INT | Ano |
| Mes | INT | Mês numérico (1–12) |
| NomeMes | VARCHAR | Nome do mês |
| Trimestre | INT | Trimestre do ano |
| Dia | INT | Dia do mês |
| DiaSemana | INT | Dia da semana (numérico) |
| NomeDiaSemana | VARCHAR | Nome do dia da semana |

**Uso Analítico**
- Filtros de Ano e Mês
- Séries temporais
- Comparações Year Over Year (YoY)

---

## 🌍 Dimensão Cidade — `dw.vw_DimCidade`

Representa o destino geográfico dos pedidos.

| Campo | Tipo | Descrição |
|------|------|----------|
| SK_Cidade | INT | Chave substituta da cidade |
| Cidade | VARCHAR | Nome da cidade |
| UF | VARCHAR(2) | Unidade Federativa |
| Regiao | VARCHAR | Região geográfica |

**Uso Analítico**
- Mapas
- Análises por UF, cidade e região
- Indicadores logísticos geográficos

---

## 🚚 Dimensão Veículo — `dw.vw_DimVeiculo`

Caracteriza os veículos utilizados nas operações logísticas.

| Campo | Tipo | Descrição |
|------|------|----------|
| SK_Veiculo | INT | Chave substituta do veículo |
| Placa | VARCHAR | Placa do veículo |
| Carroceria | VARCHAR | Tipo de carroceria |
| Filial | VARCHAR | Filial responsável |
| TipoVeiculo | VARCHAR | Categoria do veículo |

**Uso Analítico**
- Custos por tipo de veículo
- Performance por filial
- Análise de margem por frota

---

## ⚠️ View de Ocorrências — `dw.vw_Ocorrencias`

View analítica responsável por consolidar e classificar os pedidos com base nos **motivos e responsabilidades de ocorrência**, facilitando análises de falhas operacionais e causas de não conformidade.

Essa view já entrega os dados **pré-agregados**, otimizando o consumo no Power BI.

### Estrutura da View

| Campo | Tipo | Descrição |
|------|------|----------|
| idOcorrencia | INT | Código legado da ocorrência |
| Motivo | VARCHAR | Motivo da ocorrência (ex: atraso, avaria, devolução) |
| Responsabilidade | VARCHAR | Responsável pela ocorrência |
| TotalPedidos | INT | Quantidade de pedidos associados à ocorrência |

### Regra de Negócio

- `idOcorrencia = 1` → Pedido entregue **sem ocorrência**
- `idOcorrencia <> 1` → Pedido entregue **com ocorrência**
- A métrica `TotalPedidos` é calculada via `COUNT(SK_Pedido)` na Fato Pedido

### Uso Analítico

- Análise de pedidos com ocorrência
- Ranking de motivos de falha
- Avaliação de responsabilidade operacional
- Apoio direto aos indicadores:
  - **In Full**
  - **OTIF**
  - **Pedidos com Ocorrência**

### Observações Técnicas

- View derivada de `dw.FatoPedido` + `dw.DimOcorrencia`
- Pré-agregação reduz carga de cálculo no Power BI
- Facilita análises por motivo e responsabilidade sem DAX complexo

---

## 📦 Fato Pedido — `dw.vw_FatoPedido`

Tabela fato principal, contendo os eventos de pedidos logísticos.

| Campo | Tipo | Descrição |
|------|------|----------|
| SK_Pedido | BIGINT | Chave substituta do pedido |
| NroPedido | VARCHAR | Número do pedido |
| SK_TempoPedido | INT | FK para data do pedido |
| DataPedido | DATE | Data do pedido |
| SK_TempoCTE | INT | FK para data do CTE |
| DataCTE | DATE | Data do CTE |
| SK_TempoPrevista | INT | FK para data prevista |
| DataPrevista | DATE | Data prevista de entrega |
| SK_TempoEntrega | INT | FK para data de entrega |
| DataEntrega | DATE | Data efetiva de entrega |
| SK_CidadeDestino | INT | Cidade de destino |
| SK_Veiculo | INT | Veículo utilizado |
| SK_Ocorrencia | INT | Ocorrência associada |
| ValorFrete | DECIMAL | Receita do frete |
| PesoKg | DECIMAL | Peso em quilogramas |
| PesoCubo | DECIMAL | Peso cubado |
| ValorMercadoria | DECIMAL | Valor da mercadoria |
| KMViagem | INT | Quilometragem da viagem |

**Uso Analítico**
- Receita bruta
- Quantidade de pedidos
- OTIF, On Time e In Full
- Ticket médio
- Order Cycle Time

---

## 💰 Fato Custo — `dw.vw_FatoCusto`

Armazena os custos operacionais relacionados à frota.

| Campo | Tipo | Descrição |
|------|------|----------|
| SK_Custo | INT | Chave substituta do custo |
| Data | DATE | Data do custo |
| ID_Veiculo | INT | Identificador do veículo |
| ValorAbastecimento | DECIMAL | Custo com combustível |
| ValorManutencao | DECIMAL | Custo de manutenção |
| CustoFixo | DECIMAL | Custos fixos |
| CustoTotal | DECIMAL | Soma total dos custos |
| KMPercorridos | INT | Quilometragem percorrida |

**Uso Analítico**
- Custo total
- Margem operacional
- Rentabilidade por veículo
- Comparação custo x receita

---

## 🔗 Relacionamentos no Power BI

- `vw_FatoPedido[DataPedido]` → `vw_DimTempo[DataBase]`
- `vw_FatoPedido[SK_CidadeDestino]` → `vw_DimCidade[SK_Cidade]`
- `vw_FatoPedido[SK_Veiculo]` → `vw_DimVeiculo[SK_Veiculo]`
- `vw_FatoPedido[SK_Ocorrencia]` → `vw_Ocorrencia[ID_Ocorrencia]`
- `vw_FatoCusto[ID_Veiculo]` → `vw_DimVeiculo[ID_Veiculo]`
- `vw_FatoCusto[Data]` → `vw_DimTempo[DataBase]`

---

## 📝 Observações Finais

- O Power BI consome apenas **Views**, garantindo governança e desacoplamento do modelo físico
- O modelo suporta expansão para novas métricas e fatos
- Estrutura preparada para análises históricas e comparativas

---
