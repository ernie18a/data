# Daily/Weekly EMA or SMA w Colour Selector

- url: https://www.tradingview.com/script/HvXies3C-Daily-Weekly-EMA-or-SMA-w-Colour-Selector/
- type: indicator
- pine_id: PUB;8cf1943f964943ecb15b5870c52ffa54
- version: 1.0

## Description

Took pavankjadda 'Daily/Weekly EMA or SMA' and added a colour selector for the MA's. Use this to see the daily/weekly MA's on lower timeframes.

## Source Code

````pine
//@version=6
indicator("Daily/Weekly EMA or SMA", shorttitle="Daily/Weekly EMA or SMA", overlay=true, max_labels_count=22, max_lines_count=14)

// === MA SETTINGS (per-MA type selection) ===
group_ma = "MA Settings"
maType1 = input.string("EMA", "MA 1 Type", options=["EMA", "SMA"], group=group_ma)
maLen1  = input.int(5,   "MA 1 Length", group=group_ma)
maType2 = input.string("EMA", "MA 2 Type", options=["EMA", "SMA"], group=group_ma)
maLen2  = input.int(8,   "MA 2 Length", group=group_ma)
maType3 = input.string("EMA", "MA 3 Type", options=["EMA", "SMA"], group=group_ma)
maLen3  = input.int(21,  "MA 3 Length", group=group_ma)
maType4 = input.string("EMA", "MA 4 Type", options=["EMA", "SMA"], group=group_ma)
maLen4  = input.int(50,  "MA 4 Length", group=group_ma)
maType5 = input.string("SMA", "MA 5 Type", options=["EMA", "SMA"], group=group_ma)
maLen5  = input.int(100, "MA 5 Length", group=group_ma)
maType6 = input.string("SMA", "MA 6 Type", options=["EMA", "SMA"], group=group_ma)
maLen6  = input.int(200, "MA 6 Length", group=group_ma)

group_htf = "HTF data"
htfLookaheadOn = input.bool(true, "HTF lookahead (repaints)", group=group_htf, tooltip="On: higher-timeframe MAs include the developing period (smoother, can repaint on intraday). Off: non-repainting style; better for alerts and backtests.")

// === DAILY VISIBILITY ===
group_daily = "Daily MAs"
showDaily1 = input.bool(false, "Show Daily MA 1", group=group_daily)
showDaily2 = input.bool(true,  "Show Daily MA 2", group=group_daily)
showDaily3 = input.bool(true,  "Show Daily MA 3", group=group_daily)
showDaily4 = input.bool(false, "Show Daily MA 4", group=group_daily)
showDaily5 = input.bool(false, "Show Daily MA 5", group=group_daily)
showDaily6 = input.bool(false, "Show Daily MA 6", group=group_daily)

// === WEEKLY VISIBILITY ===
group_weekly = "Weekly MAs"
showW1 = input.bool(false, "Show Weekly MA 1", group=group_weekly)
showW2 = input.bool(false, "Show Weekly MA 2", group=group_weekly)
showW3 = input.bool(false, "Show Weekly MA 3", group=group_weekly)
showW4 = input.bool(false, "Show Weekly MA 4", group=group_weekly)
showW5 = input.bool(false, "Show Weekly MA 5", group=group_weekly)
showW6 = input.bool(false, "Show Weekly MA 6", group=group_weekly)

// === SLOPE COLORING ===
group_slope = "Slope Coloring"
enableSlopeColor  = input.bool(false, "Enable Slope-Based MA Coloring", group=group_slope, tooltip="MA lines turn green when rising, red when falling")
slopeRisingColor  = input.color(#26a69a, "Rising Color",  group=group_slope)
slopeFallingColor = input.color(#ef5350, "Falling Color", group=group_slope)

// === MA RIBBON ===
group_ribbon = "MA Ribbon"
enableRibbon       = input.bool(false, "Enable MA Ribbon Fill", group=group_ribbon, tooltip="Fills between consecutive daily MAs to form a ribbon")
ribbonTransparency = input.int(85, "Ribbon Transparency", minval=0, maxval=100, group=group_ribbon)

// === PRICE DISTANCE ===
group_dist = "Price Distance"
showPriceDistance = input.bool(false, "Show Price Distance % in Labels", group=group_dist, tooltip="Appends percentage distance from current price to each MA in labels")

// === MA CONFLUENCE ===
group_confluence = "MA Confluence"
enableConfluence     = input.bool(false, "Highlight MA Confluence Zones", group=group_confluence, tooltip="Highlights background when multiple MAs cluster together")
confluenceTf         = input.string("Daily", "Confluence source", options=["Daily", "Weekly", "Daily or Weekly"], group=group_confluence, tooltip="Which timeframe(s) contribute to the cluster check")
confluenceThreshold  = input.float(1.0, "Confluence Threshold %", minval=0.1, maxval=10.0, step=0.1, group=group_confluence, tooltip="Max spread between MAs as % of price")
confluenceMinMAs     = input.int(3, "Min MAs for Confluence", minval=2, maxval=6, group=group_confluence)
confluenceColor      = input.color(color.yellow, "Confluence Highlight Color", group=group_confluence)
confluenceTransp     = input.int(90, "Confluence Transparency", minval=0, maxval=100, group=group_confluence)

// === BAR COLORING ===
group_barclr = "Bar Coloring"
enableBarColor = input.bool(false, "Enable Bar Coloring", group=group_barclr, tooltip="Colors bars based on price position relative to a selected MA")
barColorTf     = input.string("Daily", "Bar color reference", options=["Daily", "Weekly", "Auto"], group=group_barclr, tooltip="Auto: Weekly MA on weekly charts, otherwise Daily")
barColorSlot   = input.int(3, "Reference MA slot (1-6)", minval=1, maxval=6, group=group_barclr)
barBullColor   = input.color(#26a69a, "Bar Bullish Color", group=group_barclr)
barBearColor   = input.color(#ef5350, "Bar Bearish Color", group=group_barclr)

// === LABEL OPTIONS ===
group_labels = "Label Options"
hideLabelsOnDWCharts = input.bool(true, "Hide labels on Daily / Weekly chart timeframe", group=group_labels, tooltip="When on, labels and tail lines are hidden on D and W interval charts to reduce clutter")
labelOffsetBars    = input.int(0, "Label Offset (bars)", minval=-50, maxval=200, tooltip="Horizontal offset from the latest bar for labels", group=group_labels)
labelOffsetTicksY  = input.int(0, "Label Vertical Offset (ticks)", minval=-100, maxval=100, tooltip="Vertical offset in ticks (positive = above line)", group=group_labels)
placeLabelsFarRight = input.bool(true, "Place labels near right edge", group=group_labels)
farRightBars       = input.int(30, "Far-right bars (approx)", minval=1, maxval=500, group=group_labels)
labelSizeInput     = input.string("Normal", "Label size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=group_labels)

// === DISPLAY ===
group_display = "Display"
plotLineWidth = input.int(1, "MA line width", minval=1, maxval=4, group=group_display)
tailLineWidth = input.int(1, "Tail line width", minval=1, maxval=4, group=group_display)

// === ALERTS ===
group_alerts = "Alerts"
enableAlerts        = input.bool(false, "Enable alerts", group=group_alerts)
alertMaSlot         = input.int(3, "Alert MA slot (1-6)", minval=1, maxval=6, group=group_alerts)
alertDailyCrossAbove = input.bool(false, "Price cross above Daily MA (slot)", group=group_alerts)
alertDailyCrossBelow = input.bool(false, "Price cross below Daily MA (slot)", group=group_alerts)
alertWeeklyCrossAbove = input.bool(false, "Price cross above Weekly MA (slot)", group=group_alerts)
alertWeeklyCrossBelow = input.bool(false, "Price cross below Weekly MA (slot)", group=group_alerts)
alertConfluenceOn   = input.bool(false, "Confluence zone entered", group=group_alerts)
alertConfluenceOff  = input.bool(false, "Confluence zone exited", group=group_alerts)
alertNewChartDay    = input.bool(false, "New calendar day (chart)", group=group_alerts, tooltip="Fires when the chart session date changes; useful on intraday charts")

// === FUNCTIONS ===
getMA(src, len, typ) =>
    typ == "EMA" ? ta.ema(src, len) : ta.sma(src, len)

f_packMas() =>
    [getMA(close, maLen1, maType1), getMA(close, maLen2, maType2), getMA(close, maLen3, maType3), getMA(close, maLen4, maType4), getMA(close, maLen5, maType5), getMA(close, maLen6, maType6)]

lookaheadMode = htfLookaheadOn ? barmerge.lookahead_on : barmerge.lookahead_off

[dailyMA1, dailyMA2, dailyMA3, dailyMA4, dailyMA5, dailyMA6] = request.security(syminfo.tickerid, "D", f_packMas(), gaps=barmerge.gaps_off, lookahead=lookaheadMode)
[maW1, maW2, maW3, maW4, maW5, maW6] = request.security(syminfo.tickerid, "W", f_packMas(), gaps=barmerge.gaps_off, lookahead=lookaheadMode)

// === INTERVAL-AWARE VISIBILITY ===
isWeeklyInterval = timeframe.isweekly
hideLabelsByInterval = hideLabelsOnDWCharts and (timeframe.isdaily or timeframe.isweekly)

showDaily1Eff = showDaily1 and not isWeeklyInterval
showDaily2Eff = showDaily2 and not isWeeklyInterval
showDaily3Eff = showDaily3 and not isWeeklyInterval
showDaily4Eff = showDaily4 and not isWeeklyInterval
showDaily5Eff = showDaily5 and not isWeeklyInterval
showDaily6Eff = showDaily6 and not isWeeklyInterval

showW1Eff = showW1
showW2Eff = showW2 or isWeeklyInterval
showW3Eff = showW3 or isWeeklyInterval
showW4Eff = showW4 or isWeeklyInterval
showW5Eff = showW5 or isWeeklyInterval
showW6Eff = showW6 or isWeeklyInterval

// === SERIES ARRAYS (for loops / confluence / alerts) ===
dailyMArr = array.from(dailyMA1, dailyMA2, dailyMA3, dailyMA4, dailyMA5, dailyMA6)
weeklyMArr = array.from(maW1, maW2, maW3, maW4, maW5, maW6)

showDailyEffArr = array.from(showDaily1Eff, showDaily2Eff, showDaily3Eff, showDaily4Eff, showDaily5Eff, showDaily6Eff)
showWeeklyEffArr = array.from(showW1Eff, showW2Eff, showW3Eff, showW4Eff, showW5Eff, showW6Eff)

maTypes = array.from(maType1, maType2, maType3, maType4, maType5, maType6)
maLens  = array.from(maLen1, maLen2, maLen3, maLen4, maLen5, maLen6)

// === BASE COLORS ===
clr1 = input.color(color.green, title="MA 1 Colour", group="Color Settings")
clr2 = input.color(color.green, title="MA 2 Colour", group="Color Settings")
clr3 = input.color(color.green, title="MA 3 Colour", group="Color Settings")
clr4 = input.color(color.green, title="MA 4 Colour", group="Color Settings")
clr5 = input.color(color.green, title="MA 5 Colour", group="Color Settings")
clr6 = input.color(color.green, title="MA 6 Colour", group="Color Settings")
baseClrs = array.from(clr1, clr2, clr3, clr4, clr5, clr6)

// === SLOPE COLOR LOGIC ===
f_plotClr(maVal, baseClr, transp) =>
    enableSlopeColor ? color.new(maVal > nz(maVal[1]) ? slopeRisingColor : slopeFallingColor, transp) : color.new(baseClr, transp)

lw = plotLineWidth

// === PLOTS (Daily) ===
pD1 = plot(showDaily1Eff ? dailyMA1 : na, "Daily MA 1", color=f_plotClr(dailyMA1, clr1, 30), linewidth=lw)
pD2 = plot(showDaily2Eff ? dailyMA2 : na, "Daily MA 2", color=f_plotClr(dailyMA2, clr2, 30), linewidth=lw)
pD3 = plot(showDaily3Eff ? dailyMA3 : na, "Daily MA 3", color=f_plotClr(dailyMA3, clr3, 30), linewidth=lw)
pD4 = plot(showDaily4Eff ? dailyMA4 : na, "Daily MA 4", color=f_plotClr(dailyMA4, clr4, 30), linewidth=lw)
pD5 = plot(showDaily5Eff ? dailyMA5 : na, "Daily MA 5", color=f_plotClr(dailyMA5, clr5, 30), linewidth=lw)
pD6 = plot(showDaily6Eff ? dailyMA6 : na, "Daily MA 6", color=f_plotClr(dailyMA6, clr6, 30), linewidth=lw)

// === PLOTS (Weekly) ===
plot(showW1Eff ? maW1 : na, "Weekly MA 1", color=f_plotClr(maW1, clr1, 55), linewidth=lw)
plot(showW2Eff ? maW2 : na, "Weekly MA 2", color=f_plotClr(maW2, clr2, 55), linewidth=lw)
plot(showW3Eff ? maW3 : na, "Weekly MA 3", color=f_plotClr(maW3, clr3, 55), linewidth=lw)
plot(showW4Eff ? maW4 : na, "Weekly MA 4", color=f_plotClr(maW4, clr4, 55), linewidth=lw)
plot(showW5Eff ? maW5 : na, "Weekly MA 5", color=f_plotClr(maW5, clr5, 55), linewidth=lw)
plot(showW6Eff ? maW6 : na, "Weekly MA 6", color=f_plotClr(maW6, clr6, 55), linewidth=lw)

// === MA RIBBON FILL (only when both band MAs are shown and valid) ===
f_ribbonPairColor(showA, showB, maShort, maLong) =>
    enableRibbon and showA and showB and not na(maShort) and not na(maLong) ? color.new(maShort >= maLong ? color.green : color.red, ribbonTransparency) : na

fill(pD1, pD2, color=f_ribbonPairColor(showDaily1Eff, showDaily2Eff, dailyMA1, dailyMA2), title="Ribbon 1-2")
fill(pD2, pD3, color=f_ribbonPairColor(showDaily2Eff, showDaily3Eff, dailyMA2, dailyMA3), title="Ribbon 2-3")
fill(pD3, pD4, color=f_ribbonPairColor(showDaily3Eff, showDaily4Eff, dailyMA3, dailyMA4), title="Ribbon 3-4")
fill(pD4, pD5, color=f_ribbonPairColor(showDaily4Eff, showDaily5Eff, dailyMA4, dailyMA5), title="Ribbon 4-5")
fill(pD5, pD6, color=f_ribbonPairColor(showDaily5Eff, showDaily6Eff, dailyMA5, dailyMA6), title="Ribbon 5-6")

// === MA CONFLUENCE ZONES ===
f_confluenceCluster(mas, shows) =>
    float lo = na
    float hi = na
    int cnt = 0
    for i = 0 to array.size(mas) - 1
        if array.get(shows, i)
            v = array.get(mas, i)
            if not na(v)
                lo := na(lo) ? v : math.min(lo, v)
                hi := na(hi) ? v : math.max(hi, v)
                cnt := cnt + 1
    spreadPct = not na(hi) and not na(lo) and close > 0 ? (hi - lo) / close * 100.0 : na
    isCl = cnt >= confluenceMinMAs and not na(spreadPct) and spreadPct < confluenceThreshold
    [isCl, cnt]

[isConfD, _cD] = f_confluenceCluster(dailyMArr, showDailyEffArr)
[isConfW, _cW] = f_confluenceCluster(weeklyMArr, showWeeklyEffArr)

isConfluent = enableConfluence and (confluenceTf == "Daily" ? isConfD : confluenceTf == "Weekly" ? isConfW : isConfD or isConfW)
bgcolor(isConfluent ? color.new(confluenceColor, confluenceTransp) : na, title="MA Confluence Zone")

// === BAR COLORING ===
barRefMA = switch barColorTf
    "Daily"  => array.get(dailyMArr, barColorSlot - 1)
    "Weekly" => array.get(weeklyMArr, barColorSlot - 1)
    => isWeeklyInterval ? array.get(weeklyMArr, barColorSlot - 1) : array.get(dailyMArr, barColorSlot - 1)

barcolor(enableBarColor and not na(barRefMA) ? (close >= barRefMA ? barBullColor : barBearColor) : na, title="MA Bar Coloring")

// === LABELS & TAILS ===
var label[] lblD = array.new_label(6, na)
var label[] lblW = array.new_label(6, na)
var line[] tailD = array.new_line(6, na)
var line[] tailW = array.new_line(6, na)

labelYOffset = labelOffsetTicksY * syminfo.mintick

f_labelX() =>
    desiredOffset = placeLabelsFarRight ? farRightBars : labelOffsetBars
    bar_index + math.max(0, math.min(desiredOffset, 500))

f_maLabel(typ, len) =>
    typ + " " + str.tostring(len)

f_labelSz() =>
    switch labelSizeInput
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        => size.normal

f_distStr(maVal) =>
    if showPriceDistance and not na(maVal) and close > 0
        dist = (close - maVal) / close * 100
        " (" + str.tostring(dist, "#.##") + "%)"
    else
        ""

f_drawLabel(label _lbl, float _y, string _title, color _color) =>
    xPos = f_labelX()
    if not na(_lbl)
        label.delete(_lbl)
    label.new(xPos, _y + labelYOffset, _title, style=label.style_label_left, color=color.new(_color, 40), textcolor=color.white, size=f_labelSz(), xloc=xloc.bar_index)

f_clearLabel(label _lbl) =>
    if not na(_lbl)
        label.delete(_lbl)
    label(na)

f_drawTail(line _existing, float _y, color _c) =>
    if not na(_existing)
        line.delete(_existing)
    line.new(bar_index, _y, f_labelX(), _y, xloc=xloc.bar_index, color=color.new(_c, 40), width=tailLineWidth)

f_clearTail(line _ln) =>
    if not na(_ln)
        line.delete(_ln)
    line(na)

if barstate.islast
    for i = 0 to 5
        yD = array.get(dailyMArr, i)
        sD = array.get(showDailyEffArr, i)
        bcD = array.get(baseClrs, i)
        typD = array.get(maTypes, i)
        lenD = array.get(maLens, i)
        curD = array.get(lblD, i)
        if sD and not hideLabelsByInterval and not na(yD)
            array.set(lblD, i, f_drawLabel(curD, yD, "D " + f_maLabel(typD, lenD) + f_distStr(yD), bcD))
        else
            array.set(lblD, i, f_clearLabel(curD))
        yW = array.get(weeklyMArr, i)
        sW = array.get(showWeeklyEffArr, i)
        bcW = array.get(baseClrs, i)
        typW = array.get(maTypes, i)
        lenW = array.get(maLens, i)
        curW = array.get(lblW, i)
        lblColW = color.new(bcW, 30)
        if sW and not hideLabelsByInterval and not na(yW)
            array.set(lblW, i, f_drawLabel(curW, yW, "W " + f_maLabel(typW, lenW) + f_distStr(yW), lblColW))
        else
            array.set(lblW, i, f_clearLabel(curW))
        curTd = array.get(tailD, i)
        if sD and not hideLabelsByInterval and not na(yD)
            array.set(tailD, i, f_drawTail(curTd, yD, bcD))
        else
            array.set(tailD, i, f_clearTail(curTd))
        curTw = array.get(tailW, i)
        lnColW = color.new(bcW, 45)
        if sW and not hideLabelsByInterval and not na(yW)
            array.set(tailW, i, f_drawTail(curTw, yW, lnColW))
        else
            array.set(tailW, i, f_clearTail(curTw))

// === ALERT CONDITIONS ===
slotIdx = alertMaSlot - 1
dailyAlertMA = array.get(dailyMArr, slotIdx)
weeklyAlertMA = array.get(weeklyMArr, slotIdx)

crossAboveD = ta.crossover(close, dailyAlertMA)
crossBelowD = ta.crossunder(close, dailyAlertMA)
crossAboveW = ta.crossover(close, weeklyAlertMA)
crossBelowW = ta.crossunder(close, weeklyAlertMA)

confOn = isConfluent and not isConfluent[1]
confOff = not isConfluent and isConfluent[1]
newDayBar = ta.change(time("D")) != 0

alertcondition(enableAlerts and alertDailyCrossAbove and crossAboveD,
                 "D/W MA: Cross above Daily MA",
                 "Price crossed above selected Daily MA")
alertcondition(enableAlerts and alertDailyCrossBelow and crossBelowD,
                 "D/W MA: Cross below Daily MA",
                 "Price crossed below selected Daily MA")
alertcondition(enableAlerts and alertWeeklyCrossAbove and crossAboveW,
                 "D/W MA: Cross above Weekly MA",
                 "Price crossed above selected Weekly MA")
alertcondition(enableAlerts and alertWeeklyCrossBelow and crossBelowW,
                 "D/W MA: Cross below Weekly MA",
                 "Price crossed below selected Weekly MA")
alertcondition(enableAlerts and alertConfluenceOn and confOn,
                 "D/W MA: Confluence entered",
                 "MA confluence zone started")
alertcondition(enableAlerts and alertConfluenceOff and confOff,
                 "D/W MA: Confluence exited",
                 "MA confluence zone ended")
alertcondition(enableAlerts and alertNewChartDay and newDayBar,
                 "D/W MA: New calendar day",
                 "New calendar day on chart")
````
