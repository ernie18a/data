# LIQS and FIBS Scalp System

- url: https://www.tradingview.com/script/cfDLzrcV-LIQS-and-FIBS-Scalp-System/
- type: indicator
- pine_id: PUB;dc9b11b1993146408ad50490240fb62d
- version: 1.0

## Description

Overview
The "LIQS and FIBS Scalp System" is an advanced Smart Money Concepts (SMC) and Price Action indicator designed for traders seeking high-probability scalping and day trading setups. Instead of relying on lagging indicators, this system dynamically maps critical liquidity sweeps, structure shifts, and optimal trade entry zones based entirely on pure price action.

Key Features

HTF Market Structure Bias (No EMA Lag):
The core of the system determines the main trend bias by tracking the most recent Break of Structure (BOS) or Change of Character (CHoCH) on your selected Higher Timeframe (HTF). If the HTF just broke a swing high, your bias is firmly Bullish. If it broke a swing low, your bias is Bearish. This ensures you are always trading in alignment with true institutional market structure, not a delayed moving average.
HTF Sweeps & Reversals:
Automatically identifies liquidity sweeps at Higher Timeframe highs and lows. It monitors price action around these key historical pivot levels and highlights potential reversal pinbars right at the sweep zones.
LTF BOS & CHoCH Logic:
Detects micro Break of Structure (BOS) and Change of Character (CHoCH) patterns to spot short-term momentum shifts in real-time, helping you catch the very beginning of a new leg.
Deep Fibonacci Setups & Runner Targets:
Following a valid CHoCH, the indicator automatically draws Fibonacci retracement zones (0.318 - 0.618) representing optimal entry points. It dynamically projects logical Stop Loss zones and extends up to Target 6 for runners to capture massive long-term trends:
Target 1 & Target 2 for short-term scalps.
Target 3 & Target 4 (3.618 - 4.236 extensions) for day trades.
Target 5 & Target 6 (5.618 - 6.854 extensions) to hold your runners and ride extreme trend continuation.
A-Plus Setup Filter & VWAP:
To protect you from fake breakouts and low-probability trades, the system validates every entry.
Pro-trend setups that align with both the HTF Structure Bias and the VWAP are highlighted with colored entry and target boxes.
Counter-trend or low-probability setups are visually muted (grayed out) so you can easily ignore them.
Built-in alerts notify you only when a micro CHoCH perfectly aligns with the HTF trend direction!
How to Use
Wait for price to sweep an HTF liquidity level, watch for a valid CHoCH in the opposite direction, and set your limit orders inside the highlighted 0.318 - 0.618 Fibonacci reaction box. Trust the colored boxes (A-Plus setups) and ignore the gray ones. Take partial profits at T1 and T2, then leave runners for the deeper T3 to T6 targets!

Disclaimer
This script is provided for educational and informational purposes only and does not constitute financial advice. Trading in financial markets involves a high degree of risk and may not be suitable for all investors. Past performance is not indicative of future results. Always conduct your own research, use strict risk management, and perform thorough backtesting before trading with real funds.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © erdensedat

//@version=6
indicator("LIQS and FIBS Scalp System", overlay = true, max_lines_count = 500, max_boxes_count = 500, max_labels_count = 500)

// =====================================================================
// ==================== WATERMARK & VWAP ===============================
// =====================================================================
var table wmTable = table.new(position.bottom_right, 1, 1)
if barstate.isfirst
    table.cell(wmTable, 0, 0, "erdensedat", text_color = color.new(color.gray, 70), text_size = size.huge)

showVwap = input.bool(true, "Show VWAP", group="Extra Features")
vwapVal = ta.vwap
plot(showVwap ? vwapVal : na, color=color.blue, title="VWAP")

// =====================================================================
// ==================== HTF SETTINGS & BIAS ============================
// =====================================================================
grpHtf = "Higher Timeframe Settings"
htf = input.timeframe("720", "Higher Timeframe (HTF)", group=grpHtf)
useBiasFilter = input.bool(true, "Use Bias Filter (Gray out invalid setups)", group=grpHtf)
grayCol = input.color(color.new(color.gray, 80), "Invalid Setup Box Color", group=grpHtf)

// HTF Bias: Based on the latest HTF Structure Break (BOS/CHoCH)
f_htf_bias() =>
    pLength = 5 // Internal pivot length for HTF structure
    ph = ta.pivothigh(high, pLength, pLength)
    pl = ta.pivotlow(low, pLength, pLength)
    
    var float lastPh = na
    var float lastPl = na
    var int trend = 0 
    
    if not na(ph)
        lastPh := ph
    if not na(pl)
        lastPl := pl
        
    if not na(lastPh) and close > lastPh
        trend := 1
        lastPh := na // reset after break
    if not na(lastPl) and close < lastPl
        trend := -1
        lastPl := na // reset after break
        
    trend

htfBiasDir = request.security(syminfo.tickerid, htf, f_htf_bias())
isHtfBullish = htfBiasDir == 1
isHtfBearish = htfBiasDir == -1

// =====================================================================
// ==================== 1. HTF SWEEPS & REVERSALS ======================
// =====================================================================
grpSweeps = "HTF Sweeps & Reversals"
maxLevels = input.int(3, "Max Sweep Levels (n)", minval = 1, group=grpSweeps)

bullColor = input.color(#089981, "Bullish Sweep Color (Low)", group=grpSweeps)
bearColor = input.color(#f23645, "Bearish Sweep Color (High)", group=grpSweeps)

// --- Indicators for Labels ---
float rsiVal = ta.rsi(close, 14)
float momVal = ta.mom(close, 10)
[diPlus, diMinus, adx] = ta.dmi(14, 14)
float atr = ta.atr(14)

type FiboSetup
    line[] lines
    label[] labels
    box[] boxes
    float bTop
    float bBot
    int dir // 1 for bull, -1 for bear
    bool isValid
    box bT3
    box bT4
    box bT5
    box bT6
    float t2Price
    float t4Price
    bool t2Hit
    bool t4Hit
    color tgCol

type Level
    float price
    line ln
    line extLn
    bool swept
    bool reversed
    box sweepBox
    label[] extraLabels
    line[] extraLines
    int lastDottedTouchBar

var bullLevels = array.new<Level>()
var bearLevels = array.new<Level>()

var float currentHtfHigh = na
var int currentHtfHighBar = na
var float currentHtfLow = na
var int currentHtfLowBar = na

bool newHtfBar = ta.change(time(htf)) != 0

if newHtfBar
    if not na(currentHtfHigh)
        line lBear = line.new(currentHtfHighBar, currentHtfHigh, bar_index, currentHtfHigh, color = bearColor, style = line.style_solid, width = 2)
        array.unshift(bearLevels, Level.new(currentHtfHigh, lBear, na, false, false, na, array.new_label(), array.new_line(), 0))
        while array.size(bearLevels) > maxLevels
            Level removed = array.pop(bearLevels)
            line.delete(removed.ln)
            line.delete(removed.extLn)
            box.delete(removed.sweepBox)
            for lb in removed.extraLabels
                label.delete(lb)
            for extLine in removed.extraLines
                line.delete(extLine)
            
    if not na(currentHtfLow)
        line lBull = line.new(currentHtfLowBar, currentHtfLow, bar_index, currentHtfLow, color = bullColor, style = line.style_solid, width = 2)
        array.unshift(bullLevels, Level.new(currentHtfLow, lBull, na, false, false, na, array.new_label(), array.new_line(), 0))
        while array.size(bullLevels) > maxLevels
            Level removed = array.pop(bullLevels)
            line.delete(removed.ln)
            line.delete(removed.extLn)
            box.delete(removed.sweepBox)
            for lb in removed.extraLabels
                label.delete(lb)
            for extLine in removed.extraLines
                line.delete(extLine)
            
    currentHtfHigh := high
    currentHtfHighBar := bar_index
    currentHtfLow := low
    currentHtfLowBar := bar_index
else
    if high > currentHtfHigh or na(currentHtfHigh)
        currentHtfHigh := high
        currentHtfHighBar := bar_index
    if low < currentHtfLow or na(currentHtfLow)
        currentHtfLow := low
        currentHtfLowBar := bar_index

isBearishPinbar() =>
    body = math.abs(close - open)
    upperWick = high - math.max(close, open)
    upperWick > body * 1.5 and upperWick > atr * 0.2

isBullishPinbar() =>
    body = math.abs(close - open)
    lowerWick = math.min(close, open) - low
    lowerWick > body * 1.5 and lowerWick > atr * 0.2

formatVal(float v) => str.tostring(v, format.mintick)

if array.size(bearLevels) > 0
    for i = 0 to array.size(bearLevels) - 1
        Level b = array.get(bearLevels, i)
        if not b.swept
            line.set_x2(b.ln, bar_index)
            if high > b.price
                b.swept := true
                line.set_style(b.ln, line.style_dashed)
                b.extLn := line.new(bar_index, b.price, bar_index, b.price, color = bearColor, style = line.style_dotted, width = 2)
                
                b.sweepBox := box.new(left = bar_index, top = high, right = bar_index + 1, bottom = b.price, border_color = bearColor, border_style = line.style_dashed, border_width = 1, bgcolor = color.new(bearColor, 90))
                     
                if close < b.price
                    b.reversed := true
                    line lRev = line.new(bar_index, high, bar_index, close, color=bearColor, width=2)
                    array.push(b.extraLines, lRev)
                    if isBearishPinbar()
                        label pbLb = label.new(bar_index, high + (atr * 0.2), text="▼", color=#00000000, textcolor=bearColor, style=label.style_label_down, size=size.normal)
                        array.push(b.extraLabels, pbLb)
        else if b.swept
            if not na(b.extLn)
                line.set_x2(b.extLn, bar_index)
            if bar_index > line.get_x1(b.extLn) and high >= b.price and close < b.price
                if b.lastDottedTouchBar != bar_index 
                    b.lastDottedTouchBar := bar_index
                    label dotLb = label.new(bar_index, high + (atr * 0.1), text="●", style=label.style_none, textcolor=bearColor, size=size.tiny)
                    array.push(b.extraLabels, dotLb)
            if not b.reversed
                if close < b.price
                    b.reversed := true
                    line lRev = line.new(bar_index - 1, high[1], bar_index, close, color=bearColor, width=2)
                    array.push(b.extraLines, lRev)
                    if isBearishPinbar()
                        label pbLb = label.new(bar_index, high + (atr * 0.2), text="▼", color=#00000000, textcolor=bearColor, style=label.style_label_down, size=size.normal)
                        array.push(b.extraLabels, pbLb)

if array.size(bullLevels) > 0
    for i = 0 to array.size(bullLevels) - 1
        Level b = array.get(bullLevels, i)
        if not b.swept
            line.set_x2(b.ln, bar_index)
            if low < b.price
                b.swept := true
                line.set_style(b.ln, line.style_dashed)
                b.extLn := line.new(bar_index, b.price, bar_index, b.price, color = bullColor, style = line.style_dotted, width = 2)
                
                b.sweepBox := box.new(left = bar_index, top = b.price, right = bar_index + 1, bottom = low, border_color = bullColor, border_style = line.style_dashed, border_width = 1, bgcolor = color.new(bullColor, 90))
                     
                if close > b.price
                    b.reversed := true
                    line lRev = line.new(bar_index, low, bar_index, close, color=bullColor, width=2)
                    array.push(b.extraLines, lRev)
                    if isBullishPinbar()
                        label pbLb = label.new(bar_index, low - (atr * 0.2), text="▲", color=#00000000, textcolor=bullColor, style=label.style_label_up, size=size.normal)
                        array.push(b.extraLabels, pbLb)
        else if b.swept
            if not na(b.extLn)
                line.set_x2(b.extLn, bar_index)
            if bar_index > line.get_x1(b.extLn) and low <= b.price and close > b.price
                if b.lastDottedTouchBar != bar_index 
                    b.lastDottedTouchBar := bar_index
                    label dotLb = label.new(bar_index, low - (atr * 0.1), text="●", style=label.style_none, textcolor=bullColor, size=size.tiny)
                    array.push(b.extraLabels, dotLb)
            if not b.reversed
                if close > b.price
                    b.reversed := true
                    line lRev = line.new(bar_index - 1, low[1], bar_index, close, color=bullColor, width=2)
                    array.push(b.extraLines, lRev)
                    if isBullishPinbar()
                        label pbLb = label.new(bar_index, low - (atr * 0.2), text="▲", color=#00000000, textcolor=bullColor, style=label.style_label_up, size=size.normal)
                        array.push(b.extraLabels, pbLb)

// =====================================================================
// ==================== 2. FIBONACCI SETUPS ============================
// =====================================================================
grpFib = "Fibonacci Setups"
showLastFib = input.int(1, "Show Last N Fibo Setups", minval=1, maxval=10, group=grpFib)
showReactBox = input.bool(true, "Show 0.318-0.618 Reaction Box", group=grpFib)
reactBoxBullCol = input.color(color.new(color.rgb(8,153,129), 80), "Bullish Box Color", group=grpFib)
reactBoxBearCol = input.color(color.new(color.red, 80), "Bearish Box Color", group=grpFib)

targetBoxCol = input.color(color.new(color.blue, 85), "Target Box Color (1.47-1.55 & 2.56-2.68)", group=grpFib)
slBoxCol = input.color(color.new(color.red, 85), "Stop Loss Box Color (-0.23 to -0.31)", group=grpFib)

var float[] fibLevels = array.from(0.0, 1.0) 

var FiboSetup[] fibSetups = array.new<FiboSetup>()

f_drawFib(float priceA, float priceB, int startBar) =>
    float diff = priceB - priceA
    float p318 = priceA + diff * 0.318
    float p618 = priceA + diff * 0.618
    float bTop = math.max(p318, p618)
    float bBot = math.min(p318, p618)
    
    int dir = diff > 0 ? 1 : -1
    
    // Check Bias Validity
    bool isValid = true
    if useBiasFilter
        if dir == 1
            if (not isHtfBullish) or (close < vwapVal)
                isValid := false
        else
            if (not isHtfBearish) or (close > vwapVal)
                isValid := false

    FiboSetup newSetup = FiboSetup.new(array.new_line(), array.new_label(), array.new_box(), bTop, bBot, dir, isValid, na, na, na, na, 0.0, 0.0, false, false, na)
    
    // Reaction Box (0.318 - 0.618)
    if showReactBox
        color bCol = dir > 0 ? reactBoxBullCol : reactBoxBearCol
        if not isValid
            bCol := grayCol
            
        string bTxt = dir > 0 ? "Bullish Entry Zone\n" + str.tostring(bTop, format.mintick) + " - " + str.tostring(bBot, format.mintick) : "Sell Entry Zone\n" + str.tostring(bTop, format.mintick) + " - " + str.tostring(bBot, format.mintick)
        if not isValid
            bTxt := "Counter-Trend Zone\n(Lower Probability)"
            
        box b = box.new(startBar, bTop, bar_index, bBot, border_color = na, bgcolor = bCol, text = bTxt, text_color = color.white, text_halign = text.align_right, text_valign = text.align_center, text_size = size.small)
        array.push(newSetup.boxes, b)

    // Stop Loss Box (-0.23 - -0.31)
    float pSl1 = priceA + diff * -0.23
    float pSl2 = priceA + diff * -0.31
    color slColToUse = isValid ? slBoxCol : grayCol
    string slTxt = "Stop Loss\n" + str.tostring(math.max(pSl1, pSl2), format.mintick) + " - " + str.tostring(math.min(pSl1, pSl2), format.mintick)
    box bSl = box.new(startBar, math.max(pSl1, pSl2), bar_index, math.min(pSl1, pSl2), border_color = na, bgcolor = slColToUse, text = slTxt, text_color = color.white, text_halign = text.align_right, text_valign = text.align_center, text_size = size.small)
    array.push(newSetup.boxes, bSl)

    // Target 1 Box (1.47 - 1.55)
    float p147 = priceA + diff * 1.47
    float p155 = priceA + diff * 1.55
    color tgColToUse = isValid ? targetBoxCol : grayCol
    newSetup.tgCol := tgColToUse
    string t1Txt = "Target 1\n" + str.tostring(math.max(p147, p155), format.mintick) + " - " + str.tostring(math.min(p147, p155), format.mintick)
    box bT1 = box.new(startBar, math.max(p147, p155), bar_index, math.min(p147, p155), border_color = na, bgcolor = tgColToUse, text = t1Txt, text_color = color.white, text_halign = text.align_right, text_valign = text.align_center, text_size = size.small)
    array.push(newSetup.boxes, bT1)

    // Target 2 Box (2.56 - 2.68)
    float p256 = priceA + diff * 2.56
    float p268 = priceA + diff * 2.68
    newSetup.t2Price := dir == 1 ? math.min(p256, p268) : math.max(p256, p268) // Price edge to hit T2
    string t2Txt = "Target 2\n" + str.tostring(math.max(p256, p268), format.mintick) + " - " + str.tostring(math.min(p256, p268), format.mintick)
    box bT2 = box.new(startBar, math.max(p256, p268), bar_index, math.min(p256, p268), border_color = na, bgcolor = tgColToUse, text = t2Txt, text_color = color.white, text_halign = text.align_right, text_valign = text.align_center, text_size = size.small)
    array.push(newSetup.boxes, bT2)
    
    // Target 3 Box (3.61 - 3.75) - Hidden initially
    float p361 = priceA + diff * 3.61
    float p375 = priceA + diff * 3.75
    string t3Txt = "Target 3\n" + str.tostring(math.max(p361, p375), format.mintick) + " - " + str.tostring(math.min(p361, p375), format.mintick)
    newSetup.bT3 := box.new(startBar, math.max(p361, p375), bar_index, math.min(p361, p375), border_color = na, bgcolor = na, text = t3Txt, text_color = na, text_halign = text.align_right, text_valign = text.align_center, text_size = size.small)
    array.push(newSetup.boxes, newSetup.bT3)

    // Target 4 Box (4.23 - 4.35) - Hidden initially
    float p423 = priceA + diff * 4.23
    float p435 = priceA + diff * 4.35
    newSetup.t4Price := dir == 1 ? math.min(p423, p435) : math.max(p423, p435) // Price edge to hit T4
    string t4Txt = "Target 4\n" + str.tostring(math.max(p423, p435), format.mintick) + " - " + str.tostring(math.min(p423, p435), format.mintick)
    newSetup.bT4 := box.new(startBar, math.max(p423, p435), bar_index, math.min(p423, p435), border_color = na, bgcolor = na, text = t4Txt, text_color = na, text_halign = text.align_right, text_valign = text.align_center, text_size = size.small)
    array.push(newSetup.boxes, newSetup.bT4)

    // Target 5 Box (5.61 - 5.75) - Hidden initially
    float p561 = priceA + diff * 5.61
    float p575 = priceA + diff * 5.75
    string t5Txt = "Target 5\n" + str.tostring(math.max(p561, p575), format.mintick) + " - " + str.tostring(math.min(p561, p575), format.mintick)
    newSetup.bT5 := box.new(startBar, math.max(p561, p575), bar_index, math.min(p561, p575), border_color = na, bgcolor = na, text = t5Txt, text_color = na, text_halign = text.align_right, text_valign = text.align_center, text_size = size.small)
    array.push(newSetup.boxes, newSetup.bT5)

    // Target 6 Box (6.85 - 7.00) - Hidden initially
    float p685 = priceA + diff * 6.85
    float p700 = priceA + diff * 7.00
    string t6Txt = "Target 6\n" + str.tostring(math.max(p685, p700), format.mintick) + " - " + str.tostring(math.min(p685, p700), format.mintick)
    newSetup.bT6 := box.new(startBar, math.max(p685, p700), bar_index, math.min(p685, p700), border_color = na, bgcolor = na, text = t6Txt, text_color = na, text_halign = text.align_right, text_valign = text.align_center, text_size = size.small)
    array.push(newSetup.boxes, newSetup.bT6)
    
    for lvl in fibLevels
        float lvlPrice = priceA + diff * lvl
        color lvlColor = color.gray
            
        line l = line.new(startBar, lvlPrice, bar_index, lvlPrice, color = lvlColor, style = line.style_solid)
        label lb = label.new(bar_index, lvlPrice, str.tostring(lvl), color = color.new(color.white, 100), textcolor = lvlColor, style = label.style_label_left, size = size.small)
        
        array.push(newSetup.lines, l)
        array.push(newSetup.labels, lb)
        
    array.push(fibSetups, newSetup)
    
    if array.size(fibSetups) > showLastFib
        FiboSetup oldestSetup = array.shift(fibSetups)
        for l in oldestSetup.lines
            line.delete(l)
        for lb in oldestSetup.labels
            label.delete(lb)
        for b in oldestSetup.boxes
            box.delete(b)

f_getRangeExtremes(int startBar, int endBar) =>
    float hh = high
    float ll = low
    if endBar > startBar and startBar > 0
        int lookback = endBar - startBar
        for i = 0 to lookback
            if high[i] > hh
                hh := high[i]
            if low[i] < ll
                ll := low[i]
    [hh, ll]

// Update dynamic targets
if array.size(fibSetups) > 0
    for i = 0 to array.size(fibSetups) - 1
        FiboSetup setup = array.get(fibSetups, i)
        
        // Check T2 hit
        if not setup.t2Hit
            if (setup.dir == 1 and high >= setup.t2Price) or (setup.dir == -1 and low <= setup.t2Price)
                setup.t2Hit := true
                box.set_bgcolor(setup.bT3, setup.tgCol)
                box.set_text_color(setup.bT3, color.white)
                box.set_bgcolor(setup.bT4, setup.tgCol)
                box.set_text_color(setup.bT4, color.white)
                
        // Check T4 hit
        if setup.t2Hit and not setup.t4Hit
            if (setup.dir == 1 and high >= setup.t4Price) or (setup.dir == -1 and low <= setup.t4Price)
                setup.t4Hit := true
                box.set_bgcolor(setup.bT5, setup.tgCol)
                box.set_text_color(setup.bT5, color.white)
                box.set_bgcolor(setup.bT6, setup.tgCol)
                box.set_text_color(setup.bT6, color.white)

// =====================================================================
// ==================== 3. BOS / CHOCH & SMC BIAS ======================
// =====================================================================
grpBOS = "BOS/CHoCH Logic"
len         = input.int(10, "Fractal Length (odd)", minval=3, maxval=51, group=grpBOS)
barsToRight = input.int(10, "Bars to Right", minval=1, maxval=300, group=grpBOS)
requireBody = input.bool(true, "Break = Close Beyond Level", group=grpBOS)
maxKeep     = input.int(6, "Show Last N Broken (BOS/CHoCH)", minval=1, maxval=20000, group=grpBOS)

candCol     = input.color(color.yellow, "Candidate Color", group=grpBOS)
candW       = input.int(1, "Candidate Width", minval=1, maxval=5, group=grpBOS)
candStyleS  = input.string("Dotted", "Candidate Style", options=["Solid","Dashed","Dotted"], group=grpBOS)
showCandText = input.bool(true, "Show Candidate Text", group=grpBOS)

brkUpCol    = input.color(color.rgb(8,153,129), "BOS/CHoCH UP Color (Green)", group=grpBOS)
brkDnCol    = input.color(color.new(color.red, 0), "BOS/CHoCH DN Color (Red)", group=grpBOS)
brkW        = input.int(3, "Broken Width", minval=1, maxval=5, group=grpBOS)
brkStyleS   = input.string("Solid", "Broken Style", options=["Solid","Dashed","Dotted"], group=grpBOS)

f_ls(string s) => s == "Solid" ? line.style_solid : s == "Dashed" ? line.style_dashed : line.style_dotted

candStyle = f_ls(candStyleS)
brkStyle  = f_ls(brkStyleS)

L = (len % 2 == 0) ? (len + 1) : len
p = int(L / 2)
tfSec = timeframe.in_seconds(timeframe.period)
extMs = tfSec * 1000 * barsToRight

phVal = ta.pivothigh(high, p, p)
plVal = ta.pivotlow(low,  p, p)
phHit = not na(phVal)
plHit = not na(plVal)

var float upLvl = na
var int   upT   = na
var int   upBar = na
var bool  upBroken = false
var line  upLine = na
var label upCandLb = na

var float dnLvl = na
var int   dnT   = na
var int   dnBar = na
var bool  dnBroken = false
var line  dnLine = na
var label dnCandLb = na

var int os = 0 

type BrokenStruct
    line ln
    label lb

var BrokenStruct[] brkStructures = array.new<BrokenStruct>()

if phHit
    if not na(upLine) and not upBroken
        line.delete(upLine)
    if not na(upCandLb)
        label.delete(upCandLb)
        
    upLvl := phVal
    upT   := time[p]
    upBar := bar_index[p]
    upBroken := false
    upLine := line.new(upT, upLvl, time + extMs, upLvl, xloc=xloc.bar_time, extend=extend.none, color=candCol, style=candStyle, width=candW)
    
    if showCandText
        upCandLb := label.new(upT, upLvl, "𝗕𝗢𝗦 ↑", xloc=xloc.bar_time, style=label.style_label_down, textcolor=brkUpCol, color=color.new(color.white, 100), size=size.normal)

if plHit
    if not na(dnLine) and not dnBroken
        line.delete(dnLine)
    if not na(dnCandLb)
        label.delete(dnCandLb)
        
    dnLvl := plVal
    dnT   := time[p]
    dnBar := bar_index[p]
    dnBroken := false
    dnLine := line.new(dnT, dnLvl, time + extMs, dnLvl, xloc=xloc.bar_time, extend=extend.none, color=candCol, style=candStyle, width=candW)
    
    if showCandText
        dnCandLb := label.new(dnT, dnLvl, "𝗕𝗢𝗦 ↓", xloc=xloc.bar_time, style=label.style_label_up, textcolor=brkDnCol, color=color.new(color.white, 100), size=size.normal)

if not na(upLine) and not upBroken
    line.set_x2(upLine, time + extMs)
if not na(dnLine) and not dnBroken
    line.set_x2(dnLine, time + extMs)

brkUp = false
brkDn = false

if not na(upLvl) and not upBroken
    brkUp := requireBody ? (close > upLvl) : (high > upLvl)
if not na(dnLvl) and not dnBroken
    brkDn := requireBody ? (close < dnLvl) : (low < dnLvl)

if brkUp
    upBroken := true
    if not na(upLine)
        line.set_color(upLine, brkUpCol)
        line.set_style(upLine, brkStyle)
        line.set_width(upLine, brkW)
        line.set_x2(upLine, time)
        
    if not na(upCandLb)
        label.delete(upCandLb)
        upCandLb := na
        
    bool isChoch = os == -1
    string typeStr = isChoch ? "𝗖𝗛𝗼𝗖𝗛" : "𝗕𝗢𝗦"
    
    if isChoch
        if isHtfBullish
            alert("Bullish CHoCH occurred aligning with HTF Trend!", alert.freq_once_per_bar_close)
        string infoTxt = "Vol: " + str.tostring(volume, format.volume) + "\nDI+: " + str.tostring(diPlus, "#.##") + " | DI-: " + str.tostring(diMinus, "#.##") + "\nRSI: " + str.tostring(rsiVal, "#.##") + "\nMom: " + formatVal(momVal)
        typeStr := typeStr + "\n" + infoTxt

    label lbTitle = label.new(int(math.avg(time, upT)), upLvl, typeStr, xloc=xloc.bar_time, style=label.style_label_down, textcolor=brkUpCol, color=color.new(color.white, 100), size=isChoch ? size.small : size.normal)
    
    array.push(brkStructures, BrokenStruct.new(upLine, lbTitle))
    upLine := na
    os := 1
    
    if isChoch
        [hh, ll] = f_getRangeExtremes(upBar, bar_index)
        f_drawFib(ll, hh, upBar)

if brkDn
    dnBroken := true
    if not na(dnLine)
        line.set_color(dnLine, brkDnCol)
        line.set_style(dnLine, brkStyle)
        line.set_width(dnLine, brkW)
        line.set_x2(dnLine, time)
        
    if not na(dnCandLb)
        label.delete(dnCandLb)
        dnCandLb := na
        
    bool isChoch = os == 1
    string typeStr = isChoch ? "𝗖𝗛𝗼𝗖𝗛" : "𝗕𝗢𝗦"
    
    if isChoch
        if isHtfBearish
            alert("Bearish CHoCH occurred aligning with HTF Trend!", alert.freq_once_per_bar_close)
        string infoTxt = "Vol: " + str.tostring(volume, format.volume) + "\nDI+: " + str.tostring(diPlus, "#.##") + " | DI-: " + str.tostring(diMinus, "#.##") + "\nRSI: " + str.tostring(rsiVal, "#.##") + "\nMom: " + formatVal(momVal)
        typeStr := typeStr + "\n" + infoTxt

    label lbTitle = label.new(int(math.avg(time, dnT)), dnLvl, typeStr, xloc=xloc.bar_time, style=label.style_label_up, textcolor=brkDnCol, color=color.new(color.white, 100), size=isChoch ? size.small : size.normal)
    
    array.push(brkStructures, BrokenStruct.new(dnLine, lbTitle))
    dnLine := na
    os := -1
    
    if isChoch
        [hh, ll] = f_getRangeExtremes(dnBar, bar_index)
        f_drawFib(hh, ll, dnBar)

while array.size(brkStructures) > maxKeep
    BrokenStruct removed = array.shift(brkStructures)
    line.delete(removed.ln)
    label.delete(removed.lb)

// =====================================================================
// ==================== ALERTS =========================================
// =====================================================================
var bool wasInBullZone = false
var bool wasInBearZone = false

bool currentlyInBullZone = false
bool currentlyInBearZone = false

if array.size(fibSetups) > 0
    FiboSetup activeSetup = array.get(fibSetups, array.size(fibSetups) - 1)
    if activeSetup.dir == 1 and activeSetup.isValid
        if low <= activeSetup.bTop and high >= activeSetup.bBot
            currentlyInBullZone := true
    else if activeSetup.dir == -1 and activeSetup.isValid
        if low <= activeSetup.bTop and high >= activeSetup.bBot
            currentlyInBearZone := true

if currentlyInBullZone and not wasInBullZone
    alert("Price entered Bullish Entry Zone!", alert.freq_once_per_bar_close)

if currentlyInBearZone and not wasInBearZone
    alert("Price entered Bearish (Sell) Entry Zone!", alert.freq_once_per_bar_close)

wasInBullZone := currentlyInBullZone
wasInBearZone := currentlyInBearZone

if barstate.islast
    for setup in fibSetups
        for l in setup.lines
            line.set_x2(l, bar_index + 10)
        for lb in setup.labels
            label.set_x(lb, bar_index + 10)
        for b in setup.boxes
            box.set_right(b, bar_index + 10)

var table biasTable = table.new(position.top_right, 1, 2, bgcolor = color.new(color.black, 80), frame_color = color.gray, frame_width = 1)
if barstate.islast
    string biasText = os == 1 ? "BIAS: BULLISH" : os == -1 ? "BIAS: BEARISH" : "BIAS: NEUTRAL"
    color biasCol = os == 1 ? brkUpCol : os == -1 ? brkDnCol : color.gray
    table.cell(biasTable, 0, 0, biasText, text_color = biasCol, text_size = size.normal)
    
    string htfBiasTxt = isHtfBullish ? "HTF TREND: BULLISH" : "HTF TREND: BEARISH"
    color htfBiasCol = isHtfBullish ? brkUpCol : brkDnCol
    table.cell(biasTable, 0, 1, htfBiasTxt, text_color = htfBiasCol, text_size = size.small)

// =====================================================================
// ==================== SCRIPT DESCRIPTION & DISCLAIMER =================
// =====================================================================
// DESCRIPTION:
// The "LIQS and FIBS Scalp System" is a comprehensive smart money and 
// price action trading indicator designed to identify high-probability 
// scalping and day trading setups.
//
// Key Features:
// 1. HTF Sweeps & Reversals: Detects liquidity sweeps of Higher Timeframe 
//    (HTF) highs and lows, filtering for reversal pinbars.
// 2. BOS & CHoCH Logic: Identifies Break of Structure (BOS) and Change 
//    of Character (CHoCH) patterns to determine short-term shifts in 
//    momentum.
// 3. Fibonacci Entry Setups: Automatically plots optimal trade entry 
//    zones (0.318 - 0.618), profit targets, and stop-loss levels based 
//    on the swing extremes that caused the CHoCH.
// 4. Trend Bias Filter: Evaluates the HTF trend (using EMA 50) and VWAP 
//    to gray-out counter-trend (low probability) setups, helping traders 
//    focus only on "A-plus" setups that align with the broader market 
//    direction.
//
// DISCLAIMER:
// This script is provided for educational and informational purposes only. 
// It does not constitute financial advice. Trading in financial markets 
// involves significant risk of loss and is not suitable for all investors. 
// Past performance is not indicative of future results. Always conduct 
// your own research and backtest strategies before risking real capital.
````
