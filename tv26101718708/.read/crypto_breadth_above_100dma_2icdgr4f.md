# Crypto Breadth % Above 100DMA

- url: https://www.tradingview.com/script/2IcdgR4F-Crypto-Breadth-Above-100DMA/
- type: indicator
- pine_id: PUB;2649b4c0913f4553ac4b9e54843cb7f3
- version: 1.0

## Description

Crypto Breadth % Above 100DMA. Used as a fillter in my system to detect good market conditions for my allocations

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © andrej87kolar

//@version=5
indicator("Crypto Breadth % Above 100DMA", overlay=false)

// === SETTINGS ===
length = input.int(100, "Moving Average Length")

// === SYMBOL LIST (EDIT IF NEEDED) ===
btc = request.security("BINANCE:BTCUSDT", timeframe.period, close)
eth = request.security("BINANCE:ETHUSDT", timeframe.period, close)
bnb = request.security("BINANCE:BNBUSDT", timeframe.period, close)
sol = request.security("BINANCE:SOLUSDT", timeframe.period, close)
xrp = request.security("BINANCE:XRPUSDT", timeframe.period, close)
ada = request.security("BINANCE:ADAUSDT", timeframe.period, close)
doge = request.security("BINANCE:DOGEUSDT", timeframe.period, close)
dot = request.security("BINANCE:DOTUSDT", timeframe.period, close)
link = request.security("BINANCE:LINKUSDT", timeframe.period, close)
ltc = request.security("BINANCE:LTCUSDT", timeframe.period, close)

// === MOVING AVERAGES ===
btc_ma = ta.sma(btc, length)
eth_ma = ta.sma(eth, length)
bnb_ma = ta.sma(bnb, length)
sol_ma = ta.sma(sol, length)
xrp_ma = ta.sma(xrp, length)
ada_ma = ta.sma(ada, length)
doge_ma = ta.sma(doge, length)
dot_ma = ta.sma(dot, length)
link_ma = ta.sma(link, length)
ltc_ma = ta.sma(ltc, length)

// === CONDITIONS ===
btc_above = btc > btc_ma ? 1 : 0
eth_above = eth > eth_ma ? 1 : 0
bnb_above = bnb > bnb_ma ? 1 : 0
sol_above = sol > sol_ma ? 1 : 0
xrp_above = xrp > xrp_ma ? 1 : 0
ada_above = ada > ada_ma ? 1 : 0
doge_above = doge > doge_ma ? 1 : 0
dot_above = dot > dot_ma ? 1 : 0
link_above = link > link_ma ? 1 : 0
ltc_above = ltc > ltc_ma ? 1 : 0

// === BREADTH CALCULATION ===
count_above = btc_above + eth_above + bnb_above + sol_above + xrp_above + ada_above + doge_above + dot_above + link_above + ltc_above
breadth = (count_above / 10) * 100

// === PLOT ===
plot(breadth, title="Breadth %", color=color.blue, linewidth=2)

// === LEVELS ===
hline(70, "Strong Breadth", color=color.green)
hline(40, "Weak Breadth", color=color.red)
````
