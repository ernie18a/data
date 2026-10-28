# IRL ERL Liquidity Map

- url: https://www.tradingview.com/script/cTE4lNcx-IRL-ERL-Liquidity-Map/
- type: indicator
- pine_id: PUB;fafbc33043534c7db0f90b6217fd0c7f
- version: 1.0

## Description

IRL ERL Liquidity Map is an original multi-timeframe orderflow and liquidity mapping tool designed to help traders organize internal liquidity zones and external liquidity objectives on one clean chart.

The script focuses on the relationship between IRL and ERL:

IRL, or Internal Range Liquidity, is represented by imbalance-style zones such as Fair Value Gaps (FVG) and Breakaway Gaps (BAG). These zones mark areas where price may return before continuing toward a larger liquidity objective.

ERL, or External Range Liquidity, is represented by swing highs, swing lows, and previous high/low levels from higher timeframes. These levels act as possible draw-on-liquidity objectives once price reacts from an internal zone.

The purpose of combining these components is not to create separate signals, but to show one complete liquidity workflow:
1. Identify an internal liquidity zone.
2. Watch whether price reacts from it or closes through it.
3. Track the likely external liquidity objective.
4. Use higher-timeframe levels and session ranges for context.

Main Features

Multi-Timeframe IRL Zones:
The indicator tracks FVG and BAG zones across selected timeframes including 15m, 1h, 4h, Daily, Weekly, and Monthly. Each timeframe can be enabled or disabled separately. Bias can be left on Auto or manually filtered to bullish or bearish.

FVG and BAG Detection:
A bullish FVG is detected when the current candle leaves an imbalance above the candle two bars back. A bearish FVG is detected when the current candle leaves an imbalance below the candle two bars back. BAG zones are stricter gap conditions where the displacement candle also breaks beyond the prior candle structure.

Zone Validation:
Zones remain active until price invalidates them by closing through the zone body on the related timeframe, or until the related external liquidity target is reached. This helps separate a simple wick reaction from a stronger body-close invalidation.

ERL Targets:
The script uses swing highs and swing lows as external liquidity targets. When price reacts from an IRL zone, the nearest relevant swing objective helps define where the current context may complete.

Swing Points:
Tiny swing dots and optional ERL swing lines can be displayed on the chart. These are intended to make local liquidity points easier to see without adding heavy visual clutter.

Higher-Timeframe Liquidity Levels:
Previous Day High/Low, Previous Week High/Low, and Previous Month High/Low can be displayed. These levels are commonly used as external liquidity references and can be automatically removed once swept.

Session Killzones:
The script includes configurable session ranges for London, New York, Asia, and Sydney. These ranges help traders study when liquidity runs, reactions, and displacement are occurring during active market windows.

Dashboard:
A compact dashboard summarizes the current orderflow state for each enabled timeframe. It shows whether price is reacting from an IRL zone, whether a zone is failing, or whether no active context is present. The dashboard uses matching timeframe colors for easier reading:
4h = orange
Daily = blue
Weekly = yellow
Monthly = red

Chart Clarity:
The script includes display controls to reduce clutter, including maximum active zones per timeframe, maximum total zones, fixed-width zone boxes, dashed zone borders, label controls, and opacity settings.

How To Use

Use higher timeframes first to identify major liquidity context. For example, Daily, Weekly, or Monthly zones can show larger areas where price may react or rebalance.

Use lower timeframes to refine entries and observe whether price is respecting or failing an internal liquidity zone.

A reacting state means price has entered an active IRL zone without yet invalidating it by body close.

A failing state means price has closed through the IRL zone according to the selected timeframe logic.

An ERL completion means price has reached the related swing or external liquidity objective after the IRL context was active.

This tool does not predict price direction by itself. It is designed as a visual framework for studying liquidity, imbalance, session timing, and higher-timeframe objectives. Traders should combine it with their own risk management, market structure analysis, and confirmation rules.

Recommended Chart Setup

For publication or clean analysis, use this indicator by itself on the chart, with minimal drawings. Keep the chart background clean so the FVG/BAG zones, ERL targets, session ranges, and higher-timeframe levels are easy to identify.

## Source Code

````pine
// This Pine Script is subject to the terms of the Mozilla Public License 2.0
// ICT orderflow liquidity framework with HTF levels and session ranges.

//@version=6
indicator("IRL ERL Liquidity Map", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

//------------------------------------------------------------------------------
// Inputs
//------------------------------------------------------------------------------
var G_TF = "Tracked Timeframes"
showTf1 = input.bool(true, "15m", inline = "tf1", group = G_TF)
tf1     = input.timeframe("15", "", inline = "tf1", group = G_TF)
biasTf1 = input.string("Auto", "", options = ["Auto", "Bullish", "Bearish"], inline = "tf1", group = G_TF)

showTf2 = input.bool(true, "1h", inline = "tf2", group = G_TF)
tf2     = input.timeframe("60", "", inline = "tf2", group = G_TF)
biasTf2 = input.string("Auto", "", options = ["Auto", "Bullish", "Bearish"], inline = "tf2", group = G_TF)

showTf3 = input.bool(true, "4h", inline = "tf3", group = G_TF)
tf3     = input.timeframe("240", "", inline = "tf3", group = G_TF)
biasTf3 = input.string("Auto", "", options = ["Auto", "Bullish", "Bearish"], inline = "tf3", group = G_TF)

showTf4 = input.bool(true, "D", inline = "tf4", group = G_TF)
tf4     = input.timeframe("D", "", inline = "tf4", group = G_TF)
biasTf4 = input.string("Auto", "", options = ["Auto", "Bullish", "Bearish"], inline = "tf4", group = G_TF)

showTf5 = input.bool(true, "W", inline = "tf5", group = G_TF)
tf5     = input.timeframe("W", "", inline = "tf5", group = G_TF)
biasTf5 = input.string("Auto", "", options = ["Auto", "Bullish", "Bearish"], inline = "tf5", group = G_TF)

showTf6 = input.bool(true, "M", inline = "tf6", group = G_TF)
tf6     = input.timeframe("M", "", inline = "tf6", group = G_TF)
biasTf6 = input.string("Auto", "", options = ["Auto", "Bullish", "Bearish"], inline = "tf6", group = G_TF)

var G_ENGINE = "Orderflow Engine"
swingLen = input.int(5, "Swing Strength", minval = 1, maxval = 50, group = G_ENGINE)
validIrlType = input.string("FVG + BAG", "Valid IRL Type", options = ["FVG Only", "BAG Only", "FVG + BAG"], group = G_ENGINE)
maxZonesPerTf = input.int(2, "Max Active Zones Per Timeframe", minval = 1, maxval = 20, group = G_ENGINE)
maxTotalZones = input.int(14, "Max Total Zones", minval = 6, maxval = 200, group = G_ENGINE)
extendBars = input.int(24, "Extend Active Zones", minval = 5, maxval = 250, group = G_ENGINE)
stopExpandWhenMitigated = input.bool(true, "Stop IRLs From Expanding When Mitigated", group = G_ENGINE)
changeColorWhenMitigated = input.bool(false, "Change IRL/FVG Color When Mitigated", group = G_ENGINE)
hideInactiveInsteadDelete = input.bool(false, "Hide Inactive Instead Of Delete", group = G_ENGINE)
keepCompleted = input.bool(false, "Keep Completed Contexts", group = G_ENGINE)
showErlBeforeTap = input.bool(true, "Show ERL Lines Before IRL Is Tapped", group = G_ENGINE)

var G_SWING = "Current Swing ERL Targets"
showSwingErl = input.bool(true, "Show Current Swing ERLs", group = G_SWING)
showSwingDots = input.bool(true, "Show Tiny Swing Dots", group = G_SWING)
maxSwingTargets = input.int(3, "Max ERLs Per Side", minval = 1, maxval = 20, group = G_SWING)
swingHighColor = input.color(color.new(#8f96a3, 0), "Swing High ERL Color", group = G_SWING)
swingLowColor = input.color(color.new(#8f96a3, 0), "Swing Low ERL Color", group = G_SWING)
swingDotColor = input.color(color.gray, "Swing Dot Color", group = G_SWING)

var G_VIS = "Visual Style"
zoneFillCol = input.color(color.new(#8f96a3, 78), "Universal IRL/FVG Color", group = G_VIS)
zoneMitigatedCol = input.color(color.new(#8f96a3, 90), "Mitigated IRL/FVG Color", group = G_VIS)
zoneLabelCol = input.color(#8f96a3, "Universal IRL/FVG Label Color", group = G_VIS)
erlColor = input.color(#8f96a3, "Universal ERL Color", group = G_VIS)
showZoneLabels = input.bool(true, "Show Zone Labels", group = G_VIS)
showDashboard = input.bool(true, "Show Bias / Reliability Table", group = G_VIS)

var G_HTF_FVG = "D/W/M FVG Colors"
useDwmFvgColors = input.bool(true, "Use Separate D/W/M FVG Colors", group = G_HTF_FVG)
fourHourFvgColor = input.color(#f6a04d, "4h FVG Color", group = G_HTF_FVG)
dailyFvgColor = input.color(#5b9cf6, "Daily FVG Color", group = G_HTF_FVG)
weeklyFvgColor = input.color(#f4d35e, "Weekly FVG Color", group = G_HTF_FVG)
monthlyFvgColor = input.color(#e57373, "Monthly FVG Color", group = G_HTF_FVG)
dwmFvgOpacity = input.int(70, "4h/D/W/M FVG Opacity", minval = 0, maxval = 100, group = G_HTF_FVG)
showZoneBorders = input.bool(true, "Show FVG/BAG Borders", group = G_HTF_FVG)
zoneBorderOpacity = input.int(35, "Border Opacity", minval = 0, maxval = 100, group = G_HTF_FVG)

var G_ALERT = "Alerts"
alertFreshIrl = input.bool(true, "Alert Fresh IRL Entry", group = G_ALERT)
alertFailing = input.bool(true, "Alert IRL Failing", group = G_ALERT)
alertCompleted = input.bool(true, "Alert ERL Completed", group = G_ALERT)

var G_SESS = "Session Killzones"
tzInput        = input.string("GMT+5:30", "Timezone", group = G_SESS)
showSessLabels = input.bool(false, "Show Session Range Labels", group = G_SESS)

showS1   = input.bool(true, "Session 1", inline = "s1", group = G_SESS)
s1_name  = input.string("London", "", inline = "s1", group = G_SESS)
s1_time  = input.session("1230-1730", "Time", group = G_SESS)
s1_color = input.color(#00bcd4, "Color", group = G_SESS)

showS2   = input.bool(true, "Session 2", inline = "s2", group = G_SESS)
s2_name  = input.string("New York", "", inline = "s2", group = G_SESS)
s2_time  = input.session("1730-0230", "Time", group = G_SESS)
s2_color = input.color(#ff9800, "Color", group = G_SESS)

showS3   = input.bool(true, "Session 3", inline = "s3", group = G_SESS)
s3_name  = input.string("Asia", "", inline = "s3", group = G_SESS)
s3_time  = input.session("0230-1030", "Time", group = G_SESS)
s3_color = input.color(#ffeb3b, "Color", group = G_SESS)

showS4   = input.bool(true, "Session 4", inline = "s4", group = G_SESS)
s4_name  = input.string("Sydney", "", inline = "s4", group = G_SESS)
s4_time  = input.session("2000-0500", "Time", group = G_SESS)
s4_color = input.color(#e91e63, "Color", group = G_SESS)

var G_HTF = "HTF Liquidity Levels"
showPD    = input.bool(true, "Previous Day H/L", group = G_HTF)
showPW    = input.bool(true, "Previous Week H/L", group = G_HTF)
showPM    = input.bool(true, "Previous Month H/L", group = G_HTF)
lineStyle = input.string("Dashed", "Line Style", options = ["Solid", "Dashed", "Dotted"], group = G_HTF)

var G_HYGIENE = "Zone Display Hygiene"
useFixedZoneWidth = input.bool(true, "Use Fixed FVG/BAG Box Width", group = G_HYGIENE, tooltip = "Keeps active zones logically valid, but displays each box with a standard width so the chart does not become cluttered.")
fixedZoneWidthBars = input.int(36, "Fixed Box Width Bars", minval = 5, maxval = 300, group = G_HYGIENE)

//------------------------------------------------------------------------------
// Types
//------------------------------------------------------------------------------
type OFZone
    box b
    line erl
    line topBorder
    line bottomBorder
    label tag
    float top
    float bottom
    float target
    int dir
    int kind
    string tfName
    int tfRank
    int bornTime
    bool mitigated
    bool completed
    bool inactive

type TargetLine
    line l
    float price
    bool isHigh

type StoredFVG
    box b
    label tag
    float top
    float bottom
    int dir
    string tfName
    int bornTime

//------------------------------------------------------------------------------
// Helpers
//------------------------------------------------------------------------------
bodyHigh() =>
    math.max(open, close)

bodyLow() =>
    math.min(open, close)

rankFromSeconds(int sec) =>
    sec >= timeframe.in_seconds("M") ? 6 : sec >= timeframe.in_seconds("W") ? 5 : sec >= timeframe.in_seconds("D") ? 4 : sec >= timeframe.in_seconds("240") ? 3 : sec >= timeframe.in_seconds("60") ? 2 : 1

tfRank(string tf) =>
    rankFromSeconds(timeframe.in_seconds(tf))

chartRank() =>
    rankFromSeconds(timeframe.in_seconds(timeframe.period))

tfAllowedOnChart(string tf) =>
    tfRank(tf) >= chartRank()

tfDisplay(string tf) =>
    tf == "15" ? "15m" : tf == "60" ? "1h" : tf == "240" ? "4h" : tf == "D" ? "D" : tf == "W" ? "W" : tf == "M" ? "M" : tf

get_line_style(string s) =>
    s == "Solid" ? line.style_solid : s == "Dashed" ? line.style_dashed : line.style_dotted

biasAllows(string biasSetting, int dir) =>
    biasSetting == "Auto" or biasSetting == "Bullish" and dir == 1 or biasSetting == "Bearish" and dir == -1

dirIcon(int dir) =>
    dir == 1 ? "▲" : "▼"

kindName(int kind) =>
    kind == 2 ? "BAG" : "FVG"

statusText(int state) =>
    state == 1 ? "bullish IRL reacting" : state == -1 ? "bearish IRL reacting" : state == 2 ? "bullish IRL failing" : state == -2 ? "bearish IRL failing" : "-"

statusColor(int state) =>
    state == 2 or state == -2 ? color.new(color.red, 0) : #8f96a3

ratioText(int follow, int total) =>
    total > 0 ? str.tostring(math.round(follow * 100.0 / total)) + "% (" + str.tostring(total) + " samples)" : "-"

isBodyThrough(float top, float bottom, int dir) =>
    dir == 1 ? bodyLow() <= bottom : bodyHigh() >= top

isBodyThroughValues(float top, float bottom, int dir, float bHi, float bLo) =>
    dir == 1 ? bLo <= bottom : bHi >= top

isTouched(float top, float bottom) =>
    low <= top and high >= bottom

isCompleted(float target, int dir) =>
    dir == 1 ? high >= target : low <= target

sameZone(float topA, float botA, float topB, float botB) =>
    not na(topA) and not na(botA) and not na(topB) and not na(botB) and math.abs(topA - topB) <= syminfo.mintick * 2 and math.abs(botA - botB) <= syminfo.mintick * 2

chartMs() =>
    int(timeframe.in_seconds(timeframe.period) * 1000)

zoneRightTime(int bornTime) =>
    useFixedZoneWidth ? bornTime + chartMs() * fixedZoneWidthBars : time + chartMs() * extendBars

zoneLeftTime(int bornTime) =>
    bornTime

zoneFillForTf(string tfName) =>
    not useDwmFvgColors ? zoneFillCol :
     tfName == "4h" ? color.new(fourHourFvgColor, dwmFvgOpacity) :
     tfName == "D" ? color.new(dailyFvgColor, dwmFvgOpacity) :
     tfName == "W" ? color.new(weeklyFvgColor, dwmFvgOpacity) :
     tfName == "M" ? color.new(monthlyFvgColor, dwmFvgOpacity) : zoneFillCol

zoneTextForTf(string tfName) =>
    not useDwmFvgColors ? zoneLabelCol :
     tfName == "4h" ? fourHourFvgColor :
     tfName == "D" ? dailyFvgColor :
     tfName == "W" ? weeklyFvgColor :
     tfName == "M" ? monthlyFvgColor : zoneLabelCol

dashboardStatusColor(string tfName, int state) =>
    state == 2 or state == -2 ? color.new(color.red, 0) : zoneTextForTf(tfName)

zoneBorderForTf(string tfName) =>
    not showZoneBorders ? na :
     tfName == "4h" ? color.new(fourHourFvgColor, zoneBorderOpacity) :
     tfName == "D" ? color.new(dailyFvgColor, zoneBorderOpacity) :
     tfName == "W" ? color.new(weeklyFvgColor, zoneBorderOpacity) :
     tfName == "M" ? color.new(monthlyFvgColor, zoneBorderOpacity) : color.new(zoneLabelCol, zoneBorderOpacity)

sameStoredFvg(string tfName, float top, float bot, int dir, int bornTime, array<StoredFVG> store) =>
    bool exists = false
    if array.size(store) > 0
        for i = array.size(store) - 1 to 0
            z = array.get(store, i)
            if z.tfName == tfName and z.dir == dir and z.bornTime == bornTime and sameZone(z.top, z.bottom, top, bot)
                exists := true
    exists

hideZone(OFZone z) =>
    box.set_bgcolor(z.b, color.new(color.white, 100))
    box.set_border_color(z.b, color.new(color.white, 100))
    line.set_color(z.erl, color.new(color.white, 100))
    if not na(z.topBorder)
        line.set_color(z.topBorder, color.new(color.white, 100))
    if not na(z.bottomBorder)
        line.set_color(z.bottomBorder, color.new(color.white, 100))
    if not na(z.tag)
        label.delete(z.tag)
    true

deleteZone(OFZone z) =>
    box.delete(z.b)
    line.delete(z.erl)
    if not na(z.topBorder)
        line.delete(z.topBorder)
    if not na(z.bottomBorder)
        line.delete(z.bottomBorder)
    if not na(z.tag)
        label.delete(z.tag)
    true

disposeZone(OFZone z) =>
    hideInactiveInsteadDelete ? hideZone(z) : deleteZone(z)

//------------------------------------------------------------------------------
// Current Chart Swing ERL Targets
//------------------------------------------------------------------------------
var highTargets = array.new<TargetLine>()
var lowTargets = array.new<TargetLine>()

ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low, swingLen, swingLen)

plot(showSwingDots and not na(ph) ? ph : na, "Tiny Swing High Dots", color = swingDotColor, style = plot.style_circles, linewidth = 1, offset = -swingLen)
plot(showSwingDots and not na(pl) ? pl : na, "Tiny Swing Low Dots", color = swingDotColor, style = plot.style_circles, linewidth = 1, offset = -swingLen)

if showSwingErl and not na(ph)
    if array.size(highTargets) >= maxSwingTargets
        oldHigh = array.shift(highTargets)
        line.delete(oldHigh.l)
    highLine = line.new(bar_index - swingLen, ph, bar_index, ph, color = swingHighColor, width = 1)
    array.push(highTargets, TargetLine.new(highLine, ph, true))

if showSwingErl and not na(pl)
    if array.size(lowTargets) >= maxSwingTargets
        oldLow = array.shift(lowTargets)
        line.delete(oldLow.l)
    lowLine = line.new(bar_index - swingLen, pl, bar_index, pl, color = swingLowColor, width = 1)
    array.push(lowTargets, TargetLine.new(lowLine, pl, false))

if array.size(highTargets) > 0
    for i = array.size(highTargets) - 1 to 0
        t = array.get(highTargets, i)
        if high >= t.price
            line.delete(t.l)
            array.remove(highTargets, i)
        else
            line.set_x2(t.l, bar_index)

if array.size(lowTargets) > 0
    for i = array.size(lowTargets) - 1 to 0
        t = array.get(lowTargets, i)
        if low <= t.price
            line.delete(t.l)
            array.remove(lowTargets, i)
        else
            line.set_x2(t.l, bar_index)

//------------------------------------------------------------------------------
// Timeframe Orderflow Engine
//------------------------------------------------------------------------------
ofState(string biasSetting) =>
    atrVal = ta.atr(14)
    bullFvg = barstate.isconfirmed and low > high[2]
    bearFvg = barstate.isconfirmed and high < low[2]
    bullBag = bullFvg and close > high[1]
    bearBag = bearFvg and close < low[1]

    validBull = validIrlType == "FVG Only" ? bullFvg : validIrlType == "BAG Only" ? bullBag : bullFvg or bullBag
    validBear = validIrlType == "FVG Only" ? bearFvg : validIrlType == "BAG Only" ? bearBag : bearFvg or bearBag

    rPh = ta.pivothigh(high, swingLen, swingLen)
    rPl = ta.pivotlow(low, swingLen, swingLen)

    var float activeTop = na
    var float activeBot = na
    var float activeTarget = na
    var int activeDir = 0
    var int activeKind = 0
    var int activeBornTime = na
    var bool activeLogged = false
    var bool activeTouched = false
    var int follow = 0
    var int total = 0
    var float lastHigh = na
    var float lastLow = na

    if not na(rPh)
        lastHigh := rPh

    if not na(rPl)
        lastLow := rPl

    if validBull and biasAllows(biasSetting, 1)
        activeTop := low
        activeBot := high[2]
        activeTarget := na(lastHigh) ? high + atrVal * 2.0 : lastHigh
        activeDir := 1
        activeKind := bullBag ? 2 : 1
        activeBornTime := time
        activeLogged := false
        activeTouched := false

    if validBear and biasAllows(biasSetting, -1)
        activeTop := low[2]
        activeBot := high
        activeTarget := na(lastLow) ? low - atrVal * 2.0 : lastLow
        activeDir := -1
        activeKind := bearBag ? 2 : 1
        activeBornTime := time
        activeLogged := false
        activeTouched := false

    touched = activeDir != 0 and isTouched(activeTop, activeBot)
    failed = activeDir != 0 and barstate.isconfirmed and isBodyThrough(activeTop, activeBot, activeDir)
    followed = activeDir != 0 and isCompleted(activeTarget, activeDir)

    int state = 0

    if activeDir != 0
        if touched and not failed
            activeTouched := true
            state := activeDir

        if failed
            state := activeDir == 1 ? 2 : -2
            if activeTouched and not activeLogged
                total += 1
                activeLogged := true

        if followed
            if activeTouched and not activeLogged
                follow += 1
                total += 1
                activeLogged := true

    limited = bar_index < 250 ? 1 : 0
    [activeTop, activeBot, activeDir, activeTarget, activeKind, activeBornTime, state, follow, total, limited]

//------------------------------------------------------------------------------
// Multi-Timeframe Calls
//------------------------------------------------------------------------------
[t1Top, t1Bot, t1Dir, t1Target, t1Kind, t1Born, t1State, t1Follow, t1Total, t1Limited] = request.security(syminfo.tickerid, tf1, ofState(biasTf1), lookahead = barmerge.lookahead_off)
[t2Top, t2Bot, t2Dir, t2Target, t2Kind, t2Born, t2State, t2Follow, t2Total, t2Limited] = request.security(syminfo.tickerid, tf2, ofState(biasTf2), lookahead = barmerge.lookahead_off)
[t3Top, t3Bot, t3Dir, t3Target, t3Kind, t3Born, t3State, t3Follow, t3Total, t3Limited] = request.security(syminfo.tickerid, tf3, ofState(biasTf3), lookahead = barmerge.lookahead_off)
[t4Top, t4Bot, t4Dir, t4Target, t4Kind, t4Born, t4State, t4Follow, t4Total, t4Limited] = request.security(syminfo.tickerid, tf4, ofState(biasTf4), lookahead = barmerge.lookahead_off)
[t5Top, t5Bot, t5Dir, t5Target, t5Kind, t5Born, t5State, t5Follow, t5Total, t5Limited] = request.security(syminfo.tickerid, tf5, ofState(biasTf5), lookahead = barmerge.lookahead_off)
[t6Top, t6Bot, t6Dir, t6Target, t6Kind, t6Born, t6State, t6Follow, t6Total, t6Limited] = request.security(syminfo.tickerid, tf6, ofState(biasTf6), lookahead = barmerge.lookahead_off)

[t1BodyHi, t1BodyLo, t1BodyTime, t1BodyConfirmed] = request.security(syminfo.tickerid, tf1, [bodyHigh(), bodyLow(), time, barstate.isconfirmed], lookahead = barmerge.lookahead_off)
[t2BodyHi, t2BodyLo, t2BodyTime, t2BodyConfirmed] = request.security(syminfo.tickerid, tf2, [bodyHigh(), bodyLow(), time, barstate.isconfirmed], lookahead = barmerge.lookahead_off)
[t3BodyHi, t3BodyLo, t3BodyTime, t3BodyConfirmed] = request.security(syminfo.tickerid, tf3, [bodyHigh(), bodyLow(), time, barstate.isconfirmed], lookahead = barmerge.lookahead_off)
[t4BodyHi, t4BodyLo, t4BodyTime, t4BodyConfirmed] = request.security(syminfo.tickerid, tf4, [bodyHigh(), bodyLow(), time, barstate.isconfirmed], lookahead = barmerge.lookahead_off)
[t5BodyHi, t5BodyLo, t5BodyTime, t5BodyConfirmed] = request.security(syminfo.tickerid, tf5, [bodyHigh(), bodyLow(), time, barstate.isconfirmed], lookahead = barmerge.lookahead_off)
[t6BodyHi, t6BodyLo, t6BodyTime, t6BodyConfirmed] = request.security(syminfo.tickerid, tf6, [bodyHigh(), bodyLow(), time, barstate.isconfirmed], lookahead = barmerge.lookahead_off)

//------------------------------------------------------------------------------
// Drawing Engine
//------------------------------------------------------------------------------
var zones = array.new<OFZone>()

zoneExists(string tfName, float top, float bot, int dir, int bornTime) =>
    bool exists = false
    if array.size(zones) > 0
        for i = array.size(zones) - 1 to 0
            z = array.get(zones, i)
            if z.tfName == tfName and z.dir == dir and z.bornTime == bornTime and sameZone(z.top, z.bottom, top, bot)
                exists := true
    exists

tfBodyFilledForZone(string tfName, float top, float bot, int dir, int bornTime) =>
    tfName == tfDisplay(tf1) ? t1BodyConfirmed and t1BodyTime > bornTime and isBodyThroughValues(top, bot, dir, t1BodyHi, t1BodyLo) :
     tfName == tfDisplay(tf2) ? t2BodyConfirmed and t2BodyTime > bornTime and isBodyThroughValues(top, bot, dir, t2BodyHi, t2BodyLo) :
     tfName == tfDisplay(tf3) ? t3BodyConfirmed and t3BodyTime > bornTime and isBodyThroughValues(top, bot, dir, t3BodyHi, t3BodyLo) :
     tfName == tfDisplay(tf4) ? t4BodyConfirmed and t4BodyTime > bornTime and isBodyThroughValues(top, bot, dir, t4BodyHi, t4BodyLo) :
     tfName == tfDisplay(tf5) ? t5BodyConfirmed and t5BodyTime > bornTime and isBodyThroughValues(top, bot, dir, t5BodyHi, t5BodyLo) :
     tfName == tfDisplay(tf6) ? t6BodyConfirmed and t6BodyTime > bornTime and isBodyThroughValues(top, bot, dir, t6BodyHi, t6BodyLo) : false

zoneStateForTf(string tfName, int baseState) =>
    int state = baseState
    if array.size(zones) > 0
        for i = array.size(zones) - 1 to 0
            z = array.get(zones, i)
            if z.tfName == tfName and not z.inactive and not z.completed
                if tfBodyFilledForZone(z.tfName, z.top, z.bottom, z.dir, z.bornTime)
                    state := z.dir == 1 ? 2 : -2
                else
                    state := z.dir
    state

trimZonesForTf(string tfName) =>
    if array.size(zones) > 0
        int seen = 0
        for i = array.size(zones) - 1 to 0
            z = array.get(zones, i)
            if z.tfName == tfName and not z.inactive
                seen += 1
                if seen > maxZonesPerTf
                    disposeZone(z)
                    array.remove(zones, i)
    true

trimTotalZones() =>
    while array.size(zones) > maxTotalZones
        z = array.shift(zones)
        disposeZone(z)
    true

addZone(bool enabled, string tf, string biasSetting, float top, float bot, int dir, float target, int kind, int bornTime) =>
    bool added = false
    tfName = tfDisplay(tf)
    canDraw = enabled and tfAllowedOnChart(tf) and dir != 0 and not na(top) and not na(bot) and not na(target) and not na(bornTime) and biasAllows(biasSetting, dir) and not zoneExists(tfName, top, bot, dir, bornTime)

    if canDraw
        leftTime = useFixedZoneWidth ? zoneLeftTime(bornTime) : bornTime - int(timeframe.in_seconds(tf) * 1000)
        rightTime = zoneRightTime(bornTime)
        bx = box.new(leftTime, top, rightTime, bot, xloc = xloc.bar_time, bgcolor = zoneFillForTf(tfName), border_color = color.new(color.white, 100), border_width = 0)
        er = line.new(leftTime, target, rightTime, target, xloc = xloc.bar_time, color = showErlBeforeTap ? erlColor : color.new(erlColor, 100), width = 1, style = line.style_solid)
        borderColor = zoneBorderForTf(tfName)
        topLn = showZoneBorders ? line.new(leftTime, top, rightTime, top, xloc = xloc.bar_time, color = borderColor, width = 1, style = line.style_dashed) : na
        botLn = showZoneBorders ? line.new(leftTime, bot, rightTime, bot, xloc = xloc.bar_time, color = borderColor, width = 1, style = line.style_dashed) : na

        label lb = na
        if showZoneLabels
            labelTxt = dirIcon(dir) + " " + tfName + " " + kindName(kind)
            lb := label.new(rightTime, (top + bot) / 2.0, labelTxt, xloc = xloc.bar_time, color = color.new(color.black, 100), textcolor = zoneTextForTf(tfName), style = label.style_label_left, size = size.small)

        array.push(zones, OFZone.new(bx, er, topLn, botLn, lb, top, bot, target, dir, kind, tfName, tfRank(tf), bornTime, false, false, false))
        trimZonesForTf(tfName)
        trimTotalZones()
        added := true
    added

newT1 = showTf1 and tfAllowedOnChart(tf1) and not na(t1Born) and (na(t1Born[1]) or t1Born != t1Born[1] or t1Top != t1Top[1] or t1Bot != t1Bot[1] or t1Dir != t1Dir[1] or t1Kind != t1Kind[1])
newT2 = showTf2 and tfAllowedOnChart(tf2) and not na(t2Born) and (na(t2Born[1]) or t2Born != t2Born[1] or t2Top != t2Top[1] or t2Bot != t2Bot[1] or t2Dir != t2Dir[1] or t2Kind != t2Kind[1])
newT3 = showTf3 and tfAllowedOnChart(tf3) and not na(t3Born) and (na(t3Born[1]) or t3Born != t3Born[1] or t3Top != t3Top[1] or t3Bot != t3Bot[1] or t3Dir != t3Dir[1] or t3Kind != t3Kind[1])
newT4 = showTf4 and tfAllowedOnChart(tf4) and not na(t4Born) and (na(t4Born[1]) or t4Born != t4Born[1] or t4Top != t4Top[1] or t4Bot != t4Bot[1] or t4Dir != t4Dir[1] or t4Kind != t4Kind[1])
newT5 = showTf5 and tfAllowedOnChart(tf5) and not na(t5Born) and (na(t5Born[1]) or t5Born != t5Born[1] or t5Top != t5Top[1] or t5Bot != t5Bot[1] or t5Dir != t5Dir[1] or t5Kind != t5Kind[1])
newT6 = showTf6 and tfAllowedOnChart(tf6) and not na(t6Born) and (na(t6Born[1]) or t6Born != t6Born[1] or t6Top != t6Top[1] or t6Bot != t6Bot[1] or t6Dir != t6Dir[1] or t6Kind != t6Kind[1])

if newT1
    addZone(showTf1, tf1, biasTf1, t1Top, t1Bot, t1Dir, t1Target, t1Kind, t1Born)
if newT2
    addZone(showTf2, tf2, biasTf2, t2Top, t2Bot, t2Dir, t2Target, t2Kind, t2Born)
if newT3
    addZone(showTf3, tf3, biasTf3, t3Top, t3Bot, t3Dir, t3Target, t3Kind, t3Born)
if newT4
    addZone(showTf4, tf4, biasTf4, t4Top, t4Bot, t4Dir, t4Target, t4Kind, t4Born)
if newT5
    addZone(showTf5, tf5, biasTf5, t5Top, t5Bot, t5Dir, t5Target, t5Kind, t5Born)
if newT6
    addZone(showTf6, tf6, biasTf6, t6Top, t6Bot, t6Dir, t6Target, t6Kind, t6Born)

freshEntry = false
contextFailing = false
contextComplete = false

if array.size(zones) > 0
    for i = array.size(zones) - 1 to 0
        z = array.get(zones, i)

        if not z.inactive and not z.completed
            touched = isTouched(z.top, z.bottom) and time > z.bornTime
            failed = tfBodyFilledForZone(z.tfName, z.top, z.bottom, z.dir, z.bornTime)
            completed = isCompleted(z.target, z.dir)
            rightTime = zoneRightTime(z.bornTime)
            leftTime = zoneLeftTime(z.bornTime)
            removedZone = false

            if not z.mitigated
                box.set_left(z.b, leftTime)
                box.set_right(z.b, rightTime)
                line.set_x1(z.erl, leftTime)
                line.set_x2(z.erl, rightTime)
                if not na(z.topBorder)
                    line.set_x1(z.topBorder, leftTime)
                    line.set_x2(z.topBorder, rightTime)
                if not na(z.bottomBorder)
                    line.set_x1(z.bottomBorder, leftTime)
                    line.set_x2(z.bottomBorder, rightTime)
                if not na(z.tag)
                    label.set_x(z.tag, rightTime)

                if touched and not failed
                    freshEntry := true
                    z.mitigated := true
                    if changeColorWhenMitigated
                        box.set_bgcolor(z.b, zoneMitigatedCol)
                    line.set_color(z.erl, erlColor)
                    array.set(zones, i, z)
            else
                box.set_left(z.b, leftTime)
                box.set_right(z.b, rightTime)
                line.set_x1(z.erl, leftTime)
                line.set_x2(z.erl, rightTime)
                if not na(z.topBorder)
                    line.set_x1(z.topBorder, leftTime)
                    line.set_x2(z.topBorder, rightTime)
                if not na(z.bottomBorder)
                    line.set_x1(z.bottomBorder, leftTime)
                    line.set_x2(z.bottomBorder, rightTime)
                if not na(z.tag)
                    label.set_x(z.tag, rightTime)

            if not removedZone and failed
                contextFailing := true
                z.inactive := true
                disposeZone(z)
                array.remove(zones, i)
            else if not removedZone and completed and (z.mitigated or not showErlBeforeTap)
                contextComplete := true
                z.completed := true
                if keepCompleted
                    box.set_bgcolor(z.b, color.new(zoneFillCol, 95))
                    line.delete(z.erl)
                    if not na(z.topBorder)
                        line.delete(z.topBorder)
                    if not na(z.bottomBorder)
                        line.delete(z.bottomBorder)
                    if not na(z.tag)
                        label.delete(z.tag)
                    array.set(zones, i, z)
                else
                    disposeZone(z)
                    array.remove(zones, i)

//------------------------------------------------------------------------------
// Dashboard
//------------------------------------------------------------------------------
limitedDataWarning = t4Limited == 1 or t5Limited == 1 or t6Limited == 1
displayT1State = zoneStateForTf(tfDisplay(tf1), t1State)
displayT2State = zoneStateForTf(tfDisplay(tf2), t2State)
displayT3State = zoneStateForTf(tfDisplay(tf3), t3State)
displayT4State = zoneStateForTf(tfDisplay(tf4), t4State)
displayT5State = zoneStateForTf(tfDisplay(tf5), t5State)
displayT6State = zoneStateForTf(tfDisplay(tf6), t6State)

var table radar = table.new(position.bottom_right, 2, 10, bgcolor = color.new(color.black, 100), border_color = color.new(color.black, 100), border_width = 0)

if barstate.islast and showDashboard
    table.cell(radar, 0, 0, "orderflow", text_color = #8f96a3, text_size = size.small, bgcolor = color.new(color.black, 100))
    table.cell(radar, 1, 0, limitedDataWarning ? "limited data" : "", text_color = #8f96a3, text_size = size.small, bgcolor = color.new(color.black, 100))

    table.cell(radar, 0, 1, tfDisplay(tf1), text_color = zoneTextForTf(tfDisplay(tf1)), text_size = size.small, bgcolor = color.new(color.black, 100))
    table.cell(radar, 1, 1, statusText(displayT1State), text_color = dashboardStatusColor(tfDisplay(tf1), displayT1State), text_size = size.small, bgcolor = color.new(color.black, 100))
    table.cell(radar, 0, 2, tfDisplay(tf2), text_color = zoneTextForTf(tfDisplay(tf2)), text_size = size.small, bgcolor = color.new(color.black, 100))
    table.cell(radar, 1, 2, statusText(displayT2State), text_color = dashboardStatusColor(tfDisplay(tf2), displayT2State), text_size = size.small, bgcolor = color.new(color.black, 100))
    table.cell(radar, 0, 3, tfDisplay(tf3), text_color = zoneTextForTf(tfDisplay(tf3)), text_size = size.small, bgcolor = color.new(color.black, 100))
    table.cell(radar, 1, 3, statusText(displayT3State), text_color = dashboardStatusColor(tfDisplay(tf3), displayT3State), text_size = size.small, bgcolor = color.new(color.black, 100))
    table.cell(radar, 0, 4, tfDisplay(tf4), text_color = zoneTextForTf(tfDisplay(tf4)), text_size = size.small, bgcolor = color.new(color.black, 100))
    table.cell(radar, 1, 4, statusText(displayT4State), text_color = dashboardStatusColor(tfDisplay(tf4), displayT4State), text_size = size.small, bgcolor = color.new(color.black, 100))
    table.cell(radar, 0, 5, tfDisplay(tf5), text_color = zoneTextForTf(tfDisplay(tf5)), text_size = size.small, bgcolor = color.new(color.black, 100))
    table.cell(radar, 1, 5, statusText(displayT5State), text_color = dashboardStatusColor(tfDisplay(tf5), displayT5State), text_size = size.small, bgcolor = color.new(color.black, 100))
    table.cell(radar, 0, 6, tfDisplay(tf6), text_color = zoneTextForTf(tfDisplay(tf6)), text_size = size.small, bgcolor = color.new(color.black, 100))
    table.cell(radar, 1, 6, statusText(displayT6State), text_color = dashboardStatusColor(tfDisplay(tf6), displayT6State), text_size = size.small, bgcolor = color.new(color.black, 100))

    table.cell(radar, 0, 7, "", text_color = #8f96a3, text_size = size.small, bgcolor = color.new(color.black, 100))
    table.cell(radar, 1, 7, "reliability:", text_color = #8f96a3, text_size = size.small, bgcolor = color.new(color.black, 100))

    cr = chartRank()
    rel1Name = cr <= 1 ? tfDisplay(tf2) : cr == 2 ? tfDisplay(tf3) : cr == 3 ? tfDisplay(tf4) : cr == 4 ? tfDisplay(tf5) : tfDisplay(tf6)
    rel1Text = cr <= 1 ? ratioText(t2Follow, t2Total) : cr == 2 ? ratioText(t3Follow, t3Total) : cr == 3 ? ratioText(t4Follow, t4Total) : cr == 4 ? ratioText(t5Follow, t5Total) : ratioText(t6Follow, t6Total)
    rel2Name = cr <= 1 ? tfDisplay(tf3) : cr == 2 ? tfDisplay(tf4) : cr == 3 ? tfDisplay(tf5) : cr == 4 ? tfDisplay(tf6) : ""
    rel2Text = cr <= 1 ? ratioText(t3Follow, t3Total) : cr == 2 ? ratioText(t4Follow, t4Total) : cr == 3 ? ratioText(t5Follow, t5Total) : cr == 4 ? ratioText(t6Follow, t6Total) : ""

    table.cell(radar, 0, 8, rel1Name, text_color = zoneTextForTf(rel1Name), text_size = size.small, bgcolor = color.new(color.black, 100))
    table.cell(radar, 1, 8, rel1Text, text_color = zoneTextForTf(rel1Name), text_size = size.small, bgcolor = color.new(color.black, 100))
    table.cell(radar, 0, 9, rel2Name, text_color = zoneTextForTf(rel2Name), text_size = size.small, bgcolor = color.new(color.black, 100))
    table.cell(radar, 1, 9, rel2Text, text_color = zoneTextForTf(rel2Name), text_size = size.small, bgcolor = color.new(color.black, 100))

//------------------------------------------------------------------------------
// Killzones
//------------------------------------------------------------------------------
draw_session(bool active, string sessTime, color col, string name) =>
    var float sHi = na
    var float sLo = na
    var line hiL = na
    var line loL = na
    var int startIdx = na
    var bool inSessionPrev = false
    inSession = not na(time(timeframe.period, sessTime, tzInput))
    isStart = inSession and not inSessionPrev
    isEnd = not inSession and inSessionPrev
    inSessionPrev := inSession
    if active
        if isStart
            sHi := high
            sLo := low
            startIdx := bar_index
            hiL := line.new(bar_index, sHi, bar_index, sHi, color = col, width = 1)
            loL := line.new(bar_index, sLo, bar_index, sLo, color = col, width = 1)
        if inSession and not na(hiL) and not na(loL)
            sHi := na(sHi) ? high : math.max(high, sHi)
            sLo := na(sLo) ? low : math.min(low, sLo)
            line.set_y1(hiL, sHi)
            line.set_y2(hiL, sHi)
            line.set_x2(hiL, bar_index)
            line.set_y1(loL, sLo)
            line.set_y2(loL, sLo)
            line.set_x2(loL, bar_index)
        if isEnd and showSessLabels and not na(startIdx)
            label.new(startIdx, sHi, name + " Range", color = #00000000, textcolor = col, style = label.style_label_lower_left, size = size.small)

if timeframe.isintraday
    draw_session(showS1, s1_time, s1_color, s1_name)
    draw_session(showS2, s2_time, s2_color, s2_name)
    draw_session(showS3, s3_time, s3_color, s3_name)
    draw_session(showS4, s4_time, s4_color, s4_name)

//------------------------------------------------------------------------------
// HTF Liquidity Levels: Vanish After Sweep
//------------------------------------------------------------------------------
[pdh, pdl] = request.security(syminfo.tickerid, "D", [high[1], low[1]], lookahead = barmerge.lookahead_on)
[pwh, pwl] = request.security(syminfo.tickerid, "W", [high[1], low[1]], lookahead = barmerge.lookahead_on)
[pmh, pml] = request.security(syminfo.tickerid, "M", [high[1], low[1]], lookahead = barmerge.lookahead_on)

var line pdhL = na
var line pdlL = na
var label pdhLb = na
var label pdlLb = na
var line pwhL = na
var line pwlL = na
var label pwhLb = na
var label pwlLb = na
var line pmhL = na
var line pmlL = na
var label pmhLb = na
var label pmlLb = na

var bool pdhSwept = false
var bool pdlSwept = false
var bool pwhSwept = false
var bool pwlSwept = false
var bool pmhSwept = false
var bool pmlSwept = false

newDay = timeframe.change("D")
newWeek = timeframe.change("W")
newMonth = timeframe.change("M")

if newDay
    pdhSwept := false
    pdlSwept := false
    line.delete(pdhL)
    line.delete(pdlL)
    label.delete(pdhLb)
    label.delete(pdlLb)
    pdhL := na
    pdlL := na
    pdhLb := na
    pdlLb := na

if newWeek
    pwhSwept := false
    pwlSwept := false
    line.delete(pwhL)
    line.delete(pwlL)
    label.delete(pwhLb)
    label.delete(pwlLb)
    pwhL := na
    pwlL := na
    pwhLb := na
    pwlLb := na

if newMonth
    pmhSwept := false
    pmlSwept := false
    line.delete(pmhL)
    line.delete(pmlL)
    label.delete(pmhLb)
    label.delete(pmlLb)
    pmhL := na
    pmlL := na
    pmhLb := na
    pmlLb := na

if showPD and not pdhSwept and high >= pdh
    pdhSwept := true
    line.delete(pdhL)
    label.delete(pdhLb)
    pdhL := na
    pdhLb := na

if showPD and not pdlSwept and low <= pdl
    pdlSwept := true
    line.delete(pdlL)
    label.delete(pdlLb)
    pdlL := na
    pdlLb := na

if showPW and not pwhSwept and high >= pwh
    pwhSwept := true
    line.delete(pwhL)
    label.delete(pwhLb)
    pwhL := na
    pwhLb := na

if showPW and not pwlSwept and low <= pwl
    pwlSwept := true
    line.delete(pwlL)
    label.delete(pwlLb)
    pwlL := na
    pwlLb := na

if showPM and not pmhSwept and high >= pmh
    pmhSwept := true
    line.delete(pmhL)
    label.delete(pmhLb)
    pmhL := na
    pmhLb := na

if showPM and not pmlSwept and low <= pml
    pmlSwept := true
    line.delete(pmlL)
    label.delete(pmlLb)
    pmlL := na
    pmlLb := na

if barstate.islast
    if showPD and not pdhSwept and na(pdhL)
        pdhL := line.new(bar_index, pdh, bar_index + 10, pdh, color = chart.fg_color, style = get_line_style(lineStyle), extend = extend.right)
        pdhLb := label.new(bar_index + 10, pdh, "PD H: " + str.tostring(pdh, format.mintick), color = #00000000, textcolor = chart.fg_color, style = label.style_label_lower_left, size = size.small)
    if showPD and not pdlSwept and na(pdlL)
        pdlL := line.new(bar_index, pdl, bar_index + 10, pdl, color = chart.fg_color, style = get_line_style(lineStyle), extend = extend.right)
        pdlLb := label.new(bar_index + 10, pdl, "PD L: " + str.tostring(pdl, format.mintick), color = #00000000, textcolor = chart.fg_color, style = label.style_label_lower_left, size = size.small)
    if showPW and not pwhSwept and na(pwhL)
        pwhL := line.new(bar_index, pwh, bar_index + 15, pwh, color = #5b9cf6, style = get_line_style(lineStyle), extend = extend.right)
        pwhLb := label.new(bar_index + 15, pwh, "PW H: " + str.tostring(pwh, format.mintick), color = #00000000, textcolor = #5b9cf6, style = label.style_label_lower_left, size = size.small)
    if showPW and not pwlSwept and na(pwlL)
        pwlL := line.new(bar_index, pwl, bar_index + 15, pwl, color = #5b9cf6, style = get_line_style(lineStyle), extend = extend.right)
        pwlLb := label.new(bar_index + 15, pwl, "PW L: " + str.tostring(pwl, format.mintick), color = #00000000, textcolor = #5b9cf6, style = label.style_label_lower_left, size = size.small)
    if showPM and not pmhSwept and na(pmhL)
        pmhL := line.new(bar_index, pmh, bar_index + 20, pmh, color = #ff9800, style = get_line_style(lineStyle), extend = extend.right)
        pmhLb := label.new(bar_index + 20, pmh, "PM H: " + str.tostring(pmh, format.mintick), color = #00000000, textcolor = #ff9800, style = label.style_label_lower_left, size = size.small)
    if showPM and not pmlSwept and na(pmlL)
        pmlL := line.new(bar_index, pml, bar_index + 20, pml, color = #ff9800, style = get_line_style(lineStyle), extend = extend.right)
        pmlLb := label.new(bar_index + 20, pml, "PM L: " + str.tostring(pml, format.mintick), color = #00000000, textcolor = #ff9800, style = label.style_label_lower_left, size = size.small)

//------------------------------------------------------------------------------
// Alerts
//------------------------------------------------------------------------------
alertcondition(alertFreshIrl and freshEntry, "Fresh IRL Entry", "Price entered a fresh IRL/FVG/BAG zone.")
alertcondition(alertFailing and contextFailing, "IRL Failing", "Active IRL context failed by body close through the zone.")
alertcondition(alertCompleted and contextComplete, "ERL Completed", "ERL boundary reached after active context.")
````
