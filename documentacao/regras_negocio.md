# 📌 Regras de Negócio – Projeto Logística Analytics

Este documento descreve as **principais regras de negócio** aplicadas no projeto **projeto-logistica-analytics**, garantindo transparência, rastreabilidade e correta interpretação das métricas logísticas e financeiras utilizadas nas análises.

---

## 1. Conceitos Gerais

O projeto analisa uma operação logística baseada em:
- Pedidos de transporte
- Custos operacionais da frota
- Cumprimento de prazos
- Ocorrências de entrega

Todas as métricas foram definidas de forma explícita para evitar ambiguidades e assegurar consistência analítica.

---

## 2. Definições de Entrega

### 🚚 Pedido Entregue
Um pedido é considerado **entregue** quando possui data de entrega registrada (`DataEntrega`).

---

### ⏱️ On Time (No Prazo)
Um pedido é considerado **On Time** quando:

Pedidos entregues após a data prevista são classificados como **Fora do Prazo**, mesmo que tenham sido entregues com sucesso.

---

### 📦 In Full
Um pedido é considerado **In Full** quando **não possui ocorrência operacional**.

Regra aplicada:
- `SK_Ocorrencia = 1` → Pedido entregue sem ocorrência
- `SK_Ocorrencia <> 1` → Pedido entregue com ocorrência

Ocorrências representam problemas como avarias, devoluções, extravios ou outros eventos operacionais registrados.

---

### 🎯 OTIF (On Time In Full)

OTIF é uma métrica composta que representa pedidos:
- Entregues **no prazo**
- **Sem ocorrência**

Definição:

Essa métrica reflete o **nível real de serviço logístico**.

---

## 3. Ocorrências Operacionais

A tabela **Dim_Ocorrencia** contém o cadastro completo de motivos e responsabilidades.

Regras:
- `SK_Ocorrencia = 1` → Entrega normal (sem ocorrência)
- `SK_Ocorrencia entre 2 e 28` → Tipos específicos de ocorrência

Importante:
- Um pedido pode ser entregue **fora do prazo e sem ocorrência**
- Atraso não é tratado como ocorrência operacional

---

## 4. Métricas Financeiras

### 💰 Receita Bruta
Representa o valor total cobrado pelo frete:

---

### 💸 Custo Total
Representa o custo operacional da frota, incluindo:
- Abastecimento
- Manutenção
- Custos fixos

Os custos são registrados na tabela **Fato_Custo** e possuem granularidade temporal própria.

---

### 📊 Resultado
Resultado operacional da operação logística: (Receita Bruta - Custos)
  
---

### 📈 Margem Operacional
Indicador percentual de rentabilidade

---

## 5. Order Cycle Time (OCT)

O **Order Cycle Time** representa o tempo médio entre o pedido e sua entrega, medido em dias.

Utilizado para avaliar eficiência operacional e tempo de resposta da logística.

---

## 6. Considerações Importantes

- Custos não são associados diretamente a pedidos individuais
- A tabela de custos é uma **tabela fato independente**
- Análises financeiras utilizam agregações por período, filial ou veículo
- Todas as métricas respeitam a granularidade original dos dados

---

📌 Este documento garante entendimento claro das regras aplicadas e serve como base para auditoria, manutenção e evolução do projeto.







