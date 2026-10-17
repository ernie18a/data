# RSI Alligator Strategy [forked from jedireza]

- url: https://www.tradingview.com/script/OQICfRi3-RSI-Alligator-Strategy-forked-from-jedireza/
- type: strategy
- pine_id: PUB;4IosL7biaz1aajV9Hjn31VMzTLKVHHAU
- version: 2.0

## Description

Backtester for RSI alligator is Williams Alligator strategy using Relative Strength Index to predict entries

Original script can be found at https://www.tradingview.com/script/61Q9WCzA-RSI-Alligator/

## Source Code

````pine
// @version=3
// RSI Alligator
// Forked from Author: Reza Akhavan
// Updated by Khalid Salomão and Agamemnon

strategy("RSI Alligator Strategy", overlay=false, pyramiding=0, default_qty_type=strategy.cash, default_qty_value=25000, initial_capital=25000, commission_type=strategy.commission.percent, commission_value=0.15, slippage=3)

// === TA LOGIC ===
overBought = input(70, minval=0, maxval=100, title="Over bought")
overSold = input(30, minval=0, maxval=100, title="Over sold")
jawPeriods = input(5, minval=1, title="Jaw Periods")
jawOffset = input(0, minval=0, title="Jaw Offset")
teethPeriods = input(13, minval=1, title="Teeth Periods")
teethOffset = input(0, minval=0, title="Teeth Offset")
lipsPeriods = input(34, minval=1, title="Lips Periods")
lipsOffset = input(0, minval=0, title="Lips Offset")

jaws = rsi(close, jawPeriods)
teeth = rsi(close, teethPeriods)
lips = rsi(close, lipsPeriods)
plot(jaws, color=green, offset=jawOffset, title="Jaw")
plot(teeth, color=red, offset=teethOffset, title="Teeth")
plot(lips, color=blue, offset=lipsOffset, title="Lips")

//
// === Signal logic ===
// 
filterCross = input(false, title="Use only major cross as signals")

LONG_SIGNAL_BOOLEAN  = filterCross ? (crossover(teeth, lips) and jaws > teeth) : (crossover(teeth, lips) and jaws > lips) or (crossover(jaws, lips) and teeth > lips)
SHORT_SIGNAL_BOOLEAN = filterCross ? (crossunder(teeth, lips) and jaws < teeth) : (crossunder(teeth, lips) and jaws < lips) or (crossunder(jaws, lips) and teeth < lips)

// === INPUT BACKTEST DATE RANGE ===
strategyType = input(defval="Long Only", options=["Long & Short", "Long Only", "Short Only"])

FromMonth = input(defval = 7, title = "From Month", minval = 1, maxval = 12)
FromDay   = input(defval = 1, title = "From Day", minval = 1, maxval = 31)
FromYear  = input(defval = 2018, title = "From Year", minval = 2017)
ToMonth   = input(defval = 12, title = "To Month", minval = 1, maxval = 12)
ToDay     = input(defval = 1, title = "To Day", minval = 1, maxval = 31)
ToYear    = input(defval = 2020, title = "To Year", minval = 2017)

start     = timestamp(FromYear, FromMonth, FromDay, 00, 00)  
finish    = timestamp(ToYear, ToMonth, ToDay, 23, 59)        
window()  => time >= start and time <= finish ? true : false // window of time verification

// === STRATEGY BUY / SELL ENTRIES ===

// plot buy and sell arrows
plotshape(LONG_SIGNAL_BOOLEAN, style=shape.triangleup, location=location.bottom, color=green, size=size.tiny)
plotshape(SHORT_SIGNAL_BOOLEAN, style=shape.triangledown, location=location.top, color=red, size=size.tiny)

// long and short entries
buy()  => window() and LONG_SIGNAL_BOOLEAN
sell() => window() and SHORT_SIGNAL_BOOLEAN

if buy()
    if (strategyType == "Short Only")
        strategy.close("Short")
    else
        strategy.entry("Long", strategy.long, comment="Long")

if sell()
    if (strategyType == "Long Only")
        strategy.close("Long")
    else
        strategy.entry("Short", strategy.short, comment="Short")
        

// === BACKTESTING: EXIT strategy ===
sl_inp = input(10, title='Stop Loss %', type=float)/100
tp_inp = input(90, title='Take Profit %', type=float)/100

stop_level = strategy.position_avg_price * (1 - sl_inp)
take_level = strategy.position_avg_price * (1 + tp_inp)

strategy.exit("Stop Loss/Profit", "Long", stop=stop_level, limit=take_level)
````
