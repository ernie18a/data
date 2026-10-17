# Liquidity Sweep Weak/Strong Engulfing

- url: https://www.tradingview.com/script/vmnFRhf6-Liquidity-Sweep-Weak-Strong-Engulfing/
- type: indicator
- pine_id: PUB;1f8ceda6bce643daa14d44a9bf05f04a
- version: 1.0

## Description

The Liquidity Sweep Weak/Strong Engulfing Indicator identifies liquidity grabs followed by engulfing patterns in the market.

First, a candle sweeps the previous candle’s high/low (liquidity hunt)
Then, based on the closing position, it classifies the signal:

🔹 Strong Engulfing

Close is above/below the entire previous candle (high/low)
Indicates strong momentum and a high-probability reversal

🔹 Weak Engulfing

Close is outside the previous candle’s body, but not a full breakout
Indicates moderate strength, needs confirmation

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// © SMT

//@version=5
indicator("Liquidity Sweep Weak/Strong Engulfing", shorttitle="LS WeakStrong", overlay=true, max_labels_count=500)

//══════════════════════════════════════════════════════════════════════════════
// INPUTS
//══════════════════════════════════════════════════════════════════════════════
grpLogic  = "Logic Settings"
grpVisual = "Visual Settings"
grpSignal = "Signal Settings"

showWeakBull   = input.bool(true,  "Show Weak Bullish", group=grpLogic)
showStrongBull = input.bool(true,  "Show Strong Bullish", group=grpLogic)
showWeakBear   = input.bool(true,  "Show Weak Bearish", group=grpLogic)
showStrongBear = input.bool(true,  "Show Strong Bearish", group=grpLogic)

requireOppositePrevCandle = input.bool(true, "Require opposite previous candle color", group=grpLogic,
     tooltip="Bullish ke liye previous candle bearish aur bearish ke liye previous candle bullish honi chahiye.")

useStrictSweep = input.bool(true, "Strict liquidity sweep", group=grpLogic,
     tooltip="ON = wick previous high/low ko break kare. OFF = equal touch bhi chalega.")

useCloseConfirmation = input.bool(true, "Only confirmed bar signals", group=grpLogic,
     tooltip="ON par signal sirf candle close hone ke baad milega.")

plotSignals = input.bool(true, "Show signal arrows", group=grpSignal)
plotLabels  = input.bool(true, "Show text labels", group=grpSignal)

// Colors
weakBullColor   = input.color(color.lime,   "Weak Bullish Color", group=grpVisual)
strongBullColor = input.color(color.green,  "Strong Bullish Color", group=grpVisual)
weakBearColor   = input.color(color.orange, "Weak Bearish Color", group=grpVisual)
strongBearColor = input.color(color.red,    "Strong Bearish Color", group=grpVisual)

bullTextColor = input.color(color.white, "Bull Text Color", group=grpVisual)
bearTextColor = input.color(color.white, "Bear Text Color", group=grpVisual)

//══════════════════════════════════════════════════════════════════════════════
// PREVIOUS CANDLE DATA
//══════════════════════════════════════════════════════════════════════════════
prevOpen  = open[1]
prevHigh  = high[1]
prevLow   = low[1]
prevClose = close[1]

prevBodyHigh = math.max(prevOpen, prevClose)
prevBodyLow  = math.min(prevOpen, prevClose)

prevBull = prevClose > prevOpen
prevBear = prevClose < prevOpen

validBullPrev = requireOppositePrevCandle ? prevBear : true
validBearPrev = requireOppositePrevCandle ? prevBull : true

barConfirmed = useCloseConfirmation ? barstate.isconfirmed : true

//══════════════════════════════════════════════════════════════════════════════
// LIQUIDITY SWEEP
// Bullish = previous low sweep
// Bearish = previous high sweep
//══════════════════════════════════════════════════════════════════════════════
bullSweep = useStrictSweep ? (low < prevLow) : (low <= prevLow)
bearSweep = useStrictSweep ? (high > prevHigh) : (high >= prevHigh)

//══════════════════════════════════════════════════════════════════════════════
// LOGIC
//
// STRONG:
// Bullish  -> sweep + close > previous high
// Bearish  -> sweep + close < previous low
//
// WEAK:
// Bullish  -> sweep + bullish engulfing valid ho, but strong na ho
// Bearish  -> sweep + bearish engulfing valid ho, but strong na ho
//
// Weak ke liye yaha body engulfing base li gayi hai:
// Bullish  -> close > previous body high
// Bearish  -> close < previous body low
//
// Strong candles weak me count nahi hongi.
//══════════════════════════════════════════════════════════════════════════════
strongBull = barConfirmed and validBullPrev and bullSweep and close > prevHigh
strongBear = barConfirmed and validBearPrev and bearSweep and close < prevLow

weakBullBase = barConfirmed and validBullPrev and bullSweep and close > prevBodyHigh
weakBearBase = barConfirmed and validBearPrev and bearSweep and close < prevBodyLow

weakBull = weakBullBase and not strongBull
weakBear = weakBearBase and not strongBear

finalWeakBull   = showWeakBull and weakBull
finalStrongBull = showStrongBull and strongBull
finalWeakBear   = showWeakBear and weakBear
finalStrongBear = showStrongBear and strongBear

//══════════════════════════════════════════════════════════════════════════════
// SHAPES
//══════════════════════════════════════════════════════════════════════════════
plotshape(plotSignals and finalWeakBull, title="Weak Bullish Engulfing",
     style=shape.triangleup, location=location.belowbar, color=weakBullColor, size=size.small, text="WB")

plotshape(plotSignals and finalStrongBull, title="Strong Bullish Engulfing",
     style=shape.triangleup, location=location.belowbar, color=strongBullColor, size=size.small, text="SB")

plotshape(plotSignals and finalWeakBear, title="Weak Bearish Engulfing",
     style=shape.triangledown, location=location.abovebar, color=weakBearColor, size=size.small, text="WS")

plotshape(plotSignals and finalStrongBear, title="Strong Bearish Engulfing",
     style=shape.triangledown, location=location.abovebar, color=strongBearColor, size=size.small, text="SS")

//══════════════════════════════════════════════════════════════════════════════
// LABELS
//══════════════════════════════════════════════════════════════════════════════
if plotLabels and finalWeakBull
    label.new(bar_index, low, "Weak Bullish",
         style=label.style_label_up, color=weakBullColor, textcolor=bullTextColor, size=size.tiny)

if plotLabels and finalStrongBull
    label.new(bar_index, low, "Strong Bullish",
         style=label.style_label_up, color=strongBullColor, textcolor=bullTextColor, size=size.tiny)

if plotLabels and finalWeakBear
    label.new(bar_index, high, "Weak Bearish",
         style=label.style_label_down, color=weakBearColor, textcolor=bearTextColor, size=size.tiny)

if plotLabels and finalStrongBear
    label.new(bar_index, high, "Strong Bearish",
         style=label.style_label_down, color=strongBearColor, textcolor=bearTextColor, size=size.tiny)

//══════════════════════════════════════════════════════════════════════════════
// ALERTS
//══════════════════════════════════════════════════════════════════════════════
alertcondition(finalWeakBull,   title="Weak Bullish Engulfing",   message="Weak Bullish Liquidity Sweep Engulfing detected")
alertcondition(finalStrongBull, title="Strong Bullish Engulfing", message="Strong Bullish Liquidity Sweep Engulfing detected")
alertcondition(finalWeakBear,   title="Weak Bearish Engulfing",   message="Weak Bearish Liquidity Sweep Engulfing detected")
alertcondition(finalStrongBear, title="Strong Bearish Engulfing", message="Strong Bearish Liquidity Sweep Engulfing detected")
````
