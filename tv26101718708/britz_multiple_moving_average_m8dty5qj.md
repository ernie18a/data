# BRITZ Multiple Moving Average

- url: https://www.tradingview.com/script/m8dTY5Qj/
- type: indicator
- pine_id: PUB;e9fc4e0e7af8428d9bdac86fbcb92a20
- version: 2.0

## Description

A system with 5 simple moving averages, fixed on the daily chart:
21 days, 50, 100, 200 and 8 weeks (56 days) with identification labels. Using only one indicator on TradingView.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Arno_Multi_SMA_Sincronizado

//@version=5
indicator("Médias Móveis Múltiplas", overlay=true)

// --- PAINEL DE CONTROLE (Checkboxes) ---
show_21  = input.bool(true, title="Exibir MM 21 Dias (Branca)")
show_50  = input.bool(true, title="Exibir MM 50 Dias (Verde)")
show_100 = input.bool(true, title="Exibir MM 100 Dias (Azul)")
show_200 = input.bool(true, title="Exibir MM 200 Dias (Vermelha)")
show_8w  = input.bool(true, title="Exibir MM 8 Semanas (Roxa)")

// Fator de proporção para manter as linhas lisas
minutos_no_dia = 1440
mult_dia = timeframe.isintraday ? (minutos_no_dia / timeframe.multiplier) : 1

// Cálculo das Médias
sma21  = ta.sma(close, math.max(1, math.round(21 * mult_dia)))
sma50  = ta.sma(close, math.max(1, math.round(50 * mult_dia)))
sma100 = ta.sma(close, math.max(1, math.round(100 * mult_dia)))
sma200 = ta.sma(close, math.max(1, math.round(200 * mult_dia)))
sma8w  = ta.sma(close, math.max(1, math.round(56 * mult_dia))) 

// Plotagem das Linhas (Sincronizadas com o Painel)
plot(sma21,  color=color.white,  linewidth=2, title="SMA 21",  display = show_21 ? display.all : display.none)
plot(sma50,  color=color.green,  linewidth=2, title="SMA 50",  display = show_50 ? display.all : display.none)
plot(sma100, color=color.blue,   linewidth=2, title="SMA 100", display = show_100 ? display.all : display.none)
plot(sma200, color=color.red,    linewidth=2, title="SMA 200", display = show_200 ? display.all : display.none)
plot(sma8w,  color=color.purple, linewidth=2, title="SMA 8S",  display = show_8w ? display.all : display.none)

// Criação das Legendas (Sincronizadas com o Painel)
if barstate.islast
    if show_21
        label.new(bar_index + 2, sma21,  "MM 21",  color=color.new(color.white, 100), textcolor=color.white,  style=label.style_label_left, size=size.small)
    if show_50
        label.new(bar_index + 2, sma50,  "MM 50",  color=color.new(color.white, 100), textcolor=color.green,  style=label.style_label_left, size=size.small)
    if show_100
        label.new(bar_index + 2, sma100, "MM 100", color=color.new(color.white, 100), textcolor=color.blue,   style=label.style_label_left, size=size.small)
    if show_200
        label.new(bar_index + 2, sma200, "MM 200", color=color.new(color.white, 100), textcolor=color.red,    style=label.style_label_left, size=size.small)
    if show_8w
        label.new(bar_index + 2, sma8w,  "MM 8S",  color=color.new(color.white, 100), textcolor=color.purple, style=label.style_label_left, size=size.small)
````
