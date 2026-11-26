# Advanced Market Condition & Momentum

- url: https://www.tradingview.com/script/98UPkJbs-Advanced-Market-Condition-Momentum/
- type: indicator
- pine_id: PUB;fbab3be0b3254b0bb27e3f3efe174e15
- version: 1.0

## Description

The Advanced Market Condition & Momentum indicator is now available in your editor. This tool is designed to provide professional-grade market context, momentum analysis, and liquidity confirmation without the noise of traditional retail indicators.

Core Engines Implemented
Trend Quality Engine (0–100 Score):

Analyzes Candle Overlap (indecision vs. conviction).
Measures Directional Efficiency (net displacement vs. total movement).
Monitors Wick Frequency to detect auction instability.
Visual: Reflected in the dashboard score and candle transparency.
Momentum Decay Engine:

Detects Expansion (high volume/range impulses).
Identifies Decay when range and volume contract immediately following an impulse.
Visual: Highlights the background with a subtle red fade when momentum is exhausting.
Liquidity Sweep Confirmation:

Tracks previous Pivot Highs/Lows (Fractals).
Detects price piercing these levels and closing back inside.
Confirmation Logic: Only marks a sweep if it is followed by displacement (range expansion).
Visual: Triangle markers (▲/▼) below/above candles.
Market Condition Classifier:

Categorizes the environment into Expansion Trend, Chop/Rotation, Neutral, or Extreme Volatility based on ATR relative to historical averages and the Trend Quality score.
Candle Efficiency Engine:

Color-codes bars based on the quality of the move.
Bright Green/Red: High-efficiency directional control.
Blue (Neutral): Absorption (large range but weak close).
Grey: Low-quality chop or indecision.
Best Practices for Use
Trend Quality: Avoid entering new trend-following positions when the score is below 40 (Chop).
Momentum Decay: Use the background highlights as a "caution" sign to tighten stops or take profits on existing runners.
Liquidity Sweeps: A confirmed sweep (triangle) indicates high-probability rejection, especially when the Trend Quality score is neutral or rotating.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LuxAlgo

//@version=6
indicator("Advanced Market Condition & Momentum", shorttitle="Lux_AMC", overlay=true, max_labels_count=500)

// --- Manual Functions to bypass namespace issues ---
sma_manual(src, len) =>
    float sum = 0.0
    for i = 0 to len - 1
        sum += src[i]
    sum / len

sum_manual(src, len) =>
    float sum = 0.0
    for i = 0 to len - 1
        sum += src[i]
    sum

clamp_manual(val, min_v, max_v) =>
    math.max(min_v, math.min(max_v, val))

// --- Inputs ---
trendLen    = input.int(14, "Trend Quality Lookback", minval=5)
overlapLen  = input.int(10, "Overlap Smoothing", minval=1)
momLen      = input.int(10, "Momentum Lookback", minval=3)
volLen      = input.int(20, "Volume Average Length", minval=5)
liqLen      = input.int(20, "Liquidity Pivot Lookback", minval=5)
showDash    = input.bool(true, "Show Dashboard")
dashPos     = input.string("top_right", "Position", options=["top_right", "bottom_right", "top_left", "bottom_left"])

// Colors
colorBull   = #089981
colorBear   = #f23645
colorNeut   = #5b9cf6
colorChop   = #787b86

// --- Calculations ---

// 1. Trend Quality
cRange      = high - low
overlapVal  = math.max(0, math.min(high, high[1]) - math.max(low, low[1]))
overlapR    = sma_manual(nz(overlapVal / math.max(cRange, 0.001)), overlapLen)
displace    = math.abs(close - close[trendLen])
totalM      = sum_manual(cRange, trendLen)
efficiency  = (displace / math.max(totalM, 0.001)) * 100
wicks       = (high - math.max(open, close)) + (math.min(open, close) - low)
wToB        = wicks / math.max(math.abs(open - close), 0.001)
avgWickR    = sma_manual(wToB, trendLen)

tqScore     = clamp_manual((efficiency * 0.5) + ((1 - math.min(overlapR, 1)) * 30) + (math.max(0, 20 - avgWickR * 5)), 0, 100)

// 2. Momentum Decay
avgC        = sma_manual(cRange, momLen)
avgV        = sma_manual(volume, volLen)
cStrB       = (close - low) / math.max(cRange, 0.001)
cStrS       = (high - close) / math.max(cRange, 0.001)
isExp       = cRange > avgC * 1.5 and volume > avgV

var bool inExp = false
var int expBars = 0
if isExp
    inExp := true
    expBars := 0
else
    expBars += 1

isDecay     = inExp and expBars > 0 and expBars <= 5 and (cRange < cRange[1] or volume < volume[1])
if expBars > 5 or (close > open ? cStrB < 0.3 : cStrS < 0.3)
    inExp := false

// 3. Liquidity Sweep
ph = ta.pivothigh(liqLen, liqLen)
pl = ta.pivotlow(liqLen, liqLen)
var float lPH = na
var float lPL = na
if not na(ph)
    lPH := ph
if not na(pl)
    lPL := pl

atr = ta.atr(14)
bSweep = low < lPL and close > lPL and (close - low) > (atr * 0.3)
sSweep = high > lPH and close < lPH and (high - close) > (atr * 0.3)
confBSweep = bSweep and cRange > avgC
confSSweep = sSweep and cRange > avgC

// 4. State
vState  = atr / math.max(ta.sma(atr, 100), 0.001)
isChop  = overlapR > 0.5 or tqScore < 40
isTrend = tqScore > 60
mState  = isChop ? "Chop" : isTrend ? "Trend" : "Neutral"
if vState > 1.8
    mState := "Extreme"

// 5. Candle Quality
effVal  = close > open ? cStrB : cStrS
highEff = effVal > 0.8
absorb  = cRange > avgC and effVal < 0.3

// --- Visuals ---
barC = highEff ? (close > open ? colorBull : colorBear) : 
       absorb ? colorNeut : 
       isChop ? colorChop : 
       (close > open ? color.new(colorBull, 50) : color.new(colorBear, 50))

barcolor(barC)
plotshape(confBSweep, "Bull Sweep", shape.triangleup, location.belowbar, colorBull, size=size.small)
plotshape(confSSweep, "Bear Sweep", shape.triangledown, location.abovebar, colorBear, size=size.small)
bgcolor(isDecay ? color.new(colorBear, 95) : na)

// --- Dashboard ---
if showDash and barstate.islast
    dashPosConst = dashPos == "top_right" ? position.top_right : dashPos == "bottom_right" ? position.bottom_right : dashPos == "top_left" ? position.top_left : position.bottom_left
    dash = table.new(dashPosConst, 2, 6, bgcolor=color.new(chart.bg_color, 10), border_width=1, border_color=chart.fg_color)
    
    table.cell(dash, 0, 0, "Metric", text_color=chart.fg_color)
    table.cell(dash, 1, 0, "Status", text_color=chart.fg_color)
    
    tqC = tqScore > 75 ? colorBull : tqScore > 50 ? colorNeut : colorBear
    table.cell(dash, 0, 1, "Trend Quality", text_color=chart.fg_color)
    table.cell(dash, 1, 1, str.tostring(math.round(tqScore)), bgcolor=tqC, text_color=color.white)
    
    mC = isExp ? colorBull : isDecay ? colorBear : colorNeut
    table.cell(dash, 0, 2, "Momentum", text_color=chart.fg_color)
    table.cell(dash, 1, 2, isExp ? "Expanding" : isDecay ? "Decaying" : "Stable", bgcolor=mC, text_color=color.white)
    
    table.cell(dash, 0, 3, "Condition", text_color=chart.fg_color)
    table.cell(dash, 1, 3, mState, text_color=chart.fg_color)
    
    table.cell(dash, 0, 4, "Efficiency", text_color=chart.fg_color)
    table.cell(dash, 1, 4, highEff ? "High" : absorb ? "Absorption" : "Mid", text_color=chart.fg_color)

    table.cell(dash, 0, 5, "Liquidity", text_color=chart.fg_color)
    table.cell(dash, 1, 5, confBSweep or confSSweep ? "Sweep Confirmed" : "Searching", text_color=chart.fg_color)
````
