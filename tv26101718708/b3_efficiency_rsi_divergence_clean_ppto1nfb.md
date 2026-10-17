# B3 Efficiency & RSI Divergence - Clean

- url: https://www.tradingview.com/script/PPto1nFb/
- type: indicator
- pine_id: PUB;97e280303c254fe9a8bff8cb7611097d
- version: 1.0

## Description

Este indicador é uma ferramenta de análise quantitativa que combina a Eficiência de Kaufman (ER) com a detecção de Divergências Regulares de Momentum (RSI). Projetado com uma interface minimalista, o objetivo principal é filtrar o "ruído" de mercado e identificar pontos de exaustão direcional, sendo especialmente útil para ativos de alta volatilidade.

Componentes Principais
1. Kaufman Efficiency Ratio (ER)
Baseado na lógica de Perry Kaufman, o indicador calcula a razão entre o deslocamento líquido do preço e a volatilidade total (soma de todos os movimentos) em um determinado período.

Eficiência (Verde): Indica movimentos direcionais limpos. Ideal para estratégias de tendência e Delta em derivativos.

Consolidação (Vermelho): Identifica zonas de "caixote" ou ruído excessivo, onde o risco de Theta decay (corrosão temporal) em opções é elevado.

2. Divergências Regulares de RSI (IFR)
O script integra um motor de busca de pivôs sincronizados para identificar divergências entre o preço e o IFR:

Bullish Divergence: Preço faz fundos menores enquanto o IFR faz fundos maiores.

Bearish Divergence: Preço faz topos maiores enquanto o IFR faz topos menores.

As divergências são exibidas de forma discreta na base do gráfico, garantindo que o Price Action permaneça limpo.

Diferenciais Técnicos
Interface Clean: Dashboard superior dinâmico que reporta o valor exato do ER e a última divergência confirmada.

Sincronização de Pivôs: Utiliza lógica de lookback ajustável para evitar sinais falsos e garantir precisão na marcação dos topos e fundos.

Otimizado para Derivativos: Atua como um filtro de qualidade para entradas, ajudando a evitar lateralidades que prejudicam operações de compra de volatilidade.

Como Calibrar
ER Low (Consolidação): Ajuste entre 0.30 e 0.40 para identificar zonas de travamento de preço.

ER High (Tendência): Ajuste entre 0.60 e 0.70 para validar rompimentos de alta qualidade.

RSI Lookback: O padrão de 5 barras é recomendado para capturar pivôs estruturais sem ruído intraday excessivo.

Aviso: Este script é uma ferramenta de auxílio à decisão e não constitui recomendação de compra ou venda. Teste sempre seus parâmetros através de backtesting antes da execução em conta real.

## Source Code

````pine
//@version=6
indicator("B3 Efficiency & RSI Divergence - Clean", overlay=true)

// --- GRUPO: EFICIÊNCIA (ER) ---
er_len      = input.int(14, "ER: Período", minval=1, group="Eficiência")
er_low      = input.float(0.30, "ER: Gatilho Consolidação", step=0.05, group="Eficiência")
er_high     = input.float(0.60, "ER: Gatilho Tendência", step=0.05, group="Eficiência")

// --- GRUPO: RSI DIVERGÊNCIA (APENAS REGULARES) ---
len         = input.int(14, "RSI: Período", minval=1, group="Divergência")
lbR         = input.int(5, "Pivot Lookback Right", group="Divergência")
lbL         = input.int(5, "Pivot Lookback Left", group="Divergência")
rangeUpper  = input.int(60, "Max Lookback Range", group="Divergência")
rangeLower  = input.int(5, "Min Lookback Range", group="Divergência")
osc         = ta.rsi(close, len)

// --- CÁLCULO EFICIÊNCIA (ER) ---
change           = math.abs(close - close[er_len])
volatility       = math.sum(math.abs(close - close[1]), er_len)
efficiency_ratio = volatility > 0 ? change / volatility : 0

bool is_consolidating = efficiency_ratio < er_low
bool is_trending      = efficiency_ratio >= er_high
bool is_fading        = not is_consolidating and not is_trending

// --- LÓGICA DE DIVERGÊNCIAS REGULARES ---
plFound = na(ta.pivotlow(osc, lbL, lbR)) ? false : true
phFound = na(ta.pivothigh(osc, lbL, lbR)) ? false : true

_inRange(cond) =>
    bars = ta.barssince(cond == true)
    rangeLower <= bars and bars <= rangeUpper

// Regular Bullish (Preço faz fundo menor, RSI faz fundo maior)
inRangePl = _inRange(plFound[1])
oscHL     = osc[lbR] > ta.valuewhen(plFound, osc[lbR], 1) and inRangePl
priceLL   = low[lbR] < ta.valuewhen(plFound, low[lbR], 1)
bullCond  = priceLL and oscHL and plFound

// Regular Bearish (Preço faz topo maior, RSI faz topo menor)
inRangePh = _inRange(phFound[1])
oscLH     = osc[lbR] < ta.valuewhen(phFound, osc[lbR], 1) and inRangePh
priceHH   = high[lbR] > ta.valuewhen(phFound, high[lbR], 1)
bearCond  = priceHH and oscLH and phFound

// --- DASHBOARD ---
var table dash = table.new(position.top_right, 2, 4, bgcolor=color.new(color.black, 20), border_width=1, border_color=color.gray)

var string last_div = "Nenhuma"
var color  div_col  = color.gray

if bullCond
    last_div := "Regular Bull", div_col := color.lime
else if bearCond
    last_div := "Regular Bear", div_col := color.red

if barstate.islast
    st_text  = is_consolidating ? "CONSOLIDAÇÃO" : (is_fading ? "ZONA DE RUÍDO" : "TENDÊNCIA FORTE")
    st_color = is_consolidating ? color.red : (is_fading ? color.orange : color.lime)
    
    table.cell(dash, 0, 0, "ER VALUE", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 0, str.tostring(math.round(efficiency_ratio, 2)), text_color=st_color, text_size=size.small)
    table.cell(dash, 0, 1, "STATUS ER", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 1, st_text, text_color=st_color, text_size=size.small)
    table.cell(dash, 0, 2, "DIVERGÊNCIA", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 2, last_div, text_color=div_col, text_size=size.small)

// --- VISUALIZAÇÃO DISCRETA (FOOTER) ---

// 1. Fita de Eficiência (Borda Inferior Principal)
fita_col = is_consolidating ? color.new(color.red, 30) : (is_fading ? color.new(color.orange, 30) : color.new(color.lime, 30))
plotshape(true, title="Fita ER", location=location.bottom, color=fita_col, style=shape.square, size=size.tiny)

// 2. Marcadores de Divergência (Triângulos discretos abaixo da fita)
// Bullish (Verde)
plotshape(bullCond, title="Bull Div", style=shape.triangleup, location=location.bottom, color=color.lime, size=size.tiny, offset=-lbR)
// Bearish (Vermelho)
plotshape(bearCond, title="Bear Div", style=shape.triangledown, location=location.bottom, color=color.red, size=size.tiny, offset=-lbR)
````
