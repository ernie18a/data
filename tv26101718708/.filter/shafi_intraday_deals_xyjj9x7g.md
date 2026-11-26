# Shafi: IntraDay Deals

- url: https://www.tradingview.com/script/xyjJ9X7g-Shafi-IntraDay-Deals/
- type: strategy
- pine_id: PUB;cd1d265cbe714c988d8ff81fce32bf70
- version: 1.0

## Description

RSI above 52 for Buy
RSI below 48 for Sell

Usually it will be as mentioned, yet should be cross checked

## Source Code

````pine
//@version=5
strategy("EMA 9 / EMA 21 with VWAP - Signal Only", 
     overlay=true,
     default_qty_type=strategy.percent_of_equity,
     default_qty_value=10,
     calc_on_every_tick=false)

// === INDICATORS (Hidden) ===
ema9  = ta.ema(close, 9)
ema21 = ta.ema(close, 21)
vwapValue = ta.vwap(close)

// === CONDITIONS (Confirmed on Candle Close) ===
buyCondition  = ta.crossover(ema9, ema21) and close > vwapValue and barstate.isconfirmed
sellCondition = ta.crossunder(ema9, ema21) and close < vwapValue and barstate.isconfirmed

// === STRATEGY ENTRIES ===
if (buyCondition)
    strategy.entry("BUY", strategy.long)

if (sellCondition)
    strategy.entry("SELL", strategy.short)

// === SIGNAL MARKERS ONLY ===
plotshape(buyCondition,
     title="BUY Signal",
     location=location.belowbar,
     style=shape.labelup,
     size=size.large,
     color=color.green,
     text="BUY",
     textcolor=color.white)

plotshape(sellCondition,
     title="SELL Signal",
     location=location.abovebar,
     style=shape.labeldown,
     size=size.large,
     color=color.red,
     text="SELL",
     textcolor=color.white)
````
