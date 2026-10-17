# RSI Fibonacci Levels Strategy

- url: https://www.tradingview.com/script/GFe2U4zZ-RSI-Fibonacci-Levels-Strategy/
- type: strategy
- pine_id: PUB;yy2fWuw5nZX4aNQhFIJoEIizja4na92h
- version: 1.0

## Description

RSI with Fibonacci Levels 

Visually can be used as: 
- Countertrend indicator at extreme green/red lines 
- Follow trend indicator 
- Fibonacci supports and resistantes zones 

The strategy works as a follow trend 

How to trade: 
The indicator is more reliable in longer time frames, at least 4H 
Choose a fibonacci level as reference 
Buy when the RSI line turns green 
Sell when the RSI line turns red

## Source Code

````pine
// (c) ReduX_o, 2019. All rights reserved.
//
// How to trade:
// The indicator is more reliable in longer time frames
// Choose a fibonacci level as reference 
// Buy when the RSI line turns green
// Sell when the RSI line turns red



//@version=4
strategy("RSI Fibonacci Levels", overlay=false, initial_capital=2000, currency=currency.USD, commission_value=0.1, slippage=0, commission_type=strategy.commission.percent, pyramiding=0, default_qty_type=strategy.percent_of_equity, default_qty_value=100)


len = input(14, minval=1, title="Rsi Periods")
f1 = input(title="Fibonacci Level", defval="38.2", options=["38.2", "50", "61.8"])

// === BACKTEST RANGE ===
FromYear = input(defval=2010, title="From Year", minval=2010)
FromMonth = input(defval=1, title="From Month", minval=1)

ToYear = input(defval=2020, title="To Year", minval=2010)
ToMonth = input(defval=1, title="To Month", minval=1)


src = hl2
fi= (f1 == "38.2") ? 38.2 : (f1 == "50")? 50 : 61.8


up = rma(max(change(src), 0), len)
down = rma(-min(change(src), 0), len)
rsi = down == 0 ? 100 : up == 0 ? 0 : 100 - 100 / (1 + up / down)


//***************************************************
rcolor = rsi >= fi ? color.lime : color.red

plot(rsi, title="RSI", color=rcolor, transp=0)
band1 = hline(78.6, color=color.red, linestyle= hline.style_solid,  editable= false)
band0 = hline(23.6, color=color.lime, linestyle= hline.style_solid, editable= false)
band2 = hline(61.8, color=color.gray, editable= false)
band3 = hline(50, color=color.black, editable= false)
band4 = hline(38.2, color=color.gray, editable= false)
band5 = hline(fi, color=color.blue, linestyle= hline.style_solid, editable= false)

strategy.entry("LE", strategy.long, comment="L", when=rsi >= fi and time > timestamp("GMT-6", FromYear, FromMonth, 00, 00, 00) and time < timestamp("GMT-6", ToYear, ToMonth, 00, 00, 00))
strategy.entry("SE", strategy.short, comment="S", when=rsi < fi and time > timestamp("GMT-6", FromYear, FromMonth, 00, 00, 00) and time < timestamp("GMT-6", ToYear, ToMonth, 00, 00, 00))
````
