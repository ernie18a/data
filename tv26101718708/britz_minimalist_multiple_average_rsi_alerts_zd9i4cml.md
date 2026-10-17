# Britz Minimalist Multiple Average + RSI Alerts

- url: https://www.tradingview.com/script/ZD9i4CMl/
- type: indicator
- pine_id: PUB;a8bead52c7834b0eb44ac4e9035d7010
- version: 2.0

## Description

Here we have, in a single TradingView indicator, 5 classic simple moving averages. Editable. I've added an orange alert (one dot) when the RSI enters overbought or oversold territory. A blue alert (one blue dot) when the RSI returns to the normal range.

Aqui dispomos em um único indicador do Trading View - 5 clássicas médias móveis simples. Editáveis. Agreguei a isso um alerta laranja ( um ponto ) quando o RSI entra em sobrecompra ou sobrevenda. Um alerta azul ( um ponto azul ) quando o RSI retorna para a zona de normalidade.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Arno_Multi_SMA_RSI_Minimalista

//@version=6
indicator('Britz Multiple Simple Average and RSI Minimalist Alert', overlay = true)

// =========================================================================
// 1. PAINEL DE CONTROLE
// =========================================================================
var GRP_SMA = 'Configurações das Médias Móveis'
show_21 = input.bool(true, title = 'Exibir MM 21 Dias (Branca)', group = GRP_SMA)
show_50 = input.bool(true, title = 'Exibir MM 50 Dias (Verde)', group = GRP_SMA)
show_100 = input.bool(true, title = 'Exibir MM 100 Dias (Azul)', group = GRP_SMA)
show_200 = input.bool(true, title = 'Exibir MM 200 Dias (Vermelha)', group = GRP_SMA)
show_8w = input.bool(true, title = 'Exibir MM 8 Semanas (Roxa)', group = GRP_SMA)

var GRP_RSI = 'Configurações de Alertas (RSI)'
show_rsi = input.bool(true, title = 'Exibir Pontos do RSI', group = GRP_RSI)
rsi_len = input.int(14, title = 'Período do RSI', group = GRP_RSI)
rsi_ob = input.int(70, title = 'Nível de Sobrecompra (Topo)', group = GRP_RSI)
rsi_os = input.int(30, title = 'Nível de Sobrevenda (Fundo)', group = GRP_RSI)

// =========================================================================
// 2. CÁLCULO E PLOTAGEM DAS MÉDIAS (FLUIDAS)
// =========================================================================
minutos_no_dia = 1440
mult_dia = timeframe.isintraday ? minutos_no_dia / timeframe.multiplier : 1

sma21 = ta.sma(close, math.max(1, math.round(21 * mult_dia)))
sma50 = ta.sma(close, math.max(1, math.round(50 * mult_dia)))
sma100 = ta.sma(close, math.max(1, math.round(100 * mult_dia)))
sma200 = ta.sma(close, math.max(1, math.round(200 * mult_dia)))
sma8w = ta.sma(close, math.max(1, math.round(56 * mult_dia)))

plot(sma21, color = color.white, linewidth = 2, title = 'SMA 21', display = show_21 ? display.all : display.none)
plot(sma50, color = color.green, linewidth = 2, title = 'SMA 50', display = show_50 ? display.all : display.none)
plot(sma100, color = color.blue, linewidth = 2, title = 'SMA 100', display = show_100 ? display.all : display.none)
plot(sma200, color = color.red, linewidth = 2, title = 'SMA 200', display = show_200 ? display.all : display.none)
plot(sma8w, color = color.purple, linewidth = 2, title = 'SMA 8S', display = show_8w ? display.all : display.none)

if barstate.islast
    if show_21
        label.new(bar_index + 2, sma21, 'MM 21', color = color.new(color.white, 100), textcolor = color.white, style = label.style_label_left, size = size.small)
    if show_50
        label.new(bar_index + 2, sma50, 'MM 50', color = color.new(color.white, 100), textcolor = color.green, style = label.style_label_left, size = size.small)
    if show_100
        label.new(bar_index + 2, sma100, 'MM 100', color = color.new(color.white, 100), textcolor = color.blue, style = label.style_label_left, size = size.small)
    if show_200
        label.new(bar_index + 2, sma200, 'MM 200', color = color.new(color.white, 100), textcolor = color.red, style = label.style_label_left, size = size.small)
    if show_8w
        label.new(bar_index + 2, sma8w, 'MM 8S', color = color.new(color.white, 100), textcolor = color.purple, style = label.style_label_left, size = size.small)

// =========================================================================
// 3. LÓGICA DO RSI E SINAIS VISUAIS (PONTOS MINIMALISTAS)
// =========================================================================
rsi_val = ta.rsi(close, rsi_len)

// Topos (Sobrecompra)
entra_ob = rsi_val >= rsi_ob and rsi_val[1] < rsi_ob
sai_ob = rsi_val < rsi_ob and rsi_val[1] >= rsi_ob

// Fundos (Sobrevenda)
entra_os = rsi_val <= rsi_os and rsi_val[1] > rsi_os
sai_os = rsi_val > rsi_os and rsi_val[1] <= rsi_os

// Plotagem - Utilizando plotchar com o caractere "•" (bullet point) e size.tiny
plotchar(show_rsi and entra_ob, title = 'Entra OB (Laranja)', char = '•', location = location.abovebar, color = color.orange, size = size.tiny)
plotchar(show_rsi and sai_ob, title = 'Sai OB (Azul)', char = '•', location = location.abovebar, color = color.blue, size = size.tiny)

plotchar(show_rsi and entra_os, title = 'Entra OS (Laranja)', char = '•', location = location.belowbar, color = color.orange, size = size.tiny)
plotchar(show_rsi and sai_os, title = 'Sai OS (Azul)', char = '•', location = location.belowbar, color = color.blue, size = size.tiny)
````
