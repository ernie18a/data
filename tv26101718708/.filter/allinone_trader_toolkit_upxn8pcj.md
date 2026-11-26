# All-In-One Trader Toolkit

- url: https://www.tradingview.com/script/UPxN8pcJ-All-In-One-Trader-Toolkit/
- type: indicator
- pine_id: PUB;ac77dc0178d7406fbdb413eb6b83ec51
- version: 4.0

## Description

# All-In-One Trader Toolkit (AIO Toolkit)

A comprehensive overlay indicator that combines the key tools intraday futures traders need into a single script. Designed for ES, NQ, and other futures instruments with all sessions anchored to New York (Eastern) time.

## Features

**Supply & Demand Zones**
Auto-detected zones scored 1–10 based on impulse strength vs. basing range. Zones auto-extend until price closes through them (or use a fixed bar width). Filter by minimum score to show only the strongest levels. Fully customizable colors.

**Previous Day High/Low (PDH/PDL)**
Automatically plots the prior trading day's high and low as dashed reference lines. Configurable number of days to keep on chart.

**Pre-Market High/Low (PMH/PML)**
Captures the high and low of the overnight/globex session. Default session is 6:00 PM – 9:30 AM ET (full globex), adjustable to any window (e.g. 4:00 AM – 9:30 AM for London open only).

**15-Minute Opening Range Breakout (ORB)**
Plots the 9:30–9:45 AM ET opening range high/low. Generates BUY/SELL signals on breakout retests. Includes three configurable take-profit levels with optional symbol-specific points for NQ and ES.

**Daily VWAP + ±1 Standard Deviation Bands**
Manually calculated VWAP with upper and lower bands, resetting each trading day.

**NY-Open Anchored VWAP + ±1 Standard Deviation Bands**
Session-only VWAP anchored to the 9:30 AM NY open. Plots only during the 9:30–4:00 PM session with no carryover lines between sessions.

**Initial Balance (IB) + Extensions**
Captures the first 60 minutes of the NY session (9:30–10:30 AM ET). Plots IB High/Low with 50% and 100% extensions in both directions.

**News / Event Markers**
Up to 3 configurable event markers with custom labels and timestamps. Draws vertical dashed lines at the specified times.

**Dual EMA**
Two independent EMAs with adjustable length, color, and line width. Defaults: 8 EMA and 200 EMA.

## Display

- All labels are pinned to the right edge of the chart for easy identification
- Global label size control (tiny / small / normal / large / huge) applies to all elements
- Every feature can be toggled on/off independently
- All colors are fully customizable through the settings panel

## Alerts

Built-in alert conditions for ORB breakouts (up/down) and retest buy/sell signals.

## Best Used On

Intraday futures charts (1-min, 2-min, 5-min) for instruments like NQ, ES, YM, RTY. Works on any symbol but session times are optimized for US equity futures.

## Source Code

````pine
// All-In-One Trader Toolkit
// Inspired by the concepts in "I Built the Indicator I Always Wished Existed"
// by BrandonTrades. Original Pine Script implementation — not a copy of the
// paid product.
//
//@version=6
indicator("All-In-One Trader Toolkit", shorttitle="AIO Toolkit", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ============================================================================
// TIMEZONE — all sessions anchored to New York
// ============================================================================
nyTZ = "America/New_York"

// ============================================================================
// GLOBAL LABEL SIZE
// ============================================================================
grp_global = "General Settings"
labelSizeInput = input.string("large", "Label Size", options=["tiny", "small", "normal", "large", "huge"], group=grp_global)
labelSz = labelSizeInput == "tiny" ? size.tiny : labelSizeInput == "small" ? size.small : labelSizeInput == "normal" ? size.normal : labelSizeInput == "large" ? size.large : size.huge

// FIX: shared helper — appends ": <price>" to a label's base text when the
// relevant toggle (one per logical group, added throughout this script) is
// on. Every "Show Price on ... Labels" input below routes through this.
appendPrice(string baseTxt, bool showPrice, float val) =>
    showPrice ? baseTxt + ": " + str.tostring(val, format.mintick) : baseTxt

// ============================================================================
// SUPPLY & DEMAND ZONES
// ============================================================================
grp_sd = "Supply & Demand Zones"
showSD       = input.bool(true, "Show Supply/Demand Zones", group=grp_sd)
impulseMult  = input.float(1.5, "Impulse Candle Size (x ATR)", minval=1.0, step=0.1, group=grp_sd, tooltip="A candle whose body is this many times the ATR is treated as an 'impulse' move away from a zone.")
lookbackATR  = input.int(7, "ATR Length", minval=1, group=grp_sd)
baseMaxBars  = input.int(3, "Max Basing Candles", minval=1, maxval=10, group=grp_sd, tooltip="How many small candles before the impulse can be combined into the zone.")
zoneExtend   = input.int(0, "Zone Extend (bars right, 0=auto-extend)", minval=0, group=grp_sd, tooltip="Set to 0 to auto-extend zones until price breaks through them. Use a number like 500 to set a fixed width.")
minScore     = input.int(1, "Minimum Zone Score to Show (1-10)", minval=1, maxval=10, group=grp_sd)
demandColor  = input.color(color.new(color.green, 25), "Demand Zone Color", group=grp_sd)
supplyColor  = input.color(color.new(color.red, 25), "Supply Zone Color", group=grp_sd)

atrVal   = ta.atr(lookbackATR)
bodyCur  = math.abs(close - open)
isImpulse   = bodyCur > impulseMult * atrVal
bullImpulse = isImpulse and close > open
bearImpulse = isImpulse and close < open

var box[]   demandBoxes  = array.new<box>()
var box[]   supplyBoxes  = array.new<box>()
var float[] demandLevels = array.new<float>()
var float[] supplyLevels = array.new<float>()

if showSD and (bullImpulse or bearImpulse)
    float baseHigh = na
    float baseLow  = na
    int   baseCount = 0
    for i = 1 to baseMaxBars
        if (high[i] - low[i]) < atrVal
            baseHigh := na(baseHigh) ? high[i] : math.max(baseHigh, high[i])
            baseLow  := na(baseLow)  ? low[i]  : math.min(baseLow, low[i])
            baseCount := baseCount + 1
        else
            break
    if baseCount > 0
        baseRange  = baseHigh - baseLow
        scoreRatio = baseRange > 0 ? bodyCur / baseRange : 10.0
        score = int(math.min(10, math.max(1, math.round(scoreRatio))))
        if score >= minScore
            leftBar = bar_index - baseCount
            int rightBar = zoneExtend == 0 ? bar_index + 1 : bar_index + zoneExtend
            if bullImpulse
                newBox = box.new(leftBar, baseHigh, rightBar, baseLow, border_color=color.new(color.green, 30), bgcolor=demandColor, text="D " + str.tostring(score) + "/10", text_size=labelSz, text_color=color.white)
                array.push(demandBoxes, newBox)
                array.push(demandLevels, baseLow)
            else
                newBox = box.new(leftBar, baseHigh, rightBar, baseLow, border_color=color.new(color.red, 30), bgcolor=supplyColor, text="S " + str.tostring(score) + "/10", text_size=labelSz, text_color=color.white)
                array.push(supplyBoxes, newBox)
                array.push(supplyLevels, baseHigh)

// Auto-extend zone right edges on every bar (when set to 0 / auto)
if zoneExtend == 0
    if array.size(demandBoxes) > 0
        for i = 0 to array.size(demandBoxes) - 1
            box.set_right(array.get(demandBoxes, i), bar_index + 1)
    if array.size(supplyBoxes) > 0
        for i = 0 to array.size(supplyBoxes) - 1
            box.set_right(array.get(supplyBoxes, i), bar_index + 1)

// Auto-delete zones once price closes through them
if array.size(demandBoxes) > 0
    for i = array.size(demandBoxes) - 1 to 0
        if close < array.get(demandLevels, i)
            box.delete(array.get(demandBoxes, i))
            array.remove(demandBoxes, i)
            array.remove(demandLevels, i)

if array.size(supplyBoxes) > 0
    for i = array.size(supplyBoxes) - 1 to 0
        if close > array.get(supplyLevels, i)
            box.delete(array.get(supplyBoxes, i))
            array.remove(supplyBoxes, i)
            array.remove(supplyLevels, i)

// ============================================================================
// PREVIOUS DAY HIGH/LOW & PRE-MARKET HIGH/LOW
// ============================================================================
grp_lv = "Key Levels"
showPDHL  = input.bool(true, "Show Previous Day High/Low", group=grp_lv)
daysBack  = input.int(1, "Days of PDH/PDL History to Keep", minval=1, maxval=30, group=grp_lv)
showPMHL  = input.bool(true, "Show Pre-Market High/Low", group=grp_lv)
pmSessionInput = input.session("1800-0930", "Pre-Market Session (ET)", group=grp_lv, tooltip="Default 1800-0930 = full globex overnight. Change to 0400-0930 for London-only, etc.")
pdHighCol = input.color(color.new(color.blue, 0), "PDH Color", group=grp_lv)
pdLowCol  = input.color(color.new(color.orange, 0), "PDL Color", group=grp_lv)
pmHighCol = input.color(color.new(color.purple, 0), "PMH Color", group=grp_lv)
pmLowCol  = input.color(color.new(color.teal, 0), "PML Color", group=grp_lv)
// FIX: two independent price toggles — PDH/PDL together, PMH/PML together.
showPDHLPriceInput = input.bool(false, "Show Price on PDH/PDL Labels", group=grp_lv)
showPMHLPriceInput = input.bool(false, "Show Price on PMH/PML Labels", group=grp_lv)

// --- Previous day H/L using trading-day change ---
var float todayHigh = na
var float todayLow  = na
var float pdHigh    = na
var float pdLow     = na
var line[] pdHighLines  = array.new<line>()
var line[] pdLowLines   = array.new<line>()
var label[] pdHighLbls  = array.new<label>()
var label[] pdLowLbls   = array.new<label>()

isNewTradingDay = ta.change(time("D")) != 0
if isNewTradingDay
    if not na(todayHigh)
        pdHigh := todayHigh
        pdLow  := todayLow
        if showPDHL
            hLine = line.new(bar_index, pdHigh, bar_index + 1, pdHigh, extend=extend.right, color=pdHighCol, width=1, style=line.style_dashed)
            lLine = line.new(bar_index, pdLow,  bar_index + 1, pdLow,  extend=extend.right, color=pdLowCol,  width=1, style=line.style_dashed)
            hLbl  = label.new(bar_index, pdHigh, appendPrice("PDH", showPDHLPriceInput, pdHigh), style=label.style_label_left, color=color.new(pdHighCol, 80), textcolor=pdHighCol, size=labelSz)
            lLbl  = label.new(bar_index, pdLow,  appendPrice("PDL", showPDHLPriceInput, pdLow), style=label.style_label_left, color=color.new(pdLowCol, 80),  textcolor=pdLowCol,  size=labelSz)
            array.push(pdHighLines, hLine)
            array.push(pdLowLines, lLine)
            array.push(pdHighLbls, hLbl)
            array.push(pdLowLbls, lLbl)
            if array.size(pdHighLines) > daysBack
                line.delete(array.shift(pdHighLines))
                line.delete(array.shift(pdLowLines))
                label.delete(array.shift(pdHighLbls))
                label.delete(array.shift(pdLowLbls))
    todayHigh := high
    todayLow  := low
else
    todayHigh := math.max(nz(todayHigh, high), high)
    todayLow  := math.min(nz(todayLow, low), low)

// --- Pre-market H/L (4:00 AM – 9:30 AM ET) ---
inPM = not na(time(timeframe.period, pmSessionInput, nyTZ))
var float pmHigh = na
var float pmLow  = na
var line pmHighLine = na
var line pmLowLine  = na
var label pmHighLbl = na
var label pmLowLbl  = na

newPM = inPM and not inPM[1]
if newPM
    pmHigh := high
    pmLow  := low
else if inPM
    pmHigh := math.max(pmHigh, high)
    pmLow  := math.min(pmLow, low)

pmEnded = (not inPM) and inPM[1]
if pmEnded and showPMHL
    line.delete(pmHighLine)
    line.delete(pmLowLine)
    label.delete(pmHighLbl)
    label.delete(pmLowLbl)
    pmHighLine := line.new(bar_index, pmHigh, bar_index + 1, pmHigh, extend=extend.right, color=pmHighCol, width=1, style=line.style_dashed)
    pmLowLine  := line.new(bar_index, pmLow,  bar_index + 1, pmLow,  extend=extend.right, color=pmLowCol,  width=1, style=line.style_dashed)
    pmHighLbl  := label.new(bar_index, pmHigh, appendPrice("PMH", showPMHLPriceInput, pmHigh), style=label.style_label_left, color=color.new(pmHighCol, 80), textcolor=pmHighCol, size=labelSz)
    pmLowLbl   := label.new(bar_index, pmLow,  appendPrice("PML", showPMHLPriceInput, pmLow), style=label.style_label_left, color=color.new(pmLowCol, 80),  textcolor=pmLowCol,  size=labelSz)

// ============================================================================
// 30-MINUTE OPENING RANGE BREAKOUT (ORB)
// ============================================================================
grp_orb = "Opening Range Breakout"
showORB       = input.bool(true, "Show ORB High/Low Lines", group=grp_orb)
orbHighCol    = input.color(color.new(#00bcd4, 0), "ORB High Color", group=grp_orb)
orbLowCol     = input.color(color.new(#ff5252, 0), "ORB Low Color", group=grp_orb)
// FIX: one price toggle covering both ORB High and ORB Low.
showORBPriceInput = input.bool(false, "Show Price on ORB Labels", group=grp_orb)

// 9:30 – 9:45 AM ET (15-min ORB)
inORB = not na(time(timeframe.period, "0930-0945", nyTZ))
var float orbHigh = na
var float orbLow  = na
var bool orbLocked = false
var string orbDir  = "none"
var line orbHighLine = na
var line orbLowLine  = na
var label orbHighLbl = na
var label orbLowLbl  = na
newORBBar = inORB and not inORB[1]
if newORBBar
    orbHigh := high
    orbLow  := low
    orbLocked := false
    orbDir  := "none"
else if inORB
    orbHigh := math.max(nz(orbHigh, high), high)
    orbLow  := math.min(nz(orbLow, low), low)

orbJustEnded = (not inORB) and inORB[1]
if orbJustEnded
    orbLocked := true
    if showORB
        line.delete(orbHighLine)
        line.delete(orbLowLine)
        label.delete(orbHighLbl)
        label.delete(orbLowLbl)
        orbHighLine := line.new(bar_index, orbHigh, bar_index + 1, orbHigh, extend=extend.right, color=orbHighCol, width=2)
        orbLowLine  := line.new(bar_index, orbLow,  bar_index + 1, orbLow,  extend=extend.right, color=orbLowCol,  width=2)
        orbHighLbl  := label.new(bar_index, orbHigh, appendPrice("ORB High", showORBPriceInput, orbHigh), style=label.style_label_left, color=color.new(orbHighCol, 80), textcolor=orbHighCol, size=labelSz)
        orbLowLbl   := label.new(bar_index, orbLow,  appendPrice("ORB Low", showORBPriceInput, orbLow),  style=label.style_label_left, color=color.new(orbLowCol, 80),  textcolor=orbLowCol,  size=labelSz)

breakUp   = orbLocked and orbDir == "none" and close > orbHigh
breakDown = orbLocked and orbDir == "none" and close < orbLow

if breakUp
    orbDir := "up"
if breakDown
    orbDir := "down"

alertcondition(breakUp,    "ORB Breakout Up",   "Price closed above the opening range high.")
alertcondition(breakDown,  "ORB Breakout Down", "Price closed below the opening range low.")

// ============================================================================
// NEWS / EVENT MARKERS
// ============================================================================
grp_ev = "News Events"
showEvents  = input.bool(true, "Show Event Markers", group=grp_ev)
event1Time  = input.time(timestamp("2026-01-01 00:00"), "Event 1 Time", group=grp_ev)
event1Label = input.string("", "Event 1 Label", group=grp_ev)
event2Time  = input.time(timestamp("2026-01-01 00:00"), "Event 2 Time", group=grp_ev)
event2Label = input.string("", "Event 2 Label", group=grp_ev)
event3Time  = input.time(timestamp("2026-01-01 00:00"), "Event 3 Time", group=grp_ev)
event3Label = input.string("", "Event 3 Label", group=grp_ev)

plotEventMarker(evTime, evLabel) =>
    if showEvents and evLabel != "" and not na(evTime)
        barMs = timeframe.in_seconds() * 1000
        if time <= evTime and evTime < time + barMs
            line.new(bar_index, low, bar_index, high, extend=extend.both, color=color.new(color.yellow, 0), style=line.style_dashed, width=1)
            label.new(bar_index, high, evLabel, style=label.style_label_down, color=color.new(color.yellow, 0), textcolor=color.black, size=labelSz)

plotEventMarker(event1Time, event1Label)
plotEventMarker(event2Time, event2Label)
plotEventMarker(event3Time, event3Label)

// ============================================================================
// DAILY VWAP + 1 STD DEV BANDS
// ============================================================================
grp_vwap = "Globex VWAP + Bands"
showVWAP      = input.bool(true, "Show Globex VWAP", group=grp_vwap)
showVWAPBands = input.bool(true, "Show ±1 StdDev Bands", group=grp_vwap)
vwapCol       = input.color(color.new(color.blue, 0), "Globex VWAP Color", group=grp_vwap)
vwapBandCol   = input.color(color.new(color.blue, 25), "Band Color", group=grp_vwap)
// FIX: VWAP line and its bands get independent price toggles.
showVwapPriceInput     = input.bool(false, "Show Price on VWAP Label", group=grp_vwap)
showVwapBandPriceInput = input.bool(false, "Show Price on Band Labels", group=grp_vwap)

// Manual VWAP calculation for bands
var float vwapSumPV  = 0.0
var float vwapSumVol = 0.0
var float vwapSumPV2 = 0.0

if isNewTradingDay
    vwapSumPV  := 0.0
    vwapSumVol := 0.0
    vwapSumPV2 := 0.0

typPrice = hlc3
vwapSumPV  += typPrice * volume
vwapSumVol += volume
vwapSumPV2 += typPrice * typPrice * volume

vwapValue    = vwapSumVol != 0 ? vwapSumPV / vwapSumVol : na
vwapVariance = vwapSumVol != 0 ? (vwapSumPV2 / vwapSumVol) - (vwapValue * vwapValue) : na
vwapStdDev   = vwapVariance > 0 ? math.sqrt(vwapVariance) : 0.0
vwapUpper    = vwapValue + vwapStdDev
vwapLower    = vwapValue - vwapStdDev

plot(showVWAP ? vwapValue : na, title="Globex VWAP", color=vwapCol, linewidth=2)
plot(showVWAP and showVWAPBands ? vwapUpper : na, title="Globex UB", color=vwapBandCol, linewidth=1)
plot(showVWAP and showVWAPBands ? vwapLower : na, title="Globex LB", color=vwapBandCol, linewidth=1)

// ============================================================================
// WEEKLY VWAP + 1 STD DEV BANDS
// ============================================================================
grp_wvwap = "Weekly VWAP + Bands"
showWVWAP      = input.bool(true, "Show Weekly VWAP", group=grp_wvwap)
showWVWAPBands = input.bool(true, "Show ±1 StdDev Bands", group=grp_wvwap)
wVwapCol       = input.color(color.new(color.white, 0), "Weekly VWAP Color", group=grp_wvwap)
wVwapBandCol   = input.color(color.new(color.white, 25), "Weekly Band Color", group=grp_wvwap)
// FIX: VWAP line and its bands get independent price toggles.
showWVwapPriceInput     = input.bool(false, "Show Price on VWAP Label", group=grp_wvwap)
showWVwapBandPriceInput = input.bool(false, "Show Price on Band Labels", group=grp_wvwap)

isNewWeek = ta.change(time("W")) != 0
var float wSumPV  = 0.0
var float wSumVol = 0.0
var float wSumPV2 = 0.0

if isNewWeek
    wSumPV  := 0.0
    wSumVol := 0.0
    wSumPV2 := 0.0

wSumPV  += typPrice * volume
wSumVol += volume
wSumPV2 += typPrice * typPrice * volume

wVwapVal  = wSumVol != 0 ? wSumPV / wSumVol : na
wVar      = wSumVol != 0 ? (wSumPV2 / wSumVol) - (wVwapVal * wVwapVal) : na
wSd       = wVar > 0 ? math.sqrt(wVar) : 0.0
wUpper    = wVwapVal + wSd
wLower    = wVwapVal - wSd

plot(showWVWAP ? wVwapVal : na, title="Weekly VWAP", color=wVwapCol, linewidth=2)
plot(showWVWAP and showWVWAPBands ? wUpper : na, title="Weekly UB", color=wVwapBandCol, linewidth=1)
plot(showWVWAP and showWVWAPBands ? wLower : na, title="Weekly LB", color=wVwapBandCol, linewidth=1)

// ============================================================================
// MONTHLY VWAP + 1 STD DEV BANDS
// ============================================================================
grp_mvwap = "Monthly VWAP + Bands"
showMVWAP      = input.bool(true, "Show Monthly VWAP", group=grp_mvwap)
showMVWAPBands = input.bool(true, "Show ±1 StdDev Bands", group=grp_mvwap)
mVwapCol       = input.color(color.new(color.blue, 0), "Monthly VWAP Color", group=grp_mvwap)
mVwapBandCol   = input.color(color.new(color.blue, 25), "Monthly Band Color", group=grp_mvwap)
// FIX: VWAP line and its bands get independent price toggles.
showMVwapPriceInput     = input.bool(false, "Show Price on VWAP Label", group=grp_mvwap)
showMVwapBandPriceInput = input.bool(false, "Show Price on Band Labels", group=grp_mvwap)

isNewMonth = ta.change(time("M")) != 0
var float mSumPV  = 0.0
var float mSumVol = 0.0
var float mSumPV2 = 0.0

if isNewMonth
    mSumPV  := 0.0
    mSumVol := 0.0
    mSumPV2 := 0.0

mSumPV  += typPrice * volume
mSumVol += volume
mSumPV2 += typPrice * typPrice * volume

mVwapVal  = mSumVol != 0 ? mSumPV / mSumVol : na
mVar      = mSumVol != 0 ? (mSumPV2 / mSumVol) - (mVwapVal * mVwapVal) : na
mSd       = mVar > 0 ? math.sqrt(mVar) : 0.0
mUpper    = mVwapVal + mSd
mLower    = mVwapVal - mSd

plot(showMVWAP ? mVwapVal : na, title="Monthly VWAP", color=mVwapCol, linewidth=2)
plot(showMVWAP and showMVWAPBands ? mUpper : na, title="Monthly UB", color=mVwapBandCol, linewidth=1)
plot(showMVWAP and showMVWAPBands ? mLower : na, title="Monthly LB", color=mVwapBandCol, linewidth=1)

// ============================================================================
// NY-OPEN ANCHORED VWAP + 1 STD DEV BANDS
// ============================================================================
grp_nyvwap = "NY-Open Anchored VWAP"
showNYVWAP      = input.bool(true, "Show NY-Open VWAP", group=grp_nyvwap)
showNYVWAPBands = input.bool(true, "Show ±1 StdDev Bands", group=grp_nyvwap)
nyVwapCol       = input.color(color.new(color.yellow, 0), "NY VWAP Color", group=grp_nyvwap)
nyVwapBandCol   = input.color(color.new(color.yellow, 25), "NY Band Color", group=grp_nyvwap)
// FIX: VWAP line and its bands get independent price toggles.
showNYVwapPriceInput     = input.bool(false, "Show Price on VWAP Label", group=grp_nyvwap)
showNYVwapBandPriceInput = input.bool(false, "Show Price on Band Labels", group=grp_nyvwap)

// Detect NY open (9:30 AM ET)
inNYSession = not na(time(timeframe.period, "0930-1600", nyTZ))
nySessionStart = inNYSession and not inNYSession[1]

var float nySumPV  = 0.0
var float nySumVol = 0.0
var float nySumPV2 = 0.0

if nySessionStart
    nySumPV  := 0.0
    nySumVol := 0.0
    nySumPV2 := 0.0

if inNYSession
    nySumPV  += typPrice * volume
    nySumVol += volume
    nySumPV2 += typPrice * typPrice * volume

nyVwapVal  = inNYSession and nySumVol != 0 ? nySumPV / nySumVol : na
nyVar2     = inNYSession and nySumVol != 0 ? (nySumPV2 / nySumVol) - (nz(nyVwapVal) * nz(nyVwapVal)) : na
nySd2      = not na(nyVar2) and nyVar2 > 0 ? math.sqrt(nyVar2) : 0.0
nyUpper2   = not na(nyVwapVal) ? nyVwapVal + nySd2 : na
nyLower2   = not na(nyVwapVal) ? nyVwapVal - nySd2 : na

plot(showNYVWAP ? nyVwapVal : na, title="NY VWAP",  color=nyVwapCol,     linewidth=2, style=plot.style_linebr)
plot(showNYVWAP and showNYVWAPBands ? nyUpper2 : na,  title="NY UB", color=nyVwapBandCol, linewidth=1, style=plot.style_linebr)
plot(showNYVWAP and showNYVWAPBands ? nyLower2 : na,  title="NY LB", color=nyVwapBandCol, linewidth=1, style=plot.style_linebr)

// ============================================================================
// INITIAL BALANCE (IB) — first 60 min of NY session + extensions
// ============================================================================
grp_ib = "Initial Balance"
showIB       = input.bool(true, "Show IB High/Low", group=grp_ib)
showIBExt    = input.bool(true, "Show IB Extensions (50% / 100%)", group=grp_ib)
ibHighCol    = input.color(color.new(#e91e63, 0), "IB High Color", group=grp_ib)
ibLowCol     = input.color(color.new(#e91e63, 0), "IB Low Color", group=grp_ib)
ibExtCol     = input.color(color.new(#e91e63, 25), "IB Extension Color", group=grp_ib)
// FIX: one toggle for IB High/Low together, a separate one for all 4 extensions.
showIBPriceInput    = input.bool(false, "Show Price on IB High/Low Labels", group=grp_ib)
showIBExtPriceInput = input.bool(false, "Show Price on IB Extension Labels", group=grp_ib)

inIB = not na(time(timeframe.period, "0930-1030", nyTZ))
var float ibHigh = na
var float ibLow  = na
var bool  ibLocked = false
var line  ibHighLine = na
var line  ibLowLine  = na
var label ibHighLbl  = na
var label ibLowLbl   = na
var line  ibExt50UpLine   = na
var line  ibExt100UpLine  = na
var line  ibExt50DnLine   = na
var line  ibExt100DnLine  = na
var label ibExt50UpLbl    = na
var label ibExt100UpLbl   = na
var label ibExt50DnLbl    = na
var label ibExt100DnLbl   = na

newIBBar = inIB and not inIB[1]
if newIBBar
    ibHigh   := high
    ibLow    := low
    ibLocked := false
else if inIB
    ibHigh := math.max(nz(ibHigh, high), high)
    ibLow  := math.min(nz(ibLow, low), low)

ibJustEnded = (not inIB) and inIB[1]
if ibJustEnded
    ibLocked := true
    if showIB
        line.delete(ibHighLine)
        line.delete(ibLowLine)
        label.delete(ibHighLbl)
        label.delete(ibLowLbl)
        ibHighLine := line.new(bar_index, ibHigh, bar_index + 1, ibHigh, extend=extend.right, color=ibHighCol, width=2)
        ibLowLine  := line.new(bar_index, ibLow,  bar_index + 1, ibLow,  extend=extend.right, color=ibLowCol,  width=2)
        ibHighLbl  := label.new(bar_index, ibHigh, appendPrice("IB High", showIBPriceInput, ibHigh), style=label.style_label_left, color=color.new(ibHighCol, 80), textcolor=ibHighCol, size=labelSz)
        ibLowLbl   := label.new(bar_index, ibLow,  appendPrice("IB Low", showIBPriceInput, ibLow),  style=label.style_label_left, color=color.new(ibLowCol, 80),  textcolor=ibLowCol,  size=labelSz)
    if showIBExt
        ibRange = ibHigh - ibLow
        ext50Up  = ibHigh + ibRange * 0.5
        ext100Up = ibHigh + ibRange
        ext50Dn  = ibLow  - ibRange * 0.5
        ext100Dn = ibLow  - ibRange
        line.delete(ibExt50UpLine)
        line.delete(ibExt100UpLine)
        line.delete(ibExt50DnLine)
        line.delete(ibExt100DnLine)
        label.delete(ibExt50UpLbl)
        label.delete(ibExt100UpLbl)
        label.delete(ibExt50DnLbl)
        label.delete(ibExt100DnLbl)
        ibExt50UpLine   := line.new(bar_index, ext50Up,  bar_index + 1, ext50Up,  extend=extend.right, color=ibExtCol, width=1, style=line.style_dashed)
        ibExt100UpLine  := line.new(bar_index, ext100Up, bar_index + 1, ext100Up, extend=extend.right, color=ibExtCol, width=1, style=line.style_dashed)
        ibExt50DnLine   := line.new(bar_index, ext50Dn,  bar_index + 1, ext50Dn,  extend=extend.right, color=ibExtCol, width=1, style=line.style_dashed)
        ibExt100DnLine  := line.new(bar_index, ext100Dn, bar_index + 1, ext100Dn, extend=extend.right, color=ibExtCol, width=1, style=line.style_dashed)
        ibExt50UpLbl    := label.new(bar_index, ext50Up,  appendPrice("IB +50%", showIBExtPriceInput, ext50Up),  style=label.style_label_left, color=color.new(ibExtCol, 80), textcolor=ibHighCol, size=labelSz)
        ibExt100UpLbl   := label.new(bar_index, ext100Up, appendPrice("IB +100%", showIBExtPriceInput, ext100Up), style=label.style_label_left, color=color.new(ibExtCol, 80), textcolor=ibHighCol, size=labelSz)
        ibExt50DnLbl    := label.new(bar_index, ext50Dn,  appendPrice("IB -50%", showIBExtPriceInput, ext50Dn),  style=label.style_label_left, color=color.new(ibExtCol, 80), textcolor=ibLowCol,  size=labelSz)
        ibExt100DnLbl   := label.new(bar_index, ext100Dn, appendPrice("IB -100%", showIBExtPriceInput, ext100Dn), style=label.style_label_left, color=color.new(ibExtCol, 80), textcolor=ibLowCol,  size=labelSz)

// Persistent IB extension values for signal logic
var float ibExt50Up_val  = na
var float ibExt100Up_val = na
var float ibExt50Dn_val  = na
var float ibExt100Dn_val = na
if ibJustEnded
    ibRange2 = ibHigh - ibLow
    ibExt50Up_val  := ibHigh + ibRange2 * 0.5
    ibExt100Up_val := ibHigh + ibRange2
    ibExt50Dn_val  := ibLow  - ibRange2 * 0.5
    ibExt100Dn_val := ibLow  - ibRange2

// ============================================================================
// 8 EMA
// ============================================================================
grp_ex = "Extras"
showEMA    = input.bool(true, "Show EMA", group=grp_ex)
emaLength  = input.int(8, "EMA Length", minval=1, group=grp_ex)
emaColor   = input.color(color.blue, "EMA Color", group=grp_ex)
emaWidth   = input.int(1, "EMA Line Width", minval=1, maxval=4, group=grp_ex)
showEMA2   = input.bool(true, "Show EMA 2", group=grp_ex)
emaLength2 = input.int(200, "EMA 2 Length", minval=1, group=grp_ex)
emaColor2  = input.color(color.orange, "EMA 2 Color", group=grp_ex)
emaWidth2  = input.int(2, "EMA 2 Line Width", minval=1, maxval=4, group=grp_ex)
// FIX: one shared price toggle for both EMA labels.
showEMAPriceInput = input.bool(false, "Show Price on EMA Labels", group=grp_ex)
emaVal  = ta.ema(close, emaLength)
emaVal2 = ta.ema(close, emaLength2)
plot(showEMA ? emaVal : na, title="EMA", color=emaColor, linewidth=emaWidth)
plot(showEMA2 ? emaVal2 : na, title="EMA 2", color=emaColor2, linewidth=emaWidth2)

// ============================================================================
// RIGHT-EDGE LABELS — keep labels at the end of every line
// ============================================================================

// --- Move existing line-based labels to current bar ---
if barstate.islast
    // PDH / PDL
    if showPDHL and array.size(pdHighLbls) > 0
        label.set_x(array.get(pdHighLbls, array.size(pdHighLbls) - 1), bar_index)
        label.set_x(array.get(pdLowLbls,  array.size(pdLowLbls) - 1),  bar_index)
    // PMH / PML
    if showPMHL and not na(pmHighLbl)
        label.set_x(pmHighLbl, bar_index)
        label.set_x(pmLowLbl,  bar_index)
    // ORB High / Low
    if showORB and not na(orbHighLbl)
        label.set_x(orbHighLbl, bar_index)
        label.set_x(orbLowLbl,  bar_index)
    // IB High / Low
    if showIB and not na(ibHighLbl)
        label.set_x(ibHighLbl, bar_index)
        label.set_x(ibLowLbl,  bar_index)
    // IB Extensions
    if showIBExt and not na(ibExt50UpLbl)
        label.set_x(ibExt50UpLbl,  bar_index)
        label.set_x(ibExt100UpLbl, bar_index)
        label.set_x(ibExt50DnLbl,  bar_index)
        label.set_x(ibExt100DnLbl, bar_index)

// --- Plot-based line labels (VWAP, NY VWAP, EMAs) ---
var label vwapLbl      = na
var label vwapUpLbl    = na
var label vwapDnLbl    = na
var label wVwapLbl     = na
var label wVwapUpLbl   = na
var label wVwapDnLbl   = na
var label mVwapLbl     = na
var label mVwapUpLbl   = na
var label mVwapDnLbl   = na
var label nyVwapLbl    = na
var label nyVwapUpLbl  = na
var label nyVwapDnLbl  = na
var label emaLbl       = na
var label ema2Lbl      = na

if barstate.islast
    // Daily VWAP
    if showVWAP and not na(vwapValue)
        label.delete(vwapLbl)
        vwapLbl := label.new(bar_index, vwapValue, appendPrice("Globex VWAP", showVwapPriceInput, vwapValue), style=label.style_label_left, color=color.new(vwapCol, 80), textcolor=vwapCol, size=labelSz)
    if showVWAP and showVWAPBands and not na(vwapUpper)
        label.delete(vwapUpLbl)
        label.delete(vwapDnLbl)
        vwapUpLbl := label.new(bar_index, vwapUpper, appendPrice("Globex UB", showVwapBandPriceInput, vwapUpper), style=label.style_label_left, color=color.new(vwapBandCol, 80), textcolor=vwapCol, size=labelSz)
        vwapDnLbl := label.new(bar_index, vwapLower, appendPrice("Globex LB", showVwapBandPriceInput, vwapLower), style=label.style_label_left, color=color.new(vwapBandCol, 80), textcolor=vwapCol, size=labelSz)
    // Weekly VWAP
    if showWVWAP and not na(wVwapVal)
        label.delete(wVwapLbl)
        wVwapLbl := label.new(bar_index, wVwapVal, appendPrice("Weekly VWAP", showWVwapPriceInput, wVwapVal), style=label.style_label_left, color=color.new(wVwapCol, 80), textcolor=wVwapCol, size=labelSz)
    if showWVWAP and showWVWAPBands and not na(wUpper)
        label.delete(wVwapUpLbl)
        label.delete(wVwapDnLbl)
        wVwapUpLbl := label.new(bar_index, wUpper, appendPrice("Weekly UB", showWVwapBandPriceInput, wUpper), style=label.style_label_left, color=color.new(wVwapBandCol, 80), textcolor=wVwapCol, size=labelSz)
        wVwapDnLbl := label.new(bar_index, wLower, appendPrice("Weekly LB", showWVwapBandPriceInput, wLower), style=label.style_label_left, color=color.new(wVwapBandCol, 80), textcolor=wVwapCol, size=labelSz)
    // Monthly VWAP
    if showMVWAP and not na(mVwapVal)
        label.delete(mVwapLbl)
        mVwapLbl := label.new(bar_index, mVwapVal, appendPrice("Monthly VWAP", showMVwapPriceInput, mVwapVal), style=label.style_label_left, color=color.new(mVwapCol, 80), textcolor=mVwapCol, size=labelSz)
    if showMVWAP and showMVWAPBands and not na(mUpper)
        label.delete(mVwapUpLbl)
        label.delete(mVwapDnLbl)
        mVwapUpLbl := label.new(bar_index, mUpper, appendPrice("Monthly UB", showMVwapBandPriceInput, mUpper), style=label.style_label_left, color=color.new(mVwapBandCol, 80), textcolor=mVwapCol, size=labelSz)
        mVwapDnLbl := label.new(bar_index, mLower, appendPrice("Monthly LB", showMVwapBandPriceInput, mLower), style=label.style_label_left, color=color.new(mVwapBandCol, 80), textcolor=mVwapCol, size=labelSz)
    // NY VWAP
    if showNYVWAP and not na(nyVwapVal)
        label.delete(nyVwapLbl)
        nyVwapLbl := label.new(bar_index, nyVwapVal, appendPrice("NY VWAP", showNYVwapPriceInput, nyVwapVal), style=label.style_label_left, color=color.new(nyVwapCol, 80), textcolor=nyVwapCol, size=labelSz)
    if showNYVWAP and showNYVWAPBands and not na(nyUpper2)
        label.delete(nyVwapUpLbl)
        label.delete(nyVwapDnLbl)
        nyVwapUpLbl := label.new(bar_index, nyUpper2, appendPrice("NY UB", showNYVwapBandPriceInput, nyUpper2), style=label.style_label_left, color=color.new(nyVwapBandCol, 80), textcolor=nyVwapCol, size=labelSz)
        nyVwapDnLbl := label.new(bar_index, nyLower2, appendPrice("NY LB", showNYVwapBandPriceInput, nyLower2), style=label.style_label_left, color=color.new(nyVwapBandCol, 80), textcolor=nyVwapCol, size=labelSz)
    // EMA 1
    if showEMA and not na(emaVal)
        label.delete(emaLbl)
        emaLbl := label.new(bar_index, emaVal, appendPrice("EMA " + str.tostring(emaLength), showEMAPriceInput, emaVal), style=label.style_label_left, color=color.new(emaColor, 80), textcolor=emaColor, size=labelSz)
    // EMA 2
    if showEMA2 and not na(emaVal2)
        label.delete(ema2Lbl)
        ema2Lbl := label.new(bar_index, emaVal2, appendPrice("EMA " + str.tostring(emaLength2), showEMAPriceInput, emaVal2), style=label.style_label_left, color=color.new(emaColor2, 80), textcolor=emaColor2, size=labelSz)
````
