# ORB Sessions Pro - Premarket + NY Open

- url: https://www.tradingview.com/script/yQ2MoXaQ-ORB-Sessions-Pro-Premarket-NY-Open/
- type: indicator
- pine_id: PUB;78680a9d391349049e716a9163a50b8a
- version: 1.0

## Description

# ORB Sessions Pro

## Overview

ORB Sessions Pro is designed to help traders visualize and compare two of the most important auction periods of the trading day:

• Premarket Opening Range (08:00–09:00 ET)
• New York Open Opening Range (09:30 ET)

Rather than treating every market open the same, this indicator allows traders to study how price responds to different auction periods and how those ranges influence the remainder of the session.

The goal is not to generate buy or sell signals.

The goal is to provide objective auction reference points that help traders understand where price is being accepted, rejected, and potentially migrating throughout the day.

---

## Features

• Independent Premarket and NY Open ORBs
• Selectable NY Open range lengths (5, 15, 30, 45, or 60 minutes)
• Display ORB levels only or extend them through the trading session
• Historical average ORB calculations
• Integrated ORB Sessions Dashboard
• Session range utilization tracking
• Custom colors, line styles, and label options
• Lightweight design with a clean chart presentation

---

## ORB Sessions Dashboard

The integrated dashboard provides quick insight into current market conditions without requiring additional calculations.

The dashboard displays:

• Premarket ORB size and historical average
• NY Open ORB size and historical average
• Average session range
• Current session range
• Percentage of average range already completed
• Remaining range based on historical averages

This allows traders to quickly determine whether the market has already completed a typical daily move or may still have room for expansion.

By combining opening range information with current range statistics, traders gain additional context about auction development throughout the session.

---

## How I Use It

The Opening Range is one of the simplest ways to identify where early market participants found value.

When price remains inside the ORB, the market is often balanced.

When price accepts above or below the ORB, it can signal initiative activity and the potential for directional movement.

The Premarket ORB often highlights overnight inventory and areas of acceptance before the cash session begins.

The NY Open ORB helps identify where institutional participation enters the market and can provide important reference levels throughout the day.

These levels become even more meaningful when combined with market context, volume profile, and value migration.

---

## Best Used With

• VWAP
• Volume Profile
• Auction Market Theory (AMT)
• Market Structure Analysis
• Balance and Imbalance Concepts
• Acceptance and Rejection Analysis

---

## Traders Workshop Philosophy

Most traders spend their time reacting to price.

This indicator was built to help traders understand the auction taking place behind the price movement.

Stop reacting to the market.

Start reading it.

---

**Real Trading. Real Testing. Real Results.**

## Source Code

````pine
//@version=6
//=====================================================================
// Indicator: ORB Sessions Pro
// Author: Christopher C. Berg
// TradingView: ChristopherBergTraderWorkshop
// Version: 1.0.0
// Initial Release: June 2026
//=====================================================================
//
// Traders Workshop
// Real Trading. Real Testing. Real Results.
//=====================================================================
indicator('ORB Sessions Pro - Premarket + NY Open', shorttitle = 'ORB Sessions Pro', overlay = true, max_lines_count = 100, max_labels_count = 50)

//================ INPUTS ================
tz = input.string('America/New_York', 'Session Timezone')

showPremarketORB = input.bool(true, 'Show 0800-0900 Premarket ORB')
showNYOpenORB = input.bool(true, 'Show 0930 NY Open ORB')

premLineMode = input.string('Open Range Only', 'Premarket Line Display', options = ['Open Range Only', 'Full Session to 1600'])
nyLineMode = input.string('Full Session to 1600', 'NY Open Line Display', options = ['Open Range Only', 'Full Session to 1600'])

nyOrbMinutes = input.int(30, 'NY Open ORB Length', options = [5, 15, 30, 45, 60])

avgLookback = input.int(20, 'ORB / Range Avg Lookback', minval = 3, maxval = 100)

// Table
showTable = input.bool(true, 'Show Table')
tablePosIn = input.string('Top Right', 'Table Position', options = ['Top Right', 'Top Left', 'Bottom Right', 'Bottom Left'])
rangeSessionMode = input.string('Full Session with Premarket', 'Range Calculation', options = ['NY Session Only', 'Full Session with Premarket'])

// Styling
orbLineWidth = input.int(3, 'ORB Line Width', minval = 1, maxval = 5)
orbLineStyleIn = input.string('Solid', 'ORB Line Style', options = ['Solid', 'Dashed', 'Dotted'])

premHighColor = input.color(color.green, 'Premarket High Color')
premLowColor = input.color(color.red, 'Premarket Low Color')

nyHighColor = input.color(color.lime, 'NY Open High Color')
nyLowColor = input.color(color.maroon, 'NY Open Low Color')

labelOffsetTicks = input.int(3, 'Label Offset Ticks', minval = 1, maxval = 50)
labelSizeIn = input.string('Small', 'Label Size', options = ['Tiny', 'Small', 'Normal', 'Large', 'Huge'])
labelTextColor = input.color(color.blue, 'Label Text Color')
labelBgColor = input.color(color.white, 'Label Background')

//================ HELPERS ================
f_line_style(_s) =>
    _s == 'Dashed' ? line.style_dashed : _s == 'Dotted' ? line.style_dotted : line.style_solid

f_label_size(_s) =>
    _s == 'Tiny' ? size.tiny : _s == 'Small' ? size.small : _s == 'Normal' ? size.normal : _s == 'Large' ? size.large : size.huge

f_table_pos(_s) =>
    _s == 'Top Left' ? position.top_left : _s == 'Bottom Right' ? position.bottom_right : _s == 'Bottom Left' ? position.bottom_left : position.top_right

f_fmt_pts(_v) =>
    na(_v) ? 'n/a' : str.tostring(_v, format.mintick) + ' pts'

f_fmt_pts_pair(_v, _avg) =>
    not na(_v) and not na(_avg) ? str.tostring(_v, format.mintick) + ' / Avg ' + str.tostring(_avg, format.mintick) : not na(_v) ? str.tostring(_v, format.mintick) + ' / Avg n/a' : 'n/a'

f_fmt_pct(_v) =>
    na(_v) ? 'n/a' : str.tostring(_v, '#.0') + '%'

f_trimmed_avg(_arr) =>
    float _avg = na
    int _sz = array.size(_arr)

    if _sz == 1
        _avg := array.get(_arr, 0)
        _avg
    else if _sz == 2
        _avg := (array.get(_arr, 0) + array.get(_arr, 1)) / 2.0
        _avg
    else if _sz > 2
        float _sum = 0.0
        float _min = array.get(_arr, 0)
        float _max = array.get(_arr, 0)

        for i = 0 to _sz - 1 by 1
            float _v = array.get(_arr, i)
            _sum := _sum + _v
            _min := math.min(_min, _v)
            _max := math.max(_max, _v)
            _max

        _avg := (_sum - _min - _max) / (_sz - 2)
        _avg

    _avg

f_trim_array(_arr, _max) =>
    while array.size(_arr) > _max
        array.shift(_arr)

f_orb_label(_name, _pts, _avg) =>
    _name + ' ORB: ' + str.tostring(_pts, format.mintick) + ' / Avg ' + (na(_avg) ? 'n/a' : str.tostring(_avg, format.mintick)) + ' pts'

orbLineStyle = f_line_style(orbLineStyleIn)
labelSize = f_label_size(labelSizeIn)

//================ SESSIONS ================
premSess = '0800-0900'
fullDaySess = '0800-1600'
rthSess = '0930-1600'

rangeSess = rangeSessionMode == 'NY Session Only' ? rthSess : fullDaySess
rangeModeLabel = rangeSessionMode == 'NY Session Only' ? 'NY Session' : 'Full Session'

nySess = nyOrbMinutes == 5 ? '0930-0935' : nyOrbMinutes == 15 ? '0930-0945' : nyOrbMinutes == 30 ? '0930-1000' : nyOrbMinutes == 45 ? '0930-1015' : '0930-1030'

inPrem = not na(time(timeframe.period, premSess, tz))
newPrem = inPrem and not inPrem[1]
endPrem = not inPrem and inPrem[1]

inNY = not na(time(timeframe.period, nySess, tz))
newNY = inNY and not inNY[1]
endNY = not inNY and inNY[1]

inFullDay = not na(time(timeframe.period, fullDaySess, tz))
endFullDay = not inFullDay and inFullDay[1]

inRTH = not na(time(timeframe.period, rthSess, tz))
endRTH = not inRTH and inRTH[1]

inRangeSess = not na(time(timeframe.period, rangeSess, tz))
newRangeSess = inRangeSess and not inRangeSess[1]

extendPremLines = premLineMode == 'Full Session to 1600'
extendNYLines = nyLineMode == 'Full Session to 1600'

//================ PREMARKET STATE ================
var float premHigh = na
var float premLow = na
var float premPts = na
var float premAvg = na
var int premStart = na
var bool premLocked = false

var line premHiLine = na
var line premLoLine = na
var label premLbl = na

var array<float> premHist = array.new_float()

//================ NY OPEN STATE ================
var float nyHigh = na
var float nyLow = na
var float nyPts = na
var float nyAvg = na
var int nyStart = na
var bool nyLocked = false

var line nyHiLine = na
var line nyLoLine = na
var label nyLbl = na

var array<float> nyHist = array.new_float()

//================ RANGE STATE ================
var float dayHigh = na
var float dayLow = na
var array<float> dayRangeHist = array.new_float()

if newRangeSess
    if not na(dayHigh) and not na(dayLow) and dayHigh > dayLow
        array.push(dayRangeHist, dayHigh - dayLow)
        f_trim_array(dayRangeHist, avgLookback)

    dayHigh := high
    dayLow := low
    dayLow

if inRangeSess
    dayHigh := na(dayHigh) ? high : math.max(dayHigh, high)
    dayLow := na(dayLow) ? low : math.min(dayLow, low)
    dayLow

//================ PREMARKET ORB ================
if showPremarketORB and newPrem
    premHigh := high
    premLow := low
    premPts := na
    premAvg := na
    premStart := bar_index
    premLocked := false
    premHiLine := na
    premLoLine := na
    premLbl := na
    premLbl

if showPremarketORB and inPrem
    premHigh := na(premHigh) ? high : math.max(premHigh, high)
    premLow := na(premLow) ? low : math.min(premLow, low)
    premLow

if showPremarketORB and endPrem and not premLocked and not na(premHigh) and not na(premLow)
    premLocked := true
    premPts := premHigh - premLow
    premAvg := f_trimmed_avg(premHist)

    premHiLine := line.new(premStart, premHigh, bar_index, premHigh, color = premHighColor, width = orbLineWidth, style = orbLineStyle)
    premLoLine := line.new(premStart, premLow, bar_index, premLow, color = premLowColor, width = orbLineWidth, style = orbLineStyle)

    premLbl := label.new(premStart, premHigh + labelOffsetTicks * syminfo.mintick, f_orb_label('PM', premPts, premAvg), style = label.style_label_down, textcolor = labelTextColor, color = labelBgColor, size = labelSize)

    array.push(premHist, premPts)
    f_trim_array(premHist, avgLookback)

if showPremarketORB and premLocked and extendPremLines and inFullDay
    if not na(premHiLine)
        line.set_x2(premHiLine, bar_index)
    if not na(premLoLine)
        line.set_x2(premLoLine, bar_index)

if showPremarketORB and premLocked and extendPremLines and endFullDay
    if not na(premHiLine)
        line.set_x2(premHiLine, bar_index[1])
    if not na(premLoLine)
        line.set_x2(premLoLine, bar_index[1])

//================ NY OPEN ORB ================
if showNYOpenORB and newNY
    nyHigh := high
    nyLow := low
    nyPts := na
    nyAvg := na
    nyStart := bar_index
    nyLocked := false
    nyHiLine := na
    nyLoLine := na
    nyLbl := na
    nyLbl

if showNYOpenORB and inNY
    nyHigh := na(nyHigh) ? high : math.max(nyHigh, high)
    nyLow := na(nyLow) ? low : math.min(nyLow, low)
    nyLow

if showNYOpenORB and endNY and not nyLocked and not na(nyHigh) and not na(nyLow)
    nyLocked := true
    nyPts := nyHigh - nyLow
    nyAvg := f_trimmed_avg(nyHist)

    nyHiLine := line.new(nyStart, nyHigh, bar_index, nyHigh, color = nyHighColor, width = orbLineWidth, style = orbLineStyle)
    nyLoLine := line.new(nyStart, nyLow, bar_index, nyLow, color = nyLowColor, width = orbLineWidth, style = orbLineStyle)

    nyLbl := label.new(nyStart, nyHigh + labelOffsetTicks * syminfo.mintick, f_orb_label('NY', nyPts, nyAvg), style = label.style_label_down, textcolor = labelTextColor, color = labelBgColor, size = labelSize)

    array.push(nyHist, nyPts)
    f_trim_array(nyHist, avgLookback)

// Fixed: NY lines only extend during 0930-1600 RTH.
if showNYOpenORB and nyLocked and extendNYLines and inRTH
    if not na(nyHiLine)
        line.set_x2(nyHiLine, bar_index)
    if not na(nyLoLine)
        line.set_x2(nyLoLine, bar_index)

// Fixed: Freeze NY lines at the final RTH bar instead of allowing next-day extension.
if showNYOpenORB and nyLocked and extendNYLines and endRTH
    if not na(nyHiLine)
        line.set_x2(nyHiLine, bar_index[1])
    if not na(nyLoLine)
        line.set_x2(nyLoLine, bar_index[1])

//================ TABLE CALCS ================
avgDayRange = f_trimmed_avg(dayRangeHist)
todayRange = not na(dayHigh) and not na(dayLow) ? dayHigh - dayLow : na
rangeUsed = not na(todayRange) and not na(avgDayRange) and avgDayRange > 0 ? todayRange / avgDayRange * 100.0 : na
rangeLeft = not na(rangeUsed) ? math.max(0.0, 100.0 - rangeUsed) : na

//================ TABLE ================
var table orbTbl = table.new(f_table_pos(tablePosIn), 2, 9, border_width = 1)

tblHdrBg = color.new(color.blue, 70)
tblOrbBg = color.new(color.blue, 88)
tblSectionBg = color.new(color.rgb(0, 128, 128), 70)
tblRangeBg = color.new(color.rgb(0, 128, 128), 88)
tblText = color.white
tblEmpty = color.new(color.black, 100)

if showTable
    table.cell(orbTbl, 0, 0, 'ORB SESSIONS', text_color = tblText, bgcolor = tblHdrBg, text_halign = text.align_left)
    table.cell(orbTbl, 1, 0, '', text_color = tblText, bgcolor = tblHdrBg)

    table.cell(orbTbl, 0, 1, 'PreMarket ORB', text_color = tblText, bgcolor = tblOrbBg, text_halign = text.align_left)
    table.cell(orbTbl, 1, 1, f_fmt_pts_pair(premPts, premAvg), text_color = tblText, bgcolor = tblOrbBg, text_halign = text.align_right)

    table.cell(orbTbl, 0, 2, 'NY Open ORB', text_color = tblText, bgcolor = tblOrbBg, text_halign = text.align_left)
    table.cell(orbTbl, 1, 2, f_fmt_pts_pair(nyPts, nyAvg), text_color = tblText, bgcolor = tblOrbBg, text_halign = text.align_right)

    table.cell(orbTbl, 0, 3, 'SESSION RANGE', text_color = tblText, bgcolor = tblSectionBg, text_halign = text.align_left)
    table.cell(orbTbl, 1, 3, '', text_color = tblText, bgcolor = tblSectionBg)

    table.cell(orbTbl, 0, 4, 'Mode', text_color = tblText, bgcolor = tblRangeBg, text_halign = text.align_left)
    table.cell(orbTbl, 1, 4, rangeModeLabel, text_color = tblText, bgcolor = tblRangeBg, text_halign = text.align_right)

    table.cell(orbTbl, 0, 5, 'Avg Range', text_color = tblText, bgcolor = tblRangeBg, text_halign = text.align_left)
    table.cell(orbTbl, 1, 5, f_fmt_pts(avgDayRange), text_color = tblText, bgcolor = tblRangeBg, text_halign = text.align_right)

    table.cell(orbTbl, 0, 6, 'Today\'s Range', text_color = tblText, bgcolor = tblRangeBg, text_halign = text.align_left)
    table.cell(orbTbl, 1, 6, f_fmt_pts(todayRange), text_color = tblText, bgcolor = tblRangeBg, text_halign = text.align_right)

    table.cell(orbTbl, 0, 7, 'Range Used', text_color = tblText, bgcolor = tblRangeBg, text_halign = text.align_left)
    table.cell(orbTbl, 1, 7, f_fmt_pct(rangeUsed), text_color = tblText, bgcolor = tblRangeBg, text_halign = text.align_right)

    table.cell(orbTbl, 0, 8, 'Range Left', text_color = tblText, bgcolor = tblRangeBg, text_halign = text.align_left)
    table.cell(orbTbl, 1, 8, f_fmt_pct(rangeLeft), text_color = tblText, bgcolor = tblRangeBg, text_halign = text.align_right)
else
    for r = 0 to 8 by 1
        table.cell(orbTbl, 0, r, '', text_color = tblText, bgcolor = tblEmpty)
        table.cell(orbTbl, 1, r, '', text_color = tblText, bgcolor = tblEmpty)

// MCP-readable — data window only
plot(premHigh, 'PM ORB High', display = display.data_window)
plot(premLow, 'PM ORB Low', display = display.data_window)
plot(nyHigh, 'NY ORB High', display = display.data_window)
plot(nyLow, 'NY ORB Low', display = display.data_window)
plot(todayRange, 'Today Range', display = display.data_window)
plot(avgDayRange, 'Avg Day Range', display = display.data_window)
````
