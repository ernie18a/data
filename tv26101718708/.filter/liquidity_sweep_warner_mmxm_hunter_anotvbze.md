# Liquidity Sweep Warner - MMXM Hunter

- url: https://www.tradingview.com/script/AnOtvbze-Liquidity-Sweep-Warner-MMXM-Hunter/
- type: indicator
- pine_id: PUB;2efa3440dd354b289c5374c5c4d83191
- version: 6.0

## Description

Hier ist eine professionelle englische Beschreibung für TradingView:

---

# Liquidity Sweep Warner – ICT / SMC Dashboard

The Liquidity Sweep Warner is designed for ICT and Smart Money Concepts traders who want a clear overview of whether key liquidity levels have already been taken during the trading day.

The indicator automatically tracks major external liquidity pools and displays their current status in a clean dashboard located in the top-right corner of the chart.

## Tracked Liquidity Levels

### Previous Day Liquidity

* Previous Day High (PDH)
* Previous Day Low (PDL)

### Asia Session Liquidity

Based on New York Time:

* Asia Session: 7:00 PM – 3:00 AM NY Time
* Asia High
* Asia Low

### London Session Liquidity

Based on New York Time:

* London Session: 3:00 AM – 9:30 AM NY Time
* London High
* London Low

### 1-Hour Main Swing Liquidity

The indicator automatically identifies major 1H swing highs and swing lows.

Default swing definition:

* Higher than the previous 3 candles
* Confirmed by 1 candle on the right

This can be customized in the settings.

## Sweep Detection

A liquidity level is considered swept immediately when price touches or exceeds the level.

No candle close is required.

Examples:

* High ≥ PDH → PDH is marked as TAKEN
* Low ≤ PDL → PDL is marked as TAKEN

This reflects the true concept of stop-hunt liquidity where even a single tick beyond the level is sufficient.

## Dashboard

The dashboard displays:

* PDH
* PDL
* Asia High
* Asia Low
* London High
* London Low
* 1H Main Swing High
* 1H Main Swing Low

Status colors:

* Green = TAKEN
* Red = OPEN

This allows traders to instantly see which liquidity pools remain available and which have already been cleared.

## Visual Chart Markings

Every tracked liquidity level is drawn as a horizontal line extending from its origin to the current price.

When a level gets swept:

* The line changes to gray
* The line becomes dashed
* An optional sweep label is printed on the chart

This makes it easy to visually confirm where liquidity has been taken.

## Alerts

The indicator can generate alerts whenever any tracked liquidity level is swept:

* PDH Swept
* PDL Swept
* Asia High Swept
* Asia Low Swept
* London High Swept
* London Low Swept
* 1H Main Swing High Swept
* 1H Main Swing Low Swept

Perfect for traders who want immediate notification when liquidity is removed from the market.

## Purpose

The goal of this indicator is simple:

Avoid trading directly into liquidity that has already been taken and maintain awareness of the next likely liquidity objective.

It provides a clear picture of market structure, external liquidity, and potential draw-on-liquidity targets throughout the trading day.

---

**Recommended Use:** ICT, SMC, MMXM, Liquidity-Based Trading, Market Structure Analysis, London Session Trading, New York Session Trading, Futures, Forex, Indices, and Crypto Markets.

## Source Code

````pine
//@version=6
indicator("Liquidity Sweep Warner - v1.1", overlay=true, max_lines_count=400, max_labels_count=200)

// ─────────────────────────────────────
// Inputs
// ─────────────────────────────────────
tz = input.string("America/New_York", "Session Timezone")

asiaSession   = input.session("1900-0300", "Asia Session NY")
londonSession = input.session("0300-0930", "London Session NY")

tfSwing = input.timeframe("15", "Main Swing Timeframe")
tfSwing2 = input.timeframe("60", "Additional Swing Timeframe 2")
tfSwing3 = input.timeframe("240", "Additional Swing Timeframe 3")
maxSwings = input.int(2, "Anzahl historischer Swing Points", minval=1)

labelVisualMode = input.string("Prominent", "Sweep Label Stil", options=["Prominent", "Dezent", "Sehr dezent"])
sweepLabelSymbol = input.string("•", "Sweep Label Symbol", options=["None", "•", "◆", "▲", "✕", "!"])
sweepLabelSizeInput = input.string("Normal", "Sweep Label Größe", options=["Tiny", "Small", "Normal", "Large"])

showSweepsTf1 = input.bool(true, "Sweeps TF1 anzeigen")
showSweepsTf2 = input.bool(true, "Sweeps TF2 anzeigen")
showSweepsTf3 = input.bool(true, "Sweeps TF3 anzeigen")

openLevelsModeTf1 = input.string("Latest", "TF1 offene Levels", options=["All", "Latest"])
openLevelsModeTf2 = input.string("Latest", "TF2 offene Levels", options=["All", "Latest"])
openLevelsModeTf3 = input.string("Latest", "TF3 offene Levels", options=["All", "Latest"])

openLevelsLatestTf1 = input.int(3, "TF1 offene Levels (Latest X)", minval=1, maxval=50)
openLevelsLatestTf2 = input.int(2, "TF2 offene Levels (Latest X)", minval=1, maxval=50)
openLevelsLatestTf3 = input.int(2, "TF3 offene Levels (Latest X)", minval=1, maxval=50)

sweptLevelsModeTf1 = input.string("Latest", "TF1 gesweepte Levels", options=["All", "Latest"])
sweptLevelsModeTf2 = input.string("Latest", "TF2 gesweepte Levels", options=["All", "Latest"])
sweptLevelsModeTf3 = input.string("Latest", "TF3 gesweepte Levels", options=["All", "Latest"])

sweptLevelsLatestTf1 = input.int(2, "TF1 gesweepte Levels (Latest X)", minval=0, maxval=50)
sweptLevelsLatestTf2 = input.int(1, "TF2 gesweepte Levels (Latest X)", minval=0, maxval=50)
sweptLevelsLatestTf3 = input.int(1, "TF3 gesweepte Levels (Latest X)", minval=0, maxval=50)

sweepLabelsModeTf1 = input.string("Latest", "TF1 Sweep-Labels", options=["All", "Latest"])
sweepLabelsModeTf2 = input.string("Latest", "TF2 Sweep-Labels", options=["All", "Latest"])
sweepLabelsModeTf3 = input.string("Latest", "TF3 Sweep-Labels", options=["All", "Latest"])

sweepLabelsLatestTf1 = input.int(8, "TF1 Sweep-Labels (Latest X)", minval=0, maxval=100)
sweepLabelsLatestTf2 = input.int(5, "TF2 Sweep-Labels (Latest X)", minval=0, maxval=100)
sweepLabelsLatestTf3 = input.int(3, "TF3 Sweep-Labels (Latest X)", minval=0, maxval=100)
sessionSweepLabelsLatest = input.int(20, "Session/PD Sweep-Labels (Latest X)", minval=0, maxval=200)
sessionSweepLabelTransparency = input.int(0, "Session/PD Sweep-Label Transparenz", minval=0, maxval=95)
sessionSweepLabelSizeInput = input.string("Normal", "Session/PD Sweep-Label Größe", options=["Tiny", "Small", "Normal", "Large"])

allModeFallbackMax = input.int(30, "All-Modus Sicherheitslimit", minval=1, maxval=200)

showDashboard = input.bool(false, "Dashboard anzeigen")
showLines     = input.bool(true, "Linien anzeigen")
showLabels    = input.bool(true, "Sweep Labels anzeigen")
showSessionLevelLabels = input.bool(false, "Session Level Labels (ASIA/LON) anzeigen")
showSwing2    = input.bool(true, "HTF 2 anzeigen")
showSwing3    = input.bool(true, "HTF 3 anzeigen")

dashGroup = "Dashboard Konfiguration"
dashTextSizeInput = input.string("Normal", "Dashboard Größe", options=["Tiny", "Small", "Normal", "Large"], group=dashGroup)
dashTransparency = input.int(20, "Dashboard Transparenz", minval=0, maxval=95, group=dashGroup)
dashShowPdhPdl = input.bool(true, "PDH/PDL zeigen", group=dashGroup)
dashShowAsia = input.bool(true, "Asia H/L zeigen", group=dashGroup)
dashShowLondon = input.bool(true, "London H/L zeigen", group=dashGroup)
dashShowTf1 = input.bool(true, "TF1 SH/SL zeigen", group=dashGroup)
dashShowTf2 = input.bool(true, "TF2 SH/SL zeigen", group=dashGroup)
dashShowTf3 = input.bool(true, "TF3 SH/SL zeigen", group=dashGroup)
dashShowNext = input.bool(true, "NEXT zeigen", group=dashGroup)

obGroup = "Order Blocks"
showOrderBlocks = input.bool(true, "Order Blocks anzeigen", group=obGroup)
obConfirmMode = input.string("Direct", "OB Bestätigung", options=["Direct", "FVG Confirmed"], group=obGroup)
obBreakBasis = input.string("Close", "Break/Invalidation zählt", options=["Close", "Wick"], group=obGroup)
obSignalTiming = input.string("On Close", "OB Anzeige-Timing", options=["Realtime", "On Close"], group=obGroup)
obBoundsMode = input.string("Wick-Open (Preferred)", "OB Grenzen", options=["Wick-Open (Preferred)", "Full Candle", "Body Open-Close"], group=obGroup)
obWidthBars = input.int(5, "OB Breite (Kerzen inkl. Initial)", minval=1, maxval=100, group=obGroup)
showInvalidatedObs = input.bool(true, "Invalidierte OB zeigen", group=obGroup)
maxHistoricalObs = input.int(30, "Anzahl historische OBs", minval=1, maxval=200, group=obGroup)
showHtfOb1 = input.bool(true, "HTF OB 1 anzeigen", group=obGroup)
htfObTf1 = input.timeframe("15", "HTF OB 1 Timeframe", group=obGroup)
showHtfOb2 = input.bool(false, "HTF OB 2 anzeigen", group=obGroup)
htfObTf2 = input.timeframe("60", "HTF OB 2 Timeframe", group=obGroup)

// ─────────────────────────────────────
// Helper
// ─────────────────────────────────────
f_status(_swept) =>
    _swept ? "TAKEN" : "OPEN"

f_bg(_swept) =>
    _swept ? color.green : color.red

f_makeLine(_oldLine, _x1, _y, _col) =>
    if not na(_oldLine)
        line.delete(_oldLine)
    line.new(_x1, _y, time, _y, xloc=xloc.bar_time, extend=extend.none, color=_col, width=2)

f_makeLevelLabel(_oldLabel, _x, _y, _txt, _style, _col) =>
    if not na(_oldLabel)
        label.delete(_oldLabel)
    label.new(_x, _y, _txt, xloc=xloc.bar_time, style=_style, color=_col, textcolor=color.white)

f_sweepLine(_ln) =>
    if not na(_ln)
        line.set_x2(_ln, time)
        line.set_color(_ln, color.gray)
        line.set_style(_ln, line.style_dashed)

f_extend(_ln) =>
    if not na(_ln)
        line.set_x2(_ln, time)

f_tfName(_tf) =>
    _tf == "1" ? "1m" :
     _tf == "3" ? "3m" :
     _tf == "5" ? "5m" :
     _tf == "15" ? "15m" :
     _tf == "30" ? "30m" :
     _tf == "45" ? "45m" :
     _tf == "60" ? "1H" :
     _tf == "120" ? "2H" :
     _tf == "180" ? "3H" :
     _tf == "240" ? "4H" :
     _tf == "D" ? "1D" :
     _tf == "W" ? "1W" :
     _tf == "M" ? "1M" : _tf

f_labelSize(_s) =>
    _s == "Tiny" ? size.tiny : _s == "Small" ? size.small : _s == "Large" ? size.large : size.normal

f_dashTextSize(_s) =>
    _s == "Tiny" ? size.tiny : _s == "Small" ? size.small : _s == "Large" ? size.large : size.normal

f_dashBg(_base) =>
    color.new(_base, dashTransparency)

f_sweepBg(_base) =>
    _alpha = labelVisualMode == "Sehr dezent" ? 85 : labelVisualMode == "Dezent" ? 65 : 0
    color.new(_base, _alpha)

f_sweepTextColor() =>
    _alpha = labelVisualMode == "Sehr dezent" ? 55 : labelVisualMode == "Dezent" ? 25 : 0
    color.new(color.white, _alpha)

f_sessionSweepBg(_base) =>
    color.new(_base, sessionSweepLabelTransparency)

f_sweepPrefix() =>
    sweepLabelSymbol == "None" ? "" : sweepLabelSymbol + " "

f_modeLimit(_mode, _latest) =>
    _mode == "All" ? allModeFallbackMax : _latest

f_levelExistsAtPrice(_prices, _p) =>
    _exists = false
    _eps = syminfo.mintick * 0.5
    _i = 0
    while _i < array.size(_prices)
        if math.abs(array.get(_prices, _i) - _p) <= _eps
            _exists := true
        _i += 1
    _exists

f_pushAndTrimSweepLabel(_arr, _lb, _mode, _latest) =>
    if not na(_lb)
        array.push(_arr, _lb)
    _limit = f_modeLimit(_mode, _latest)
    while array.size(_arr) > _limit
        _old = array.shift(_arr)
        if not na(_old)
            label.delete(_old)

f_pruneLevels(_prices, _times, _lines, _labels, _swept, _openMode, _openLatest, _sweptMode, _sweptLatest) =>
    _openKeep = f_modeLimit(_openMode, _openLatest)
    _sweptKeep = f_modeLimit(_sweptMode, _sweptLatest)
    _openCnt = 0
    _sweptCnt = 0
    if array.size(_prices) > 0
        _i = array.size(_prices) - 1
        while _i >= 0
            _isSwept = array.get(_swept, _i)
            _keep = _isSwept ? (_sweptCnt < _sweptKeep) : (_openCnt < _openKeep)
            if _keep
                if _isSwept
                    _sweptCnt += 1
                else
                    _openCnt += 1
            else
                _ln = array.get(_lines, _i)
                _lb = array.get(_labels, _i)
                if not na(_ln)
                    line.delete(_ln)
                if not na(_lb)
                    label.delete(_lb)
                array.remove(_prices, _i)
                array.remove(_times, _i)
                array.remove(_lines, _i)
                array.remove(_labels, _i)
                array.remove(_swept, _i)
            _i -= 1

f_clearLevels(_prices, _times, _lines, _labels, _swept) =>
    while array.size(_prices) > 0
        _ln = array.pop(_lines)
        _lb = array.pop(_labels)
        array.pop(_prices)
        array.pop(_times)
        array.pop(_swept)
        if not na(_ln)
            line.delete(_ln)
        if not na(_lb)
            label.delete(_lb)

f_clearLabelArray(_arr) =>
    while array.size(_arr) > 0
        _lb = array.pop(_arr)
        if not na(_lb)
            label.delete(_lb)

f_obTop(_isBull, _o, _h, _l, _c) =>
    if obBoundsMode == "Wick-Open (Preferred)"
        _isBull ? _o : _h
    else if obBoundsMode == "Full Candle"
        _h
    else
        math.max(_o, _c)

f_obBottom(_isBull, _o, _h, _l, _c) =>
    if obBoundsMode == "Wick-Open (Preferred)"
        _isBull ? _l : _o
    else if obBoundsMode == "Full Candle"
        _l
    else
        math.min(_o, _c)

f_obBarMs() =>
    nz(timeframe.in_seconds(timeframe.period), 60) * 1000

f_tfBarMs(_tf) =>
    nz(timeframe.in_seconds(_tf), nz(timeframe.in_seconds(timeframe.period), 60)) * 1000

f_tfLabel(_tf) =>
    _n = str.tonumber(_tf)
    if na(_n)
        _tf
    else
        _mins = int(_n)
        if _mins < 60
            str.tostring(_mins) + "m"
        else if math.floor(_mins / 60) * 60 == _mins
            _hours = int(_mins / 60)
            str.tostring(_hours) + "H"
        else
            str.tostring(_mins) + "m"

f_showTfOnChart(_tf) =>
    _chartSec = timeframe.in_seconds(timeframe.period)
    _tfSec = timeframe.in_seconds(_tf)
    na(_chartSec) or na(_tfSec) ? true : _chartSec <= _tfSec

// ─────────────────────────────────────
// Previous Day High / Low
// ─────────────────────────────────────
pdh = request.security(syminfo.tickerid, "D", high[1], barmerge.gaps_off, barmerge.lookahead_off)
pdl = request.security(syminfo.tickerid, "D", low[1], barmerge.gaps_off, barmerge.lookahead_off)
pdTime = request.security(syminfo.tickerid, "D", time[1], barmerge.gaps_off, barmerge.lookahead_off)

newDay = dayofmonth != dayofmonth[1]

var bool pdhSwept = false
var bool pdlSwept = false
var line pdhLine = na
var line pdlLine = na
var label pdhLevelLabel = na
var label pdlLevelLabel = na

if newDay
    pdhSwept := false
    pdlSwept := false
    if showLines
        pdhLine := f_makeLine(pdhLine, pdTime, pdh, color.red)
        pdlLine := f_makeLine(pdlLine, pdTime, pdl, color.lime)
    if showLabels
        pdhLevelLabel := f_makeLevelLabel(pdhLevelLabel, pdTime, pdh, "PDH", label.style_label_down, color.red)
        pdlLevelLabel := f_makeLevelLabel(pdlLevelLabel, pdTime, pdl, "PDL", label.style_label_up, color.green)

// ─────────────────────────────────────
// Asia Session 19:00–03:00 NY
// ─────────────────────────────────────
inAsia = not na(time(timeframe.period, asiaSession, tz))
asiaStart = inAsia and not inAsia[1]
asiaEnd   = not inAsia and inAsia[1]

var float asiaHigh = na
var float asiaLow  = na
var int asiaHighTime = na
var int asiaLowTime  = na
var bool asiaHighSwept = false
var bool asiaLowSwept  = false
var bool asiaLevelsFinalized = false
var line asiaHighLine = na
var line asiaLowLine  = na
var label asiaHighLevelLabel = na
var label asiaLowLevelLabel  = na

if asiaStart
    asiaHigh := high
    asiaLow := low
    asiaHighTime := time
    asiaLowTime := time
    asiaHighSwept := false
    asiaLowSwept := false
    asiaLevelsFinalized := false

if inAsia
    if na(asiaHigh) or high > asiaHigh
        asiaHigh := high
        asiaHighTime := time
    if na(asiaLow) or low < asiaLow
        asiaLow := low
        asiaLowTime := time

if asiaEnd and showLines
    asiaHighLine := f_makeLine(asiaHighLine, asiaHighTime, asiaHigh, color.red)
    asiaLowLine  := f_makeLine(asiaLowLine, asiaLowTime, asiaLow, color.lime)

if asiaEnd
    asiaLevelsFinalized := true

if asiaEnd and showLabels and showSessionLevelLabels
    asiaHighLevelLabel := f_makeLevelLabel(asiaHighLevelLabel, asiaHighTime, asiaHigh, "ASIA H", label.style_label_down, color.red)
    asiaLowLevelLabel  := f_makeLevelLabel(asiaLowLevelLabel, asiaLowTime, asiaLow, "ASIA L", label.style_label_up, color.green)

if not showSessionLevelLabels
    if not na(asiaHighLevelLabel)
        label.delete(asiaHighLevelLabel)
        asiaHighLevelLabel := na
    if not na(asiaLowLevelLabel)
        label.delete(asiaLowLevelLabel)
        asiaLowLevelLabel := na

// ─────────────────────────────────────
// London Session 03:00–09:30 NY
// ─────────────────────────────────────
inLondon = not na(time(timeframe.period, londonSession, tz))
londonStart = inLondon and not inLondon[1]
londonEnd   = not inLondon and inLondon[1]

var float londonHigh = na
var float londonLow  = na
var int londonHighTime = na
var int londonLowTime  = na
var bool londonHighSwept = false
var bool londonLowSwept  = false
var bool londonLevelsFinalized = false
var line londonHighLine = na
var line londonLowLine  = na
var label londonHighLevelLabel = na
var label londonLowLevelLabel  = na

if londonStart
    londonHigh := high
    londonLow := low
    londonHighTime := time
    londonLowTime := time
    londonHighSwept := false
    londonLowSwept := false
    londonLevelsFinalized := false

if inLondon
    if na(londonHigh) or high > londonHigh
        londonHigh := high
        londonHighTime := time
    if na(londonLow) or low < londonLow
        londonLow := low
        londonLowTime := time

if londonEnd and showLines
    londonHighLine := f_makeLine(londonHighLine, londonHighTime, londonHigh, color.red)
    londonLowLine  := f_makeLine(londonLowLine, londonLowTime, londonLow, color.lime)

if londonEnd
    londonLevelsFinalized := true

var array<label> sessionSweepLabels = array.new_label()

if londonEnd and showLabels and showSessionLevelLabels
    londonHighLevelLabel := f_makeLevelLabel(londonHighLevelLabel, londonHighTime, londonHigh, "LON H", label.style_label_down, color.red)
    londonLowLevelLabel  := f_makeLevelLabel(londonLowLevelLabel, londonLowTime, londonLow, "LON L", label.style_label_up, color.green)

if not showSessionLevelLabels
    if not na(londonHighLevelLabel)
        label.delete(londonHighLevelLabel)
        londonHighLevelLabel := na
    if not na(londonLowLevelLabel)
        label.delete(londonLowLevelLabel)
        londonLowLevelLabel := na

// ─────────────────────────────────────
// 1H Main Swing High / Low
// ─────────────────────────────────────
// Exakte Regel (direkte Nachbarkerzen):
// SL: low[1] muss tiefer sein als low[2] (links) und low (rechts)
// SH: high[1] muss höher sein als high[2] (links) und high (rechts)
f_swings() =>
    _validHigh = not na(high[2]) and not na(high[1]) and not na(high) and high[1] > high[2] and high[1] > high
    _validLow  = not na(low[2]) and not na(low[1]) and not na(low) and low[1] < low[2] and low[1] < low

    _lastHigh     = ta.valuewhen(_validHigh, high[1], 0)
    _lastHighTime = ta.valuewhen(_validHigh, time[1], 0)
    _lastLow      = ta.valuewhen(_validLow, low[1], 0)
    _lastLowTime  = ta.valuewhen(_validLow, time[1], 0)
    [_lastHigh, _lastHighTime, _lastLow, _lastLowTime]

[swingHigh, swingHighTime, swingLow, swingLowTime] = request.security(syminfo.tickerid, tfSwing, f_swings(), barmerge.gaps_off, barmerge.lookahead_off)
[swingHigh2, swingHighTime2, swingLow2, swingLowTime2] = request.security(syminfo.tickerid, tfSwing2, f_swings(), barmerge.gaps_off, barmerge.lookahead_off)
[swingHigh3, swingHighTime3, swingLow3, swingLowTime3] = request.security(syminfo.tickerid, tfSwing3, f_swings(), barmerge.gaps_off, barmerge.lookahead_off)

tfSwingName  = f_tfName(tfSwing)
tfSwingName2 = f_tfName(tfSwing2)
tfSwingName3 = f_tfName(tfSwing3)
showTf1OnChart = f_showTfOnChart(tfSwing)
showTf2OnChart = f_showTfOnChart(tfSwing2)
showTf3OnChart = f_showTfOnChart(tfSwing3)

// Arrays für mehrere historische Swing Points (Anzahl = maxSwings)
var array<float> shPrices  = array.new_float()
var array<int>   shTimes   = array.new_int()
var array<line>  shLines    = array.new_line()
var array<label> shLabels   = array.new_label()
var array<bool>  shSweptArr  = array.new_bool()

var array<float> slPrices  = array.new_float()
var array<int>   slTimes   = array.new_int()
var array<line>  slLines    = array.new_line()
var array<label> slLabels   = array.new_label()
var array<bool>  slSweptArr  = array.new_bool()

var int lastShTime = na
var int lastSlTime = na
var float prevMainSwingHighForKey = na
var float prevMainSwingLowForKey = na
var array<label> sweepLabelsTf1 = array.new_label()

newMainSwingHigh = not na(swingHigh) and not na(swingHighTime) and (na(lastShTime) or swingHighTime != lastShTime)
newMainSwingLow  = not na(swingLow) and not na(swingLowTime) and (na(lastSlTime) or swingLowTime != lastSlTime)

if newMainSwingHigh
    lastShTime := swingHighTime
    keyTxtHigh = tfSwingName + " SH"
    prevMainSwingHighForKey := swingHigh
    _existsHighAnyTf = f_levelExistsAtPrice(shPrices, swingHigh)
    if not _existsHighAnyTf and showTf1OnChart
        shLn = showLines ? line.new(swingHighTime, swingHigh, time, swingHigh, xloc=xloc.bar_time, extend=extend.none, color=color.orange, width=2) : na
        shLb = showLabels ? label.new(swingHighTime, swingHigh, keyTxtHigh, xloc=xloc.bar_time, style=label.style_label_down, color=color.orange, textcolor=color.white) : na
        array.push(shPrices, swingHigh)
        array.push(shTimes, swingHighTime)
        array.push(shLines, shLn)
        array.push(shLabels, shLb)
        array.push(shSweptArr, false)
        if array.size(shPrices) > maxSwings
            oldLn = array.shift(shLines)
            oldLb = array.shift(shLabels)
            array.shift(shPrices)
            array.shift(shTimes)
            array.shift(shSweptArr)
            if not na(oldLn)
                line.delete(oldLn)
            if not na(oldLb)
                label.delete(oldLb)

if newMainSwingLow
    lastSlTime := swingLowTime
    keyTxtLow = tfSwingName + " SL"
    prevMainSwingLowForKey := swingLow
    _existsLowAnyTf = f_levelExistsAtPrice(slPrices, swingLow)
    if not _existsLowAnyTf and showTf1OnChart
        slLn = showLines ? line.new(swingLowTime, swingLow, time, swingLow, xloc=xloc.bar_time, extend=extend.none, color=color.aqua, width=2) : na
        slLb = showLabels ? label.new(swingLowTime, swingLow, keyTxtLow, xloc=xloc.bar_time, style=label.style_label_up, color=color.aqua, textcolor=color.white) : na
        array.push(slPrices, swingLow)
        array.push(slTimes, swingLowTime)
        array.push(slLines, slLn)
        array.push(slLabels, slLb)
        array.push(slSweptArr, false)
        if array.size(slPrices) > maxSwings
            oldLnL = array.shift(slLines)
            oldLbL = array.shift(slLabels)
            array.shift(slPrices)
            array.shift(slTimes)
            array.shift(slSweptArr)
            if not na(oldLnL)
                line.delete(oldLnL)
            if not na(oldLbL)
                label.delete(oldLbL)

// Pro Bar: offene Swing-Linien verlängern, gesweepte exakt auf der Sweep-Kerze einfrieren
mainSwingHighSweepNow = false
mainSwingLowSweepNow  = false

if showTf1OnChart and array.size(shPrices) > 0
    for i = 0 to array.size(shPrices) - 1
        shP  = array.get(shPrices, i)
        shSw = array.get(shSweptArr, i)
        shL  = array.get(shLines, i)
        if not shSw
            if high >= shP
                array.set(shSweptArr, i, true)
                mainSwingHighSweepNow := true
                if not na(shL)
                    line.set_x2(shL, time)
                    line.set_color(shL, color.gray)
                    line.set_style(shL, line.style_dashed)
                if showLabels and showSweepsTf1
                    _txt = f_sweepPrefix() + tfSwingName + " SH SWEPT"
                    _lb = label.new(time, shP, _txt, xloc=xloc.bar_time, style=label.style_label_down, color=f_sweepBg(color.orange), textcolor=f_sweepTextColor(), size=f_labelSize(sweepLabelSizeInput))
                    f_pushAndTrimSweepLabel(sweepLabelsTf1, _lb, sweepLabelsModeTf1, sweepLabelsLatestTf1)
            else if not na(shL)
                line.set_x2(shL, time)

if showTf1OnChart and array.size(slPrices) > 0
    for i = 0 to array.size(slPrices) - 1
        slP  = array.get(slPrices, i)
        slSw = array.get(slSweptArr, i)
        slL  = array.get(slLines, i)
        if not slSw
            if low <= slP
                array.set(slSweptArr, i, true)
                mainSwingLowSweepNow := true
                if not na(slL)
                    line.set_x2(slL, time)
                    line.set_color(slL, color.gray)
                    line.set_style(slL, line.style_dashed)
                if showLabels and showSweepsTf1
                    _txt = f_sweepPrefix() + tfSwingName + " SL SWEPT"
                    _lb = label.new(time, slP, _txt, xloc=xloc.bar_time, style=label.style_label_up, color=f_sweepBg(color.aqua), textcolor=f_sweepTextColor(), size=f_labelSize(sweepLabelSizeInput))
                    f_pushAndTrimSweepLabel(sweepLabelsTf1, _lb, sweepLabelsModeTf1, sweepLabelsLatestTf1)
            else if not na(slL)
                line.set_x2(slL, time)

// Aktueller (zuletzt erkannter) Swing für Dashboard / Next-Side-Logik
mainSwingHigh      = array.size(shPrices) > 0 ? array.get(shPrices, array.size(shPrices) - 1) : na
mainSwingLow       = array.size(slPrices) > 0 ? array.get(slPrices, array.size(slPrices) - 1) : na
mainSwingHighSwept = array.size(shSweptArr) > 0 ? array.get(shSweptArr, array.size(shSweptArr) - 1) : false
mainSwingLowSwept  = array.size(slSweptArr) > 0 ? array.get(slSweptArr, array.size(slSweptArr) - 1) : false

if showTf1OnChart and mainSwingHighSweepNow
    alert(tfSwingName + " Swing High swept", alert.freq_once_per_bar)
if showTf1OnChart and mainSwingLowSweepNow
    alert(tfSwingName + " Swing Low swept", alert.freq_once_per_bar)

f_pruneLevels(shPrices, shTimes, shLines, shLabels, shSweptArr, openLevelsModeTf1, openLevelsLatestTf1, sweptLevelsModeTf1, sweptLevelsLatestTf1)
f_pruneLevels(slPrices, slTimes, slLines, slLabels, slSweptArr, openLevelsModeTf1, openLevelsLatestTf1, sweptLevelsModeTf1, sweptLevelsLatestTf1)
if not showTf1OnChart
    f_clearLevels(shPrices, shTimes, shLines, shLabels, shSweptArr)
    f_clearLevels(slPrices, slTimes, slLines, slLabels, slSweptArr)
    f_clearLabelArray(sweepLabelsTf1)

// ─────────────────────────────────────
// Additional Swing HTF 2
// ─────────────────────────────────────
var array<float> shPrices2  = array.new_float()
var array<int>   shTimes2   = array.new_int()
var array<line>  shLines2   = array.new_line()
var array<label> shLabels2  = array.new_label()
var array<bool>  shSweptArr2 = array.new_bool()

var array<float> slPrices2  = array.new_float()
var array<int>   slTimes2   = array.new_int()
var array<line>  slLines2   = array.new_line()
var array<label> slLabels2  = array.new_label()
var array<bool>  slSweptArr2 = array.new_bool()

var int lastShTime2 = na
var int lastSlTime2 = na
var float prevMainSwingHighForKey2 = na
var float prevMainSwingLowForKey2 = na
var array<label> sweepLabelsTf2 = array.new_label()

newMainSwingHigh2 = not na(swingHigh2) and not na(swingHighTime2) and (na(lastShTime2) or swingHighTime2 != lastShTime2)
newMainSwingLow2  = not na(swingLow2) and not na(swingLowTime2) and (na(lastSlTime2) or swingLowTime2 != lastSlTime2)

if newMainSwingHigh2
    lastShTime2 := swingHighTime2
    keyTxtHigh2 = tfSwingName2 + " SH"
    prevMainSwingHighForKey2 := swingHigh2
    _existsHighAnyTf2 = f_levelExistsAtPrice(shPrices2, swingHigh2) or f_levelExistsAtPrice(shPrices, swingHigh2)
    if not _existsHighAnyTf2 and showTf2OnChart
        shLn2 = (showLines and showSwing2) ? line.new(swingHighTime2, swingHigh2, time, swingHigh2, xloc=xloc.bar_time, extend=extend.none, color=color.fuchsia, width=2) : na
        shLb2 = (showLabels and showSwing2) ? label.new(swingHighTime2, swingHigh2, keyTxtHigh2, xloc=xloc.bar_time, style=label.style_label_down, color=color.fuchsia, textcolor=color.white) : na
        array.push(shPrices2, swingHigh2)
        array.push(shTimes2, swingHighTime2)
        array.push(shLines2, shLn2)
        array.push(shLabels2, shLb2)
        array.push(shSweptArr2, false)
        if array.size(shPrices2) > maxSwings
            oldLn2 = array.shift(shLines2)
            oldLb2 = array.shift(shLabels2)
            array.shift(shPrices2)
            array.shift(shTimes2)
            array.shift(shSweptArr2)
            if not na(oldLn2)
                line.delete(oldLn2)
            if not na(oldLb2)
                label.delete(oldLb2)

if newMainSwingLow2
    lastSlTime2 := swingLowTime2
    keyTxtLow2 = tfSwingName2 + " SL"
    prevMainSwingLowForKey2 := swingLow2
    _existsLowAnyTf2 = f_levelExistsAtPrice(slPrices2, swingLow2) or f_levelExistsAtPrice(slPrices, swingLow2)
    if not _existsLowAnyTf2 and showTf2OnChart
        slLn2 = (showLines and showSwing2) ? line.new(swingLowTime2, swingLow2, time, swingLow2, xloc=xloc.bar_time, extend=extend.none, color=color.teal, width=2) : na
        slLb2 = (showLabels and showSwing2) ? label.new(swingLowTime2, swingLow2, keyTxtLow2, xloc=xloc.bar_time, style=label.style_label_up, color=color.teal, textcolor=color.white) : na
        array.push(slPrices2, swingLow2)
        array.push(slTimes2, swingLowTime2)
        array.push(slLines2, slLn2)
        array.push(slLabels2, slLb2)
        array.push(slSweptArr2, false)
        if array.size(slPrices2) > maxSwings
            oldLnL2 = array.shift(slLines2)
            oldLbL2 = array.shift(slLabels2)
            array.shift(slPrices2)
            array.shift(slTimes2)
            array.shift(slSweptArr2)
            if not na(oldLnL2)
                line.delete(oldLnL2)
            if not na(oldLbL2)
                label.delete(oldLbL2)

mainSwingHighSweepNow2 = false
mainSwingLowSweepNow2  = false

if showTf2OnChart and array.size(shPrices2) > 0
    for i = 0 to array.size(shPrices2) - 1
        shP2  = array.get(shPrices2, i)
        shSw2 = array.get(shSweptArr2, i)
        shL2  = array.get(shLines2, i)
        if not shSw2
            if high >= shP2
                array.set(shSweptArr2, i, true)
                mainSwingHighSweepNow2 := true
                if not na(shL2)
                    line.set_x2(shL2, time)
                    line.set_color(shL2, color.gray)
                    line.set_style(shL2, line.style_dashed)
                if showLabels and showSwing2 and showSweepsTf2
                    _txt = f_sweepPrefix() + tfSwingName2 + " SH SWEPT"
                    _lb = label.new(time, shP2, _txt, xloc=xloc.bar_time, style=label.style_label_down, color=f_sweepBg(color.fuchsia), textcolor=f_sweepTextColor(), size=f_labelSize(sweepLabelSizeInput))
                    f_pushAndTrimSweepLabel(sweepLabelsTf2, _lb, sweepLabelsModeTf2, sweepLabelsLatestTf2)
            else if not na(shL2)
                line.set_x2(shL2, time)

if showTf2OnChart and array.size(slPrices2) > 0
    for i = 0 to array.size(slPrices2) - 1
        slP2  = array.get(slPrices2, i)
        slSw2 = array.get(slSweptArr2, i)
        slL2  = array.get(slLines2, i)
        if not slSw2
            if low <= slP2
                array.set(slSweptArr2, i, true)
                mainSwingLowSweepNow2 := true
                if not na(slL2)
                    line.set_x2(slL2, time)
                    line.set_color(slL2, color.gray)
                    line.set_style(slL2, line.style_dashed)
                if showLabels and showSwing2 and showSweepsTf2
                    _txt = f_sweepPrefix() + tfSwingName2 + " SL SWEPT"
                    _lb = label.new(time, slP2, _txt, xloc=xloc.bar_time, style=label.style_label_up, color=f_sweepBg(color.teal), textcolor=f_sweepTextColor(), size=f_labelSize(sweepLabelSizeInput))
                    f_pushAndTrimSweepLabel(sweepLabelsTf2, _lb, sweepLabelsModeTf2, sweepLabelsLatestTf2)
            else if not na(slL2)
                line.set_x2(slL2, time)

mainSwingHigh2      = array.size(shPrices2) > 0 ? array.get(shPrices2, array.size(shPrices2) - 1) : na
mainSwingLow2       = array.size(slPrices2) > 0 ? array.get(slPrices2, array.size(slPrices2) - 1) : na
mainSwingHighSwept2 = array.size(shSweptArr2) > 0 ? array.get(shSweptArr2, array.size(shSweptArr2) - 1) : false
mainSwingLowSwept2  = array.size(slSweptArr2) > 0 ? array.get(slSweptArr2, array.size(slSweptArr2) - 1) : false

if showTf2OnChart and mainSwingHighSweepNow2
    alert(tfSwingName2 + " Swing High swept", alert.freq_once_per_bar)
if showTf2OnChart and mainSwingLowSweepNow2
    alert(tfSwingName2 + " Swing Low swept", alert.freq_once_per_bar)

f_pruneLevels(shPrices2, shTimes2, shLines2, shLabels2, shSweptArr2, openLevelsModeTf2, openLevelsLatestTf2, sweptLevelsModeTf2, sweptLevelsLatestTf2)
f_pruneLevels(slPrices2, slTimes2, slLines2, slLabels2, slSweptArr2, openLevelsModeTf2, openLevelsLatestTf2, sweptLevelsModeTf2, sweptLevelsLatestTf2)
if not showTf2OnChart
    f_clearLevels(shPrices2, shTimes2, shLines2, shLabels2, shSweptArr2)
    f_clearLevels(slPrices2, slTimes2, slLines2, slLabels2, slSweptArr2)
    f_clearLabelArray(sweepLabelsTf2)

// ─────────────────────────────────────
// Additional Swing HTF 3
// ─────────────────────────────────────
var array<float> shPrices3  = array.new_float()
var array<int>   shTimes3   = array.new_int()
var array<line>  shLines3   = array.new_line()
var array<label> shLabels3  = array.new_label()
var array<bool>  shSweptArr3 = array.new_bool()

var array<float> slPrices3  = array.new_float()
var array<int>   slTimes3   = array.new_int()
var array<line>  slLines3   = array.new_line()
var array<label> slLabels3  = array.new_label()
var array<bool>  slSweptArr3 = array.new_bool()

var int lastShTime3 = na
var int lastSlTime3 = na
var float prevMainSwingHighForKey3 = na
var float prevMainSwingLowForKey3 = na
var array<label> sweepLabelsTf3 = array.new_label()

newMainSwingHigh3 = not na(swingHigh3) and not na(swingHighTime3) and (na(lastShTime3) or swingHighTime3 != lastShTime3)
newMainSwingLow3  = not na(swingLow3) and not na(swingLowTime3) and (na(lastSlTime3) or swingLowTime3 != lastSlTime3)

if newMainSwingHigh3
    lastShTime3 := swingHighTime3
    keyTxtHigh3 = tfSwingName3 + " SH"
    prevMainSwingHighForKey3 := swingHigh3
    _existsHighAnyTf3 = f_levelExistsAtPrice(shPrices3, swingHigh3) or f_levelExistsAtPrice(shPrices, swingHigh3) or f_levelExistsAtPrice(shPrices2, swingHigh3)
    if not _existsHighAnyTf3 and showTf3OnChart
        shLn3 = (showLines and showSwing3) ? line.new(swingHighTime3, swingHigh3, time, swingHigh3, xloc=xloc.bar_time, extend=extend.none, color=color.purple, width=2) : na
        shLb3 = (showLabels and showSwing3) ? label.new(swingHighTime3, swingHigh3, keyTxtHigh3, xloc=xloc.bar_time, style=label.style_label_down, color=color.purple, textcolor=color.white) : na
        array.push(shPrices3, swingHigh3)
        array.push(shTimes3, swingHighTime3)
        array.push(shLines3, shLn3)
        array.push(shLabels3, shLb3)
        array.push(shSweptArr3, false)
        if array.size(shPrices3) > maxSwings
            oldLn3 = array.shift(shLines3)
            oldLb3 = array.shift(shLabels3)
            array.shift(shPrices3)
            array.shift(shTimes3)
            array.shift(shSweptArr3)
            if not na(oldLn3)
                line.delete(oldLn3)
            if not na(oldLb3)
                label.delete(oldLb3)

if newMainSwingLow3
    lastSlTime3 := swingLowTime3
    keyTxtLow3 = tfSwingName3 + " SL"
    prevMainSwingLowForKey3 := swingLow3
    _existsLowAnyTf3 = f_levelExistsAtPrice(slPrices3, swingLow3) or f_levelExistsAtPrice(slPrices, swingLow3) or f_levelExistsAtPrice(slPrices2, swingLow3)
    if not _existsLowAnyTf3 and showTf3OnChart
        slLn3 = (showLines and showSwing3) ? line.new(swingLowTime3, swingLow3, time, swingLow3, xloc=xloc.bar_time, extend=extend.none, color=color.navy, width=2) : na
        slLb3 = (showLabels and showSwing3) ? label.new(swingLowTime3, swingLow3, keyTxtLow3, xloc=xloc.bar_time, style=label.style_label_up, color=color.navy, textcolor=color.white) : na
        array.push(slPrices3, swingLow3)
        array.push(slTimes3, swingLowTime3)
        array.push(slLines3, slLn3)
        array.push(slLabels3, slLb3)
        array.push(slSweptArr3, false)
        if array.size(slPrices3) > maxSwings
            oldLnL3 = array.shift(slLines3)
            oldLbL3 = array.shift(slLabels3)
            array.shift(slPrices3)
            array.shift(slTimes3)
            array.shift(slSweptArr3)
            if not na(oldLnL3)
                line.delete(oldLnL3)
            if not na(oldLbL3)
                label.delete(oldLbL3)

mainSwingHighSweepNow3 = false
mainSwingLowSweepNow3  = false

if showTf3OnChart and array.size(shPrices3) > 0
    for i = 0 to array.size(shPrices3) - 1
        shP3  = array.get(shPrices3, i)
        shSw3 = array.get(shSweptArr3, i)
        shL3  = array.get(shLines3, i)
        if not shSw3
            if high >= shP3
                array.set(shSweptArr3, i, true)
                mainSwingHighSweepNow3 := true
                if not na(shL3)
                    line.set_x2(shL3, time)
                    line.set_color(shL3, color.gray)
                    line.set_style(shL3, line.style_dashed)
                if showLabels and showSwing3 and showSweepsTf3
                    _txt = f_sweepPrefix() + tfSwingName3 + " SH SWEPT"
                    _lb = label.new(time, shP3, _txt, xloc=xloc.bar_time, style=label.style_label_down, color=f_sweepBg(color.purple), textcolor=f_sweepTextColor(), size=f_labelSize(sweepLabelSizeInput))
                    f_pushAndTrimSweepLabel(sweepLabelsTf3, _lb, sweepLabelsModeTf3, sweepLabelsLatestTf3)
            else if not na(shL3)
                line.set_x2(shL3, time)

if showTf3OnChart and array.size(slPrices3) > 0
    for i = 0 to array.size(slPrices3) - 1
        slP3  = array.get(slPrices3, i)
        slSw3 = array.get(slSweptArr3, i)
        slL3  = array.get(slLines3, i)
        if not slSw3
            if low <= slP3
                array.set(slSweptArr3, i, true)
                mainSwingLowSweepNow3 := true
                if not na(slL3)
                    line.set_x2(slL3, time)
                    line.set_color(slL3, color.gray)
                    line.set_style(slL3, line.style_dashed)
                if showLabels and showSwing3 and showSweepsTf3
                    _txt = f_sweepPrefix() + tfSwingName3 + " SL SWEPT"
                    _lb = label.new(time, slP3, _txt, xloc=xloc.bar_time, style=label.style_label_up, color=f_sweepBg(color.navy), textcolor=f_sweepTextColor(), size=f_labelSize(sweepLabelSizeInput))
                    f_pushAndTrimSweepLabel(sweepLabelsTf3, _lb, sweepLabelsModeTf3, sweepLabelsLatestTf3)
            else if not na(slL3)
                line.set_x2(slL3, time)

mainSwingHigh3      = array.size(shPrices3) > 0 ? array.get(shPrices3, array.size(shPrices3) - 1) : na
mainSwingLow3       = array.size(slPrices3) > 0 ? array.get(slPrices3, array.size(slPrices3) - 1) : na
mainSwingHighSwept3 = array.size(shSweptArr3) > 0 ? array.get(shSweptArr3, array.size(shSweptArr3) - 1) : false
mainSwingLowSwept3  = array.size(slSweptArr3) > 0 ? array.get(slSweptArr3, array.size(slSweptArr3) - 1) : false

if showTf3OnChart and mainSwingHighSweepNow3
    alert(tfSwingName3 + " Swing High swept", alert.freq_once_per_bar)
if showTf3OnChart and mainSwingLowSweepNow3
    alert(tfSwingName3 + " Swing Low swept", alert.freq_once_per_bar)

f_pruneLevels(shPrices3, shTimes3, shLines3, shLabels3, shSweptArr3, openLevelsModeTf3, openLevelsLatestTf3, sweptLevelsModeTf3, sweptLevelsLatestTf3)
f_pruneLevels(slPrices3, slTimes3, slLines3, slLabels3, slSweptArr3, openLevelsModeTf3, openLevelsLatestTf3, sweptLevelsModeTf3, sweptLevelsLatestTf3)
if not showTf3OnChart
    f_clearLevels(shPrices3, shTimes3, shLines3, shLabels3, shSweptArr3)
    f_clearLevels(slPrices3, slTimes3, slLines3, slLabels3, slSweptArr3)
    f_clearLabelArray(sweepLabelsTf3)

// ─────────────────────────────────────
// Extend Lines
// ─────────────────────────────────────
if showLines
    if not pdhSwept
        f_extend(pdhLine)
    if not pdlSwept
        f_extend(pdlLine)
    if not asiaHighSwept
        f_extend(asiaHighLine)
    if not asiaLowSwept
        f_extend(asiaLowLine)
    if not londonHighSwept
        f_extend(londonHighLine)
    if not londonLowSwept
        f_extend(londonLowLine)

// ─────────────────────────────────────
// Sweep Logic: 1 Tick reicht, kein Close nötig
// ─────────────────────────────────────
pdhSweepNow = not pdhSwept and not na(pdh) and high >= pdh
pdlSweepNow = not pdlSwept and not na(pdl) and low <= pdl

asiaHighSweepNow = asiaLevelsFinalized and not asiaHighSwept and not inAsia and not na(asiaHigh) and high >= asiaHigh
asiaLowSweepNow  = asiaLevelsFinalized and not asiaLowSwept and not inAsia and not na(asiaLow) and low <= asiaLow

londonHighSweepNow = londonLevelsFinalized and not londonHighSwept and not inLondon and not na(londonHigh) and high >= londonHigh
londonLowSweepNow  = londonLevelsFinalized and not londonLowSwept and not inLondon and not na(londonLow) and low <= londonLow

if pdhSweepNow
    pdhSwept := true
    f_sweepLine(pdhLine)
    if showLabels
        _lb = label.new(time, pdh, "PDH SWEPT", xloc=xloc.bar_time, style=label.style_label_down, color=f_sessionSweepBg(color.red), textcolor=color.white, size=f_labelSize(sessionSweepLabelSizeInput))
        f_pushAndTrimSweepLabel(sessionSweepLabels, _lb, "Latest", sessionSweepLabelsLatest)
    alert("PDH swept: " + str.tostring(pdh), alert.freq_once_per_bar)

if pdlSweepNow
    pdlSwept := true
    f_sweepLine(pdlLine)
    if showLabels
        _lb = label.new(time, pdl, "PDL SWEPT", xloc=xloc.bar_time, style=label.style_label_up, color=f_sessionSweepBg(color.green), textcolor=color.white, size=f_labelSize(sessionSweepLabelSizeInput))
        f_pushAndTrimSweepLabel(sessionSweepLabels, _lb, "Latest", sessionSweepLabelsLatest)
    alert("PDL swept: " + str.tostring(pdl), alert.freq_once_per_bar)

if asiaHighSweepNow
    asiaHighSwept := true
    f_sweepLine(asiaHighLine)
    if showLabels
        _lb = label.new(time, asiaHigh, "ASIA HIGH SWEPT", xloc=xloc.bar_time, style=label.style_label_down, color=f_sessionSweepBg(color.red), textcolor=color.white, size=f_labelSize(sessionSweepLabelSizeInput))
        f_pushAndTrimSweepLabel(sessionSweepLabels, _lb, "Latest", sessionSweepLabelsLatest)
    alert("Asia High swept: " + str.tostring(asiaHigh), alert.freq_once_per_bar)

if asiaLowSweepNow
    asiaLowSwept := true
    f_sweepLine(asiaLowLine)
    if showLabels
        _lb = label.new(time, asiaLow, "ASIA LOW SWEPT", xloc=xloc.bar_time, style=label.style_label_up, color=f_sessionSweepBg(color.green), textcolor=color.white, size=f_labelSize(sessionSweepLabelSizeInput))
        f_pushAndTrimSweepLabel(sessionSweepLabels, _lb, "Latest", sessionSweepLabelsLatest)
    alert("Asia Low swept: " + str.tostring(asiaLow), alert.freq_once_per_bar)

if londonHighSweepNow
    londonHighSwept := true
    f_sweepLine(londonHighLine)
    if showLabels
        _lb = label.new(time, londonHigh, "LONDON HIGH SWEPT", xloc=xloc.bar_time, style=label.style_label_down, color=f_sessionSweepBg(color.red), textcolor=color.white, size=f_labelSize(sessionSweepLabelSizeInput))
        f_pushAndTrimSweepLabel(sessionSweepLabels, _lb, "Latest", sessionSweepLabelsLatest)
    alert("London High swept: " + str.tostring(londonHigh), alert.freq_once_per_bar)

if londonLowSweepNow
    londonLowSwept := true
    f_sweepLine(londonLowLine)
    if showLabels
        _lb = label.new(time, londonLow, "LONDON LOW SWEPT", xloc=xloc.bar_time, style=label.style_label_up, color=f_sessionSweepBg(color.green), textcolor=color.white, size=f_labelSize(sessionSweepLabelSizeInput))
        f_pushAndTrimSweepLabel(sessionSweepLabels, _lb, "Latest", sessionSweepLabelsLatest)
    alert("London Low swept: " + str.tostring(londonLow), alert.freq_once_per_bar)

// ─────────────────────────────────────
// Alert Conditions
// ─────────────────────────────────────
alertcondition(pdhSweepNow, "PDH Swept", "Previous Day High swept")
alertcondition(pdlSweepNow, "PDL Swept", "Previous Day Low swept")
alertcondition(asiaHighSweepNow, "Asia High Swept", "Asia High swept")
alertcondition(asiaLowSweepNow, "Asia Low Swept", "Asia Low swept")
alertcondition(londonHighSweepNow, "London High Swept", "London High swept")
alertcondition(londonLowSweepNow, "London Low Swept", "London Low swept")
alertcondition(showTf1OnChart and mainSwingHighSweepNow, "Main Swing 1 High Swept", "Main Swing 1 High swept")
alertcondition(showTf1OnChart and mainSwingLowSweepNow, "Main Swing 1 Low Swept", "Main Swing 1 Low swept")
alertcondition(showTf2OnChart and mainSwingHighSweepNow2, "Main Swing 2 High Swept", "Main Swing 2 High swept")
alertcondition(showTf2OnChart and mainSwingLowSweepNow2, "Main Swing 2 Low Swept", "Main Swing 2 Low swept")
alertcondition(showTf3OnChart and mainSwingHighSweepNow3, "Main Swing 3 High Swept", "Main Swing 3 High swept")
alertcondition(showTf3OnChart and mainSwingLowSweepNow3, "Main Swing 3 Low Swept", "Main Swing 3 Low swept")

// ─────────────────────────────────────
// Next Side Logic
// ─────────────────────────────────────
buySideOpen = not pdhSwept or not asiaHighSwept or not londonHighSwept or (showTf1OnChart and not mainSwingHighSwept) or (showTf2OnChart and not mainSwingHighSwept2) or (showTf3OnChart and not mainSwingHighSwept3)
sellSideOpen = not pdlSwept or not asiaLowSwept or not londonLowSwept or (showTf1OnChart and not mainSwingLowSwept) or (showTf2OnChart and not mainSwingLowSwept2) or (showTf3OnChart and not mainSwingLowSwept3)

lastBuySweep  = pdhSweepNow or asiaHighSweepNow or londonHighSweepNow or (showTf1OnChart and mainSwingHighSweepNow) or (showTf2OnChart and mainSwingHighSweepNow2) or (showTf3OnChart and mainSwingHighSweepNow3)
lastSellSweep = pdlSweepNow or asiaLowSweepNow or londonLowSweepNow or (showTf1OnChart and mainSwingLowSweepNow) or (showTf2OnChart and mainSwingLowSweepNow2) or (showTf3OnChart and mainSwingLowSweepNow3)

var string nextSide = "WAITING"

if lastSellSweep and buySideOpen
    nextSide := "BUY-SIDE LIQUIDITY"
if lastBuySweep and sellSideOpen
    nextSide := "SELL-SIDE LIQUIDITY"

// ─────────────────────────────────────
// Order Blocks
// ─────────────────────────────────────
var array<int> obStartBars = array.new_int()
var array<int> obEndBars = array.new_int()
var array<float> obTops = array.new_float()
var array<float> obBottoms = array.new_float()
var array<bool> obIsBull = array.new_bool()
var array<bool> obInvalid = array.new_bool()
var array<line> obTopLines = array.new_line()
var array<line> obBottomLines = array.new_line()

var array<int> obPendingBars = array.new_int()
var array<float> obPendingTops = array.new_float()
var array<float> obPendingBottoms = array.new_float()
var array<bool> obPendingIsBull = array.new_bool()

f_removeObAt(_idx) =>
    _lnTop = array.get(obTopLines, _idx)
    _lnBot = array.get(obBottomLines, _idx)
    if not na(_lnTop)
        line.delete(_lnTop)
    if not na(_lnBot)
        line.delete(_lnBot)
    array.remove(obStartBars, _idx)
    array.remove(obEndBars, _idx)
    array.remove(obTops, _idx)
    array.remove(obBottoms, _idx)
    array.remove(obIsBull, _idx)
    array.remove(obInvalid, _idx)
    array.remove(obTopLines, _idx)
    array.remove(obBottomLines, _idx)

f_addOb(_startBar, _top, _bottom, _isBull) =>
    _endBar = _startBar + obWidthBars - 1
    _col = _isBull ? color.blue : color.red
    _lnTop = line.new(_startBar, _top, _endBar, _top, xloc=xloc.bar_index, extend=extend.none, color=_col, width=2)
    _lnBot = line.new(_startBar, _bottom, _endBar, _bottom, xloc=xloc.bar_index, extend=extend.none, color=_col, width=2)
    array.push(obStartBars, _startBar)
    array.push(obEndBars, _endBar)
    array.push(obTops, _top)
    array.push(obBottoms, _bottom)
    array.push(obIsBull, _isBull)
    array.push(obInvalid, false)
    array.push(obTopLines, _lnTop)
    array.push(obBottomLines, _lnBot)

f_trimObs() =>
    while array.size(obStartBars) > maxHistoricalObs
        f_removeObAt(0)

if showOrderBlocks
    _signalAllowedNow = obSignalTiming == "Realtime" or barstate.isconfirmed
    _breakUp = obBreakBasis == "Close" ? close > high[1] : high > high[1]
    _breakDown = obBreakBasis == "Close" ? close < low[1] : low < low[1]
    _prevBear = close[1] < open[1]
    _prevBull = close[1] > open[1]

    _newBullCandidate = _signalAllowedNow and bar_index > 1 and _prevBear and _breakUp
    _newBearCandidate = _signalAllowedNow and bar_index > 1 and _prevBull and _breakDown

    if _newBullCandidate
        _top = f_obTop(true, open[1], high[1], low[1], close[1])
        _bot = f_obBottom(true, open[1], high[1], low[1], close[1])
        if obConfirmMode == "Direct"
            f_addOb(bar_index - 1, _top, _bot, true)
        else
            array.push(obPendingBars, bar_index - 1)
            array.push(obPendingTops, _top)
            array.push(obPendingBottoms, _bot)
            array.push(obPendingIsBull, true)

    if _newBearCandidate
        _top = f_obTop(false, open[1], high[1], low[1], close[1])
        _bot = f_obBottom(false, open[1], high[1], low[1], close[1])
        if obConfirmMode == "Direct"
            f_addOb(bar_index - 1, _top, _bot, false)
        else
            array.push(obPendingBars, bar_index - 1)
            array.push(obPendingTops, _top)
            array.push(obPendingBottoms, _bot)
            array.push(obPendingIsBull, false)

    if obConfirmMode == "FVG Confirmed"
        _bullFvgNow = bar_index > 2 and low > high[2]
        _bearFvgNow = bar_index > 2 and high < low[2]
        _pi = array.size(obPendingBars) - 1
        while _pi >= 0
            _pBar = array.get(obPendingBars, _pi)
            _pBull = array.get(obPendingIsBull, _pi)
            _confirm = _signalAllowedNow and bar_index > _pBar and ((_pBull and _bullFvgNow) or (not _pBull and _bearFvgNow))
            if _confirm
                f_addOb(_pBar, array.get(obPendingTops, _pi), array.get(obPendingBottoms, _pi), _pBull)
                array.remove(obPendingBars, _pi)
                array.remove(obPendingTops, _pi)
                array.remove(obPendingBottoms, _pi)
                array.remove(obPendingIsBull, _pi)
            _pi -= 1

    _oi = array.size(obStartBars) - 1
    while _oi >= 0
        _isBullOb = array.get(obIsBull, _oi)
        _top = array.get(obTops, _oi)
        _bot = array.get(obBottoms, _oi)
        _invalidNow = _isBullOb ? (obBreakBasis == "Close" ? close < _bot : low < _bot) : (obBreakBasis == "Close" ? close > _top : high > _top)
        if _invalidNow
            array.set(obInvalid, _oi, true)

        _lnTop = array.get(obTopLines, _oi)
        _lnBot = array.get(obBottomLines, _oi)
        _inv = array.get(obInvalid, _oi)
        if not na(_lnTop)
            line.set_style(_lnTop, _inv ? line.style_dashed : line.style_solid)
            line.set_color(_lnTop, _isBullOb ? color.blue : color.red)
        if not na(_lnBot)
            line.set_style(_lnBot, _inv ? line.style_dashed : line.style_solid)
            line.set_color(_lnBot, _isBullOb ? color.blue : color.red)

        if _inv and not showInvalidatedObs
            f_removeObAt(_oi)
        _oi -= 1

    f_trimObs()
else
    while array.size(obStartBars) > 0
        f_removeObAt(array.size(obStartBars) - 1)
    while array.size(obPendingBars) > 0
        array.pop(obPendingBars)
        array.pop(obPendingTops)
        array.pop(obPendingBottoms)
        array.pop(obPendingIsBull)

// ─────────────────────────────────────
// HTF Order Blocks (2 layers)
// ─────────────────────────────────────
var array<int> htf1StartTimes = array.new_int()
var array<int> htf1EndTimes = array.new_int()
var array<float> htf1Tops = array.new_float()
var array<float> htf1Bottoms = array.new_float()
var array<bool> htf1IsBull = array.new_bool()
var array<bool> htf1Invalid = array.new_bool()
var array<line> htf1TopLines = array.new_line()
var array<line> htf1BottomLines = array.new_line()
var array<label> htf1Tags = array.new_label()
var array<int> htf1PendingTimes = array.new_int()
var array<float> htf1PendingTops = array.new_float()
var array<float> htf1PendingBottoms = array.new_float()
var array<bool> htf1PendingIsBull = array.new_bool()
var int htf1LastBullSourceTime = na
var int htf1LastBearSourceTime = na

var array<int> htf2StartTimes = array.new_int()
var array<int> htf2EndTimes = array.new_int()
var array<float> htf2Tops = array.new_float()
var array<float> htf2Bottoms = array.new_float()
var array<bool> htf2IsBull = array.new_bool()
var array<bool> htf2Invalid = array.new_bool()
var array<line> htf2TopLines = array.new_line()
var array<line> htf2BottomLines = array.new_line()
var array<label> htf2Tags = array.new_label()
var array<int> htf2PendingTimes = array.new_int()
var array<float> htf2PendingTops = array.new_float()
var array<float> htf2PendingBottoms = array.new_float()
var array<bool> htf2PendingIsBull = array.new_bool()
var int htf2LastBullSourceTime = na
var int htf2LastBearSourceTime = na

f_htfRemoveAt(_startTimes, _endTimes, _tops, _bottoms, _isBull, _invalid, _topLines, _bottomLines, _tags, _idx) =>
    _lnTop = array.get(_topLines, _idx)
    _lnBot = array.get(_bottomLines, _idx)
    _tag = array.get(_tags, _idx)
    if not na(_lnTop)
        line.delete(_lnTop)
    if not na(_lnBot)
        line.delete(_lnBot)
    if not na(_tag)
        label.delete(_tag)
    array.remove(_startTimes, _idx)
    array.remove(_endTimes, _idx)
    array.remove(_tops, _idx)
    array.remove(_bottoms, _idx)
    array.remove(_isBull, _idx)
    array.remove(_invalid, _idx)
    array.remove(_topLines, _idx)
    array.remove(_bottomLines, _idx)
    array.remove(_tags, _idx)

f_htfAddOb(_tfText, _startTimes, _endTimes, _tops, _bottoms, _isBull, _invalid, _topLines, _bottomLines, _tags, _sourceTime, _top, _bottom, _bull, _barMs) =>
    _ms = _barMs
    _endTime = _sourceTime + (obWidthBars - 1) * _ms
    _col = _bull ? color.blue : color.red
    _lnTop = line.new(_sourceTime, _top, _endTime, _top, xloc=xloc.bar_time, extend=extend.none, color=_col, width=2)
    _lnBot = line.new(_sourceTime, _bottom, _endTime, _bottom, xloc=xloc.bar_time, extend=extend.none, color=_col, width=2)
    _txt = _tfText + " " + (_bull ? "BULL OB" : "BEAR OB")
    _tagY = _bull ? _top : _bottom
    _tagStyle = _bull ? label.style_label_down : label.style_label_up
    _tag = label.new(_endTime, _tagY, _txt, xloc=xloc.bar_time, style=_tagStyle, color=color.new(_col, 70), textcolor=color.white, size=size.tiny)
    array.push(_startTimes, _sourceTime)
    array.push(_endTimes, _endTime)
    array.push(_tops, _top)
    array.push(_bottoms, _bottom)
    array.push(_isBull, _bull)
    array.push(_invalid, false)
    array.push(_topLines, _lnTop)
    array.push(_bottomLines, _lnBot)
    array.push(_tags, _tag)

f_htfTrim(_startTimes, _endTimes, _tops, _bottoms, _isBull, _invalid, _topLines, _bottomLines, _tags) =>
    while array.size(_startTimes) > maxHistoricalObs
        f_htfRemoveAt(_startTimes, _endTimes, _tops, _bottoms, _isBull, _invalid, _topLines, _bottomLines, _tags, 0)

f_htfClearPending(_pTimes, _pTops, _pBottoms, _pIsBull) =>
    while array.size(_pTimes) > 0
        array.pop(_pTimes)
        array.pop(_pTops)
        array.pop(_pBottoms)
        array.pop(_pIsBull)

_signalAllowedNow = obSignalTiming == "Realtime" or barstate.isconfirmed

// HTF 1
[_h1o, _h1h, _h1l, _h1c, _h1t] = request.security(syminfo.tickerid, htfObTf1, [open, high, low, close, time], barmerge.gaps_off, barmerge.lookahead_off)
if showOrderBlocks and showHtfOb1 and f_showTfOnChart(htfObTf1)
    _h1BarMs = f_tfBarMs(htfObTf1)
    _h1TfText = f_tfLabel(htfObTf1)
    _h1BreakUp = obBreakBasis == "Close" ? _h1c > _h1h[1] : _h1h > _h1h[1]
    _h1BreakDown = obBreakBasis == "Close" ? _h1c < _h1l[1] : _h1l < _h1l[1]
    _h1PrevBear = _h1c[1] < _h1o[1]
    _h1PrevBull = _h1c[1] > _h1o[1]
    _h1SourceTime = _h1t[1]

    _h1NewBull = _signalAllowedNow and not na(_h1SourceTime) and _h1PrevBear and _h1BreakUp and (na(htf1LastBullSourceTime) or _h1SourceTime != htf1LastBullSourceTime)
    _h1NewBear = _signalAllowedNow and not na(_h1SourceTime) and _h1PrevBull and _h1BreakDown and (na(htf1LastBearSourceTime) or _h1SourceTime != htf1LastBearSourceTime)

    if _h1NewBull
        _top = f_obTop(true, _h1o[1], _h1h[1], _h1l[1], _h1c[1])
        _bot = f_obBottom(true, _h1o[1], _h1h[1], _h1l[1], _h1c[1])
        if obConfirmMode == "Direct"
            f_htfAddOb(_h1TfText, htf1StartTimes, htf1EndTimes, htf1Tops, htf1Bottoms, htf1IsBull, htf1Invalid, htf1TopLines, htf1BottomLines, htf1Tags, _h1SourceTime, _top, _bot, true, _h1BarMs)
        else
            array.push(htf1PendingTimes, _h1SourceTime)
            array.push(htf1PendingTops, _top)
            array.push(htf1PendingBottoms, _bot)
            array.push(htf1PendingIsBull, true)
        htf1LastBullSourceTime := _h1SourceTime

    if _h1NewBear
        _top = f_obTop(false, _h1o[1], _h1h[1], _h1l[1], _h1c[1])
        _bot = f_obBottom(false, _h1o[1], _h1h[1], _h1l[1], _h1c[1])
        if obConfirmMode == "Direct"
            f_htfAddOb(_h1TfText, htf1StartTimes, htf1EndTimes, htf1Tops, htf1Bottoms, htf1IsBull, htf1Invalid, htf1TopLines, htf1BottomLines, htf1Tags, _h1SourceTime, _top, _bot, false, _h1BarMs)
        else
            array.push(htf1PendingTimes, _h1SourceTime)
            array.push(htf1PendingTops, _top)
            array.push(htf1PendingBottoms, _bot)
            array.push(htf1PendingIsBull, false)
        htf1LastBearSourceTime := _h1SourceTime

    if obConfirmMode == "FVG Confirmed"
        _h1BullFvg = _h1l > _h1h[2]
        _h1BearFvg = _h1h < _h1l[2]
        _pi = array.size(htf1PendingTimes) - 1
        while _pi >= 0
            _pTime = array.get(htf1PendingTimes, _pi)
            _pBull = array.get(htf1PendingIsBull, _pi)
            _ok = _signalAllowedNow and _h1t > _pTime and ((_pBull and _h1BullFvg) or (not _pBull and _h1BearFvg))
            if _ok
                f_htfAddOb(_h1TfText, htf1StartTimes, htf1EndTimes, htf1Tops, htf1Bottoms, htf1IsBull, htf1Invalid, htf1TopLines, htf1BottomLines, htf1Tags, _pTime, array.get(htf1PendingTops, _pi), array.get(htf1PendingBottoms, _pi), _pBull, _h1BarMs)
                array.remove(htf1PendingTimes, _pi)
                array.remove(htf1PendingTops, _pi)
                array.remove(htf1PendingBottoms, _pi)
                array.remove(htf1PendingIsBull, _pi)
            _pi -= 1

    _oi = array.size(htf1StartTimes) - 1
    while _oi >= 0
        _bull = array.get(htf1IsBull, _oi)
        _top = array.get(htf1Tops, _oi)
        _bot = array.get(htf1Bottoms, _oi)
        _invNow = _bull ? (obBreakBasis == "Close" ? close < _bot : low < _bot) : (obBreakBasis == "Close" ? close > _top : high > _top)
        if _invNow
            array.set(htf1Invalid, _oi, true)
        _inv = array.get(htf1Invalid, _oi)
        _lnTop = array.get(htf1TopLines, _oi)
        _lnBot = array.get(htf1BottomLines, _oi)
        if not na(_lnTop)
            line.set_style(_lnTop, _inv ? line.style_dashed : line.style_solid)
        if not na(_lnBot)
            line.set_style(_lnBot, _inv ? line.style_dashed : line.style_solid)
        if _inv and not showInvalidatedObs
            f_htfRemoveAt(htf1StartTimes, htf1EndTimes, htf1Tops, htf1Bottoms, htf1IsBull, htf1Invalid, htf1TopLines, htf1BottomLines, htf1Tags, _oi)
        _oi -= 1

    f_htfTrim(htf1StartTimes, htf1EndTimes, htf1Tops, htf1Bottoms, htf1IsBull, htf1Invalid, htf1TopLines, htf1BottomLines, htf1Tags)
else
    while array.size(htf1StartTimes) > 0
        f_htfRemoveAt(htf1StartTimes, htf1EndTimes, htf1Tops, htf1Bottoms, htf1IsBull, htf1Invalid, htf1TopLines, htf1BottomLines, htf1Tags, array.size(htf1StartTimes) - 1)
    f_htfClearPending(htf1PendingTimes, htf1PendingTops, htf1PendingBottoms, htf1PendingIsBull)

// HTF 2
[_h2o, _h2h, _h2l, _h2c, _h2t] = request.security(syminfo.tickerid, htfObTf2, [open, high, low, close, time], barmerge.gaps_off, barmerge.lookahead_off)
if showOrderBlocks and showHtfOb2 and f_showTfOnChart(htfObTf2)
    _h2BarMs = f_tfBarMs(htfObTf2)
    _h2TfText = f_tfLabel(htfObTf2)
    _h2BreakUp = obBreakBasis == "Close" ? _h2c > _h2h[1] : _h2h > _h2h[1]
    _h2BreakDown = obBreakBasis == "Close" ? _h2c < _h2l[1] : _h2l < _h2l[1]
    _h2PrevBear = _h2c[1] < _h2o[1]
    _h2PrevBull = _h2c[1] > _h2o[1]
    _h2SourceTime = _h2t[1]

    _h2NewBull = _signalAllowedNow and not na(_h2SourceTime) and _h2PrevBear and _h2BreakUp and (na(htf2LastBullSourceTime) or _h2SourceTime != htf2LastBullSourceTime)
    _h2NewBear = _signalAllowedNow and not na(_h2SourceTime) and _h2PrevBull and _h2BreakDown and (na(htf2LastBearSourceTime) or _h2SourceTime != htf2LastBearSourceTime)

    if _h2NewBull
        _top = f_obTop(true, _h2o[1], _h2h[1], _h2l[1], _h2c[1])
        _bot = f_obBottom(true, _h2o[1], _h2h[1], _h2l[1], _h2c[1])
        if obConfirmMode == "Direct"
            f_htfAddOb(_h2TfText, htf2StartTimes, htf2EndTimes, htf2Tops, htf2Bottoms, htf2IsBull, htf2Invalid, htf2TopLines, htf2BottomLines, htf2Tags, _h2SourceTime, _top, _bot, true, _h2BarMs)
        else
            array.push(htf2PendingTimes, _h2SourceTime)
            array.push(htf2PendingTops, _top)
            array.push(htf2PendingBottoms, _bot)
            array.push(htf2PendingIsBull, true)
        htf2LastBullSourceTime := _h2SourceTime

    if _h2NewBear
        _top = f_obTop(false, _h2o[1], _h2h[1], _h2l[1], _h2c[1])
        _bot = f_obBottom(false, _h2o[1], _h2h[1], _h2l[1], _h2c[1])
        if obConfirmMode == "Direct"
            f_htfAddOb(_h2TfText, htf2StartTimes, htf2EndTimes, htf2Tops, htf2Bottoms, htf2IsBull, htf2Invalid, htf2TopLines, htf2BottomLines, htf2Tags, _h2SourceTime, _top, _bot, false, _h2BarMs)
        else
            array.push(htf2PendingTimes, _h2SourceTime)
            array.push(htf2PendingTops, _top)
            array.push(htf2PendingBottoms, _bot)
            array.push(htf2PendingIsBull, false)
        htf2LastBearSourceTime := _h2SourceTime

    if obConfirmMode == "FVG Confirmed"
        _h2BullFvg = _h2l > _h2h[2]
        _h2BearFvg = _h2h < _h2l[2]
        _pi2 = array.size(htf2PendingTimes) - 1
        while _pi2 >= 0
            _pTime2 = array.get(htf2PendingTimes, _pi2)
            _pBull2 = array.get(htf2PendingIsBull, _pi2)
            _ok2 = _signalAllowedNow and _h2t > _pTime2 and ((_pBull2 and _h2BullFvg) or (not _pBull2 and _h2BearFvg))
            if _ok2
                f_htfAddOb(_h2TfText, htf2StartTimes, htf2EndTimes, htf2Tops, htf2Bottoms, htf2IsBull, htf2Invalid, htf2TopLines, htf2BottomLines, htf2Tags, _pTime2, array.get(htf2PendingTops, _pi2), array.get(htf2PendingBottoms, _pi2), _pBull2, _h2BarMs)
                array.remove(htf2PendingTimes, _pi2)
                array.remove(htf2PendingTops, _pi2)
                array.remove(htf2PendingBottoms, _pi2)
                array.remove(htf2PendingIsBull, _pi2)
            _pi2 -= 1

    _oi2 = array.size(htf2StartTimes) - 1
    while _oi2 >= 0
        _bull2 = array.get(htf2IsBull, _oi2)
        _top2 = array.get(htf2Tops, _oi2)
        _bot2 = array.get(htf2Bottoms, _oi2)
        _invNow2 = _bull2 ? (obBreakBasis == "Close" ? close < _bot2 : low < _bot2) : (obBreakBasis == "Close" ? close > _top2 : high > _top2)
        if _invNow2
            array.set(htf2Invalid, _oi2, true)
        _inv2 = array.get(htf2Invalid, _oi2)
        _lnTop2 = array.get(htf2TopLines, _oi2)
        _lnBot2 = array.get(htf2BottomLines, _oi2)
        if not na(_lnTop2)
            line.set_style(_lnTop2, _inv2 ? line.style_dashed : line.style_solid)
        if not na(_lnBot2)
            line.set_style(_lnBot2, _inv2 ? line.style_dashed : line.style_solid)
        if _inv2 and not showInvalidatedObs
            f_htfRemoveAt(htf2StartTimes, htf2EndTimes, htf2Tops, htf2Bottoms, htf2IsBull, htf2Invalid, htf2TopLines, htf2BottomLines, htf2Tags, _oi2)
        _oi2 -= 1

    f_htfTrim(htf2StartTimes, htf2EndTimes, htf2Tops, htf2Bottoms, htf2IsBull, htf2Invalid, htf2TopLines, htf2BottomLines, htf2Tags)
else
    while array.size(htf2StartTimes) > 0
        f_htfRemoveAt(htf2StartTimes, htf2EndTimes, htf2Tops, htf2Bottoms, htf2IsBull, htf2Invalid, htf2TopLines, htf2BottomLines, htf2Tags, array.size(htf2StartTimes) - 1)
    f_htfClearPending(htf2PendingTimes, htf2PendingTops, htf2PendingBottoms, htf2PendingIsBull)

// ─────────────────────────────────────
// Dashboard
// ─────────────────────────────────────
var table dash = table.new(position.top_right, 3, 30, border_width=1)

if showDashboard and barstate.islast
    dashTxtSize = f_dashTextSize(dashTextSizeInput)

    for r = 0 to 29
        table.cell(dash, 0, r, "", text_color=color.white, bgcolor=color.new(color.black, 100), text_size=dashTxtSize)
        table.cell(dash, 1, r, "", text_color=color.white, bgcolor=color.new(color.black, 100), text_size=dashTxtSize)
        table.cell(dash, 2, r, "", text_color=color.white, bgcolor=color.new(color.black, 100), text_size=dashTxtSize)

    row = 0
    table.cell(dash, 0, row, "LEVEL", text_color=color.white, bgcolor=f_dashBg(color.black), text_size=dashTxtSize)
    table.cell(dash, 1, row, "STATUS", text_color=color.white, bgcolor=f_dashBg(color.black), text_size=dashTxtSize)
    table.cell(dash, 2, row, "PRICE", text_color=color.white, bgcolor=f_dashBg(color.black), text_size=dashTxtSize)
    row += 1

    if dashShowPdhPdl
        table.cell(dash, 0, row, "PDH", text_color=color.white, bgcolor=f_dashBg(color.black), text_size=dashTxtSize)
        table.cell(dash, 1, row, f_status(pdhSwept), text_color=color.white, bgcolor=f_dashBg(f_bg(pdhSwept)), text_size=dashTxtSize)
        table.cell(dash, 2, row, str.tostring(pdh), text_color=color.white, bgcolor=f_dashBg(color.black), text_size=dashTxtSize)
        row += 1

        table.cell(dash, 0, row, "PDL", text_color=color.white, bgcolor=f_dashBg(color.black), text_size=dashTxtSize)
        table.cell(dash, 1, row, f_status(pdlSwept), text_color=color.white, bgcolor=f_dashBg(f_bg(pdlSwept)), text_size=dashTxtSize)
        table.cell(dash, 2, row, str.tostring(pdl), text_color=color.white, bgcolor=f_dashBg(color.black), text_size=dashTxtSize)
        row += 1

    if dashShowAsia
        table.cell(dash, 0, row, "ASIA H", text_color=color.white, bgcolor=f_dashBg(color.black), text_size=dashTxtSize)
        table.cell(dash, 1, row, f_status(asiaHighSwept), text_color=color.white, bgcolor=f_dashBg(f_bg(asiaHighSwept)), text_size=dashTxtSize)
        table.cell(dash, 2, row, str.tostring(asiaHigh), text_color=color.white, bgcolor=f_dashBg(color.black), text_size=dashTxtSize)
        row += 1

        table.cell(dash, 0, row, "ASIA L", text_color=color.white, bgcolor=f_dashBg(color.black), text_size=dashTxtSize)
        table.cell(dash, 1, row, f_status(asiaLowSwept), text_color=color.white, bgcolor=f_dashBg(f_bg(asiaLowSwept)), text_size=dashTxtSize)
        table.cell(dash, 2, row, str.tostring(asiaLow), text_color=color.white, bgcolor=f_dashBg(color.black), text_size=dashTxtSize)
        row += 1

    if dashShowLondon
        table.cell(dash, 0, row, "LON H", text_color=color.white, bgcolor=f_dashBg(color.black), text_size=dashTxtSize)
        table.cell(dash, 1, row, f_status(londonHighSwept), text_color=color.white, bgcolor=f_dashBg(f_bg(londonHighSwept)), text_size=dashTxtSize)
        table.cell(dash, 2, row, str.tostring(londonHigh), text_color=color.white, bgcolor=f_dashBg(color.black), text_size=dashTxtSize)
        row += 1

        table.cell(dash, 0, row, "LON L", text_color=color.white, bgcolor=f_dashBg(color.black), text_size=dashTxtSize)
        table.cell(dash, 1, row, f_status(londonLowSwept), text_color=color.white, bgcolor=f_dashBg(f_bg(londonLowSwept)), text_size=dashTxtSize)
        table.cell(dash, 2, row, str.tostring(londonLow), text_color=color.white, bgcolor=f_dashBg(color.black), text_size=dashTxtSize)
        row += 1

    if dashShowTf1
        table.cell(dash, 0, row, tfSwingName + " High", text_color=color.white, bgcolor=f_dashBg(color.black), text_size=dashTxtSize)
        table.cell(dash, 1, row, f_status(mainSwingHighSwept), text_color=color.white, bgcolor=f_dashBg(f_bg(mainSwingHighSwept)), text_size=dashTxtSize)
        table.cell(dash, 2, row, str.tostring(mainSwingHigh), text_color=color.white, bgcolor=f_dashBg(color.black), text_size=dashTxtSize)
        row += 1

        table.cell(dash, 0, row, tfSwingName + " Low", text_color=color.white, bgcolor=f_dashBg(color.black), text_size=dashTxtSize)
        table.cell(dash, 1, row, f_status(mainSwingLowSwept), text_color=color.white, bgcolor=f_dashBg(f_bg(mainSwingLowSwept)), text_size=dashTxtSize)
        table.cell(dash, 2, row, str.tostring(mainSwingLow), text_color=color.white, bgcolor=f_dashBg(color.black), text_size=dashTxtSize)
        row += 1

    if dashShowTf2
        table.cell(dash, 0, row, tfSwingName2 + " High", text_color=color.white, bgcolor=f_dashBg(color.black), text_size=dashTxtSize)
        table.cell(dash, 1, row, showSwing2 ? f_status(mainSwingHighSwept2) : "OFF", text_color=color.white, bgcolor=f_dashBg(showSwing2 ? f_bg(mainSwingHighSwept2) : color.gray), text_size=dashTxtSize)
        table.cell(dash, 2, row, showSwing2 ? str.tostring(mainSwingHigh2) : "-", text_color=color.white, bgcolor=f_dashBg(color.black), text_size=dashTxtSize)
        row += 1

        table.cell(dash, 0, row, tfSwingName2 + " Low", text_color=color.white, bgcolor=f_dashBg(color.black), text_size=dashTxtSize)
        table.cell(dash, 1, row, showSwing2 ? f_status(mainSwingLowSwept2) : "OFF", text_color=color.white, bgcolor=f_dashBg(showSwing2 ? f_bg(mainSwingLowSwept2) : color.gray), text_size=dashTxtSize)
        table.cell(dash, 2, row, showSwing2 ? str.tostring(mainSwingLow2) : "-", text_color=color.white, bgcolor=f_dashBg(color.black), text_size=dashTxtSize)
        row += 1

    if dashShowTf3
        table.cell(dash, 0, row, tfSwingName3 + " High", text_color=color.white, bgcolor=f_dashBg(color.black), text_size=dashTxtSize)
        table.cell(dash, 1, row, showSwing3 ? f_status(mainSwingHighSwept3) : "OFF", text_color=color.white, bgcolor=f_dashBg(showSwing3 ? f_bg(mainSwingHighSwept3) : color.gray), text_size=dashTxtSize)
        table.cell(dash, 2, row, showSwing3 ? str.tostring(mainSwingHigh3) : "-", text_color=color.white, bgcolor=f_dashBg(color.black), text_size=dashTxtSize)
        row += 1

        table.cell(dash, 0, row, tfSwingName3 + " Low", text_color=color.white, bgcolor=f_dashBg(color.black), text_size=dashTxtSize)
        table.cell(dash, 1, row, showSwing3 ? f_status(mainSwingLowSwept3) : "OFF", text_color=color.white, bgcolor=f_dashBg(showSwing3 ? f_bg(mainSwingLowSwept3) : color.gray), text_size=dashTxtSize)
        table.cell(dash, 2, row, showSwing3 ? str.tostring(mainSwingLow3) : "-", text_color=color.white, bgcolor=f_dashBg(color.black), text_size=dashTxtSize)
        row += 1

    if dashShowNext
        table.cell(dash, 0, row, "NEXT", text_color=color.white, bgcolor=f_dashBg(color.black), text_size=dashTxtSize)
        table.cell(dash, 1, row, nextSide, text_color=color.white, bgcolor=f_dashBg(color.blue), text_size=dashTxtSize)
        table.cell(dash, 2, row, "", text_color=color.white, bgcolor=f_dashBg(color.blue), text_size=dashTxtSize)
````
