# Supertrend Nexus

- url: https://www.tradingview.com/script/c8NoI0Hw-Supertrend-Nexus/
- type: indicator
- pine_id: PUB;6d063a6d21994d55be916eca5361c551
- version: 1.0

## Description

Supertrend Nexus

A next-generation trend engine built around the core principles of Supertrend, enhanced with adaptive volatility, trend quality analysis, efficiency measurement, and multi-timeframe confirmation.

Traditional Supertrend indicators are designed to answer one primary question:

"Has trend direction changed?"

Supertrend Nexus expands on that concept by transforming a simple trend-following system into a complete market interpretation framework designed to answer:

• Is the trend strengthening or weakening?
• Is movement efficient or choppy?
• Is higher timeframe direction supporting the move?
• Is current price action extended?
• Is continuation or exhaustion more likely?
• Is the setup high quality or lower probability?

Features

Adaptive Supertrend Engine

Builds upon traditional ATR-based Supertrend calculations
Optional adaptive multiplier system
Automatically adjusts sensitivity based on market efficiency
Helps reduce noise while responding more dynamically to changing market conditions

Efficiency Ratio Analysis

Measures directional movement relative to market noise
Identifies whether price action is efficient or choppy
Helps filter lower-quality conditions

Higher Timeframe Alignment

Optional HTF trend confirmation
Compares local trend conditions against broader market direction
Helps align setups with larger directional pressure

EMA Trend Confirmation

Additional trend validation layer
Helps identify whether price is trading with or against prevailing direction

Trend Quality Scoring
Combines multiple components into an overall signal-strength framework:

• Trend alignment
• Higher timeframe agreement
• Efficiency ratio
• Distance from Supertrend
• Adaptive trend behavior

Decision Dashboard

Supertrend Nexus converts raw market data into a simplified decision engine.

Includes:

• Market State analysis
• Signal Strength meter
• Trade Quality grading
• Trend direction classification
• Higher timeframe alignment
• Efficiency state
• Risk and behavior analysis
• Next-action guidance

Market State Examples

Bullish Trend Confirmed

Trend direction and confirmations aligned

Bearish Trend Confirmed

Downside trend pressure supported by confirmation filters

Bullish / HTF Conflict

Local direction differs from broader market trend

Mixed Trend State

Conditions are conflicting or lower quality
Risk / Behavior Examples

Examples may include:

• Continuation favored
• Pullback risk increasing
• Choppy conditions present
• Whipsaw risk elevated
• Extended trend behavior

Suggested Uses

Can be combined with:

• Market structure
• Supply and demand zones
• Liquidity sweeps
• Volume Profile / POC analysis
• Higher timeframe bias
• Risk management systems

About TrendGenY Indicators

[i]TrendGenY indicators are built from market experience, creative concepts, and a constant pursuit of unique perspectives. Rather than following conventional ideas, the focus is on uncovering alternative insights and viewing market behavior through different angles to reveal information that traditional tools may overlook and help traders build a more meaningful edge in the market.[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TrendGenY

//@version=5
indicator("TrendGenY Supertrend Nexus", shorttitle="Supertrend Nexus", overlay=true, max_labels_count=500)

//────────────────────
// Inputs
//────────────────────
src = input.source(hl2, "Source")

gCore = "Supertrend Core"
atrLen = input.int(10, "ATR Period", minval=1, group=gCore)
baseMult = input.float(3.0, "Base ATR Multiplier", step=0.1, group=gCore)
atrMethod = input.string("RMA", "ATR Method", options=["RMA", "SMA"], group=gCore)

gAdaptive = "Adaptive Engine"
useAdaptive = input.bool(true, "Use Adaptive Multiplier", group=gAdaptive)
erLen = input.int(20, "Efficiency Length", minval=2, group=gAdaptive)
minMult = input.float(1.8, "Minimum Multiplier", step=0.1, group=gAdaptive)
maxMult = input.float(4.5, "Maximum Multiplier", step=0.1, group=gAdaptive)

gTrend = "Confirmation"
emaLen = input.int(50, "Trend EMA Length", group=gTrend)
useHTF = input.bool(true, "Use HTF Confirmation", group=gTrend)
htf = input.timeframe("60", "Higher Timeframe", group=gTrend)

gVisual = "Visuals"
showSignals = input.bool(true, "Show Buy/Sell Signals", group=gVisual)
showDashboard = input.bool(true, "Show Dashboard", group=gVisual)
showFill = input.bool(true, "Show Trend Fill", group=gVisual)
tableSize = input.string("Small", "Table Size", options=["Tiny", "Small", "Normal", "Large"], group=gVisual)
tablePos = input.string("Top Right", "Table Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=gVisual)

bullColor = input.color(color.lime, "Bullish Color", group=gVisual)
bearColor = input.color(color.red, "Bearish Color", group=gVisual)
neutralColor = input.color(color.gray, "Neutral Color", group=gVisual)
warningColor = input.color(color.orange, "Warning Color", group=gVisual)
headerBg = input.color(color.black, "Header Background", group=gVisual)
labelBg = input.color(color.rgb(20, 24, 32), "Label Background", group=gVisual)
textColor = input.color(color.white, "Text Color", group=gVisual)

//────────────────────
// ATR
//────────────────────
tr = ta.tr(true)
atrSma = ta.sma(tr, atrLen)
atrRma = ta.atr(atrLen)
atr = atrMethod == "RMA" ? atrRma : atrSma

//────────────────────
// Efficiency Ratio
//────────────────────
direction = math.abs(close - close[erLen])
noise = math.sum(math.abs(close - close[1]), erLen)
er = noise != 0 ? direction / noise : 0.0

// Higher ER = cleaner trend = tighter multiplier
adaptiveMult = maxMult - ((maxMult - minMult) * er)
mult = useAdaptive ? adaptiveMult : baseMult

//────────────────────
// Supertrend Core
//────────────────────
upperBand = src + mult * atr
lowerBand = src - mult * atr

prevUpper = nz(upperBand[1], upperBand)
prevLower = nz(lowerBand[1], lowerBand)

lowerBand := close[1] > prevLower ? math.max(lowerBand, prevLower) : lowerBand
upperBand := close[1] < prevUpper ? math.min(upperBand, prevUpper) : upperBand

trend = 1
trend := nz(trend[1], trend)
trend := trend == -1 and close > prevUpper ? 1 : trend == 1 and close < prevLower ? -1 : trend

bullFlip = trend == 1 and trend[1] == -1
bearFlip = trend == -1 and trend[1] == 1

activeLine = trend == 1 ? lowerBand : upperBand

//────────────────────
// Confirmation
//────────────────────
ema = ta.ema(close, emaLen)
trendAligned = trend == 1 ? close > ema : close < ema

f_htfTrend() =>
    hAtr = ta.atr(atrLen)
    hUpper = hl2 + baseMult * hAtr
    hLower = hl2 - baseMult * hAtr

    hPrevUpper = nz(hUpper[1], hUpper)
    hPrevLower = nz(hLower[1], hLower)

    hLower := close[1] > hPrevLower ? math.max(hLower, hPrevLower) : hLower
    hUpper := close[1] < hPrevUpper ? math.min(hUpper, hPrevUpper) : hUpper

    hTrend = 1
    hTrend := nz(hTrend[1], hTrend)
    hTrend := hTrend == -1 and close > hPrevUpper ? 1 : hTrend == 1 and close < hPrevLower ? -1 : hTrend
    hTrend

htfTrend = request.security(syminfo.tickerid, htf, f_htfTrend(), barmerge.gaps_off, barmerge.lookahead_off)
htfAligned = trend == htfTrend

//────────────────────
// Trend Quality Score
//────────────────────
distanceFromLine = math.abs(close - activeLine)
distanceATR = atr != 0 ? distanceFromLine / atr : 0

score = 0.0
score += trendAligned ? 25 : 0
score += htfAligned ? 25 : 0
score += er > 0.50 ? 25 : er > 0.30 ? 15 : 5
score += distanceATR > 0.75 ? 15 : 8
score += useAdaptive ? 10 : 0
score := math.min(score, 100)

grade =
     score >= 85 ? "A+" :
     score >= 75 ? "A" :
     score >= 65 ? "B+" :
     score >= 55 ? "B" :
     score >= 45 ? "C" :
     "Avoid"

state =
     trend == 1 and trendAligned and htfAligned ? "Bullish Trend Confirmed" :
     trend == -1 and trendAligned and htfAligned ? "Bearish Trend Confirmed" :
     trend == 1 and not htfAligned ? "Bullish / HTF Conflict" :
     trend == -1 and not htfAligned ? "Bearish / HTF Conflict" :
     "Mixed Trend State"

risk =
     er < 0.30 ? "Choppy / Whipsaw Risk" :
     distanceATR > 2.5 ? "Extended / Pullback Risk" :
     trendAligned and htfAligned ? "Continuation Favored" :
     "Mixed Confirmation"

nextAction =
     score >= 75 ? "Follow Pullbacks" :
     score >= 55 ? "Wait for Confirmation" :
     "Avoid / Stand Aside"

//────────────────────
// Plots
//────────────────────
bullPlot = plot(trend == 1 ? lowerBand : na, "Bullish Supertrend", color=bullColor, linewidth=2, style=plot.style_linebr)
bearPlot = plot(trend == -1 ? upperBand : na, "Bearish Supertrend", color=bearColor, linewidth=2, style=plot.style_linebr)

midPlot = plot(ohlc4, display=display.none)

fill(midPlot, bullPlot, color=showFill and trend == 1 ? color.new(bullColor, 85) : na)
fill(midPlot, bearPlot, color=showFill and trend == -1 ? color.new(bearColor, 85) : na)

plotshape(showSignals and bullFlip, title="Buy Signal", text="BUY", style=shape.labelup, location=location.belowbar, color=bullColor, textcolor=color.black, size=size.tiny)
plotshape(showSignals and bearFlip, title="Sell Signal", text="SELL", style=shape.labeldown, location=location.abovebar, color=bearColor, textcolor=color.white, size=size.tiny)

//────────────────────
// Dashboard
//────────────────────
txtSize =
     tableSize == "Tiny" ? size.tiny :
     tableSize == "Small" ? size.small :
     tableSize == "Normal" ? size.normal :
     size.large

pos =
     tablePos == "Top Left" ? position.top_left :
     tablePos == "Bottom Right" ? position.bottom_right :
     tablePos == "Bottom Left" ? position.bottom_left :
     position.top_right

stateBg =
     str.contains(state, "Bullish") and htfAligned ? bullColor :
     str.contains(state, "Bearish") and htfAligned ? bearColor :
     warningColor

riskBg =
     str.contains(risk, "Continuation") ? bullColor :
     str.contains(risk, "Risk") ? warningColor :
     neutralColor

meterBlocks = math.round(score / 10)
meter = ""
for i = 1 to 10
    meter += i <= meterBlocks ? "█" : "░"

var table dash = table.new(pos, 2, 10, border_width=1)

if showDashboard and barstate.islast
    table.cell(dash, 0, 0, "MARKET ENGINE", bgcolor=headerBg, text_color=textColor, text_size=txtSize)
    table.cell(dash, 1, 0, "LIVE STATE", bgcolor=headerBg, text_color=textColor, text_size=txtSize)

    table.cell(dash, 0, 1, "Market State", bgcolor=labelBg, text_color=textColor, text_size=txtSize)
    table.cell(dash, 1, 1, state, bgcolor=stateBg, text_color=textColor, text_size=txtSize)

    table.cell(dash, 0, 2, "Signal Strength", bgcolor=labelBg, text_color=textColor, text_size=txtSize)
    table.cell(dash, 1, 2, meter + " " + str.tostring(score, "#") + "%", bgcolor=neutralColor, text_color=textColor, text_size=txtSize)

    table.cell(dash, 0, 3, "Trade Quality", bgcolor=labelBg, text_color=textColor, text_size=txtSize)
    table.cell(dash, 1, 3, grade, bgcolor=stateBg, text_color=textColor, text_size=txtSize)

    table.cell(dash, 0, 4, "Trend Direction", bgcolor=labelBg, text_color=textColor, text_size=txtSize)
    table.cell(dash, 1, 4, trend == 1 ? "Bullish ↑" : "Bearish ↓", bgcolor=trend == 1 ? bullColor : bearColor, text_color=textColor, text_size=txtSize)

    table.cell(dash, 0, 5, "HTF Alignment", bgcolor=labelBg, text_color=textColor, text_size=txtSize)
    table.cell(dash, 1, 5, htfAligned ? "Aligned" : "Conflict", bgcolor=htfAligned ? bullColor : warningColor, text_color=textColor, text_size=txtSize)

    table.cell(dash, 0, 6, "Trend Filter", bgcolor=labelBg, text_color=textColor, text_size=txtSize)
    table.cell(dash, 1, 6, trendAligned ? "Confirmed" : "Against EMA", bgcolor=trendAligned ? bullColor : warningColor, text_color=textColor, text_size=txtSize)

    table.cell(dash, 0, 7, "Efficiency", bgcolor=labelBg, text_color=textColor, text_size=txtSize)
    table.cell(dash, 1, 7, str.tostring(er, "#.##"), bgcolor=er > 0.5 ? bullColor : er > 0.3 ? warningColor : neutralColor, text_color=textColor, text_size=txtSize)

    table.cell(dash, 0, 8, "Risk / Behavior", bgcolor=labelBg, text_color=textColor, text_size=txtSize)
    table.cell(dash, 1, 8, risk, bgcolor=riskBg, text_color=textColor, text_size=txtSize)

    table.cell(dash, 0, 9, "Next Action", bgcolor=labelBg, text_color=textColor, text_size=txtSize)
    table.cell(dash, 1, 9, nextAction, bgcolor=score >= 75 ? bullColor : score >= 55 ? warningColor : neutralColor, text_color=textColor, text_size=txtSize)

//────────────────────
// Alerts
//────────────────────
alertcondition(bullFlip, "Bullish Supertrend Flip", "Supertrend Nexus flipped bullish.")
alertcondition(bearFlip, "Bearish Supertrend Flip", "Supertrend Nexus flipped bearish.")
alertcondition(htfAligned and bullFlip, "Bullish Flip with HTF Alignment", "Bullish Supertrend flip confirmed by HTF.")
alertcondition(htfAligned and bearFlip, "Bearish Flip with HTF Alignment", "Bearish Supertrend flip confirmed by HTF.")
````
