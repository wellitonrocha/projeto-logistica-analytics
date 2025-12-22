# 📦 projeto-logistica-analytics

Projeto de **Analytics Logístico** desenvolvido com foco em **SQL avançado**, engenharia de dados e análise de performance operacional e financeira, utilizando uma arquitetura completa de **Data Warehouse** e visualização no **Power BI**.

---

## 📌 1. Visão Geral do Projeto

Operações logísticas geram grandes volumes de dados relacionados a **pedidos, custos de frota, prazos de entrega e ocorrências operacionais**. Sem um modelo de dados bem estruturado e regras claras de negócio, esses dados não se convertem em informação confiável para tomada de decisão.

O **projeto-logistica-analytics** foi desenvolvido para simular um **cenário corporativo real**, no qual dados operacionais são tratados, organizados e disponibilizados para análises estratégicas.  

O projeto tem como **pilar central o uso avançado de SQL**, aplicado de forma consistente em todo o pipeline de dados. Ao mesmo tempo, apresenta uma visão **end-to-end**, cobrindo engenharia de dados, modelagem dimensional, qualidade, governança e visualização analítica no Power BI.

🎯 **Objetivo principal:** transformar dados operacionais brutos em **informação confiável, analítica e acionável**.

---

## 🎯 2. Objetivos do Projeto

### 🔧 Objetivos Técnicos
- Demonstrar domínio avançado de **SQL Server**
- Construir um pipeline de dados organizado em múltiplas camadas
- Aplicar boas práticas de modelagem relacional e dimensional
- Garantir integridade, consistência e rastreabilidade dos dados

### 📊 Objetivos Analíticos
- Criar métricas logísticas padronizadas (OTIF, On Time, In Full)
- Analisar custos, receita e rentabilidade da operação
- Avaliar desempenho por filial, tipo de veículo e região
- Permitir análises temporais e geográficas confiáveis

### 💼 Objetivos de Negócio
- Apoiar decisões sobre eficiência operacional
- Identificar gargalos logísticos
- Avaliar nível de serviço e impacto financeiro das operações

---

## 🏗️ 3. Arquitetura da Solução

O projeto segue uma arquitetura clássica de **Data Warehouse corporativo**, organizada em camadas bem definidas para garantir clareza, governança e escalabilidade.

### 🔄 Fluxo de Dados
- Fonte de dados operacional  
- **Staging (STG)** — dados brutos  
- **ODS** — dados tratados e padronizados  
- **Data Warehouse (DW)** — modelo analítico  
- **Power BI** — camada de consumo e visualização  

### 🗂️ Schemas Utilizados
- **stg**: ingestão dos dados brutos
- **ods**: dados tratados, tipados e validados
- **dw**: fatos e dimensões para análise

Boas práticas adotadas incluem separação de responsabilidades por camada, integridade referencial, padronização de tipos e uso de views para consumo analítico.

---

## 🧱 4. Modelagem de Dados

Foi adotada uma **modelagem híbrida**:
- Relacional nas camadas STG e ODS
- Dimensional (modelo estrela) no Data Warehouse

### 📌 Tabelas Fato
- **Fato_Pedido**: métricas operacionais e financeiras dos pedidos
- **Fato_Custo**: custos recorrentes da frota ao longo do tempo

### 📌 Dimensões
- Tempo
- Veículo
- Filial
- Ocorrência
- Localidade (Cidade, UF, Região)

Essa abordagem respeita a granularidade real dos dados e evita distorções analíticas.

### 📷 Diagrama da Modelagem
> *Inserir imagem da modelagem dimensional*

---

## 🧠 5. SQL — Pilar Central do Projeto

O **SQL é o núcleo técnico** deste projeto e foi utilizado em todas as etapas da solução.

Principais aplicações:
- Criação de schemas, tabelas e constraints
- Desenvolvimento de views analíticas
- Implementação de regras de negócio no banco
- Transformações complexas e padronização de dados

Foram utilizados conceitos como:
- CTEs para organização e legibilidade
- Joins complexos entre múltiplas entidades
- Tratamento de dados inconsistentes
- Escrita de queries orientadas à performance e manutenção

📌 O foco foi construir SQL **legível, escalável e alinhado a boas práticas corporativas**.

---

## 🧹 6. Qualidade e Tratamento de Dados

A qualidade dos dados foi tratada como requisito essencial.

Principais cuidados adotados:
- Limpeza de dados inválidos
- Padronização de formatos e tipos
- Correção de inconsistências oriundas da fonte
- Controle de duplicidade
- Garantia de integridade entre fatos e dimensões

Essas práticas asseguram que as análises reflitam corretamente a realidade operacional.

---

## 📊 7. Power BI — Camada Analítica e Visual

O Power BI foi utilizado como camada final de consumo, conectado diretamente às views do Data Warehouse.

### Destaques da Solução
- Modelo semântico alinhado à modelagem dimensional
- Relacionamentos claros e bem definidos
- Métricas em DAX baseadas em regras de negócio sólidas
- Dashboards orientados à tomada de decisão

### Principais Indicadores
- Receita Bruta
- Custo Total
- Resultado e Margem Operacional
- OTIF, On Time e In Full
- Order Cycle Time
- Volume de pedidos e ocorrências

### 📷 Prints dos Dashboards
> *Inserir imagens das abas do Power BI*

---

## 🛠️ 8. Tecnologias Utilizadas

- SQL Server
- SQL (DDL, DML, CTEs, Views)
- Power BI
- GitHub

---

## 📚 9. Principais Aprendizados

- Aplicação prática de SQL em um pipeline completo
- Importância da modelagem correta para análises confiáveis
- Separação clara entre dados operacionais e analíticos
- Impacto direto da qualidade dos dados no BI
- Construção de métricas logísticas auditáveis

---

## 🚀 10. Próximos Passos e Evoluções Futuras

- Automatização do pipeline de dados
- Implementação de cargas incrementais
- Monitoramento de qualidade de dados
- Integração com novas fontes
- Evolução para análises preditivas

---

👤 **Autor:** Welliton da Rocha  
Projeto desenvolvido com foco em **Engenharia de Dados, SQL Avançado e Analytics aplicado ao negócio**.
