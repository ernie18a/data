# Chinaski - Golden Blocks Radar

- url: https://www.tradingview.com/script/nfL3CFWc-Chinaski-Golden-Blocks-Radar/
- type: indicator
- pine_id: PUB;29ff1dd7b28f432aa11afa9957d0f937
- version: 1.0

## Description

[image]https://www.tradingview.com/x/Y1n3Czln/[/image]
Golden Blocks are unmitigated supply/demand order blocks that must also posses all of these three qualities: 

1. Broken structure
2. Generated imbalance (FVG) 
3. Have resting session liquidity (or PDL/PDH) right before them.

The indicator alerts when such untapped orders are being collected. It is intended as a context alert, not an automatic buy/sell signal.

The indicator also features: 
• Previous Day / Week / Month Highs and Lows
• Asia, London, and New York session highs/lows
• M5 and M15 Fair Value Gap detection
• Liquidity sweep detection
• Sweep → M5 FVG confirmation markers
• M15 FVG tap alerts with EMA bias-table agreement
• Multi-timeframe EMA bias table

With these, you may create your own alerts and strategies: For example, it can tell you to monitor the charts when an M15 bullish gap is tapped or formed during a 70% bullish trend. It can also be set up for PDL/PDH reversals.

Best used on intraday charts, especially M1–M15, with M5 as the core execution timeframe.

This indicator is a visual decision-support tool. It does not provide financial advice, guaranteed outcomes, or automatic trade recommendations. Traders should use their own risk management and confirmation process.

## Source Code

````pine
// This indicator is developed by Selçuk Akyüz 2026
// Golden Blocks with Alerts

//@version=6
indicator("Chinaski - Golden Blocks Radar", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500, dynamic_requests=true)

//=============================================================================
// CONSTANTS
//=============================================================================
BULLISH = 1
BEARISH = -1

msHour = 60 * 60 * 1000
msMin  = 60 * 1000

//=============================================================================
// GROUPS
//=============================================================================
G_FVG     = "Engine 1 — Lux-Spine FVG Boxes"
G_RAILS   = "Engine 2 — Liquidity Rails"
G_SESS    = "Engine 3 — Session Rails"
G_SWEEP   = "Engine 4 — Sweep + M5 FVG Confirmation"
G_TAP     = "Engine 5 — FVG Tap Engine"
G_EVENTS  = "Engine 6 — M5 / M15 Event Detectors"
G_ALERTS  = "Engine 7 — Master Alert Tick List"
G_TABLE   = "Engine 8 — Bias Table"
G_GOLD    = "Engine 10 — Golden Blocks"
G_STYLE   = "Style / Signal Colors"

//=============================================================================
// STYLE / SIGNAL COLORS
//=============================================================================
bullSignalColor = input.color(color.rgb(0, 180, 120), "Bull / Buy Signal Color", group=G_STYLE)
bearSignalColor = input.color(color.rgb(220, 60, 60), "Bear / Sell Signal Color", group=G_STYLE)
rawBullColor    = input.color(color.new(color.lime, 35), "Raw Bull Sweep Color", group=G_STYLE)
rawBearColor    = input.color(color.new(color.red, 35), "Raw Bear Sweep Color", group=G_STYLE)
tapMarkerColor  = input.color(color.yellow, "Relevant Tap Marker Color", group=G_STYLE)
showLevelLabels = input.bool(true, "Show Rail Labels", group=G_STYLE)

//=============================================================================
// ENGINE 1 — LUX-SPINE FVG INPUTS
//=============================================================================
showFairValueGapsInput      = input.bool(true, "Show FVG Boxes", group=G_FVG)
displayedFvgMode            = input.string("M15", "Displayed FVG Mode", options=["Chart TF", "M15", "M5"], group=G_FVG)
fairValueGapsThresholdInput = input.bool(false, "Auto Threshold", group=G_FVG)
fairValueGapsBullColorInput = input.color(color.new(#00ff68, 74), "Bullish FVG Box", group=G_FVG)
fairValueGapsBearColorInput = input.color(color.new(#ff0008, 74), "Bearish FVG Box", group=G_FVG)
fairValueGapsExtendInput    = input.int(8, "Extend FVG", minval=0, maxval=100, group=G_FVG)
deleteMitigatedFVGsInput    = input.bool(false, "Delete Mitigated FVGs", group=G_FVG)
splitFvgInput               = input.bool(false, "Lux Split FVG Into Two Halves", group=G_FVG)
maxFvgsInput                = input.int(25, "Max FVG Boxes", minval=1, maxval=250, group=G_FVG)

displayedFvgTf = displayedFvgMode == "Chart TF" ? "" : displayedFvgMode == "M15" ? "15" : "5"

//=============================================================================
// ENGINE 2 — LIQUIDITY RAIL INPUTS
//=============================================================================
lookbackHours = input.int(72, "Lookback Hours", minval=24, maxval=240, group=G_RAILS)
pivotLen      = input.int(3, "H1 Swing Strength", minval=1, maxval=20, group=G_RAILS)
extendHours   = input.int(48, "Liquidity Line Extend Hours", minval=6, maxval=240, group=G_RAILS)

showPD        = input.bool(true, "Show PDH / PDL", group=G_RAILS)
showPW        = input.bool(true, "Show PWH / PWL", group=G_RAILS)
showPM        = input.bool(false, "Show PMH / PML", group=G_RAILS)
showH1Swings  = input.bool(true, "Show H1 Swing Liquidity", group=G_RAILS)

railLabelOffset = input.int(10, "Right Tag Offset Bars", minval=1, maxval=50, group=G_RAILS)
railHistoryBars = input.int(300, "Rail History Bars", minval=50, maxval=2000, group=G_RAILS)

dailyColor   = input.color(color.rgb(41, 98, 255), "Daily Rail Color", group=G_RAILS)
weeklyColor  = input.color(color.orange, "Weekly Rail Color", group=G_RAILS)
monthlyColor = input.color(color.gray, "Monthly Rail Color", group=G_RAILS)
h1Color      = input.color(color.rgb(41, 98, 255), "H1 Swing Rail Color", group=G_RAILS)

//=============================================================================
// ENGINE 3 — SESSION INPUTS
//=============================================================================
showAsiaRails   = input.bool(true, "Show Asia H/L", group=G_SESS)
showLondonRails = input.bool(true, "Show London H/L", group=G_SESS)
showNYRails     = input.bool(false, "Show NY H/L", group=G_SESS)

sessionTz = input.string("America/New_York", "Session Timezone", options=["America/New_York", "UTC", "Europe/London", "Europe/Istanbul", "Exchange"], group=G_SESS)
asiaSession   = input.session("2000-0300", "Asia Session", group=G_SESS)
londonSession = input.session("0300-0830", "London Session", group=G_SESS)
nySession     = input.session("0830-1800", "NY Session", group=G_SESS)

asiaColor   = input.color(color.purple, "Asia Color", group=G_SESS)
londonColor = input.color(color.rgb(41, 98, 255), "London Color", group=G_SESS)
nyColor     = input.color(color.green, "NY Color", group=G_SESS)

showSessionBg = input.bool(false, "Show Session Backgrounds", group=G_SESS)

//=============================================================================
// ENGINE 4 — SWEEP + CONFIRMATION INPUTS
//=============================================================================
enableEngine4      = input.bool(true, "Enable Sweep → M5 FVG Confirmation", group=G_SWEEP)
armMinutes         = input.int(15, "M5 FVG Confirmation Window Minutes", minval=5, maxval=60, group=G_SWEEP)
showRawSweepMarks  = input.bool(false, "Show Raw Sweep Circles", group=G_SWEEP)
showEntryMarks     = input.bool(true, "Show Confirmed ! Markers", group=G_SWEEP)

usePdRailsForSweep       = input.bool(true, "Use PDH / PDL Sweeps", group=G_SWEEP)
usePwRailsForSweep       = input.bool(true, "Use PWH / PWL Sweeps", group=G_SWEEP)
usePmRailsForSweep       = input.bool(false, "Use PMH / PML Sweeps", group=G_SWEEP)
useH1RailsForSweep       = input.bool(true, "Use H1 Swing Sweeps", group=G_SWEEP)
useSessionRailsForSweep  = input.bool(true, "Use Session Sweeps", group=G_SWEEP)

//=============================================================================
// ENGINE 5 — TAP ENGINE INPUTS
//=============================================================================
enableTapEngineInput       = input.bool(true, "Enable Displayed FVG Tap Engine", group=G_TAP)
showTapMarkersInput        = input.bool(false, "Show Generic FVG Tap Markers", group=G_TAP)
showM15PagerMarkersInput   = input.bool(true, "Show M15 Tap + Table ! Markers", group=G_TAP)
tapOnlyOnceInput           = input.bool(true, "Alert Once Per FVG", group=G_TAP)
tapMode                    = input.string("Stop + Fade", "Tapped FVG Behavior", options=["Stop + Fade", "Delete", "Fade + Extend"], group=G_TAP)
tapBoxColor                = input.color(color.new(color.gray, 92), "Tapped Box Fade Color", group=G_TAP)
tapBorderColorInput        = input.color(color.yellow, "Tapped FVG Border Color", group=G_TAP)

//=============================================================================
// ENGINE 6 — EVENT DETECTORS
//=============================================================================
enableM5Events  = input.bool(true, "Detect M5 FVG Events", group=G_EVENTS)
enableM15Events = input.bool(true, "Detect M15 FVG Events", group=G_EVENTS)

//=============================================================================
// ENGINE 7 — MASTER ALERT TICK LIST
//=============================================================================
useMasterAlerts = input.bool(true, "Use Master alert() System", group=G_ALERTS)

alBullSweep = input.bool(false, "Bullish Liquidity Sweep", group=G_ALERTS)
alBearSweep = input.bool(false, "Bearish Liquidity Sweep", group=G_ALERTS)

alBuyEntry  = input.bool(true, "BUY: Sweep + M5 FVG", group=G_ALERTS)
alSellEntry = input.bool(true, "SELL: Sweep + M5 FVG", group=G_ALERTS)

alLuxBullFormed = input.bool(false, "Displayed Bullish FVG Formed", group=G_ALERTS)
alLuxBearFormed = input.bool(false, "Displayed Bearish FVG Formed", group=G_ALERTS)
alLuxBullTapped = input.bool(false, "Displayed Bullish FVG Tapped", group=G_ALERTS)
alLuxBearTapped = input.bool(false, "Displayed Bearish FVG Tapped", group=G_ALERTS)

alM15BullFormed = input.bool(false, "M15 Bullish FVG Formed", group=G_ALERTS)
alM15BearFormed = input.bool(false, "M15 Bearish FVG Formed", group=G_ALERTS)

alM5BullFormed = input.bool(false, "M5 Bullish FVG Formed", group=G_ALERTS)
alM5BearFormed = input.bool(false, "M5 Bearish FVG Formed", group=G_ALERTS)

alM15BullTapBullTable = input.bool(true, "M15 Bullish FVG Tapped + Bullish Table", group=G_ALERTS)
alM15BearTapBearTable = input.bool(true, "M15 Bearish FVG Tapped + Bearish Table", group=G_ALERTS)

alGoldenBlockTapped = input.bool(true, "Golden Block Tapped", group=G_ALERTS)

alAnyFormed = input.bool(false, "Any FVG Formed", group=G_ALERTS)
alAnyTapped = input.bool(false, "Any FVG Tapped", group=G_ALERTS)

//=============================================================================
// ENGINE 8 — BIAS TABLE
//=============================================================================
showBiasTable = input.bool(true, "Show Timeframe Bias Table", group=G_TABLE)
tableMode     = input.string("Intraday", "Bias Table Mode", options=["Intraday", "Swing"], group=G_TABLE)
emaLen        = input.int(100, "Bias EMA Length", minval=10, maxval=300, group=G_TABLE)

//=============================================================================
// ENGINE 10 — GOLDEN BLOCKS INPUTS
//=============================================================================
enableGoldenBlocks = input.bool(true, "Show Golden Blocks", group=G_GOLD)
gbDetectionMode = input.string("Session-Owned Displacement OB", "Detection Mode",
     options=["Strict Inducement OB", "Session-Owned Displacement OB"], group=G_GOLD)
gbSwingLen    = input.int(20, "Swing Detection Length", minval=5, group=G_GOLD)
gbInternalLen = input.int(5, "Internal Detection Length", minval=2, group=G_GOLD)
gbFvgWindow   = input.int(5, "FVG Window After OB", minval=2, maxval=20, group=G_GOLD)
gbRequireTarget = input.bool(true, "Require Opposite Liquidity Target", group=G_GOLD)
gbMitigationMode = input.string("Wick Touch", "Mitigation Mode",
     options=["Wick Touch", "Close Into Zone", "Full Invalidation"], group=G_GOLD)
gbShowNonGolden = input.bool(false, "Show Non-Golden Displacement OBs", group=G_GOLD)
gbMaxShown = input.int(30, "Max Golden Blocks Shown", minval=5, maxval=100, group=G_GOLD)
gbBullColor = input.color(color.new(#089981, 85), "Bullish OB Color", group=G_GOLD)
gbBearColor = input.color(color.new(#f23645, 85), "Bearish OB Color", group=G_GOLD)
gbGoldColor = input.color(color.new(color.yellow, 78), "Golden Block Color", group=G_GOLD)
gbBorderTransparency = input.int(35, "Border Transparency", minval=0, maxval=100, group=G_GOLD)
gbObMult = input.float(0.50, "Buffer: OB Height Multiplier", minval=0.0, step=0.05, group=G_GOLD)
gbSessionMult = input.float(0.03, "Buffer: Session Range %", minval=0.0, step=0.01, group=G_GOLD)
gbAtrMult = input.float(0.10, "Buffer: ATR Multiplier", minval=0.0, step=0.01, group=G_GOLD)
gbAtrLen = input.int(14, "ATR Length", minval=1, group=G_GOLD)

//=============================================================================
// TIME / MESSAGE HELPERS
//=============================================================================
leftLimit = timenow - lookbackHours * msHour
rightTime = time + extendHours * msHour

selectedTz = sessionTz == "Exchange" ? syminfo.timezone : sessionTz

msg(_event) =>
    syminfo.ticker + " | " + _event + " | chart_tf: " + timeframe.period + " | price: " + str.tostring(close, format.mintick)

msgTf(_event, _signalTf) =>
    syminfo.ticker + " | " + _event + " | chart_tf: " + timeframe.period + " | signal_tf: " + _signalTf + " | price: " + str.tostring(close, format.mintick)

isInSession(_sess) =>
    not na(time(timeframe.period, _sess, selectedTz))

displayedSignalTf = displayedFvgTf == "" ? timeframe.period : displayedFvgTf

//=============================================================================
// ENGINE 1 — LUX-SPINE FVG BOXES
//=============================================================================
type fairValueGap
    float top
    float bottom
    int bias
    int bornBar
    bool tapped
    box topBox
    box bottomBox

var array<fairValueGap> fairValueGaps = array.new<fairValueGap>()

fairValueGapBox(leftTime, rightTimeFvg, topPrice, bottomPrice, boxColor) =>
    box.new(
         chart.point.new(leftTime, na, topPrice),
         chart.point.new(rightTimeFvg + fairValueGapsExtendInput * nz(time - time[1], msMin), na, bottomPrice),
         xloc=xloc.bar_time,
         border_color=boxColor,
         bgcolor=boxColor,
         force_overlay=true)

safeDeleteBox(box boxId) =>
    if not na(boxId)
        box.delete(boxId)
    true

deleteFairValueGaps() =>
    if deleteMitigatedFVGsInput and array.size(fairValueGaps) > 0
        i = array.size(fairValueGaps) - 1
        while i >= 0
            eachFairValueGap = array.get(fairValueGaps, i)
            filledBull = low < eachFairValueGap.bottom and eachFairValueGap.bias == BULLISH
            filledBear = high > eachFairValueGap.top and eachFairValueGap.bias == BEARISH

            if filledBull or filledBear
                safeDeleteBox(eachFairValueGap.topBox)
                safeDeleteBox(eachFairValueGap.bottomBox)
                array.remove(fairValueGaps, i)
            i -= 1
    true

trimFairValueGaps() =>
    while array.size(fairValueGaps) > maxFvgsInput
        old = array.pop(fairValueGaps)
        safeDeleteBox(old.topBox)
        safeDeleteBox(old.bottomBox)
    true

drawFairValueGaps() =>
    bool bullishFairValueGap = false
    bool bearishFairValueGap = false

    [lastClose, lastOpen, lastTime, currentHigh, currentLow, currentTime, last2High, last2Low] =
         request.security(
             syminfo.tickerid,
             displayedFvgTf,
             [close[1], open[1], time[1], high, low, time, high[2], low[2]],
             lookahead=barmerge.lookahead_on)

    barDeltaPercent = (lastClose - lastOpen) / (lastOpen * 100)
    newTimeframe = timeframe.change(displayedFvgTf)
    threshold = fairValueGapsThresholdInput ? ta.cum(math.abs(newTimeframe ? barDeltaPercent : 0)) / math.max(bar_index, 1) * 2 : 0

    bullishFairValueGap := showFairValueGapsInput and currentLow > last2High and lastClose > last2High and barDeltaPercent > threshold and newTimeframe
    bearishFairValueGap := showFairValueGapsInput and currentHigh < last2Low and lastClose < last2Low and -barDeltaPercent > threshold and newTimeframe

    if bullishFairValueGap
        mid = math.avg(currentLow, last2High)

        if splitFvgInput
            topBox = fairValueGapBox(lastTime, currentTime, currentLow, mid, fairValueGapsBullColorInput)
            botBox = fairValueGapBox(lastTime, currentTime, mid, last2High, fairValueGapsBullColorInput)
            array.unshift(fairValueGaps, fairValueGap.new(currentLow, last2High, BULLISH, bar_index, false, topBox, botBox))
        else
            oneBox = fairValueGapBox(lastTime, currentTime, currentLow, last2High, fairValueGapsBullColorInput)
            array.unshift(fairValueGaps, fairValueGap.new(currentLow, last2High, BULLISH, bar_index, false, oneBox, na))

    if bearishFairValueGap
        mid = math.avg(currentHigh, last2Low)

        if splitFvgInput
            topBox = fairValueGapBox(lastTime, currentTime, currentHigh, mid, fairValueGapsBearColorInput)
            botBox = fairValueGapBox(lastTime, currentTime, mid, last2Low, fairValueGapsBearColorInput)
            array.unshift(fairValueGaps, fairValueGap.new(currentHigh, last2Low, BEARISH, bar_index, false, topBox, botBox))
        else
            oneBox = fairValueGapBox(lastTime, currentTime, currentHigh, last2Low, fairValueGapsBearColorInput)
            array.unshift(fairValueGaps, fairValueGap.new(currentHigh, last2Low, BEARISH, bar_index, false, oneBox, na))

    [bullishFairValueGap, bearishFairValueGap]

//=============================================================================
// ENGINE 5 — TAP ENGINE FOR DISPLAYED FVG BOXES
//=============================================================================
processFvgTaps() =>
    bool bullTap = false
    bool bearTap = false

    if enableTapEngineInput and array.size(fairValueGaps) > 0
        i = array.size(fairValueGaps) - 1
        while i >= 0
            each = array.get(fairValueGaps, i)

            overlaps = bar_index > each.bornBar and high >= each.bottom and low <= each.top
            allowed = overlaps and (not each.tapped or not tapOnlyOnceInput)

            if allowed
                if each.bias == BULLISH
                    bullTap := true
                if each.bias == BEARISH
                    bearTap := true

                if tapMode == "Delete"
                    safeDeleteBox(each.topBox)
                    safeDeleteBox(each.bottomBox)
                    array.remove(fairValueGaps, i)
                else
                    if not na(each.topBox)
                        box.set_border_color(each.topBox, tapBorderColorInput)
                        box.set_bgcolor(each.topBox, tapBoxColor)
                        if tapMode == "Stop + Fade"
                            box.set_right(each.topBox, time)

                    if not na(each.bottomBox)
                        box.set_border_color(each.bottomBox, tapBorderColorInput)
                        box.set_bgcolor(each.bottomBox, tapBoxColor)
                        if tapMode == "Stop + Fade"
                            box.set_right(each.bottomBox, time)

                    each.tapped := true
                    array.set(fairValueGaps, i, each)

            i -= 1

    [bullTap, bearTap]

//=============================================================================
// ENGINE 2 — LIQUIDITY MAP
//=============================================================================
[pdh, pdl] = request.security(syminfo.tickerid, "D", [high[1], low[1]], lookahead=barmerge.lookahead_off)
[pwh, pwl] = request.security(syminfo.tickerid, "W", [high[1], low[1]], lookahead=barmerge.lookahead_off)
[pmh, pml] = request.security(syminfo.tickerid, "M", [high[1], low[1]], lookahead=barmerge.lookahead_off)

[h1PH, h1PHTime] = request.security(syminfo.tickerid, "60", [ta.pivothigh(high, pivotLen, pivotLen), time[pivotLen]], lookahead=barmerge.lookahead_off)
[h1PL, h1PLTime] = request.security(syminfo.tickerid, "60", [ta.pivotlow(low, pivotLen, pivotLen), time[pivotLen]], lookahead=barmerge.lookahead_off)

var array<float> swingPrices = array.new_float()
var array<int>   swingTimes  = array.new_int()
var array<int>   swingBiases = array.new_int()

cleanupSwings() =>
    i = array.size(swingTimes) - 1
    while i >= 0
        if array.get(swingTimes, i) < leftLimit
            array.remove(swingTimes, i)
            array.remove(swingPrices, i)
            array.remove(swingBiases, i)
        i -= 1
    true

var int lastPHTime = na
var int lastPLTime = na

if showH1Swings and not na(h1PH) and h1PHTime >= leftLimit and h1PHTime != lastPHTime
    array.push(swingPrices, h1PH)
    array.push(swingTimes, h1PHTime)
    array.push(swingBiases, +1)
    lastPHTime := h1PHTime

if showH1Swings and not na(h1PL) and h1PLTime >= leftLimit and h1PLTime != lastPLTime
    array.push(swingPrices, h1PL)
    array.push(swingTimes, h1PLTime)
    array.push(swingBiases, -1)
    lastPLTime := h1PLTime

cleanupSwings()

railStartIndex() =>
    math.max(0, bar_index - railHistoryBars)

var array<line>  lvlLines  = array.new_line()
var array<label> lvlLabels = array.new_label()

clearLevels() =>
    while array.size(lvlLines) > 0
        line.delete(array.pop(lvlLines))
    while array.size(lvlLabels) > 0
        label.delete(array.pop(lvlLabels))
    true

drawRailIndex(_x1, _price, _txt, _col, _style, _width) =>
    x2 = bar_index + railLabelOffset
    ln = line.new(_x1, _price, x2, _price, xloc=xloc.bar_index, extend=extend.none, color=_col, style=_style, width=_width)
    array.push(lvlLines, ln)

    if showLevelLabels
        lb = label.new(x2, _price, _txt, xloc=xloc.bar_index, style=label.style_label_left, textcolor=_col, color=color.new(_col, 88), size=size.small)
        array.push(lvlLabels, lb)
    true

if barstate.islast
    clearLevels()

    rs = railStartIndex()

    if showPD
        drawRailIndex(rs, pdh, "PDH", dailyColor, line.style_solid, 1)
        drawRailIndex(rs, pdl, "PDL", dailyColor, line.style_solid, 1)

    if showPW
        drawRailIndex(rs, pwh, "PWH", weeklyColor, line.style_solid, 1)
        drawRailIndex(rs, pwl, "PWL", weeklyColor, line.style_dashed, 1)

    if showPM
        drawRailIndex(rs, pmh, "PMH", monthlyColor, line.style_solid, 1)
        drawRailIndex(rs, pml, "PML", monthlyColor, line.style_dashed, 1)

    if showH1Swings and array.size(swingPrices) > 0
        for i = 0 to array.size(swingPrices) - 1
            txt = array.get(swingBiases, i) == +1 ? "H1 H" : "H1 L"
            drawRailIndex(rs, array.get(swingPrices, i), txt, h1Color, line.style_dotted, 1)

//=============================================================================
// ENGINE 3 — SESSION RAILS
//=============================================================================
var float asiaHigh = na
var float asiaLow = na
var int asiaHighBar = na
var int asiaLowBar = na
var bool asiaActive = false
var line asiaHighLine = na
var line asiaLowLine = na
var label asiaHighLabel = na
var label asiaLowLabel = na

var float londonHigh = na
var float londonLow = na
var int londonHighBar = na
var int londonLowBar = na
var bool londonActive = false
var line londonHighLine = na
var line londonLowLine = na
var label londonHighLabel = na
var label londonLowLabel = na

var float nyHigh = na
var float nyLow = na
var int nyHighBar = na
var int nyLowBar = na
var bool nyActive = false
var line nyHighLine = na
var line nyLowLine = na
var label nyHighLabel = na
var label nyLowLabel = na

rightTagX = bar_index + railLabelOffset

// Asia
if isInSession(asiaSession)
    if not asiaActive
        if not na(asiaHighLine)
            line.delete(asiaHighLine)
        if not na(asiaLowLine)
            line.delete(asiaLowLine)
        if not na(asiaHighLabel)
            label.delete(asiaHighLabel)
        if not na(asiaLowLabel)
            label.delete(asiaLowLabel)

        asiaHigh := high
        asiaLow := low
        asiaHighBar := bar_index
        asiaLowBar := bar_index
        asiaActive := true

        if showAsiaRails
            asiaHighLine := line.new(asiaHighBar, asiaHigh, rightTagX, asiaHigh, xloc=xloc.bar_index, color=asiaColor, style=line.style_solid, width=1)
            asiaLowLine := line.new(asiaLowBar, asiaLow, rightTagX, asiaLow, xloc=xloc.bar_index, color=asiaColor, style=line.style_dashed, width=1)
            if showLevelLabels
                asiaHighLabel := label.new(rightTagX, asiaHigh, "Asia H", xloc=xloc.bar_index, style=label.style_label_left, textcolor=asiaColor, color=color.new(asiaColor, 88), size=size.small)
                asiaLowLabel := label.new(rightTagX, asiaLow, "Asia L", xloc=xloc.bar_index, style=label.style_label_left, textcolor=asiaColor, color=color.new(asiaColor, 88), size=size.small)
    else
        if high > asiaHigh
            asiaHigh := high
            asiaHighBar := bar_index
        if low < asiaLow
            asiaLow := low
            asiaLowBar := bar_index
else
    asiaActive := false

if showAsiaRails
    if not na(asiaHighLine)
        line.set_xy1(asiaHighLine, asiaHighBar, asiaHigh)
        line.set_xy2(asiaHighLine, rightTagX, asiaHigh)
    if not na(asiaLowLine)
        line.set_xy1(asiaLowLine, asiaLowBar, asiaLow)
        line.set_xy2(asiaLowLine, rightTagX, asiaLow)
    if showLevelLabels and not na(asiaHighLabel)
        label.set_xy(asiaHighLabel, rightTagX, asiaHigh)
    if showLevelLabels and not na(asiaLowLabel)
        label.set_xy(asiaLowLabel, rightTagX, asiaLow)

// London
if isInSession(londonSession)
    if not londonActive
        if not na(londonHighLine)
            line.delete(londonHighLine)
        if not na(londonLowLine)
            line.delete(londonLowLine)
        if not na(londonHighLabel)
            label.delete(londonHighLabel)
        if not na(londonLowLabel)
            label.delete(londonLowLabel)

        londonHigh := high
        londonLow := low
        londonHighBar := bar_index
        londonLowBar := bar_index
        londonActive := true

        if showLondonRails
            londonHighLine := line.new(londonHighBar, londonHigh, rightTagX, londonHigh, xloc=xloc.bar_index, color=londonColor, style=line.style_solid, width=1)
            londonLowLine := line.new(londonLowBar, londonLow, rightTagX, londonLow, xloc=xloc.bar_index, color=londonColor, style=line.style_dashed, width=1)
            if showLevelLabels
                londonHighLabel := label.new(rightTagX, londonHigh, "London H", xloc=xloc.bar_index, style=label.style_label_left, textcolor=londonColor, color=color.new(londonColor, 88), size=size.small)
                londonLowLabel := label.new(rightTagX, londonLow, "London L", xloc=xloc.bar_index, style=label.style_label_left, textcolor=londonColor, color=color.new(londonColor, 88), size=size.small)
    else
        if high > londonHigh
            londonHigh := high
            londonHighBar := bar_index
        if low < londonLow
            londonLow := low
            londonLowBar := bar_index
else
    londonActive := false

if showLondonRails
    if not na(londonHighLine)
        line.set_xy1(londonHighLine, londonHighBar, londonHigh)
        line.set_xy2(londonHighLine, rightTagX, londonHigh)
    if not na(londonLowLine)
        line.set_xy1(londonLowLine, londonLowBar, londonLow)
        line.set_xy2(londonLowLine, rightTagX, londonLow)
    if showLevelLabels and not na(londonHighLabel)
        label.set_xy(londonHighLabel, rightTagX, londonHigh)
    if showLevelLabels and not na(londonLowLabel)
        label.set_xy(londonLowLabel, rightTagX, londonLow)

// New York
if isInSession(nySession)
    if not nyActive
        if not na(nyHighLine)
            line.delete(nyHighLine)
        if not na(nyLowLine)
            line.delete(nyLowLine)
        if not na(nyHighLabel)
            label.delete(nyHighLabel)
        if not na(nyLowLabel)
            label.delete(nyLowLabel)

        nyHigh := high
        nyLow := low
        nyHighBar := bar_index
        nyLowBar := bar_index
        nyActive := true

        if showNYRails
            nyHighLine := line.new(nyHighBar, nyHigh, rightTagX, nyHigh, xloc=xloc.bar_index, color=nyColor, style=line.style_solid, width=1)
            nyLowLine := line.new(nyLowBar, nyLow, rightTagX, nyLow, xloc=xloc.bar_index, color=nyColor, style=line.style_dashed, width=1)
            if showLevelLabels
                nyHighLabel := label.new(rightTagX, nyHigh, "NY H", xloc=xloc.bar_index, style=label.style_label_left, textcolor=nyColor, color=color.new(nyColor, 88), size=size.small)
                nyLowLabel := label.new(rightTagX, nyLow, "NY L", xloc=xloc.bar_index, style=label.style_label_left, textcolor=nyColor, color=color.new(nyColor, 88), size=size.small)
    else
        if high > nyHigh
            nyHigh := high
            nyHighBar := bar_index
        if low < nyLow
            nyLow := low
            nyLowBar := bar_index
else
    nyActive := false

if showNYRails
    if not na(nyHighLine)
        line.set_xy1(nyHighLine, nyHighBar, nyHigh)
        line.set_xy2(nyHighLine, rightTagX, nyHigh)
    if not na(nyLowLine)
        line.set_xy1(nyLowLine, nyLowBar, nyLow)
        line.set_xy2(nyLowLine, rightTagX, nyLow)
    if showLevelLabels and not na(nyHighLabel)
        label.set_xy(nyHighLabel, rightTagX, nyHigh)
    if showLevelLabels and not na(nyLowLabel)
        label.set_xy(nyLowLabel, rightTagX, nyLow)

bgcolor(showSessionBg and isInSession(asiaSession) ? color.new(asiaColor, 95) : na)
bgcolor(showSessionBg and isInSession(londonSession) ? color.new(londonColor, 95) : na)
bgcolor(showSessionBg and isInSession(nySession) ? color.new(nyColor, 95) : na)

//=============================================================================
// ENGINE 10 — GOLDEN BLOCKS
// Session-owned displacement OBs. Isolated tap alert; no interaction with other engines.
//=============================================================================
gbAtr = ta.atr(gbAtrLen)

max_bars_back(high, 2000)
max_bars_back(low, 2000)
max_bars_back(close, 2000)
max_bars_back(open, 2000)

var int gbTrend = 0
var int gbITrend = 0

var float gbTopY = 0.0
var int gbTopX = 0
var float gbBtmY = 0.0
var int gbBtmX = 0
var float gbITopY = 0.0
var int gbITopX = 0
var float gbIBtmY = 0.0
var int gbIBtmX = 0

var array<float> gbTops  = array.new_float()
var array<float> gbBtms  = array.new_float()
var array<int>   gbLefts = array.new_int()
var array<int>   gbTypes = array.new_int()
var array<box>   gbBoxes = array.new_box()

gbSwings(len)=>
    var os = 0
    u = ta.highest(len)
    l = ta.lowest(len)
    os := high[len] > u ? 0 : low[len] < l ? 1 : os[1]
    [os == 0 and os[1] != 0 ? high[len] : 0,
     os == 1 and os[1] != 1 ? low[len] : 0]

gbBrokeAfterIdm(isBull, idmOff, breakLevel)=>
    bool broke = false
    if idmOff > 0 and not na(breakLevel)
        for r = 0 to idmOff - 1
            if isBull and close[r] > breakLevel
                broke := true
                break
            if not isBull and close[r] < breakLevel
                broke := true
                break
    broke

gbBuffer(obTop, obBtm, sH, sL)=>
    obH = math.abs(obTop - obBtm)
    sRange = not na(sH) and not na(sL) ? math.abs(sH - sL) : 0.0
    math.max(math.max(obH * gbObMult, sRange * gbSessionMult), gbAtr * gbAtrMult)

gbOverlap(obTop, obBtm, rail, buffer)=>
    not na(rail) and obBtm <= rail + buffer and obTop >= rail - buffer

gbOwnerDir(typ, obTop, obBtm)=>
    string owner = ""

    bAsia = gbBuffer(obTop, obBtm, asiaHigh, asiaLow)
    bLon  = gbBuffer(obTop, obBtm, londonHigh, londonLow)
    bNY   = gbBuffer(obTop, obBtm, nyHigh, nyLow)

    if typ == BEARISH
        if gbOverlap(obTop, obBtm, asiaHigh, bAsia)
            owner := "Asia H"
        else if gbOverlap(obTop, obBtm, londonHigh, bLon)
            owner := "London H"
        else if gbOverlap(obTop, obBtm, nyHigh, bNY)
            owner := "NY H"
    else
        if gbOverlap(obTop, obBtm, asiaLow, bAsia)
            owner := "Asia L"
        else if gbOverlap(obTop, obBtm, londonLow, bLon)
            owner := "London L"
        else if gbOverlap(obTop, obBtm, nyLow, bNY)
            owner := "NY L"

    owner

gbHasTargetLiq(typ, obTop, obBtm)=>
    bearTarget = (not na(asiaLow) and asiaLow < obBtm) or (not na(londonLow) and londonLow < obBtm) or (not na(nyLow) and nyLow < obBtm)
    bullTarget = (not na(asiaHigh) and asiaHigh > obTop) or (not na(londonHigh) and londonHigh > obTop) or (not na(nyHigh) and nyHigh > obTop)
    typ == BEARISH ? bearTarget : bullTarget

gbMitigated(typ, obTop, obBtm, h, l, c)=>
    wickTouch     = h >= obBtm and l <= obTop
    closeIntoZone = c <= obTop and c >= obBtm
    fullInvalid   = (typ == BULLISH and l < obBtm) or (typ == BEARISH and h > obTop)

    gbMitigationMode == "Wick Touch" ? wickTouch :
     gbMitigationMode == "Close Into Zone" ? closeIntoZone :
     fullInvalid

gbFindFvgStep(isBull, off, win)=>
    int found = na
    maxStep = math.min(win, off)

    if maxStep >= 2
        for step = 2 to maxStep
            conf = off - step
            gap = isBull ? low[conf] > high[conf + 2] : high[conf] < low[conf + 2]
            if gap
                found := step
                break

    found

gbFindLiquidityOb(isBull, startIdx, endIdx, breakLevel)=>
    sIdx = math.max(0, startIdx)
    eIdx = math.max(sIdx, endIdx)

    for i = sIdx to eIdx
        off = bar_index - i

        if off < 3 or off > 1990
            continue

        typ = isBull ? BULLISH : BEARISH
        isOpp = isBull ? close[off] < open[off] : close[off] > open[off]

        int fvgStep = na

        if gbDetectionMode == "Strict Inducement OB"
            immediateFvg = isBull ? low[off - 2] > high[off] : high[off - 2] < low[off]
            if immediateFvg
                fvgStep := 2
        else
            fvgStep := gbFindFvgStep(isBull, off, gbFvgWindow)

        fvgOk = not na(fvgStep)

        if isOpp and fvgOk
            obTop = high[off]
            obBtm = low[off]

            bool qualifies = false

            if gbDetectionMode == "Strict Inducement OB"
                bool hasIdm = false

                for k = 1 to off - 2
                    checkOff = off - k

                    if isBull
                        localIdmLow = low[checkOff] < low[checkOff + 1] and low[checkOff] < low[checkOff - 1]
                        if localIdmLow and gbBrokeAfterIdm(true, checkOff, breakLevel)
                            hasIdm := true
                            break
                    else
                        localIdmHigh = high[checkOff] > high[checkOff + 1] and high[checkOff] > high[checkOff - 1]
                        if localIdmHigh and gbBrokeAfterIdm(false, checkOff, breakLevel)
                            hasIdm := true
                            break

                qualifies := hasIdm
            else
                owner = gbOwnerDir(typ, obTop, obBtm)
                targetOk = gbRequireTarget ? gbHasTargetLiq(typ, obTop, obBtm) : true
                qualifies := owner != "" and targetOk

            if qualifies
                isHit = false
                startM = fvgStep + 1

                if off >= startM
                    for m = startM to off
                        if gbMitigated(typ, obTop, obBtm, high[off - m], low[off - m], close[off - m])
                            isHit := true
                            break

                if not isHit
                    isNew = true

                    if array.size(gbLefts) > 0
                        for j = 0 to math.min(10, array.size(gbLefts) - 1)
                            if array.get(gbLefts, j) == time[off]
                                isNew := false
                                break

                    if isNew
                        array.unshift(gbTops, obTop)
                        array.unshift(gbBtms, obBtm)
                        array.unshift(gbLefts, time[off])
                        array.unshift(gbTypes, typ)

                        if array.size(gbTypes) > 120
                            array.pop(gbTops)
                            array.pop(gbBtms)
                            array.pop(gbLefts)
                            array.pop(gbTypes)

[gbTpP, gbBpP] = gbSwings(gbSwingLen)
[gbITpP, gbIBpP] = gbSwings(gbInternalLen)

gbTapped = false
gbBullTapped = false
gbBearTapped = false
gbTappedOwner = ""
gbTappedDir = ""

if enableGoldenBlocks
    if gbTpP != 0
        gbTopY := gbTpP
        gbTopX := bar_index - gbSwingLen

    if gbITpP != 0
        gbITopY := gbITpP
        gbITopX := bar_index - gbInternalLen

    if gbBpP != 0
        gbBtmY := gbBpP
        gbBtmX := bar_index - gbSwingLen

    if gbIBpP != 0
        gbIBtmY := gbIBpP
        gbIBtmX := bar_index - gbInternalLen

    if gbITopY != 0 and ta.crossover(close, gbITopY)
        gbFindLiquidityOb(true, gbIBtmX, bar_index, gbITopY)
        gbITrend := BULLISH

    if gbTopY != 0 and ta.crossover(close, gbTopY)
        gbFindLiquidityOb(true, gbBtmX, bar_index, gbTopY)
        gbTrend := BULLISH

    if gbIBtmY != 0 and ta.crossunder(close, gbIBtmY)
        gbFindLiquidityOb(false, gbITopX, bar_index, gbIBtmY)
        gbITrend := BEARISH

    if gbBtmY != 0 and ta.crossunder(close, gbBtmY)
        gbFindLiquidityOb(false, gbTopX, bar_index, gbBtmY)
        gbTrend := BEARISH

    if array.size(gbTypes) > 0
        for i = array.size(gbTypes) - 1 to 0
            typ = array.get(gbTypes, i)
            obTop = array.get(gbTops, i)
            obBtm = array.get(gbBtms, i)
            ownerLive = gbOwnerDir(typ, obTop, obBtm)
            targetLiveOk = gbRequireTarget ? gbHasTargetLiq(typ, obTop, obBtm) : true
            isLiveGold = ownerLive != "" and targetLiveOk

            if gbMitigated(typ, obTop, obBtm, high, low, close)
                if isLiveGold
                    gbTapped := true
                    gbBullTapped := typ == BULLISH
                    gbBearTapped := typ == BEARISH
                    gbTappedOwner := ownerLive
                    gbTappedDir := typ == BULLISH ? "Bullish" : "Bearish"

                array.remove(gbTops, i)
                array.remove(gbBtms, i)
                array.remove(gbLefts, i)
                array.remove(gbTypes, i)

if barstate.isfirst
    for i = 0 to gbMaxShown - 1
        array.push(gbBoxes, box.new(na, na, na, na, xloc=xloc.bar_time))

if barstate.islast
    gbCurrSize = array.size(gbTypes)

    for i = 0 to gbMaxShown - 1
        b = array.get(gbBoxes, i)

        if enableGoldenBlocks and i < gbCurrSize
            obTop = array.get(gbTops, i)
            obBtm = array.get(gbBtms, i)
            typ = array.get(gbTypes, i)

            owner = gbOwnerDir(typ, obTop, obBtm)
            targetOk = gbRequireTarget ? gbHasTargetLiq(typ, obTop, obBtm) : true
            isGold = owner != "" and targetOk

            shouldShow = isGold or gbShowNonGolden

            if shouldShow
                c = isGold ? gbGoldColor : typ == BULLISH ? gbBullColor : gbBearColor
                txt = isGold ? owner + " Golden Block" : gbDetectionMode == "Strict Inducement OB" ? "Inducement OB" : "Displacement OB"

                box.set_lefttop(b, array.get(gbLefts, i), obTop)
                box.set_rightbottom(b, time, obBtm)
                box.set_extend(b, extend.right)
                box.set_bgcolor(b, c)
                box.set_border_color(b, isGold ? color.new(color.yellow, 5) : color.new(c, gbBorderTransparency))
                box.set_text(b, txt)
                box.set_text_color(b, chart.fg_color)
                box.set_text_size(b, size.tiny)
            else
                box.set_lefttop(b, na, na)
                box.set_rightbottom(b, na, na)
                box.set_extend(b, extend.none)
        else
            box.set_lefttop(b, na, na)
            box.set_rightbottom(b, na, na)
            box.set_extend(b, extend.none)

//=============================================================================
// ENGINE 6 — M5 / M15 FVG EVENT DETECTORS
//=============================================================================
[m5BullRaw, m5BearRaw, m5Time] = request.security(syminfo.tickerid, "5", [low > high[2], high < low[2], time], lookahead=barmerge.lookahead_off)

[m15BullRaw, m15BearRaw, m15Time, m15BullTop, m15BullBot, m15BearTop, m15BearBot] = request.security(syminfo.tickerid, "15", [low > high[2], high < low[2], time, low, high[2], low[2], high], lookahead=barmerge.lookahead_off)

var int lastM5BullTime = na
var int lastM5BearTime = na
var int lastM15BullTime = na
var int lastM15BearTime = na

m5BullFormed = enableM5Events and m5BullRaw and m5Time != lastM5BullTime
m5BearFormed = enableM5Events and m5BearRaw and m5Time != lastM5BearTime
m15BullFormed = enableM15Events and m15BullRaw and m15Time != lastM15BullTime
m15BearFormed = enableM15Events and m15BearRaw and m15Time != lastM15BearTime

if m5BullFormed
    lastM5BullTime := m5Time
if m5BearFormed
    lastM5BearTime := m5Time
if m15BullFormed
    lastM15BullTime := m15Time
if m15BearFormed
    lastM15BearTime := m15Time

//=============================================================================
// ENGINE 6B — INVISIBLE M15 FVG TAP TRACKER
//=============================================================================
var array<float> m15TrackTops   = array.new_float()
var array<float> m15TrackBots   = array.new_float()
var array<int>   m15TrackTimes  = array.new_int()
var array<int>   m15TrackBiases = array.new_int()
var array<bool>  m15TrackTapped = array.new_bool()

m15TrackExists(_t, _bias) =>
    exists = false
    if array.size(m15TrackTimes) > 0
        for i = 0 to array.size(m15TrackTimes) - 1
            if array.get(m15TrackTimes, i) == _t and array.get(m15TrackBiases, i) == _bias
                exists := true
    exists

if m15BullFormed and not m15TrackExists(m15Time, BULLISH)
    array.push(m15TrackTops, m15BullTop)
    array.push(m15TrackBots, m15BullBot)
    array.push(m15TrackTimes, m15Time)
    array.push(m15TrackBiases, BULLISH)
    array.push(m15TrackTapped, false)

if m15BearFormed and not m15TrackExists(m15Time, BEARISH)
    array.push(m15TrackTops, m15BearTop)
    array.push(m15TrackBots, m15BearBot)
    array.push(m15TrackTimes, m15Time)
    array.push(m15TrackBiases, BEARISH)
    array.push(m15TrackTapped, false)

m15BullTapped = false
m15BearTapped = false

if array.size(m15TrackTimes) > 0
    i = array.size(m15TrackTimes) - 1
    while i >= 0
        top = array.get(m15TrackTops, i)
        bot = array.get(m15TrackBots, i)
        born = array.get(m15TrackTimes, i)
        bias = array.get(m15TrackBiases, i)
        tapped = array.get(m15TrackTapped, i)

        expired = born < leftLimit
        touched = not tapped and time >= born + 15 * msMin and high >= bot and low <= top

        if expired
            array.remove(m15TrackTops, i)
            array.remove(m15TrackBots, i)
            array.remove(m15TrackTimes, i)
            array.remove(m15TrackBiases, i)
            array.remove(m15TrackTapped, i)
        else if touched
            array.set(m15TrackTapped, i, true)

            if bias == BULLISH
                m15BullTapped := true
            else
                m15BearTapped := true

        i -= 1

//=============================================================================
// ENGINE 4 — SWEEP ARMING + M5 FVG CONFIRMATION
//=============================================================================
bullSweepReject(_lvl) =>
    not na(_lvl) and low < _lvl and close > _lvl

bearSweepReject(_lvl) =>
    not na(_lvl) and high > _lvl and close < _lvl

storedBullSweep() =>
    found = false
    if useH1RailsForSweep and showH1Swings and array.size(swingPrices) > 0
        for i = 0 to array.size(swingPrices) - 1
            if array.get(swingBiases, i) == -1 and bullSweepReject(array.get(swingPrices, i))
                found := true
    found

storedBearSweep() =>
    found = false
    if useH1RailsForSweep and showH1Swings and array.size(swingPrices) > 0
        for i = 0 to array.size(swingPrices) - 1
            if array.get(swingBiases, i) == +1 and bearSweepReject(array.get(swingPrices, i))
                found := true
    found

bullSweepRaw =
     (usePdRailsForSweep and showPD and bullSweepReject(pdl)) or
     (usePwRailsForSweep and showPW and bullSweepReject(pwl)) or
     (usePmRailsForSweep and showPM and bullSweepReject(pml)) or
     storedBullSweep() or
     (useSessionRailsForSweep and showAsiaRails and bullSweepReject(asiaLow)) or
     (useSessionRailsForSweep and showLondonRails and bullSweepReject(londonLow)) or
     (useSessionRailsForSweep and showNYRails and bullSweepReject(nyLow))

bearSweepRaw =
     (usePdRailsForSweep and showPD and bearSweepReject(pdh)) or
     (usePwRailsForSweep and showPW and bearSweepReject(pwh)) or
     (usePmRailsForSweep and showPM and bearSweepReject(pmh)) or
     storedBearSweep() or
     (useSessionRailsForSweep and showAsiaRails and bearSweepReject(asiaHigh)) or
     (useSessionRailsForSweep and showLondonRails and bearSweepReject(londonHigh)) or
     (useSessionRailsForSweep and showNYRails and bearSweepReject(nyHigh))

bullSweep = barstate.isconfirmed and bullSweepRaw
bearSweep = barstate.isconfirmed and bearSweepRaw

var bool armedBull = false
var bool armedBear = false
var int  bullArmTime = na
var int  bearArmTime = na

if enableEngine4 and bullSweep
    armedBull := true
    bullArmTime := time

if enableEngine4 and bearSweep
    armedBear := true
    bearArmTime := time

bullValidWindow = armedBull and time <= bullArmTime + armMinutes * msMin
bearValidWindow = armedBear and time <= bearArmTime + armMinutes * msMin

bullEntryAlert = enableEngine4 and bullValidWindow and m5BullFormed
bearEntryAlert = enableEngine4 and bearValidWindow and m5BearFormed

if bullEntryAlert or (armedBull and not bullValidWindow)
    armedBull := false

if bearEntryAlert or (armedBear and not bearValidWindow)
    armedBear := false

//=============================================================================
// EXECUTION — FVG + TAP
//=============================================================================
deleteFairValueGaps()
[luxBullFVG, luxBearFVG] = drawFairValueGaps()
[luxBullTap, luxBearTap] = processFvgTaps()
trimFairValueGaps()

//=============================================================================
// ENGINE 8 — TIMEFRAME BIAS TABLE
//=============================================================================
tfBias(_tf) =>
    request.security(syminfo.tickerid, _tf, close > ta.ema(close, emaLen), lookahead=barmerge.lookahead_off)

tfName(_slot) =>
    tableMode == "Swing" ? (_slot == 0 ? "5M" : _slot == 1 ? "15M" : _slot == 2 ? "1H" : _slot == 3 ? "4H" : "D") : (_slot == 0 ? "1M" : _slot == 1 ? "3M" : _slot == 2 ? "5M" : _slot == 3 ? "15M" : "30M")

tfCode(_slot) =>
    tableMode == "Swing" ? (_slot == 0 ? "5" : _slot == 1 ? "15" : _slot == 2 ? "60" : _slot == 3 ? "240" : "D") : (_slot == 0 ? "1" : _slot == 1 ? "3" : _slot == 2 ? "5" : _slot == 3 ? "15" : "30")

bias0 = tfBias(tfCode(0))
bias1 = tfBias(tfCode(1))
bias2 = tfBias(tfCode(2))
bias3 = tfBias(tfCode(3))
bias4 = tfBias(tfCode(4))

biasBullCount = (bias0 ? 1 : 0) + (bias1 ? 1 : 0) + (bias2 ? 1 : 0) + (bias3 ? 1 : 0) + (bias4 ? 1 : 0)

tableBullish = biasBullCount >= 4
tableBearish = biasBullCount <= 1

m15BullTapBullTable = m15BullTapped and tableBullish
m15BearTapBearTable = m15BearTapped and tableBearish

var table biasTable = table.new(position.top_right, 3, 7, border_width=1)

if showBiasTable and barstate.islast
    table.cell(biasTable, 0, 0, "TF", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(biasTable, 1, 0, "BIAS", text_color=color.white, bgcolor=color.new(color.black, 0))

    for i = 0 to 4
        isBull = i == 0 ? bias0 : i == 1 ? bias1 : i == 2 ? bias2 : i == 3 ? bias3 : bias4
        txt = isBull ? "BUY" : "SELL"
        bg = isBull ? color.new(bullSignalColor, 20) : color.new(bearSignalColor, 20)

        table.cell(biasTable, 0, i + 1, tfName(i), text_color=color.white, bgcolor=color.new(color.black, 30))
        table.cell(biasTable, 1, i + 1, txt, text_color=color.white, bgcolor=bg)

    bullPct = biasBullCount / 5.0
    sellPct = 1.0 - bullPct
    gateTxt = tableBullish ? "BUY OK" : tableBearish ? "SELL OK" : "MIXED"
    gateBg = tableBullish ? color.new(bullSignalColor, 0) : tableBearish ? color.new(bearSignalColor, 0) : color.new(color.gray, 20)

    table.cell(biasTable, 0, 6, "70%", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(biasTable, 1, 6, gateTxt, text_color=color.white, bgcolor=gateBg)

    for r = 0 to 6
        table.cell(biasTable, 2, r, "        ", text_color=color.new(color.white, 100), bgcolor=color.new(color.white, 100))

//=============================================================================
// MARKERS
//=============================================================================
plotshape(showRawSweepMarks and bullSweep, title="Raw Bullish Sweep", style=shape.circle, location=location.belowbar, color=rawBullColor, text="RS", textcolor=color.white, size=size.tiny)
plotshape(showRawSweepMarks and bearSweep, title="Raw Bearish Sweep", style=shape.circle, location=location.abovebar, color=rawBearColor, text="RS", textcolor=color.white, size=size.tiny)

plotshape(showEntryMarks and bullEntryAlert, title="BUY: Sweep + M5 FVG", style=shape.labelup, location=location.belowbar, color=bullSignalColor, text="!", textcolor=color.white, size=size.small)
plotshape(showEntryMarks and bearEntryAlert, title="SELL: Sweep + M5 FVG", style=shape.labeldown, location=location.abovebar, color=bearSignalColor, text="!", textcolor=color.white, size=size.small)

// Generic TAP markers are OFF by default. The tap logic remains invisible.
plotshape(showTapMarkersInput and luxBullTap, title="Displayed Bullish FVG Tapped", style=shape.diamond, location=location.belowbar, color=tapMarkerColor, text="TAP", textcolor=color.black, size=size.tiny)
plotshape(showTapMarkersInput and luxBearTap, title="Displayed Bearish FVG Tapped", style=shape.diamond, location=location.abovebar, color=tapMarkerColor, text="TAP", textcolor=color.black, size=size.tiny)

// Relevant pager tap markers only.
plotshape(showM15PagerMarkersInput and m15BullTapBullTable, title="M15 Bull Tap + Bull Table", style=shape.labelup, location=location.belowbar, color=bullSignalColor, text="!", textcolor=color.white, size=size.small)
plotshape(showM15PagerMarkersInput and m15BearTapBearTable, title="M15 Bear Tap + Bear Table", style=shape.labeldown, location=location.abovebar, color=bearSignalColor, text="!", textcolor=color.white, size=size.small)

//=============================================================================
// ALERTCONDITIONS
//=============================================================================
alertcondition(bullSweep, "Radar Bullish Liquidity Sweep", "Radar V3.6: Bullish liquidity sweep")
alertcondition(bearSweep, "Radar Bearish Liquidity Sweep", "Radar V3.6: Bearish liquidity sweep")
alertcondition(bullEntryAlert, "Radar BUY: Sweep + M5 FVG", "Radar V3.6: BUY confirmed by sweep + M5 FVG")
alertcondition(bearEntryAlert, "Radar SELL: Sweep + M5 FVG", "Radar V3.6: SELL confirmed by sweep + M5 FVG")

alertcondition(luxBullFVG, "Displayed Bullish FVG Formed", "Radar V3.6: displayed bullish FVG formed")
alertcondition(luxBearFVG, "Displayed Bearish FVG Formed", "Radar V3.6: displayed bearish FVG formed")
alertcondition(luxBullTap, "Displayed Bullish FVG Tapped", "Radar V3.6: displayed bullish FVG tapped")
alertcondition(luxBearTap, "Displayed Bearish FVG Tapped", "Radar V3.6: displayed bearish FVG tapped")

alertcondition(m5BullFormed, "M5 Bullish FVG Formed", "Radar V3.6: M5 bullish FVG formed")
alertcondition(m5BearFormed, "M5 Bearish FVG Formed", "Radar V3.6: M5 bearish FVG formed")
alertcondition(m15BullFormed, "M15 Bullish FVG Formed", "Radar V3.6: M15 bullish FVG formed")
alertcondition(m15BearFormed, "M15 Bearish FVG Formed", "Radar V3.6: M15 bearish FVG formed")

alertcondition(m15BullTapBullTable, "M15 Bullish FVG Tapped + Bullish Table", "Radar V3.6: M15 bullish FVG tapped while table is bullish")
alertcondition(m15BearTapBearTable, "M15 Bearish FVG Tapped + Bearish Table", "Radar V3.6: M15 bearish FVG tapped while table is bearish")

alertcondition(gbTapped, "Golden Block Tapped", "Radar V3.6: Golden Block tapped")

//=============================================================================
// MASTER ALERT CALLS — USE "ANY alert() FUNCTION CALL"
//=============================================================================
anyFormed = luxBullFVG or luxBearFVG or m5BullFormed or m5BearFormed or m15BullFormed or m15BearFormed
anyTapped = luxBullTap or luxBearTap or m15BullTapped or m15BearTapped

if useMasterAlerts and alBullSweep and bullSweep
    alert(msg("Bullish Liquidity Sweep"), alert.freq_once_per_bar_close)

if useMasterAlerts and alBearSweep and bearSweep
    alert(msg("Bearish Liquidity Sweep"), alert.freq_once_per_bar_close)

if useMasterAlerts and alBuyEntry and bullEntryAlert
    alert(msgTf("BUY: Sweep + M5 FVG", "5"), alert.freq_once_per_bar)

if useMasterAlerts and alSellEntry and bearEntryAlert
    alert(msgTf("SELL: Sweep + M5 FVG", "5"), alert.freq_once_per_bar)

if useMasterAlerts and alLuxBullFormed and luxBullFVG
    alert(msgTf("Displayed Bullish FVG Formed", displayedSignalTf), alert.freq_once_per_bar_close)

if useMasterAlerts and alLuxBearFormed and luxBearFVG
    alert(msgTf("Displayed Bearish FVG Formed", displayedSignalTf), alert.freq_once_per_bar_close)

if useMasterAlerts and alLuxBullTapped and luxBullTap
    alert(msgTf("Displayed Bullish FVG Tapped", displayedSignalTf), alert.freq_once_per_bar)

if useMasterAlerts and alLuxBearTapped and luxBearTap
    alert(msgTf("Displayed Bearish FVG Tapped", displayedSignalTf), alert.freq_once_per_bar)

if useMasterAlerts and alM15BullFormed and m15BullFormed
    alert(msgTf("M15 Bullish FVG Formed", "15"), alert.freq_once_per_bar_close)

if useMasterAlerts and alM15BearFormed and m15BearFormed
    alert(msgTf("M15 Bearish FVG Formed", "15"), alert.freq_once_per_bar_close)

if useMasterAlerts and alM5BullFormed and m5BullFormed
    alert(msgTf("M5 Bullish FVG Formed", "5"), alert.freq_once_per_bar)

if useMasterAlerts and alM5BearFormed and m5BearFormed
    alert(msgTf("M5 Bearish FVG Formed", "5"), alert.freq_once_per_bar)

if useMasterAlerts and alM15BullTapBullTable and m15BullTapBullTable
    alert(msgTf("M15 Bullish FVG Tapped + Bullish Table", "15"), alert.freq_once_per_bar)

if useMasterAlerts and alM15BearTapBearTable and m15BearTapBearTable
    alert(msgTf("M15 Bearish FVG Tapped + Bearish Table", "15"), alert.freq_once_per_bar)

if useMasterAlerts and alGoldenBlockTapped and gbTapped
    alert(msg("Golden Block Tapped | owner: " + gbTappedOwner + " | direction: " + gbTappedDir), alert.freq_once_per_bar)

if useMasterAlerts and alAnyFormed and anyFormed
    alert(msgTf("Any FVG Formed", "mixed"), alert.freq_once_per_bar)

if useMasterAlerts and alAnyTapped and anyTapped
    alert(msgTf("Any FVG Tapped", "mixed"), alert.freq_once_per_bar)
````
