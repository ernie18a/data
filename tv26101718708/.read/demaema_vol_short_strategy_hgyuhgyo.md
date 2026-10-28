#  DEMA/EMA & VOL (Short strategy)

- url: https://www.tradingview.com/script/HgyuhGYO-DEMA-EMA-VOL-Short-strategy/
- type: strategy
- pine_id: PUB;QnrZ2QX0xKTu2WNXRgmwJOSJDV2SGiQp
- version: 1.0

## Description

Hello,
I am trying to build a short momentum strategy that is based off of the DEMA crossing under the EMA, but because many momentum strategies send too many signals, I have also implemented a volatility condition based on the average true range percentage (ATRP). Essentially, as momentum moves downwards + volatility (ATRP) moves upwards, it shorts the security. However, I am having an issue with exiting trades. I think this would be a great strategy if I could simply get the strategy to exit the trades. Does anyone mind looking through the source code and tell me what I might be doing wrong? In return, I would hope that this strategy could be useful to you in same way! Thank you for looking!

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Qorbanjf

//@version=4
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Qorbanjf

//@version=4
strategy("Qorban: DEMA/EMA & VOL Short ONLY", shorttitle="DEMA/EMA & VOL SHORT", overlay=true, initial_capital=10000, default_qty_value=10000)

// DEMA
length = input(10, minval=1, title="DEMA LENGTH")
src = input(close, title="Source")
e1 = ema(src, length)
e2 = ema(e1, length)
dema1 = 2 * e1 - e2
plot(dema1, "DEMA", color=color.yellow)

//EMA
len = input(25, minval=1, title="EMA Length")
srb = input(close, title="Source")
offset = input(title="Offset", type=input.integer, defval=0, minval=-500, maxval=500)
ema1 = ema(srb, len)
plot(ema1, title="EMA", color=color.blue, offset=offset)

// get ATR VALUE
atr = atr(14)

//ATRP (Average True Price in precentage)

// Inputs
atrTimeFrame = input("D", title="ATR Timeframe", type=input.resolution)
atrLookback = input(defval=14,title="ATR Lookback Period",type=input.integer)
useMA = input(title = "Show Moving Average?", type = input.bool, defval = true)
maType = input(defval="EMA", options=["EMA", "SMA"], title = "Moving Average Type")
maLength = input(defval = 20, title = "Moving Average Period", minval = 1)
slType = input(title="Stop Loss ATR / %", type=input.float, defval=5.0, step=0.1)
slMulti = input(title="SL Multiplier", type=input.float, defval=1.0, step=0.1)
minimumProfitPercent = input(title="Minimum profit %", type=input.float, defval=20.00)

// ATR Logic
// atrValue = atr(atrLookback)
// atrp = (atrValue/close)*100
// plot(atrp, color=color.white, linewidth=2, transp = 30)

atrValue = security(syminfo.tickerid, atrTimeFrame, atr(atrLookback))
atrp = (atrValue/close)*100

// Moving Average Logic
ma(maType, src, length) =>
    maType == "EMA" ? ema(src, length) : sma(src, length) //Ternary Operator (if maType equals EMA, then do ema calc, else do sma calc)
maFilter = security(syminfo.tickerid, atrTimeFrame, ma(maType, atrp, maLength))


// Determine percentage of open profit
var entry = 0.0
distanceProfit = low - entry
distanceProfitPercent = distanceProfit / entry

//Determin if we have a long entry signal OR a sell position signal
profitSignal = minimumProfitPercent == 0.0 or distanceProfitPercent >= minimumProfitPercent
shortSignal = crossunder(dema1, ema1) and atrp > maFilter and strategy.position_size == 0 and not na(atr)
exitSignal = profitSignal and strategy.position_size !=0 and  crossover(dema1, ema1)


// === INPUT BACKTEST RANGE ===
//FromMonth = input(defval = 1, title = "From Month", minval = 1, maxval = 12)
//FromDay   = input(defval = 1, title = "From Day", minval = 1, maxval = 31)
//FromYear  = input(defval = 2017, title = "From Year", minval = 2000)
//ToMonth   = input(defval = 1, title = "To Month", minval = 1, maxval = 12)
//ToDay     = input(defval = 1, title = "To Day", minval = 1, maxval = 31)
//ToYear    = input(defval = 9999, title = "To Year", minval = 2017)

//Invert trade direction & flipping 
//tradInvert = input(defval = false, title = "invert trade direction")
//MOM_MR = input(defval=1, title = "MOM = 1 / MR = -1", minval=-1, maxval=1)
//plots=input(false, title="Show plots?")

// Get stop loss (in pips AND percentage distance)
shortStop = highest(high, 4) - (atr * slMulti)
shortStopPercent = close - (close * slMulti)

// Save long stop & target prices (used for drawing data to the chart & deetermining profit)
var shortStopSaved = 0.0
var shortTargetSaved = 0.0
enterShort = false
if shortSignal
    shortStopSaved := slType ? shortStop : shortStopPercent
    enterShort:= true
    entry := close


// long conditions 
//enterLong = crossover(dema1, ema1) and atrp < maFilter
//exitSignal => crossunder(dema1, ema1)

//Enter trades when conditions are met
strategy.entry("short", strategy.short, when=enterShort, comment="SHORT")

//place exit orders (only executed after trades are active)
strategy.exit(id="Short exit",
 from_entry="short",
 limit=exitSignal ? close : na,
 stop=shortStopSaved,
 when=strategy.position_size > 0,
 comment="end short")
 

//short strategy
//goShort() => crossunder(dema1, ema1) and atrp > maFilter
//KillShort() => crossover(dema1, ema1) 
//strategy.entry("SHORT", strategy.short, when = goShort())
//strategy.close("COVER", when = KillShort())
````
