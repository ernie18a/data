# Day Trade Setup - FVG Finder

- url: https://www.tradingview.com/script/oyOEBMLF-Day-Trade-Setup-FVG-Finder/
- type: indicator
- pine_id: PUB;be0d8f17ee204592b25f041dc098f727
- version: 1.0

## Description

Day Trade Setup - FVG Finder

Day Trade Setup - FVG Finder is a Fair Value Gap detection tool designed to identify bullish and bearish price imbalances directly on the chart.

The indicator scans both the current chart timeframe and a user-selected higher timeframe, then displays active FVG zones as colored boxes with optional price labels. Zones remain visible until they are mitigated or, for chart-timeframe zones, expire after the selected lookback period.

How It Works

A bullish Fair Value Gap is detected when the low of the current candle is above the high from two candles earlier, creating an untraded price area between them.

A bearish Fair Value Gap is detected when the high of the current candle is below the low from two candles earlier.

The script measures the size of each gap in points and displays only the zones that meet the minimum gap-distance setting selected by the user.

All chart-timeframe FVG calculations are confirmed after the candle closes.

Main Features
Detects bullish and bearish Fair Value Gaps
Displays FVG zones directly on the chart
Adjustable minimum FVG gap size
Customizable bullish and bearish zone colors
Adjustable zone transparency
Automatic extension of active zones
Automatic removal when a zone is mitigated
Optional expiration of older chart-timeframe zones
Higher-timeframe FVG detection
Adjustable higher-timeframe gap threshold
Optional price labels for the upper and lower edges of each zone
Light and dark chart-theme support
Alerts for new and mitigated FVG zones
Current Timeframe FVG Zones

The indicator scans the active chart timeframe for three-candle price imbalances.

When a valid bullish or bearish FVG is detected, the zone is drawn from the originating candle area and extended to the right.

Chart-timeframe zones remain active until:

Price closes beyond the opposite boundary of the zone, or
The zone exceeds the selected historical bar limit

For a bullish FVG, the zone is considered mitigated when price closes below its lower boundary.

For a bearish FVG, the zone is considered mitigated when price closes above its upper boundary.

Higher-Timeframe FVG Zones

Users can enable Multi-Timeframe FVG detection and select a separate higher timeframe.

Higher-timeframe zones are calculated using completed higher-timeframe candles to reduce changes caused by an unfinished candle.

HTF zones are displayed on the current chart and continue extending until price closes beyond their mitigation boundary.

This allows traders to monitor broader price imbalances without switching between multiple charts.

FVG Gap Filter

The FVG GAP (Point) setting controls the minimum size required for a chart-timeframe imbalance to be displayed.

The HTF FVG GAP (Point) setting applies the same type of filter to higher-timeframe zones.

Increasing these values reduces the number of smaller gaps shown on the chart, while lowering them allows the indicator to display more zones.

The correct point value may vary depending on the symbol, broker, and minimum tick size.

Price Tags

Optional price tags can be displayed at the upper and lower boundaries of every FVG zone.

Users can choose to:

Match the tag color with the bullish or bearish zone
Automatically adjust the tag color for light or dark charts
Select custom background and text colors
Change the tag-text size

These labels help users read the exact zone boundaries without manually checking the price scale.

Alerts

The indicator provides alert conditions for:

New Bullish FVG
New Bearish FVG
Bullish FVG Mitigated
Bearish FVG Mitigated
New Bullish Higher-Timeframe FVG
New Bearish Higher-Timeframe FVG
Bullish Higher-Timeframe FVG Mitigated
Bearish Higher-Timeframe FVG Mitigated

After adding the indicator to the chart, users can create TradingView alerts for any of these conditions.

Suggested Use

FVG zones may be used as areas of interest for:

Pullbacks
Rebalancing of price imbalances
Support and resistance context
Trend-continuation setups
Liquidity and market-structure analysis
Multi-timeframe confluence

The indicator does not generate direct Buy or Sell entries. Traders should evaluate each zone together with market structure, trend direction, liquidity, volatility, trading session, and personal risk-management rules.

Limitations

Fair Value Gaps do not guarantee that price will return to a zone or react from it.

During volatile market conditions, multiple zones may form within a short period. Some zones may be mitigated immediately, while others may remain active for an extended time.

Mitigation is determined using candle closes beyond the selected zone boundary. Intrabar price movement alone does not remove a zone.

Higher-timeframe zones are based on completed higher-timeframe candles, so they appear only after the relevant candle has closed.

Historical zones may also be limited by TradingView drawing-object limits and the selected lookback settings.

Disclaimer

Day Trade Setup - FVG Finder is provided for technical analysis and educational purposes only.

It does not provide financial advice, investment advice, trade recommendations, or guaranteed trading results. Fair Value Gap zones are reference areas only and should not be used as standalone entry signals.

Users are responsible for independently evaluating market conditions and applying appropriate risk management before trading with real funds.

## Source Code

````pine
//@version=6
// =====================================================================
// Copyright © Daytradesetup. All rights reserved.
// =====================================================================
indicator("Day Trade Setup - FVG Finder", overlay = true, max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500)

// ---------------- Core inputs (same as original MQL5 "input" variables) ----------------
FVG_DIS = input.int(1000, title = "FVG GAP (Point)", group = "FVG Zone")
barback = input.int(100, title = "Find FVG Back", group = "FVG Zone")
bclr    = input.color(color.new(#1547F0, 0), title = "FVG Buy Color", group = "FVG Zone")   // Day Trade Setup blue
sclr    = input.color(color.new(#C724B1, 0), title = "FVG Sell Color", group = "FVG Zone")  // Day Trade Setup magenta
boxOpacity = input.int(75, title = "Box Fill Transparency %", minval = 0, maxval = 95, group = "FVG Zone")
boxFillBuy  = color.new(bclr, boxOpacity)
boxFillSell = color.new(sclr, boxOpacity)

// ---------------- Theme ----------------
theme = input.string("Dark", title = "Chart Theme", options = ["Light", "Dark"], group = "Theme")
isLightTheme = theme == "Light"

// ---------------- Axis-style price tags (top/bottom edge) ----------------
showAxisTags       = input.bool(true, title = "Show Axis Tags (Top/Bottom)", group = "Axis Tags")
axisTagMatchZone   = input.bool(true, title = "Match Zone Color (Buy/Sell)", group = "Axis Tags")
axisTagAutoColor   = input.bool(true, title = "Auto Color by Theme (when Match Zone is off)", group = "Axis Tags")
axisTagBgColorIn   = input.color(color.white, title = "Tag Background Color (used when Auto/Match is off)", group = "Axis Tags")
axisTagTextColorIn = input.color(color.black, title = "Tag Text Color (used when Auto/Match is off)", group = "Axis Tags")
axisTagSizeInput   = input.string("Tiny", title = "Tag Text Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = "Axis Tags")

// ---------------- Multi-timeframe FVG ----------------
showHtfZones  = input.bool(true, title = "Show Higher Timeframe (HTF) FVG Zones", group = "Multi-Timeframe FVG (MTF)")
htfRes        = input.timeframe("60", title = "HTF Timeframe", group = "Multi-Timeframe FVG (MTF)")
FVG_DIS_HTF   = input.int(1000, title = "HTF FVG GAP (Point)", group = "Multi-Timeframe FVG (MTF)")
htfBoxOpacity = input.int(60, title = "HTF Box Fill Transparency %", minval = 0, maxval = 95, group = "Multi-Timeframe FVG (MTF)")
htfBoxFillBuy  = color.new(bclr, htfBoxOpacity)
htfBoxFillSell = color.new(sclr, htfBoxOpacity)

// ---------------- Resolve style values ----------------
f_size(s) =>
    sz = s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Normal" ? size.normal : s == "Large" ? size.large : size.huge
    sz

axisSz  = f_size(axisTagSizeInput)

axisBgAuto      = axisTagAutoColor ? (isLightTheme ? color.new(color.white, 0) : color.new(color.black, 0)) : axisTagBgColorIn
axisTextAuto    = axisTagAutoColor ? (isLightTheme ? color.black : color.white) : axisTagTextColorIn

axisBgBuy    = axisTagMatchZone ? bclr : axisBgAuto
axisBgSell   = axisTagMatchZone ? sclr : axisBgAuto
axisTextBuy  = axisTagMatchZone ? color.white : axisTextAuto
axisTextSell = axisTagMatchZone ? color.white : axisTextAuto


// ---------------- Internal constants (plain globals in MQL5, not inputs) ----------------
rayBar  = 1                 // MQL5 "ray_bar"
rayBars = 45 + rayBar       // right-edge projection, same as "45+ray_bar"

// ---------------- Persistent storage for active FVG zones (chart timeframe) ----------------
var bullBox    = array.new<box>()
var bullTopTag = array.new<label>()
var bullBotTag = array.new<label>()
var bullTop    = array.new<float>()
var bullBot    = array.new<float>()
var bullForm   = array.new<int>()

var bearBox    = array.new<box>()
var bearTopTag = array.new<label>()
var bearBotTag = array.new<label>()
var bearTop    = array.new<float>()
var bearBot    = array.new<float>()
var bearForm   = array.new<int>()

// ---------------- Persistent storage for active FVG zones (HTF) ----------------
var bullHtfBox    = array.new<box>()
var bullHtfTopTag = array.new<label>()
var bullHtfBotTag = array.new<label>()
var bullHtfTop    = array.new<float>()
var bullHtfBot    = array.new<float>()

var bearHtfBox    = array.new<box>()
var bearHtfTopTag = array.new<label>()
var bearHtfBotTag = array.new<label>()
var bearHtfTop    = array.new<float>()
var bearHtfBot    = array.new<float>()

// ---------------- FVG detection (current bar vs. 2 bars back) ----------------
pb1 = low[0]
pb2 = high[2]
fvgb_dis = math.abs(pb1 - pb2) / syminfo.mintick

ps1 = high[0]
ps2 = low[2]
fvgs_dis = math.abs(ps2 - ps1) / syminfo.mintick

// ---------------- HTF FVG detection ----------------
// index 0 on the security series is the still-forming HTF bar, so index 1 is
// the last CLOSED htf bar ("current" for our comparison) and index 3 is the
// closed htf bar 2 back from it ("far" candle) — mirrors low[0]/high[2] above.
[htfBarTime, htfFarTime, htfLow1, htfHigh3, htfHigh1, htfLow3] = request.security(syminfo.tickerid, htfRes,
     [time[1], time[3], low[1], high[3], high[1], low[3]], lookahead = barmerge.lookahead_off)

var float lastHtfBarTime = na
isNewHtfBar = showHtfZones and not na(htfBarTime) and not na(htfFarTime) and htfBarTime != lastHtfBarTime

pb1_htf = htfLow1
pb2_htf = htfHigh3
fvgb_dis_htf = math.abs(pb1_htf - pb2_htf) / syminfo.mintick

ps1_htf = htfHigh1
ps2_htf = htfLow3
fvgs_dis_htf = math.abs(ps2_htf - ps1_htf) / syminfo.mintick

// ---------------- helper: mitigate / expire / extend existing zones (chart timeframe) ----------------
manageZones(boxArr, topTagArr, botTagArr, topArr, botArr, formArr, isBull) =>
    mitigatedAny = false
    i = array.size(boxArr) - 1
    while i >= 0
        top       = array.get(topArr, i)
        bot       = array.get(botArr, i)
        formBar   = array.get(formArr, i)
        mitigated = isBull ? close < bot : close > top
        expired   = (bar_index - formBar) > barback
        if mitigated or expired
            if mitigated
                mitigatedAny := true
            box.delete(array.get(boxArr, i))
            topTagId = array.get(topTagArr, i)
            if not na(topTagId)
                label.delete(topTagId)
            botTagId = array.get(botTagArr, i)
            if not na(botTagId)
                label.delete(botTagId)
            array.remove(boxArr, i)
            array.remove(topTagArr, i)
            array.remove(botTagArr, i)
            array.remove(topArr, i)
            array.remove(botArr, i)
            array.remove(formArr, i)
        else
            rightEdge = bar_index + rayBars
            box.set_right(array.get(boxArr, i), rightEdge)
            topTagId2 = array.get(topTagArr, i)
            if not na(topTagId2)
                label.set_x(topTagId2, rightEdge)
            botTagId2 = array.get(botTagArr, i)
            if not na(botTagId2)
                label.set_x(botTagId2, rightEdge)
        i := i - 1
    mitigatedAny

// ---------------- helper: mitigate / extend existing zones (HTF) ----------------
// HTF zones use xloc.bar_time (drawn from the HTF far-candle's open time to
// "now") so no chart-bar_index bookkeeping is needed; only mitigation is
// checked here — there is no bar-count expiry for HTF zones.
manageHtfZones(boxArr, topTagArr, botTagArr, topArr, botArr, isBull) =>
    mitigatedAny = false
    i = array.size(boxArr) - 1
    while i >= 0
        top       = array.get(topArr, i)
        bot       = array.get(botArr, i)
        mitigated = isBull ? close < bot : close > top
        if mitigated
            mitigatedAny := true
            box.delete(array.get(boxArr, i))
            topTagId = array.get(topTagArr, i)
            if not na(topTagId)
                label.delete(topTagId)
            botTagId = array.get(botTagArr, i)
            if not na(botTagId)
                label.delete(botTagId)
            array.remove(boxArr, i)
            array.remove(topTagArr, i)
            array.remove(botTagArr, i)
            array.remove(topArr, i)
            array.remove(botArr, i)
        else
            box.set_right(array.get(boxArr, i), time)
            topTagId2 = array.get(topTagArr, i)
            if not na(topTagId2)
                label.set_x(topTagId2, time)
            botTagId2 = array.get(botTagArr, i)
            if not na(botTagId2)
                label.set_x(botTagId2, time)
        i := i - 1
    mitigatedAny

// ---------------- alert trigger flags (reset every bar) ----------------
bullFvgNew          = false
bearFvgNew           = false
bullFvgMitigated     = false
bearFvgMitigated     = false
bullHtfFvgNew        = false
bearHtfFvgNew        = false
bullHtfFvgMitigated  = false
bearHtfFvgMitigated  = false

// ---------------- main (only on new/confirmed bar, like rates_total>prev_calculated) ----------------
if barstate.isconfirmed
    bullFvgMitigated := manageZones(bullBox, bullTopTag, bullBotTag, bullTop, bullBot, bullForm, true)
    bearFvgMitigated := manageZones(bearBox, bearTopTag, bearBotTag, bearTop, bearBot, bearForm, false)
    bullHtfFvgMitigated := manageHtfZones(bullHtfBox, bullHtfTopTag, bullHtfBotTag, bullHtfTop, bullHtfBot, true)
    bearHtfFvgMitigated := manageHtfZones(bearHtfBox, bearHtfTopTag, bearHtfBotTag, bearHtfTop, bearHtfBot, false)

    // ---- new bullish FVG (chart timeframe) ----
    if pb1 > pb2 and fvgb_dis >= FVG_DIS
        leftBar   = bar_index - 2
        formBar   = bar_index
        rightEdge = bar_index + rayBars

        newBox    = box.new(leftBar, pb1, rightEdge, pb2, bclr, 1, line.style_solid, extend.none, xloc.bar_index, boxFillBuy)
        newTopTag = showAxisTags ? label.new(rightEdge, pb1, str.tostring(pb1, format.mintick), xloc.bar_index, yloc.price, axisBgBuy, label.style_label_left, axisTextBuy, axisSz) : na
        newBotTag = showAxisTags ? label.new(rightEdge, pb2, str.tostring(pb2, format.mintick), xloc.bar_index, yloc.price, axisBgBuy, label.style_label_left, axisTextBuy, axisSz) : na

        array.push(bullBox, newBox)
        array.push(bullTopTag, newTopTag)
        array.push(bullBotTag, newBotTag)
        array.push(bullTop, pb1)
        array.push(bullBot, pb2)
        array.push(bullForm, formBar)
        bullFvgNew := true

    // ---- new bearish FVG (chart timeframe) ----
    if ps1 < ps2 and fvgs_dis >= FVG_DIS
        leftBar   = bar_index - 2
        formBar   = bar_index
        rightEdge = bar_index + rayBars

        newBox    = box.new(leftBar, ps2, rightEdge, ps1, sclr, 1, line.style_solid, extend.none, xloc.bar_index, boxFillSell)
        newTopTag = showAxisTags ? label.new(rightEdge, ps2, str.tostring(ps2, format.mintick), xloc.bar_index, yloc.price, axisBgSell, label.style_label_left, axisTextSell, axisSz) : na
        newBotTag = showAxisTags ? label.new(rightEdge, ps1, str.tostring(ps1, format.mintick), xloc.bar_index, yloc.price, axisBgSell, label.style_label_left, axisTextSell, axisSz) : na

        array.push(bearBox, newBox)
        array.push(bearTopTag, newTopTag)
        array.push(bearBotTag, newBotTag)
        array.push(bearTop, ps2)
        array.push(bearBot, ps1)
        array.push(bearForm, formBar)
        bearFvgNew := true

    // ---- new bullish / bearish FVG (HTF) — only once per newly closed HTF bar ----
    if isNewHtfBar
        lastHtfBarTime := htfBarTime

        if pb1_htf > pb2_htf and fvgb_dis_htf >= FVG_DIS_HTF
            newHtfBox    = box.new(htfFarTime, pb1_htf, time, pb2_htf, bclr, 2, line.style_solid, extend.none, xloc.bar_time, htfBoxFillBuy)
            newHtfTopTag = showAxisTags ? label.new(time, pb1_htf, str.tostring(pb1_htf, format.mintick), xloc.bar_time, yloc.price, axisBgBuy, label.style_label_left, axisTextBuy, axisSz) : na
            newHtfBotTag = showAxisTags ? label.new(time, pb2_htf, str.tostring(pb2_htf, format.mintick), xloc.bar_time, yloc.price, axisBgBuy, label.style_label_left, axisTextBuy, axisSz) : na

            array.push(bullHtfBox, newHtfBox)
            array.push(bullHtfTopTag, newHtfTopTag)
            array.push(bullHtfBotTag, newHtfBotTag)
            array.push(bullHtfTop, pb1_htf)
            array.push(bullHtfBot, pb2_htf)
            bullHtfFvgNew := true

        if ps1_htf < ps2_htf and fvgs_dis_htf >= FVG_DIS_HTF
            newHtfBox    = box.new(htfFarTime, ps2_htf, time, ps1_htf, sclr, 2, line.style_solid, extend.none, xloc.bar_time, htfBoxFillSell)
            newHtfTopTag = showAxisTags ? label.new(time, ps2_htf, str.tostring(ps2_htf, format.mintick), xloc.bar_time, yloc.price, axisBgSell, label.style_label_left, axisTextSell, axisSz) : na
            newHtfBotTag = showAxisTags ? label.new(time, ps1_htf, str.tostring(ps1_htf, format.mintick), xloc.bar_time, yloc.price, axisBgSell, label.style_label_left, axisTextSell, axisSz) : na

            array.push(bearHtfBox, newHtfBox)
            array.push(bearHtfTopTag, newHtfTopTag)
            array.push(bearHtfBotTag, newHtfBotTag)
            array.push(bearHtfTop, ps2_htf)
            array.push(bearHtfBot, ps1_htf)
            bearHtfFvgNew := true

// ---------------- Alerts ----------------
alertcondition(bullFvgNew, title = "New Bullish FVG", message = "New Bullish FVG formed on {{ticker}} {{interval}} at {{close}}")
alertcondition(bearFvgNew, title = "New Bearish FVG", message = "New Bearish FVG formed on {{ticker}} {{interval}} at {{close}}")
alertcondition(bullFvgMitigated, title = "Bullish FVG Mitigated", message = "Bullish FVG mitigated on {{ticker}} {{interval}} at {{close}}")
alertcondition(bearFvgMitigated, title = "Bearish FVG Mitigated", message = "Bearish FVG mitigated on {{ticker}} {{interval}} at {{close}}")
alertcondition(bullHtfFvgNew, title = "New Bullish HTF FVG", message = "New Bullish HTF FVG formed on {{ticker}} at {{close}}")
alertcondition(bearHtfFvgNew, title = "New Bearish HTF FVG", message = "New Bearish HTF FVG formed on {{ticker}} at {{close}}")
alertcondition(bullHtfFvgMitigated, title = "Bullish HTF FVG Mitigated", message = "Bullish HTF FVG mitigated on {{ticker}} at {{close}}")
alertcondition(bearHtfFvgMitigated, title = "Bearish HTF FVG Mitigated", message = "Bearish HTF FVG mitigated on {{ticker}} at {{close}}")
````
