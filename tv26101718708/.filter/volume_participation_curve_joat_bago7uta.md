# Volume Participation Curve [JOAT]

- url: https://www.tradingview.com/script/baGo7UTA-Volume-Participation-Curve-JOAT/
- type: indicator
- pine_id: PUB;212328992eee438283544fb36b2bc3a5
- version: 1.0

## Description

[b]Volume Participation Curve [JOAT][/b]

[b]Introduction[/b]

VPC Volume Participation Curve is an open-source volume seasonality indicator that compares current volume against historical participation for the same time bucket. It helps answer a simple but important question: is current activity meaningful compared with what usually happens at this time?

Instead of treating all volume bars equally, VPC builds recurring buckets by minute, hour, day, or month, then compares live volume against the expected bucket value. It also tracks session pace so traders can see whether the session is leading or lagging expected participation.

[image]https://www.tradingview.com/x/jUF2rXJ8/[/image]

[b]Core Concepts[/b]

[b]1. Time-Bucketed Expected Volume[/b]
The indicator builds historical volume samples by time bucket. Auto mode chooses practical buckets based on the chart timeframe.

[b]2. Median or Mean Summary[/b]
Expected volume can be calculated by median or mean. Median is the default because it is more robust against abnormal spikes.

[b]3. Participation Ratio[/b]
The main curve is current smoothed volume divided by expected volume. A value above 1.0 means current activity is above expectation.

[b]4. Session Pace[/b]
Session cumulative volume is compared with cumulative expected volume to determine whether the whole session is leading or lagging.

[b]5. Regime Bands[/b]
Expansion and compression thresholds are shown as clean bands around the 1.0 baseline.

[b]Features[/b]

[list]
[*][b]Expected volume engine:[/b] Learns recurring volume behavior from historical buckets
[*][b]Participation curve:[/b] Displays current volume relative to expected activity
[*][b]Session pace curve:[/b] Shows whether cumulative session activity is ahead or behind
[*][b]Expansion and compression bands:[/b] Identifies above-expected or below-expected participation
[*][b]Dark-mode fills:[/b] Uses restrained green/red/neutral blends
[*][b]Top-right dashboard:[/b] Shows bucket, participation, pace, surprise, growth, state, and sample count
[*][b]Confirmed alerts:[/b] Includes expansion, compression, pace lead, and pace lag alerts
[/list]

[b]Input Parameters[/b]

[b]Seasonality:[/b]
[list]
[*]Historical Samples per Bucket
[*]Bucket Mode: Auto, Minute, Hour, Day, or Month
[*]Expected Value: Median or Mean
[/list]

[b]Curve:[/b]
[list]
[*]Volume Smoothing
[*]Session Pace Window
[/list]

[b]Visual:[/b]
[list]
[*]Show Regime Bands
[*]Show Pace Curve
[*]Color Background
[/list]

[b]How to Use[/b]

[b]Step 1:[/b] Read the participation curve relative to the 1.0 baseline.

[b]Step 2:[/b] Treat readings above 1.2 as expansion context and readings below 0.8 as compression context.

[b]Step 3:[/b] Confirm whether session pace agrees with the current bar's participation.

[b]Step 4:[/b] Use the output as a participation filter for breakout, continuation, or reversal tools.

[b]Limitations[/b]

[list]
[*]New symbols or sparse histories may need time to build useful bucket samples
[*]Unusual news or event-driven sessions can distort expected-volume comparisons
[*]Volume reporting differs by asset class and exchange
[*]This indicator does not predict direction; it measures participation context
[/list]

[b]Originality Statement[/b]

VPC is an original JOAT volume model combining time-bucketed expected volume, session pace, expansion/compression bands, and confirmed alerts in a Pine Script v6 pane indicator.

[b]Disclaimer[/b]

This script is for educational and informational purposes only. It is not financial advice and does not guarantee future results. Trading involves risk, and users should apply their own risk management.

Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Volume Participation Curve [JOAT]", "VPC [JOAT]", overlay=false, max_lines_count=50, max_labels_count=20, max_bars_back=5000)

//------------------------------------------------------------------------------//
// Volume Participation Curve
// Compares live volume against time-of-day expectations and session pace using
// only confirmed bars for persistent learning and signal states.
//------------------------------------------------------------------------------//

// ---------- Inputs
vpcGroupSeason = "Seasonality"
vpcGroupCurve  = "Curve"
vpcGroupVisual = "Visual"
vpcGroupDash   = "Dashboard"

historyLen  = input.int(120, "Historical Samples per Bucket", minval=20, maxval=500, group=vpcGroupSeason)
bucketMode  = input.string("Auto", "Bucket Mode", options=["Auto", "Minute", "Hour", "Day", "Month"], group=vpcGroupSeason)
summaryMode = input.string("Median", "Expected Value", options=["Median", "Mean"], group=vpcGroupSeason)
smoothLen   = input.int(5, "Volume Smoothing", minval=1, maxval=50, group=vpcGroupCurve)
paceLen     = input.int(12, "Session Pace Window", minval=2, maxval=100, group=vpcGroupCurve)
showDash    = input.bool(true, "Show Dashboard", group=vpcGroupDash)
paceSmoothLen = math.max(2, int(math.round(paceLen * 0.5)))

showBands   = input.bool(true, "Show Regime Bands", group=vpcGroupVisual)
showPace    = input.bool(true, "Show Pace Curve", group=vpcGroupVisual)
showColorBg = input.bool(true, "Color Background", group=vpcGroupVisual)

// ---------- Palette
colBull  = color.rgb(8, 153, 129)
colBear  = color.rgb(242, 54, 69)
colGold  = color.rgb(245, 173, 66)
colNeut  = color.rgb(143, 155, 179)
colDeep  = color.rgb(12, 16, 22)
colMid   = color.rgb(22, 28, 36)
colText  = color.rgb(226, 234, 243)
colGrid  = color.rgb(51, 61, 77)

// ---------- Data model
// Pine maps are safest when arrays are wrapped in a user-defined type.
type bucketVector
    array<float> values

// ---------- Helpers
f_bucketFormat(_mode) =>
    switch _mode
        "Minute" => "HH:mm"
        "Hour"   => "yyyy-MM-dd HH"
        "Day"    => "yyyy-MM-dd"
        "Month"  => "yyyy-MM"
        => timeframe.isintraday ? (timeframe.multiplier <= 15 ? "HH:mm" : "yyyy-MM-dd HH") : timeframe.isdaily ? "yyyy-MM-dd" : "yyyy-MM"

f_autoMode() =>
    timeframe.isintraday ? (timeframe.multiplier <= 30 ? "Minute" : "Hour") : timeframe.isdaily ? "Day" : "Month"

f_key() =>
    fmt = bucketMode == "Auto" ? f_bucketFormat(f_autoMode()) : f_bucketFormat(bucketMode)
    str.format_time(time, fmt)

f_mean(_arr) =>
    float out = na
    if array.size(_arr) > 0
        float total = 0.0
        for i = 0 to array.size(_arr) - 1
            total += array.get(_arr, i)
        out := total / array.size(_arr)
    out

f_median(_arr) =>
    float out = na
    sz = array.size(_arr)
    if sz > 0
        tmp = array.copy(_arr)
        array.sort(tmp, order.ascending)
        mid = math.floor((sz - 1) / 2)
        out := sz % 2 == 1 ? array.get(tmp, mid) : (array.get(tmp, mid) + array.get(tmp, mid + 1)) / 2.0
    out

f_expected(_arr) =>
    summaryMode == "Mean" ? f_mean(_arr) : f_median(_arr)

f_bucketColor(_ratio) =>
    _ratio >= 1.2 ? colBull : _ratio <= 0.8 ? colBear : colNeut

// ---------- Historical state
var map<string, bucketVector> bucketStore = map.new<string, bucketVector>()
var array<float> sessionActual = array.new_float()
var array<float> sessionExpected = array.new_float()
var float sessionActualCum = 0.0
var float sessionExpectedCum = 0.0
var float sessionBase = na
var float priorSessionVolume = na
var int   sessionBars = 0
var string lastKey = ""

inSession = true
dayStart = na(time("D")[1]) or time("D") != time("D")[1]
sessionStart = dayStart
confirmedBar = barstate.isconfirmed

// ---------- Learning loop on confirmed bars
bucketKey = f_key()
bucketObj = map.contains(bucketStore, bucketKey) ? map.get(bucketStore, bucketKey) : bucketVector.new(array.new_float())
bucketArr = bucketObj.values
bucketExp = f_expected(bucketArr)
smoothedVolume = ta.ema(volume, smoothLen)
bucketExpected = na(bucketExp) ? smoothedVolume : bucketExp

if confirmedBar
    if sessionStart
        if not barstate.isfirst
            priorSessionVolume := sessionActualCum
        sessionActualCum := 0.0
        sessionExpectedCum := 0.0
        sessionBars := 0
        sessionBase := smoothedVolume
        sessionActual := array.new_float()
        sessionExpected := array.new_float()

    if inSession
        sessionBars += 1
        sessionActualCum += volume
        sessionExpectedCum += math.max(bucketExpected, syminfo.mintick)

        if not na(bucketExpected)
            if array.size(sessionExpected) >= historyLen
                array.shift(sessionExpected)
            array.push(sessionExpected, bucketExpected)

        if array.size(sessionActual) >= historyLen
            array.shift(sessionActual)
        array.push(sessionActual, volume)

        if not map.contains(bucketStore, bucketKey)
            map.put(bucketStore, bucketKey, bucketVector.new(array.new_float()))
        liveObj = map.get(bucketStore, bucketKey)
        liveArr = liveObj.values
        if array.size(liveArr) >= historyLen
            array.shift(liveArr)
        array.push(liveArr, volume)
        map.put(bucketStore, bucketKey, liveObj)
// ---------- Participation metrics
expectedNow = math.max(bucketExpected, syminfo.mintick)
participationRatio = volume / expectedNow
participationCurve = ta.ema(participationRatio, smoothLen)
paceRatio = sessionExpectedCum > 0 ? sessionActualCum / sessionExpectedCum : na
paceCurve = ta.ema(paceRatio, paceSmoothLen)
relativeSurprise = participationRatio - 1.0
sessionGrowth = sessionActualCum / math.max(1.0, nz(priorSessionVolume, sessionActualCum))

expansionState = confirmedBar and participationRatio >= 1.2
compressionState = confirmedBar and participationRatio <= 0.8
paceLead = confirmedBar and not na(paceRatio) and paceRatio > 1.05 and participationRatio > 1.0
paceLag = confirmedBar and not na(paceRatio) and paceRatio < 0.95 and participationRatio < 1.0

curveColor = f_bucketColor(participationCurve)
paceColor = paceRatio >= 1.0 ? color.new(colBull, 0) : color.new(colBear, 0)

// ---------- Core plots
baseline = plot(1.0, "Baseline", color=color.new(colNeut, 70), linewidth=1, style=plot.style_line)
curvePlot = plot(participationCurve, "Participation", color=color.new(curveColor, 0), linewidth=2)
pacePlot = plot(showPace ? paceCurve : na, "Pace", color=color.new(paceColor, 0), linewidth=2, style=plot.style_line)
upperBand = plot(showBands ? 1.2 : na, "Expansion Band", color=color.new(colBull, 82), linewidth=1, style=plot.style_line)
lowerBand = plot(showBands ? 0.8 : na, "Compression Band", color=color.new(colBear, 82), linewidth=1, style=plot.style_line)

fill(curvePlot, baseline, color=color.new(curveColor, 86), title="Participation Fill")
fill(upperBand, baseline, color=color.new(colBull, 92), title="Expansion Fill")
fill(baseline, lowerBand, color=color.new(colBear, 92), title="Compression Fill")

bgcolor(showColorBg ? (expansionState ? color.new(colBull, 92) : compressionState ? color.new(colBear, 92) : na) : na)

// ---------- Confirmed regime events
plotchar(expansionState, title="Expansion", char=" ", location=location.top, display=display.none)
plotchar(compressionState, title="Compression", char=" ", location=location.bottom, display=display.none)
plotchar(paceLead, title="Pace Lead", char=" ", location=location.top, display=display.none)
plotchar(paceLag, title="Pace Lag", char=" ", location=location.bottom, display=display.none)

alertcondition(expansionState, "VPC Volume Expansion", "VPC confirmed above-expected volume participation on a closed bar.")
alertcondition(compressionState, "VPC Volume Compression", "VPC confirmed below-expected volume participation on a closed bar.")
alertcondition(paceLead, "VPC Session Pace Lead", "VPC confirmed session volume pace is leading expected participation.")
alertcondition(paceLag, "VPC Session Pace Lag", "VPC confirmed session volume pace is lagging expected participation.")

// ---------- Dashboard
var table dash = table.new(position.top_right, 2, 7, bgcolor=color.new(colDeep, 12), frame_color=color.new(colGrid, 35), border_color=color.new(colGrid, 35), frame_width=1)

f_row(_row, _title, _value, _bg) =>
    table.cell(dash, 0, _row, _title, text_color=color.new(colText, 0), bgcolor=_bg, text_size=size.normal)
    table.cell(dash, 1, _row, _value, text_color=color.new(colText, 0), bgcolor=_bg, text_size=size.normal)

if barstate.islast and showDash
    table.clear(dash, 0, 0, 1, 6)
    f_row(0, "Bucket", bucketKey, color.new(colMid, 0))
    f_row(1, "Participation", str.tostring(participationCurve, "#.00") + "x", color.new(curveColor, 80))
    f_row(2, "Pace", na(paceRatio) ? "n/a" : str.tostring(paceCurve, "#.00") + "x", color.new(paceColor, 82))
    f_row(3, "Surprise", str.tostring(relativeSurprise * 100.0, "#.0") + "%", color.new(colMid, 0))
    f_row(4, "Session Growth", str.tostring(sessionGrowth * 100.0, "#.0") + "%", color.new(colMid, 0))
    f_row(5, "State", expansionState ? "Expansion" : compressionState ? "Compression" : "Balanced", color.new(curveColor, 82))
    f_row(6, "Samples", str.tostring(array.size(bucketArr)), color.new(colMid, 0))
else if barstate.islast and not showDash
    table.clear(dash, 0, 0, 1, 6)
````
