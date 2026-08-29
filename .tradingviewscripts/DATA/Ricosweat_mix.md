<!-- tradingview-pine-id: PUB;1fc90c34ffcb4c97b504df3103a60092 -->
<!-- tradingviewscripts-format: 1 -->
# Ricosweat mix

Source: https://www.tradingview.com/script/oqiPdbTS-Ricosweat-mix/

## Description

Ricosweat Mix is a multi‑framework market‑structure and trend‑context indicator designed for intraday and swing traders who want a clean, actionable dashboard of higher‑timeframe trend, dynamic moving averages, VWAP structure, S/R flips, and candle‑by‑candle momentum shifts.
This script blends several high‑value components into one unified overlay, helping traders quickly understand trend direction, intraday bias, and key reaction zones without clutter.

Core Features
1. Higher‑Timeframe Trend Filter (HTF)
Pulls EMA‑200 from a user‑selectable higher timeframe (default: 60‑minute).

Provides a simple visual trend bias so traders can align entries with HTF momentum.

2. Moving Averages Suite
Configurable and color‑coded:

9 EMA – short‑term momentum

21 EMA – micro‑trend

200 EMA – macro‑trend anchor

Session VWAP – institutional volume‑weighted mean

Optional VWAP Standard Deviation Bands for volatility context

These help identify pullbacks, trend continuation zones, and dynamic support/resistance.

3. Pivot‑Based Support & Resistance Flips
Automatic detection of pivot highs/lows using left/right bar inputs

Highlights S/R flips, a powerful price‑reaction signal used by discretionary traders

Custom colors for support vs. resistance

4. First‑Hour Initial Balance (IB)
Plots the 0930–1030 session IB (configurable)

Helps traders track range expansion, breakout conditions, and opening‑drive behavior

Clean IB high/low lines with customizable color

5. CBC (Candle‑By‑Candle) Trend Flips
Highlights bullish or bearish candle‑by‑candle shifts

Useful for scalpers and momentum traders

Custom bull/bear colors for instant visual recognition

What This Indicator Helps You Do
Quickly identify trend alignment across multiple timeframes

Spot high‑probability pullback zones using EMAs and VWAP

Track intraday structure via IB and pivot‑based S/R

Recognize micro‑momentum shifts with CBC flips

Reduce chart clutter by combining several tools into one unified overlay

Ideal For
Intraday futures traders (NQ, ES, SPY, QQQ)

Momentum scalpers

Trend‑following traders

Anyone wanting a clean, multi‑signal overlay without over‑complication

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Quant

//@version=6
indicator("Ricosweat mix", overlay=true, max_lines_count=500, max_labels_count=500)

// --- Settings ---
// CBC Settings
groupCbc = "CBC (Candle-By-Candle) Flip"
showCbc = input.bool(true, "Show CBC Flips", group=groupCbc)
colorBullCbc = input.color(#089981, "Bullish CBC", group=groupCbc)
colorBearCbc = input.color(#f23645, "Bearish CBC", group=groupCbc)

// First Hour IB Settings
groupIb = "First Hour Initial Balance (IB)"
showIb = input.bool(true, "Show First Hour IB", group=groupIb)
sess = input.session("0930-1030", "IB Session", group=groupIb)
ibLineColor = input.color(color.blue, "IB Line Color", group=groupIb)

// S/R Flip Settings
groupSr = "S/R Flip (Pivot Based)"
showSr = input.bool(true, "Show S/R Flips", group=groupSr)
leftBars = input.int(2, "Pivot Left Bars", group=groupSr)
rightBars = input.int(2, "Pivot Right Bars", group=groupSr)
colorSrRes = input.color(color.red, "Resistance Color", group=groupSr)
colorSrSup = input.color(color.green, "Support Color", group=groupSr)

// Moving Averages & VWAP Settings
groupMa = "Moving Averages & VWAP"
showEma9 = input.bool(true, "Show 9 EMA", group=groupMa)
colorEma9 = input.color(color.new(color.yellow, 0), "9 EMA Color", group=groupMa)

showEma21 = input.bool(true, "Show 21 EMA", group=groupMa)
colorEma21 = input.color(color.new(color.blue, 0), "21 EMA Color", group=groupMa)

showEma200 = input.bool(true, "Show 200 EMA", group=groupMa)
colorEma200 = input.color(color.new(color.purple, 0), "200 EMA Color", group=groupMa)

showVwap = input.bool(true, "Show Session VWAP", group=groupMa)
colorVwap = input.color(color.new(color.white, 0), "VWAP Color", group=groupMa)

showVwapBands = input.bool(false, "Show VWAP Bands (StDev)", group=groupMa, tooltip="Check to show upper/lower 2 StdDev VWAP bands")

// HTF Trend Settings
groupHtf = "Higher Timeframe Trend"
showHtf = input.bool(true, "Show HTF Trend Dashboard", group=groupHtf)
htfRes = input.timeframe("60", "HTF Resolution", group=groupHtf)

// --- Logic: HTF Trend Filter ---
htfEma200 = request.security(syminfo.tickerid, htfRes, ta.ema(close, 200))
htfClose = request.security(syminfo.tickerid, htfRes, close)
isHtfBullish = htfClose > htfEma200

if showHtf
    var table htfTable = table.new(position.top_right, 1, 1, border_width = 1)
    table.cell(htfTable, 0, 0, "HTF (" + htfRes + ") Trend: " + (isHtfBullish ? "BULL" : "BEAR"), 
      bgcolor=isHtfBullish ? color.new(color.green, 80) : color.new(color.red, 80), 
      text_color=color.white, text_size=size.small)

// --- Logic: EMAs & VWAP ---
ema9 = ta.ema(close, 9)
ema21 = ta.ema(close, 21)
ema200 = ta.ema(close, 200)

plot9 = plot(showEma9 ? ema9 : na, title="9 EMA", color=colorEma9, linewidth=1)
plot21 = plot(showEma21 ? ema21 : na, title="21 EMA", color=colorEma21, linewidth=1)
plot(showEma200 ? ema200 : na, title="200 EMA", color=colorEma200, linewidth=3)

// EMA Trend Ribbon
ribbonColor = ema9 > ema21 ? color.new(#089981, 85) : color.new(#f23645, 85)
fill(plot9, plot21, color=ribbonColor, title="EMA Ribbon")

var float vwapValue = na
var float vwapUpper = na
var float vwapLower = na

if showVwap
    [v, u, l] = ta.vwap(hlc3, true, 1)
    vwapValue := v
    vwapUpper := u
    vwapLower := l

plot(showVwap ? vwapValue : na, title="VWAP", color=colorVwap, linewidth=2, style=plot.style_linebr)
plot(showVwapBands and showVwap ? vwapUpper : na, title="VWAP Upper", color=color.new(colorVwap, 70), style=plot.style_linebr)
plot(showVwapBands and showVwap ? vwapLower : na, title="VWAP Lower", color=color.new(colorVwap, 70), style=plot.style_linebr)


// --- Logic: First Hour IB ---
var float ibHigh = na
var float ibLow = na
var line ibTopLine = na
var line ibBotLine = na

inSession = not na(time(timeframe.period, sess))
isSessionStart = inSession and not inSession[1]
isSessionEnd = not inSession and inSession[1]

if isSessionStart
    ibHigh := high
    ibLow := low
else if inSession
    ibHigh := math.max(ibHigh, high)
    ibLow := math.min(ibLow, low)

if isSessionStart and showIb
    ibTopLine := line.new(bar_index, ibHigh, bar_index, ibHigh, color=ibLineColor, style=line.style_dashed)
    ibBotLine := line.new(bar_index, ibLow, bar_index, ibLow, color=ibLineColor, style=line.style_dashed)
else if inSession and showIb
    line.set_y2(ibTopLine, ibHigh)
    line.set_y1(ibTopLine, ibHigh)
    line.set_x2(ibTopLine, bar_index)
    line.set_y2(ibBotLine, ibLow)
    line.set_y1(ibBotLine, ibLow)
    line.set_x2(ibBotLine, bar_index)
else if showIb and not na(ibTopLine)
    // Extend lines for the day
    line.set_x2(ibTopLine, bar_index)
    line.set_x2(ibBotLine, bar_index)

// Alert for IB Breakout (only triggers after IB session forms)
if ta.crossover(close, ibHigh) and not inSession
    alert("Price broke above IB High", alert.freq_once_per_bar_close)
if ta.crossunder(close, ibLow) and not inSession
    alert("Price broke below IB Low", alert.freq_once_per_bar_close)

// --- Logic: CBC Flip ---
var bool isBullishCbc = false

bool potBull = not isBullishCbc and close > high[1]
bool potBear = isBullishCbc and close < low[1]

if potBull
    isBullishCbc := true
if potBear
    isBullishCbc := false

bool bullFlip = potBull
bool bearFlip = potBear

if bullFlip and showCbc
    label.new(bar_index, low, "▲", color=color.new(color.white, 100), textcolor=colorBullCbc, style=label.style_label_up, size=size.small)
    alert("Bullish CBC Flip", alert.freq_once_per_bar_close)
    
if bearFlip and showCbc
    label.new(bar_index, high, "▼", color=color.new(color.white, 100), textcolor=colorBearCbc, style=label.style_label_down, size=size.small)
    alert("Bearish CBC Flip", alert.freq_once_per_bar_close)

// --- Logic: S/R Flips (Pivot based Support turning Resistance or vice versa) ---
float ph = ta.pivothigh(high, leftBars, rightBars)
float pl = ta.pivotlow(low, leftBars, rightBars)

float avgVol = ta.sma(volume, 20)

var float lastRes = na
var float lastSup = na
var line resLine = na
var line supLine = na
var label resLabel = na
var label supLabel = na
var bool resIsStrong = false
var bool supIsStrong = false

if not na(ph)
    lastRes := ph
    resIsStrong := volume[rightBars] > avgVol[rightBars]
    if showSr
        resLine := line.new(bar_index[rightBars], ph, bar_index, ph, color=colorSrRes, style=line.style_solid, width=resIsStrong ? 2 : 1)
        string strTxt = resIsStrong ? "Strong Resistance: " : "Resistance: "
        resLabel := label.new(bar_index, ph, strTxt, color=color.new(color.white, 100), textcolor=colorSrRes, style=label.style_label_down, size=size.tiny)
if not na(pl)
    lastSup := pl
    supIsStrong := volume[rightBars] > avgVol[rightBars]
    if showSr
        supLine := line.new(bar_index[rightBars], pl, bar_index, pl, color=colorSrSup, style=line.style_solid, width=supIsStrong ? 2 : 1)
        string strTxt = supIsStrong ? "Strong Support: " : "Support: "
        supLabel := label.new(bar_index, pl, strTxt, color=color.new(color.white, 100), textcolor=colorSrSup, style=label.style_label_up, size=size.tiny)

// S/R Alerts and Clearing
if not na(lastRes) and close > lastRes
    alert("Price broke Resistance level", alert.freq_once_per_bar_close)
    if showSr
        lastRes := na 

if not na(lastSup) and close < lastSup
    alert("Price broke Support level", alert.freq_once_per_bar_close)
    if showSr
        lastSup := na 

if showSr and not na(resLine)
    line.set_x2(resLine, bar_index)
    if not na(resLabel)
        label.set_x(resLabel, bar_index)
        float pctRes = math.abs(close - lastRes) / lastRes * 100
        string prefix = resIsStrong ? "Strong Resistance: " : "Resistance: "
        label.set_text(resLabel, prefix + str.tostring(pctRes, "#.##") + "%")
if showSr and not na(supLine)
    line.set_x2(supLine, bar_index)
    if not na(supLabel)
        label.set_x(supLabel, bar_index)
        float pctSup = math.abs(close - lastSup) / lastSup * 100
        string prefix = supIsStrong ? "Strong Support: " : "Support: "
        label.set_text(supLabel, prefix + str.tostring(pctSup, "#.##") + "%")
````
