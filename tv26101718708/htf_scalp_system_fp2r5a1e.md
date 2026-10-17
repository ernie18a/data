# HTF Scalp System

- url: https://www.tradingview.com/script/Fp2r5a1e-HTF-Scalp-System/
- type: indicator
- pine_id: PUB;0935377728924378afe0d8e092c47b70
- version: 1.0

## Description

HTF Scalp System

HTF Scalp System is a higher-timeframe reference tool designed for intraday traders who follow liquidity, market structure, and the Accumulation–Manipulation–Distribution (AMD) concept.

The indicator automatically projects key higher-timeframe levels onto lower-timeframe charts, helping traders identify potential reaction zones without manually marking them.

Features
Higher Timeframe Open

Displays the current higher-timeframe opening price, which often acts as an important intraday equilibrium level.

ADR-Based Manipulation Levels

The indicator calculates dynamic manipulation zones using a configurable percentage of the Average Daily Range (ADR).

Bearish Manipulation Level = HTF Open + ADR %
Bullish Manipulation Level = HTF Open − ADR %

These levels can help identify potential liquidity grabs and reversal areas.

Previous HTF High & Low

Plots the previous higher-timeframe high and low as projected support and resistance levels.

These areas are commonly watched for:

Liquidity sweeps
Breakout reactions
Reversal opportunities
AMD Path Projection

The indicator tracks the current higher-timeframe session high and low and visualises a simplified AMD (Accumulation–Manipulation–Distribution) path.

Depending on the current market position relative to the HTF Open, the projected path illustrates the likely manipulation leg before the ongoing directional move.

This is intended as a visual guide rather than a predictive signal.

Optional VWAP

An integrated VWAP can be enabled for traders who use volume-weighted price as an additional confluence factor.

Inputs
Higher Timeframe selection
ADR calculation length
Manipulation zone percentage
Line extension length
Individual visibility controls for all levels
Optional VWAP with custom colour and width
Best Used For
Intraday trading
Scalping
Liquidity-based trading
AMD framework
ICT-inspired market analysis
Higher-timeframe bias
Notes

This indicator is designed as a market structure and reference tool. It does not generate buy or sell signals and should be used alongside your own trading plan, price action analysis, and risk management.

The projected AMD path is a visual representation of current market behaviour and should not be interpreted as a guarantee of future price movement.

## Source Code

````pine
//@version=6
indicator("HTF Scalp System", overlay = true, max_lines_count = 500)

// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/

// --- Inputs ---
grp1 = "Level Settings"
htf = input.timeframe("240", "HTF Timeframe", group=grp1)
adrLength = input.int(14, "ADR Length", group=grp1)
manipulationPct = input.float(0.25, "Manipulation Zone (ADR %)", step=0.05, group=grp1, tooltip="Percentage of ADR to calculate the manipulation levels above/below the open.")
extendBars = input.int(5, "Extend Right (Bars)", group=grp1, tooltip="How many bars to extend the lines to the right.")

grp2 = "Visibility"
showOpen = input.bool(true, "Show Open", group=grp2)
showManip = input.bool(true, "Show Manipulation Levels", group=grp2)
showPrevHL = input.bool(true, "Show Previous High/Low", group=grp2)
showPath = input.bool(true, "Show AMD Path", group=grp2)

grp3 = "VWAP Settings"
showVwap = input.bool(false, "Show VWAP", group=grp3)
vwapColor = input.color(color.new(#2962ff, 0), "VWAP Color", group=grp3)
vwapWidth = input.int(1, "VWAP Line Width", minval=1, maxval=4, group=grp3)

// --- Watermark ---
var table watermarkTable = table.new(position.bottom_right, 1, 1)
if barstate.isfirst
    table.cell(watermarkTable, 0, 0, "erdensedat", text_color=color.new(chart.fg_color, 85), text_size=size.huge, text_halign=text.align_right)

// --- Data Fetching ---
high_low = high - low
htf_adr = request.security(syminfo.tickerid, htf, ta.sma(high_low, adrLength)[1], lookahead = barmerge.lookahead_on)

[htfOpen, prevHigh, prevLow] = request.security(syminfo.tickerid, htf, [open, high[1], low[1]], lookahead = barmerge.lookahead_on)

// --- Calculations ---
manipulationRange = htf_adr * manipulationPct
bearishManipLevel = htfOpen + manipulationRange
bullishManipLevel = htfOpen - manipulationRange

// Trigger on new HTF bar
isNewHTF = ta.change(time(htf)) != 0

// Track session extremes
var int htfStartBar = na
var float sessionHigh = na
var int sessionHighBar = na
var float sessionLow = na
var int sessionLowBar = na

if isNewHTF
    htfStartBar := bar_index
    sessionHigh := high
    sessionHighBar := bar_index
    sessionLow := low
    sessionLowBar := bar_index
else
    if high > sessionHigh
        sessionHigh := high
        sessionHighBar := bar_index
    if low < sessionLow
        sessionLow := low
        sessionLowBar := bar_index

// Line and Label Variables
var line openLine = na
var line bearLine = na
var line bullLine = na
var line prevHLine = na
var line prevLLine = na
var line pathLine1 = na
var line pathLine2 = na

var label openLbl = na
var label bearLbl = na
var label bullLbl = na
var label prevHLbl = na
var label prevLLbl = na

// Drawing Function
drawLineAndLabel(yValue, color, style, txt, startIdx) =>
    l = line.new(startIdx, yValue, bar_index + extendBars, yValue, color=color, style=style, width=2)
    lbl = label.new(bar_index + extendBars, yValue, txt, color=color.new(color, 100), textcolor=color, style=label.style_label_left, size=size.small)
    [l, lbl]

// Draw projections on the last bar
if barstate.islast
    line.delete(openLine)
    line.delete(bearLine)
    line.delete(bullLine)
    line.delete(prevHLine)
    line.delete(prevLLine)
    line.delete(pathLine1)
    line.delete(pathLine2)
    
    label.delete(openLbl)
    label.delete(bearLbl)
    label.delete(bullLbl)
    label.delete(prevHLbl)
    label.delete(prevLLbl)

    int startIdx = na(htfStartBar) ? bar_index : htfStartBar
    
    if showOpen
        [o_l, o_lbl] = drawLineAndLabel(htfOpen, color.new(chart.fg_color, 30), line.style_solid, "Open", startIdx)
        openLine := o_l
        openLbl := o_lbl
        
    if showManip
        [bear_l, bear_lbl] = drawLineAndLabel(bearishManipLevel, color.new(#f23645, 0), line.style_dashed, "Bearish Level", startIdx)
        bearLine := bear_l
        bearLbl := bear_lbl
        
        [bull_l, bull_lbl] = drawLineAndLabel(bullishManipLevel, color.new(#089981, 0), line.style_dashed, "Bullish Level", startIdx)
        bullLine := bull_l
        bullLbl := bull_lbl
        
    if showPrevHL
        [ph_l, ph_lbl] = drawLineAndLabel(prevHigh, color.new(#f23645, 30), line.style_dotted, "Prev High", startIdx)
        prevHLine := ph_l
        prevHLbl := ph_lbl
        
        [pl_l, pl_lbl] = drawLineAndLabel(prevLow, color.new(#089981, 30), line.style_dotted, "Prev Low", startIdx)
        prevLLine := pl_l
        prevLLbl := pl_lbl

    if showPath and not na(htfStartBar)
        isBullish = close > htfOpen
        
        int fakeBar = isBullish ? sessionLowBar : sessionHighBar
        float fakeVal = isBullish ? sessionLow : sessionHigh
        
        pathColor = color.new(#2962ff, 0)
        
        pathLine1 := line.new(startIdx, htfOpen, fakeBar, fakeVal, color=pathColor, width=2)
        pathLine2 := line.new(fakeBar, fakeVal, bar_index, close, color=pathColor, width=2)

// --- VWAP ---
plot(showVwap ? ta.vwap : na, title="VWAP", color=vwapColor, linewidth=vwapWidth)
````
