# Niftybees / Goldbees Switch

- url: https://www.tradingview.com/script/K7NQONOJ-Niftybees-Goldbees-Switch/
- type: indicator
- pine_id: PUB;6cf0076cf33b46299432cc5358d081fb
- version: 1.0

## Description

The position is held until the opposite breakout flips it, so capital is always working in whichever asset is currently trending. Signals are confirmed on the daily candle close to avoid intraday whipsaws, with on-chart labels, holding-state shading, and alerts for each switch.

## Source Code

````pine
//@version=6
// ============================================================
//  Niftybees / Goldbees — Donchian Breakout Switch
//  One ratio. Two assets. Always invested.
//
//  Setup : ratio = NIFTYBEES close / GOLDBEES close  (this chart)
//          20-day rolling high / low, Close-to-Close
//          Signal triggers on the DAILY CANDLE CLOSE.
//
//  Ratio closes > prior 20-day high  ->  Buy NIFTYBEES (sell Goldbees)
//  Ratio closes < prior 20-day low   ->  Buy GOLDBEES (sell Niftybees)
//
//  Add this while the NIFTYBEES/GOLDBEES ratio chart is open (1D).
// ============================================================
indicator("Niftybees / Goldbees Switch", shorttitle="NB/GB Switch", overlay=true)

// -- Inputs --------------------------------------------------
length         = input.int(20, "Lookback (days)", minval=1)
confirmOnClose = input.bool(true, "Trigger only on daily close", tooltip="ON: the switch is decided by the closed daily candle - no intraday flip-flopping or repaint. OFF: evaluates live, intrabar.")
showLevels     = input.bool(true, "Show breakout levels")
shadeHold      = input.bool(true, "Shade current holding")

// -- Breakout levels: PRIOR N-day high / low, Close-to-Close --
// [1] shifts the window back one bar so today's close is excluded,
// giving the "prior 20-day high / low" the rules reference.
priorHigh = ta.highest(close, length)[1]
priorLow  = ta.lowest(close,  length)[1]

// -- Breakout tests (daily close vs prior level) -------------
breakUp = close > priorHigh      // ratio breaks up   -> Niftybees
breakDn = close < priorLow       // ratio breaks down -> Goldbees

// -- Regime (always invested): +1 = NIFTYBEES, -1 = GOLDBEES --
// Only commit the flip on a confirmed bar when confirmOnClose is ON,
// so live candles can't trigger and then reverse before the close.
var int regime = 0
doUpdate = confirmOnClose ? barstate.isconfirmed : true
regime := doUpdate ? (breakUp ? 1 : breakDn ? -1 : regime) : regime

// Fire a label only when the holding actually flips
switchToNifty = regime ==  1 and regime[1] !=  1
switchToGold  = regime == -1 and regime[1] != -1

// -- Plot the trigger levels ---------------------------------
plot(showLevels ? priorHigh : na, "Prior 20d high", color=color.new(color.teal,   0), style=plot.style_stepline, linewidth=1)
plot(showLevels ? priorLow  : na, "Prior 20d low",  color=color.new(color.orange, 0), style=plot.style_stepline, linewidth=1)

// -- Shade by what you currently hold ------------------------
bgcolor(shadeHold ? (regime == 1 ? color.new(color.teal, 90) : regime == -1 ? color.new(color.orange, 90) : na) : na)

// -- Switch labels -------------------------------------------
plotshape(switchToNifty, "Buy NIFTYBEES", shape.labelup, location.belowbar, color=color.new(color.teal, 0), text="Buy\nNIFTYBEES", textcolor=color.white, size=size.small)
plotshape(switchToGold, "Buy GOLDBEES", shape.labeldown, location.abovebar, color=color.new(color.orange, 0), text="Buy\nGOLDBEES", textcolor=color.white, size=size.small)

// -- Alerts (set frequency to "Once Per Bar Close") ----------
alertcondition(switchToNifty, "Switch to NIFTYBEES", "Ratio closed above prior 20-day high - sell Goldbees, deploy into Niftybees")
alertcondition(switchToGold, "Switch to GOLDBEES", "Ratio closed below prior 20-day low - sell Niftybees, deploy into Goldbees")
````
