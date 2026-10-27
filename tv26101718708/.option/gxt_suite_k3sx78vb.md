# GxT Suite

- url: https://www.tradingview.com/script/k3Sx78vb-GxT-Suite/
- type: indicator
- pine_id: PUB;4473df3635ff4a399d5741ae79946a1b
- version: 1.0

## Description

GxT SMT Divergence & Liquidity Suite

A multi-concept indicator built around Smart Money Technique (SMT) divergence and liquidity-based market structure. It compares your chart symbol against a correlated asset you choose, and layers on the core tools used to confirm reversals and continuations: swing structure, key liquidity levels, fair value gaps, premium/discount positioning, displacement, and precision divergence signals.

What it plots:

SMT Divergence (▲/▼ labels) — Flags when your chart makes a new swing high/low that the comparison asset fails to confirm (a classic sign of smart money divergence between correlated markets, e.g. ES vs NQ, or EURUSD vs GBPUSD).
PSP (Precision Swing Point) — Diamond markers on candles where your asset and the comparison asset close in opposite directions, highlighting single-candle inefficiency/divergence.
Fair Value Gaps (FVG) — Auto-detects 3-candle imbalances, draws them as shaded zones, and automatically removes them once price fully mitigates the gap.
IRL / ERL (Range Liquidity) — Plots the most recent swing high (External Range Liquidity / target) and swing low (Internal Range Liquidity / reversal point) as dotted reference lines.
Premium / Discount Zones — Shades the upper (premium) and lower (discount) halves of the current range around a 50% equilibrium line, helping gauge where price sits relative to fair value.
Displacement Candles — Highlights candles with unusually large range (ATR-based), typically marking aggressive institutional moves that precede or confirm structure shifts.

Inputs:

Comparison symbol (for SMT/PSP calculations)
Swing/pivot length and SMT sync window
Toggle visibility for each component (SMT labels, swings, PSP, FVG, range levels, premium/discount, displacement)
Custom colors for FVG and premium/discount zones

Alerts included for:

Bullish/bearish SMT divergence
Bullish/bearish PSP
New bullish/bearish FVG formation

Best used for: Confirming reversals or continuations at key liquidity levels by cross-checking structure between two correlated instruments, in the spirit of ICT-style SMT divergence and multi-timeframe liquidity trading frameworks.

## Source Code

````pine
//@version=6
indicator("GxT SMT Divergence & Liquidity Suite", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ============================================================================
// GxT SMT DIVERGENCE & LIQUIDITY SUITE
// Based on: SMT Divergence, 2-Stage SMT, Asset Synchronization, IRL/ERL,
// Manipulation Ranges, Key Level Refinement (FVG), Premium/Discount,
// PSP (Precision Swing Point), Displacement, and the Universal Sequence.
// ============================================================================

// ---------------------------- INPUTS ---------------------------------------
grpSMT = "SMT Divergence (Asset Synchronization)"
compSymbol = input.symbol("", "Comparison Symbol (correlated asset)", group = grpSMT,
     tooltip = "Set this to a correlated instrument (e.g. if chart is ES, use NQ). Leave blank to default to the chart symbol.")
pivotLen   = input.int(5, "Swing / Pivot Length", minval = 1, group = grpSMT)
syncWindow = input.int(15, "SMT Sync Window (bars)", minval = 1, group = grpSMT,
     tooltip = "Max bar distance allowed between a swing on the chart symbol and the matching swing on the comparison symbol to still be considered the same swing.")
showSMT    = input.bool(true, "Show SMT Divergence Labels", group = grpSMT)
showSwings = input.bool(true, "Show Swing High/Low Markers", group = grpSMT)

grpPSP = "PSP (Precision Swing Point)"
showPSP = input.bool(true, "Show PSP Markers", group = grpPSP)

grpFVG = "Fair Value Gaps (Key Level Refinement)"
showFVG        = input.bool(true, "Show FVG", group = grpFVG)
removeFilledFVG = input.bool(true, "Delete FVG once fully filled", group = grpFVG)
fvgBullColor   = input.color(color.new(color.teal, 80), "Bullish FVG Color", group = grpFVG)
fvgBearColor   = input.color(color.new(color.red, 80), "Bearish FVG Color", group = grpFVG)

grpRange = "IRL / ERL (Range Liquidity)"
showRange = input.bool(true, "Show Range High/Low (IRL/ERL)", group = grpRange)

grpPD = "Premium / Discount"
showPD = input.bool(true, "Show Premium/Discount Zones", group = grpPD)
premiumColor  = input.color(color.new(color.red, 92), "Premium Zone Color", group = grpPD)
discountColor = input.color(color.new(color.teal, 92), "Discount Zone Color", group = grpPD)

grpDisp = "Displacement"
showDisp = input.bool(true, "Highlight Displacement Candles", group = grpDisp)
dispMult = input.float(1.5, "Displacement ATR Multiplier", minval = 0.1, group = grpDisp)

// ---------------------------- SWING / PIVOT DETECTION -----------------------
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

plotshape(showSwings and not na(ph), style = shape.triangledown, location = location.abovebar,
     color = color.new(color.red, 0), offset = -pivotLen, size = size.tiny, title = "Swing High")
plotshape(showSwings and not na(pl), style = shape.triangleup, location = location.belowbar,
     color = color.new(color.lime, 0), offset = -pivotLen, size = size.tiny, title = "Swing Low")

// ---------------------------- IRL / ERL (RANGE HIGH/LOW) --------------------
var float lastSwingHigh    = na
var float lastSwingLow     = na
var int   lastSwingHighBar = na
var int   lastSwingLowBar  = na

if not na(ph)
    lastSwingHigh    := ph
    lastSwingHighBar := bar_index - pivotLen
if not na(pl)
    lastSwingLow    := pl
    lastSwingLowBar := bar_index - pivotLen

var line  rangeHighLine  = na
var line  rangeLowLine   = na
var label rangeHighLabel = na
var label rangeLowLabel  = na

if showRange
    if not na(ph)
        line.delete(rangeHighLine)
        label.delete(rangeHighLabel)
        rangeHighLine  := line.new(lastSwingHighBar, lastSwingHigh, bar_index, lastSwingHigh, color = color.gray, style = line.style_dotted)
        rangeHighLabel := label.new(bar_index, lastSwingHigh, "Range High (ERL/Target)", style = label.style_label_left,
             color = color.new(color.white, 100), textcolor = color.gray, size = size.small)
    else if not na(rangeHighLine)
        line.set_x2(rangeHighLine, bar_index)
        label.set_x(rangeHighLabel, bar_index)

    if not na(pl)
        line.delete(rangeLowLine)
        label.delete(rangeLowLabel)
        rangeLowLine  := line.new(lastSwingLowBar, lastSwingLow, bar_index, lastSwingLow, color = color.gray, style = line.style_dotted)
        rangeLowLabel := label.new(bar_index, lastSwingLow, "Range Low (IRL/Reversal)", style = label.style_label_left,
             color = color.new(color.white, 100), textcolor = color.gray, size = size.small)
    else if not na(rangeLowLine)
        line.set_x2(rangeLowLine, bar_index)
        label.set_x(rangeLowLabel, bar_index)

// ---------------------------- PREMIUM / DISCOUNT -----------------------------
var line eqLine = na
var box  premiumBox = na
var box  discountBox = na

if showPD and not na(lastSwingHigh) and not na(lastSwingLow)
    eq = (lastSwingHigh + lastSwingLow) / 2.0
    startBar = math.min(lastSwingHighBar, lastSwingLowBar)
    line.delete(eqLine)
    box.delete(premiumBox)
    box.delete(discountBox)
    eqLine       := line.new(startBar, eq, bar_index, eq, color = color.orange, style = line.style_dashed)
    premiumBox   := box.new(startBar, lastSwingHigh, bar_index, eq, border_color = na, bgcolor = premiumColor)
    discountBox  := box.new(startBar, eq, bar_index, lastSwingLow, border_color = na, bgcolor = discountColor)
else if showPD and not na(eqLine)
    line.set_x2(eqLine, bar_index)
    box.set_right(premiumBox, bar_index)
    box.set_right(discountBox, bar_index)

// ---------------------------- FAIR VALUE GAPS --------------------------------
var box[]   bullBoxes = array.new_box()
var float[] bullTops  = array.new_float()
var float[] bullBots  = array.new_float()

var box[]   bearBoxes = array.new_box()
var float[] bearTops  = array.new_float()
var float[] bearBots  = array.new_float()

bullFVG = low > high[2]
bearFVG = high < low[2]

if showFVG and bullFVG
    bx = box.new(bar_index[2], low, bar_index, high[2], border_color = na, bgcolor = fvgBullColor, extend = extend.right)
    array.push(bullBoxes, bx)
    array.push(bullTops, low)
    array.push(bullBots, high[2])

if showFVG and bearFVG
    bx = box.new(bar_index[2], low[2], bar_index, high, border_color = na, bgcolor = fvgBearColor, extend = extend.right)
    array.push(bearBoxes, bx)
    array.push(bearTops, low[2])
    array.push(bearBots, high)

if array.size(bullBoxes) > 0
    for i = array.size(bullBoxes) - 1 to 0
        bx  = array.get(bullBoxes, i)
        bot = array.get(bullBots, i)
        if low <= bot
            if removeFilledFVG
                box.delete(bx)
            else
                box.set_extend(bx, extend.none)
                box.set_right(bx, bar_index)
            array.remove(bullBoxes, i)
            array.remove(bullTops, i)
            array.remove(bullBots, i)

if array.size(bearBoxes) > 0
    for i = array.size(bearBoxes) - 1 to 0
        bx  = array.get(bearBoxes, i)
        top = array.get(bearTops, i)
        if high >= top
            if removeFilledFVG
                box.delete(bx)
            else
                box.set_extend(bx, extend.none)
                box.set_right(bx, bar_index)
            array.remove(bearBoxes, i)
            array.remove(bearTops, i)
            array.remove(bearBots, i)

// ---------------------------- DISPLACEMENT ------------------------------------
atrVal = ta.atr(14)
isDisplacement = math.abs(close - open) > atrVal * dispMult
barcolor(showDisp and isDisplacement ? (close > open ? color.new(color.lime, 20) : color.new(color.red, 20)) : na,
     title = "Displacement Candle")

// ---------------------------- COMPARISON SYMBOL DATA ---------------------------
resolvedSymbol = compSymbol == "" ? syminfo.tickerid : compSymbol

compHigh  = request.security(resolvedSymbol, timeframe.period, high,  lookahead = barmerge.lookahead_off)
compLow   = request.security(resolvedSymbol, timeframe.period, low,   lookahead = barmerge.lookahead_off)
compOpen  = request.security(resolvedSymbol, timeframe.period, open,  lookahead = barmerge.lookahead_off)
compClose = request.security(resolvedSymbol, timeframe.period, close, lookahead = barmerge.lookahead_off)
compPH    = request.security(resolvedSymbol, timeframe.period, ta.pivothigh(high, pivotLen, pivotLen), lookahead = barmerge.lookahead_off)
compPL    = request.security(resolvedSymbol, timeframe.period, ta.pivotlow(low, pivotLen, pivotLen),  lookahead = barmerge.lookahead_off)

// ---------------------------- PSP (Precision Swing Point) ----------------------
pspBull = close > open and compClose < compOpen
pspBear = close < open and compClose > compOpen

plotshape(showPSP and pspBull, style = shape.diamond, location = location.belowbar,
     color = color.new(color.blue, 0), size = size.tiny, title = "PSP Bullish")
plotshape(showPSP and pspBear, style = shape.diamond, location = location.abovebar,
     color = color.new(color.purple, 0), size = size.tiny, title = "PSP Bearish")

// ---------------------------- SMT DIVERGENCE ------------------------------------
var float mainPH1 = na
var float mainPH2 = na
var int   mainPH1Bar = na

var float mainPL1 = na
var float mainPL2 = na
var int   mainPL1Bar = na

var float compPH1 = na
var float compPH2 = na
var int   compPH1Bar = na

var float compPL1 = na
var float compPL2 = na
var int   compPL1Bar = na

var bool bearSMTFlag = false
var bool bullSMTFlag = false
bearSMTFlag := false
bullSMTFlag := false

// track comparison symbol pivots on its own cadence
if not na(compPH)
    compPH2    := compPH1
    compPH1    := compPH
    compPH1Bar := bar_index - pivotLen

if not na(compPL)
    compPL2    := compPL1
    compPL1    := compPL
    compPL1Bar := bar_index - pivotLen

// bearish SMT: main makes a Higher High while comparison makes a Lower/Equal High
if not na(ph)
    mainPH2    := mainPH1
    mainPH1    := ph
    mainPH1Bar := bar_index - pivotLen

    if not na(compPH1Bar) and not na(compPH2) and math.abs(mainPH1Bar - compPH1Bar) <= syncWindow
        if mainPH1 > mainPH2 and compPH1 <= compPH2
            bearSMTFlag := true
            if showSMT
                label.new(bar_index, high + atrVal, "SMT ▼", style = label.style_label_down,
                     color = color.new(color.red, 0), textcolor = color.white, size = size.small)

// bullish SMT: main makes a Lower Low while comparison makes a Higher/Equal Low
if not na(pl)
    mainPL2    := mainPL1
    mainPL1    := pl
    mainPL1Bar := bar_index - pivotLen

    if not na(compPL1Bar) and not na(compPL2) and math.abs(mainPL1Bar - compPL1Bar) <= syncWindow
        if mainPL1 < mainPL2 and compPL1 >= compPL2
            bullSMTFlag := true
            if showSMT
                label.new(bar_index, low - atrVal, "SMT ▲", style = label.style_label_up,
                     color = color.new(color.lime, 0), textcolor = color.black, size = size.small)

// ---------------------------- ALERTS ---------------------------------------------
alertcondition(bullSMTFlag, title = "Bullish SMT Divergence", message = "Bullish SMT Divergence detected vs comparison symbol")
alertcondition(bearSMTFlag, title = "Bearish SMT Divergence", message = "Bearish SMT Divergence detected vs comparison symbol")
alertcondition(pspBull, title = "Bullish PSP", message = "Bullish PSP (candle color divergence) detected")
alertcondition(pspBear, title = "Bearish PSP", message = "Bearish PSP (candle color divergence) detected")
alertcondition(bullFVG, title = "Bullish FVG Formed", message = "New bullish Fair Value Gap formed")
alertcondition(bearFVG, title = "Bearish FVG Formed", message = "New bearish Fair Value Gap formed")
````
