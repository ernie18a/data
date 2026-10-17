# EMA Zone Retest (20/50)

- url: https://www.tradingview.com/script/FL0KwlFT-EMA-Zone-Retest-20-50/
- type: indicator
- pine_id: PUB;0c5320cffab3487a876a560aa0e67b94
- version: 1.0

## Description

Work in progress, EMA indicator which uses retesting EMA x3 times for buy signals and x1 EMA retest for sells. Use own risk management if using, and don't use the indicator blindly. On back test 1st June to 19th June it had a 65% success rate on 2:1RR

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Scotland7

//@version=6
indicator("EMA Zone Retest (20/50)", overlay=true)
// ---------------- Inputs ----------------
fastLen   = input.int(20, "Fast EMA Length")
slowLen   = input.int(50, "Slow EMA Length")
buyTouches  = input.int(3, "Retests required for BUY", minval=1)
sellTouches = input.int(1, "Retests required for SELL", minval=1)

// ---------------- EMAs ----------------
emaFast = ta.ema(close, fastLen)
emaSlow = ta.ema(close, slowLen)

plot(emaFast, "EMA Fast", color=color.new(color.aqua, 0))
plot(emaSlow, "EMA Slow", color=color.new(color.orange, 0))

zoneTop = math.max(emaFast, emaSlow)
zoneBot = math.min(emaFast, emaSlow)
fill(plot(zoneTop, "Zone Top", display=display.none),
     plot(zoneBot, "Zone Bottom", display=display.none),
     color=color.new(color.gray, 85))

// ---------------- Crossover detection ----------------
bullCross = ta.crossover(emaFast, emaSlow)   // 20 crosses above 50
bearCross = ta.crossunder(emaFast, emaSlow)  // 20 crosses below 50

var string trend     = "none"
var int    touchCount = 0
var bool   inZonePrev = false
var bool   signalFiredThisCycle = false

if bullCross
    trend := "bull"
    touchCount := 0
    signalFiredThisCycle := false

if bearCross
    trend := "bear"
    touchCount := 0
    signalFiredThisCycle := false

// ---------------- Retest (touch) detection ----------------
// A "touch" = price range for this bar overlaps the EMA zone,
// counted only on the transition from outside -> inside (one touch per visit)
insideZoneNow = (low <= zoneTop) and (high >= zoneBot)
touchEvent    = insideZoneNow and not inZonePrev

buySignal  = false
sellSignal = false

if touchEvent and trend == "bull"
    touchCount += 1
    if touchCount == buyTouches and not signalFiredThisCycle
        buySignal := true
        signalFiredThisCycle := true

if touchEvent and trend == "bear"
    touchCount += 1
    if touchCount == sellTouches and not signalFiredThisCycle
        sellSignal := true
        signalFiredThisCycle := true

inZonePrev := insideZoneNow

// ---------------- Plot signals ----------------
plotshape(buySignal, title="BUY", style=shape.labelup, location=location.belowbar,
     color=color.new(color.green, 0), text="BUY", textcolor=color.white, size=size.small)

plotshape(sellSignal, title="SELL", style=shape.labeldown, location=location.abovebar,
     color=color.new(color.red, 0), text="SELL", textcolor=color.white, size=size.small)

// ---------------- Alerts ----------------
alertcondition(buySignal, title="EMA Zone Buy", message="Buy signal: 3rd retest of EMA zone after bullish crossover")
alertcondition(sellSignal, title="EMA Zone Sell", message="Sell signal: 1st retest of EMA zone after bearish crossover")
````
