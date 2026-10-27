# Option Buy By TAPAS

- url: https://www.tradingview.com/script/1dyS86bj-Option-Buy-By-TAPAS/
- type: indicator
- pine_id: PUB;8a992efce628496f84fba43d0a393d71
- version: 1.0

## Description

Option Buy using Bolliger Band (BB)
When Heikin Ashi Red candle touch the Lower BB and candle change to Green then Buy Signal
When Heikin Ashi Green candle touch the Upper BB and candle change to Red then Sell Signal

## Source Code

````pine

//@version=6
indicator("Option Buy By TAPAS", overlay=true)

// === INPUTS ===
bbLength = input.int(20, "BB Length")
bbMult   = input.float(2.0, "BB Multiplier")
entrySession1  = input.session("0916-1030", "Entry Session1 (IST)")
entrySession2  = input.session("1031-1525", "Entry Session2 (IST)")
marketSession = input.session("0915-1530", "Market Session (IST)")
Reward = input.float(4.0, "Reward")

// === SESSION FILTERS ===
inEntrySession1  = not na(time(timeframe.period, entrySession1))
inEntrySession2  = not na(time(timeframe.period, entrySession2))
inMarketSession = not na(time(timeframe.period, marketSession))

// === SQOFF TIME ===
sqoffTime = (hour == 15 and minute >= 25)

// === NEW DAY RESET ===
newDay = ta.change(time("D"))  != 0


// === HEIKIN ASHI ===
ha_close = (open + high + low + close) / 4
var float ha_open = na
ha_open := na(ha_open[1]) ? (open + close)/2 : (ha_open[1] + ha_close[1])/2
ha_low  = math.min(low, math.min(ha_open, ha_close))

// === BOLLINGER BAND ===
basis = ta.sma(close, bbLength)
dev   = bbMult * ta.stdev(close, bbLength)
lowerBB = basis - dev

// === OSCILLATOR SECTION ===
kLength = 8
kSmoothing = 5
reversalStrength = ta.sma(ta.stoch(close, high, low, kLength), kSmoothing)


// === SETUP ===
prev1 = ha_close[1] < ha_open[1] and ha_low[1] <= lowerBB[1]
prev2 = ha_close[2] < ha_open[2] and ha_low[2] <= lowerBB[2]

signalCandle = ha_close > ha_open
setup1 = (prev1 or prev2) and signalCandle and inEntrySession1
setup2 = (prev1 or prev2) and signalCandle and inEntrySession2 and reversalStrength < 26

// === VARIABLES ===
var float buyLevel = na
var float stopLoss = na
var float target   = na

var bool activeSetup1 = false
var bool activeSetup2 = false
var bool tradeTaken  = false

// === DAILY RESET ===
if newDay
    activeSetup1 := false
    activeSetup2 := false
    tradeTaken  := false

// === SETUP CREATION ===
if setup1 and not activeSetup1 and inMarketSession
    buyLevel := close
    stopLoss := prev1 ? ha_low[1] : ha_low[2]
    risk = buyLevel - stopLoss
    target := buyLevel + (risk * Reward)
    activeSetup1 := true
    //activeSetup2 := true
    tradeTaken := false

// === SETUP CREATION ===
if setup2 and not activeSetup2 and inMarketSession
    buyLevel := close
    stopLoss := prev1 ? ha_low[1] : ha_low[2]
    risk = buyLevel - stopLoss
    target := buyLevel + (risk * Reward)
    //activeSetup1 := true
    activeSetup2 := true
    tradeTaken := false

// ✅ DIRECT BREAKOUT ENTRY (Retest Removed)
buySignal1 = activeSetup1 and not tradeTaken and inEntrySession1 and ta.crossover(close, buyLevel)
buySignal2 = activeSetup2 and not tradeTaken and inEntrySession2 and ta.crossover(close, buyLevel)

if buySignal1
    tradeTaken := true

if buySignal2
    tradeTaken := true

// === EXIT CONDITIONS ===
targetHit = tradeTaken and high >= target
slHit     = tradeTaken and close <= stopLoss
sqOff     = tradeTaken and sqoffTime

exitNow = targetHit or slHit or sqOff or not inMarketSession

// === RESET ===
if exitNow
    activeSetup1 := false
    activeSetup2 := false
    tradeTaken  := false

// === PLOTS ===
plot(activeSetup1 ? buyLevel : na, "Buy Level", color=color.green, linewidth=2, style=plot.style_linebr)
plot(activeSetup1 ? stopLoss : na, "Stoploss", color=color.red, linewidth=2, style=plot.style_linebr)
plot(activeSetup1 ? target : na, "Target (1:5)", color=color.purple, linewidth=2, style=plot.style_linebr)

plot(activeSetup2 ? buyLevel : na, "Buy Level", color=color.green, linewidth=2, style=plot.style_linebr)
plot(activeSetup2 ? stopLoss : na, "Stoploss", color=color.red, linewidth=2, style=plot.style_linebr)
plot(activeSetup2 ? target : na, "Target (1:5)", color=color.purple, linewidth=2, style=plot.style_linebr)


// === SIGNALS ===
plotshape(buySignal1, title="BUY", location=location.belowbar,
     color=color.lime, style=shape.triangleup, text="BUY")

plotshape(targetHit, title="TARGET", location=location.abovebar,
     color=color.blue, style=shape.triangledown, text="Target")

plotshape(slHit, title="SL", location=location.abovebar,
     color=color.red, style=shape.triangledown, text="SL")

plotshape(sqOff, title="TIME EXIT", location=location.abovebar,
     color=color.orange, style=shape.labeldown, text="TIME")


// === SIGNALS2 ===
plotshape(buySignal2, title="BUY", location=location.belowbar,
     color=color.lime, style=shape.triangleup, text="BUY")

plotshape(targetHit, title="TARGET", location=location.abovebar,
     color=color.blue, style=shape.triangledown, text="Target")

plotshape(slHit, title="SL", location=location.abovebar,
     color=color.red, style=shape.triangledown, text="SL")

plotshape(sqOff, title="TIME EXIT", location=location.abovebar,
     color=color.orange, style=shape.labeldown, text="TIME")

// === ALERTS ===
alertcondition(buySignal1, title="Buy", message="Breakout Buy Triggered")
alertcondition(buySignal2, title="Buy1", message="Breakout Buy Triggered")
alertcondition(targetHit, title="Target Alert", message="Target Hit")
alertcondition(slHit, title="Stoploss Alert", message="Stoploss Hit")
alertcondition(sqOff, title="Square-off Alert", message="Auto Exit at 15:25 IST")
````
