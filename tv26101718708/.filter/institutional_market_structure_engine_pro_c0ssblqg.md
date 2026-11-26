# Institutional Market Structure Engine [PRO]

- url: https://www.tradingview.com/script/C0sSblQg-Institutional-Market-Structure-Engine-PRO/
- type: indicator
- pine_id: PUB;00f38a9518514753b4f32be1a3ea496f
- version: 1.0

## Description

Institutional Market Structure Engine [PRO]
The Institutional Market Structure Engine is an advanced, fully non-repainting quantitative trading script built for professional Smart Money Concepts (SMC) and price action traders. Rather than cluttering the chart with endless geometric shapes, this indicator employs a highly strict validation engine to ensure only the highest-probability, institutionally-backed levels are displayed on your chart.

Core Features
1. Dual-Layer Market Structure Engine The script simultaneously tracks two layers of market structure:

Macro (External) Structure: Tracks major high-timeframe swings (drawn with thick, solid lines). Prints M-BOS (Break of Structure) and M-CHOCH (Change of Character).
Micro (Internal) Structure: Tracks short-term pullbacks and minor structure (drawn with thin, dotted lines). Prints m-bos and m-choch.
2. Volume Delta Validation Not all structure breaks are equal. The engine uses a 20-period Volume SMA to validate structural displacement. If a break occurs on high volume, it is labeled as a "Strong BOS". If it occurs on low volume, the engine identifies it as a potential fake-out and labels it as a "Weak BOS" or "Sweep".

3. Strict Smart Money Concepts (OB + FVG + IFVG) This indicator features an incredibly strict SMC generation algorithm designed to keep your chart remarkably clean:

Coupled Order Blocks & FVGs: Fair Value Gaps are only drawn if they are formed immediately following a valid Order Block. Isolated displacement without an initiating block is ignored.
Liquidity Sweeps: Order blocks can be strictly filtered to only appear if they swept the liquidity (wick) of the preceding candle.
Inversion FVGs (IFVG): When price completely closes through an unmitigated FVG, it flips polarity. A broken Bullish FVG instantly converts into a Bearish IFVG (acting as resistance), changing its color and label until it is mitigated from the opposite side.
Chart Garbage Collection: To prevent visual clutter, the engine forces a maximum active limit. It actively sweeps the chart to ensure you never have more than 6 active Order Blocks and 6 active IFVGs/FVGs on your screen at any given time.
4. Institutional Liquidity Pools Institutional algorithms heavily target multi-day liquidity. The script automatically fetches and projects the exact horizontal price levels for:

Previous Day Highs and Lows (PDH / PDL) - Dashed Lines
Previous Week Highs and Lows (PWH / PWL) - Thick Solid Lines
5. Multi-Timeframe Dashboard A sleek, customizable Heads-Up Display (HUD) sits in the corner of your screen, feeding you real-time trend alignment metrics. It calculates exponential moving average trends across 4 custom timeframes so you never take a trade against the higher timeframe momentum.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Antigravity (Institutional Quantitative Engine)

//@version=6
indicator("Institutional Market Structure Engine [PRO]", shorttitle="IMS Engine", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// =================================================================================================
// 1. CONFIGURATION
// =================================================================================================
group_struct = "Market Structure & Swings"
lenExt       = input.int(20, "Macro Swing Length", minval=2, tooltip="Pivot lookback for major external structure", group=group_struct)
lenInt       = input.int(5, "Micro Swing Length", minval=2, tooltip="Pivot lookback for minor internal structure", group=group_struct)
bosConfType  = input.string("Close", "Break Confirmation", options=["Close", "Wick"], group=group_struct)
showStruct   = input.bool(true, "Show BOS / CHOCH Lines", group=group_struct)



group_liq    = "Liquidity & Sweeps"
showLiq      = input.bool(true, "Show Swing Liquidity Sweeps", group=group_liq)
showPDL      = input.bool(true, "Show Previous Day/Week Highs/Lows", group=group_liq)

group_smc    = "Smart Money Concepts"
showFVG      = input.bool(true, "Show Fair Value Gaps (FVG)", group=group_smc)
fvgMinSize   = input.float(0.2, "Min FVG Size (ATR multiplier)", group=group_smc)
showOB       = input.bool(true, "Show Order Blocks (OB)", group=group_smc)
strongOBOnly = input.bool(true, "Only Show Strong OBs (Sweep + Immediate FVG)", tooltip="OB must sweep the previous candle's wick and be adjacent to an FVG", group=group_smc)
showPD       = input.bool(true, "Show Premium/Discount Zones", group=group_smc)

group_mtf    = "Multi-Timeframe Engine"
showDashboard= input.bool(true, "Show MTF Dashboard", group=group_mtf)
dashLoc      = input.string("Top Right", "Dashboard Position", options=["Top Right", "Bottom Right", "Top Left", "Bottom Left"], group=group_mtf)
dashSize     = input.string("Small", "Dashboard Text Size", options=["Tiny", "Small", "Normal", "Large", "Huge", "Auto"], group=group_mtf)
tf1          = input.timeframe("15", "Timeframe 1", group=group_mtf)
tf2          = input.timeframe("60", "Timeframe 2", group=group_mtf)
tf3          = input.timeframe("240", "Timeframe 3", group=group_mtf)
tf4          = input.timeframe("D", "Timeframe 4", group=group_mtf)

group_ui     = "Theme & Visuals"
colorBull    = input.color(#00E676, "Bullish Color", group=group_ui)
colorBear    = input.color(#FF5252, "Bearish Color", group=group_ui)
colorNeut    = input.color(#9E9E9E, "Neutral Color", group=group_ui)
colorText    = input.color(color.white, "Text Color", group=group_ui)

// =================================================================================================
// 2. TYPES & DATA STRUCTURES
// =================================================================================================
type Swing
    int   idx
    float p
    bool  isHigh
    bool  isBroken

type FVG
    box   bx
    bool  isBull
    float top
    float bot
    bool  mitigated
    bool  isInverted
    bool  invertedMitigated

type OB
    box   bx
    bool  isBull
    float top
    float bot
    bool  mitigated

// =================================================================================================
// 3. UTILITIES, MATH & TIME
// =================================================================================================
atr = ta.atr(14)
upColorC = color.new(colorBull, 80)
dnColorC = color.new(colorBear, 80)
upColorL = color.new(colorBull, 0)
dnColorL = color.new(colorBear, 0)

volMa = ta.sma(volume, 20)
isHighVol = volume > volMa

breakVal(price, isBull) =>
    bosConfType == "Close" ? (isBull ? close > price : close < price) : (isBull ? high > price : low < price)



// =================================================================================================
// 4. PREVIOUS DAY/WEEK LIQUIDITY (PDH/PDL)
// =================================================================================================
[pdHigh, pdLow] = request.security(syminfo.tickerid, "D", [high[1], low[1]], lookahead=barmerge.lookahead_on)
[pwHigh, pwLow] = request.security(syminfo.tickerid, "W", [high[1], low[1]], lookahead=barmerge.lookahead_on)

var line linePDH = na
var line linePDL = na
var line linePWH = na
var line linePWL = na

if showPDL
    if timeframe.change("D")
        linePDH := line.new(bar_index, pdHigh, bar_index + 1, pdHigh, color=colorText, style=line.style_dashed)
        linePDL := line.new(bar_index, pdLow, bar_index + 1, pdLow, color=colorText, style=line.style_dashed)
    else
        if not na(linePDH)
            line.set_x2(linePDH, bar_index)
        if not na(linePDL)
            line.set_x2(linePDL, bar_index)
        
    if timeframe.change("W")
        linePWH := line.new(bar_index, pwHigh, bar_index + 1, pwHigh, color=colorText, style=line.style_solid, width=2)
        linePWL := line.new(bar_index, pwLow, bar_index + 1, pwLow, color=colorText, style=line.style_solid, width=2)
    else
        if not na(linePWH)
            line.set_x2(linePWH, bar_index)
        if not na(linePWL)
            line.set_x2(linePWL, bar_index)

// =================================================================================================
// 5. MARKET STRUCTURE ENGINE (INTERNAL & EXTERNAL)
// =================================================================================================
var Swing[] highSwingsExt = array.new<Swing>()
var Swing[] lowSwingsExt  = array.new<Swing>()
var Swing[] highSwingsInt = array.new<Swing>()
var Swing[] lowSwingsInt  = array.new<Swing>()

var line[] structLines = array.new<line>()
var label[] structLabels = array.new<label>()

phExt = ta.pivothigh(high, lenExt, lenExt)
plExt = ta.pivotlow(low, lenExt, lenExt)
phInt = ta.pivothigh(high, lenInt, lenInt)
plInt = ta.pivotlow(low, lenInt, lenInt)

var int trendExt = 0
var int trendInt = 0
var string lastEvent = "None"

// Update Swings
if not na(phExt)
    array.unshift(highSwingsExt, Swing.new(bar_index - lenExt, phExt, true, false))
if not na(plExt)
    array.unshift(lowSwingsExt, Swing.new(bar_index - lenExt, plExt, false, false))

if not na(phInt)
    array.unshift(highSwingsInt, Swing.new(bar_index - lenInt, phInt, true, false))
if not na(plInt)
    array.unshift(lowSwingsInt, Swing.new(bar_index - lenInt, plInt, false, false))

// Process External Structure
if array.size(highSwingsExt) > 0 and array.size(lowSwingsExt) > 0
    topExt = array.get(highSwingsExt, 0)
    botExt = array.get(lowSwingsExt, 0)
    
    // Bullish Break
    if not topExt.isBroken and breakVal(topExt.p, true)
        topExt.isBroken := true
        isChoch = trendExt == -1
        trendExt := 1
        
        lblText = isChoch ? "M-CHOCH" : (isHighVol ? "Strong M-BOS" : "Weak M-BOS")
        lastEvent := lblText
        
        if showStruct
            ln = line.new(topExt.idx, topExt.p, bar_index, topExt.p, color=upColorL, style=line.style_solid, width=2)
            lbl = label.new(math.round(math.avg(topExt.idx, bar_index)), topExt.p, lblText, color=color.new(color.white, 100), textcolor=upColorL, style=label.style_label_down, size=size.small)
            array.push(structLines, ln)
            array.push(structLabels, lbl)

    // Bearish Break
    if not botExt.isBroken and breakVal(botExt.p, false)
        botExt.isBroken := true
        isChoch = trendExt == 1
        trendExt := -1
        
        lblText = isChoch ? "M-CHOCH" : (isHighVol ? "Strong M-BOS" : "Weak M-BOS")
        lastEvent := lblText
        
        if showStruct
            ln = line.new(botExt.idx, botExt.p, bar_index, botExt.p, color=dnColorL, style=line.style_solid, width=2)
            lbl = label.new(math.round(math.avg(botExt.idx, bar_index)), botExt.p, lblText, color=color.new(color.white, 100), textcolor=dnColorL, style=label.style_label_up, size=size.small)
            array.push(structLines, ln)
            array.push(structLabels, lbl)

// Process Internal Structure
if array.size(highSwingsInt) > 0 and array.size(lowSwingsInt) > 0
    topInt = array.get(highSwingsInt, 0)
    botInt = array.get(lowSwingsInt, 0)
    
    if not topInt.isBroken and breakVal(topInt.p, true)
        topInt.isBroken := true
        isChoch = trendInt == -1
        trendInt := 1
        
        lblText = isChoch ? "m-choch" : (isHighVol ? "m-bos" : "m-sweep")
        if showStruct
            ln = line.new(topInt.idx, topInt.p, bar_index, topInt.p, color=upColorL, style=line.style_dotted)
            lbl = label.new(math.round(math.avg(topInt.idx, bar_index)), topInt.p, lblText, color=color.new(color.white, 100), textcolor=upColorL, style=label.style_label_down, size=size.tiny)
            array.push(structLines, ln)
            array.push(structLabels, lbl)

    if not botInt.isBroken and breakVal(botInt.p, false)
        botInt.isBroken := true
        isChoch = trendInt == 1
        trendInt := -1
        
        lblText = isChoch ? "m-choch" : (isHighVol ? "m-bos" : "m-sweep")
        if showStruct
            ln = line.new(botInt.idx, botInt.p, bar_index, botInt.p, color=dnColorL, style=line.style_dotted)
            lbl = label.new(math.round(math.avg(botInt.idx, bar_index)), botInt.p, lblText, color=color.new(color.white, 100), textcolor=dnColorL, style=label.style_label_up, size=size.tiny)
            array.push(structLines, ln)
            array.push(structLabels, lbl)

if array.size(structLines) > 100
    line.delete(array.shift(structLines))
    label.delete(array.shift(structLabels))

// =================================================================================================
// 6. LIQUIDITY ENGINE
// =================================================================================================
var line[] liqLines = array.new<line>()
if showLiq
    // External Sweep checks
    if array.size(highSwingsExt) > 1
        sw = array.get(highSwingsExt, 1)
        if not sw.isBroken and high > sw.p and close < sw.p
            sw.isBroken := true
            ln = line.new(sw.idx, sw.p, bar_index, sw.p, color=colorText, style=line.style_dotted)
            lbl = label.new(bar_index, high, "Sweep", style=label.style_label_down, color=color.new(color.white, 100), textcolor=colorText, size=size.tiny)
            array.push(liqLines, ln)
            
    if array.size(lowSwingsExt) > 1
        sw = array.get(lowSwingsExt, 1)
        if not sw.isBroken and low < sw.p and close > sw.p
            sw.isBroken := true
            ln = line.new(sw.idx, sw.p, bar_index, sw.p, color=colorText, style=line.style_dotted)
            lbl = label.new(bar_index, low, "Sweep", style=label.style_label_up, color=color.new(color.white, 100), textcolor=colorText, size=size.tiny)
            array.push(liqLines, ln)

if array.size(liqLines) > 50
    line.delete(array.shift(liqLines))

// =================================================================================================
// 7. SMART MONEY CONCEPTS (FVG, OB, IFVG)
// =================================================================================================
var FVG[] fvgs = array.new<FVG>()
var OB[] obs = array.new<OB>()

bullImpulse = close[1] > open[1] and (close[1] - open[1]) > (high[1] - low[1]) * 0.5 and (high[1] - low[1]) > atr
bearImpulse = close[1] < open[1] and (open[1] - close[1]) > (high[1] - low[1]) * 0.5 and (high[1] - low[1]) > atr

// ONLY Strongest displacement (backed by Volume)
isBullFVG = low > high[2] and bullImpulse and (low - high[2]) > (atr * fvgMinSize) and isHighVol
isBearFVG = high < low[2] and bearImpulse and (low[2] - high) > (atr * fvgMinSize) and isHighVol

if showFVG or showOB
    if isBullFVG
        bool hasValidOB = false
        // Search backwards up to 4 bars for an OB preceding the displacement
        for i = 1 to 4
            if close[i] < open[i]
                isSweep = low[i] < low[i+1]
                isStrong = isSweep
                
                if (not strongOBOnly or isStrong)
                    hasValidOB := true
                    if showOB
                        obColor = color.new(colorBull, 70)
                        b = box.new(bar_index-i, high[i], bar_index, low[i], border_color=upColorL, bgcolor=obColor, text="OB+FVG", text_size=size.tiny, text_color=upColorL, text_halign=text.align_right, text_valign=text.align_bottom)
                        array.unshift(obs, OB.new(b, true, high[i], low[i], false))
                break
                
        // Only draw FVG if formed with an Order Block
        if hasValidOB and showFVG
            b = box.new(bar_index-2, high[2], bar_index, low, border_color=na, bgcolor=upColorC)
            array.unshift(fvgs, FVG.new(b, true, low, high[2], false, false, false))

    if isBearFVG
        bool hasValidOB = false
        for i = 1 to 4
            if close[i] > open[i]
                isSweep = high[i] > high[i+1]
                isStrong = isSweep
                
                if (not strongOBOnly or isStrong)
                    hasValidOB := true
                    if showOB
                        obColor = color.new(colorBear, 70)
                        b = box.new(bar_index-i, high[i], bar_index, low[i], border_color=dnColorL, bgcolor=obColor, text="OB+FVG", text_size=size.tiny, text_color=dnColorL, text_halign=text.align_right, text_valign=text.align_top)
                        array.unshift(obs, OB.new(b, false, high[i], low[i], false))
                break
                
        // Only draw FVG if formed with an Order Block
        if hasValidOB and showFVG
            b = box.new(bar_index-2, low[2], bar_index, high, border_color=na, bgcolor=dnColorC)
            array.unshift(fvgs, FVG.new(b, false, low[2], high, false, false, false))

// Mitigation Engine
if array.size(fvgs) > 0
    for i = array.size(fvgs) - 1 to 0
        f = array.get(fvgs, i)
        
        if not f.invertedMitigated
            box.set_right(f.bx, bar_index)
            
            // 1. Normal Mitigation (touch)
            if not f.mitigated and not f.isInverted
                if (f.isBull and low < f.top) or (not f.isBull and high > f.bot)
                    f.mitigated := true
                    box.set_bgcolor(f.bx, color.new(colorNeut, 90))
            
            // 2. Inversion (close completely through)
            if not f.isInverted
                if (f.isBull and close < f.bot) or (not f.isBull and close > f.top)
                    f.isInverted := true
                    f.isBull := not f.isBull // Flip polarity
                    box.set_bgcolor(f.bx, f.isBull ? color.new(colorBull, 85) : color.new(colorBear, 85))
                    box.set_border_color(f.bx, f.isBull ? colorBull : colorBear)
                    box.set_text(f.bx, "IFVG")
                    box.set_text_size(f.bx, size.tiny)
                    box.set_text_color(f.bx, f.isBull ? colorBull : colorBear)
                    box.set_text_halign(f.bx, text.align_right)
                    box.set_text_valign(f.bx, f.isBull ? text.align_bottom : text.align_top)
            
            // 3. IFVG Mitigation (touch from other side)
            if f.isInverted
                if (f.isBull and low < f.top) or (not f.isBull and high > f.bot)
                    f.invertedMitigated := true
                    box.set_bgcolor(f.bx, color.new(colorNeut, 95))
                    box.set_border_color(f.bx, na)

if array.size(obs) > 0
    for i = array.size(obs) - 1 to 0
        o = array.get(obs, i)
        if not o.mitigated
            box.set_right(o.bx, bar_index)
            if (o.isBull and low < o.top) or (not o.isBull and high > o.bot)
                o.mitigated := true
                box.set_bgcolor(o.bx, color.new(colorNeut, 90))
                box.set_border_color(o.bx, color.new(colorNeut, 80))

// Max Active Limit (Garbage Collection)
int maxSMC = 6

int activeFvgCount = 0
if array.size(fvgs) > 0
    for i = 0 to array.size(fvgs) - 1
        f = array.get(fvgs, i)
        if not f.invertedMitigated
            activeFvgCount += 1
            if activeFvgCount > maxSMC
                f.invertedMitigated := true
                box.delete(f.bx)

int activeObCount = 0
if array.size(obs) > 0
    for i = 0 to array.size(obs) - 1
        o = array.get(obs, i)
        if not o.mitigated
            activeObCount += 1
            if activeObCount > maxSMC
                o.mitigated := true
                box.delete(o.bx)

if array.size(fvgs) > 50
    f = array.pop(fvgs)
    if not na(f.bx)
        box.delete(f.bx)
if array.size(obs) > 50
    o = array.pop(obs)
    if not na(o.bx)
        box.delete(o.bx)

// Premium & Discount
var box pdBox = na
var line pdMid = na
if showPD and array.size(highSwingsExt) > 0 and array.size(lowSwingsExt) > 0
    topPD = array.get(highSwingsExt, 0).p
    botPD = array.get(lowSwingsExt, 0).p
    startIdx = math.max(array.get(highSwingsExt, 0).idx, array.get(lowSwingsExt, 0).idx)
    
    if na(pdBox)
        pdBox := box.new(startIdx, topPD, bar_index, botPD, bgcolor=color.new(colorBull, 95), border_color=colorText, border_style=line.style_dashed)
        pdMid := line.new(startIdx, math.avg(topPD, botPD), bar_index, math.avg(topPD, botPD), color=colorText, style=line.style_dotted)
    else
        box.set_lefttop(pdBox, startIdx, topPD)
        box.set_rightbottom(pdBox, bar_index, botPD)
        line.set_xy1(pdMid, startIdx, math.avg(topPD, botPD))
        line.set_xy2(pdMid, bar_index, math.avg(topPD, botPD))

// =================================================================================================
// 8. MULTI-TIMEFRAME ENGINE
// =================================================================================================
get_mtf_data() =>
    t = ta.ema(close, 20) > ta.ema(close, 50) ? 1 : -1
    [t, close]

[t1_t, t1_c] = request.security(syminfo.tickerid, tf1, get_mtf_data(), lookahead=barmerge.lookahead_off)
[t2_t, t2_c] = request.security(syminfo.tickerid, tf2, get_mtf_data(), lookahead=barmerge.lookahead_off)
[t3_t, t3_c] = request.security(syminfo.tickerid, tf3, get_mtf_data(), lookahead=barmerge.lookahead_off)
[t4_t, t4_c] = request.security(syminfo.tickerid, tf4, get_mtf_data(), lookahead=barmerge.lookahead_off)

// =================================================================================================
// 9. DASHBOARD UI
// =================================================================================================
var table dash = na
if showDashboard
    tSize = dashSize == "Tiny" ? size.tiny : dashSize == "Small" ? size.small : dashSize == "Normal" ? size.normal : dashSize == "Large" ? size.large : dashSize == "Huge" ? size.huge : size.auto
    if na(dash)
        pos = dashLoc == "Top Right" ? position.top_right : dashLoc == "Bottom Right" ? position.bottom_right : dashLoc == "Top Left" ? position.top_left : position.bottom_left
        dash := table.new(pos, 3, 6, bgcolor=color.new(#1e222d, 10), border_width=1, border_color=color.new(colorText, 80))
        
        table.cell(dash, 0, 0, "Timeframe", text_color=colorText, text_size=tSize)
        table.cell(dash, 1, 0, "Trend", text_color=colorText, text_size=tSize)
        table.cell(dash, 2, 0, "Structure", text_color=colorText, text_size=tSize)
        
        table.cell(dash, 0, 1, "Current", text_color=colorText, text_size=tSize)
        table.cell(dash, 0, 2, tf1, text_color=colorText, text_size=tSize)
        table.cell(dash, 0, 3, tf2, text_color=colorText, text_size=tSize)
        table.cell(dash, 0, 4, tf3, text_color=colorText, text_size=tSize)
        table.cell(dash, 0, 5, tf4, text_color=colorText, text_size=tSize)

    cTrendColor = trendExt == 1 ? colorBull : colorBear
    table.cell(dash, 1, 1, trendExt == 1 ? "Bullish" : "Bearish", text_color=cTrendColor, text_size=tSize)
    table.cell(dash, 2, 1, lastEvent, text_color=cTrendColor, text_size=tSize)
    
    table.cell(dash, 1, 2, t1_t == 1 ? "Bullish" : "Bearish", text_color=t1_t == 1 ? colorBull : colorBear, text_size=tSize)
    table.cell(dash, 1, 3, t2_t == 1 ? "Bullish" : "Bearish", text_color=t2_t == 1 ? colorBull : colorBear, text_size=tSize)
    table.cell(dash, 1, 4, t3_t == 1 ? "Bullish" : "Bearish", text_color=t3_t == 1 ? colorBull : colorBear, text_size=tSize)
    table.cell(dash, 1, 5, t4_t == 1 ? "Bullish" : "Bearish", text_color=t4_t == 1 ? colorBull : colorBear, text_size=tSize)
    
    table.cell(dash, 2, 2, "T1", text_color=colorText, text_size=tSize)
    table.cell(dash, 2, 3, "T2", text_color=colorText, text_size=tSize)
    table.cell(dash, 2, 4, "T3", text_color=colorText, text_size=tSize)
    table.cell(dash, 2, 5, "T4", text_color=colorText, text_size=tSize)
````
