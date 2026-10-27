# PO3 Mmxm 

- url: https://www.tradingview.com/script/TX5gJQX5-PO3-Mmxm/
- type: indicator
- pine_id: PUB;e5c4dce1872d43d3aa06832df9912ffa
- version: 8.0

## Description

PO3 Mmxm is a range-mapping and projection tool built around Power of 3 style price-delivery logic.

The script allows traders to select a PO3 value, such as 27, 81, 243, 729, and higher expansion values, then builds a source range and forward projection boxes from that selected range. The tool is designed to help study how price may expand from a defined dealing range and how projected levels can align with midpoint, premium, discount, rebalance, and range-extreme areas.

[b]Main features:[/b]

[i]* Selectable PO3 range values
* Bullish or bearish session bias setting
* Source range projection logic
* Optional half-range projection mode
* Adjustable source range shifting
* Forward projection boxes
* Source range subdivisions using quarter or eighth levels
* Optional range high and range low zones
* Optional rebalance zones using configurable premium and discount percentages
* Optional all-level GIP zone display
* Table showing selected PO3 value, projection reference levels, target, and range extreme
* Configurable session start and projection end time[/i]

The range high and range low zones are calculated from the selected PO3 framework and projected range structure. Rebalance zones are drawn from user-defined percentage bands inside the projection boxes, allowing traders to compare current price location against premium, discount, and equilibrium-style areas.

This script is intended as a visual research and chart-mapping tool. It does not predict future price movement, does not guarantee trade outcomes, and should be used together with independent market analysis and risk management.

GIP Levels Example(S/R)
[image]https://www.tradingview.com/x/ccIx3Uxc/[/image]

Rebalance Levels Example (Rebalance/Retracement)
[image]https://www.tradingview.com/x/ElfjV3cs/[/image]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator('PO3 Mmxm Projection Framework', overlay = true, max_boxes_count = 500, max_lines_count = 200, max_labels_count = 200)

// ============================= Public Settings =============================
groupMain = '- - - - PO3 MMXM Public Settings - - - -'
groupSource = '- - - - Source Range Subdivisions - - - -'
groupGB = '- - - - GIP / Range Zones - - - -'
groupPD = '- - - - Rebalance Zones - - - -'

sessionTemplate = input.string('Auto All Sessions', 'Session Template', options = ['Asian', 'London', 'New York', 'Auto All Sessions', 'Custom'], group = groupMain, display = display.none, tooltip = 'Asian: 7PM–12AM NY. London: 2AM–5AM NY. New York: 9:30AM–5PM NY. Auto All Sessions draws Asian, London, and NY. Custom uses the custom time inputs below.')
sessionLookbackDays = input.int(3, 'Auto All Sessions Lookback Days', minval = 1, maxval = 20, group = groupMain, display = display.none, tooltip = 'Only used by Auto All Sessions. Draws sessions whose start time is within this many calendar days from the latest bar.')
showAsianRanges = input.bool(true, 'Show Asian Ranges', group = groupMain, display = display.none, tooltip = 'Enable/disable Asian PO3 ranges in Asian or Auto All Sessions mode.')
showLondonRanges = input.bool(true, 'Show London Ranges', group = groupMain, display = display.none, tooltip = 'Enable/disable London PO3 ranges in London or Auto All Sessions mode.')
showInfoTable = input.bool(false, 'Show PO3 Info Table', group = groupMain, display = display.none, tooltip = 'Toggle the upper-right PO3 info table on/off. Default is off for a cleaner chart.')
extraProjectionShift = input.string('Auto Only', 'Extra Projection Shift', options = ['Auto Only', 'Down 2', 'Down 1', 'Down 1/2', 'Up 1/2', 'Up 1', 'Up 2'], group = groupMain, display = display.none, tooltip = 'Optional manual adjustment after Auto Align. Use this if the projection needs another 1/2, 1, or 2 range shift.')
forecastAnchorMinutes = input.int(60, 'Forecast Anchor Window Minutes', minval = 15, maxval = 180, group = groupMain, display = display.none, tooltip = 'Locks the projection anchor after this many minutes from session start. This prevents the projection from chasing the full day high/low and overstretching late in the session.')
forecastAdrCoverage = input.float(0.85, 'Forecast ADR Coverage', minval = 0.25, maxval = 1.25, step = 0.05, group = groupMain, display = display.none, tooltip = 'Scales daily ADR into the projected session map. For NQ/MNQ daily-range forecasting, 0.85-0.95 is the cleaner middle ground: avoids the old 243 overstretch but prevents the map from collapsing to 40.5.')
customStartHour = input.int(9, 'Custom Start Hour NY 24h', minval = 0, maxval = 23, group = groupMain, display = display.none)
customStartMinute = input.int(30, 'Custom Start Minute', minval = 0, maxval = 59, group = groupMain, display = display.none)
customEndHour = input.int(17, 'Custom End Hour NY 24h', minval = 0, maxval = 23, group = groupMain, display = display.none)
customEndMinute = input.int(0, 'Custom End Minute', minval = 0, maxval = 59, group = groupMain, display = display.none)

showAllGIPLevels = input.bool(false, 'Show All GIP Levels', group = groupGB, display = display.none, tooltip = 'Draws yellow GIP zones.')
showRangeZones = input.bool(true, 'Show Smart GIP / Rebalance Range Zones', group = groupGB, display = display.none, tooltip = 'Draws the highest/lowest valid range zones derived from touched GIP and rebalance zones.')
showPDZones = input.bool(false, 'Show Rebalance Zones', group = groupPD, display = display.none, tooltip = 'Blue bands at 17–29% discount and 71–83% premium of each projection box.')
showSourceSubdivisions = input.bool(true, 'Show Source Range Subdivisions', group = groupSource, display = display.none)
subdivisionType = input.string('1/4', 'Subdivision Type', options = ['1/4', '1/8'], group = groupSource, display = display.none)
showSubEQs = input.bool(true, 'Show Projection Sub-EQ Lines', group = groupSource, display = display.none)

// ============================= Private Engine Constants =============================
// These are intentionally not exposed as inputs to keep the public settings panel clean.
po3Number = 81
biasMode = 'Auto Session FPI'
enable950MacroBiasOverride = true
useSessionFpiAsProjectionBias = true
bias = 'Bearish'
useHalfRange = false
projectionCount = 4
rangeShift = 'Auto Align'
maxAutoAlignHalfSteps = projectionCount * 2
asianLondonAutoHalfPo3 = true
asianLondonProjectionEnvelopeAlign = true
asianLondonRangeOnlyMode = true
maxAsianLondonRangeBoxes = 30

po3SelectionMode = 'Auto Hybrid'
adrLength = 14
autoUseNoAdrFallback = true
autoNoAdrPricePctFloor = 8.0
autoScaleProfile = 'Auto'
spFuturesStructureCapMultiplier = 0.75
spFuturesStructureLookbackBars = 240
spFuturesRecentRangeMultiplier = 1.05
spFuturesPricePctFloor = 0.20
stockPricePctFloor = 3.0
stockVolatilityMultiplier = 1.00
forexStructureCapMultiplier = 1.00
forexStructureLookbackBars = 240
forexRecentRangeMultiplier = 1.15
forexPricePctFloor = 0.05
metalsStructureCapMultiplier = 0.85
metalsStructureLookbackBars = 240
metalsRecentRangeMultiplier = 1.15
metalsPricePctFloor = 0.15
autoUnderCoveragePenalty = 1.50
autoAllowPhaseExpansion = true
autoPhaseExpansionMultiplier = 1.15
autoEarlyFactor = 0.45
autoLunchFactor = 0.60
autoPmFactor = 0.80
asianSessionAdrFactor = 0.25
londonSessionAdrFactor = 0.35
nyReferenceFactorForAsianLondonHalf = autoPmFactor
autoAllowExpansionUpgrade = true
autoIncludeSmallAssetScales = true

groupVisual = '- - - - Private Visual Defaults - - - -'
generalTextSize = 'normal'
showTable = showInfoTable
compactTable = true
tablePosition = 'Top Right'
projBorderClrIn = color.new(#000000, 25)
subEQClrIn = color.new(#000000, 13)
projBoxBullClr = color.new(#1bb358, 98)
projBoxBearClr = color.new(#b60e0e, 98)

startHour = sessionTemplate == 'Asian' ? 19 : sessionTemplate == 'London' ? 2 : sessionTemplate == 'New York' ? 9 : customStartHour
startMinute = sessionTemplate == 'New York' ? 30 : sessionTemplate == 'Custom' ? customStartMinute : 0
endHour = sessionTemplate == 'Asian' ? 0 : sessionTemplate == 'London' ? 5 : sessionTemplate == 'New York' ? 17 : customEndHour
endMinute = sessionTemplate == 'Custom' ? customEndMinute : 0

subdivLineColor = color.new(#ffffff, 80)

rangeHighClr = color.new(#c45050, 70)
rangeLowClr = color.new(#50a070, 70)
allGIPLevelsClr = color.new(#ffd84d, 89)
rangeBoxBorder = color.new(#888888, 40)
allGIPBorderClr = color.new(#ffd84d, 50)
showRangeLabels = true
showAllGIPLabels = false
rangeLabelSize = 'small'
rangeLabelTxt = color.new(#ffffff, 0)
rangeLabelBg = color.new(#000000, 30)
allGIPBandPct = 11.0
sharedZoneClr = color.new(#808080, 72)

pdApplyToSource = true
pdUpperTop = 83.0
pdUpperBot = 71.0
pdLowerTop = 29.0
pdLowerBot = 17.0
pdZoneClr = color.new(#2962ff, 82)
pdBorderClr = color.new(#2962ff, 50)
pdShowLabels = false

// ============================= Helpers =============================
f_textSize(s) =>
    s == 'tiny' ? size.tiny : s == 'small' ? size.small : s == 'large' ? size.large : s == 'huge' ? size.huge : size.normal

f_fracLabel(idx, divisions) =>
    if divisions == 4
        switch idx
            1 => '1/4'
            2 => '2/4'
            3 => '3/4'
            => ''
    else
        switch idx
            1 => '1/8'
            2 => '2/8'
            3 => '3/8'
            4 => '4/8'
            5 => '5/8'
            6 => '6/8'
            7 => '7/8'
            => ''

f_price(p) =>
    str.tostring(p, format.mintick)

f_floor_to_tick(p) =>
    math.floor(p / syminfo.mintick) * syminfo.mintick

f_ceil_to_tick(p) =>
    math.ceil(p / syminfo.mintick) * syminfo.mintick

f_zoneTouched(zoneHigh, zoneLow, windowHigh, windowLow) =>
    not na(windowHigh) and not na(windowLow) and windowHigh >= zoneLow and windowLow <= zoneHigh

f_clockReached(_h, _m) =>
    hour(time, 'America/New_York') * 60 + minute(time, 'America/New_York') >= _h * 60 + _m

f_candidateName(_base, _half, _unit) =>
    _half ? str.tostring(_unit, '#.####') + ' (1/2 of ' + str.tostring(_base, '#.####') + ')' : str.tostring(_base, '#.####')

txtSize = f_textSize(generalTextSize)
tblTxtSize = compactTable ? size.tiny : txtSize

// PO3 escalation ladder for index futures (NQ/MNQ default start = 81).
// Sequence: 40.5 (1/2 of 81) -> 81 -> 121.5 (1/2 of 243) -> 243 -> 364.5 (1/2 of 729) -> 729.
// "Close beyond the projection extreme" moves one step up the ladder:
// full number -> half of next number -> untoggle half -> full next number, etc.
f_ladderUnit(i) =>
    i == 0 ? 40.5 : i == 1 ? 81.0 : i == 2 ? 121.5 : i == 3 ? 243.0 : i == 4 ? 364.5 : 729.0

f_ladderBase(i) =>
    i == 0 ? 81.0 : i == 1 ? 81.0 : i == 2 ? 243.0 : i == 3 ? 243.0 : i == 4 ? 729.0 : 729.0

f_ladderHalf(i) =>
    i == 0 or i == 2 or i == 4

// Build the NY PO3 map anchored to the actual session extreme (wick, not body):
// bullish  -> source range LOW snapped down to the half-unit grid at/under the session LOW
//             (so the projection map's low is anchored to the lowest low of the session)
// bearish  -> source range HIGH snapped up to the half-unit grid at/over the session HIGH
f_nyAnchoredMap(_unit, _dir, _sessLow, _sessHigh) =>
    float gridStep = _unit / 2.0
    float sl = na
    float sh = na
    if _dir == 1
        sl := math.floor(_sessLow / gridStep) * gridStep
        sh := sl + _unit
        sh
    else
        sh := math.ceil(_sessHigh / gridStep) * gridStep
        sl := sh - _unit
        sl
    [sh, sl]

// ============================= Session Logic =============================
tz = 'America/New_York'
nyHour = hour(time, tz)
nyMinute = minute(time, tz)
autoAllSessionsMode = sessionTemplate == 'Auto All Sessions'

// Selected/custom template session.
sessionStartToday = timestamp(tz, year(time, tz), month(time, tz), dayofmonth(time, tz), startHour, startMinute)
sessionEndTodayRaw = timestamp(tz, year(time, tz), month(time, tz), dayofmonth(time, tz), endHour, endMinute)
sessionEndToday = sessionEndTodayRaw <= sessionStartToday ? sessionEndTodayRaw + 86400000 : sessionEndTodayRaw
sessionStartPrev = sessionStartToday - 86400000
sessionEndPrev = sessionEndToday - 86400000
selectedInTodaySession = time >= sessionStartToday and time <= sessionEndToday
selectedInPrevSession = time >= sessionStartPrev and time <= sessionEndPrev
selectedInSessionRaw = selectedInTodaySession or selectedInPrevSession
selectedSessionEnabled = sessionTemplate == 'Asian' ? showAsianRanges : sessionTemplate == 'London' ? showLondonRanges : true
selectedInSession = selectedInSessionRaw and selectedSessionEnabled
selectedSessionStart = selectedInTodaySession ? sessionStartToday : selectedInPrevSession ? sessionStartPrev : sessionStartToday
selectedSessionEnd = selectedInTodaySession ? sessionEndToday : selectedInPrevSession ? sessionEndPrev : sessionEndToday

// Auto All Sessions templates.
asianStartToday = timestamp(tz, year(time, tz), month(time, tz), dayofmonth(time, tz), 19, 0)
asianEndToday = asianStartToday + 5 * 60 * 60000
asianStartPrev = asianStartToday - 86400000
asianEndPrev = asianEndToday - 86400000
inAsianToday = time >= asianStartToday and time <= asianEndToday
inAsianPrev = time >= asianStartPrev and time <= asianEndPrev
inAsianSession = inAsianToday or inAsianPrev
asianSessionStart = inAsianToday ? asianStartToday : inAsianPrev ? asianStartPrev : asianStartToday
asianSessionEnd = inAsianToday ? asianEndToday : inAsianPrev ? asianEndPrev : asianEndToday

londonStartToday = timestamp(tz, year(time, tz), month(time, tz), dayofmonth(time, tz), 2, 0)
londonEndToday = timestamp(tz, year(time, tz), month(time, tz), dayofmonth(time, tz), 5, 0)
londonStartPrev = londonStartToday - 86400000
londonEndPrev = londonEndToday - 86400000
inLondonToday = time >= londonStartToday and time <= londonEndToday
inLondonPrev = time >= londonStartPrev and time <= londonEndPrev
inLondonSession = inLondonToday or inLondonPrev
londonSessionStart = inLondonToday ? londonStartToday : inLondonPrev ? londonStartPrev : londonStartToday
londonSessionEnd = inLondonToday ? londonEndToday : inLondonPrev ? londonEndPrev : londonEndToday

nyStartToday = timestamp(tz, year(time, tz), month(time, tz), dayofmonth(time, tz), 9, 30)
nyEndToday = timestamp(tz, year(time, tz), month(time, tz), dayofmonth(time, tz), 17, 0)
nyStartPrev = nyStartToday - 86400000
nyEndPrev = nyEndToday - 86400000
inNyToday = time >= nyStartToday and time <= nyEndToday
inNyPrev = time >= nyStartPrev and time <= nyEndPrev
inNySession = inNyToday or inNyPrev
nySessionStart = inNyToday ? nyStartToday : inNyPrev ? nyStartPrev : nyStartToday
nySessionEnd = inNyToday ? nyEndToday : inNyPrev ? nyEndPrev : nyEndToday

activeAsianSession = showAsianRanges and inAsianSession
activeLondonSession = showLondonRanges and inLondonSession
inAutoSession = activeAsianSession or activeLondonSession or inNySession
inSession = autoAllSessionsMode ? inAutoSession : selectedInSession

currentSessionStart = autoAllSessionsMode ? activeAsianSession ? asianSessionStart : activeLondonSession ? londonSessionStart : inNySession ? nySessionStart : selectedSessionStart : selectedSessionStart
currentSessionEnd = autoAllSessionsMode ? activeAsianSession ? asianSessionEnd : activeLondonSession ? londonSessionEnd : inNySession ? nySessionEnd : selectedSessionEnd : selectedSessionEnd
activeSessionName = autoAllSessionsMode ? activeAsianSession ? 'Asian' : activeLondonSession ? 'London' : inNySession ? 'New York' : 'None' : sessionTemplate
activeStartHour = activeSessionName == 'Asian' ? 19 : activeSessionName == 'London' ? 2 : activeSessionName == 'New York' ? 9 : startHour
activeStartMinute = activeSessionName == 'New York' ? 30 : activeSessionName == 'Custom' ? startMinute : 0

prevInSession = bar_index > 0 ? inSession[1] : false
newSession = inSession and not prevInSession

var float sessHigh = na
var float sessLow = na
var float sessBodyHigh = na
var float sessBodyLow = na
var int sessStartTime = na

var float projWindowHigh = na
var float projWindowLow = na

var float forecastAnchorHigh = na
var float forecastAnchorLow = na
var float forecastAnchorBodyHigh = na
var float forecastAnchorBodyLow = na
var bool forecastAnchorLocked = false

curDayEndTime = currentSessionEnd
inProjectionWindow = inSession and time <= curDayEndTime
lookbackCutoffTime = last_bar_time - sessionLookbackDays * 86400000
sessionWithinLookback = not autoAllSessionsMode or currentSessionStart >= lookbackCutoffTime

barBodyHigh = math.max(open, close)
barBodyLow = math.min(open, close)

if newSession
    sessHigh := high
    sessLow := low
    sessBodyHigh := barBodyHigh
    sessBodyLow := barBodyLow
    sessStartTime := time
    projWindowHigh := na
    projWindowLow := na
    forecastAnchorHigh := high
    forecastAnchorLow := low
    forecastAnchorBodyHigh := barBodyHigh
    forecastAnchorBodyLow := barBodyLow
    forecastAnchorLocked := false
    projWindowLow

if inSession and not na(sessHigh)
    sessHigh := math.max(sessHigh, high)
    sessLow := math.min(sessLow, low)
    sessBodyHigh := na(sessBodyHigh) ? barBodyHigh : math.max(sessBodyHigh, barBodyHigh)
    sessBodyLow := na(sessBodyLow) ? barBodyLow : math.min(sessBodyLow, barBodyLow)
    sessLow

if inProjectionWindow
    projWindowHigh := na(projWindowHigh) ? high : math.max(projWindowHigh, high)
    projWindowLow := na(projWindowLow) ? low : math.min(projWindowLow, low)
    projWindowLow

// Forecast anchor window: the projection should be anchored from the early-session discovery range,
// not from the full session high/low after price already travelled.
forecastAnchorWindowEnd = currentSessionStart + forecastAnchorMinutes * 60000
inForecastAnchorWindow = inSession and time <= math.min(forecastAnchorWindowEnd, currentSessionEnd)

if inForecastAnchorWindow
    forecastAnchorHigh := na(forecastAnchorHigh) ? high : math.max(forecastAnchorHigh, high)
    forecastAnchorLow := na(forecastAnchorLow) ? low : math.min(forecastAnchorLow, low)
    forecastAnchorBodyHigh := na(forecastAnchorBodyHigh) ? barBodyHigh : math.max(forecastAnchorBodyHigh, barBodyHigh)
    forecastAnchorBodyLow := na(forecastAnchorBodyLow) ? barBodyLow : math.min(forecastAnchorBodyLow, barBodyLow)

if inSession and not forecastAnchorLocked and time >= forecastAnchorWindowEnd
    forecastAnchorLocked := true

anchorHighForProjection = nz(forecastAnchorHigh, nz(projWindowHigh, sessHigh))
anchorLowForProjection = nz(forecastAnchorLow, nz(projWindowLow, sessLow))
anchorBodyHighForProjection = nz(forecastAnchorBodyHigh, nz(sessBodyHigh, anchorHighForProjection))
anchorBodyLowForProjection = nz(forecastAnchorBodyLow, nz(sessBodyLow, anchorLowForProjection))
// Hybrid approach:
// - keep PO3 sizing anchored to the locked early-session forecast window
// - but align the vertical map to the live session candle-body envelope using the highest candle open/close
//   and lowest candle open/close, so the printed session bodies stay inside the PO3 projection range.
bodyHighForAlignment = nz(sessBodyHigh, anchorBodyHighForProjection)
bodyLowForAlignment = nz(sessBodyLow, anchorBodyLowForProjection)
anchorRangeForSizing = not na(anchorHighForProjection) and not na(anchorLowForProjection) ? anchorHighForProjection - anchorLowForProjection : na
bodyRangeForAlignment = not na(bodyHighForAlignment) and not na(bodyLowForAlignment) ? bodyHighForAlignment - bodyLowForAlignment : na

// ============================= Session Bias Engine =============================
// Auto mode: first FPI/FVG from the configured session-start FPI window determines session bias.
// Example: start 9:30 => session FPI window 9:30–10:00.
// Macro override: the macro that begins at :50 after the configured session start hour.
// Example: start 9:30 => 9:50 macro. Start 21:00 => 21:50 macro.
// Bullish FPI = low > high[2]. Bearish FPI = high < low[2].
sessionFpiWindowStart = currentSessionStart
sessionFpiWindowEnd = currentSessionStart + 30 * 60000

macroBaseOffsetMinutesRaw = (activeStartMinute <= 50 ? activeStartHour * 60 + 50 : ((activeStartHour + 1) % 24) * 60 + 50) - (activeStartHour * 60 + activeStartMinute)
macroBaseOffsetMinutes = macroBaseOffsetMinutesRaw < 0 ? macroBaseOffsetMinutesRaw + 1440 : macroBaseOffsetMinutesRaw
sessionMacroWindowStart = currentSessionStart + macroBaseOffsetMinutes * 60000
sessionMacroWindowEnd = sessionMacroWindowStart + 20 * 60000

sessionFpiWindow = inSession and time >= sessionFpiWindowStart and time < sessionFpiWindowEnd
sessionMacroWindow = inSession and time >= sessionMacroWindowStart and time <= sessionMacroWindowEnd

bullFpiDetected = low > high[2]
bearFpiDetected = high < low[2]
fpiDirDetected = bullFpiDetected ? 1 : bearFpiDetected ? -1 : 0

var int autoSessionFpiDir = 0
var float autoSessionFpiTop = na
var float autoSessionFpiBottom = na
var float autoSessionFpiMid = na
var int autoSessionFpiTime = na

var int sessionMacroFpiDir = 0
var float sessionMacroFpiTop = na
var float sessionMacroFpiBottom = na
var float sessionMacroFpiMid = na
var int sessionMacroFpiTime = na

if newSession
    autoSessionFpiDir := 0
    autoSessionFpiTop := na
    autoSessionFpiBottom := na
    autoSessionFpiMid := na
    autoSessionFpiTime := na
    sessionMacroFpiDir := 0
    sessionMacroFpiTop := na
    sessionMacroFpiBottom := na
    sessionMacroFpiMid := na
    sessionMacroFpiTime := na

if biasMode == 'Auto Session FPI' and sessionFpiWindow and autoSessionFpiDir == 0 and fpiDirDetected != 0
    autoSessionFpiDir := fpiDirDetected
    autoSessionFpiTop := bullFpiDetected ? low : low[2]
    autoSessionFpiBottom := bullFpiDetected ? high[2] : high
    autoSessionFpiMid := (autoSessionFpiTop + autoSessionFpiBottom) / 2.0
    autoSessionFpiTime := time

if enable950MacroBiasOverride and sessionMacroWindow and sessionMacroFpiDir == 0 and fpiDirDetected != 0
    sessionMacroFpiDir := fpiDirDetected
    sessionMacroFpiTop := bullFpiDetected ? low : low[2]
    sessionMacroFpiBottom := bullFpiDetected ? high[2] : high
    sessionMacroFpiMid := (sessionMacroFpiTop + sessionMacroFpiBottom) / 2.0
    sessionMacroFpiTime := time

manualBiasDir = bias == 'Bullish' ? 1 : -1

// Live read of where the last close sits relative to the macro FPI. This is only used
// to DETECT the first resolution; it must not be the value that drives bias every bar,
// otherwise a late pullback back across the macro FPI flips the whole session bias.
sessionMacroLiveDir = enable950MacroBiasOverride and sessionMacroFpiDir != 0 ? close > sessionMacroFpiTop ? 1 : close < sessionMacroFpiBottom ? -1 : 0 : 0

// Latch the macro override the FIRST time price closes above/below the macro FPI,
// then hold it for the remainder of the session. Reset only on a new session.
var int sessionMacroOverrideDir = 0
if newSession
    sessionMacroOverrideDir := 0
if sessionMacroOverrideDir == 0 and sessionMacroLiveDir != 0
    sessionMacroOverrideDir := sessionMacroLiveDir

projectionMacroOverrideDir = sessionMacroOverrideDir
waitingForSessionFpiCalibration = biasMode == 'Auto Session FPI' and inSession and autoSessionFpiDir == 0 and sessionMacroOverrideDir == 0
// Macro bias takes control once price first closes above/below the 9:50 macro FPI, and
// then stays latched for the rest of the session so intraday pullbacks do not flip it.
sessionBiasDir = sessionMacroOverrideDir != 0 ? sessionMacroOverrideDir : biasMode == 'Auto Session FPI' and autoSessionFpiDir != 0 ? autoSessionFpiDir : biasMode == 'Auto Session FPI' ? 0 : manualBiasDir
sessionBiasText = sessionBiasDir == 1 ? 'Bullish' : sessionBiasDir == -1 ? 'Bearish' : 'Pending'
sessionBiasReason = sessionMacroOverrideDir == 1 ? 'Session Macro Override: price above macro FPI' : sessionMacroOverrideDir == -1 ? 'Session Macro Override: price below macro FPI' : biasMode == 'Auto Session FPI' ? (autoSessionFpiDir != 0 ? 'Auto Session FPI' : 'Waiting for Session FPI') : 'Manual'

// ============================= Derived Colors =============================
isBearish = sessionBiasDir == -1
sourceBorderClr = isBearish ? color.new(#b05050, 55) : color.new(#50a070, 55)
sourceBoxClr = isBearish ? color.new(#b05050, 88) : color.new(#50a070, 88)
thickLineClr = isBearish ? color.new(#c45050, 15) : color.new(#50b070, 15)
projBoxClr = isBearish ? projBoxBearClr : projBoxBullClr
eqClr = color.new(#ffffff, 20)
lblTextClr = color.new(#000000, 0)
tableBgClr = color.new(#2a2d36, 15)
tableBorderClr = color.new(#4a4d56, 40)
tableHeaderClr = isBearish ? color.new(#8b4040, 30) : color.new(#408b60, 30)

// ============================= Auto PO3 Scale Engine =============================
// For new listings / recent IPOs, Daily ADR can be na because there is not enough history.
// If expectedSessionMove becomes 0, the auto engine will select the smallest possible unit.
// This fallback prevents that by using observed session/projection-window range and a price-percent floor.
adrRaw = request.security(syminfo.tickerid, 'D', ta.sma(high - low, adrLength)[1], lookahead = barmerge.lookahead_off)
adrValid = not na(adrRaw) and adrRaw > 0

observedSessionRange = not na(sessHigh) and not na(sessLow) ? sessHigh - sessLow : na
observedProjectionRange = not na(projWindowHigh) and not na(projWindowLow) ? projWindowHigh - projWindowLow : na
observedForecastRange = nz(anchorRangeForSizing, nz(observedSessionRange, observedProjectionRange))
pricePctFallback = close * (autoNoAdrPricePctFloor / 100.0)

noAdrFallbackMove = math.max(nz(observedForecastRange, 0.0), pricePctFallback)
// Session-template phase sizing.
// Asian/London must not use the old PM factor just because the chart clock is 7PM/2AM.
// Daily-range forecast sizing should not shrink just because the scale locks early.
// The prior version used autoEarlyFactor at 9:50, which caused NQ/MNQ to collapse into a 40.5 map.
// Use the PM/full-session factor for NY so the map forecasts the day, not only the first hour.
nySessionPhaseFactor = activeSessionName == 'New York' ? autoPmFactor : nyHour < 10 or nyHour == 10 and nyMinute < 30 ? autoEarlyFactor : nyHour < 12 ? autoLunchFactor : autoPmFactor
asianLondonNyReferenceHalfMode = asianLondonAutoHalfPo3 and (activeSessionName == 'Asian' or activeSessionName == 'London')
// When enabled, Asian/London first calculate the normal NY reference projection size,
// then use half of that final 5-box projection range. This is different from selecting a
// smaller Asian/London PO3 first and then halving that smaller PO3.
autoPhaseFactor = asianLondonNyReferenceHalfMode ? nyReferenceFactorForAsianLondonHalf : activeSessionName == 'Asian' ? asianSessionAdrFactor : activeSessionName == 'London' ? londonSessionAdrFactor : activeSessionName == 'New York' ? nySessionPhaseFactor : nySessionPhaseFactor

tickerUpper = str.upper(syminfo.ticker)
rootUpper = str.upper(syminfo.root)
isMetalTicker = str.contains(tickerUpper, 'XAU') or str.contains(tickerUpper, 'XAG')
isSPFuturesTicker = syminfo.type == 'futures' and (str.contains(rootUpper, 'MES') or rootUpper == 'ES' or str.contains(tickerUpper, 'MES') or str.contains(tickerUpper, ':ES') or str.contains(tickerUpper, 'ES1'))
isNasdaqFuturesTicker = syminfo.type == 'futures' and (str.contains(rootUpper, 'MNQ') or rootUpper == 'NQ' or str.contains(tickerUpper, 'MNQ') or str.contains(tickerUpper, ':NQ') or str.contains(tickerUpper, 'NQ1'))
isIndexFuturesTicker = isSPFuturesTicker or isNasdaqFuturesTicker
isStockScaleProfile = autoScaleProfile == 'Stocks / ETFs' or autoScaleProfile == 'Auto' and syminfo.type == 'stock'
isSPFuturesProfile = autoScaleProfile == 'S&P Futures' or autoScaleProfile == 'Auto' and isIndexFuturesTicker
isForexPairProfile = autoScaleProfile == 'Forex Pairs' or autoScaleProfile == 'Auto' and syminfo.type == 'forex' and not isMetalTicker
isMetalsProfile = autoScaleProfile == 'Metals' or autoScaleProfile == 'Auto' and isMetalTicker

stockPriceFloorMove = close * (stockPricePctFloor / 100.0)
stockHybridMoveRaw = math.max(nz(adrRaw, 0.0), nz(observedSessionRange, 0.0), nz(observedProjectionRange, 0.0), stockPriceFloorMove)
stockHybridMove = stockHybridMoveRaw * stockVolatilityMultiplier

forecastAdrFactor = activeSessionName == 'New York' ? forecastAdrCoverage : 1.0
futuresExpectedMove = adrValid ? adrRaw * autoPhaseFactor * forecastAdrFactor : autoUseNoAdrFallback ? noAdrFallbackMove : 0.0

spFuturesRollingRange = ta.highest(high, spFuturesStructureLookbackBars) - ta.lowest(low, spFuturesStructureLookbackBars)
spFuturesFloorMove = close * (spFuturesPricePctFloor / 100.0)
spFuturesStructureMove = math.max(nz(spFuturesRollingRange, 0.0) * spFuturesRecentRangeMultiplier, spFuturesFloorMove)
spFuturesStructureCap = spFuturesStructureMove * spFuturesStructureCapMultiplier
spFuturesAdrPhaseMove = adrValid ? adrRaw * autoPhaseFactor * forecastAdrFactor : autoUseNoAdrFallback ? noAdrFallbackMove : 0.0
spFuturesExpectedMove = spFuturesAdrPhaseMove > 0 ? math.min(spFuturesAdrPhaseMove, spFuturesStructureCap) : spFuturesStructureCap

forexRollingRange = ta.highest(high, forexStructureLookbackBars) - ta.lowest(low, forexStructureLookbackBars)
forexFloorMove = close * (forexPricePctFloor / 100.0)
forexStructureMove = math.max(nz(forexRollingRange, 0.0) * forexRecentRangeMultiplier, forexFloorMove)
forexStructureCap = forexStructureMove * forexStructureCapMultiplier
forexAdrPhaseMove = adrValid ? adrRaw * autoPhaseFactor * forecastAdrFactor : autoUseNoAdrFallback ? noAdrFallbackMove : 0.0
forexExpectedMove = forexAdrPhaseMove > 0 ? math.min(forexAdrPhaseMove, forexStructureCap) : forexStructureCap

metalsRollingRange = ta.highest(high, metalsStructureLookbackBars) - ta.lowest(low, metalsStructureLookbackBars)
metalsFloorMove = close * (metalsPricePctFloor / 100.0)
metalsStructureMove = math.max(nz(metalsRollingRange, 0.0) * metalsRecentRangeMultiplier, metalsFloorMove)
metalsStructureCap = metalsStructureMove * metalsStructureCapMultiplier
metalsAdrPhaseMove = adrValid ? adrRaw * autoPhaseFactor * forecastAdrFactor : autoUseNoAdrFallback ? noAdrFallbackMove : 0.0
metalsExpectedMove = metalsAdrPhaseMove > 0 ? math.min(metalsAdrPhaseMove, metalsStructureCap) : metalsStructureCap

adrPoints = isStockScaleProfile ? stockHybridMove : isSPFuturesProfile ? spFuturesExpectedMove : isForexPairProfile ? forexExpectedMove : isMetalsProfile ? metalsExpectedMove : adrValid ? adrRaw : autoUseNoAdrFallback ? noAdrFallbackMove : na
expectedSessionMove = isStockScaleProfile ? stockHybridMove : isSPFuturesProfile ? spFuturesExpectedMove : isForexPairProfile ? forexExpectedMove : isMetalsProfile ? metalsExpectedMove : futuresExpectedMove
// PO3 sizing must respect the forecast anchor, ADR forecast, live candle-body coverage,
// and a controlled realized-range expansion.
// If the live session candle bodies do not fit inside the total projection envelope,
// the auto engine must step up to a larger PO3 candidate.
realizedExpansionMove = not na(observedSessionRange) ? observedSessionRange * 0.65 : na
bodyFitMove = not na(bodyRangeForAlignment) ? bodyRangeForAlignment * 1.10 : na
autoSizingMove = math.max(nz(expectedSessionMove, 0.0), nz(observedForecastRange, 0.0), nz(realizedExpansionMove, 0.0), nz(bodyFitMove, 0.0))
mapBoxCountForSizing = float(projectionCount + 1)
desiredProjectionUnit = mapBoxCountForSizing > 0 ? autoSizingMove / mapBoxCountForSizing : autoSizingMove
autoDataSource = isStockScaleProfile ? 'Stock' : isSPFuturesProfile ? 'Index fut' : isForexPairProfile ? 'FX pair' : isMetalsProfile ? 'Metals' : adrValid ? 'ADR' : autoUseNoAdrFallback ? 'No-ADR' : 'No ADR'

f_autoUnitScore(_unit) =>
    // Size against the full visible map: source box + projection boxes.
    // Old logic used only projectionCount, which made a 5-box map choose one scale too large.
    _total = _unit * mapBoxCountForSizing
    _total < autoSizingMove ? (autoSizingMove - _total) * autoUnderCoveragePenalty : _total - autoSizingMove

// Candidate PO3 units.
// Forex pairs need pip-sized decimal PO3 units.
// Metals/stocks keep larger decimal/full-point PO3 units.
candUnit1 = isForexPairProfile ? 0.0001875 : autoIncludeSmallAssetScales ? 0.1875 : 40.5
candBase1 = isForexPairProfile ? 0.000375 : autoIncludeSmallAssetScales ? 0.375 : 81.0
candHalf1 = true

candUnit2 = isForexPairProfile ? 0.000375 : autoIncludeSmallAssetScales ? 0.375 : 81.0
candBase2 = isForexPairProfile ? 0.000375 : autoIncludeSmallAssetScales ? 0.375 : 81.0
candHalf2 = false

candUnit3 = isForexPairProfile ? 0.00075 : autoIncludeSmallAssetScales ? 0.75 : 121.5
candBase3 = isForexPairProfile ? 0.0015 : autoIncludeSmallAssetScales ? 1.5 : 243.0
candHalf3 = true

candUnit4 = isForexPairProfile ? 0.0015 : autoIncludeSmallAssetScales ? 1.5 : 243.0
candBase4 = isForexPairProfile ? 0.003 : autoIncludeSmallAssetScales ? 3.0 : 243.0
candHalf4 = true

candUnit5 = isForexPairProfile ? 0.003 : autoIncludeSmallAssetScales ? 3.0 : 364.5
candBase5 = isForexPairProfile ? 0.003 : autoIncludeSmallAssetScales ? 3.0 : 729.0
candHalf5 = false

candUnit6 = isForexPairProfile ? 0.0045 : 4.5
candBase6 = isForexPairProfile ? 0.009 : 9.0
candHalf6 = true

candUnit7 = isForexPairProfile ? 0.006 : 6.0
candBase7 = isForexPairProfile ? 0.006 : 6.0
candHalf7 = false

candUnit8 = isForexPairProfile ? 0.009 : 9.0
candBase8 = isForexPairProfile ? 0.009 : 9.0
candHalf8 = false

candUnit9 = isForexPairProfile ? 0.0135 : 13.5
candBase9 = isForexPairProfile ? 0.027 : 27.0
candHalf9 = true

candUnit10 = isForexPairProfile ? 0.027 : 27.0
candBase10 = isForexPairProfile ? 0.027 : 27.0
candHalf10 = false

candUnit11 = isForexPairProfile ? 0.0405 : 40.5
candBase11 = isForexPairProfile ? 0.081 : 81.0
candHalf11 = true

candUnit12 = isForexPairProfile ? 0.081 : 81.0
candBase12 = isForexPairProfile ? 0.081 : 81.0
candHalf12 = false

candUnit13 = isForexPairProfile ? 0.1215 : 121.5
candBase13 = isForexPairProfile ? 0.243 : 243.0
candHalf13 = true

candUnit14 = isForexPairProfile ? 0.243 : 243.0
candBase14 = isForexPairProfile ? 0.243 : 243.0
candHalf14 = false

candUnit15 = isForexPairProfile ? 0.3645 : 364.5
candBase15 = isForexPairProfile ? 0.729 : 729.0
candHalf15 = true

candUnit16 = isForexPairProfile ? 0.729 : 729.0
candBase16 = isForexPairProfile ? 0.729 : 729.0
candHalf16 = false

score1 = f_autoUnitScore(candUnit1)
score2 = f_autoUnitScore(candUnit2)
score3 = f_autoUnitScore(candUnit3)
score4 = f_autoUnitScore(candUnit4)
score5 = f_autoUnitScore(candUnit5)
score6 = f_autoUnitScore(candUnit6)
score7 = f_autoUnitScore(candUnit7)
score8 = f_autoUnitScore(candUnit8)
score9 = f_autoUnitScore(candUnit9)
score10 = f_autoUnitScore(candUnit10)
score11 = f_autoUnitScore(candUnit11)
score12 = f_autoUnitScore(candUnit12)
score13 = f_autoUnitScore(candUnit13)
score14 = f_autoUnitScore(candUnit14)
score15 = f_autoUnitScore(candUnit15)
score16 = f_autoUnitScore(candUnit16)

float dynUnit = candUnit1
float dynBase = candBase1
bool dynHalf = candHalf1
float dynScore = score1

if score2 < dynScore
    dynUnit := candUnit2
    dynBase := candBase2
    dynHalf := candHalf2
    dynScore := score2

if score3 < dynScore
    dynUnit := candUnit3
    dynBase := candBase3
    dynHalf := candHalf3
    dynScore := score3

if score4 < dynScore
    dynUnit := candUnit4
    dynBase := candBase4
    dynHalf := candHalf4
    dynScore := score4

if score5 < dynScore
    dynUnit := candUnit5
    dynBase := candBase5
    dynHalf := candHalf5
    dynScore := score5

if score6 < dynScore
    dynUnit := candUnit6
    dynBase := candBase6
    dynHalf := candHalf6
    dynScore := score6

if score7 < dynScore
    dynUnit := candUnit7
    dynBase := candBase7
    dynHalf := candHalf7
    dynScore := score7

if score8 < dynScore
    dynUnit := candUnit8
    dynBase := candBase8
    dynHalf := candHalf8
    dynScore := score8

if score9 < dynScore
    dynUnit := candUnit9
    dynBase := candBase9
    dynHalf := candHalf9
    dynScore := score9

if score10 < dynScore
    dynUnit := candUnit10
    dynBase := candBase10
    dynHalf := candHalf10
    dynScore := score10

if score11 < dynScore
    dynUnit := candUnit11
    dynBase := candBase11
    dynHalf := candHalf11
    dynScore := score11

if score12 < dynScore
    dynUnit := candUnit12
    dynBase := candBase12
    dynHalf := candHalf12
    dynScore := score12

if score13 < dynScore
    dynUnit := candUnit13
    dynBase := candBase13
    dynHalf := candHalf13
    dynScore := score13

if score14 < dynScore
    dynUnit := candUnit14
    dynBase := candBase14
    dynHalf := candHalf14
    dynScore := score14

if score15 < dynScore
    dynUnit := candUnit15
    dynBase := candBase15
    dynHalf := candHalf15
    dynScore := score15

if score16 < dynScore
    dynUnit := candUnit16
    dynBase := candBase16
    dynHalf := candHalf16
    dynScore := score16


// Hard floor: if the live candle-body envelope is larger than the total map height,
// force the next larger candidate that can contain the bodies inside the projection.
float minBodyFitUnit = not na(bodyRangeForAlignment) and mapBoxCountForSizing > 0 ? bodyRangeForAlignment * 1.05 / mapBoxCountForSizing : na
float fitUnit = dynUnit
float fitBase = dynBase
bool fitHalf = dynHalf

if not na(minBodyFitUnit)
    if candUnit1 >= minBodyFitUnit
        fitUnit := candUnit1
        fitBase := candBase1
        fitHalf := candHalf1
    else if candUnit2 >= minBodyFitUnit
        fitUnit := candUnit2
        fitBase := candBase2
        fitHalf := candHalf2
    else if candUnit3 >= minBodyFitUnit
        fitUnit := candUnit3
        fitBase := candBase3
        fitHalf := candHalf3
    else if candUnit4 >= minBodyFitUnit
        fitUnit := candUnit4
        fitBase := candBase4
        fitHalf := candHalf4
    else if candUnit5 >= minBodyFitUnit
        fitUnit := candUnit5
        fitBase := candBase5
        fitHalf := candHalf5
    else if candUnit6 >= minBodyFitUnit
        fitUnit := candUnit6
        fitBase := candBase6
        fitHalf := candHalf6
    else if candUnit7 >= minBodyFitUnit
        fitUnit := candUnit7
        fitBase := candBase7
        fitHalf := candHalf7
    else if candUnit8 >= minBodyFitUnit
        fitUnit := candUnit8
        fitBase := candBase8
        fitHalf := candHalf8
    else if candUnit9 >= minBodyFitUnit
        fitUnit := candUnit9
        fitBase := candBase9
        fitHalf := candHalf9
    else if candUnit10 >= minBodyFitUnit
        fitUnit := candUnit10
        fitBase := candBase10
        fitHalf := candHalf10
    else if candUnit11 >= minBodyFitUnit
        fitUnit := candUnit11
        fitBase := candBase11
        fitHalf := candHalf11
    else if candUnit12 >= minBodyFitUnit
        fitUnit := candUnit12
        fitBase := candBase12
        fitHalf := candHalf12
    else if candUnit13 >= minBodyFitUnit
        fitUnit := candUnit13
        fitBase := candBase13
        fitHalf := candHalf13
    else if candUnit14 >= minBodyFitUnit
        fitUnit := candUnit14
        fitBase := candBase14
        fitHalf := candHalf14
    else if candUnit15 >= minBodyFitUnit
        fitUnit := candUnit15
        fitBase := candBase15
        fitHalf := candHalf15
    else
        fitUnit := candUnit16
        fitBase := candBase16
        fitHalf := candHalf16

if not na(minBodyFitUnit) and fitUnit > dynUnit
    dynUnit := fitUnit
    dynBase := fitBase
    dynHalf := fitHalf
    dynScore := f_autoUnitScore(dynUnit)

autoConfidence = autoSizingMove > 0 ? math.max(0.0, 100.0 - dynScore / autoSizingMove * 100.0) : na
realizedSessionRange = not na(sessHigh) and not na(sessLow) ? sessHigh - sessLow : na

var bool autoScaleLocked = false
var bool autoScaleExpanded = false
var float lockedUnit = na
var float lockedBase = na
var bool lockedHalf = false
var string lockedReason = 'Pending'
var bool lockedFromNoAdr = false

if newSession
    autoScaleLocked := false
    autoScaleExpanded := false
    lockedUnit := na
    lockedBase := na
    lockedHalf := false
    lockedReason := 'Pending'
    lockedFromNoAdr := false

autoModeManual = po3SelectionMode == 'Manual'
autoLockReady = inSession and time >= sessionMacroWindowStart
autoExpansionReady = inSession and time >= sessionMacroWindowStart + 40 * 60000
manualUnit = useHalfRange ? float(po3Number) / 2.0 : float(po3Number)

if not autoModeManual and not waitingForSessionFpiCalibration and not autoScaleLocked and autoLockReady and autoSizingMove > 0
    autoScaleLocked := true
    lockedUnit := dynUnit
    lockedBase := dynBase
    lockedHalf := dynHalf
    lockedReason := 'Lock ' + autoDataSource
    lockedFromNoAdr := not isStockScaleProfile and not isSPFuturesProfile and not isForexPairProfile and not isMetalsProfile and not adrValid and autoUseNoAdrFallback

smallMapExhausted = autoScaleLocked and not na(realizedSessionRange) and not na(lockedUnit) and realizedSessionRange >= lockedUnit * mapBoxCountForSizing * 0.95
rangeOutgrewProjectionMap = autoScaleLocked and not na(realizedSessionRange) and not na(lockedUnit) and realizedSessionRange > lockedUnit * mapBoxCountForSizing * 1.10
adrNotComplete = not na(realizedSessionRange) and not na(adrPoints) and realizedSessionRange < adrPoints * 0.95
expansionCandidateLarger = not na(lockedUnit) and dynUnit > lockedUnit

// Normal ADR symbols can upgrade after the expansion check.
// Earlier version locked too early at 9:50. Example: NVDA could lock 0.75 from early-AM ADR,
// then late-AM/PM expected move expands to where 1.5 is correct. Phase expansion fixes that.
// No-ADR symbols remain elastic because the fallback estimate can grow sharply after IPO/debut volatility develops.
lockedProjectionCoverage = lockedUnit * mapBoxCountForSizing
phaseExpectedOutgrewLock = not lockedFromNoAdr and autoAllowPhaseExpansion and autoScaleLocked and autoExpansionReady and expansionCandidateLarger and expectedSessionMove > lockedProjectionCoverage * autoPhaseExpansionMultiplier
normalAdrExpansion = not lockedFromNoAdr and not isStockScaleProfile and not isSPFuturesProfile and not isForexPairProfile and not isMetalsProfile and not autoScaleExpanded and autoExpansionReady and smallMapExhausted and expansionCandidateLarger
spFuturesExpectedOutgrewLock = isSPFuturesProfile and autoScaleLocked and expansionCandidateLarger and expectedSessionMove > lockedProjectionCoverage * autoPhaseExpansionMultiplier
spFuturesRangeOutgrewLock = isSPFuturesProfile and autoScaleLocked and expansionCandidateLarger and not na(realizedSessionRange) and realizedSessionRange > lockedProjectionCoverage * autoPhaseExpansionMultiplier
spFuturesElasticExpansion = isSPFuturesProfile and (spFuturesExpectedOutgrewLock or spFuturesRangeOutgrewLock)
stockExpectedOutgrewLock = isStockScaleProfile and autoScaleLocked and expansionCandidateLarger and expectedSessionMove > lockedProjectionCoverage * autoPhaseExpansionMultiplier
stockRangeOutgrewLock = isStockScaleProfile and autoScaleLocked and expansionCandidateLarger and not na(realizedSessionRange) and realizedSessionRange > lockedProjectionCoverage * autoPhaseExpansionMultiplier
stockElasticExpansion = isStockScaleProfile and (stockExpectedOutgrewLock or stockRangeOutgrewLock)
fxMetalsProfileActive = isForexPairProfile or isMetalsProfile
fxMetalsExpectedOutgrewLock = fxMetalsProfileActive and autoScaleLocked and expansionCandidateLarger and expectedSessionMove > lockedProjectionCoverage * autoPhaseExpansionMultiplier
fxMetalsRangeOutgrewLock = fxMetalsProfileActive and autoScaleLocked and expansionCandidateLarger and not na(realizedSessionRange) and realizedSessionRange > lockedProjectionCoverage * autoPhaseExpansionMultiplier
fxMetalsElasticExpansion = fxMetalsProfileActive and (fxMetalsExpectedOutgrewLock or fxMetalsRangeOutgrewLock)
noAdrExpectedOutgrewLock = lockedFromNoAdr and autoScaleLocked and expansionCandidateLarger and expectedSessionMove > lockedProjectionCoverage * autoPhaseExpansionMultiplier
noAdrRangeOutgrewLock = lockedFromNoAdr and autoScaleLocked and expansionCandidateLarger and not na(realizedSessionRange) and realizedSessionRange > lockedProjectionCoverage * autoPhaseExpansionMultiplier
noAdrElasticExpansion = lockedFromNoAdr and (noAdrExpectedOutgrewLock or noAdrRangeOutgrewLock)

if po3SelectionMode == 'Auto Hybrid' and autoAllowExpansionUpgrade and autoScaleLocked and (rangeOutgrewProjectionMap or phaseExpectedOutgrewLock or normalAdrExpansion or spFuturesElasticExpansion or stockElasticExpansion or fxMetalsElasticExpansion or noAdrElasticExpansion)
    lockedUnit := dynUnit
    lockedBase := dynBase
    lockedHalf := dynHalf
    lockedReason := rangeOutgrewProjectionMap ? 'Expand Range Break' : spFuturesElasticExpansion ? 'Expand S&P' : stockElasticExpansion ? 'Expand Stock' : fxMetalsElasticExpansion ? 'Expand FX/metals' : phaseExpectedOutgrewLock ? 'Expand Phase' : lockedFromNoAdr ? 'Expand No-ADR' : 'Expand Range'
    autoScaleExpanded := normalAdrExpansion or autoScaleExpanded

float effectiveUnit = manualUnit
float effectiveBase = float(po3Number)
bool effectiveHalf = useHalfRange
string effectiveReason = 'Manual'

if not autoModeManual
    effectiveUnit := autoScaleLocked ? lockedUnit : dynUnit
    effectiveBase := autoScaleLocked ? lockedBase : dynBase
    effectiveHalf := autoScaleLocked ? lockedHalf : dynHalf
    effectiveReason := autoScaleLocked ? lockedReason : 'Dynamic ' + autoDataSource

useAsianLondonHalfPo3 = asianLondonNyReferenceHalfMode
if useAsianLondonHalfPo3
    effectiveHalf := true
    effectiveUnit := effectiveBase / 2.0
    effectiveReason := effectiveReason + ' | NY 5-box half'

effectiveLabel = f_candidateName(effectiveBase, effectiveHalf, effectiveUnit)

// ============================= PO3 Range Calculation =============================
sessionFpiAnchorHigh = biasMode == 'Auto Session FPI' and autoSessionFpiDir != 0 ? math.max(anchorBodyHighForProjection, nz(autoSessionFpiTop, anchorBodyHighForProjection)) : anchorBodyHighForProjection
sessionFpiAnchorLow = biasMode == 'Auto Session FPI' and autoSessionFpiDir != 0 ? math.min(anchorBodyLowForProjection, nz(autoSessionFpiBottom, anchorBodyLowForProjection)) : anchorBodyLowForProjection
refPrice = isBearish ? sessionFpiAnchorHigh : sessionFpiAnchorLow
po3Float = math.max(float(effectiveBase), syminfo.mintick)

// Intraday target bridge:
// Final target is the 4th deviation / 5th box in session FPI direction.
// Rebalance/GIP values mirror the final-box target zone the bot uses for runner/countertrend logic.
po3FinalTarget = isBearish ? refPrice - po3Float * 4.0 : refPrice + po3Float * 4.0
po3FinalBoxNear = isBearish ? refPrice - po3Float * 3.0 : refPrice + po3Float * 3.0
po3FinalRebalanceA = isBearish ? po3FinalTarget + po3Float * 0.17 : po3FinalTarget - po3Float * 0.17
po3FinalRebalanceB = isBearish ? po3FinalTarget + po3Float * 0.29 : po3FinalTarget - po3Float * 0.29
po3FinalGip = isBearish ? po3FinalTarget + po3Float * 0.25 : po3FinalTarget - po3Float * 0.25
rangeIdx = math.floor(nz(refPrice) / po3Float)
rLow = rangeIdx * po3Float
rHigh = (rangeIdx + 1) * po3Float
rEQ = (rLow + rHigh) / 2.0
halfRange = po3Float / 2.0

float srcHigh = na
float srcLow = na
float rSize = na

if effectiveHalf
    if isBearish
        srcHigh := rEQ
        srcLow := rLow
        rSize := halfRange
        rSize
    else
        srcHigh := rHigh
        srcLow := rEQ
        rSize := halfRange
        rSize
else
    srcHigh := rHigh
    srcLow := rLow
    rSize := po3Float
    rSize

// ============================= Auto Source Alignment =============================
// Auto Align now supports wider static PO3 shifts, not only +/-1 source unit.
// NY keeps source-anchor alignment.
// Asian/London use direct 5th-rectangle alignment:
// - bullish A/L: place the session high inside the final/5th bullish projection rectangle.
// - bearish A/L: place the session low inside the final/5th bearish projection rectangle.
// This is algebraic, not just a scoring search, so it can shift down/up multiple boxes when required.
float appliedShiftUnits = 0.0
float anchorExtreme = isBearish ? anchorBodyHighForProjection : anchorBodyLowForProjection
bool useAsianLondonFinalRectangleAlignment = asianLondonProjectionEnvelopeAlign and (activeSessionName == 'Asian' or activeSessionName == 'London')

if rangeShift == 'Auto Align'
    if useAsianLondonFinalRectangleAlignment
        float activeHighAnchor = anchorHighForProjection
        float activeLowAnchor = anchorLowForProjection

        // Center the session extreme in the final projected rectangle.
        // Bullish final rectangle center = srcHigh + shift*rSize + (projectionCount - 0.5)*rSize.
        // Bearish final rectangle center = srcLow + shift*rSize - (projectionCount - 0.5)*rSize.
        float rawShiftUnits = isBearish ? ((activeLowAnchor - srcLow) / rSize + (projectionCount - 0.5)) : ((activeHighAnchor - srcHigh) / rSize - (projectionCount - 0.5))
        float roundedShiftUnits = math.round(rawShiftUnits * 2.0) / 2.0
        float maxShiftUnits = maxAutoAlignHalfSteps * 0.5
        appliedShiftUnits := math.max(-maxShiftUnits, math.min(maxShiftUnits, roundedShiftUnits))
    else
        float bestShiftUnits = 0.0
        float bestScore = 1000000000.0
        float bodyMid = (bodyHighForAlignment + bodyLowForAlignment) / 2.0

        for sh = -maxAutoAlignHalfSteps to maxAutoAlignHalfSteps by 1
            float testShiftUnits = sh * 0.5
            float testHigh = srcHigh + testShiftUnits * rSize
            float testLow = srcLow + testShiftUnits * rSize
            float testProjTop = isBearish ? testHigh : testHigh + projectionCount * rSize
            float testProjBottom = isBearish ? testLow - projectionCount * rSize : testLow
            float overflowTop = math.max(0.0, bodyHighForAlignment - testProjTop)
            float overflowBottom = math.max(0.0, testProjBottom - bodyLowForAlignment)
            float projMid = (testProjTop + testProjBottom) / 2.0
            float centerScore = math.abs(projMid - bodyMid)
            // Directional anchor rule requested by user:
            // bullish => session body low should sit on the bottom of the total projection envelope.
            // bearish => session body high should sit on the top of the total projection envelope.
            float directionalAnchorScore = isBearish ? math.abs(testProjTop - bodyHighForAlignment) : math.abs(testProjBottom - bodyLowForAlignment)
            float oppositeEdgeScore = isBearish ? math.abs(testProjBottom - bodyLowForAlignment) : math.abs(testProjTop - bodyHighForAlignment)
            float sourceAnchorScore = isBearish ? math.abs(testHigh - anchorBodyHighForProjection) : math.abs(testLow - anchorBodyLowForProjection)
            float score = (overflowTop + overflowBottom) * 5000.0 + directionalAnchorScore * 4.0 + centerScore * 0.5 + oppositeEdgeScore * 0.15 + sourceAnchorScore * 0.10

            if score < bestScore
                bestScore := score
                bestShiftUnits := testShiftUnits

        appliedShiftUnits := bestShiftUnits
else if rangeShift == 'Shift Down 1/2'
    appliedShiftUnits := -0.5
else if rangeShift == 'Shift Up 1/2'
    appliedShiftUnits := 0.5
else if rangeShift == 'Shift Down 1'
    appliedShiftUnits := -1.0
else if rangeShift == 'Shift Up 1'
    appliedShiftUnits := 1.0

extraShiftUnits = extraProjectionShift == 'Down 2' ? -2.0 : extraProjectionShift == 'Down 1' ? -1.0 : extraProjectionShift == 'Down 1/2' ? -0.5 : extraProjectionShift == 'Up 1/2' ? 0.5 : extraProjectionShift == 'Up 1' ? 1.0 : extraProjectionShift == 'Up 2' ? 2.0 : 0.0
appliedShiftUnits += extraShiftUnits

if appliedShiftUnits != 0.0
    srcHigh := srcHigh + appliedShiftUnits * rSize
    srcLow := srcLow + appliedShiftUnits * rSize

float projHigh = na
float projLow = na
float projEQ = na

if isBearish
    projHigh := srcHigh
    projLow := srcLow - projectionCount * rSize
    projEQ := (projHigh + projLow) / 2.0
    projEQ
else
    projLow := srcLow
    projHigh := srcHigh + projectionCount * rSize
    projEQ := (projHigh + projLow) / 2.0
    projEQ

// ============================= NY PO3 Completion Lock Engine =============================
// A complete PO3 MMXM = price has traded into the final-box GIP zone (the target edge of
// projection box #5 / 4th projection) in the bias direction. Once that happens the map LOCKS:
// no more re-sizing / re-aligning as long as no new session high or low is made outside it.
// If price keeps running and wicks outside the locked envelope -> shift the whole map in
// half-unit steps (anchor rule preserved). If a bar CLOSES beyond the projection extreme ->
// escalate to the next ladder step (half of next PO3 number first, then the full number).
isNyEngineActive = activeSessionName == 'New York' and sessionBiasDir != 0 and not na(sessLow) and not na(sessHigh)

var int nyLadderIdx = -1
var bool nyMapLocked = false
var bool nyFinalGipReached = false
var float nyLkSrcHigh = na
var float nyLkSrcLow = na
var float nyLkUnit = na
var float nyLkBase = na
var bool nyLkHalf = false

if newSession
    nyLadderIdx := -1
    nyMapLocked := false
    nyFinalGipReached := false
    nyLkSrcHigh := na
    nyLkSrcLow := na
    nyLkUnit := na
    nyLkBase := na
    nyLkHalf := false

// Seed the ladder from whatever the auto scale engine chose when bias first resolves.
// On NQ/MNQ this is normally 81 -> ladder index 1.
if isNyEngineActive and nyLadderIdx < 0
    nyLadderIdx := effectiveUnit <= 40.5 ? 0 : effectiveUnit <= 81.0 ? 1 : effectiveUnit <= 121.5 ? 2 : effectiveUnit <= 243.0 ? 3 : effectiveUnit <= 364.5 ? 4 : 5

if isNyEngineActive and nyLadderIdx >= 0
    // 1) While NOT locked, rebuild the anchored map live every bar.
    if not nyMapLocked
        float u = f_ladderUnit(nyLadderIdx)
        [mh, ml] = f_nyAnchoredMap(u, sessionBiasDir, sessLow, sessHigh)
        nyLkSrcHigh := mh
        nyLkSrcLow := ml
        nyLkUnit := u
        nyLkBase := f_ladderBase(nyLadderIdx)
        nyLkHalf := f_ladderHalf(nyLadderIdx)

    float envHigh = sessionBiasDir == 1 ? nyLkSrcHigh + projectionCount * nyLkUnit : nyLkSrcHigh
    float envLow = sessionBiasDir == 1 ? nyLkSrcLow : nyLkSrcLow - projectionCount * nyLkUnit

    // 2) Completion check: has price reached the final-box GIP zone (target edge of box #5)?
    float gipHalfBand = nyLkUnit * (allGIPBandPct / 100.0)
    float finalTargetLvl = sessionBiasDir == 1 ? envHigh - nyLkUnit : envLow + nyLkUnit
    bool touchedFinalGip = sessionBiasDir == 1 ? sessHigh >= finalTargetLvl - gipHalfBand : sessLow <= finalTargetLvl + gipHalfBand

    if touchedFinalGip and not nyFinalGipReached
        nyFinalGipReached := true
        nyMapLocked := true

    // 3) Post-completion management.
    if nyMapLocked
        bool closedBeyond = barstate.isconfirmed and (sessionBiasDir == 1 ? close > envHigh : close < envLow)
        if closedBeyond and nyLadderIdx < 5
            // Escalate: next ladder step (half of next PO3 first, then full), unlock,
            // re-anchor to session extreme, wait for a fresh completion on the new map.
            nyLadderIdx := nyLadderIdx + 1
            nyMapLocked := false
            nyFinalGipReached := false
            float u2 = f_ladderUnit(nyLadderIdx)
            [mh2, ml2] = f_nyAnchoredMap(u2, sessionBiasDir, sessLow, sessHigh)
            nyLkSrcHigh := mh2
            nyLkSrcLow := ml2
            nyLkUnit := u2
            nyLkBase := f_ladderBase(nyLadderIdx)
            nyLkHalf := f_ladderHalf(nyLadderIdx)
        else
            // Wick outside the locked envelope (no close beyond) -> shift map in 1/2-unit steps.
            float halfStep = nyLkUnit / 2.0
            if sessionBiasDir == 1 and high > envHigh
                while nyLkSrcHigh + projectionCount * nyLkUnit < high
                    nyLkSrcHigh := nyLkSrcHigh + halfStep
                    nyLkSrcLow := nyLkSrcLow + halfStep
            if sessionBiasDir == -1 and low < envLow
                while nyLkSrcLow - projectionCount * nyLkUnit > low
                    nyLkSrcHigh := nyLkSrcHigh - halfStep
                    nyLkSrcLow := nyLkSrcLow - halfStep

// 4) Override the generic engine output for NY so all downstream drawing,
//    GIP/rebalance zones, table and hidden plots use the locked/anchored map.
if isNyEngineActive and not na(nyLkSrcHigh)
    srcHigh := nyLkSrcHigh
    srcLow := nyLkSrcLow
    rSize := nyLkUnit
    effectiveUnit := nyLkUnit
    effectiveBase := nyLkBase
    effectiveHalf := nyLkHalf
    effectiveReason := (nyMapLocked ? 'NY Locked (PO3 complete)' : nyFinalGipReached ? 'NY Complete' : 'NY Anchored') + ' L' + str.tostring(nyLadderIdx)
    effectiveLabel := f_candidateName(nyLkBase, nyLkHalf, nyLkUnit)
    if isBearish
        projHigh := srcHigh
        projLow := srcLow - projectionCount * rSize
        projLow
    else
        projLow := srcLow
        projHigh := srcHigh + projectionCount * rSize
        projHigh
    projEQ := (projHigh + projLow) / 2.0

// ============================= Drawing Arrays =============================
var array<box> allBoxes = array.new_box()
var array<line> allLines = array.new_line()
var array<label> allLabels = array.new_label()
var array<line> subdivLines = array.new_line()
var array<label> subdivLabels = array.new_label()
var table lvlTable = na

f_endTime() =>
    currentSessionEnd

var int _x1 = 0
var int _x2 = 0

drawBox(bHigh, bLow, bgClr, borderClr) =>
    array.push(allBoxes, box.new(_x1, bHigh, _x2, bLow, xloc = xloc.bar_time, bgcolor = bgClr, border_color = borderClr, border_width = 1))

drawZone(zoneHigh, zoneLow, bgClr, labelTxt, borderClr, showLbl) =>
    array.push(allBoxes, box.new(_x1, zoneHigh, _x2, zoneLow, xloc = xloc.bar_time, bgcolor = bgClr, border_color = borderClr, border_width = 1))
    if showLbl
        float mid = (zoneHigh + zoneLow) / 2.0
        array.push(allLabels, label.new(_x2, mid, labelTxt + ' ' + f_price(zoneHigh) + ' / ' + f_price(zoneLow), xloc = xloc.bar_time, style = label.style_label_left, color = rangeLabelBg, textcolor = rangeLabelTxt, size = f_textSize(rangeLabelSize)))

f_drawPDZones(bHigh, bLow) =>
    float rng = bHigh - bLow
    float uT = bLow + rng * (pdUpperTop / 100.0)
    float uB = bLow + rng * (pdUpperBot / 100.0)
    float lT = bLow + rng * (pdLowerTop / 100.0)
    float lB = bLow + rng * (pdLowerBot / 100.0)

    array.push(allBoxes, box.new(_x1, uT, _x2, uB, xloc = xloc.bar_time, bgcolor = pdZoneClr, border_color = pdBorderClr, border_width = 1))
    array.push(allBoxes, box.new(_x1, lT, _x2, lB, xloc = xloc.bar_time, bgcolor = pdZoneClr, border_color = pdBorderClr, border_width = 1))

    if pdShowLabels
        array.push(allLabels, label.new(_x2, (uT + uB) / 2.0, str.tostring(pdUpperBot, '#.#') + '-' + str.tostring(pdUpperTop, '#.#') + '%', xloc = xloc.bar_time, style = label.style_label_left, color = color.new(color.white, 100), textcolor = pdBorderClr, size = txtSize))
        array.push(allLabels, label.new(_x2, (lT + lB) / 2.0, str.tostring(pdLowerBot, '#.#') + '-' + str.tostring(pdLowerTop, '#.#') + '%', xloc = xloc.bar_time, style = label.style_label_left, color = color.new(color.white, 100), textcolor = pdBorderClr, size = txtSize))

// ============================= Main Draw Block =============================
// In Auto All Sessions mode, keep completed session drawings on the chart.
// At the start of each new session, release current-object references without deleting the objects.
if newSession and autoAllSessionsMode
    array.clear(allBoxes)
    array.clear(allLines)
    array.clear(allLabels)
    array.clear(subdivLines)
    array.clear(subdivLabels)

if waitingForSessionFpiCalibration and sessionWithinLookback
    if array.size(allBoxes) > 0
        for i = 0 to array.size(allBoxes) - 1 by 1
            box.delete(array.get(allBoxes, i))

    if array.size(allLines) > 0
        for i = 0 to array.size(allLines) - 1 by 1
            line.delete(array.get(allLines, i))

    if array.size(allLabels) > 0
        for i = 0 to array.size(allLabels) - 1 by 1
            label.delete(array.get(allLabels, i))

    if array.size(subdivLines) > 0
        for i = 0 to array.size(subdivLines) - 1 by 1
            line.delete(array.get(subdivLines, i))

    if array.size(subdivLabels) > 0
        for i = 0 to array.size(subdivLabels) - 1 by 1
            label.delete(array.get(subdivLabels, i))

    array.clear(allBoxes)
    array.clear(allLines)
    array.clear(allLabels)
    array.clear(subdivLines)
    array.clear(subdivLabels)

    if not na(lvlTable)
        table.delete(lvlTable)

if not waitingForSessionFpiCalibration and sessionWithinLookback and inSession and not na(srcHigh) and not na(srcLow) and not na(rSize) and not na(sessStartTime)

    if array.size(allBoxes) > 0
        for i = 0 to array.size(allBoxes) - 1 by 1
            box.delete(array.get(allBoxes, i))

    if array.size(allLines) > 0
        for i = 0 to array.size(allLines) - 1 by 1
            line.delete(array.get(allLines, i))

    if array.size(allLabels) > 0
        for i = 0 to array.size(allLabels) - 1 by 1
            label.delete(array.get(allLabels, i))

    if array.size(subdivLines) > 0
        for i = 0 to array.size(subdivLines) - 1 by 1
            line.delete(array.get(subdivLines, i))

    if array.size(subdivLabels) > 0
        for i = 0 to array.size(subdivLabels) - 1 by 1
            label.delete(array.get(subdivLabels, i))

    array.clear(allBoxes)
    array.clear(allLines)
    array.clear(allLabels)
    array.clear(subdivLines)
    array.clear(subdivLabels)

    int endTime = f_endTime()
    _x1 := sessStartTime
    _x2 := math.max(endTime, sessStartTime)

    useAsianLondonRangeOnly = asianLondonRangeOnlyMode and (activeSessionName == 'Asian' or activeSessionName == 'London')

    if useAsianLondonRangeOnly
        // Asian/London mode:
        // Do NOT create directional projections.
        // Draw only the PO3 ranges price actually enters/passes through, starting from the aligned source range.
        float sessionHighSeen = nz(sessHigh, high)
        float sessionLowSeen = nz(sessLow, low)
        int lowerSteps = int(math.max(0, math.ceil((srcLow - sessionLowSeen) / rSize)))
        int upperSteps = int(math.max(0, math.ceil((sessionHighSeen - srcHigh) / rSize)))
        int firstStep = -lowerSteps
        int lastStep = upperSteps
        int rawRangeBoxCount = lastStep - firstStep + 1
        int rangeBoxCount = math.min(math.max(rawRangeBoxCount, 1), maxAsianLondonRangeBoxes)

        for rb = 0 to rangeBoxCount - 1 by 1
            int step = firstStep + rb
            float boxLow = srcLow + step * rSize
            float boxHigh = srcHigh + step * rSize
            float boxMid = (boxHigh + boxLow) / 2.0
            bool currentBoxTouched = sessionHighSeen >= boxLow and sessionLowSeen <= boxHigh

            if currentBoxTouched
                drawBox(boxHigh, boxLow, sourceBoxClr, sourceBorderClr)

                array.push(allLines, line.new(_x1, boxMid, _x2, boxMid, xloc = xloc.bar_time, color = eqClr, style = line.style_dashed, width = 1))
                array.push(allLabels, label.new(_x2, boxMid, '#' + str.tostring(rb + 1) + ' EQ: ' + f_price(boxMid), xloc = xloc.bar_time, style = label.style_label_left, color = color.new(color.white, 100), textcolor = color.new(eqClr, 25), size = txtSize))

                if showSourceSubdivisions
                    int divisions = subdivisionType == '1/4' ? 4 : 8
                    float boxRange = boxHigh - boxLow

                    for j = 1 to divisions - 1 by 1
                        float sLvl = boxLow + boxRange * j / divisions
                        string fracTxt = f_fracLabel(j, divisions)

                        if not(divisions == 8 and j == 4)
                            array.push(allLines, line.new(_x1, sLvl, _x2, sLvl, xloc = xloc.bar_time, color = subdivLineColor, style = line.style_dashed, width = 1))
                            array.push(allLabels, label.new(_x2, sLvl, fracTxt + ': ' + f_price(sLvl), xloc = xloc.bar_time, style = label.style_label_left, color = color.new(color.white, 100), textcolor = subdivLineColor, size = txtSize))

                if showPDZones
                    f_drawPDZones(boxHigh, boxLow)

                if showAllGIPLevels
                    float gipBandHalf = rSize * (allGIPBandPct / 100.0)
                    float gMidTop = f_ceil_to_tick(boxMid + gipBandHalf)
                    float gMidBot = f_floor_to_tick(boxMid - gipBandHalf)
                    float gLowTop = f_ceil_to_tick(boxLow + gipBandHalf)
                    float gLowBot = f_floor_to_tick(boxLow - gipBandHalf)
                    float gHighTop = f_ceil_to_tick(boxHigh + gipBandHalf)
                    float gHighBot = f_floor_to_tick(boxHigh - gipBandHalf)

                    drawZone(gMidTop, gMidBot, allGIPLevelsClr, '#' + str.tostring(rb + 1) + ' GIP Mid', allGIPBorderClr, showAllGIPLabels)
                    drawZone(gLowTop, gLowBot, allGIPLevelsClr, '#' + str.tostring(rb + 1) + ' GIP Low', allGIPBorderClr, showAllGIPLabels)
                    drawZone(gHighTop, gHighBot, allGIPLevelsClr, '#' + str.tostring(rb + 1) + ' GIP High', allGIPBorderClr, showAllGIPLabels)

        int rangeLblX = _x1 + int((_x2 - _x1) / 2)
        float rangeLblY = nz(sessHigh, high)
        array.push(allLabels, label.new(rangeLblX, rangeLblY, activeSessionName + ' PO3 Ranges: ' + effectiveLabel + ' | active ranges', xloc = xloc.bar_time, style = label.style_label_down, color = color.new(sourceBorderClr, 45), textcolor = color.new(lblTextClr, 15), size = txtSize))

    else

        // ============================= Source Range Box =============================
        drawBox(srcHigh, srcLow, sourceBoxClr, sourceBorderClr)

        if showPDZones and pdApplyToSource
            f_drawPDZones(srcHigh, srcLow)

        srcEQ = (srcHigh + srcLow) / 2.0

        array.push(allLines, line.new(_x1, srcEQ, _x2, srcEQ, xloc = xloc.bar_time, color = eqClr, style = line.style_dashed, width = 1))

        if showSourceSubdivisions
            int divisions = subdivisionType == '1/4' ? 4 : 8
            float srcRange = srcHigh - srcLow

            for j = 1 to divisions - 1 by 1
                float sLvl = srcLow + srcRange * j / divisions
                string fracTxt = f_fracLabel(j, divisions)

                if not(divisions == 8 and j == 4)
                    array.push(allLines, line.new(_x1, sLvl, _x2, sLvl, xloc = xloc.bar_time, color = subdivLineColor, style = line.style_dashed, width = 2))
                    array.push(allLabels, label.new(_x2, sLvl, fracTxt + ': ' + f_price(sLvl), xloc = xloc.bar_time, style = label.style_label_left, color = color.new(color.white, 100), textcolor = subdivLineColor, size = txtSize))

        string rlbl = effectiveLabel
        string slbl = appliedShiftUnits == -2.0 ? ' v2' : appliedShiftUnits == -1.5 ? ' v1.5' : appliedShiftUnits == -1.0 ? ' v1' : appliedShiftUnits == -0.5 ? ' v1/2' : appliedShiftUnits == 0.5 ? ' ^1/2' : appliedShiftUnits == 1.0 ? ' ^1' : appliedShiftUnits == 1.5 ? ' ^1.5' : appliedShiftUnits == 2.0 ? ' ^2' : ''
        slbl := rangeShift == 'Auto Align' and slbl != '' ? slbl + ' auto' : rangeShift == 'Auto Align' ? ' auto' : slbl

        float srcLblY = isBearish ? srcLow : srcHigh
        int srcLblX = _x1 + int((_x2 - _x1) / 2)

        array.push(allLabels, label.new(srcLblX, srcLblY, 'Source PO3: ' + rlbl + slbl, xloc = xloc.bar_time, style = isBearish ? label.style_label_down : label.style_label_up, color = color.new(sourceBorderClr, 40), textcolor = lblTextClr, size = txtSize))

        array.push(allLabels, label.new(_x2, srcHigh, 'Src High: ' + f_price(srcHigh), xloc = xloc.bar_time, style = label.style_label_left, color = color.new(color.white, 100), textcolor = lblTextClr, size = txtSize))

        array.push(allLabels, label.new(_x2, srcEQ, 'Src EQ: ' + f_price(srcEQ), xloc = xloc.bar_time, style = label.style_label_left, color = color.new(color.white, 100), textcolor = color.new(#a0a0a0, 20), size = txtSize))

        array.push(allLabels, label.new(_x2, srcLow, 'Src Low: ' + f_price(srcLow), xloc = xloc.bar_time, style = label.style_label_left, color = color.new(color.white, 100), textcolor = lblTextClr, size = txtSize))

        // ============================= Projection Boxes =============================
        for i = 1 to projectionCount by 1
            float bxHigh = na
            float bxLow = na

            if isBearish
                bxHigh := srcLow - (i - 1) * rSize
                bxLow := srcLow - i * rSize
                bxLow
            else
                bxLow := srcHigh + (i - 1) * rSize
                bxHigh := srcHigh + i * rSize
                bxHigh

            drawBox(bxHigh, bxLow, projBoxClr, projBorderClrIn)

            if showPDZones
                f_drawPDZones(bxHigh, bxLow)

            if showSubEQs
                float subEQ = (bxHigh + bxLow) / 2.0

                array.push(allLines, line.new(_x1, subEQ, _x2, subEQ, xloc = xloc.bar_time, color = subEQClrIn, style = line.style_dotted, width = 1))

                array.push(allLabels, label.new(_x2, subEQ, '#' + str.tostring(i) + ' EQ: ' + f_price(subEQ), xloc = xloc.bar_time, style = label.style_label_left, color = color.new(color.white, 100), textcolor = subEQClrIn, size = txtSize))

            if i == projectionCount
                float tLvl = isBearish ? bxHigh : bxLow
                float eLvl = isBearish ? bxLow : bxHigh

                array.push(allLines, line.new(_x1, tLvl, _x2, tLvl, xloc = xloc.bar_time, color = thickLineClr, width = 3, style = line.style_solid))

                array.push(allLabels, label.new(_x2, tLvl, 'Target: ' + f_price(tLvl), xloc = xloc.bar_time, style = label.style_label_left, color = color.new(thickLineClr, 60), textcolor = lblTextClr, size = txtSize))

                array.push(allLines, line.new(_x1, eLvl, _x2, eLvl, xloc = xloc.bar_time, color = thickLineClr, width = 3, style = line.style_solid))

                array.push(allLabels, label.new(_x2, eLvl, 'Range Extreme: ' + f_price(eLvl), xloc = xloc.bar_time, style = label.style_label_left, color = color.new(thickLineClr, 60), textcolor = lblTextClr, size = txtSize))

        // ============================= All GIP Levels =============================
        // Source box: bottom + midpoint + top
        // Projection boxes: midpoint + directional edge only
        if showAllGIPLevels
            float gipBandHalf = rSize * (allGIPBandPct / 100.0)

            for gBox = 0 to projectionCount by 1
                float gHigh = na
                float gLow = na
                string gName = ''

                if gBox == 0
                    gHigh := srcHigh
                    gLow := srcLow
                    gName := 'Src'
                    gName
                else
                    if isBearish
                        gHigh := srcLow - (gBox - 1) * rSize
                        gLow := srcLow - gBox * rSize
                        gLow
                    else
                        gLow := srcHigh + (gBox - 1) * rSize
                        gHigh := srcHigh + gBox * rSize
                        gHigh
                    gName := '#' + str.tostring(gBox)
                    gName

                float gMidCenter = (gHigh + gLow) / 2.0

                float gMidTop = f_ceil_to_tick(gMidCenter + gipBandHalf)
                float gMidBot = f_floor_to_tick(gMidCenter - gipBandHalf)

                drawZone(gMidTop, gMidBot, allGIPLevelsClr, gName + ' GIP Mid', allGIPBorderClr, showAllGIPLabels)

                if gBox == 0
                    float gLowTop = f_ceil_to_tick(gLow + gipBandHalf)
                    float gLowBot = f_floor_to_tick(gLow - gipBandHalf)
                    float gHighTop = f_ceil_to_tick(gHigh + gipBandHalf)
                    float gHighBot = f_floor_to_tick(gHigh - gipBandHalf)

                    drawZone(gLowTop, gLowBot, allGIPLevelsClr, gName + ' GIP Low', allGIPBorderClr, showAllGIPLabels)
                    drawZone(gHighTop, gHighBot, allGIPLevelsClr, gName + ' GIP High', allGIPBorderClr, showAllGIPLabels)
                else
                    float gEdgeCenter = isBearish ? gLow : gHigh
                    float gEdgeTop = f_ceil_to_tick(gEdgeCenter + gipBandHalf)
                    float gEdgeBot = f_floor_to_tick(gEdgeCenter - gipBandHalf)

                    drawZone(gEdgeTop, gEdgeBot, allGIPLevelsClr, gName + ' GIP Edge', allGIPBorderClr, showAllGIPLabels)

        // ============================= SMART Range High / Low Zones =============================
        if showRangeZones
            float gipBandBelow = 0.111 * rSize
            float gipBandAbove = 0.110 * rSize

            float selectedHighTop = na
            float selectedHighBot = na
            float selectedHighKey = na

            float selectedLowTop = na
            float selectedLowBot = na
            float selectedLowKey = na

            bool foundHighCandidate = false
            bool foundLowCandidate = false

            // ---------- Internal GIP Candidate Scan ----------
            // Source box scans low + midpoint + high.
            // Projection boxes scan midpoint + directional edge.
            for scanBox = 0 to projectionCount by 1
                float sHigh = na
                float sLow = na

                if scanBox == 0
                    sHigh := srcHigh
                    sLow := srcLow
                    sLow
                else
                    if isBearish
                        sHigh := srcLow - (scanBox - 1) * rSize
                        sLow := srcLow - scanBox * rSize
                        sLow
                    else
                        sLow := srcHigh + (scanBox - 1) * rSize
                        sHigh := srcHigh + scanBox * rSize
                        sHigh

                float sMid = (sHigh + sLow) / 2.0

                if scanBox == 0
                    for gp = 0 to 2 by 1
                        float gipCenter = gp == 0 ? sLow : gp == 1 ? sMid : sHigh
                        float gipTop = f_ceil_to_tick(gipCenter + gipBandAbove)
                        float gipBot = f_floor_to_tick(gipCenter - gipBandBelow)
                        bool gipTouched = f_zoneTouched(gipTop, gipBot, projWindowHigh, projWindowLow)

                        if gipTouched
                            float highKey = gipTop
                            float lowKey = gipBot

                            if not foundHighCandidate or highKey > selectedHighKey
                                selectedHighTop := gipTop
                                selectedHighBot := gipBot
                                selectedHighKey := highKey
                                foundHighCandidate := true
                                foundHighCandidate

                            if not foundLowCandidate or lowKey < selectedLowKey
                                selectedLowTop := gipTop
                                selectedLowBot := gipBot
                                selectedLowKey := lowKey
                                foundLowCandidate := true
                                foundLowCandidate
                else
                    float sEdge = isBearish ? sLow : sHigh

                    for gp = 0 to 1 by 1
                        float gipCenter = gp == 0 ? sMid : sEdge
                        float gipTop = f_ceil_to_tick(gipCenter + gipBandAbove)
                        float gipBot = f_floor_to_tick(gipCenter - gipBandBelow)
                        bool gipTouched = f_zoneTouched(gipTop, gipBot, projWindowHigh, projWindowLow)

                        if gipTouched
                            float highKey = gipTop
                            float lowKey = gipBot

                            if not foundHighCandidate or highKey > selectedHighKey
                                selectedHighTop := gipTop
                                selectedHighBot := gipBot
                                selectedHighKey := highKey
                                foundHighCandidate := true
                                foundHighCandidate

                            if not foundLowCandidate or lowKey < selectedLowKey
                                selectedLowTop := gipTop
                                selectedLowBot := gipBot
                                selectedLowKey := lowKey
                                foundLowCandidate := true
                                foundLowCandidate

            // ---------- Internal Rebalance Candidate Scan ----------
            int totalBoxesForRebalance = projectionCount + 1

            for rb = 0 to totalBoxesForRebalance - 1 by 1
                float bHigh = na
                float bLow = na

                if rb == 0
                    bHigh := srcHigh
                    bLow := srcLow
                    bLow
                else
                    if isBearish
                        bHigh := srcLow - (rb - 1) * rSize
                        bLow := srcLow - rb * rSize
                        bLow
                    else
                        bLow := srcHigh + (rb - 1) * rSize
                        bHigh := srcHigh + rb * rSize
                        bHigh

                float bRng = bHigh - bLow

                float rbUpperTop = f_ceil_to_tick(bLow + bRng * (pdUpperTop / 100.0))
                float rbUpperBot = f_floor_to_tick(bLow + bRng * (pdUpperBot / 100.0))
                float rbLowerTop = f_ceil_to_tick(bLow + bRng * (pdLowerTop / 100.0))
                float rbLowerBot = f_floor_to_tick(bLow + bRng * (pdLowerBot / 100.0))

                bool upperTouched = f_zoneTouched(rbUpperTop, rbUpperBot, projWindowHigh, projWindowLow)
                bool lowerTouched = f_zoneTouched(rbLowerTop, rbLowerBot, projWindowHigh, projWindowLow)

                if upperTouched
                    float upperHighKey = rbUpperTop
                    float upperLowKey = rbUpperBot

                    if not foundHighCandidate or upperHighKey > selectedHighKey
                        selectedHighTop := rbUpperTop
                        selectedHighBot := rbUpperBot
                        selectedHighKey := upperHighKey
                        foundHighCandidate := true
                        foundHighCandidate

                    if not foundLowCandidate or upperLowKey < selectedLowKey
                        selectedLowTop := rbUpperTop
                        selectedLowBot := rbUpperBot
                        selectedLowKey := upperLowKey
                        foundLowCandidate := true
                        foundLowCandidate

                if lowerTouched
                    float lowerHighKey = rbLowerTop
                    float lowerLowKey = rbLowerBot

                    if not foundHighCandidate or lowerHighKey > selectedHighKey
                        selectedHighTop := rbLowerTop
                        selectedHighBot := rbLowerBot
                        selectedHighKey := lowerHighKey
                        foundHighCandidate := true
                        foundHighCandidate

                    if not foundLowCandidate or lowerLowKey < selectedLowKey
                        selectedLowTop := rbLowerTop
                        selectedLowBot := rbLowerBot
                        selectedLowKey := lowerLowKey
                        foundLowCandidate := true
                        foundLowCandidate

            if foundHighCandidate and foundLowCandidate
                bool sameZone = math.abs(selectedHighTop - selectedLowTop) < syminfo.mintick and math.abs(selectedHighBot - selectedLowBot) < syminfo.mintick

                if sameZone
                    drawZone(selectedHighTop, selectedHighBot, sharedZoneClr, 'Range High / Low', rangeBoxBorder, showRangeLabels)
                else
                    drawZone(selectedHighTop, selectedHighBot, rangeHighClr, 'Range High', rangeBoxBorder, showRangeLabels)
                    drawZone(selectedLowTop, selectedLowBot, rangeLowClr, 'Range Low', rangeBoxBorder, showRangeLabels)

            else if foundHighCandidate
                drawZone(selectedHighTop, selectedHighBot, rangeHighClr, 'Range High', rangeBoxBorder, showRangeLabels)

            else if foundLowCandidate
                drawZone(selectedLowTop, selectedLowBot, rangeLowClr, 'Range Low', rangeBoxBorder, showRangeLabels)

        // ============================= Levels Table =============================
        if showTable
            if not na(lvlTable)
                table.delete(lvlTable)

            tPos = position.top_right

            if tablePosition == 'Top Left'
                tPos := position.top_left
                tPos
            else if tablePosition == 'Top Right'
                tPos := position.top_right
                tPos
            else if tablePosition == 'Bottom Left'
                tPos := position.bottom_left
                tPos
            else
                tPos := position.bottom_right
                tPos

            lvlTable := table.new(position = tPos, columns = 2, rows = 9, bgcolor = tableBgClr, border_width = 1, border_color = tableBorderClr)

            string po3Lbl = effectiveLabel
            string shTxt = appliedShiftUnits == -1.0 ? ' v1' : appliedShiftUnits == -0.5 ? ' v1/2' : appliedShiftUnits == 0.5 ? ' ^1/2' : appliedShiftUnits == 1.0 ? ' ^1' : ''
            shTxt := rangeShift == 'Auto Align' and shTxt != '' ? shTxt + ' auto' : rangeShift == 'Auto Align' ? ' auto' : shTxt

            table.cell(lvlTable, 0, 0, autoAllSessionsMode ? activeSessionName + ' PO3' : 'PO3 Projection', text_color = lblTextClr, text_size = tblTxtSize, bgcolor = tableHeaderClr)

            table.cell(lvlTable, 1, 0, sessionBiasText + ' | ' + po3Lbl + shTxt, text_color = lblTextClr, text_size = tblTxtSize, bgcolor = tableHeaderClr)

            table.cell(lvlTable, 0, 1, 'Range High', text_color = color.new(#7ab8a0, 0), text_size = tblTxtSize, bgcolor = color.new(#7ab8a0, 88))

            table.cell(lvlTable, 1, 1, f_price(srcHigh), text_color = color.new(#7ab8a0, 0), text_size = tblTxtSize, bgcolor = color.new(#7ab8a0, 88))

            table.cell(lvlTable, 0, 2, 'Unit: ' + str.tostring(rSize, '#.####'), text_color = color.new(#a0a0a0, 0), text_size = tblTxtSize, bgcolor = color.new(#a0a0a0, 88))

            table.cell(lvlTable, 1, 2, f_price(projEQ), text_color = color.new(#a0a0a0, 0), text_size = tblTxtSize, bgcolor = color.new(#a0a0a0, 88))

            float termPx = isBearish ? srcLow - (projectionCount - 1) * rSize : srcHigh + (projectionCount - 1) * rSize

            table.cell(lvlTable, 0, 3, 'Target', text_color = color.new(#c4a35a, 0), text_size = tblTxtSize, bgcolor = color.new(#c4a35a, 88))

            table.cell(lvlTable, 1, 3, f_price(termPx), text_color = color.new(#c4a35a, 0), text_size = tblTxtSize, bgcolor = color.new(#c4a35a, 88))

            table.cell(lvlTable, 0, 4, 'Extreme', text_color = color.new(#c45050, 0), text_size = tblTxtSize, bgcolor = color.new(#c45050, 88))

            table.cell(lvlTable, 1, 4, f_price(isBearish ? projLow : projHigh), text_color = color.new(#c45050, 0), text_size = tblTxtSize, bgcolor = color.new(#c45050, 88))

            table.cell(lvlTable, 0, 5, 'Mode', text_color = color.new(#d6d6d6, 0), text_size = tblTxtSize, bgcolor = color.new(#505050, 88))
            table.cell(lvlTable, 1, 5, po3SelectionMode, text_color = color.new(#d6d6d6, 0), text_size = tblTxtSize, bgcolor = color.new(#505050, 88))

            table.cell(lvlTable, 0, 6, autoDataSource + ' / Exp.', text_color = color.new(#d6d6d6, 0), text_size = tblTxtSize, bgcolor = color.new(#505050, 88))
            table.cell(lvlTable, 1, 6, str.tostring(adrPoints, '#.####') + ' / ' + str.tostring(expectedSessionMove, '#.####'), text_color = color.new(#d6d6d6, 0), text_size = tblTxtSize, bgcolor = color.new(#505050, 88))

            table.cell(lvlTable, 0, 7, 'Unit / Conf.', text_color = color.new(#d6d6d6, 0), text_size = tblTxtSize, bgcolor = color.new(#505050, 88))
            table.cell(lvlTable, 1, 7, effectiveLabel + ' / ' + str.tostring(autoConfidence, '#.##') + '%', text_color = color.new(#d6d6d6, 0), text_size = tblTxtSize, bgcolor = color.new(#505050, 88))

            table.cell(lvlTable, 0, 8, 'Reason', text_color = color.new(#d6d6d6, 0), text_size = tblTxtSize, bgcolor = color.new(#505050, 88))
            table.cell(lvlTable, 1, 8, sessionBiasReason + (sessionMacroFpiDir != 0 ? ' | Macro ' + f_price(sessionMacroFpiMid) : '') + ' | ' + effectiveReason + (useAsianLondonFinalRectangleAlignment ? ' | A/L 5thCenter' : '') + (extraShiftUnits != 0.0 ? ' | ManualShift ' + str.tostring(extraShiftUnits, '#.##') : '') + ' | Move ' + str.tostring(autoSizingMove, '#.##') + ' | F ' + str.tostring(autoPhaseFactor, '#.##') + ' | Sh ' + str.tostring(appliedShiftUnits, '#.##') + ' | Body ' + str.tostring(bodyRangeForAlignment, '#.##') + (isSPFuturesProfile ? ' | ES LB ' + str.tostring(spFuturesStructureLookbackBars) : isForexPairProfile ? ' | FX LB ' + str.tostring(forexStructureLookbackBars) : isMetalsProfile ? ' | M LB ' + str.tostring(metalsStructureLookbackBars) : ''), text_color = color.new(#d6d6d6, 0), text_size = tblTxtSize, bgcolor = color.new(#505050, 88))

// ============================= PO3 Target Bridge Hidden Plots =============================
// Pine cannot directly read another script's drawings, so the bot duplicates this target math internally.
// These plots expose the same final target/GIP/rebalance levels in the data window for verification.
plot(po3FinalTarget, "PO3 Final 4th Deviation Target", display = display.none)
plot(po3FinalRebalanceA, "PO3 Final Rebalance A", display = display.none)
plot(po3FinalRebalanceB, "PO3 Final Rebalance B", display = display.none)
plot(po3FinalGip, "PO3 Final GIP", display = display.none)
````
