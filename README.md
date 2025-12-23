# 📦 projeto-logistica-analytics

Projeto de **Analytics Logístico** desenvolvido com foco em **SQL avançado**, engenharia de dados e análise de performance operacional e financeira, utilizando uma arquitetura completa de **Data Warehouse** e visualização no **Power BI**.

---

## 📌 1. Visão Geral do Projeto

Operações logísticas geram grandes volumes de dados relacionados a **pedidos, custos de frota, prazos de entrega e ocorrências operacionais.** Sem um modelo de dados bem estruturado e regras claras de negócio, esses dados não se convertem em informação confiável para tomada de decisão.

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
## 📂 4. Estrutura do Repositório

projeto-logistica-analytics/
```text
├── sql/
│   ├── stg/        # Scripts de staging (dados brutos, sem regras de negócio)
│   ├── ods/        # Dados tratados e normalizados (camada operacional)
│   ├── dw/         # Modelagem dimensional (fatos e dimensões)
│   └── views/      # Views de consumo para ferramentas analíticas
│
├── powerbi/
│   └── projeto_logistica_analytics.pbix  # Dashboard final e modelo semântico
│
├── docs/
│   ├── regras_negocio.md     # Definições de métricas, KPIs e regras de negócio
│   └── dicionario_dados.md   # Dicionário de dados do Data Warehouse e views
│
├── assets/
│   ├── backgrounds/          # Backgrounds das páginas (SVG – criados no Figma)
│   ├── icons/                # Ícones utilizados nos visuais (PNG)
│   └── images/               # Prints do dashboard e da modelagem dimensional
│
└── README.md
```
### 🧭 Como navegar pelo projeto

- Comece pela pasta **sql/** para entender a lógica de ingestão, tratamento e modelagem dos dados.
- Consulte **docs/** para compreender as regras de negócio, métricas e estrutura analítica.
- Explore **powerbi/** para visualizar o resultado final do projeto.
- Utilize **assets/** para referências visuais do design, modelagem e dashboards.

Essa organização reforça a proposta de um projeto **robusto, escalável e orientado a boas práticas**, facilitando a leitura tanto para recrutadores quanto para times técnicos.

## 🧱 5. Modelagem de Dados

Foi adotada uma **modelagem híbrida**:
- Relacional nas camadas STG e ODS
- Dimensional (modelo estrela) no Data Warehouse

### 📌 Tabelas Fato
- **Fato_Pedido**: métricas operacionais e financeiras dos pedidos
- **Fato_Custo**: custos recorrentes da frota ao longo do tempo

### 📌 Dimensões
- Dim_Cidade (Cidade, UF, Região)
- Dim_Ocorrencia
- Dim_Tempo
- Dim_Veiculo

Essa abordagem respeita a granularidade real dos dados e evita distorções analíticas.

### 📷 Diagrama da Modelagem
<img width="1020" height="519" alt="image" src="https://github.com/user-attachments/assets/636f2e49-820f-4031-9fde-e3bbd2beac11" />

---

## 🧠 6. SQL — Pilar Central do Projeto

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

## 🧹 7. Qualidade e Tratamento de Dados

A qualidade dos dados foi tratada como requisito essencial.

Principais cuidados adotados:
- Limpeza de dados inválidos
- Padronização de formatos e tipos
- Correção de inconsistências oriundas da fonte
- Controle de duplicidade
- Garantia de integridade entre fatos e dimensões

Essas práticas asseguram que as análises reflitam corretamente a realidade operacional.

---

## 📊 8. Power BI — Camada Analítica e Visual

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

### Aba 1 - Home
<img width="1239" height="696" alt="image" src="https://github.com/user-attachments/assets/8874cf75-a4c4-48de-921c-2d12bd9d8ee7" />

### Aba 2 - Análise de Custos
<img width="1237" height="695" alt="image" src="https://github.com/user-attachments/assets/23ed988b-ea33-4870-8ca8-43a24522d886" />

### Aba 3 - Análise de Pedidos
<img width="1236" height="696" alt="image" src="https://github.com/user-attachments/assets/a338d697-3a87-4d01-b332-e0bc8e424022" />

---

## 🎨 9. Design do Dashboard e Experiência Visual (Figma + Power BI)

A camada visual deste projeto foi **planejada e construída de forma estratégica**, utilizando o **Figma como ferramenta de design** antes da implementação no Power BI. O objetivo foi garantir **clareza analítica, consistência visual e uma experiência próxima a dashboards corporativos reais**, indo além de uma simples entrega técnica.

### 🧩 Processo de Design

- Criação dos **backgrounds das páginas no Figma**, exportados em **SVG** para manter qualidade, escala e nitidez
- Definição prévia de:
  - Grid e alinhamento dos visuais
  - Espaçamentos consistentes entre KPIs
  - Hierarquia visual para leitura executiva
- Padronização de:
  - Paleta de cores
  - Tipografia
  - Ícones e elementos gráficos
- Separação clara entre:
  - Indicadores estratégicos (cards)
  - Análises táticas (gráficos)
  - Visões operacionais (matrizes e mapas)

### 🔌 Integração com o Power BI

- Backgrounds aplicados diretamente nas páginas do Power BI
- Utilização de **ícones personalizados em PNG** nos indicadores
- Design orientado à **leitura rápida e tomada de decisão**
- Redução de ruído visual e excesso de informação

### 🎯 Benefícios do Approach

- Maior **usabilidade do dashboard**
- Melhor **legibilidade dos KPIs**
- Experiência visual consistente entre abas
- Dashboard com aparência **profissional e corporativa**, não apenas técnica

Esse cuidado com design reforça a proposta **end-to-end do projeto**, conectando **engenharia de dados, modelagem analítica e apresentação executiva** em uma única solução.

---

## 🛠️ 10. Tecnologias Utilizadas

- SQL Server
- SQL (DDL, DML, CTEs, Views)
- Power BI
- Figma
- GitHub

---

## 📚 11. Principais Aprendizados

- Aplicação prática de SQL em um pipeline completo
- Importância da modelagem correta para análises confiáveis
- Separação clara entre dados operacionais e analíticos
- Impacto direto da qualidade dos dados no BI
- Construção de métricas logísticas auditáveis

---

👤 **Autor:** Welliton da Rocha  
Projeto desenvolvido com foco em **Engenharia de Dados, SQL Avançado e Analytics aplicado ao negócio**.
