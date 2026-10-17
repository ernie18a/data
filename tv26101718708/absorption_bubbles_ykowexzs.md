# Absorption Bubbles

- url: https://www.tradingview.com/script/YkOWEXZs-Absorption-Bubbles/
- type: indicator
- pine_id: PUB;dd45b77cb7bc44669a8339e216f2ae09
- version: 1.0

## Description

Absorption Bubbles


Chart example (how to read it)
Green and red bubbles highlight candles with unusually high relative volume where price action suggests rejection (potential absorption) rather than clean continuation. Horizontal lines mark strong reaction levels and remain visible to track future retests/mitigation. The top-right table summarizes the current volume environment: Session RVOL (today vs average), Bar RVOL (current bar vs normal), Efficiency (volume-to-movement proxy), and an ATR-based stop distance (volatility reference).


This indicator helps you interpret relative volume participation and price reaction to highlight potential absorption / rejection areas without requiring Level 2 (order book) data.

What it does

1. Absorption Bubbles: Marks candles where volume is meaningfully higher than normal (relative volume) and where price action suggests a rejection rather than clean acceptance.

2. Persistent Zones (optional): When a strong event is detected, the script can draw a horizontal level/zone that remains on the chart to track retests and mitigation.

3. Volume Regime Table: Displays session and bar relative volume to quickly gauge whether the market is operating in a low-, normal-, or high-liquidity environment.

4. ATR Stop (RMA): Provides an ATR-based stop distance to standardize risk under changing volatility.

Why it’s useful

1. Helps identify moments when participation increases and price either rejects (often associated with absorption/defense) or moves efficiently (often associated with continuation).

2. Adds context to decide whether conditions are more likely choppy/rotational or trending/displacing, using volume and volatility proxies.

3. Keeps key reaction levels visible via zones, making retests easier to track.

How to use it

1. Start with the table:

: Higher Session RVOL generally means more liquidity and potentially better follow-through.

: Higher Bar RVOL highlights unusually active candles.

2. Focus bubbles around key locations:
Use bubbles as confirmation near important levels (session highs/lows, prior day levels, HTF
zones, obvious liquidity pools). Avoid treating mid-range bubbles as standalone signals.

3. Use zones as decision levels (if enabled):
Watch for clean rejection from the zone, or a decisive body break and retest for
continuation.

4.Use ATR Stop as a volatility reference:
Multiply the ATR value to match your risk model and instrument volatility.

Settings guidance

1. Increase RVOL thresholds to reduce noise (fewer, higher-quality signals).

2. Decrease thresholds to catch more frequent micro-events (more signals, more false positives).

3. Adjust lookbacks based on timeframe and instrument.

Limitations

1. This script does not use bid/ask delta or full order book information.

2. “Absorption” is inferred from volume + candle behavior, so signals should be used as confluence, not as a standalone trading system.

## Source Code

````pine
//@version=6
indicator("Absorption Bubbles", overlay=true, max_lines_count=500, max_labels_count=500)

// ─────────────────────────────
// INPUTS — ABSORPTION
// ─────────────────────────────
showBubbles          = input.bool(true,  "Show Absorption Bubbles", group="Absorption")
bubbleOnAbsorbBar    = input.bool(true,  "Place Bubble on Absorption Bar (else on confirm bar)", group="Absorption")
confirmNextBar       = input.bool(true,  "Require Next-Bar Confirmation", group="Absorption")
requireReversalClose = input.bool(true,  "Require Reversal Close", group="Absorption")

volLen          = input.int(20,   "Volume MA Length (Bar RVOL)", minval=5, group="Absorption")
volMult         = input.float(1.5,"Volume Threshold (x MA)", step=0.1, group="Absorption")
wickRatio       = input.float(0.6,"Min Wick Ratio", step=0.05, group="Absorption")
maxBodyPct      = input.float(0.35,"Max Body % of Range", step=0.05, group="Absorption")
confirmTolTicks = input.int(1, "Confirmation Tolerance (ticks)", minval=0, group="Absorption")

// ─────────────────────────────
// INPUTS — ZONES (ACCUMULATION)
// ─────────────────────────────
showZones       = input.bool(true,  "Show Zones", group="Zones")
maxZonesPerSide = input.int(12, "Max Zones per Side", minval=1, maxval=50, group="Zones")
mergeTolTicks   = input.int(2,  "Merge Tolerance (ticks)", minval=0, group="Zones")
breakTolTicks   = input.int(2,  "Break Tolerance (ticks)", minval=0, group="Zones")
lineExtendBars  = input.int(200,"Zone Extension (bars)", minval=10, group="Zones")
maxLineWidth    = input.int(5,  "Max Zone Width", minval=1, maxval=6, group="Zones")
showZoneCount   = input.bool(true, "Show Zone Count (xN)", group="Zones")

// ─────────────────────────────
// INPUTS — REGIME BOX
// ─────────────────────────────
showBox          = input.bool(true, "Show Regime Box", group="Regime Box")
sessionStr       = input.session("0930-1600", "Session (exchange time)", group="Regime Box")
sessionsLookback = input.int(20, "Sessions Lookback (avg)", minval=5, maxval=60, group="Regime Box")

rvolLow          = input.float(0.85, "Sess RVOL Low (THIN)", step=0.05, group="Regime Box")
rvolHigh         = input.float(1.15, "Sess RVOL High", step=0.05, group="Regime Box")

erLookback       = input.int(20, "Efficiency Lookback (bars)", minval=5, maxval=200, group="Regime Box")
erTrendThresh    = input.float(0.45, "Efficiency Threshold (TREND)", step=0.05, group="Regime Box")

// ─────────────────────────────
// INPUTS — ATR STOP 
// ─────────────────────────────
atrLen        = input.int(14, title="ATR Period", minval=1, group="ATR Stop")
atrSmoothing  = input.string(title="Smoothing", defval="RMA", options=["RMA", "SMA", "EMA", "WMA"], group="ATR Stop")
atrMultiplier = input.float(title="ATR Multiplier", defval=1.0, minval=0.01, maxval=100, step=0.05, group="ATR Stop")

// ─────────────────────────────
// HELPERS
// ─────────────────────────────
f_avg_float(float[] a) =>
    int n = array.size(a)
    if n == 0
        na
    else
        float s = 0.0
        for i = 0 to n - 1
            s += array.get(a, i)
        s / n

f_zone_color(bool isSell, int hits) =>
    int tr = math.max(0, 75 - hits * 12)
    isSell ? color.new(color.red, tr) : color.new(color.lime, tr)

f_zone_width(int hits) =>
    math.min(maxLineWidth, math.max(1, 1 + hits / 2))

f_find_match(float[] levels, float lvl, float tolPrice) =>
    int idx = -1
    int n = array.size(levels)
    if n > 0
        for i = 0 to n - 1
            if math.abs(array.get(levels, i) - lvl) <= tolPrice
                idx := i
                break
    idx

f_update_tag(label tg, int x, float y, int hits, bool isSell) =>
    if not na(tg)
        label.set_x(tg, x)
        label.set_y(tg, y)
        label.set_text(tg, "x" + str.tostring(hits))
        label.set_textcolor(tg, color.white)
        label.set_style(tg, label.style_label_left)
        label.set_color(tg, isSell ? color.new(color.red, 0) : color.new(color.lime, 0))

f_create_tag(int x, float y, int hits, bool isSell) =>
    label.new(x, y, "x" + str.tostring(hits), style=label.style_label_left, textcolor=color.white, color=(isSell ? color.new(color.red, 0) : color.new(color.lime, 0)))

// ATR smoothing function (your style)
ma_function(series float src, int len) =>
    if atrSmoothing == "RMA"
        ta.rma(src, len)
    else if atrSmoothing == "SMA"
        ta.sma(src, len)
    else if atrSmoothing == "EMA"
        ta.ema(src, len)
    else
        ta.wma(src, len)

// ─────────────────────────────
// CORE SERIES
// ─────────────────────────────
tickSize    = syminfo.mintick
float barMsF = timeframe.in_seconds() * 1000.0
int barMs    = int(barMsF)

candleRange = high - low
safeRange   = candleRange <= tickSize ? tickSize : candleRange

body      = math.abs(close - open)
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low

volMA = ta.sma(volume, volLen)
float barRVOL = (not na(volMA) and volMA > 0) ? (volume / volMA) : na

// ATR Stop value (TR smoothed * multiplier)
catr   = ma_function(ta.tr(true), atrLen)
atrVal = catr * atrMultiplier

// ─────────────────────────────
// ABSORPTION + CONFIRMATION
// ─────────────────────────────
highVolume   = volume > volMA * volMult
smallBody    = body < candleRange * maxBodyPct
upperWickDom = (upperWick / safeRange) >= wickRatio
lowerWickDom = (lowerWick / safeRange) >= wickRatio

upperCloseOk = (not requireReversalClose) or (close < open)
lowerCloseOk = (not requireReversalClose) or (close > open)

upperAbsorb = highVolume and smallBody and upperWickDom and upperCloseOk
lowerAbsorb = highVolume and smallBody and lowerWickDom and lowerCloseOk

tol = confirmTolTicks * tickSize

sellConfirmed = confirmNextBar ? (upperAbsorb[1] and high <= high[1] + tol) : upperAbsorb
buyConfirmed  = confirmNextBar ? (lowerAbsorb[1] and low  >= low[1] - tol) : lowerAbsorb

sellLevel = confirmNextBar ? high[1] : high
buyLevel  = confirmNextBar ? low[1]  : low

// ─────────────────────────────
// BUBBLES (anchored)
// ─────────────────────────────
bubbleOffset = 0
if bubbleOnAbsorbBar and confirmNextBar
    bubbleOffset := -1

float sellBubble = (showBubbles and sellConfirmed) ? sellLevel : na
float buyBubble  = (showBubbles and buyConfirmed)  ? buyLevel  : na

plotshape(sellBubble, title="Sell Bubble", style=shape.circle, location=location.absolute, color=color.new(color.red, 0),  size=size.small, offset=bubbleOffset)
plotshape(buyBubble,  title="Buy Bubble",  style=shape.circle, location=location.absolute, color=color.new(color.lime, 0), size=size.small, offset=bubbleOffset)

// ─────────────────────────────
// ZONES (ACCUMULATED)
// ─────────────────────────────
var float[] sellLevels = array.new_float()
var line[]  sellLines  = array.new_line()
var int[]   sellHits   = array.new_int()
var label[] sellTags   = array.new_label()

var float[] buyLevels  = array.new_float()
var line[]  buyLines   = array.new_line()
var int[]   buyHits    = array.new_int()
var label[] buyTags    = array.new_label()

mergeTol = mergeTolTicks * tickSize
breakTol = breakTolTicks * tickSize

if showZones and sellConfirmed
    int idxS = f_find_match(sellLevels, sellLevel, mergeTol)
    if idxS >= 0
        int h = array.get(sellHits, idxS) + 1
        array.set(sellHits, idxS, h)
        line ln = array.get(sellLines, idxS)
        line.set_x2(ln, bar_index + lineExtendBars)
        line.set_width(ln, f_zone_width(h))
        line.set_color(ln, f_zone_color(true, h))
        if showZoneCount
            label tg = array.get(sellTags, idxS)
            f_update_tag(tg, bar_index, array.get(sellLevels, idxS), h, true)
    else
        line ln = line.new(bar_index, sellLevel, bar_index + lineExtendBars, sellLevel, color=f_zone_color(true, 1), width=f_zone_width(1))
        array.unshift(sellLevels, sellLevel)
        array.unshift(sellLines, ln)
        array.unshift(sellHits, 1)
        label tg = na
        if showZoneCount
            tg := f_create_tag(bar_index, sellLevel, 1, true)
        array.unshift(sellTags, tg)
        if array.size(sellLevels) > maxZonesPerSide
            line  dln = array.pop(sellLines)
            label dtg = array.pop(sellTags)
            array.pop(sellLevels)
            array.pop(sellHits)
            if not na(dln)
                line.delete(dln)
            if not na(dtg)
                label.delete(dtg)

if showZones and buyConfirmed
    int idxB = f_find_match(buyLevels, buyLevel, mergeTol)
    if idxB >= 0
        int h = array.get(buyHits, idxB) + 1
        array.set(buyHits, idxB, h)
        line ln = array.get(buyLines, idxB)
        line.set_x2(ln, bar_index + lineExtendBars)
        line.set_width(ln, f_zone_width(h))
        line.set_color(ln, f_zone_color(false, h))
        if showZoneCount
            label tg = array.get(buyTags, idxB)
            f_update_tag(tg, bar_index, array.get(buyLevels, idxB), h, false)
    else
        line ln = line.new(bar_index, buyLevel, bar_index + lineExtendBars, buyLevel, color=f_zone_color(false, 1), width=f_zone_width(1))
        array.unshift(buyLevels, buyLevel)
        array.unshift(buyLines, ln)
        array.unshift(buyHits, 1)
        label tg = na
        if showZoneCount
            tg := f_create_tag(bar_index, buyLevel, 1, false)
        array.unshift(buyTags, tg)
        if array.size(buyLevels) > maxZonesPerSide
            line  dln = array.pop(buyLines)
            label dtg = array.pop(buyTags)
            array.pop(buyLevels)
            array.pop(buyHits)
            if not na(dln)
                line.delete(dln)
            if not na(dtg)
                label.delete(dtg)

if showZones
    int i = array.size(sellLevels) - 1
    while i >= 0
        float lvl = array.get(sellLevels, i)
        if close > lvl + breakTol
            line ln = array.get(sellLines, i)
            label tg = array.get(sellTags, i)
            if not na(ln)
                line.delete(ln)
            if not na(tg)
                label.delete(tg)
            array.remove(sellLevels, i)
            array.remove(sellLines, i)
            array.remove(sellHits, i)
            array.remove(sellTags, i)
        i -= 1

    int j = array.size(buyLevels) - 1
    while j >= 0
        float lvl = array.get(buyLevels, j)
        if close < lvl - breakTol
            line ln = array.get(buyLines, j)
            label tg = array.get(buyTags, j)
            if not na(ln)
                line.delete(ln)
            if not na(tg)
                label.delete(tg)
            array.remove(buyLevels, j)
            array.remove(buyLines, j)
            array.remove(buyHits, j)
            array.remove(buyTags, j)
        j -= 1

// ─────────────────────────────
// SESSION RVOL (time-progress; precise)
// ─────────────────────────────
inSess     = not na(time(timeframe.period, sessionStr))
sessStart  = (not inSess[1]) and inSess
sessEnd    = inSess[1] and (not inSess)

var float sessVol = 0.0
var int   sessStartTime = na
var int   sessLastTime  = na
var float[] sessVolHist = array.new_float()
var float[] sessDurHist = array.new_float()

if sessStart
    sessVol := 0.0
    sessStartTime := int(time)
    sessLastTime  := int(time)

if inSess
    sessVol += volume
    sessLastTime := int(time)

if sessEnd and not na(sessStartTime) and not na(sessLastTime)
    float durMs = float((sessLastTime - sessStartTime) + barMs)
    array.unshift(sessVolHist, sessVol)
    array.unshift(sessDurHist, durMs)
    if array.size(sessVolHist) > sessionsLookback
        array.pop(sessVolHist)
    if array.size(sessDurHist) > sessionsLookback
        array.pop(sessDurHist)

avgSessVol = f_avg_float(sessVolHist)
avgSessDur = f_avg_float(sessDurHist)

float progress = na
float expectedSoFar = na
float sessRVOL = na

if inSess and not na(sessStartTime) and not na(avgSessDur) and avgSessDur > 0
    float elapsed = float((int(time) - sessStartTime) + barMs)
    progress := math.min(1.0, elapsed / avgSessDur)

if inSess and not na(avgSessVol) and not na(progress)
    expectedSoFar := avgSessVol * progress

if inSess and not na(expectedSoFar) and expectedSoFar > 0
    sessRVOL := sessVol / expectedSoFar

// Efficiency Ratio
absMove = math.abs(close - close[erLookback])
noise   = ta.sma(math.abs(ta.change(close)), erLookback) * erLookback
effER   = noise > 0 ? absMove / noise : na

string regime = "OUT"
if inSess
    if (not na(sessRVOL)) and (sessRVOL <= rvolLow)
        regime := "THIN"
    else if (not na(sessRVOL)) and (sessRVOL >= rvolHigh) and (not na(effER)) and (effER >= erTrendThresh)
        regime := "TREND"
    else
        regime := "BALANCE"

color bgReg = color.new(color.gray, 80)
if regime == "TREND"
    bgReg := color.new(color.green, 70)
else if regime == "THIN"
    bgReg := color.new(color.red, 70)
else if regime == "BALANCE"
    bgReg := color.new(color.orange, 75)

color rvolBg = color.new(color.black, 65)
if inSess and not na(sessRVOL)
    if sessRVOL >= rvolHigh
        rvolBg := color.new(color.green, 75)
    else if sessRVOL <= rvolLow
        rvolBg := color.new(color.red, 75)
    else
        rvolBg := color.new(color.orange, 78)

color barBg = color.new(color.black, 65)
if not na(barRVOL)
    if barRVOL >= volMult
        barBg := color.new(color.green, 78)
    else if barRVOL <= 0.75
        barBg := color.new(color.red, 78)
    else
        barBg := color.new(color.orange, 80)

// ─────────────────────────────
// TABLE (Regime + Sess RVOL + Bar RVOL + Efficiency + ATR Stop)
// ─────────────────────────────
var table t = na
if showBox and na(t)
    t := table.new(position.top_right, 2, 5, border_width=1)

if showBox
    table.cell(t, 0, 0, "VOL REGIME", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(t, 1, 0, inSess ? regime : "OUT", text_color=color.white, bgcolor=bgReg)

    string sessR = (inSess and not na(sessRVOL)) ? str.tostring(sessRVOL, "#.##") : "n/a"
    table.cell(t, 0, 1, "Sess RVOL", text_color=color.white, bgcolor=color.new(color.black, 65))
    table.cell(t, 1, 1, sessR, text_color=color.white, bgcolor=rvolBg)

    string barR = not na(barRVOL) ? str.tostring(barRVOL, "#.##") : "n/a"
    table.cell(t, 0, 2, "Bar RVOL", text_color=color.white, bgcolor=color.new(color.black, 65))
    table.cell(t, 1, 2, barR, text_color=color.white, bgcolor=barBg)

    string effTxt = not na(effER) ? str.tostring(effER, "#.###") : "n/a"
    table.cell(t, 0, 3, "Efficiency", text_color=color.white, bgcolor=color.new(color.black, 65))
    table.cell(t, 1, 3, effTxt, text_color=color.white, bgcolor=color.new(color.black, 65))

    string atrTxt = not na(atrVal) ? str.tostring(atrVal, format.mintick) : "n/a"
    table.cell(t, 0, 4, "ATR Stop (" + atrSmoothing + ")", text_color=color.white, bgcolor=color.new(color.black, 65))
    table.cell(t, 1, 4, atrTxt, text_color=color.white, bgcolor=color.new(color.black, 65))
````
