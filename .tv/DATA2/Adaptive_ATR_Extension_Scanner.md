<!-- tradingview-pine-id: PUB;189f2fed6f6049c588e695049fb7464b -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# Adaptive ATR% Extension Scanner

Source: https://www.tradingview.com/script/Bi4wbP4B-Adaptive-ATR-Extension-Scanner/

## Description

Identifying when a stock is historically overextended and due for a mean-reverting pullback is a critical component of risk management and scaling out of swing trades. The Adaptive ATR% Extension Scanner provides an objective, mathematical way to measure these extensions based entirely on a stock's unique historical volatility profile.

Rather than relying on static guesses for when a stock is "too far" from its moving average, this tool actively reads the chart's history to tell you exactly when current price action has reached an statistical extreme.

Key Features:

 Dynamic Percentile Lookback: The indicator automatically scans the last 20 swing highs (pullbacks) for the specific ticker you are viewing. It calculates the exact ATR% multiple at each peak to establish a unique historical baseline for what constitutes an "extended" move.

 Dual-Tier Signals: The script calculates the 75th percentile (Warning) and 90th percentile (Extreme) of past pullbacks. It plots highly customizable signals directly on your chart when the current price breaches these historically significant thresholds.

 Multi-MA Variance Scanner: Not every stock respects the same baseline. The built-in dashboard tracks the 10 EMA, 20 EMA, 50 SMA, and 200 SMA simultaneously. It calculates the historical variance for each to determine which moving average produces the most tightly clustered, predictable extensions.

 Auto-Best Fit: The script can automatically select the moving average with the lowest historical variance to drive your chart visuals and trigger your signals, completely removing the guesswork.

 Customizable Price Bands: Toggle upper price bands on or off to project exactly what dollar amount the stock needs to hit to reach an overextended state, allowing you to easily set advance limit orders.

How to Use:

Leave the MA setting on "Auto (Best Fit)" to let the script find the most predictable baseline for the current ticker. Watch for the warning dots (yellow by default) as a signal to scale out partial positions, and extreme dots (red by default) as a signal to tighten trailing stops aggressively. Full customization options allow you to change dot colors, emojis/characters, opacity, and dashboard visuals to fit your exact charting style.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © chardogg74

//@version=6
indicator("Adaptive ATR% Extension Scanner", overlay=true, max_labels_count=50)

// --- Inputs ---
grp_main = "Core Settings"
activeMA = input.string("Auto (Best Fit)", title="MA for Chart Signals", options=["10 EMA", "20 EMA", "50 SMA", "200 SMA", "Auto (Best Fit)"], group=grp_main)
trackDir = input.string("Both", title="Track Direction", options=["Upper", "Lower", "Both"], group=grp_main)
showBands = input.bool(true, title="Show Dynamic Bands", group=grp_main)

grp_up = "Upside Dots Customization"
showWarnDotUp = input.bool(true, title="Show Up Warning", inline="u1", group=grp_up)
warnCharUp = input.string("•", title="Char", inline="u1", group=grp_up)
warnColorUp = input.color(color.new(#d98254, 50), title="Color", inline="u1", group=grp_up) // Peach/Orange

showExtDotUp = input.bool(true, title="Show Up Extreme", inline="u2", group=grp_up)
extCharUp = input.string("•", title="Char", inline="u2", group=grp_up)
extColorUp = input.color(color.new(#995960, 50), title="Color", inline="u2", group=grp_up) // Maroon

dotSize = input.string("tiny", title="Dot Size", options=["auto", "tiny", "small", "normal", "large", "huge"], group=grp_up)

grp_dn = "Downside Dots Customization"
showWarnDotDn = input.bool(true, title="Show Dn Warning", inline="d1", group=grp_dn)
warnCharDn = input.string("•", title="Char", inline="d1", group=grp_dn)
warnColorDn = input.color(color.new(#88a383, 50), title="Color", inline="d1", group=grp_dn) // Light Olive

showExtDotDn = input.bool(true, title="Show Dn Extreme", inline="d2", group=grp_dn)
extCharDn = input.string("•", title="Char", inline="d2", group=grp_dn)
extColorDn = input.color(color.new(#5e7568, 50), title="Color", inline="d2", group=grp_dn) // Dark Green

grp_bands = "Bands Customization"
bandWarnUpCol = input.color(color.new(#d98254, 50), title="Up Warn Band", inline="b1", group=grp_bands)
bandExtUpCol  = input.color(color.new(#995960, 30), title="Up Ext Band", inline="b1", group=grp_bands)
fillUpCol     = input.color(color.new(#995960, 90), title="Up Fill Background", inline="b1", group=grp_bands)

bandWarnDnCol = input.color(color.new(#88a383, 50), title="Dn Warn Band", inline="b2", group=grp_bands)
bandExtDnCol  = input.color(color.new(#5e7568, 30), title="Dn Ext Band", inline="b2", group=grp_bands)
fillDnCol     = input.color(color.new(#5e7568, 90), title="Dn Fill Background", inline="b2", group=grp_bands)

grp_dash = "Dashboard Settings"
showTable = input.bool(true, title="Show Dashboard", group=grp_dash)
showVar = input.bool(true, title="Show Variance Scanner", group=grp_dash)
tbBgColor = input.color(color.new(color.white, 100), title="Background Color", group=grp_dash) // 100 opacity = fully transparent
tbTxtColor = input.color(color.new(color.black, 0), title="Base Text Color", group=grp_dash)
tbSize = input.string("small", title="Text Size", options=["auto", "tiny", "small", "normal", "large", "huge"], group=grp_dash)

grp_dyn = "Dynamic Lookback Settings"
lookback = input.int(20, title="Past Pullbacks to Analyze", group=grp_dyn)
warnPctile = input.int(75, title="Warning Percentile", group=grp_dyn)
extPctile = input.int(90, title="Extreme Percentile", group=grp_dyn)
pivotLeft = input.int(10, title="Swing High/Low Left Bars", group=grp_dyn)
pivotRight = input.int(5, title="Swing High/Low Right Bars", group=grp_dyn)

// --- Custom Functions (Global Scope) ---
f_get_percentile(float[] arr, int pct) =>
    int sz = array.size(arr)
    if sz == 0
        na
    else
        float[] arr_copy = array.copy(arr)
        array.sort(arr_copy)
        int idx = math.round((sz - 1) * (pct / 100.0))
        array.get(arr_copy, idx)

f_variance(float[] arr) =>
    int sz = array.size(arr)
    if sz < 2
        na
    else
        float mean = array.avg(arr)
        float sumSq = 0.0
        for val in arr
            sumSq += math.pow(val - mean, 2)
        sumSq / (sz - 1)

calcBandPriceUp(float m, float ma, float atr) =>
    if na(m) or m <= 0
        na
    else
        (ma + math.sqrt(math.pow(ma, 2) + (4 * m * ma * atr))) / 2

calcBandPriceDn(float m, float ma, float atr) =>
    if na(m) or m <= 0
        na
    else
        float inner = math.pow(ma, 2) - (4 * m * ma * atr)
        inner >= 0 ? (ma + math.sqrt(inner)) / 2 : na 

f_draw_row(table tb, int r, string label, float curMult, float[] arr, float vScore, bool isBest, int wPct, int ePct, color wCol, color eCol, bool sVar, color tCol, string tSize, string contextStr) =>
    color cColor = isBest ? color.new(color.green, 0) : tCol
    float wMult = f_get_percentile(arr, wPct)
    float eMult = f_get_percentile(arr, ePct)
    
    table.cell(tb, 0, r, label + (isBest ? " (BEST)" : ""), text_color=cColor, text_size=tSize)
    table.cell(tb, 1, r, str.tostring(curMult, "#.##")+"x", text_color=tCol, text_size=tSize)
    table.cell(tb, 2, r, str.tostring(wMult, "#.##")+"x", text_color=wCol, text_size=tSize)
    table.cell(tb, 3, r, str.tostring(eMult, "#.##")+"x", text_color=eCol, text_size=tSize)
    if sVar
        table.cell(tb, 4, r, str.tostring(vScore, "#.##"), text_color=tCol, text_size=tSize)

// --- Core Calculations ---
float ma10 = ta.ema(close, 10)
float ma20 = ta.ema(close, 20)
float ma50 = ta.sma(close, 50)
float ma200 = ta.sma(close, 200)
float atrVal = ta.atr(14)
float atrPct = atrVal / close

// Calculate Multiples (Up and Down separately)
float m10_up = close > ma10 ? ((close - ma10) / ma10) / atrPct : 0
float m10_dn = close < ma10 ? ((ma10 - close) / ma10) / atrPct : 0

float m20_up = close > ma20 ? ((close - ma20) / ma20) / atrPct : 0
float m20_dn = close < ma20 ? ((ma20 - close) / ma20) / atrPct : 0

float m50_up = close > ma50 ? ((close - ma50) / ma50) / atrPct : 0
float m50_dn = close < ma50 ? ((ma50 - close) / ma50) / atrPct : 0

float m200_up = close > ma200 ? ((close - ma200) / ma200) / atrPct : 0
float m200_dn = close < ma200 ? ((ma200 - close) / ma200) / atrPct : 0

// --- Historical Tracking Arrays ---
var float[] arr10_up = array.new_float(0)
var float[] arr10_dn = array.new_float(0)
var float[] arr20_up = array.new_float(0)
var float[] arr20_dn = array.new_float(0)
var float[] arr50_up = array.new_float(0)
var float[] arr50_dn = array.new_float(0)
var float[] arr200_up = array.new_float(0)
var float[] arr200_dn = array.new_float(0)

float ph = ta.pivothigh(high, pivotLeft, pivotRight)
float pl = ta.pivotlow(low, pivotLeft, pivotRight)

// Track Upside
if not na(ph)
    float aP = atrVal[pivotRight] / close[pivotRight]
    float m10 = ((close[pivotRight] - ma10[pivotRight]) / ma10[pivotRight]) / aP
    float m20 = ((close[pivotRight] - ma20[pivotRight]) / ma20[pivotRight]) / aP
    float m50 = ((close[pivotRight] - ma50[pivotRight]) / ma50[pivotRight]) / aP
    float m200 = ((close[pivotRight] - ma200[pivotRight]) / ma200[pivotRight]) / aP
    
    if m10 > 0 
        array.unshift(arr10_up, m10)
        if array.size(arr10_up) > lookback
            array.pop(arr10_up)
    if m20 > 0 
        array.unshift(arr20_up, m20)
        if array.size(arr20_up) > lookback
            array.pop(arr20_up)
    if m50 > 0 
        array.unshift(arr50_up, m50)
        if array.size(arr50_up) > lookback
            array.pop(arr50_up)
    if m200 > 0 
        array.unshift(arr200_up, m200)
        if array.size(arr200_up) > lookback
            array.pop(arr200_up)

// Track Downside
if not na(pl)
    float aP = atrVal[pivotRight] / close[pivotRight]
    float m10 = ((ma10[pivotRight] - close[pivotRight]) / ma10[pivotRight]) / aP
    float m20 = ((ma20[pivotRight] - close[pivotRight]) / ma20[pivotRight]) / aP
    float m50 = ((ma50[pivotRight] - close[pivotRight]) / ma50[pivotRight]) / aP
    float m200 = ((ma200[pivotRight] - close[pivotRight]) / ma200[pivotRight]) / aP
    
    if m10 > 0 
        array.unshift(arr10_dn, m10)
        if array.size(arr10_dn) > lookback
            array.pop(arr10_dn)
    if m20 > 0 
        array.unshift(arr20_dn, m20)
        if array.size(arr20_dn) > lookback
            array.pop(arr20_dn)
    if m50 > 0 
        array.unshift(arr50_dn, m50)
        if array.size(arr50_dn) > lookback
            array.pop(arr50_dn)
    if m200 > 0 
        array.unshift(arr200_dn, m200)
        if array.size(arr200_dn) > lookback
            array.pop(arr200_dn)

// --- Stats Calculation ---
bool isUpContext = close >= ma50

float var10 = isUpContext ? f_variance(arr10_up) : f_variance(arr10_dn)
float var20 = isUpContext ? f_variance(arr20_up) : f_variance(arr20_dn)
float var50 = isUpContext ? f_variance(arr50_up) : f_variance(arr50_dn)
float var200 = isUpContext ? f_variance(arr200_up) : f_variance(arr200_dn)

float minVar = math.min(nz(var10, 9999), nz(var20, 9999), nz(var50, 9999), nz(var200, 9999))
string bestFitStr = minVar == var10 ? "10 EMA" : minVar == var20 ? "20 EMA" : minVar == var50 ? "50 SMA" : minVar == var200 ? "200 SMA" : "N/A"

// --- Chart Visuals Logic ---
string selectedMA = activeMA == "Auto (Best Fit)" ? bestFitStr : activeMA

float chartMA = selectedMA == "10 EMA" ? ma10 : selectedMA == "20 EMA" ? ma20 : selectedMA == "50 SMA" ? ma50 : ma200
bool chartUpContext = close >= chartMA

float chartMultUp = selectedMA == "10 EMA" ? m10_up : selectedMA == "20 EMA" ? m20_up : selectedMA == "50 SMA" ? m50_up : m200_up
float chartMultDn = selectedMA == "10 EMA" ? m10_dn : selectedMA == "20 EMA" ? m20_dn : selectedMA == "50 SMA" ? m50_dn : m200_dn

float[] chartArrUp = selectedMA == "10 EMA" ? arr10_up : selectedMA == "20 EMA" ? arr20_up : selectedMA == "50 SMA" ? arr50_up : arr200_up
float[] chartArrDn = selectedMA == "10 EMA" ? arr10_dn : selectedMA == "20 EMA" ? arr20_dn : selectedMA == "50 SMA" ? arr50_dn : arr200_dn

float chartWarnMultUp = array.size(chartArrUp) >= 5 ? f_get_percentile(chartArrUp, warnPctile) : na
float chartExtMultUp = array.size(chartArrUp) >= 5 ? f_get_percentile(chartArrUp, extPctile) : na
float chartWarnMultDn = array.size(chartArrDn) >= 5 ? f_get_percentile(chartArrDn, warnPctile) : na
float chartExtMultDn = array.size(chartArrDn) >= 5 ? f_get_percentile(chartArrDn, extPctile) : na

// Plot Bands
float bandWarnUp = calcBandPriceUp(chartWarnMultUp, chartMA, atrVal)
float bandExtUp = calcBandPriceUp(chartExtMultUp, chartMA, atrVal)
float bandWarnDn = calcBandPriceDn(chartWarnMultDn, chartMA, atrVal)
float bandExtDn = calcBandPriceDn(chartExtMultDn, chartMA, atrVal)

plot(chartMA, color=color.new(color.blue, 0), title="Selected Baseline", linewidth=2)

bool doUp = trackDir == "Upper" or trackDir == "Both"
bool doDn = trackDir == "Lower" or trackDir == "Both"

p1_up = plot(showBands and doUp ? bandWarnUp : na, color=bandWarnUpCol, title="Up Warn Band", style=plot.style_linebr)
p2_up = plot(showBands and doUp ? bandExtUp : na, color=bandExtUpCol, title="Up Ext Band", style=plot.style_linebr)
fill(p1_up, p2_up, color=showBands and doUp ? fillUpCol : na, title="Up Fill Background")

p1_dn = plot(showBands and doDn ? bandWarnDn : na, color=bandWarnDnCol, title="Dn Warn Band", style=plot.style_linebr)
p2_dn = plot(showBands and doDn ? bandExtDn : na, color=bandExtDnCol, title="Dn Ext Band", style=plot.style_linebr)
fill(p1_dn, p2_dn, color=showBands and doDn ? fillDnCol : na, title="Dn Fill Background")

// --- Plot Dots (Workaround for const string) ---
bool isWarnUp = doUp and not na(chartWarnMultUp) and chartMultUp >= chartWarnMultUp and chartMultUp < chartExtMultUp
bool isExtUp = doUp and not na(chartExtMultUp) and chartMultUp >= chartExtMultUp

bool isWarnDn = doDn and not na(chartWarnMultDn) and chartMultDn >= chartWarnMultDn and chartMultDn < chartExtMultDn
bool isExtDn = doDn and not na(chartExtMultDn) and chartMultDn >= chartExtMultDn

plotchar(showWarnDotUp and isWarnUp and dotSize == "auto", title="Up Warn", char=warnCharUp, location=location.abovebar, color=warnColorUp, size=size.auto)
plotchar(showWarnDotUp and isWarnUp and dotSize == "tiny", title="Up Warn", char=warnCharUp, location=location.abovebar, color=warnColorUp, size=size.tiny)
plotchar(showWarnDotUp and isWarnUp and dotSize == "small", title="Up Warn", char=warnCharUp, location=location.abovebar, color=warnColorUp, size=size.small)

plotchar(showExtDotUp and isExtUp and dotSize == "auto", title="Up Ext", char=extCharUp, location=location.abovebar, color=extColorUp, size=size.auto)
plotchar(showExtDotUp and isExtUp and dotSize == "tiny", title="Up Ext", char=extCharUp, location=location.abovebar, color=extColorUp, size=size.tiny)
plotchar(showExtDotUp and isExtUp and dotSize == "small", title="Up Ext", char=extCharUp, location=location.abovebar, color=extColorUp, size=size.small)

plotchar(showWarnDotDn and isWarnDn and dotSize == "auto", title="Dn Warn", char=warnCharDn, location=location.belowbar, color=warnColorDn, size=size.auto)
plotchar(showWarnDotDn and isWarnDn and dotSize == "tiny", title="Dn Warn", char=warnCharDn, location=location.belowbar, color=warnColorDn, size=size.tiny)
plotchar(showWarnDotDn and isWarnDn and dotSize == "small", title="Dn Warn", char=warnCharDn, location=location.belowbar, color=warnColorDn, size=size.small)

plotchar(showExtDotDn and isExtDn and dotSize == "auto", title="Dn Ext", char=extCharDn, location=location.belowbar, color=extColorDn, size=size.auto)
plotchar(showExtDotDn and isExtDn and dotSize == "tiny", title="Dn Ext", char=extCharDn, location=location.belowbar, color=extColorDn, size=size.tiny)
plotchar(showExtDotDn and isExtDn and dotSize == "small", title="Dn Ext", char=extCharDn, location=location.belowbar, color=extColorDn, size=size.small)

// --- Dashboard Drawing (Context Aware) ---
if showTable
    int cols = showVar ? 5 : 4
    var table tb = table.new(position.bottom_right, cols, 6, bgcolor=tbBgColor, border_width=1, border_color=color.gray)
    
    color ctxWarnCol = chartUpContext ? warnColorUp : warnColorDn
    color ctxExtCol = chartUpContext ? extColorUp : extColorDn
    string ctxTitle = chartUpContext ? "UPSIDE METRICS" : "DOWNSIDE METRICS"
    
    // Headers
    table.merge_cells(tb, 0, 0, cols - 1, 0)
    table.cell(tb, 0, 0, ctxTitle, text_color=color.gray, text_size=tbSize)
    
    table.cell(tb, 0, 1, "BASELINE", text_color=tbTxtColor, text_size=tbSize)
    table.cell(tb, 1, 1, "CURRENT", text_color=tbTxtColor, text_size=tbSize)
    table.cell(tb, 2, 1, "WARN", text_color=ctxWarnCol, text_size=tbSize)
    table.cell(tb, 3, 1, "EXTREME", text_color=ctxExtCol, text_size=tbSize)
    if showVar
        table.cell(tb, 4, 1, "VARIANCE", text_color=tbTxtColor, text_size=tbSize)

    // Select correct arrays based on context
    float m10 = chartUpContext ? m10_up : m10_dn
    float m20 = chartUpContext ? m20_up : m20_dn
    float m50 = chartUpContext ? m50_up : m50_dn
    float m200 = chartUpContext ? m200_up : m200_dn
    
    float[] a10 = chartUpContext ? arr10_up : arr10_dn
    float[] a20 = chartUpContext ? arr20_up : arr20_dn
    float[] a50 = chartUpContext ? arr50_up : arr50_dn
    float[] a200 = chartUpContext ? arr200_up : arr200_dn

    // Populate Rows
    f_draw_row(tb, 2, "10 EMA", m10, a10, var10, bestFitStr == "10 EMA", warnPctile, extPctile, ctxWarnCol, ctxExtCol, showVar, tbTxtColor, tbSize, ctxTitle)
    f_draw_row(tb, 3, "20 EMA", m20, a20, var20, bestFitStr == "20 EMA", warnPctile, extPctile, ctxWarnCol, ctxExtCol, showVar, tbTxtColor, tbSize, ctxTitle)
    f_draw_row(tb, 4, "50 SMA", m50, a50, var50, bestFitStr == "50 SMA", warnPctile, extPctile, ctxWarnCol, ctxExtCol, showVar, tbTxtColor, tbSize, ctxTitle)
    f_draw_row(tb, 5, "200 SMA", m200, a200, var200, bestFitStr == "200 SMA", warnPctile, extPctile, ctxWarnCol, ctxExtCol, showVar, tbTxtColor, tbSize, ctxTitle)
````
