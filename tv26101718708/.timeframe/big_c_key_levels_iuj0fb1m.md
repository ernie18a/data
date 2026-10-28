# Big C Key Levels

- url: https://www.tradingview.com/script/Iuj0Fb1m-Big-C-Key-Levels/
- type: indicator
- pine_id: PUB;48ab44d62b874db8849331ad5297b999
- version: 2.0

## Description

Big C Key Levels plots the most important price levels for intraday trading — all in one clean, customizable indicator.
Levels included:

CDH / CDL — Current Day High and Low, updates live as the session develops
PMH / PML — Premarket High and Low, locked in at 9:30 AM EST
PDH / PDL — Previous Day High and Low
PWH / PWL — Previous Week High and Low

Features:

Full customization — colors, line style, line width, and show/hide toggles for each level group
Alert system built in — set alerts for any level break directly from the indicator
Clean visual hierarchy — each level group has its own distinct style so your chart never looks cluttered
Works on all intraday timeframes from 30 seconds up to 4H

How to use:
Open Settings → Inputs to customize each level group to match your chart setup. Use the Alert dropdown to set notifications on any level break.

## Source Code

````pine
//@version=6
indicator("Big C Key Levels v1.0", overlay = true, max_lines_count = 100, max_labels_count = 100, max_boxes_count = 20)

// ============================================================
// Big C Key Levels v1.0  |  Phase 5 Polish Build
// Clean key-level map for structure + awareness only.
//
// Phase 1:
// - NY session/timezone logic
// - Manual CDH/CDL tracking
// - PMH/PML daily line reset
// - Dynamic alert() system
// - Confirmed-close alert option
// - Optional once-per-level/action-per-day limiter
//
// Phase 2:
// - ORH/ORL
// - Previous Close
// - Day Open
// - Previous Month High/Low
//
// Phase 3:
// - Break alerts
// - Confirmed-close rejection alerts with cooldown
// - Proximity alerts
//
// Phase 4:
// - PM + OR range shading
// - Staggered right-side labels
// - Visual hierarchy + nearest level highlight
// - Broken level flip after confirmed close + retest hold
// - Real reclaim alerts based on level state
//
// Phase 5:
// - Version header
// - Cleaner settings layout
// - Retest buffer moved to Visual Settings
// - Final naming polish
// - Flip marker invalidation
// - Live OR visibility polish
// - Automatic exchange timezone default
// - Lighter PM/OR fill defaults
// - Wider OR label spacing
// - Consistent OR label y-offset
// - Grouped alert toggles
// - Phone-friendly alert message format
// ============================================================

// --- Inputs: Session Settings ---
var string grpSession = "Session Settings"
tzMode = input.string("Exchange", title = "Timezone", group = grpSession, options = ["Exchange", "America/New_York", "America/Chicago", "America/Denver", "America/Los_Angeles", "Europe/London", "Europe/Berlin", "Asia/Tokyo", "Asia/Hong_Kong", "Australia/Sydney", "Etc/UTC"])
activeTz = tzMode == "Exchange" ? syminfo.timezone : tzMode
premarketSession = input.session("0400-0929:23456", title = "Premarket Session", group = grpSession)
regularSession   = input.session("0930-1600:23456", title = "Regular Session", group = grpSession)

// --- Inputs: CDH/CDL ---
var string grpCDH = "CDH / CDL Settings"
showCDH  = input.bool(true,      title = "Show CDH/CDL", group = grpCDH)
colorCDH = input.color(#00C087,  title = "CDH Color",    group = grpCDH)
colorCDL = input.color(#FF4D4D,  title = "CDL Color",    group = grpCDH)
cdhWidth = input.int(1,          title = "Line Width",   group = grpCDH, minval = 1, maxval = 4)
cdhStyle = input.string("Solid", title = "Line Style",   group = grpCDH, options = ["Solid", "Dashed", "Dotted"])

// --- Inputs: PMH/PML ---
var string grpPM = "Premarket Settings"
showPM       = input.bool(true, title = "Show PMH/PML", group = grpPM, inline = "pmShow")
showPMFill   = input.bool(true, title = "Shade", group = grpPM, inline = "pmShow")
colorPMH     = input.color(#FF9800,   title = "PMH Color",    group = grpPM)
colorPML     = input.color(#E65100,   title = "PML Color",    group = grpPM)
pmWidth      = input.int(2, title = "Width", group = grpPM, minval = 1, maxval = 4, inline = "pmLine")
pmStyle      = input.string("Dashed", title = "Style", group = grpPM, options = ["Solid", "Dashed", "Dotted"], inline = "pmLine")
pmFillTransp = input.int(95, title = "PM Fill Transparency", group = grpPM, minval = 70, maxval = 100)

// --- Inputs: ORH/ORL ---
var string grpOR = "Opening Range Settings"
showOR       = input.bool(true, title = "Show ORH/ORL", group = grpOR, inline = "orShow")
showORFill   = input.bool(true, title = "Shade", group = grpOR, inline = "orShow")
orMinutes    = input.int(15,         title = "Opening Range Minutes", group = grpOR, options = [5, 15, 30, 60])
colorORH     = input.color(#2196F3,  title = "ORH Color",             group = grpOR)
colorORL     = input.color(#1976D2,  title = "ORL Color",             group = grpOR)
orWidth      = input.int(2, title = "Width", group = grpOR, minval = 1, maxval = 4, inline = "orLine")
orStyle      = input.string("Solid", title = "Style", group = grpOR, options = ["Solid", "Dashed", "Dotted"], inline = "orLine")
orFillTransp = input.int(97, title = "OR Fill Transparency", group = grpOR, minval = 70, maxval = 100)

// --- Inputs: Previous Close ---
var string grpPC = "Previous Close Settings"
showPC  = input.bool(true,       title = "Show Previous Close",  group = grpPC)
colorPC = input.color(#FFD54F,   title = "Previous Close Color", group = grpPC)
pcWidth = input.int(1,           title = "Line Width",           group = grpPC, minval = 1, maxval = 4)
pcStyle = input.string("Dashed", title = "Line Style",           group = grpPC, options = ["Solid", "Dashed", "Dotted"])

// --- Inputs: Day Open ---
var string grpDO = "Day Open Settings"
showDO  = input.bool(false,      title = "Show Day Open",  group = grpDO)
colorDO = input.color(#FFFFFF,   title = "Day Open Color", group = grpDO)
doWidth = input.int(1,           title = "Line Width",     group = grpDO, minval = 1, maxval = 4)
doStyle = input.string("Dotted", title = "Line Style",     group = grpDO, options = ["Solid", "Dashed", "Dotted"])

// --- Inputs: PDH/PDL ---
var string grpPD = "Previous Day Settings"
showPD   = input.bool(true,      title = "Show PDH/PDL", group = grpPD)
colorPDH = input.color(#B0BEC5,  title = "PDH Color",    group = grpPD)
colorPDL = input.color(#B0BEC5,  title = "PDL Color",    group = grpPD)
pdWidth  = input.int(1,          title = "Line Width",   group = grpPD, minval = 1, maxval = 4)
pdStyle  = input.string("Solid", title = "Line Style",   group = grpPD, options = ["Solid", "Dashed", "Dotted"])

// --- Inputs: PWH/PWL ---
var string grpPW = "Previous Week Settings"
showPW   = input.bool(true,       title = "Show PWH/PWL", group = grpPW)
colorPWH = input.color(#7E57C2,   title = "PWH Color",    group = grpPW)
colorPWL = input.color(#7E57C2,   title = "PWL Color",    group = grpPW)
pwWidth  = input.int(1,           title = "Line Width",   group = grpPW, minval = 1, maxval = 4)
pwStyle  = input.string("Dotted", title = "Line Style",   group = grpPW, options = ["Solid", "Dashed", "Dotted"])

// --- Inputs: Previous Month ---
var string grpPMo = "Previous Month Settings"
showPMo   = input.bool(false,      title = "Show PMoH/PMoL", group = grpPMo)
colorPMoH = input.color(#26A69A,   title = "PMoH Color",     group = grpPMo)
colorPMoL = input.color(#26A69A,   title = "PMoL Color",     group = grpPMo)
pmoWidth  = input.int(1,           title = "Line Width",     group = grpPMo, minval = 1, maxval = 4)
pmoStyle  = input.string("Dotted", title = "Line Style",     group = grpPMo, options = ["Solid", "Dashed", "Dotted"])

// --- Inputs: Visuals ---
var string grpVisual = "Visual Settings"
labelBaseOffset       = input.int(2, title = "Base Label Offset", group = grpVisual, minval = 1, maxval = 20, inline = "labels")
labelStaggerStep      = input.int(2, title = "Stagger Step", group = grpVisual, minval = 1, maxval = 10, inline = "labels")
orLabelExtraOffset    = input.int(70, title = "OR Label Extra Offset", group = grpVisual, minval = 1, maxval = 200)
orLabelYNudgeTicks    = input.int(10, title = "OR Label Y Offset Ticks", group = grpVisual, minval = 0, maxval = 100)
showNearestHighlight  = input.bool(true, title = "Highlight Nearest S/R", group = grpVisual, inline = "nearest")
nearestWidthBoost     = input.int(1, title = "Width Boost", group = grpVisual, minval = 1, maxval = 3, inline = "nearest")
showFlipLabels        = input.bool(true, title = "Show Flip Marker In Labels", group = grpVisual)
retestAtrBuffer       = input.float(0.10, title = "Flip Retest ATR Buffer", group = grpVisual, minval = 0.01, step = 0.01)

// --- Inputs: Alerts ---
var string grpAlerts = "Alert Settings"
alertOnClose          = input.bool(true, title = "Confirmed Close Only", group = grpAlerts, inline = "alertMain")
limitAlertsOncePerDay = input.bool(false, title = "Once Per Level/Day", group = grpAlerts, inline = "alertMain")

enableBreakAlerts     = input.bool(true, title = "Break", group = grpAlerts, inline = "alertTypes1")
enableRejectionAlerts = input.bool(true, title = "Reject", group = grpAlerts, inline = "alertTypes1")
enableReclaimAlerts   = input.bool(false, title = "Reclaim", group = grpAlerts, inline = "alertTypes2")
enableProximityAlerts = input.bool(false, title = "Proximity", group = grpAlerts, inline = "alertTypes2")

proximityMode    = input.string("ATR", title = "Proximity Mode", group = grpAlerts, options = ["ATR", "Percent", "Dollar"])
proximityAtrLen  = input.int(14, title = "ATR Length", group = grpAlerts, minval = 1, inline = "proxATR")
proximityATR     = input.float(0.25, title = "ATR Dist", group = grpAlerts, minval = 0.01, step = 0.01, inline = "proxATR")
proximityPercent = input.float(0.15, title = "% Dist", group = grpAlerts, minval = 0.01, step = 0.01, inline = "proxOther")
proximityDollar  = input.float(0.25, title = "$ Dist", group = grpAlerts, minval = 0.01, step = 0.01, inline = "proxOther")

alertCDHL  = input.bool(false, title = "CDH/CDL Alerts", group = grpAlerts)
alertPMHL  = input.bool(true,  title = "PMH/PML Alerts", group = grpAlerts)
alertORHL  = input.bool(true,  title = "ORH/ORL Alerts", group = grpAlerts)
alertPC    = input.bool(true,  title = "PC Alerts", group = grpAlerts)
alertDO    = input.bool(false, title = "DO Alerts", group = grpAlerts)
alertPDHL  = input.bool(true,  title = "PDH/PDL Alerts", group = grpAlerts)
alertPWHL  = input.bool(false, title = "PWH/PWL Alerts", group = grpAlerts)
alertPMoHL = input.bool(false, title = "PMoH/PMoL Alerts", group = grpAlerts)

// --- Helpers ---
f_lineStyle(s) =>
    s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid

f_levelDistance(level, atrVal) =>
    proximityMode == "ATR" ? atrVal * proximityATR :
     proximityMode == "Percent" ? math.abs(level) * proximityPercent * 0.01 :
     proximityDollar

f_nearLevel(level, atrVal) =>
    not na(level) and math.abs(close - level) <= f_levelDistance(level, atrVal)

f_canFire(key, firedString) =>
    not limitAlertsOncePerDay or not str.contains(firedString, "|" + key + "|")

f_markFire(key, firedString) =>
    firedString + "|" + key + "|"

f_sendAlert(txt) =>
    alert(syminfo.ticker + " | " + txt + " | " + str.tostring(close, format.mintick), alert.freq_once_per_bar)

f_flipText(supportFlip, resistanceFlip) =>
    showFlipLabels and supportFlip ? " ✓S" : showFlipLabels and resistanceFlip ? " ✓R" : ""

f_width(baseWidth, isNearest) =>
    showNearestHighlight and isNearest ? math.min(baseWidth + nearestWidthBoost, 5) : baseWidth

f_levelChanged(currentLevel, priorLevel) =>
    not na(currentLevel) and (na(priorLevel) or math.abs(currentLevel - priorLevel) > syminfo.mintick)

cdhLineStyle = f_lineStyle(cdhStyle)
pmLineStyle  = f_lineStyle(pmStyle)
orLineStyle  = f_lineStyle(orStyle)
pcLineStyle  = f_lineStyle(pcStyle)
doLineStyle  = f_lineStyle(doStyle)
pdLineStyle  = f_lineStyle(pdStyle)
pwLineStyle  = f_lineStyle(pwStyle)
pmoLineStyle = f_lineStyle(pmoStyle)

invisible = color.new(color.white, 100)

// --- Session logic ---
nyDayTime   = time("D", "0000-2359:1234567", activeTz)
isNewDay    = ta.change(nyDayTime) != 0
inPremarket = not na(time(timeframe.period, premarketSession, activeTz))
inRegular   = not na(time(timeframe.period, regularSession, activeTz))
sessionOpen = inRegular and not (inRegular[1] == true)

// --- Manual Current Day H/L Tracking ---
var float cdhLive = na
var float cdlLive = na
if isNewDay or na(cdhLive) or na(cdlLive)
    cdhLive := high
    cdlLive := low
else
    cdhLive := math.max(cdhLive, high)
    cdlLive := math.min(cdlLive, low)
cdh = cdhLive
cdl = cdlLive

// --- Premarket tracking ---
var float pmHighFinal = na
var float pmLowFinal  = na
var float pmHighLive  = na
var float pmLowLive   = na
var bool  pmDone      = false
var line pmHighLine = na
var line pmLowLine  = na
var label pmHighLabel = na
var label pmLowLabel  = na
var linefill pmFill = na
var bool pmHighLineCreated  = false
var bool pmLowLineCreated   = false
var bool pmHighLabelCreated = false
var bool pmLowLabelCreated  = false

if isNewDay
    pmHighLive  := na
    pmLowLive   := na
    pmHighFinal := na
    pmLowFinal  := na
    pmDone      := false
    if not na(pmHighLine)
        line.delete(pmHighLine)
    if not na(pmLowLine)
        line.delete(pmLowLine)
    if not na(pmHighLabel)
        label.delete(pmHighLabel)
    if not na(pmLowLabel)
        label.delete(pmLowLabel)
    if not na(pmFill)
        linefill.delete(pmFill)
    pmHighLine  := na
    pmLowLine   := na
    pmHighLabel := na
    pmLowLabel  := na
    pmFill      := na
    pmHighLineCreated  := false
    pmLowLineCreated   := false
    pmHighLabelCreated := false
    pmLowLabelCreated  := false

if inPremarket and not pmDone
    pmHighLive := na(pmHighLive) ? high : math.max(pmHighLive, high)
    pmLowLive  := na(pmLowLive)  ? low  : math.min(pmLowLive, low)

if sessionOpen and not pmDone
    pmHighFinal := pmHighLive
    pmLowFinal  := pmLowLive
    pmDone      := true

pmH = na(pmHighFinal) ? pmHighLive : pmHighFinal
pmL = na(pmLowFinal)  ? pmLowLive  : pmLowFinal

// --- Opening Range tracking ---
var float orHighFinal = na
var float orLowFinal  = na
var float orHighLive  = na
var float orLowLive   = na
var bool  orDone      = false
var int   orStartTime = na
var line orHighLine = na
var line orLowLine  = na
var label orHighLabel = na
var label orLowLabel  = na
var linefill orFill = na

if isNewDay
    orHighFinal := na
    orLowFinal  := na
    orHighLive  := na
    orLowLive   := na
    orDone      := false
    orStartTime := na
    if not na(orHighLine)
        line.delete(orHighLine)
    if not na(orLowLine)
        line.delete(orLowLine)
    if not na(orHighLabel)
        label.delete(orHighLabel)
    if not na(orLowLabel)
        label.delete(orLowLabel)
    if not na(orFill)
        linefill.delete(orFill)
    orHighLine  := na
    orLowLine   := na
    orHighLabel := na
    orLowLabel  := na
    orFill      := na

orStartTrigger = sessionOpen or (inRegular and na(orStartTime))
if orStartTrigger
    orStartTime := time
    orHighLive  := high
    orLowLive   := low
    orHighFinal := na
    orLowFinal  := na
    orDone      := false

orWindowMs = orMinutes * 60 * 1000
inORWindow = inRegular and not na(orStartTime) and time < orStartTime + orWindowMs
if inORWindow and not orDone
    orHighLive := na(orHighLive) ? high : math.max(orHighLive, high)
    orLowLive  := na(orLowLive)  ? low  : math.min(orLowLive, low)
if inRegular and not na(orStartTime) and not orDone and time >= orStartTime + orWindowMs
    orHighFinal := orHighLive
    orLowFinal  := orLowLive
    orDone      := true
orH = na(orHighFinal) ? orHighLive : orHighFinal
orL = na(orLowFinal)  ? orLowLive  : orLowFinal

// --- Day Open Tracking ---
var float dayOpen = na
var line doLine = na
var label doLabel = na
if isNewDay
    dayOpen := na
    if not na(doLine)
        line.delete(doLine)
    if not na(doLabel)
        label.delete(doLabel)
    doLine  := na
    doLabel := na
if sessionOpen
    dayOpen := open

// --- Higher timeframe levels ---
prevClose = request.security(syminfo.tickerid, "D", close[1], lookahead = barmerge.lookahead_on)
pdh       = request.security(syminfo.tickerid, "D", high[1],  lookahead = barmerge.lookahead_on)
pdl       = request.security(syminfo.tickerid, "D", low[1],   lookahead = barmerge.lookahead_on)
pwh       = request.security(syminfo.tickerid, "W", high[1],  lookahead = barmerge.lookahead_on)
pwl       = request.security(syminfo.tickerid, "W", low[1],   lookahead = barmerge.lookahead_on)
pmoh      = request.security(syminfo.tickerid, "M", high[1],  lookahead = barmerge.lookahead_on)
pmol      = request.security(syminfo.tickerid, "M", low[1],   lookahead = barmerge.lookahead_on)

// --- ATR / cross signals ---
atrForProximity = ta.atr(proximityAtrLen)
retestBuffer = atrForProximity * retestAtrBuffer

pmhCrossUp   = ta.crossover(close, pmH)
pmlCrossDown = ta.crossunder(close, pmL)
pmlCrossUp   = ta.crossover(close, pmL)
orhCrossUp   = ta.crossover(close, orH)
orlCrossDown = ta.crossunder(close, orL)
orlCrossUp   = ta.crossover(close, orL)
pcCrossUp    = ta.crossover(close, prevClose)
pcCrossDown  = ta.crossunder(close, prevClose)
doCrossUp    = ta.crossover(close, dayOpen)
doCrossDown  = ta.crossunder(close, dayOpen)
pdhCrossUp   = ta.crossover(close, pdh)
pdlCrossDown = ta.crossunder(close, pdl)
pdlCrossUp   = ta.crossover(close, pdl)
pwhCrossUp   = ta.crossover(close, pwh)
pwlCrossDown = ta.crossunder(close, pwl)
pwlCrossUp   = ta.crossover(close, pwl)
pmohCrossUp  = ta.crossover(close, pmoh)
pmolCrossDown = ta.crossunder(close, pmol)
pmolCrossUp   = ta.crossover(close, pmol)

// --- Nearest support/resistance detection ---
var float nearestRes = na
var float nearestSup = na
nearestRes := na
nearestSup := na

f_nearestCandidate(level, enabled) =>
    enabled and not na(level)

if f_nearestCandidate(cdh, showCDH) and cdh > close
    nearestRes := na(nearestRes) ? cdh : math.min(nearestRes, cdh)
if f_nearestCandidate(pmH, showPM) and pmH > close
    nearestRes := na(nearestRes) ? pmH : math.min(nearestRes, pmH)
if f_nearestCandidate(orH, showOR and orDone) and orH > close
    nearestRes := na(nearestRes) ? orH : math.min(nearestRes, orH)
if f_nearestCandidate(prevClose, showPC) and prevClose > close
    nearestRes := na(nearestRes) ? prevClose : math.min(nearestRes, prevClose)
if f_nearestCandidate(dayOpen, showDO) and dayOpen > close
    nearestRes := na(nearestRes) ? dayOpen : math.min(nearestRes, dayOpen)
if f_nearestCandidate(pdh, showPD) and pdh > close
    nearestRes := na(nearestRes) ? pdh : math.min(nearestRes, pdh)
if f_nearestCandidate(pwh, showPW) and pwh > close
    nearestRes := na(nearestRes) ? pwh : math.min(nearestRes, pwh)
if f_nearestCandidate(pmoh, showPMo) and pmoh > close
    nearestRes := na(nearestRes) ? pmoh : math.min(nearestRes, pmoh)

if f_nearestCandidate(cdl, showCDH) and cdl < close
    nearestSup := na(nearestSup) ? cdl : math.max(nearestSup, cdl)
if f_nearestCandidate(pmL, showPM) and pmL < close
    nearestSup := na(nearestSup) ? pmL : math.max(nearestSup, pmL)
if f_nearestCandidate(orL, showOR and orDone) and orL < close
    nearestSup := na(nearestSup) ? orL : math.max(nearestSup, orL)
if f_nearestCandidate(prevClose, showPC) and prevClose < close
    nearestSup := na(nearestSup) ? prevClose : math.max(nearestSup, prevClose)
if f_nearestCandidate(dayOpen, showDO) and dayOpen < close
    nearestSup := na(nearestSup) ? dayOpen : math.max(nearestSup, dayOpen)
if f_nearestCandidate(pdl, showPD) and pdl < close
    nearestSup := na(nearestSup) ? pdl : math.max(nearestSup, pdl)
if f_nearestCandidate(pwl, showPW) and pwl < close
    nearestSup := na(nearestSup) ? pwl : math.max(nearestSup, pwl)
if f_nearestCandidate(pmol, showPMo) and pmol < close
    nearestSup := na(nearestSup) ? pmol : math.max(nearestSup, pmol)

isNearestRes(level) => showNearestHighlight and not na(nearestRes) and not na(level) and math.abs(level - nearestRes) <= syminfo.mintick
isNearestSup(level) => showNearestHighlight and not na(nearestSup) and not na(level) and math.abs(level - nearestSup) <= syminfo.mintick

// --- Flip state tracking ---
var bool pmhLost = false
var bool pmhFlipSupport = false
var bool pmhFlipResistance = false
var bool pmlLost = false
var bool pmlFlipSupport = false
var bool pmlFlipResistance = false
var bool orhLost = false
var bool orhFlipSupport = false
var bool orhFlipResistance = false
var bool orlLost = false
var bool orlFlipSupport = false
var bool orlFlipResistance = false
var bool pcLost = false
var bool pcFlipSupport = false
var bool pcFlipResistance = false
var bool doLost = false
var bool doFlipSupport = false
var bool doFlipResistance = false
var bool pdhLost = false
var bool pdhFlipSupport = false
var bool pdhFlipResistance = false
var bool pdlLost = false
var bool pdlFlipSupport = false
var bool pdlFlipResistance = false
var bool pwhLost = false
var bool pwhFlipSupport = false
var bool pwhFlipResistance = false
var bool pwlLost = false
var bool pwlFlipSupport = false
var bool pwlFlipResistance = false
var bool pmohLost = false
var bool pmohFlipSupport = false
var bool pmohFlipResistance = false
var bool pmolLost = false
var bool pmolFlipSupport = false
var bool pmolFlipResistance = false

var float lastPrevClose = na
var float lastPdh = na
var float lastPdl = na
var float lastPwh = na
var float lastPwl = na
var float lastPmoh = na
var float lastPmol = na

if isNewDay
    pmhLost := false
    pmhFlipSupport := false
    pmhFlipResistance := false
    pmlLost := false
    pmlFlipSupport := false
    pmlFlipResistance := false
    orhLost := false
    orhFlipSupport := false
    orhFlipResistance := false
    orlLost := false
    orlFlipSupport := false
    orlFlipResistance := false
    doLost := false
    doFlipSupport := false
    doFlipResistance := false

if f_levelChanged(prevClose, lastPrevClose)
    pcLost := false
    pcFlipSupport := false
    pcFlipResistance := false
    lastPrevClose := prevClose

if f_levelChanged(pdh, lastPdh)
    pdhLost := false
    pdhFlipSupport := false
    pdhFlipResistance := false
    lastPdh := pdh

if f_levelChanged(pdl, lastPdl)
    pdlLost := false
    pdlFlipSupport := false
    pdlFlipResistance := false
    lastPdl := pdl

if f_levelChanged(pwh, lastPwh)
    pwhLost := false
    pwhFlipSupport := false
    pwhFlipResistance := false
    lastPwh := pwh

if f_levelChanged(pwl, lastPwl)
    pwlLost := false
    pwlFlipSupport := false
    pwlFlipResistance := false
    lastPwl := pwl

if f_levelChanged(pmoh, lastPmoh)
    pmohLost := false
    pmohFlipSupport := false
    pmohFlipResistance := false
    lastPmoh := pmoh

if f_levelChanged(pmol, lastPmol)
    pmolLost := false
    pmolFlipSupport := false
    pmolFlipResistance := false
    lastPmol := pmol

canAlert = alertOnClose ? barstate.isconfirmed : true
canReject = barstate.isconfirmed

// Break state: mark a level as lost/taken only after confirmed close through it.
pmhBreakState = not na(pmH) and barstate.isconfirmed and close > pmH
pmlBreakState = not na(pmL) and barstate.isconfirmed and close < pmL
orhBreakState = orDone and not na(orH) and barstate.isconfirmed and close > orH
orlBreakState = orDone and not na(orL) and barstate.isconfirmed and close < orL
pcUpState     = not na(prevClose) and barstate.isconfirmed and close > prevClose
pcDnState     = not na(prevClose) and barstate.isconfirmed and close < prevClose
doUpState     = inRegular and not na(dayOpen) and barstate.isconfirmed and close > dayOpen
doDnState     = inRegular and not na(dayOpen) and barstate.isconfirmed and close < dayOpen
pdhBreakState = not na(pdh) and barstate.isconfirmed and close > pdh
pdlBreakState = not na(pdl) and barstate.isconfirmed and close < pdl
pwhBreakState = not na(pwh) and barstate.isconfirmed and close > pwh
pwlBreakState = not na(pwl) and barstate.isconfirmed and close < pwl
pmohBreakState = not na(pmoh) and barstate.isconfirmed and close > pmoh
pmolBreakState = not na(pmol) and barstate.isconfirmed and close < pmol

pmhFlipNow = pmhLost and not pmhFlipSupport and not na(pmH) and barstate.isconfirmed and low <= pmH + retestBuffer and close > pmH
pmlFlipNow = pmlLost and not pmlFlipResistance and not na(pmL) and barstate.isconfirmed and high >= pmL - retestBuffer and close < pmL
orhFlipNow = orhLost and not orhFlipSupport and orDone and not na(orH) and barstate.isconfirmed and low <= orH + retestBuffer and close > orH
orlFlipNow = orlLost and not orlFlipResistance and orDone and not na(orL) and barstate.isconfirmed and high >= orL - retestBuffer and close < orL
pcFlipSupNow = pcLost and not pcFlipSupport and not na(prevClose) and barstate.isconfirmed and low <= prevClose + retestBuffer and close > prevClose
pcFlipResNow = pcLost and not pcFlipResistance and not na(prevClose) and barstate.isconfirmed and high >= prevClose - retestBuffer and close < prevClose
doFlipSupNow = doLost and not doFlipSupport and inRegular and not na(dayOpen) and barstate.isconfirmed and low <= dayOpen + retestBuffer and close > dayOpen
doFlipResNow = doLost and not doFlipResistance and inRegular and not na(dayOpen) and barstate.isconfirmed and high >= dayOpen - retestBuffer and close < dayOpen
pdhFlipNow = pdhLost and not pdhFlipSupport and not na(pdh) and barstate.isconfirmed and low <= pdh + retestBuffer and close > pdh
pdlFlipNow = pdlLost and not pdlFlipResistance and not na(pdl) and barstate.isconfirmed and high >= pdl - retestBuffer and close < pdl
pwhFlipNow = pwhLost and not pwhFlipSupport and not na(pwh) and barstate.isconfirmed and low <= pwh + retestBuffer and close > pwh
pwlFlipNow = pwlLost and not pwlFlipResistance and not na(pwl) and barstate.isconfirmed and high >= pwl - retestBuffer and close < pwl
pmohFlipNow = pmohLost and not pmohFlipSupport and not na(pmoh) and barstate.isconfirmed and low <= pmoh + retestBuffer and close > pmoh
pmolFlipNow = pmolLost and not pmolFlipResistance and not na(pmol) and barstate.isconfirmed and high >= pmol - retestBuffer and close < pmol

if pmhBreakState
    pmhLost := true
if pmlBreakState
    pmlLost := true
if orhBreakState
    orhLost := true
if orlBreakState
    orlLost := true
if pcUpState or pcDnState
    pcLost := true
if doUpState or doDnState
    doLost := true
if pdhBreakState
    pdhLost := true
if pdlBreakState
    pdlLost := true
if pwhBreakState
    pwhLost := true
if pwlBreakState
    pwlLost := true
if pmohBreakState
    pmohLost := true
if pmolBreakState
    pmolLost := true

if pmhFlipNow
    pmhFlipSupport := true
if pmlFlipNow
    pmlFlipResistance := true
if orhFlipNow
    orhFlipSupport := true
if orlFlipNow
    orlFlipResistance := true
if pcFlipSupNow
    pcFlipSupport := true
if pcFlipResNow
    pcFlipResistance := true
if doFlipSupNow
    doFlipSupport := true
if doFlipResNow
    doFlipResistance := true
if pdhFlipNow
    pdhFlipSupport := true
if pdlFlipNow
    pdlFlipResistance := true
if pwhFlipNow
    pwhFlipSupport := true
if pwlFlipNow
    pwlFlipResistance := true
if pmohFlipNow
    pmohFlipSupport := true
if pmolFlipNow
    pmolFlipResistance := true

// Flip invalidation: clear stale role markers when price closes back through the level.
if barstate.isconfirmed
    if pmhFlipSupport and not na(pmH) and close < pmH
        pmhFlipSupport := false
    if pmlFlipResistance and not na(pmL) and close > pmL
        pmlFlipResistance := false
    if orhFlipSupport and not na(orH) and close < orH
        orhFlipSupport := false
    if orlFlipResistance and not na(orL) and close > orL
        orlFlipResistance := false
    if pcFlipSupport and not na(prevClose) and close < prevClose
        pcFlipSupport := false
    if pcFlipResistance and not na(prevClose) and close > prevClose
        pcFlipResistance := false
    if doFlipSupport and not na(dayOpen) and close < dayOpen
        doFlipSupport := false
    if doFlipResistance and not na(dayOpen) and close > dayOpen
        doFlipResistance := false
    if pdhFlipSupport and not na(pdh) and close < pdh
        pdhFlipSupport := false
    if pdlFlipResistance and not na(pdl) and close > pdl
        pdlFlipResistance := false
    if pwhFlipSupport and not na(pwh) and close < pwh
        pwhFlipSupport := false
    if pwlFlipResistance and not na(pwl) and close > pwl
        pwlFlipResistance := false
    if pmohFlipSupport and not na(pmoh) and close < pmoh
        pmohFlipSupport := false
    if pmolFlipResistance and not na(pmol) and close > pmol
        pmolFlipResistance := false

// --- Lines and labels ---
var line highLine = na
var line lowLine = na
var label highLabel = na
var label lowLabel = na
if bar_index == 0
    highLine := line.new(bar_index, cdh, bar_index + 1, cdh, extend = extend.right, color = colorCDH, width = cdhWidth, style = cdhLineStyle)
    lowLine  := line.new(bar_index, cdl, bar_index + 1, cdl, extend = extend.right, color = colorCDL, width = cdhWidth, style = cdhLineStyle)
    highLabel := label.new(bar_index, cdh, text = "", color = invisible, textcolor = colorCDH, style = label.style_none, size = size.normal)
    lowLabel  := label.new(bar_index, cdl, text = "", color = invisible, textcolor = colorCDL, style = label.style_none, size = size.normal)

if showCDH
    line.set_y1(highLine, cdh), line.set_y2(highLine, cdh), line.set_color(highLine, colorCDH), line.set_width(highLine, f_width(cdhWidth, isNearestRes(cdh))), line.set_style(highLine, cdhLineStyle)
    line.set_y1(lowLine, cdl), line.set_y2(lowLine, cdl), line.set_color(lowLine, colorCDL), line.set_width(lowLine, f_width(cdhWidth, isNearestSup(cdl))), line.set_style(lowLine, cdhLineStyle)
    label.set_x(highLabel, bar_index + labelBaseOffset), label.set_y(highLabel, cdh), label.set_text(highLabel, "CDH " + str.tostring(cdh, format.mintick)), label.set_textcolor(highLabel, colorCDH)
    label.set_x(lowLabel, bar_index + labelBaseOffset + labelStaggerStep), label.set_y(lowLabel, cdl), label.set_text(lowLabel, "CDL " + str.tostring(cdl, format.mintick)), label.set_textcolor(lowLabel, colorCDL)
else
    line.set_color(highLine, invisible), line.set_color(lowLine, invisible), label.set_text(highLabel, ""), label.set_text(lowLabel, "")

if not na(pmH) and not pmHighLineCreated
    pmHighLine := line.new(bar_index, pmH, bar_index + 1, pmH, extend = extend.right, color = colorPMH, width = pmWidth, style = pmLineStyle)
    pmHighLineCreated := true
if not na(pmL) and not pmLowLineCreated
    pmLowLine := line.new(bar_index, pmL, bar_index + 1, pmL, extend = extend.right, color = colorPML, width = pmWidth, style = pmLineStyle)
    pmLowLineCreated := true
if not na(pmHighLine) and not na(pmLowLine) and na(pmFill)
    pmFill := linefill.new(pmHighLine, pmLowLine, color.new(colorPMH, pmFillTransp))
if not na(pmHighLine)
    line.set_y1(pmHighLine, pmH), line.set_y2(pmHighLine, pmH), line.set_color(pmHighLine, showPM ? colorPMH : invisible), line.set_width(pmHighLine, f_width(pmWidth, isNearestRes(pmH))), line.set_style(pmHighLine, pmLineStyle)
if not na(pmLowLine)
    line.set_y1(pmLowLine, pmL), line.set_y2(pmLowLine, pmL), line.set_color(pmLowLine, showPM ? colorPML : invisible), line.set_width(pmLowLine, f_width(pmWidth, isNearestSup(pmL))), line.set_style(pmLowLine, pmLineStyle)
if not na(pmFill)
    linefill.set_color(pmFill, showPM and showPMFill ? color.new(colorPMH, pmFillTransp) : invisible)
if not na(pmH) and not pmHighLabelCreated
    pmHighLabel := label.new(bar_index + labelBaseOffset, pmH, text = "", color = invisible, textcolor = colorPMH, style = label.style_none, size = size.normal)
    pmHighLabelCreated := true
if not na(pmL) and not pmLowLabelCreated
    pmLowLabel := label.new(bar_index + labelBaseOffset + labelStaggerStep, pmL, text = "", color = invisible, textcolor = colorPML, style = label.style_none, size = size.normal)
    pmLowLabelCreated := true
if not na(pmHighLabel)
    label.set_x(pmHighLabel, bar_index + labelBaseOffset + labelStaggerStep * 2), label.set_y(pmHighLabel, pmH), label.set_text(pmHighLabel, showPM ? "PMH " + str.tostring(pmH, format.mintick) + f_flipText(pmhFlipSupport, false) : ""), label.set_textcolor(pmHighLabel, colorPMH)
if not na(pmLowLabel)
    label.set_x(pmLowLabel, bar_index + labelBaseOffset + labelStaggerStep * 3), label.set_y(pmLowLabel, pmL), label.set_text(pmLowLabel, showPM ? "PML " + str.tostring(pmL, format.mintick) + f_flipText(false, pmlFlipResistance) : ""), label.set_textcolor(pmLowLabel, colorPML)

if not na(orH) and na(orHighLine)
    orHighLine := line.new(bar_index, orH, bar_index + 1, orH, extend = extend.right, color = colorORH, width = orWidth, style = orLineStyle)
if not na(orL) and na(orLowLine)
    orLowLine := line.new(bar_index, orL, bar_index + 1, orL, extend = extend.right, color = colorORL, width = orWidth, style = orLineStyle)
if not na(orHighLine) and not na(orLowLine) and na(orFill)
    orFill := linefill.new(orHighLine, orLowLine, color.new(colorORH, orFillTransp))
orLiveColorH = orDone ? colorORH : color.new(colorORH, 45)
orLiveColorL = orDone ? colorORL : color.new(colorORL, 45)
if not na(orHighLine)
    line.set_y1(orHighLine, orH), line.set_y2(orHighLine, orH), line.set_color(orHighLine, showOR ? orLiveColorH : invisible), line.set_width(orHighLine, f_width(orWidth, isNearestRes(orH))), line.set_style(orHighLine, orLineStyle)
if not na(orLowLine)
    line.set_y1(orLowLine, orL), line.set_y2(orLowLine, orL), line.set_color(orLowLine, showOR ? orLiveColorL : invisible), line.set_width(orLowLine, f_width(orWidth, isNearestSup(orL))), line.set_style(orLowLine, orLineStyle)
if not na(orFill)
    linefill.set_color(orFill, showOR and showORFill ? color.new(colorORH, orFillTransp) : invisible)
if not na(orH) and na(orHighLabel)
    orHighLabel := label.new(bar_index + labelBaseOffset, orH, text = "", color = invisible, textcolor = colorORH, style = label.style_none, size = size.normal)
if not na(orL) and na(orLowLabel)
    orLowLabel := label.new(bar_index + labelBaseOffset, orL, text = "", color = invisible, textcolor = colorORL, style = label.style_none, size = size.normal)
orStatusText = orDone ? "" : " forming"
orLabelNudge = syminfo.mintick * orLabelYNudgeTicks
orHighLabelY = not na(orH) ? orH + orLabelNudge : orH
orLowLabelY = not na(orL) ? orL + orLabelNudge : orL
if not na(orHighLabel)
    label.set_x(orHighLabel, bar_index + labelBaseOffset + labelStaggerStep * orLabelExtraOffset), label.set_y(orHighLabel, orHighLabelY), label.set_text(orHighLabel, showOR ? "ORH " + str.tostring(orH, format.mintick) + orStatusText + f_flipText(orhFlipSupport, false) : ""), label.set_textcolor(orHighLabel, orLiveColorH)
if not na(orLowLabel)
    label.set_x(orLowLabel, bar_index + labelBaseOffset + labelStaggerStep * (orLabelExtraOffset + 1)), label.set_y(orLowLabel, orLowLabelY), label.set_text(orLowLabel, showOR ? "ORL " + str.tostring(orL, format.mintick) + orStatusText + f_flipText(false, orlFlipResistance) : ""), label.set_textcolor(orLowLabel, orLiveColorL)

var line pcLine = na
var line pdhLine = na
var line pdlLine = na
var line pwhLine = na
var line pwlLine = na
var line pmohLine = na
var line pmolLine = na
var label pcLabel = na
var label pdhLabel = na
var label pdlLabel = na
var label pwhLabel = na
var label pwlLabel = na
var label pmohLabel = na
var label pmolLabel = na
if bar_index == 0
    pcLine := line.new(bar_index, prevClose, bar_index + 1, prevClose, extend = extend.right, color = color.new(colorPC, 15), width = pcWidth, style = pcLineStyle)
    pdhLine := line.new(bar_index, pdh, bar_index + 1, pdh, extend = extend.right, color = color.new(colorPDH, 25), width = pdWidth, style = pdLineStyle)
    pdlLine := line.new(bar_index, pdl, bar_index + 1, pdl, extend = extend.right, color = color.new(colorPDL, 25), width = pdWidth, style = pdLineStyle)
    pwhLine := line.new(bar_index, pwh, bar_index + 1, pwh, extend = extend.right, color = colorPWH, width = pwWidth, style = pwLineStyle)
    pwlLine := line.new(bar_index, pwl, bar_index + 1, pwl, extend = extend.right, color = colorPWL, width = pwWidth, style = pwLineStyle)
    pmohLine := line.new(bar_index, pmoh, bar_index + 1, pmoh, extend = extend.right, color = color.new(colorPMoH, 35), width = pmoWidth, style = pmoLineStyle)
    pmolLine := line.new(bar_index, pmol, bar_index + 1, pmol, extend = extend.right, color = color.new(colorPMoL, 35), width = pmoWidth, style = pmoLineStyle)
    pcLabel := label.new(bar_index, prevClose, text = "", color = invisible, textcolor = color.new(colorPC, 15), style = label.style_none, size = size.small)
    pdhLabel := label.new(bar_index, pdh, text = "", color = invisible, textcolor = color.new(colorPDH, 25), style = label.style_none, size = size.small)
    pdlLabel := label.new(bar_index, pdl, text = "", color = invisible, textcolor = color.new(colorPDL, 25), style = label.style_none, size = size.small)
    pwhLabel := label.new(bar_index, pwh, text = "", color = invisible, textcolor = colorPWH, style = label.style_none, size = size.normal)
    pwlLabel := label.new(bar_index, pwl, text = "", color = invisible, textcolor = colorPWL, style = label.style_none, size = size.normal)
    pmohLabel := label.new(bar_index, pmoh, text = "", color = invisible, textcolor = color.new(colorPMoH, 35), style = label.style_none, size = size.small)
    pmolLabel := label.new(bar_index, pmol, text = "", color = invisible, textcolor = color.new(colorPMoL, 35), style = label.style_none, size = size.small)

line.set_y1(pcLine, prevClose), line.set_y2(pcLine, prevClose), line.set_color(pcLine, showPC ? color.new(colorPC, 15) : invisible), line.set_width(pcLine, f_width(pcWidth, isNearestRes(prevClose) or isNearestSup(prevClose))), line.set_style(pcLine, pcLineStyle)
label.set_x(pcLabel, bar_index + labelBaseOffset + labelStaggerStep * 8), label.set_y(pcLabel, prevClose), label.set_text(pcLabel, showPC ? "PC " + str.tostring(prevClose, format.mintick) + f_flipText(pcFlipSupport, pcFlipResistance) : ""), label.set_textcolor(pcLabel, color.new(colorPC, 15))

if not na(dayOpen) and na(doLine)
    doLine := line.new(bar_index, dayOpen, bar_index + 1, dayOpen, extend = extend.right, color = color.new(colorDO, 35), width = doWidth, style = doLineStyle)
    doLabel := label.new(bar_index, dayOpen, text = "", color = invisible, textcolor = color.new(colorDO, 35), style = label.style_none, size = size.small)
if not na(doLine) and not na(doLabel)
    line.set_y1(doLine, dayOpen), line.set_y2(doLine, dayOpen), line.set_color(doLine, showDO ? color.new(colorDO, 35) : invisible), line.set_width(doLine, f_width(doWidth, isNearestRes(dayOpen) or isNearestSup(dayOpen))), line.set_style(doLine, doLineStyle)
    label.set_x(doLabel, bar_index + labelBaseOffset + labelStaggerStep * 9), label.set_y(doLabel, dayOpen), label.set_text(doLabel, showDO ? "DO " + str.tostring(dayOpen, format.mintick) + f_flipText(doFlipSupport, doFlipResistance) : ""), label.set_textcolor(doLabel, color.new(colorDO, 35))

line.set_y1(pdhLine, pdh), line.set_y2(pdhLine, pdh), line.set_color(pdhLine, showPD ? color.new(colorPDH, 25) : invisible), line.set_width(pdhLine, f_width(pdWidth, isNearestRes(pdh))), line.set_style(pdhLine, pdLineStyle)
line.set_y1(pdlLine, pdl), line.set_y2(pdlLine, pdl), line.set_color(pdlLine, showPD ? color.new(colorPDL, 25) : invisible), line.set_width(pdlLine, f_width(pdWidth, isNearestSup(pdl))), line.set_style(pdlLine, pdLineStyle)
label.set_x(pdhLabel, bar_index + labelBaseOffset + labelStaggerStep * 10), label.set_y(pdhLabel, pdh), label.set_text(pdhLabel, showPD ? "PDH " + str.tostring(pdh, format.mintick) + f_flipText(pdhFlipSupport, false) : ""), label.set_textcolor(pdhLabel, color.new(colorPDH, 25))
label.set_x(pdlLabel, bar_index + labelBaseOffset + labelStaggerStep * 11), label.set_y(pdlLabel, pdl), label.set_text(pdlLabel, showPD ? "PDL " + str.tostring(pdl, format.mintick) + f_flipText(false, pdlFlipResistance) : ""), label.set_textcolor(pdlLabel, color.new(colorPDL, 25))

line.set_y1(pwhLine, pwh), line.set_y2(pwhLine, pwh), line.set_color(pwhLine, showPW ? colorPWH : invisible), line.set_width(pwhLine, f_width(pwWidth, isNearestRes(pwh))), line.set_style(pwhLine, pwLineStyle)
line.set_y1(pwlLine, pwl), line.set_y2(pwlLine, pwl), line.set_color(pwlLine, showPW ? colorPWL : invisible), line.set_width(pwlLine, f_width(pwWidth, isNearestSup(pwl))), line.set_style(pwlLine, pwLineStyle)
label.set_x(pwhLabel, bar_index + labelBaseOffset + labelStaggerStep * 12), label.set_y(pwhLabel, pwh), label.set_text(pwhLabel, showPW ? "PWH " + str.tostring(pwh, format.mintick) + f_flipText(pwhFlipSupport, false) : ""), label.set_textcolor(pwhLabel, colorPWH)
label.set_x(pwlLabel, bar_index + labelBaseOffset + labelStaggerStep * 13), label.set_y(pwlLabel, pwl), label.set_text(pwlLabel, showPW ? "PWL " + str.tostring(pwl, format.mintick) + f_flipText(false, pwlFlipResistance) : ""), label.set_textcolor(pwlLabel, colorPWL)

line.set_y1(pmohLine, pmoh), line.set_y2(pmohLine, pmoh), line.set_color(pmohLine, showPMo ? color.new(colorPMoH, 35) : invisible), line.set_width(pmohLine, f_width(pmoWidth, isNearestRes(pmoh))), line.set_style(pmohLine, pmoLineStyle)
line.set_y1(pmolLine, pmol), line.set_y2(pmolLine, pmol), line.set_color(pmolLine, showPMo ? color.new(colorPMoL, 35) : invisible), line.set_width(pmolLine, f_width(pmoWidth, isNearestSup(pmol))), line.set_style(pmolLine, pmoLineStyle)
label.set_x(pmohLabel, bar_index + labelBaseOffset + labelStaggerStep * 14), label.set_y(pmohLabel, pmoh), label.set_text(pmohLabel, showPMo ? "PMoH " + str.tostring(pmoh, format.mintick) + f_flipText(pmohFlipSupport, false) : ""), label.set_textcolor(pmohLabel, color.new(colorPMoH, 35))
label.set_x(pmolLabel, bar_index + labelBaseOffset + labelStaggerStep * 15), label.set_y(pmolLabel, pmol), label.set_text(pmolLabel, showPMo ? "PMoL " + str.tostring(pmol, format.mintick) + f_flipText(false, pmolFlipResistance) : ""), label.set_textcolor(pmolLabel, color.new(colorPMoL, 35))


// --- Alert engine ---
var string firedToday = ""
if isNewDay
    firedToday := ""

newDayHighBase = inRegular and not na(cdh[1]) and canAlert and (alertOnClose ? close > cdh[1] : high > cdh[1])
newDayLowBase  = inRegular and not na(cdl[1]) and canAlert and (alertOnClose ? close < cdl[1] : low < cdl[1])

pmhBreakBase = not na(pmH) and canAlert and pmhCrossUp
pmlBreakBase = not na(pmL) and canAlert and pmlCrossDown
orhBreakBase = orDone and not na(orH) and canAlert and orhCrossUp
orlBreakBase = orDone and not na(orL) and canAlert and orlCrossDown
pcUpBreakBase = not na(prevClose) and canAlert and pcCrossUp
pcDownBreakBase = not na(prevClose) and canAlert and pcCrossDown
doUpBreakBase = inRegular and not na(dayOpen) and canAlert and doCrossUp
doDownBreakBase = inRegular and not na(dayOpen) and canAlert and doCrossDown
pdhBreakBase = not na(pdh) and canAlert and pdhCrossUp
pdlBreakBase = not na(pdl) and canAlert and pdlCrossDown
pwhBreakBase = not na(pwh) and canAlert and pwhCrossUp
pwlBreakBase = not na(pwl) and canAlert and pwlCrossDown
pmohBreakBase = not na(pmoh) and canAlert and pmohCrossUp
pmolBreakBase = not na(pmol) and canAlert and pmolCrossDown

pmhRejectRaw = not na(pmH) and canReject and high > pmH and close < pmH
pmlRejectRaw = not na(pmL) and canReject and low < pmL and close > pmL
orhRejectRaw = orDone and not na(orH) and canReject and high > orH and close < orH
orlRejectRaw = orDone and not na(orL) and canReject and low < orL and close > orL
pcRejectUpRaw = not na(prevClose) and canReject and high > prevClose and close < prevClose
pcRejectDnRaw = not na(prevClose) and canReject and low < prevClose and close > prevClose
doRejectUpRaw = inRegular and not na(dayOpen) and canReject and high > dayOpen and close < dayOpen
doRejectDnRaw = inRegular and not na(dayOpen) and canReject and low < dayOpen and close > dayOpen
pdhRejectRaw = not na(pdh) and canReject and high > pdh and close < pdh
pdlRejectRaw = not na(pdl) and canReject and low < pdl and close > pdl
pwhRejectRaw = not na(pwh) and canReject and high > pwh and close < pwh
pwlRejectRaw = not na(pwl) and canReject and low < pwl and close > pwl
pmohRejectRaw = not na(pmoh) and canReject and high > pmoh and close < pmoh
pmolRejectRaw = not na(pmol) and canReject and low < pmol and close > pmol

pmhRejectBase = pmhRejectRaw and not pmhRejectRaw[1]
pmlRejectBase = pmlRejectRaw and not pmlRejectRaw[1]
orhRejectBase = orhRejectRaw and not orhRejectRaw[1]
orlRejectBase = orlRejectRaw and not orlRejectRaw[1]
pcRejectUpBase = pcRejectUpRaw and not pcRejectUpRaw[1]
pcRejectDnBase = pcRejectDnRaw and not pcRejectDnRaw[1]
doRejectUpBase = doRejectUpRaw and not doRejectUpRaw[1]
doRejectDnBase = doRejectDnRaw and not doRejectDnRaw[1]
pdhRejectBase = pdhRejectRaw and not pdhRejectRaw[1]
pdlRejectBase = pdlRejectRaw and not pdlRejectRaw[1]
pwhRejectBase = pwhRejectRaw and not pwhRejectRaw[1]
pwlRejectBase = pwlRejectRaw and not pwlRejectRaw[1]
pmohRejectBase = pmohRejectRaw and not pmohRejectRaw[1]
pmolRejectBase = pmolRejectRaw and not pmolRejectRaw[1]

pmhNear = f_nearLevel(pmH, atrForProximity)
pmlNear = f_nearLevel(pmL, atrForProximity)
orhNear = orDone and f_nearLevel(orH, atrForProximity)
orlNear = orDone and f_nearLevel(orL, atrForProximity)
pcNear = f_nearLevel(prevClose, atrForProximity)
doNear = inRegular and f_nearLevel(dayOpen, atrForProximity)
pdhNear = f_nearLevel(pdh, atrForProximity)
pdlNear = f_nearLevel(pdl, atrForProximity)
pwhNear = f_nearLevel(pwh, atrForProximity)
pwlNear = f_nearLevel(pwl, atrForProximity)
pmohNear = f_nearLevel(pmoh, atrForProximity)
pmolNear = f_nearLevel(pmol, atrForProximity)

pmhProxBase = canAlert and pmhNear and not pmhNear[1]
pmlProxBase = canAlert and pmlNear and not pmlNear[1]
orhProxBase = canAlert and orhNear and not orhNear[1]
orlProxBase = canAlert and orlNear and not orlNear[1]
pcProxBase = canAlert and pcNear and not pcNear[1]
doProxBase = canAlert and doNear and not doNear[1]
pdhProxBase = canAlert and pdhNear and not pdhNear[1]
pdlProxBase = canAlert and pdlNear and not pdlNear[1]
pwhProxBase = canAlert and pwhNear and not pwhNear[1]
pwlProxBase = canAlert and pwlNear and not pwlNear[1]
pmohProxBase = canAlert and pmohNear and not pmohNear[1]
pmolProxBase = canAlert and pmolNear and not pmolNear[1]

newDayHigh = alertCDHL and enableBreakAlerts and newDayHighBase and f_canFire("NEW_DAY_HIGH", firedToday)
newDayLow = alertCDHL and enableBreakAlerts and newDayLowBase and f_canFire("NEW_DAY_LOW", firedToday)
pmhBreak = alertPMHL and enableBreakAlerts and pmhBreakBase and f_canFire("PMH_BREAK", firedToday)
pmlBreak = alertPMHL and enableBreakAlerts and pmlBreakBase and f_canFire("PML_BREAK", firedToday)
orhBreak = alertORHL and enableBreakAlerts and orhBreakBase and f_canFire("ORH_BREAK", firedToday)
orlBreak = alertORHL and enableBreakAlerts and orlBreakBase and f_canFire("ORL_BREAK", firedToday)
pcUpBreak = alertPC and enableBreakAlerts and pcUpBreakBase and f_canFire("PC_BREAK_ABOVE", firedToday)
pcDownBreak = alertPC and enableBreakAlerts and pcDownBreakBase and f_canFire("PC_BREAK_BELOW", firedToday)
doUpBreak = alertDO and enableBreakAlerts and doUpBreakBase and f_canFire("DO_BREAK_ABOVE", firedToday)
doDownBreak = alertDO and enableBreakAlerts and doDownBreakBase and f_canFire("DO_BREAK_BELOW", firedToday)
pdhBreak = alertPDHL and enableBreakAlerts and pdhBreakBase and f_canFire("PDH_BREAK", firedToday)
pdlBreak = alertPDHL and enableBreakAlerts and pdlBreakBase and f_canFire("PDL_BREAK", firedToday)
pwhBreak = alertPWHL and enableBreakAlerts and pwhBreakBase and f_canFire("PWH_BREAK", firedToday)
pwlBreak = alertPWHL and enableBreakAlerts and pwlBreakBase and f_canFire("PWL_BREAK", firedToday)
pmohBreak = alertPMoHL and enableBreakAlerts and pmohBreakBase and f_canFire("PMOH_BREAK", firedToday)
pmolBreak = alertPMoHL and enableBreakAlerts and pmolBreakBase and f_canFire("PMOL_BREAK", firedToday)

pmhReject = alertPMHL and enableRejectionAlerts and pmhRejectBase and f_canFire("PMH_REJECT", firedToday)
pmlReject = alertPMHL and enableRejectionAlerts and pmlRejectBase and f_canFire("PML_REJECT", firedToday)
orhReject = alertORHL and enableRejectionAlerts and orhRejectBase and f_canFire("ORH_REJECT", firedToday)
orlReject = alertORHL and enableRejectionAlerts and orlRejectBase and f_canFire("ORL_REJECT", firedToday)
pcRejectUp = (alertPC) and enableRejectionAlerts and pcRejectUpBase and f_canFire("PC_REJECT_UP", firedToday)
pcRejectDn = (alertPC) and enableRejectionAlerts and pcRejectDnBase and f_canFire("PC_REJECT_DN", firedToday)
doRejectUp = (alertDO) and enableRejectionAlerts and doRejectUpBase and f_canFire("DO_REJECT_UP", firedToday)
doRejectDn = (alertDO) and enableRejectionAlerts and doRejectDnBase and f_canFire("DO_REJECT_DN", firedToday)
pdhReject = alertPDHL and enableRejectionAlerts and pdhRejectBase and f_canFire("PDH_REJECT", firedToday)
pdlReject = alertPDHL and enableRejectionAlerts and pdlRejectBase and f_canFire("PDL_REJECT", firedToday)
pwhReject = alertPWHL and enableRejectionAlerts and pwhRejectBase and f_canFire("PWH_REJECT", firedToday)
pwlReject = alertPWHL and enableRejectionAlerts and pwlRejectBase and f_canFire("PWL_REJECT", firedToday)
pmohReject = alertPMoHL and enableRejectionAlerts and pmohRejectBase and f_canFire("PMOH_REJECT", firedToday)
pmolReject = alertPMoHL and enableRejectionAlerts and pmolRejectBase and f_canFire("PMOL_REJECT", firedToday)

pmhReclaim = alertPMHL and enableReclaimAlerts and pmhFlipNow and f_canFire("PMH_RECLAIM", firedToday)
pmlReclaim = alertPMHL and enableReclaimAlerts and pmlFlipNow and f_canFire("PML_RECLAIM", firedToday)
orhReclaim = alertORHL and enableReclaimAlerts and orhFlipNow and f_canFire("ORH_RECLAIM", firedToday)
orlReclaim = alertORHL and enableReclaimAlerts and orlFlipNow and f_canFire("ORL_RECLAIM", firedToday)
pcReclaim = (alertPC) and enableReclaimAlerts and (pcFlipSupNow or pcFlipResNow) and f_canFire("PC_RECLAIM", firedToday)
doReclaim = (alertDO) and enableReclaimAlerts and (doFlipSupNow or doFlipResNow) and f_canFire("DO_RECLAIM", firedToday)
pdhReclaim = alertPDHL and enableReclaimAlerts and pdhFlipNow and f_canFire("PDH_RECLAIM", firedToday)
pdlReclaim = alertPDHL and enableReclaimAlerts and pdlFlipNow and f_canFire("PDL_RECLAIM", firedToday)
pwhReclaim = alertPWHL and enableReclaimAlerts and pwhFlipNow and f_canFire("PWH_RECLAIM", firedToday)
pwlReclaim = alertPWHL and enableReclaimAlerts and pwlFlipNow and f_canFire("PWL_RECLAIM", firedToday)
pmohReclaim = alertPMoHL and enableReclaimAlerts and pmohFlipNow and f_canFire("PMOH_RECLAIM", firedToday)
pmolReclaim = alertPMoHL and enableReclaimAlerts and pmolFlipNow and f_canFire("PMOL_RECLAIM", firedToday)

pmhProx = alertPMHL and enableProximityAlerts and pmhProxBase and f_canFire("PMH_PROX", firedToday)
pmlProx = alertPMHL and enableProximityAlerts and pmlProxBase and f_canFire("PML_PROX", firedToday)
orhProx = alertORHL and enableProximityAlerts and orhProxBase and f_canFire("ORH_PROX", firedToday)
orlProx = alertORHL and enableProximityAlerts and orlProxBase and f_canFire("ORL_PROX", firedToday)
pcProx = (alertPC) and enableProximityAlerts and pcProxBase and f_canFire("PC_PROX", firedToday)
doProx = (alertDO) and enableProximityAlerts and doProxBase and f_canFire("DO_PROX", firedToday)
pdhProx = alertPDHL and enableProximityAlerts and pdhProxBase and f_canFire("PDH_PROX", firedToday)
pdlProx = alertPDHL and enableProximityAlerts and pdlProxBase and f_canFire("PDL_PROX", firedToday)
pwhProx = alertPWHL and enableProximityAlerts and pwhProxBase and f_canFire("PWH_PROX", firedToday)
pwlProx = alertPWHL and enableProximityAlerts and pwlProxBase and f_canFire("PWL_PROX", firedToday)
pmohProx = alertPMoHL and enableProximityAlerts and pmohProxBase and f_canFire("PMOH_PROX", firedToday)
pmolProx = alertPMoHL and enableProximityAlerts and pmolProxBase and f_canFire("PMOL_PROX", firedToday)

firedToday := newDayHigh ? f_markFire("NEW_DAY_HIGH", firedToday) : firedToday
firedToday := newDayLow ? f_markFire("NEW_DAY_LOW", firedToday) : firedToday
firedToday := pmhBreak ? f_markFire("PMH_BREAK", firedToday) : firedToday
firedToday := pmlBreak ? f_markFire("PML_BREAK", firedToday) : firedToday
firedToday := orhBreak ? f_markFire("ORH_BREAK", firedToday) : firedToday
firedToday := orlBreak ? f_markFire("ORL_BREAK", firedToday) : firedToday
firedToday := pcUpBreak ? f_markFire("PC_BREAK_ABOVE", firedToday) : firedToday
firedToday := pcDownBreak ? f_markFire("PC_BREAK_BELOW", firedToday) : firedToday
firedToday := doUpBreak ? f_markFire("DO_BREAK_ABOVE", firedToday) : firedToday
firedToday := doDownBreak ? f_markFire("DO_BREAK_BELOW", firedToday) : firedToday
firedToday := pdhBreak ? f_markFire("PDH_BREAK", firedToday) : firedToday
firedToday := pdlBreak ? f_markFire("PDL_BREAK", firedToday) : firedToday
firedToday := pwhBreak ? f_markFire("PWH_BREAK", firedToday) : firedToday
firedToday := pwlBreak ? f_markFire("PWL_BREAK", firedToday) : firedToday
firedToday := pmohBreak ? f_markFire("PMOH_BREAK", firedToday) : firedToday
firedToday := pmolBreak ? f_markFire("PMOL_BREAK", firedToday) : firedToday
firedToday := pmhReject ? f_markFire("PMH_REJECT", firedToday) : firedToday
firedToday := pmlReject ? f_markFire("PML_REJECT", firedToday) : firedToday
firedToday := orhReject ? f_markFire("ORH_REJECT", firedToday) : firedToday
firedToday := orlReject ? f_markFire("ORL_REJECT", firedToday) : firedToday
firedToday := pcRejectUp ? f_markFire("PC_REJECT_UP", firedToday) : firedToday
firedToday := pcRejectDn ? f_markFire("PC_REJECT_DN", firedToday) : firedToday
firedToday := doRejectUp ? f_markFire("DO_REJECT_UP", firedToday) : firedToday
firedToday := doRejectDn ? f_markFire("DO_REJECT_DN", firedToday) : firedToday
firedToday := pdhReject ? f_markFire("PDH_REJECT", firedToday) : firedToday
firedToday := pdlReject ? f_markFire("PDL_REJECT", firedToday) : firedToday
firedToday := pwhReject ? f_markFire("PWH_REJECT", firedToday) : firedToday
firedToday := pwlReject ? f_markFire("PWL_REJECT", firedToday) : firedToday
firedToday := pmohReject ? f_markFire("PMOH_REJECT", firedToday) : firedToday
firedToday := pmolReject ? f_markFire("PMOL_REJECT", firedToday) : firedToday
firedToday := pmhReclaim ? f_markFire("PMH_RECLAIM", firedToday) : firedToday
firedToday := pmlReclaim ? f_markFire("PML_RECLAIM", firedToday) : firedToday
firedToday := orhReclaim ? f_markFire("ORH_RECLAIM", firedToday) : firedToday
firedToday := orlReclaim ? f_markFire("ORL_RECLAIM", firedToday) : firedToday
firedToday := pcReclaim ? f_markFire("PC_RECLAIM", firedToday) : firedToday
firedToday := doReclaim ? f_markFire("DO_RECLAIM", firedToday) : firedToday
firedToday := pdhReclaim ? f_markFire("PDH_RECLAIM", firedToday) : firedToday
firedToday := pdlReclaim ? f_markFire("PDL_RECLAIM", firedToday) : firedToday
firedToday := pwhReclaim ? f_markFire("PWH_RECLAIM", firedToday) : firedToday
firedToday := pwlReclaim ? f_markFire("PWL_RECLAIM", firedToday) : firedToday
firedToday := pmohReclaim ? f_markFire("PMOH_RECLAIM", firedToday) : firedToday
firedToday := pmolReclaim ? f_markFire("PMOL_RECLAIM", firedToday) : firedToday
firedToday := pmhProx ? f_markFire("PMH_PROX", firedToday) : firedToday
firedToday := pmlProx ? f_markFire("PML_PROX", firedToday) : firedToday
firedToday := orhProx ? f_markFire("ORH_PROX", firedToday) : firedToday
firedToday := orlProx ? f_markFire("ORL_PROX", firedToday) : firedToday
firedToday := pcProx ? f_markFire("PC_PROX", firedToday) : firedToday
firedToday := doProx ? f_markFire("DO_PROX", firedToday) : firedToday
firedToday := pdhProx ? f_markFire("PDH_PROX", firedToday) : firedToday
firedToday := pdlProx ? f_markFire("PDL_PROX", firedToday) : firedToday
firedToday := pwhProx ? f_markFire("PWH_PROX", firedToday) : firedToday
firedToday := pwlProx ? f_markFire("PWL_PROX", firedToday) : firedToday
firedToday := pmohProx ? f_markFire("PMOH_PROX", firedToday) : firedToday
firedToday := pmolProx ? f_markFire("PMOL_PROX", firedToday) : firedToday

if newDayHigh
    f_sendAlert("New Day High")
if newDayLow
    f_sendAlert("New Day Low")
if pmhBreak
    f_sendAlert("PMH Break")
if pmlBreak
    f_sendAlert("PML Break")
if orhBreak
    f_sendAlert("ORH Break")
if orlBreak
    f_sendAlert("ORL Break")
if pcUpBreak
    f_sendAlert("PC Break Above")
if pcDownBreak
    f_sendAlert("PC Break Below")
if doUpBreak
    f_sendAlert("DO Break Above")
if doDownBreak
    f_sendAlert("DO Break Below")
if pdhBreak
    f_sendAlert("PDH Break")
if pdlBreak
    f_sendAlert("PDL Break")
if pwhBreak
    f_sendAlert("PWH Break")
if pwlBreak
    f_sendAlert("PWL Break")
if pmohBreak
    f_sendAlert("PMoH Break")
if pmolBreak
    f_sendAlert("PMoL Break")
if pmhReject
    f_sendAlert("PMH Rejection")
if pmlReject
    f_sendAlert("PML Rejection")
if orhReject
    f_sendAlert("ORH Rejection")
if orlReject
    f_sendAlert("ORL Rejection")
if pcRejectUp
    f_sendAlert("PC Rejection Above")
if pcRejectDn
    f_sendAlert("PC Rejection Below")
if doRejectUp
    f_sendAlert("DO Rejection Above")
if doRejectDn
    f_sendAlert("DO Rejection Below")
if pdhReject
    f_sendAlert("PDH Rejection")
if pdlReject
    f_sendAlert("PDL Rejection")
if pwhReject
    f_sendAlert("PWH Rejection")
if pwlReject
    f_sendAlert("PWL Rejection")
if pmohReject
    f_sendAlert("PMoH Rejection")
if pmolReject
    f_sendAlert("PMoL Rejection")
if pmhReclaim
    f_sendAlert("PMH Reclaim")
if pmlReclaim
    f_sendAlert("PML Reclaim")
if orhReclaim
    f_sendAlert("ORH Reclaim")
if orlReclaim
    f_sendAlert("ORL Reclaim")
if pcReclaim
    f_sendAlert("PC Reclaim")
if doReclaim
    f_sendAlert("DO Reclaim")
if pdhReclaim
    f_sendAlert("PDH Reclaim")
if pdlReclaim
    f_sendAlert("PDL Reclaim")
if pwhReclaim
    f_sendAlert("PWH Reclaim")
if pwlReclaim
    f_sendAlert("PWL Reclaim")
if pmohReclaim
    f_sendAlert("PMoH Reclaim")
if pmolReclaim
    f_sendAlert("PMoL Reclaim")
if pmhProx
    f_sendAlert("PMH Proximity")
if pmlProx
    f_sendAlert("PML Proximity")
if orhProx
    f_sendAlert("ORH Proximity")
if orlProx
    f_sendAlert("ORL Proximity")
if pcProx
    f_sendAlert("PC Proximity")
if doProx
    f_sendAlert("DO Proximity")
if pdhProx
    f_sendAlert("PDH Proximity")
if pdlProx
    f_sendAlert("PDL Proximity")
if pwhProx
    f_sendAlert("PWH Proximity")
if pwlProx
    f_sendAlert("PWL Proximity")
if pmohProx
    f_sendAlert("PMoH Proximity")
if pmolProx
    f_sendAlert("PMoL Proximity")

// --- Invisible plots for manual cross alert dropdown ---
plot(cdh, title = "CDH", color = na, display = display.none)
plot(cdl, title = "CDL", color = na, display = display.none)
plot(pmH, title = "PMH", color = na, display = display.none)
plot(pmL, title = "PML", color = na, display = display.none)
plot(orH, title = "ORH", color = na, display = display.none)
plot(orL, title = "ORL", color = na, display = display.none)
plot(prevClose, title = "Previous Close", color = na, display = display.none)
plot(dayOpen, title = "Day Open", color = na, display = display.none)
plot(pdh, title = "PDH", color = na, display = display.none)
plot(pdl, title = "PDL", color = na, display = display.none)
plot(pwh, title = "PWH", color = na, display = display.none)
plot(pwl, title = "PWL", color = na, display = display.none)
plot(pmoh, title = "PMoH", color = na, display = display.none)
plot(pmol, title = "PMoL", color = na, display = display.none)
````
