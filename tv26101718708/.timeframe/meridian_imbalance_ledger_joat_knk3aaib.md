# Meridian Imbalance Ledger [JOAT]

- url: https://www.tradingview.com/script/KnK3AaIb-Meridian-Imbalance-Ledger-JOAT/
- type: indicator
- pine_id: PUB;86318f7f4f18436cb5efee364a7e8559
- version: 1.0

## Description

[b]Meridian Imbalance Ledger [JOAT][/b]

[b]Introduction[/b]

Meridian Imbalance Ledger is an open-source imbalance mapping tool that tracks confirmed chart-timeframe, higher-timeframe, and micro-structure fair value gaps inside one coordinated framework. The script is designed to answer three practical questions: where imbalance was created, whether that imbalance is still active, and how price is behaving when it returns to those zones.

The indicator solves a context problem. Many imbalance tools only mark a gap once and leave the trader to manually judge whether it remains relevant. Meridian instead maintains a living ledger of active zones, inversion status, fill progress, age, and structural pressure so the chart shows which imbalances still matter and which ones have been consumed.

[image]https://www.tradingview.com/x/rXYBUG0f/[/image]

[b]Core Concepts[/b]

[b]1. Multi-source imbalance detection[/b]

Meridian separates imbalance generation into three sources:
[list]
[*]Chart timeframe imbalances
[*]Higher-timeframe imbalances requested with non-repainting offset logic
[*]Optional micro-structure imbalance scans from lower-timeframe data
[/list]

This allows a trader to see whether current price is interacting with local inefficiency, inherited higher-timeframe inefficiency, or smaller sub-bar displacement inside the current bar structure.

[b]2. Fill progress and retirement logic[/b]

Each zone remains active until its fill rule is satisfied. The script supports configurable retirement behavior so zones can be treated as mitigated on a simple touch, midpoint interaction, or deeper body-based invalidation depending on the chosen rule set.

[b]3. Inversion tracking[/b]

If price meaningfully breaches an imbalance, the zone can be treated as structurally altered rather than simply forgotten. Meridian keeps inversion state so prior bullish inefficiency can become resistance context and prior bearish inefficiency can become support context.

[b]4. Age and pressure weighting[/b]

Not all zones deserve equal weight. Meridian tracks zone age and active count to create a pressure ratio that helps communicate whether bullish or bearish imbalance structure is dominating the chart right now.

[b]Features[/b]

[list]
[*][b]Chart, HTF, and micro imbalance layers:[/b] Multiple imbalance sources displayed in one coordinated ledger
[*][b]Non-repainting HTF requests:[/b] Higher-timeframe data requested using historical offsets for safer confirmed context
[*][b]Fill-progress tracking:[/b] Zones remain active until their configured retirement condition is met
[*][b]Inversion state handling:[/b] Breached imbalances can remain visible as flipped structural context
[*][b]Age-aware zone fading:[/b] Older zones visually decay to reduce clutter while retaining context
[*][b]Pressure ratio and active counts:[/b] Quick read on whether bullish or bearish imbalance pressure is leading
[*][b]Compact top-right dashboard:[/b] Displays counts, inversion totals, micro scan status, and bias ratio
[*][b]Confirmed-bar alerts:[/b] New imbalance, inversion, and state transitions only trigger on confirmed bars
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1:[/b] Identify whether current price is trading inside fresh chart-timeframe imbalance or approaching older inherited imbalance from a higher timeframe.

[b]Step 2:[/b] Use the dashboard counts and bias ratio to judge whether current imbalance structure is skewed toward support or resistance.

[b]Step 3:[/b] Monitor inversion states. A previously bullish zone that has failed cleanly may become useful resistance context on retests.

[b]Step 4:[/b] Treat micro imbalance scans as execution detail, not a standalone trend signal. The broader chart and HTF layers should carry more decision weight.

[b]Limitations[/b]

[list]
[*]Micro-structure scans depend on lower-timeframe availability and plan limits
[*]HTF imbalances are intentionally delayed by one completed HTF bar to reduce repaint risk
[*]An imbalance zone is contextual, not a guarantee of reversal or continuation
[/list]

[b]Originality Statement[/b]

Meridian Imbalance Ledger is original in the way it combines confirmed chart imbalances, non-repainting higher-timeframe imbalance inheritance, optional micro scans, and zone lifecycle management into one stateful framework. The script is intended as a structured market context layer, not a one-click entry signal.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It does not provide financial advice or trade recommendations. Imbalance reactions can fail, invert, or be ignored entirely by the market. Always use independent confirmation and risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Meridian Imbalance Ledger [JOAT]", overlay = true, max_boxes_count = 400, max_lines_count = 400, max_labels_count = 300, calc_bars_count = 4000)
//------------------------------------------------------------------------------
// Input groups
//------------------------------------------------------------------------------
string groupDetection = "Detection"
string groupMtf = "MTF"
string groupLifecycle = "Lifecycle"
string groupStyle = "Style"
string groupDashboard = "Dashboard"
string groupAlerts = "Alerts"

// Detection
bool showChart = input.bool(true, "Chart Imbalances", group = groupDetection)
bool showHtf = input.bool(true, "HTF Imbalances", group = groupDetection)
bool showMicro = input.bool(true, "Micro Imbalances", group = groupDetection)
float minWidthAtr = input.float(0.20, "Minimum Width in ATR", minval = 0.0, step = 0.05, group = groupDetection)
float displacementFactor = input.float(0.15, "Impulse Confirmation ATR", minval = 0.0, step = 0.05, group = groupDetection)
string fillRule = input.string("Midpoint Reached", "Retirement Rule", options = ["Any Touch", "Midpoint Reached", "Body Beyond"], group = groupDetection)

// MTF
string htfInput = input.timeframe("240", "Higher Timeframe", group = groupMtf)
string microTfInput = input.timeframe("5", "Micro Timeframe", group = groupMtf)
int microThreshold = input.int(3, "Minimum Micro Imbalances", minval = 1, maxval = 20, group = groupMtf)
float microWidthAtr = input.float(0.05, "Micro Minimum Width in ATR", minval = 0.0, step = 0.01, group = groupMtf)

// Lifecycle
bool rejectOverlap = input.bool(true, "Reject Overlapping New Zones", group = groupLifecycle)
bool allowInversion = input.bool(true, "Allow Inversion Tracking", group = groupLifecycle)
int keepBars = input.int(260, "Maximum Active Lifetime", minval = 20, maxval = 2000, group = groupLifecycle)
int maxZonesPerSide = input.int(18, "Maximum Zones Per Side", minval = 2, maxval = 50, group = groupLifecycle)
int staleFadeStart = input.int(90, "Fade Start Bars", minval = 10, maxval = 500, group = groupLifecycle)

// Style
color bullChartCol = input.color(color.rgb(28, 201, 175), "Chart Bull", group = groupStyle, inline = "c1")
color bearChartCol = input.color(color.rgb(255, 126, 98), "", group = groupStyle, inline = "c1")
color bullHtfCol = input.color(color.rgb(86, 125, 255), "HTF Bull", group = groupStyle, inline = "c2")
color bearHtfCol = input.color(color.rgb(245, 97, 161), "", group = groupStyle, inline = "c2")
color bullMicroCol = input.color(color.rgb(239, 188, 86), "Micro Bull", group = groupStyle, inline = "c3")
color bearMicroCol = input.color(color.rgb(188, 134, 255), "", group = groupStyle, inline = "c3")
color invertCol = input.color(color.rgb(239, 203, 95), "Inversion Border", group = groupStyle)
color neutralCol = input.color(color.rgb(116, 128, 156), "Neutral Accent", group = groupStyle)
int fillOpacity = input.int(84, "Zone Transparency", minval = 10, maxval = 95, group = groupStyle)
int lineOpacity = input.int(32, "Midline Transparency", minval = 0, maxval = 95, group = groupStyle)
bool showMidlines = input.bool(true, "Show Midlines", group = groupStyle)
bool showLabels = input.bool(true, "Show Labels", group = groupStyle)
bool showCandles = input.bool(true, "Color Candles by Active Bias", group = groupStyle)
bool showBackdrop = input.bool(true, "Show Background Bias Tint", group = groupStyle)

// Dashboard
bool showDashboard = input.bool(true, "Show Dashboard", group = groupDashboard)
string dashSize = input.string("Normal", "Dashboard Size", options = ["Small", "Normal", "Large"], group = groupDashboard)
bool showDistanceMetrics = input.bool(true, "Show Distance Metrics", group = groupDashboard)

// Alerts
bool enableAlerts = input.bool(true, "Enable Alerts", group = groupAlerts)

//------------------------------------------------------------------------------
// Helper functions
//------------------------------------------------------------------------------
f_clamp(float value, float lo, float hi) =>
    math.min(math.max(value, lo), hi)

f_mid(float top, float bottom) =>
    math.avg(top, bottom)

f_size(string sizeName) =>
    switch sizeName
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_origin_color(string origin, int direction) =>
    if origin == "HTF"
        direction == 1 ? bullHtfCol : bearHtfCol
    else if origin == "Micro"
        direction == 1 ? bullMicroCol : bearMicroCol
    else
        direction == 1 ? bullChartCol : bearChartCol

f_fill_ratio(int direction, float top, float bottom) =>
    float zoneHeight = math.max(top - bottom, syminfo.mintick)
    direction == 1 ? f_clamp((top - low) / zoneHeight, 0.0, 1.25) : f_clamp((high - bottom) / zoneHeight, 0.0, 1.25)

f_should_retire(int direction, float top, float bottom, string rule) =>
    float mid = f_mid(top, bottom)
    direction == 1 ? (rule == "Any Touch" ? low <= top : rule == "Body Beyond" ? close <= bottom : low <= mid) : (rule == "Any Touch" ? high >= bottom : rule == "Body Beyond" ? close >= top : high >= mid)

f_count_true(array<bool> states) =>
    int total = 0
    if array.size(states) > 0
        for i = 0 to array.size(states) - 1
            total += array.get(states, i) ? 1 : 0
    total

f_calc_overlap(float top, float bottom, array<float> tops, array<float> bottoms) =>
    bool overlap = false
    if array.size(tops) > 0
        for i = 0 to array.size(tops) - 1
            overlap := overlap or (bottom <= array.get(tops, i) and top >= array.get(bottoms, i))
    overlap

f_label_text(string origin, float progress, bool inverted, int age) =>
    string labelText = origin + "  " + str.tostring(math.min(progress, 1.0) * 100.0, "#.0") + "%"
    labelText += inverted ? "  Inv" : ""
    labelText += "  " + str.tostring(age)
    labelText

f_age_alpha(int age) =>
    age <= staleFadeStart ? fillOpacity : int(f_clamp(fillOpacity + (age - staleFadeStart) * 0.25, fillOpacity, 95))

f_push_zone(array<box> boxes, array<line> mids, array<label> labels, array<float> tops, array<float> bottoms, array<int> births, array<float> fills, array<bool> inverted, array<string> origins, float top, float bottom, string origin, int direction) =>
    float mid = f_mid(top, bottom)
    color zoneColor = f_origin_color(origin, direction)
    box zoneBox = box.new(left = bar_index, top = top, right = bar_index + 1, bottom = bottom, bgcolor = color.new(zoneColor, fillOpacity), border_color = color.new(zoneColor, 0), border_width = 1)
    line zoneMid = line.new(bar_index, mid, bar_index + 1, mid, color = color.new(zoneColor, lineOpacity), style = line.style_dashed, width = 1)
    label zoneLabel = label.new(bar_index + 1, mid, origin, style = label.style_label_left, color = color.new(chart.bg_color, 100), textcolor = zoneColor, size = size.small)
    array.unshift(boxes, zoneBox)
    array.unshift(mids, zoneMid)
    array.unshift(labels, zoneLabel)
    array.unshift(tops, top)
    array.unshift(bottoms, bottom)
    array.unshift(births, bar_index)
    array.unshift(fills, 0.0)
    array.unshift(inverted, false)
    array.unshift(origins, origin)

f_trim(array<box> boxes, array<line> mids, array<label> labels, array<float> tops, array<float> bottoms, array<int> births, array<float> fills, array<bool> inverted, array<string> origins, int maxCount) =>
    while array.size(boxes) > maxCount
        box oldBox = array.pop(boxes)
        line oldMid = array.pop(mids)
        label oldLabel = array.pop(labels)
        box.delete(oldBox)
        line.delete(oldMid)
        label.delete(oldLabel)
        array.pop(tops)
        array.pop(bottoms)
        array.pop(births)
        array.pop(fills)
        array.pop(inverted)
        array.pop(origins)

//------------------------------------------------------------------------------
// Persistent storage
//------------------------------------------------------------------------------
var array<box> bullBoxes = array.new<box>()
var array<line> bullMids = array.new<line>()
var array<label> bullLabels = array.new<label>()
var array<float> bullTops = array.new<float>()
var array<float> bullBottoms = array.new<float>()
var array<int> bullBirths = array.new<int>()
var array<float> bullFills = array.new<float>()
var array<bool> bullInverted = array.new<bool>()
var array<string> bullOrigins = array.new<string>()

var array<box> bearBoxes = array.new<box>()
var array<line> bearMids = array.new<line>()
var array<label> bearLabels = array.new<label>()
var array<float> bearTops = array.new<float>()
var array<float> bearBottoms = array.new<float>()
var array<int> bearBirths = array.new<int>()
var array<float> bearFills = array.new<float>()
var array<bool> bearInverted = array.new<bool>()
var array<string> bearOrigins = array.new<string>()

//------------------------------------------------------------------------------
// Chart imbalance detection
//------------------------------------------------------------------------------
float atrBase = ta.atr(14)
float minWidth = atrBase * minWidthAtr
float impulseWidth = atrBase * displacementFactor

bool chartBull = showChart and barstate.isconfirmed and low > high[2] and close[1] > high[2] and (low - high[2]) >= minWidth and math.abs(close[1] - open[1]) >= impulseWidth
bool chartBear = showChart and barstate.isconfirmed and high < low[2] and close[1] < low[2] and (low[2] - high) >= minWidth and math.abs(close[1] - open[1]) >= impulseWidth

if chartBull and (not rejectOverlap or not f_calc_overlap(low, high[2], bullTops, bullBottoms))
    f_push_zone(bullBoxes, bullMids, bullLabels, bullTops, bullBottoms, bullBirths, bullFills, bullInverted, bullOrigins, low, high[2], "Chart", 1)

if chartBear and (not rejectOverlap or not f_calc_overlap(low[2], high, bearTops, bearBottoms))
    f_push_zone(bearBoxes, bearMids, bearLabels, bearTops, bearBottoms, bearBirths, bearFills, bearInverted, bearOrigins, low[2], high, "Chart", -1)

//------------------------------------------------------------------------------
// Higher-timeframe detection using confirmed offset requests
//------------------------------------------------------------------------------
bool htfValid = timeframe.in_seconds(htfInput) >= timeframe.in_seconds(timeframe.period)
bool newHtfBar = timeframe.change(htfInput)
float htfLowA = request.security(syminfo.tickerid, htfInput, low[1], lookahead = barmerge.lookahead_on)
float htfHighA = request.security(syminfo.tickerid, htfInput, high[1], lookahead = barmerge.lookahead_on)
float htfCloseB = request.security(syminfo.tickerid, htfInput, close[2], lookahead = barmerge.lookahead_on)
float htfLowC = request.security(syminfo.tickerid, htfInput, low[3], lookahead = barmerge.lookahead_on)
float htfHighC = request.security(syminfo.tickerid, htfInput, high[3], lookahead = barmerge.lookahead_on)
float htfAtr = request.security(syminfo.tickerid, htfInput, ta.atr(14)[1], lookahead = barmerge.lookahead_on)

bool htfBull = showHtf and htfValid and newHtfBar and htfLowA > htfHighC and htfCloseB > htfHighC and (htfLowA - htfHighC) >= htfAtr * minWidthAtr
bool htfBear = showHtf and htfValid and newHtfBar and htfHighA < htfLowC and htfCloseB < htfLowC and (htfLowC - htfHighA) >= htfAtr * minWidthAtr

if htfBull and (not rejectOverlap or not f_calc_overlap(htfLowA, htfHighC, bullTops, bullBottoms))
    f_push_zone(bullBoxes, bullMids, bullLabels, bullTops, bullBottoms, bullBirths, bullFills, bullInverted, bullOrigins, htfLowA, htfHighC, "HTF", 1)

if htfBear and (not rejectOverlap or not f_calc_overlap(htfLowC, htfHighA, bearTops, bearBottoms))
    f_push_zone(bearBoxes, bearMids, bearLabels, bearTops, bearBottoms, bearBirths, bearFills, bearInverted, bearOrigins, htfLowC, htfHighA, "HTF", -1)

//------------------------------------------------------------------------------
// Lower-timeframe micro imbalance scan
//------------------------------------------------------------------------------
[microHighs, microLows, microCloses, microAtrs] = request.security_lower_tf(syminfo.tickerid, microTfInput, [high, low, close, ta.atr(14)])
int microBullCount = 0
int microBearCount = 0
float microBullTop = na
float microBullBottom = na
float microBearTop = na
float microBearBottom = na

if showMicro and array.size(microHighs) >= 3 and barstate.isconfirmed
    for i = 2 to array.size(microHighs) - 1
        float h2 = array.get(microHighs, i - 2)
        float l0 = array.get(microLows, i)
        float c1 = array.get(microCloses, i - 1)
        float l2 = array.get(microLows, i - 2)
        float h0 = array.get(microHighs, i)
        float atrMicro = array.get(microAtrs, i)
        bool bullMicro = l0 > h2 and c1 > h2 and (l0 - h2) >= atrMicro * microWidthAtr
        bool bearMicro = h0 < l2 and c1 < l2 and (l2 - h0) >= atrMicro * microWidthAtr
        if bullMicro
            microBullCount += 1
            microBullTop := na(microBullTop) ? l0 : math.max(microBullTop, l0)
            microBullBottom := na(microBullBottom) ? h2 : math.min(microBullBottom, h2)
        if bearMicro
            microBearCount += 1
            microBearTop := na(microBearTop) ? l2 : math.max(microBearTop, l2)
            microBearBottom := na(microBearBottom) ? h0 : math.min(microBearBottom, h0)

bool microBull = showMicro and microBullCount >= microThreshold and not na(microBullTop) and not na(microBullBottom)
bool microBear = showMicro and microBearCount >= microThreshold and not na(microBearTop) and not na(microBearBottom)

if microBull and (not rejectOverlap or not f_calc_overlap(microBullTop, microBullBottom, bullTops, bullBottoms))
    f_push_zone(bullBoxes, bullMids, bullLabels, bullTops, bullBottoms, bullBirths, bullFills, bullInverted, bullOrigins, microBullTop, microBullBottom, "Micro", 1)

if microBear and (not rejectOverlap or not f_calc_overlap(microBearTop, microBearBottom, bearTops, bearBottoms))
    f_push_zone(bearBoxes, bearMids, bearLabels, bearTops, bearBottoms, bearBirths, bearFills, bearInverted, bearOrigins, microBearTop, microBearBottom, "Micro", -1)

//------------------------------------------------------------------------------
// Trim storage
//------------------------------------------------------------------------------
f_trim(bullBoxes, bullMids, bullLabels, bullTops, bullBottoms, bullBirths, bullFills, bullInverted, bullOrigins, maxZonesPerSide)
f_trim(bearBoxes, bearMids, bearLabels, bearTops, bearBottoms, bearBirths, bearFills, bearInverted, bearOrigins, maxZonesPerSide)

//------------------------------------------------------------------------------
// Zone lifecycle updates
//------------------------------------------------------------------------------
bool bullInversionSignal = false
bool bearInversionSignal = false

if array.size(bullBoxes) > 0
    for i = array.size(bullBoxes) - 1 to 0
        box zoneBox = array.get(bullBoxes, i)
        line zoneMid = array.get(bullMids, i)
        label zoneLabel = array.get(bullLabels, i)
        float top = array.get(bullTops, i)
        float bottom = array.get(bullBottoms, i)
        int born = array.get(bullBirths, i)
        float progress = math.max(array.get(bullFills, i), f_fill_ratio(1, top, bottom))
        bool inverted = array.get(bullInverted, i)
        string origin = array.get(bullOrigins, i)
        int age = bar_index - born
        color baseColor = f_origin_color(origin, 1)

        array.set(bullFills, i, progress)
        box.set_right(zoneBox, bar_index + 1)
        box.set_bgcolor(zoneBox, color.new(baseColor, f_age_alpha(age)))
        line.set_x2(zoneMid, bar_index + 1)
        line.set_color(zoneMid, showMidlines ? color.new(baseColor, lineOpacity) : color.new(chart.bg_color, 100))
        label.set_x(zoneLabel, bar_index + 1)
        label.set_y(zoneLabel, f_mid(top, bottom))
        label.set_text(zoneLabel, showLabels ? f_label_text(origin, progress, inverted, age) : "")
        label.set_textcolor(zoneLabel, inverted ? invertCol : baseColor)

        if allowInversion and not inverted and barstate.isconfirmed and close < bottom
            array.set(bullInverted, i, true)
            bullInversionSignal := true
            box.set_border_color(zoneBox, invertCol)
            line.set_color(zoneMid, invertCol)
            label.set_textcolor(zoneLabel, invertCol)

        bool retire = f_should_retire(1, top, bottom, fillRule)
        bool stale = age > keepBars
        bool hardKill = allowInversion and array.get(bullInverted, i) and close > top
        if retire or stale or hardKill
            box.delete(zoneBox)
            line.delete(zoneMid)
            label.delete(zoneLabel)
            array.remove(bullBoxes, i)
            array.remove(bullMids, i)
            array.remove(bullLabels, i)
            array.remove(bullTops, i)
            array.remove(bullBottoms, i)
            array.remove(bullBirths, i)
            array.remove(bullFills, i)
            array.remove(bullInverted, i)
            array.remove(bullOrigins, i)

if array.size(bearBoxes) > 0
    for i = array.size(bearBoxes) - 1 to 0
        box zoneBox = array.get(bearBoxes, i)
        line zoneMid = array.get(bearMids, i)
        label zoneLabel = array.get(bearLabels, i)
        float top = array.get(bearTops, i)
        float bottom = array.get(bearBottoms, i)
        int born = array.get(bearBirths, i)
        float progress = math.max(array.get(bearFills, i), f_fill_ratio(-1, top, bottom))
        bool inverted = array.get(bearInverted, i)
        string origin = array.get(bearOrigins, i)
        int age = bar_index - born
        color baseColor = f_origin_color(origin, -1)

        array.set(bearFills, i, progress)
        box.set_right(zoneBox, bar_index + 1)
        box.set_bgcolor(zoneBox, color.new(baseColor, f_age_alpha(age)))
        line.set_x2(zoneMid, bar_index + 1)
        line.set_color(zoneMid, showMidlines ? color.new(baseColor, lineOpacity) : color.new(chart.bg_color, 100))
        label.set_x(zoneLabel, bar_index + 1)
        label.set_y(zoneLabel, f_mid(top, bottom))
        label.set_text(zoneLabel, showLabels ? f_label_text(origin, progress, inverted, age) : "")
        label.set_textcolor(zoneLabel, inverted ? invertCol : baseColor)

        if allowInversion and not inverted and barstate.isconfirmed and close > top
            array.set(bearInverted, i, true)
            bearInversionSignal := true
            box.set_border_color(zoneBox, invertCol)
            line.set_color(zoneMid, invertCol)
            label.set_textcolor(zoneLabel, invertCol)

        bool retire = f_should_retire(-1, top, bottom, fillRule)
        bool stale = age > keepBars
        bool hardKill = allowInversion and array.get(bearInverted, i) and close < bottom
        if retire or stale or hardKill
            box.delete(zoneBox)
            line.delete(zoneMid)
            label.delete(zoneLabel)
            array.remove(bearBoxes, i)
            array.remove(bearMids, i)
            array.remove(bearLabels, i)
            array.remove(bearTops, i)
            array.remove(bearBottoms, i)
            array.remove(bearBirths, i)
            array.remove(bearFills, i)
            array.remove(bearInverted, i)
            array.remove(bearOrigins, i)

//------------------------------------------------------------------------------
// Bias and metrics
//------------------------------------------------------------------------------
int bullCount = array.size(bullBoxes)
int bearCount = array.size(bearBoxes)
int bullInvCount = f_count_true(bullInverted)
int bearInvCount = f_count_true(bearInverted)
string structureState = bullCount > bearCount ? "Bid Support" : bullCount < bearCount ? "Offer Pressure" : "Balanced"
color structureColor = bullCount > bearCount ? bullChartCol : bullCount < bearCount ? bearChartCol : chart.fg_color
float nearestBull = bullCount > 0 ? array.get(bullBottoms, 0) : na
float nearestBear = bearCount > 0 ? array.get(bearTops, 0) : na
float bullDistance = not na(nearestBull) ? (close - nearestBull) / math.max(atrBase, syminfo.mintick) : na
float bearDistance = not na(nearestBear) ? (nearestBear - close) / math.max(atrBase, syminfo.mintick) : na
float pressureRatio = (bullCount - bearCount) / math.max(bullCount + bearCount, 1)
color candleColor = pressureRatio > 0 ? color.from_gradient(pressureRatio, 0.0, 1.0, bullChartCol, bullHtfCol) : pressureRatio < 0 ? color.from_gradient(math.abs(pressureRatio), 0.0, 1.0, bearChartCol, bearHtfCol) : neutralCol

color backdropColor = showBackdrop ? color.new(candleColor, 93) : na
bgcolor(backdropColor)

color chartCandleColor = showCandles ? candleColor : na
barcolor(chartCandleColor)
plotcandle(showCandles ? open : na, showCandles ? high : na, showCandles ? low : na, showCandles ? close : na, color = candleColor, wickcolor = candleColor, bordercolor = candleColor)

plot(nearestBull, "Nearest Bull Base", display = display.none)
plot(nearestBear, "Nearest Bear Ceiling", display = display.none)

//------------------------------------------------------------------------------
// Dashboard
//------------------------------------------------------------------------------
var table dash = table.new(position.top_right, 2, 8, bgcolor = color.new(color.rgb(8, 10, 17), 0), frame_color = color.new(chart.fg_color, 75), frame_width = 1, border_color = color.new(chart.fg_color, 90), border_width = 1)
if showDashboard and barstate.islast
    table.cell(dash, 0, 0, "Meridian", text_color = chart.fg_color, bgcolor = color.new(color.rgb(25, 30, 44), 0), text_size = f_size(dashSize))
    table.cell(dash, 1, 0, structureState, text_color = structureColor, bgcolor = color.new(color.rgb(25, 30, 44), 0), text_size = f_size(dashSize))
    table.cell(dash, 0, 1, "Bull Zones", text_color = chart.fg_color, text_size = f_size(dashSize))
    table.cell(dash, 1, 1, str.tostring(bullCount), text_color = bullChartCol, text_size = f_size(dashSize))
    table.cell(dash, 0, 2, "Bear Zones", text_color = chart.fg_color, text_size = f_size(dashSize))
    table.cell(dash, 1, 2, str.tostring(bearCount), text_color = bearChartCol, text_size = f_size(dashSize))
    table.cell(dash, 0, 3, "Bull Inv", text_color = chart.fg_color, text_size = f_size(dashSize))
    table.cell(dash, 1, 3, str.tostring(bullInvCount), text_color = invertCol, text_size = f_size(dashSize))
    table.cell(dash, 0, 4, "Bear Inv", text_color = chart.fg_color, text_size = f_size(dashSize))
    table.cell(dash, 1, 4, str.tostring(bearInvCount), text_color = invertCol, text_size = f_size(dashSize))
    table.cell(dash, 0, 5, "Micro Scan", text_color = chart.fg_color, text_size = f_size(dashSize))
    table.cell(dash, 1, 5, str.tostring(microBullCount) + " / " + str.tostring(microBearCount), text_color = bullMicroCol, text_size = f_size(dashSize))
    table.cell(dash, 0, 6, "Bias Ratio", text_color = chart.fg_color, text_size = f_size(dashSize))
    table.cell(dash, 1, 6, str.tostring(pressureRatio, "#.##"), text_color = candleColor, text_size = f_size(dashSize))
    table.cell(dash, 0, 7, showDistanceMetrics ? "Distances" : "ATR", text_color = chart.fg_color, text_size = f_size(dashSize))
    string metricText = showDistanceMetrics ? "B " + (na(bullDistance) ? "na" : str.tostring(bullDistance, "#.##")) + " | S " + (na(bearDistance) ? "na" : str.tostring(bearDistance, "#.##")) : str.tostring(atrBase, format.mintick)
    table.cell(dash, 1, 7, metricText, text_color = chart.fg_color, text_size = f_size(dashSize))

//------------------------------------------------------------------------------
// Alerts
//------------------------------------------------------------------------------
alertcondition(enableAlerts and chartBull, "Meridian Chart Bull", "A new chart bullish imbalance has formed.")
alertcondition(enableAlerts and chartBear, "Meridian Chart Bear", "A new chart bearish imbalance has formed.")
alertcondition(enableAlerts and htfBull, "Meridian HTF Bull", "A new higher-timeframe bullish imbalance has formed.")
alertcondition(enableAlerts and htfBear, "Meridian HTF Bear", "A new higher-timeframe bearish imbalance has formed.")
alertcondition(enableAlerts and microBull, "Meridian Micro Bull", "Micro bullish imbalance clustering is active.")
alertcondition(enableAlerts and microBear, "Meridian Micro Bear", "Micro bearish imbalance clustering is active.")
alertcondition(enableAlerts and bullInversionSignal, "Meridian Bull Inversion", "A bullish imbalance has inverted into overhead supply.")
alertcondition(enableAlerts and bearInversionSignal, "Meridian Bear Inversion", "A bearish imbalance has inverted into underprice support.")
````
