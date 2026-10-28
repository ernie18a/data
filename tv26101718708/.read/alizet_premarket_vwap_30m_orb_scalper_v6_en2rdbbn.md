# ALIZET - Premarket + VWAP + 30m ORB Scalper v6

- url: https://www.tradingview.com/script/EN2rDBbn-ALIZET-Premarket-VWAP-30m-ORB-Scalper-v6/
- type: indicator
- pine_id: PUB;67958fcee3524db9b2da80b0b6f545b6
- version: 1.0

## Description

ALIZET - Premarket + VWAP + 30m ORB Scalper v6

A comprehensive intraday scalping indicator designed for SPY, QQQ, and other liquid equities. Combines three proven frameworks — Premarket levels, VWAP, and Opening Range Breakout — with overbought mean-reversion signals and automatic ATR-based exit targets.

Features:

🔵 VWAP — Dynamic intraday anchor plotted in orange. Used as an optional filter to confirm breakout direction.

🟡 Premarket High / Low — Automatically tracks the high and low from 4:00–9:30 AM. Key levels that often act as support and resistance during the regular session.

🟦 Opening Range Breakout (ORB) — Builds the opening range over a configurable window (default 30 min). Highlights the ORB formation period in blue. Plots ORB High (aqua) and ORB Low (fuchsia) for the remainder of the session.

🟢🔴 ORB Breakout Signals — Fires a LONG signal when price crosses above the ORB High, and a SHORT signal when price crosses below the ORB Low. Optional filters: VWAP direction and volume confirmation.

🟠 Overbought Sell Signals — Independent mean-reversion sell alerts triggered when RSI crosses above 70 (adjustable). Designed to catch overextended moves before a pullback.

📐 ATR Exit Levels — Every signal automatically plots three dashed exit targets at 1×, 1.5×, and 2× ATR from the entry price, labeled with exact prices. ORB signals use green/red; overbought signals use orange.

Settings:

Toggle each feature on/off independently
Configurable ORB window (5–60 min)
ATR length (default 14)
RSI length and overbought threshold
Volume MA filter with multiplier
Custom premarket and RTH session times
Best used on: 1m, 2m, 5m timeframes during regular US market hours.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © afdzjr69
//@version=6
indicator("ALIZET - Premarket + VWAP + 30m ORB Scalper v6", overlay = true, max_lines_count = 500, max_labels_count = 500)
// ---------- Inputs ----------
showVWAP      = input.bool(true, "Show VWAP")
showPremarket = input.bool(true, "Show Premarket High/Low")
showORB       = input.bool(true, "Show Opening Range")
orbMinutes    = input.int(30, "Opening Range Minutes", minval = 5, maxval = 60, step = 5)
showSignals   = input.bool(true, "Show Breakout Signals")
useVWAPFilter = input.bool(true, "Require VWAP Filter")
useVolFilter  = input.bool(false, "Require Volume Filter")
volLength     = input.int(20, "Volume MA Length", minval = 1)
volMult       = input.float(1.2, "Volume Multiplier", minval = 0.1, step = 0.1)
showATRExits  = input.bool(true, "Show ATR Exit Levels")
atrLength     = input.int(14, "ATR Length", minval = 1)
showOBSignals = input.bool(true, "Show Overbought Sell Signals")
rsiLength     = input.int(14, "RSI Length", minval = 1)
rsiOBLevel    = input.float(70.0, "RSI Overbought Level", minval = 50, maxval = 90, step = 1)
premarketSession = input.session("0400-0930", "Premarket Session")
rthSession       = input.session("0930-1600", "Regular Session")
// ---------- Session state ----------
bool inPremarket = not na(time(timeframe.period, premarketSession))
bool inRTH       = not na(time(timeframe.period, rthSession))
bool newDay      = ta.change(time("D")) != 0
bool rthStart    = inRTH and not inRTH[1]
// ---------- VWAP ----------
float vwapValue = ta.vwap(hlc3)
plot(showVWAP ? vwapValue : na, "VWAP", color = color.orange, linewidth = 2)
// ---------- Premarket High / Low ----------
var float pmHigh = na
var float pmLow  = na
if newDay
    pmHigh := na
    pmLow  := na
if inPremarket
    pmHigh := na(pmHigh) ? high : math.max(pmHigh, high)
    pmLow  := na(pmLow) ? low : math.min(pmLow, low)
plot(showPremarket and not na(pmHigh) ? pmHigh : na, "Premarket High", color = color.new(color.green, 0), linewidth = 2, style = plot.style_linebr)
plot(showPremarket and not na(pmLow) ? pmLow : na, "Premarket Low", color = color.new(color.red, 0), linewidth = 2, style = plot.style_linebr)
// ---------- Opening Range ----------
var float orbHigh = na
var float orbLow  = na
var int orbStartTime = na
var bool orbDone = false
if rthStart
    orbHigh := high
    orbLow := low
    orbStartTime := time
    orbDone := false
else if inRTH and not orbDone
    orbHigh := math.max(orbHigh, high)
    orbLow := math.min(orbLow, low)
    orbDone := time >= orbStartTime + orbMinutes * 60 * 1000
plot(showORB and inRTH and not na(orbHigh) ? orbHigh : na, "ORB High", color = color.aqua, linewidth = 2, style = plot.style_linebr)
plot(showORB and inRTH and not na(orbLow) ? orbLow : na, "ORB Low", color = color.fuchsia, linewidth = 2, style = plot.style_linebr)
// ---------- Filters ----------
float volMA = ta.sma(volume, volLength)
bool volOkay = volume > volMA * volMult
bool longVWAP = close > vwapValue
bool shortVWAP = close < vwapValue
// ---------- ORB Signals ----------
bool longBreak = inRTH and orbDone and ta.crossover(close, orbHigh)
bool shortBreak = inRTH and orbDone and ta.crossunder(close, orbLow)
bool longSignal  = longBreak  and (not useVWAPFilter or longVWAP)  and (not useVolFilter or volOkay)
bool shortSignal = shortBreak and (not useVWAPFilter or shortVWAP) and (not useVolFilter or volOkay)
// ---------- ATR ----------
float atrValue = ta.atr(atrLength)
// ---------- Overbought Sell Signal ----------
float rsiValue   = ta.rsi(close, rsiLength)
bool obSellSignal = showOBSignals and ta.crossover(rsiValue, rsiOBLevel)
// ---------- ORB Signal Labels ----------
if showSignals and longSignal
    label.new(bar_index, low, "LONG\nORB + VWAP", style = label.style_label_up, color = color.green, textcolor = color.white)
if showSignals and shortSignal
    label.new(bar_index, high, "SHORT\nORB + VWAP", style = label.style_label_down, color = color.red, textcolor = color.white)
// ---------- Overbought Label ----------
if obSellSignal
    label.new(bar_index, high, "SELL\nOverbought", style = label.style_label_down, color = color.new(color.orange, 10), textcolor = color.white)
// ---------- ATR Exit Lines — ORB signals (most recent only) ----------
var line atrL1 = na
var line atrL2 = na
var line atrL3 = na
var label atrLbl1 = na
var label atrLbl2 = na
var label atrLbl3 = na
if showATRExits and (longSignal or shortSignal)
    line.delete(atrL1)
    line.delete(atrL2)
    line.delete(atrL3)
    label.delete(atrLbl1)
    label.delete(atrLbl2)
    label.delete(atrLbl3)
    float dir = longSignal ? 1.0 : -1.0
    color col = longSignal ? color.green : color.red
    float t1  = close + dir * 1.0 * atrValue
    float t2  = close + dir * 1.5 * atrValue
    float t3  = close + dir * 2.0 * atrValue
    atrL1   := line.new(bar_index, t1, bar_index + 1, t1, extend = extend.right, color = color.new(col, 55), width = 1, style = line.style_dashed)
    atrL2   := line.new(bar_index, t2, bar_index + 1, t2, extend = extend.right, color = color.new(col, 30), width = 1, style = line.style_dashed)
    atrL3   := line.new(bar_index, t3, bar_index + 1, t3, extend = extend.right, color = col, width = 2, style = line.style_dashed)
    atrLbl1 := label.new(bar_index, t1, "1R  " + str.tostring(t1, format.mintick), style = label.style_label_right, color = color.new(col, 55), textcolor = color.white, size = size.small)
    atrLbl2 := label.new(bar_index, t2, "1.5R  " + str.tostring(t2, format.mintick), style = label.style_label_right, color = color.new(col, 30), textcolor = color.white, size = size.small)
    atrLbl3 := label.new(bar_index, t3, "2R  " + str.tostring(t3, format.mintick), style = label.style_label_right, color = col, textcolor = color.white, size = size.small)
// ---------- ATR Exit Lines — Overbought Sell (most recent only) ----------
var line obL1 = na
var line obL2 = na
var line obL3 = na
var label obLbl1 = na
var label obLbl2 = na
var label obLbl3 = na
if showATRExits and obSellSignal
    line.delete(obL1)
    line.delete(obL2)
    line.delete(obL3)
    label.delete(obLbl1)
    label.delete(obLbl2)
    label.delete(obLbl3)
    float t1 = close - 1.0 * atrValue
    float t2 = close - 1.5 * atrValue
    float t3 = close - 2.0 * atrValue
    obL1   := line.new(bar_index, t1, bar_index + 1, t1, extend = extend.right, color = color.new(color.orange, 55), width = 1, style = line.style_dashed)
    obL2   := line.new(bar_index, t2, bar_index + 1, t2, extend = extend.right, color = color.new(color.orange, 30), width = 1, style = line.style_dashed)
    obL3   := line.new(bar_index, t3, bar_index + 1, t3, extend = extend.right, color = color.orange, width = 2, style = line.style_dashed)
    obLbl1 := label.new(bar_index, t1, "1R  " + str.tostring(t1, format.mintick), style = label.style_label_right, color = color.new(color.orange, 55), textcolor = color.white, size = size.small)
    obLbl2 := label.new(bar_index, t2, "1.5R  " + str.tostring(t2, format.mintick), style = label.style_label_right, color = color.new(color.orange, 30), textcolor = color.white, size = size.small)
    obLbl3 := label.new(bar_index, t3, "2R  " + str.tostring(t3, format.mintick), style = label.style_label_right, color = color.orange, textcolor = color.white, size = size.small)
// ---------- Background ----------
bgcolor(inPremarket ? color.new(color.yellow, 92) : na, title = "Premarket Background")
bgcolor(inRTH and not orbDone ? color.new(color.blue, 94) : na, title = "Opening Range Window")
// ---------- Alerts ----------
alertcondition(longSignal,   "Long ORB + VWAP",  "Long signal: Price broke above opening range high and passed filters.")
alertcondition(shortSignal,  "Short ORB + VWAP", "Short signal: Price broke below opening range low and passed filters.")
alertcondition(obSellSignal, "Overbought Sell",  "Sell signal: RSI crossed above overbought level.")
plot(close)
````
