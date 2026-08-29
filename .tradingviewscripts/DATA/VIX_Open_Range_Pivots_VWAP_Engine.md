<!-- tradingview-pine-id: PUB;61b8a8c5bb9844c88ccb5a55230cfa13 -->
<!-- tradingviewscripts-format: 1 -->
# VIX, Open Range, Pivots & VWAP Engine

Source: https://www.tradingview.com/script/QUkAe16L-VIX-Open-Range-Pivots-VWAP-Engine/

## Description

Vix based buy sell,

 has 5 min and 15 min Open range,

 range based pivot levels, 

rolling vwap, 

Vwap, 

adjustable ema with time frame selection

---

## Source Code

````pine
//@version=6
indicator("VIX, Open Range, Pivots & VWAP Engine", overlay=true, max_lines_count=500, max_labels_count=500)

// ==========================================
// --- Inputs Block ---
// ==========================================
// 1. Core VIX Engine Inputs
string vixTicker          = input.symbol("NSE:INDIAVIX", title="VIX Source Ticker", group="1. VIX & Price Matrix")
int priceLength           = input.int(10, title="Price Close Lookback Period", minval=1, group="1. VIX & Price Matrix")
float vixRevThreshold     = input.float(0.3, title="VIX Intraday Reversal Threshold (%)", step=0.1, group="1. VIX & Price Matrix")
float vix15Threshold      = input.float(0.5, title="15m VIX Override Threshold (%)", step=0.1, group="1. VIX & Price Matrix", tooltip="If VIX drops/spikes this % in 15m, instantly flags Bull/Bear")
float vix5NeutralThresh   = input.float(0.25, title="5m VIX Neutral Threshold (%)", step=0.05, group="1. VIX & Price Matrix")
float vix15NeutralThresh  = input.float(0.15, title="15m VIX Neutral Threshold (%)", step=0.05, group="1. VIX & Price Matrix")

// 2. Dual Multi-Timeframe EMA Inputs
int emaLen1       = input.int(20, title="EMA 1 Length", group="2. Dual Mtf EMAs")
string emaTf1     = input.timeframe("", title="EMA 1 Timeframe (Empty = Chart)", group="2. Dual Mtf EMAs")
int emaLen2       = input.int(50, title="EMA 2 Length", group="2. Dual Mtf EMAs")
string emaTf2     = input.timeframe("", title="EMA 2 Timeframe (Empty = Chart)", group="2. Dual Mtf EMAs")

// 3. VWAP & Rolling Configuration
string grpVwap    = "VWAP Settings"
int lenVwapR1     = input.int(14, "Rolling VWAP 1 Length", minval=1, group=grpVwap)
int lenVwapR2     = input.int(75, "Rolling VWAP 2 Length", minval=1, group=grpVwap)

// 4. Pivot History & Theme Configuration
string grpColor   = "Visual Theme Configuration"
color colorPivot  = input.color(color.blue, "Pivot Point Center", group=grpColor)
color colorMid    = input.color(color.gray, "Mid Pivot Levels (mR/mS)", group=grpColor)
color colorRes    = input.color(color.red, "Resistance Levels", group=grpColor)
color colorSup    = input.color(color.green, "Support Levels", group=grpColor)
color colorVwapD  = input.color(color.black, "Session VWAP", group=grpColor)
color colorVwapR1 = input.color(color.orange, "Rolling VWAP 1 (14)", group=grpColor)
color colorVwapR2 = input.color(color.navy, "Rolling VWAP 2 (75)", group=grpColor)

int maxPivotLevels = input.int(4, "Max Pivot Levels to Display (1-7)", minval=1, maxval=7, group="Pivot History Configuration")
int historyDays    = input.int(5, "Show Historical Days (1-7)", minval=1, maxval=7, group="Pivot History Configuration")

// --- NEW SETTING FOR DASHBOARD WIDTH ---
int max15mBlocks   = input.int(9, "Max 15m Blocks in Dashboard", minval=3, maxval=20, group="Labels Configuration", tooltip="Reduces the width of the dashboard so it doesn't overlap left-side indicators.")
bool showLabels    = input.bool(true, "Show Staggered Labels On/Off", group="Labels Configuration")

color colLong      = input.color(#1b9e77, title="Long Signal Color", group="Style Presets")
color colShort     = input.color(#d95f02, title="Short Signal Color", group="Style Presets")

// ==========================================
// --- Advanced Session Control ---
// ==========================================
bool isNewSession = ta.change(time("D")) != 0 or (time - time[1] > 7200000)
var int barsInSession = 0
var int sessionStartBarIndex = 0
var int sessionStartTime = 0

if isNewSession
    barsInSession := 1
    sessionStartBarIndex := bar_index
    sessionStartTime := time
else
    barsInSession += 1

int sessionEndTime = sessionStartTime + 23400000
int millisInDay = 86400000

// ==========================================
// --- Global Engine Helper Functions ---
// ==========================================
add_line_time(int startT, int endT, float lnVal, color col, string styleType, int lnWidth, line[] lineArr) =>
    lineStyle = styleType == "dashed" ? line.style_dashed : line.style_solid
    array.push(lineArr, line.new(x1=startT, y1=lnVal, x2=endT, y2=lnVal, xloc=xloc.bar_time, extend=extend.none, color=col, style=lineStyle, width=lnWidth))

add_lbl(int barIdx, float priceVal, string txt, color textCol, string lblStyle, label[] lblArr) =>
    array.push(lblArr, label.new(barIdx, priceVal, txt, color=color.new(color.white, 100), textcolor=textCol, style=lblStyle, size=size.small))

// ==========================================
// --- Opening Range (OR) Multi-Day Engine ---
// ==========================================
var float or5High = na
var float or5Low  = na
var float mtf15OrHigh = na
var float mtf15OrLow  = na

var line[] orLines = array.new<line>(0)
var label[] orLabels = array.new<label>(0)
var bool orLinesDrawn = false

bool in5mOR = time < sessionStartTime + 5 * 60000
bool in15mOR = time < sessionStartTime + 15 * 60000

if isNewSession
    or5High := high
    or5Low  := low
    mtf15OrHigh := high
    mtf15OrLow  := low
    orLinesDrawn := false

    if array.size(orLines) > 0
        for i = array.size(orLines) - 1 to 0
            ln = array.get(orLines, i)
            if (timenow - line.get_x1(ln)) > (historyDays * millisInDay)
                line.delete(ln)
                array.remove(orLines, i)
    if array.size(orLabels) > 0
        for i = array.size(orLabels) - 1 to 0
            lbl = array.get(orLabels, i)
            if (timenow - label.get_x(lbl)) > (historyDays * millisInDay)
                label.delete(lbl)
                array.remove(orLabels, i)
else
    if in5mOR
        or5High := math.max(or5High, high)
        or5Low  := math.min(or5Low, low)
    if in15mOR
        mtf15OrHigh := math.max(mtf15OrHigh, high)
        mtf15OrLow  := math.min(mtf15OrLow, low)

if not in15mOR and not orLinesDrawn
    orLinesDrawn := true
    array.push(orLines, line.new(x1=sessionStartTime, y1=or5High, x2=sessionEndTime, y2=or5High, xloc=xloc.bar_time, color=color.new(color.green, 40), width=2))
    array.push(orLines, line.new(x1=sessionStartTime, y1=or5Low, x2=sessionEndTime, y2=or5Low, xloc=xloc.bar_time, color=color.new(color.red, 40), width=2))
    array.push(orLines, line.new(x1=sessionStartTime, y1=mtf15OrHigh, x2=sessionEndTime, y2=mtf15OrHigh, xloc=xloc.bar_time, color=color.new(color.teal, 20), width=2))
    array.push(orLines, line.new(x1=sessionStartTime, y1=mtf15OrLow, x2=sessionEndTime, y2=mtf15OrLow, xloc=xloc.bar_time, color=color.new(color.maroon, 20), width=2))

    if showLabels
        int anchorBar = sessionStartBarIndex
        if or5High == mtf15OrHigh
            array.push(orLabels, label.new(anchorBar + 2, or5High, "OR-H (5m & 15m): " + str.tostring(or5High, "#.##"), color=color.new(color.white, 100), textcolor=color.green, style=label.style_label_upper_left, size=size.small))
        else
            array.push(orLabels, label.new(anchorBar + 2, or5High, "OR-H (5m): " + str.tostring(or5High, "#.##"), color=color.new(color.white, 100), textcolor=color.green, style=label.style_label_upper_left, size=size.small))
            array.push(orLabels, label.new(anchorBar + 4, mtf15OrHigh, "OR-H (15m): " + str.tostring(mtf15OrHigh, "#.##"), color=color.new(color.white, 100), textcolor=color.teal, style=label.style_label_upper_left, size=size.small))

        if or5Low == mtf15OrLow
            array.push(orLabels, label.new(anchorBar + 6, or5Low, "OR-L (5m & 15m): " + str.tostring(or5Low, "#.##"), color=color.new(color.white, 100), textcolor=color.red, style=label.style_label_upper_left, size=size.small))
        else
            array.push(orLabels, label.new(anchorBar + 6, or5Low, "OR-L (5m): " + str.tostring(or5Low, "#.##"), color=color.new(color.white, 100), textcolor=color.red, style=label.style_label_upper_left, size=size.small))
            array.push(orLabels, label.new(anchorBar + 8, mtf15OrLow, "OR-L (15m): " + str.tostring(mtf15OrLow, "#.##"), color=color.new(color.white, 100), textcolor=color.maroon, style=label.style_label_upper_left, size=size.small))

// ==========================================
// --- Core VIX Signal Matrix Logic ---
// ==========================================
float vixClose     = request.security(vixTicker, timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off)
float vixOpen      = request.security(vixTicker, timeframe.period, open,  barmerge.gaps_off, barmerge.lookahead_off)
float vixPrevClose = request.security(vixTicker, "D", close[1], barmerge.gaps_off, barmerge.lookahead_on)
float vix15Open    = request.security(vixTicker, "15", open, barmerge.gaps_off, barmerge.lookahead_off)

float dailyVixChangePct = not na(vixPrevClose) and vixPrevClose != 0 ? ((vixClose - vixPrevClose) / vixPrevClose) * 100.0 : 0.0
float vix5Pct           = not na(vixOpen) and vixOpen != 0 ? ((vixClose - vixOpen) / vixOpen) * 100.0 : 0.0
float vix15Pct          = not na(vix15Open) and vix15Open != 0 ? ((vixClose - vix15Open) / vix15Open) * 100.0 : 0.0

var int vixTrend = 0 
var float vixExtremum = na 

if isNewSession
    vixTrend := 0 
    vixExtremum := vixClose

if not na(vixClose)
    if vixTrend == 0
        if not na(vixExtremum)
            float startPctChange = ((vixClose - vixExtremum) / vixExtremum) * 100.0
            if startPctChange >= vixRevThreshold
                vixTrend := 1, vixExtremum := vixClose
            else if startPctChange <= -vixRevThreshold
                vixTrend := -1, vixExtremum := vixClose
    else if vixTrend == 1 
        vixExtremum := math.max(vixExtremum, vixClose) 
        float highPctChange = ((vixClose - vixExtremum) / vixExtremum) * 100.0
        if highPctChange <= -vixRevThreshold
            vixTrend := -1, vixExtremum := vixClose
    else if vixTrend == -1 
        vixExtremum := math.min(vixExtremum, vixClose) 
        float lowPctChange = ((vixClose - vixExtremum) / vixExtremum) * 100.0
        if lowPctChange >= vixRevThreshold
            vixTrend := 1, vixExtremum := vixClose

bool isVixFalling = vixTrend == -1 
bool isVixRising  = vixTrend == 1

float highestCloseBoundary = ta.highest(close[1], priceLength)
float lowestCloseBoundary  = ta.lowest(close[1], priceLength)
bool isBullishCandle = close > open
bool isBearishCandle = close < open

bool isEarlySession = time < sessionStartTime + 10 * 60000 
bool closeBullBreak = isEarlySession ? (close > or5High and isBullishCandle) : (close > highestCloseBoundary and isBullishCandle)
bool closeBearBreak = isEarlySession ? (close < or5Low and isBearishCandle)  : (close < lowestCloseBoundary and isBearishCandle)

bool rawLongCondition  = closeBullBreak and isVixFalling
bool rawShortCondition = closeBearBreak and isVixRising

bool forceBull = vix15Pct <= -vix15Threshold
bool forceBear = vix15Pct >= vix15Threshold
bool isVixNeutral = (math.abs(vix5Pct) < vix5NeutralThresh) and (math.abs(vix15Pct) < vix15NeutralThresh)

var string activeBarStateText = "Neutral" 
if isNewSession
    activeBarStateText := "Neutral"

if isVixNeutral
    activeBarStateText := "Neutral"
else if forceBull
    activeBarStateText := "Bull"
else if forceBear
    activeBarStateText := "Bear"
else if rawLongCondition
    activeBarStateText := "Bull"
else if rawShortCondition
    activeBarStateText := "Bear"

var string[] signalHistoryText = array.new<string>(0)
var int[] signalHistoryTime    = array.new<int>(0)

if isNewSession
    array.clear(signalHistoryText)
    array.clear(signalHistoryTime)

if barstate.isconfirmed
    array.push(signalHistoryText, activeBarStateText)
    array.push(signalHistoryTime, time)
    if array.size(signalHistoryText) > 120
        array.shift(signalHistoryText)
        array.shift(signalHistoryTime)

var int lastPlot = 0
bool plotLong  = activeBarStateText == "Bull" and lastPlot != 1
bool plotShort = activeBarStateText == "Bear" and lastPlot != -1

if plotLong
    lastPlot := 1
else if plotShort
    lastPlot := -1

plotshape(plotLong, title="Long Entry Flag", style=shape.triangleup, location=location.belowbar, color=colLong, size=size.normal)
plotshape(plotShort, title="Short Entry Flag", style=shape.triangledown, location=location.abovebar, color=colShort, size=size.normal)

// ==========================================
// --- Dual Multi-Timeframe EMAs ---
// ==========================================
float mtfEma1 = request.security(syminfo.tickerid, emaTf1, ta.ema(close, emaLen1), barmerge.gaps_off, barmerge.lookahead_off)
float mtfEma2 = request.security(syminfo.tickerid, emaTf2, ta.ema(close, emaLen2), barmerge.gaps_off, barmerge.lookahead_off)
plot(mtfEma1, title="Dual EMA 1 Line", color=color.blue, linewidth=1)
plot(mtfEma2, title="Dual EMA 2 Line", color=color.purple, linewidth=1)

// ==========================================
// --- Floor Trader Pivots Calculations ---
// ==========================================
prevHigh  = request.security(syminfo.tickerid, "D", high[1],  lookahead=barmerge.lookahead_on)
prevLow   = request.security(syminfo.tickerid, "D", low[1],   lookahead=barmerge.lookahead_on)
prevClose = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_on)

float pp = (prevHigh + prevLow + prevClose) / 3.0
float rw = prevHigh - prevLow
float r1 = 2.0 * pp - prevLow,               s1 = 2.0 * pp - prevHigh
float r2 = pp + rw,                          s2 = pp - rw
float r3 = prevHigh + 2.0 * (pp - prevLow),  s3 = prevLow - 2.0 * (prevHigh - pp)
float r4 = pp + (rw * 2.0),                  s4 = pp - (rw * 2.0)
float r5 = pp + (rw * 3.0),                  s5 = pp - (rw * 3.0)
float r6 = pp + (rw * 4.0),                  s6 = pp - (rw * 4.0)
float r7 = pp + (rw * 5.0),                  s7 = pp - (rw * 5.0)

mR1 = (pp + r1) / 2.0, mS1 = (pp + s1) / 2.0
mR2 = (r1 + r2) / 2.0, mS2 = (s1 + s2) / 2.0
mR3 = (r2 + r3) / 2.0, mS3 = (s2 + s3) / 2.0
mR4 = (r3 + r4) / 2.0, mS4 = (s3 + s4) / 2.0
mR5 = (r4 + r5) / 2.0, mS5 = (s4 + s5) / 2.0
mR6 = (r5 + r6) / 2.0, mS6 = (s5 + s6) / 2.0
mR7 = (r6 + r7) / 2.0, mS7 = (s6 + s7) / 2.0

var line[] pivotLines = array.new<line>(0)
if isNewSession
    if array.size(pivotLines) > 0
        for i = array.size(pivotLines) - 1 to 0
            line.delete(array.get(pivotLines, i))
        array.clear(pivotLines)

    add_line_time(sessionStartTime, sessionEndTime, pp, colorPivot, "solid", 2, pivotLines)
    for lvl = 1 to maxPivotLevels
        if lvl == 1
            add_line_time(sessionStartTime, sessionEndTime, r1, colorRes, "solid", 1, pivotLines), add_line_time(sessionStartTime, sessionEndTime, mR1, colorMid, "dashed", 1, pivotLines)
            add_line_time(sessionStartTime, sessionEndTime, s1, colorSup, "solid", 1, pivotLines), add_line_time(sessionStartTime, sessionEndTime, mS1, colorMid, "dashed", 1, pivotLines)
        if lvl == 2
            add_line_time(sessionStartTime, sessionEndTime, r2, colorRes, "solid", 1, pivotLines), add_line_time(sessionStartTime, sessionEndTime, mR2, colorMid, "dashed", 1, pivotLines)
            add_line_time(sessionStartTime, sessionEndTime, s2, colorSup, "solid", 1, pivotLines), add_line_time(sessionStartTime, sessionEndTime, mS2, colorMid, "dashed", 1, pivotLines)
        if lvl == 3
            add_line_time(sessionStartTime, sessionEndTime, r3, colorRes, "solid", 1, pivotLines), add_line_time(sessionStartTime, sessionEndTime, mR3, colorMid, "dashed", 1, pivotLines)
            add_line_time(sessionStartTime, sessionEndTime, s3, colorSup, "solid", 1, pivotLines), add_line_time(sessionStartTime, sessionEndTime, mS3, colorMid, "dashed", 1, pivotLines)
        if lvl == 4
            add_line_time(sessionStartTime, sessionEndTime, r4, colorRes, "solid", 1, pivotLines), add_line_time(sessionStartTime, sessionEndTime, mR4, colorMid, "dashed", 1, pivotLines)
            add_line_time(sessionStartTime, sessionEndTime, s4, colorSup, "solid", 1, pivotLines), add_line_time(sessionStartTime, sessionEndTime, mS4, colorMid, "dashed", 1, pivotLines)
        if lvl == 5
            add_line_time(sessionStartTime, sessionEndTime, r5, colorRes, "solid", 1, pivotLines), add_line_time(sessionStartTime, sessionEndTime, mR5, colorMid, "dashed", 1, pivotLines)
            add_line_time(sessionStartTime, sessionEndTime, s5, colorSup, "solid", 1, pivotLines), add_line_time(sessionStartTime, sessionEndTime, mS5, colorMid, "dashed", 1, pivotLines)
        if lvl == 6
            add_line_time(sessionStartTime, sessionEndTime, r6, colorRes, "solid", 1, pivotLines), add_line_time(sessionStartTime, sessionEndTime, mR6, colorMid, "dashed", 1, pivotLines)
            add_line_time(sessionStartTime, sessionEndTime, s6, colorSup, "solid", 1, pivotLines), add_line_time(sessionStartTime, sessionEndTime, mS6, colorMid, "dashed", 1, pivotLines)
        if lvl == 7
            add_line_time(sessionStartTime, sessionEndTime, r7, colorRes, "solid", 1, pivotLines), add_line_time(sessionStartTime, sessionEndTime, mR7, colorMid, "dashed", 1, pivotLines)
            add_line_time(sessionStartTime, sessionEndTime, s7, colorSup, "solid", 1, pivotLines), add_line_time(sessionStartTime, sessionEndTime, mS7, colorMid, "dashed", 1, pivotLines)

// ==========================================
// --- Dynamic Rolling VWAPs Channel Systems ---
// ==========================================
f_rolling_vwap(int len, float src) =>
    float sumPV = ta.sma(src * volume, len) * len
    float sumV  = ta.sma(volume, len) * len
    sumV > 0 ? sumPV / sumV : na

vwapSession   = ta.vwap(hlc3)
vwapR1_Center = f_rolling_vwap(lenVwapR1, hlc3)
vwapR1_High   = f_rolling_vwap(lenVwapR1, high)
vwapR1_Low    = f_rolling_vwap(lenVwapR1, low)
vwapR2_Center = f_rolling_vwap(lenVwapR2, hlc3)

plot(vwapSession, "Session VWAP", color=colorVwapD, linewidth=3)
plot(vwapR1_Center, "Rolling VWAP 1 Center", color=colorVwapR1, linewidth=2)
plot(vwapR1_High, "Rolling VWAP 1 High Band", color=colorVwapR1, linewidth=1)
plot(vwapR1_Low, "Rolling VWAP 1 Low Band", color=colorVwapR1, linewidth=1)
plot(vwapR2_Center, "Rolling VWAP 2 Center", color=colorVwapR2, linewidth=3)


// ==========================================
// --- Staggered Labels Real-Time Updates ---
// ==========================================
var label[] sessionLabels = array.new<label>(0)
var bool initSessionLabels = false

if isNewSession
    initSessionLabels := false
    if array.size(sessionLabels) > 0
        for i = 0 to array.size(sessionLabels) - 1
            label.delete(array.get(sessionLabels, i))
        array.clear(sessionLabels)

if showLabels and not in15mOR and not initSessionLabels
    initSessionLabels := true
    int anchorBar = sessionStartBarIndex
    
    add_lbl(anchorBar + 10, pp, "PP: " + str.tostring(pp, "#.##"), colorPivot, label.style_label_left, sessionLabels)
    
    for lvl = 1 to maxPivotLevels
        int baseR = anchorBar + 10 + (lvl * 8)
        int baseS = anchorBar + 14 + (lvl * 8)
        
        if lvl == 1
            add_lbl(baseR, r1, "R1: " + str.tostring(r1, "#.##"), colorRes, label.style_label_left, sessionLabels)
            add_lbl(baseR + 2, mR1, "mR1: " + str.tostring(mR1, "#.##"), colorMid, label.style_label_right, sessionLabels)
            add_lbl(baseS, s1, "S1: " + str.tostring(s1, "#.##"), colorSup, label.style_label_left, sessionLabels)
            add_lbl(baseS + 2, mS1, "mS1: " + str.tostring(mS1, "#.##"), colorMid, label.style_label_right, sessionLabels)
        if lvl == 2
            add_lbl(baseR, r2, "R2: " + str.tostring(r2, "#.##"), colorRes, label.style_label_left, sessionLabels)
            add_lbl(baseR + 2, mR2, "mR2: " + str.tostring(mR2, "#.##"), colorMid, label.style_label_right, sessionLabels)
            add_lbl(baseS, s2, "S2: " + str.tostring(s2, "#.##"), colorSup, label.style_label_left, sessionLabels)
            add_lbl(baseS + 2, mS2, "mS2: " + str.tostring(mS2, "#.##"), colorMid, label.style_label_right, sessionLabels)
        if lvl == 3
            add_lbl(baseR, r3, "R3: " + str.tostring(r3, "#.##"), colorRes, label.style_label_left, sessionLabels)
            add_lbl(baseR + 2, mR3, "mR3: " + str.tostring(mR3, "#.##"), colorMid, label.style_label_right, sessionLabels)
            add_lbl(baseS, s3, "S3: " + str.tostring(s3, "#.##"), colorSup, label.style_label_left, sessionLabels)
            add_lbl(baseS + 2, mS3, "mS3: " + str.tostring(mS3, "#.##"), colorMid, label.style_label_right, sessionLabels)
        if lvl == 4
            add_lbl(baseR, r4, "R4: " + str.tostring(r4, "#.##"), colorRes, label.style_label_left, sessionLabels)
            add_lbl(baseR + 2, mR4, "mR4: " + str.tostring(mR4, "#.##"), colorMid, label.style_label_right, sessionLabels)
            add_lbl(baseS, s4, "S4: " + str.tostring(s4, "#.##"), colorSup, label.style_label_left, sessionLabels)
            add_lbl(baseS + 2, mS4, "mS4: " + str.tostring(mS4, "#.##"), colorMid, label.style_label_right, sessionLabels)
        if lvl == 5
            add_lbl(baseR, r5, "R5: " + str.tostring(r5, "#.##"), colorRes, label.style_label_left, sessionLabels)
            add_lbl(baseR + 2, mR5, "mR5: " + str.tostring(mR5, "#.##"), colorMid, label.style_label_right, sessionLabels)
            add_lbl(baseS, s5, "S5: " + str.tostring(s5, "#.##"), colorSup, label.style_label_left, sessionLabels)
            add_lbl(baseS + 2, mS5, "mS5: " + str.tostring(mS5, "#.##"), colorMid, label.style_label_right, sessionLabels)
        if lvl == 6
            add_lbl(baseR, r6, "R6: " + str.tostring(r6, "#.##"), colorRes, label.style_label_left, sessionLabels)
            add_lbl(baseR + 2, mR6, "mR6: " + str.tostring(mR6, "#.##"), colorMid, label.style_label_right, sessionLabels)
            add_lbl(baseS, s6, "S6: " + str.tostring(s6, "#.##"), colorSup, label.style_label_left, sessionLabels)
            add_lbl(baseS + 2, mS6, "mS6: " + str.tostring(mS6, "#.##"), colorMid, label.style_label_right, sessionLabels)
        if lvl == 7
            add_lbl(baseR, r7, "R7: " + str.tostring(r7, "#.##"), colorRes, label.style_label_left, sessionLabels)
            add_lbl(baseR + 2, mR7, "mR7: " + str.tostring(mR7, "#.##"), colorMid, label.style_label_right, sessionLabels)
            add_lbl(baseS, s7, "S7: " + str.tostring(s7, "#.##"), colorSup, label.style_label_left, sessionLabels)
            add_lbl(baseS + 2, mS7, "mS7: " + str.tostring(mS7, "#.##"), colorMid, label.style_label_right, sessionLabels)

    add_lbl(anchorBar + 75, mtfEma1, "EMA 1: " + str.tostring(mtfEma1, "#.##"), color.blue, label.style_label_left, sessionLabels)
    add_lbl(anchorBar + 77, mtfEma2, "EMA 2: " + str.tostring(mtfEma2, "#.##"), color.purple, label.style_label_left, sessionLabels)
    add_lbl(anchorBar + 79, vwapSession, "S-VWAP: " + str.tostring(vwapSession, "#.##"), colorVwapD, label.style_label_left, sessionLabels)
    add_lbl(anchorBar + 81, vwapR1_Center, "R-VWAP1: " + str.tostring(vwapR1_Center, "#.##"), colorVwapR1, label.style_label_left, sessionLabels)
    add_lbl(anchorBar + 83, vwapR2_Center, "R-VWAP2: " + str.tostring(vwapR2_Center, "#.##"), colorVwapR2, label.style_label_left, sessionLabels)

if showLabels and array.size(sessionLabels) > 0 and not in15mOR
    int idx = 0
    label.set_y(array.get(sessionLabels, idx), pp), idx += 1
    
    for lvl = 1 to maxPivotLevels
        if lvl == 1
            label.set_y(array.get(sessionLabels, idx), r1), idx += 1, label.set_y(array.get(sessionLabels, idx), mR1), idx += 1
            label.set_y(array.get(sessionLabels, idx), s1), idx += 1, label.set_y(array.get(sessionLabels, idx), mS1), idx += 1
        if lvl == 2
            label.set_y(array.get(sessionLabels, idx), r2), idx += 1, label.set_y(array.get(sessionLabels, idx), mR2), idx += 1
            label.set_y(array.get(sessionLabels, idx), s2), idx += 1, label.set_y(array.get(sessionLabels, idx), mS2), idx += 1
        if lvl == 3
            label.set_y(array.get(sessionLabels, idx), r3), idx += 1, label.set_y(array.get(sessionLabels, idx), mR3), idx += 1
            label.set_y(array.get(sessionLabels, idx), s3), idx += 1, label.set_y(array.get(sessionLabels, idx), mS3), idx += 1
        if lvl == 4
            label.set_y(array.get(sessionLabels, idx), r4), idx += 1, label.set_y(array.get(sessionLabels, idx), mR4), idx += 1
            label.set_y(array.get(sessionLabels, idx), s4), idx += 1, label.set_y(array.get(sessionLabels, idx), mS4), idx += 1
        if lvl == 5
            label.set_y(array.get(sessionLabels, idx), r5), idx += 1, label.set_y(array.get(sessionLabels, idx), mR5), idx += 1
            label.set_y(array.get(sessionLabels, idx), s5), idx += 1, label.set_y(array.get(sessionLabels, idx), mS5), idx += 1
        if lvl == 6
            label.set_y(array.get(sessionLabels, idx), r6), idx += 1, label.set_y(array.get(sessionLabels, idx), mR6), idx += 1
            label.set_y(array.get(sessionLabels, idx), s6), idx += 1, label.set_y(array.get(sessionLabels, idx), mS6), idx += 1
        if lvl == 7
            label.set_y(array.get(sessionLabels, idx), r7), idx += 1, label.set_y(array.get(sessionLabels, idx), mR7), idx += 1
            label.set_y(array.get(sessionLabels, idx), s7), idx += 1, label.set_y(array.get(sessionLabels, idx), mS7), idx += 1

    label.set_y(array.get(sessionLabels, idx), mtfEma1), idx += 1
    label.set_y(array.get(sessionLabels, idx), mtfEma2), idx += 1
    label.set_y(array.get(sessionLabels, idx), vwapSession), idx += 1
    label.set_y(array.get(sessionLabels, idx), vwapR1_Center), idx += 1
    label.set_y(array.get(sessionLabels, idx), vwapR2_Center), idx += 1

// ==========================================
// --- 2-Row HUD Dashboard Rendering ---
// ==========================================
format_time(int ms) => str.tostring(hour(ms), "00") + ":" + str.tostring(minute(ms), "00")

color lightBull = color.rgb(129, 199, 132) 
color lightBear = color.rgb(229, 115, 115) 
color dashGray  = color.rgb(158, 158, 158) 

f_get_color(string state) =>
    state == "Bull" ? lightBull : (state == "Bear" ? lightBear : dashGray)

var table dashTable = table.new(position.top_right, columns = 50, rows = 2, border_width = 1, border_color = color.new(color.white, 100))

if barstate.islast
    table.clear(dashTable, 0, 0, 49, 1)

    int totalBars = array.size(signalHistoryTime)
    
    string vText = isVixNeutral ? "Neutral" : (vixTrend == -1 ? "Cooling" : "Spiking")
    
    string vixCellTop = "VIX: " + (dailyVixChangePct > 0 ? "+" : "") + str.tostring(dailyVixChangePct, "#.##") + "%"
    string vixCellBot = vText
    
    table.cell(dashTable, 0, 0, vixCellTop, text_color=color.white, bgcolor=color.new(color.black, 15), text_size=size.normal)
    table.cell(dashTable, 0, 1, vixCellBot, text_color=color.white, bgcolor=color.new(color.black, 15), text_size=size.normal)
    
    // ROW 0: 15-Minute Blocks (Dynamically Capped)
    int start15 = 0
    int total15mBlocks = math.ceil(totalBars / 3.0)
    if total15mBlocks > max15mBlocks
        start15 := (total15mBlocks - max15mBlocks) * 3

    int colIdx15 = 1
    if totalBars > 0
        for i = start15 to totalBars - 1 by 3
            if colIdx15 > 49
                break
                
            int b1 = i, b2 = math.min(totalBars - 1, i + 1), b3 = math.min(totalBars - 1, i + 2)
            
            string hState1 = array.get(signalHistoryText, b1)
            string hState2 = array.get(signalHistoryText, b2)
            string hState3 = array.get(signalHistoryText, b3)
            
            string macroState = "Neutral"
            if hState1 == "Bull" or hState2 == "Bull" or hState3 == "Bull"
                macroState := "Bull"
            else if hState1 == "Bear" or hState2 == "Bear" or hState3 == "Bear"
                macroState := "Bear"
            
            string cellText = format_time(array.get(signalHistoryTime, b1)) + "\n" + macroState
            table.cell(dashTable, colIdx15, 0, cellText, text_color=color.white, bgcolor=f_get_color(macroState), text_size=size.small)
            colIdx15 += 1
            
    // ROW 1: 5-Minute Pipeline (Capped at exactly 6 historical blocks + Now)
    int maxFiveMinBars = 6
    int p_start = math.max(0, totalBars - maxFiveMinBars)
    int colIdx5 = 1
    
    table.cell(dashTable, colIdx5, 1, "5m Pipeline ➡️", text_color=color.white, bgcolor=color.new(color.black, 15), text_size=size.small)
    colIdx5 += 1
    
    if totalBars > 0
        for i = p_start to totalBars - 1
            if colIdx5 > 48
                break
                
            string state = array.get(signalHistoryText, i)
            string cellText = format_time(array.get(signalHistoryTime, i)) + "\n" + state
            table.cell(dashTable, colIdx5, 1, cellText, text_color=color.white, bgcolor=f_get_color(state), text_size=size.small)
            colIdx5 += 1
            
    if colIdx5 <= 49
        table.cell(dashTable, colIdx5, 1, "Now:\n" + activeBarStateText, text_color=color.white, bgcolor=f_get_color(activeBarStateText), text_size=size.small)
        colIdx5 += 1
        
    // --- 10% EDGE OFFSET SPACER ---
    int spacerCol = math.max(colIdx15, colIdx5)
    if spacerCol <= 49
        table.cell(dashTable, spacerCol, 0, "", width=10, bgcolor=na)
        table.cell(dashTable, spacerCol, 1, "", width=10, bgcolor=na)
````
