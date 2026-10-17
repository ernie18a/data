# WiselyWealth : EMA RSI Smart Money Zone Tracker

- url: https://www.tradingview.com/script/NVczDGLi-WiselyWealth-EMA-RSI-Smart-Money-Zone-Tracker/
- type: indicator
- pine_id: PUB;82d0b84bc6124c9a93632dbf1b98354c
- version: 1.0

## Description

### Comprehensive Guide to the "WiselyWealth : EMA RSI Smart Money Zone Tracker" Indicator

**Introduction: What is the Script and Its Purpose?**
The script provided in the file "EMA RSI Smart Money Zone Tracker" is an advanced, multi-faceted trading indicator programmed in Pine Script version 6 for the TradingView platform. The primary purpose of this script is to provide traders with a highly structured, all-in-one trading system that successfully bridges traditional trend-following technical analysis with modern Smart Money Concepts (SMC). Many traders struggle to combine momentum indicators with institutional supply and demand zones without cluttering their charts. This script solves that problem by automating signal generation, dynamically calculating risk-to-reward parameters, and elegantly visualizing institutional footprints. It is designed to keep traders on the right side of the trend while simultaneously preventing them from entering trades in poor structural locations, ultimately aiming to increase the probability of a successful trade.

**Working Mechanism: How the Script Detects Trading Signals**
The operational mechanics of this indicator are divided into three core pillars: baseline trend confirmation, institutional market structure mapping, and automated risk management.

At its core, the script detects buy and sell signals by evaluating two classic technical indicators: the Exponential Moving Average (EMA) and the Relative Strength Index (RSI). The script utilizes a 9-period EMA as its primary trend filter. When the price closes above the EMA line, the algorithm interprets the current market structure as bullish; conversely, closing below the EMA signifies a bearish trend. However, trend alone is not enough to trigger a signal. The script simultaneously analyzes market momentum using a 14-period RSI. The RSI acts as a definitive trigger utilizing a baseline reference level of 50.0. A raw Buy Signal is strictly generated when the price is above the 9 EMA and the RSI crosses above the 50 level, whereas a Sell Signal requires the price to be below the EMA with the RSI dropping below 50. To prevent chart clutter and avoid overtrading during extended trends, the script features a "One at a time" filter. This intelligent mechanism ignores any subsequent signals in the same direction while a trade is currently active, ensuring the trader focuses on managing the initial entry until it hits the Stop Loss or the final Take Profit.

Beyond basic signals, the script continuously maps Smart Money Concepts (SMC) in the background. It detects Order Blocks (OB) by identifying structural breaks based on a 10-bar pivot swing length. When the price breaks a confirmed swing high, the script marks the lowest candle prior to the breakout as a Bullish Order Block. It also identifies Fair Value Gaps (FVG) by scanning for 3-candle price imbalances. To ensure that only significant institutional gaps are displayed, the script filters out market noise by requiring the gap to be larger than a specific Average True Range (ATR) multiplier, which is set to 0.25 by default.

Once a signal is triggered, the script executes its risk management mechanism. It calculates a dynamic Stop Loss (SL) by looking back at the previous 4 candles to find the lowest low for a long position, or the highest high for a short position, and adds a customizable price buffer. Furthermore, it projects three distinct Take Profit (TP1, TP2, TP3) levels using a fixed price step distance (defaulted to 10.0), drawing clean, gradient-faded projection boxes on the chart to visualize the active trade.

**How to Use: Recommended Settings and Suitable Markets**
To maximize the effectiveness of the "EMA RSI Smart Money Zone Tracker", traders should align the script's settings with the specific asset they are trading. The default settings for the core indicators (9 EMA and 14 RSI) are optimized for short-to-medium-term momentum trading and should generally remain unchanged. However, the "SL Buffer (Price)" and "TP Step (Price Distance)" must be calibrated according to the specific market's volatility. For highly volatile assets like Crypto or specific Forex pairs (e.g., GBP/JPY), traders should increase the TP Step and SL Buffer to account for wider price swings and prevent premature stop-outs.

Regarding the most suitable market environment, this indicator thrives in markets that highly respect institutional order flow and structural liquidity. Therefore, major Forex pairs, robust commodities like Gold, and major equity indices (such as the S&P 500 or NASDAQ) are highly recommended. Most importantly, the developer has specifically engineered this script for a particular timeframe. The indicator includes a built-in visual warning system that activates if the script is applied to anything other than the 15-minute (15m) chart. Therefore, to achieve the most accurate SMC zone detection and the highest reliability of EMA/RSI crossover signals, traders should strictly utilize this indicator on the 15-minute timeframe. Traders should look for signal confluences—for example, taking an EMA/RSI buy signal only when the price has just mitigated a Bullish Order Block or bounced optimally from a Bullish Fair Value Gap.

## Source Code

````pine
//@version=6
indicator("WiselyWealth : EMA RSI Smart Money Zone Tracker", shorttitle = "EMA+RSI SMC Pro", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500, max_bars_back = 500)

// ==============================================================================
// 1. INPUT SETTINGS
// ==============================================================================

// ───────────── Core Indicator Settings ─────────────
grp_sig    = "1. Core Indicators & Signal"
emaLen     = input.int(9, "EMA Length", minval = 1, group = grp_sig, tooltip = "Sets the length for the Exponential Moving Average baseline trend filter. Price above indicates bullish trend; price below indicates bearish trend.")
rsiLen     = input.int(14, "RSI Length", minval = 1, group = grp_sig, tooltip = "Sets the lookback period for the Relative Strength Index (RSI) to evaluate market momentum.")
rsiLevel   = input.float(50.0, "RSI Reference Level", group = grp_sig, tooltip = "Defines the middle baseline for RSI. Bullish entry requires RSI above this level, while Bearish entry requires RSI below it (default is 50.0).")
oneAtATime = input.bool(true, "One at a time (Filter same-direction repeat signals)", group = grp_sig, tooltip = "When enabled, ignores subsequent signals in the same direction while a trade is active until it reaches Stop Loss or Take Profit 3.")

// ───────────── Risk & Target Settings ─────────────
grp_risk   = "2. Risk & Target (SL / TP)"
slLookback = input.int(4, "SL Lookback Bars", minval = 1, group = grp_risk, tooltip = "Number of previous candles checked to find the lowest low (for Long) or highest high (for Short) prior to the signal bar.")
slBuffer   = input.float(0.0, "SL Buffer (Price)", minval = 0.0, step = 0.1, group = grp_risk, tooltip = "Additional price buffer placed beyond the swing low/high to protect against market noise and spread.")
tpStep     = input.float(10.0, "TP Step (Price Distance)", minval = 0.01, step = 0.5, group = grp_risk, tooltip = "Fixed price distance per TP level: TP1 = Entry ± 1x Step, TP2 = Entry ± 2x Step, and TP3 = Entry ± 3x Step.")
atrLen     = input.int(14, "ATR Length", minval = 1, group = grp_risk, tooltip = "Period used to calculate the Average True Range (ATR) for volatility measurement and FVG gap filtering.")

// ───────────── Smart Money Concepts (OB & FVG) ─────────────
grp_ob       = "3. Smart Money Concepts: Order Blocks (OB)"
showOB       = input.bool(true, "Show Order Blocks", group = grp_ob, tooltip = "Toggles the detection and display of Bullish and Bearish Order Block zones on the chart.")
swingLen     = input.int(10, "Swing Length (Pivot)", minval = 2, maxval = 50, group = grp_ob, tooltip = "Number of bars to the left and right required to confirm a pivot high or low for detecting structural breaks.")
deletePrevOB = input.bool(true, "Delete Previous OB on New OB", group = grp_ob, tooltip = "When enabled, automatically deletes older Order Blocks whenever a new one forms, keeping only the most recent Order Block on your chart.")
maxOB        = input.int(1, "Max Active OBs Per Side", minval = 1, maxval = 20, group = grp_ob, tooltip = "Maximum number of active unmitigated Order Blocks kept in memory and displayed per side.")
obBullCol    = input.color(color.new(#2962ff, 0), "Bullish OB Color", group = grp_ob, tooltip = "Border and background fill color for Bullish Order Block boxes.")
obBearCol    = input.color(color.new(#e040fb, 0), "Bearish OB Color", group = grp_ob, tooltip = "Border and background fill color for Bearish Order Block boxes.")

grp_fvg    = "4. Smart Money Concepts: Fair Value Gap (FVG)"
showFVG    = input.bool(true, "Show Fair Value Gaps", group = grp_fvg, tooltip = "Toggles the detection and visual rendering of 3-candle Fair Value Gap imbalance boxes.")
fvgMinAtr  = input.float(0.25, "Min FVG Size (× ATR)", minval = 0.0, step = 0.05, group = grp_fvg, tooltip = "Minimum gap size threshold expressed as an ATR multiplier. Filters out minor, insignificant imbalances.")
maxFVG     = input.int(5, "Max Active FVGs Per Side", minval = 1, maxval = 20, group = grp_fvg, tooltip = "Maximum number of active, unmitigated Fair Value Gap boxes displayed per side.")
fvgMitType = input.string("Close Through", "FVG Mitigation By", options = ["Close Through", "Close Inside", "Wick Touch"], group = grp_fvg, tooltip = "Rule for determining FVG mitigation: candle close piercing through the gap, closing inside the gap, or wick touch.")
fvgBullCol = input.color(color.new(#00bcd4, 0), "Bullish FVG Color", group = grp_fvg, tooltip = "Color scheme for Bullish Fair Value Gap boxes.")
fvgBearCol = input.color(color.new(#ff9800, 0), "Bearish FVG Color", group = grp_fvg, tooltip = "Color scheme for Bearish Fair Value Gap boxes.")
removeMit  = input.bool(true, "Remove Mitigated OB / FVG Boxes", group = grp_fvg, tooltip = "When enabled, completely deletes mitigated OB and FVG boxes. When disabled, locks boxes at the mitigation bar.")

// ───────────── Display & Visuals ─────────────
grp_vis    = "5. Display & Visuals"
showLevels = input.bool(true, "Show Entry / SL / TP Zones", group = grp_vis, tooltip = "Toggles the display of entry, stop loss, and take profit projection boxes, lines, and price labels.")
keepLevels = input.bool(false, "Keep Past Trade Zones (Don't clear on new trade)", group = grp_vis, tooltip = "When enabled, retains previous trade level zones on the chart instead of clearing them when a new trade triggers.")
showHits   = input.bool(true, "Mark TP / SL Hit Points", group = grp_vis, tooltip = "Displays colored dot markers on bars where Take Profit or Stop Loss levels are reached.")
keepSigs   = input.bool(true, "Keep Historical Buy/Sell & Hit Markers", group = grp_vis, tooltip = "When enabled, preserves historical Buy/Sell signal labels and hit markers across past candles.")
extBars    = input.int(10, "Extend Zone Beyond Bar", minval = 1, maxval = 50, group = grp_vis, tooltip = "Number of bars to project active trade levels, Order Blocks, and Fair Value Gaps forward into the future.")
zoneTransp = input.int(80, "Zone Transparency", minval = 0, maxval = 100, group = grp_vis, tooltip = "Base transparency percentage for trade projection zone boxes (0 = opaque, 100 = invisible).")
fadeBars   = input.int(15, "Gradient Fade Length (Bars)", minval = 0, maxval = 50, group = grp_vis, tooltip = "Number of bars over which the right edge of trade zones smoothly fades to create an aesthetic gradient.")
colorBars  = input.bool(true, "Color Candles by Trend", group = grp_vis, tooltip = "Colors price bars according to trend status: green for bullish, red for bearish, and gray for neutral.")
showEma    = input.bool(true, "Show EMA Line", group = grp_vis, tooltip = "Toggles the visibility of the Exponential Moving Average line on the chart.")
showTfWarn = input.bool(false, "Show 15m Timeframe Suggestion Table", group = grp_vis, tooltip = "Displays an on-screen warning banner when the indicator is applied on a timeframe other than 15 minutes.")

// ───────────── Colors ─────────────
grp_col    = "6. Colors"
slCol      = input.color(#f44336, "Stop Loss Color", group = grp_col, tooltip = "Color for Stop Loss levels, risk zones, and bearish markers.")
tpCol      = input.color(#00e676, "Take Profit Color", group = grp_col, tooltip = "Color for Take Profit levels, reward zones, and bullish markers.")
entryCol   = input.color(#9e9e9e, "Entry Level Color", group = grp_col, tooltip = "Color for the trade entry line and label.")
emaCol     = input.color(#2962ff, "EMA Color", group = grp_col, tooltip = "Color of the Exponential Moving Average line plotted on the chart.")

// ==============================================================================
// 2. CORE CALCULATIONS
// ==============================================================================

emaVal = ta.ema(close, emaLen)
rsiVal = ta.rsi(close, rsiLen)
atrVal = ta.atr(atrLen)

// Prior swing reference for Stop Loss calculation (previous 4 bars before signal)
prevLowestLow   = ta.lowest(low, slLookback)[1]
prevHighestHigh = ta.highest(high, slLookback)[1]

// Baseline Trend Conditions
bullCond = close > emaVal and rsiVal > rsiLevel
bearCond = close < emaVal and rsiVal < rsiLevel

// ==============================================================================
// 3. TRADE STATE & STORAGE
// ==============================================================================

var int   dir      = 0       // Current Trade State: 1 = Long, -1 = Short, 0 = Flat
var int   entryBar = na
var float entry    = na
var float sl       = na
var float tp1      = na
var float tp2      = na
var float tp3      = na
var bool  hit1     = false
var bool  hit2     = false
var bool  hit3     = false

// Drawing objects arrays
var array<box>   zoneBoxes  = array.new<box>()
var array<line>  lvlLines   = array.new<line>()
var array<label> lvlLabels  = array.new<label>()
var array<label> markLabels = array.new<label>()

// SMC zone storage
var array<box> bullOBs  = array.new<box>()
var array<box> bearOBs  = array.new<box>()
var array<box> bullFVGs = array.new<box>()
var array<box> bearFVGs = array.new<box>()

FADE_SEGS = 6

// ==============================================================================
// 4. DRAWING & RENDERING HELPERS
// ==============================================================================

clearTrade() =>
    for b in zoneBoxes
        box.delete(b)
    for l in lvlLines
        line.delete(l)
    for lb in lvlLabels
        label.delete(lb)
    array.clear(zoneBoxes)
    array.clear(lvlLines)
    array.clear(lvlLabels)

clearMarks() =>
    for lb in markLabels
        label.delete(lb)
    array.clear(markLabels)

clearZones(array<box> arr) =>
    for b in arr
        box.delete(b)
    array.clear(arr)

drawZone(int x1, int x2, float top, float bot, color col) =>
    fadeStart = math.max(x1, x2 - fadeBars)
    if fadeStart > x1
        array.push(zoneBoxes, box.new(x1, top, fadeStart, bot, border_color = color(na), border_width = 0, bgcolor = color.new(col, zoneTransp)))
    span = x2 - fadeStart
    for i = 0 to FADE_SEGS - 1
        a = fadeStart + math.round(span * i * 1.0 / FADE_SEGS)
        b = fadeStart + math.round(span * (i + 1) * 1.0 / FADE_SEGS)
        if b > a
            t = zoneTransp + (100.0 - zoneTransp) * (i + 1) / (FADE_SEGS + 1)
            array.push(zoneBoxes, box.new(a, top, b, bot, border_color = color(na), border_width = 0, bgcolor = color.new(col, t)))

drawLevel(int x1, int x2, float price, color col, string txt) =>
    array.push(lvlLines, line.new(x1, price, x2, price, color = col, width = 1))
    array.push(lvlLabels, label.new(x2, price, txt + ": " + str.tostring(price, format.mintick), style = label.style_label_left, color = col, textcolor = color.white, size = size.small))

drawTrade(int xEnd) =>
    if not keepLevels
        clearTrade()
    drawZone(entryBar, xEnd, math.max(entry, sl),  math.min(entry, sl),  slCol)
    drawZone(entryBar, xEnd, math.max(entry, tp3), math.min(entry, tp3), tpCol)
    drawLevel(entryBar, xEnd, sl,    slCol,    "Stop Loss")
    drawLevel(entryBar, xEnd, entry, entryCol, "Entry")
    drawLevel(entryBar, xEnd, tp1,   tpCol,    "Take Profit 1")
    drawLevel(entryBar, xEnd, tp2,   tpCol,    "Take Profit 2")
    drawLevel(entryBar, xEnd, tp3,   tpCol,    "Take Profit 3")

addDot(bool above, color col, string tag) =>
    array.push(markLabels, label.new(bar_index, above ? high : low, tag, yloc = above ? yloc.abovebar : yloc.belowbar, style = label.style_circle, color = col, textcolor = color.white, size = size.tiny))

newZone(int x1, float top, float bot, color col, string txt) =>
    box.new(x1, top, bar_index + extBars, bot, border_color = color.new(col, 40), border_width = 1, bgcolor = color.new(col, 82), text = txt, text_color = col, text_size = size.tiny, text_halign = text.align_left)

pushZone(array<box> arr, box b, int maxN) =>
    array.push(arr, b)
    if array.size(arr) > maxN
        box.delete(array.shift(arr))

updateZones(array<box> arr, bool isBull, float checkPrice, bool checkInside) =>
    n = array.size(arr)
    if n > 0
        for i = n - 1 to 0
            b = array.get(arr, i)
            top = box.get_top(b)
            bot = box.get_bottom(b)
            broken = false
            if checkInside
                broken := isBull ? (checkPrice < top) : (checkPrice > bot)
            else
                broken := isBull ? (checkPrice < bot) : (checkPrice > top)
            
            if broken
                array.remove(arr, i)
                if removeMit
                    box.delete(b)
                else
                    box.set_right(b, bar_index)
            else
                box.set_right(b, bar_index + extBars)

// ==============================================================================
// 5. SMART MONEY CONCEPTS (SMC): ORDER BLOCKS & FAIR VALUE GAPS
// ==============================================================================

// --- Pivot Calculation ---
ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low, swingLen, swingLen)

var float swHigh     = na
var int   swHighBar  = na
var bool  swHighUsed = true
var float swLow      = na
var int   swLowBar   = na
var bool  swLowUsed  = true

if not na(ph)
    swHigh     := ph
    swHighBar  := bar_index - swingLen
    swHighUsed := false
if not na(pl)
    swLow     := pl
    swLowBar  := bar_index - swingLen
    swLowUsed := false

// --- Order Blocks Tracking & Mitigation ---
// Mitigated when candle close pierces through the opposite side of the block
updateZones(bullOBs, true,  close, false)
updateZones(bearOBs, false, close, false)

// Bullish OB: Close breaks above swing high -> find lowest candle since that swing
if showOB and not swHighUsed and close > swHigh and barstate.isconfirmed
    swHighUsed := true
    span = math.min(bar_index - swHighBar, 200)
    float obTop = high[1]
    float obBot = low[1]
    int   obIdx = 1
    for i = 1 to span
        if low[i] < obBot
            obBot := low[i]
            obTop := high[i]
            obIdx := i
    if deletePrevOB
        clearZones(bullOBs)
    pushZone(bullOBs, newZone(bar_index - obIdx, obTop, obBot, obBullCol, "Bull OB"), maxOB)

// Bearish OB: Close breaks below swing low -> find highest candle since that swing
if showOB and not swLowUsed and close < swLow and barstate.isconfirmed
    swLowUsed := true
    span = math.min(bar_index - swLowBar, 200)
    float obTop = high[1]
    float obBot = low[1]
    int   obIdx = 1
    for i = 1 to span
        if high[i] > obTop
            obTop := high[i]
            obBot := low[i]
            obIdx := i
    if deletePrevOB
        clearZones(bearOBs)
    pushZone(bearOBs, newZone(bar_index - obIdx, obTop, obBot, obBearCol, "Bear OB"), maxOB)

// --- Fair Value Gaps (FVG) Tracking & Mitigation ---
float fvgBullPrice = fvgMitType == "Close Through" ? close : fvgMitType == "Wick Touch" ? low : close
float fvgBearPrice = fvgMitType == "Close Through" ? close : fvgMitType == "Wick Touch" ? high : close
bool  fvgInside    = fvgMitType == "Close Inside"

updateZones(bullFVGs, true,  fvgBullPrice, fvgInside)
updateZones(bearFVGs, false, fvgBearPrice, fvgInside)

minGap = atrVal * fvgMinAtr

// Bullish FVG: Current candle low is strictly above high of 2 candles ago
if showFVG and barstate.isconfirmed and low > high[2] and (low - high[2]) >= minGap
    pushZone(bullFVGs, newZone(bar_index - 2, low, high[2], fvgBullCol, "FVG"), maxFVG)

// Bearish FVG: Current candle high is strictly below low of 2 candles ago
if showFVG and barstate.isconfirmed and high < low[2] and (low[2] - high) >= minGap
    pushZone(bearFVGs, newZone(bar_index - 2, low[2], high, fvgBearCol, "FVG"), maxFVG)

// ==============================================================================
// 6. TRADE SIGNALS & EXECUTION LOGIC
// ==============================================================================

// Rising Edge Signals (First crossover bar confirmed)
buySignalRaw  = bullCond and not bullCond[1] and barstate.isconfirmed
sellSignalRaw = bearCond and not bearCond[1] and barstate.isconfirmed

// One-at-a-time filter: Prevents duplicate signals in the same direction while trade is active
buySignal  = buySignalRaw  and (not oneAtATime or dir != 1)
sellSignal = sellSignalRaw and (not oneAtATime or dir != -1)

// ==============================================================================
// 7. TP / SL HIT DETECTION & TRACKING
// ==============================================================================

tp1Hit = false
tp2Hit = false
tp3Hit = false
slHit  = false

if dir != 0 and bar_index > entryBar
    isLong = dir == 1
    // Check Stop Loss first (conservative evaluation)
    if (isLong ? low <= sl : high >= sl)
        slHit := true
    else
        // Check Take Profit levels sequentially
        if not hit1 and (isLong ? high >= tp1 : low <= tp1)
            hit1   := true
            tp1Hit := true
        if not hit2 and (isLong ? high >= tp2 : low <= tp2)
            hit2   := true
            tp2Hit := true
        if not hit3 and (isLong ? high >= tp3 : low <= tp3)
            hit3   := true
            tp3Hit := true

    // Visual mark points on hit candles
    if showHits
        if tp1Hit
            addDot(isLong, tpCol, "")
        if tp2Hit
            addDot(isLong, tpCol, "")
        if tp3Hit
            addDot(isLong, tpCol, "")
        if slHit
            addDot(not isLong, slCol, "")

    // Real-time alert triggers
    if tp1Hit
        alert("TP1 Reached for " + syminfo.ticker + " @ " + str.tostring(tp1, format.mintick), alert.freq_once_per_bar)
    if tp2Hit
        alert("TP2 Reached for " + syminfo.ticker + " @ " + str.tostring(tp2, format.mintick), alert.freq_once_per_bar)
    if tp3Hit
        alert("TP3 Reached for " + syminfo.ticker + " @ " + str.tostring(tp3, format.mintick), alert.freq_once_per_bar)
    if slHit
        alert("Stop Loss Hit for " + syminfo.ticker + " @ " + str.tostring(sl, format.mintick), alert.freq_once_per_bar)

    // Position conclusion: Close trade and freeze drawing upon SL or TP3 hit
    if slHit or hit3
        dir := 0
        if showLevels
            drawTrade(bar_index)

// ==============================================================================
// 8. NEW SIGNAL INITIALIZATION
// ==============================================================================

if buySignal or sellSignal
    if not keepLevels
        clearTrade()
    if not keepSigs
        clearMarks()

    dir      := buySignal ? 1 : -1
    entryBar := bar_index
    entry    := close
    sl       := buySignal ? (prevLowestLow - slBuffer) : (prevHighestHigh + slBuffer)
    tp1      := entry + (dir * tpStep)
    tp2      := entry + (dir * tpStep * 2)
    tp3      := entry + (dir * tpStep * 3)
    hit1     := false
    hit2     := false
    hit3     := false

    // Signal Label on chart
    if buySignal
        array.push(markLabels, label.new(bar_index, low, "BUY", yloc = yloc.belowbar, style = label.style_label_up, color = color.new(tpCol, 10), textcolor = color.white, size = size.small))
    else
        array.push(markLabels, label.new(bar_index, high, "SELL", yloc = yloc.abovebar, style = label.style_label_down, color = color.new(slCol, 10), textcolor = color.white, size = size.small))

    // Draw trade projection levels
    if showLevels
        drawTrade(bar_index + extBars)

    // Trigger Entry Alert
    alert((buySignal ? "BUY " : "SELL ") + syminfo.ticker + " @ " + str.tostring(entry, format.mintick) + " | SL: " + str.tostring(sl, format.mintick) + " | TP1: " + str.tostring(tp1, format.mintick) + " | TP2: " + str.tostring(tp2, format.mintick) + " | TP3: " + str.tostring(tp3, format.mintick), alert.freq_once_per_bar_close)

// Extend ongoing active trade levels on the current real-time bar
if barstate.islast and dir != 0 and showLevels
    drawTrade(bar_index + extBars)

// ==============================================================================
// 9. PLOTS & BAR COLORING
// ==============================================================================

plot(showEma ? emaVal : na, "EMA 9", color = emaCol, linewidth = 2)
barcolor(colorBars ? (bullCond ? tpCol : bearCond ? slCol : color.gray) : na)

// ==============================================================================
// 10. ALERTS (alertcondition)
// ==============================================================================

alertcondition(buySignal,  "Buy Signal",  "BUY Signal on {{ticker}} @ {{close}} | EMA + RSI Bullish Cross")
alertcondition(sellSignal, "Sell Signal", "SELL Signal on {{ticker}} @ {{close}} | EMA + RSI Bearish Cross")
alertcondition(tp1Hit,     "TP1 Hit",     "Take Profit 1 Hit on {{ticker}}")
alertcondition(tp2Hit,     "TP2 Hit",     "Take Profit 2 Hit on {{ticker}}")
alertcondition(tp3Hit,     "TP3 Hit",     "Take Profit 3 Hit on {{ticker}}")
alertcondition(tp1Hit or tp2Hit or tp3Hit, "Any TP Hit", "Take Profit (TP1/TP2/TP3) Hit on {{ticker}}")
alertcondition(slHit,      "SL Hit",      "Stop Loss Hit on {{ticker}}")

// ==============================================================================
// 11. TIMEFRAME RECOMMENDATION TABLE (OPTIONAL)
// ==============================================================================

var table tfWarn = table.new(position.top_right, 1, 1)
if showTfWarn and barstate.islast and timeframe.period != "15"
    table.cell(tfWarn, 0, 0, "Optimized for 15m (Current: " + timeframe.period + ")", bgcolor = color.new(color.orange, 20), text_color = color.white, text_size = size.small)
````
