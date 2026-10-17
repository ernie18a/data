# Bitcoin Halving Cycle Strategy [Gabremoku]

- url: https://www.tradingview.com/script/lD1AXj0B-Bitcoin-Halving-Cycle-Strategy-Gabremoku/
- type: indicator
- pine_id: PUB;4ac6ca6ffcee4daaa36da8319517384d
- version: 1.0

## Description

This script is a Bitcoin cycle timing indicator built around the historical halving structure.

The core idea is simple:
- define a Buy window a fixed number of days before each halving,
- define a Sell window a fixed number of days after each halving,
- project the next key dates directly on the chart.

The indicator does not try to predict price with oscillators, momentum formulas, or future-looking data. Instead, it focuses on a structural market rhythm that many Bitcoin traders monitor: the recurring supply shock created by halvings.

How it works
- The script uses known historical Bitcoin halving dates.
- It calculates a Buy date at halving minus N days.
- It calculates a Sell date at halving plus N days.
- It draws vertical reference lines for Buy, Halving, and Sell events.
- It plots historical labels on the actual event bars.
- It projects the upcoming Buy, Sell, and Halving labels forward to their own future dates on the chart.
- A dashboard summarizes the active cycle, next key date, and remaining days.

What makes this script useful
Most halving tools only mark the halving date itself. This script expands the concept into a complete cycle timeline by transforming each halving into three practical timing landmarks:
1. accumulation window before halving,
2. halving anchor point,
3. distribution window after halving.

This makes the script more useful for traders and investors who want a visual cycle map instead of a single event marker.

How to use it
- Apply it on BTCUSD or BTCUSDT.
- Daily and weekly charts are the most readable timeframes for this model.
- Use "Buy Days Before Halving" to control how early the accumulation window begins.
- Use "Sell Days After Halving" to control how long the post-halving window extends.
- Use the projected labels to monitor the next cycle dates in advance.
- Use the dashboard to read the current phase quickly.

Included features
- Historical halving timeline
- Buy and Sell event mapping
- Future projected labels positioned on future dates
- Optional cycle range highlighting
- Dashboard with next Buy, next Sell, next Halving, and countdown
- Custom colors and label controls

Important notes
- This script is a cycle visualization tool, not financial advice.
- It does not guarantee future market behavior.
- The projected future halving date is used as a timeline estimate for planning and visualization only.
- Past cycle behavior does not guarantee similar future performance.
- For clarity and to avoid misleading output, this script should be used on standard candlestick charts.

This publication is intended to provide a clean and practical timing framework for Bitcoin traders who study halving-driven market cycles rather than signal-based entry systems.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Gabremoku

//@version=6
indicator("Bitcoin Halving Cycle Strategy [Gabremoku]", overlay=true, max_labels_count=500, max_lines_count=500)
// ─────────────────────────────────────────────────────
// Bitcoin Halving Cycle Timeline
// Marks Bitcoin halving dates and two cycle windows:
// - BUY at halving - N days
// - SELL at halving + N days
// Designed as a timing map, not as a promise of results.
// ─────────────────────────────────────────────────────

// ── INPUTS ────────────────────────────────────────────
grp0 = "Core"
daysBeforeInput = input.int(500, "Buy Days Before Halving", minval=1, group=grp0)
daysAfterInput  = input.int(500, "Sell Days After Halving", minval=1, group=grp0)
showHistorical  = input.bool(true, "Show Historical Cycles", group=grp0)
showFuture      = input.bool(true, "Show Next Cycle Projection", group=grp0)
extendLines     = input.bool(true, "Extend Event Lines", group=grp0)

grp1 = "Style"
bullColor    = input.color(color.rgb(0, 170, 120), "Buy Color", group=grp1)
bearColor    = input.color(color.rgb(220, 60, 60), "Sell Color", group=grp1)
halvingColor = input.color(color.rgb(245, 170, 35), "Halving Color", group=grp1)
lineColor    = input.color(color.rgb(120, 120, 120), "Guide Line Color", group=grp1)
textColor    = chart.fg_color

grp2 = "Markers"
showBuyLabels       = input.bool(true, "Show Buy Labels", group=grp2)
showSellLabels      = input.bool(true, "Show Sell Labels", group=grp2)
showHalvingLabels   = input.bool(true, "Show Halving Labels", group=grp2)
showPriceInLabels   = input.bool(true, "Show Price In Labels", group=grp2)
showProjectedLabels = input.bool(true, "Show Projected Next Labels", group=grp2)
markerSizeInput     = input.string("Normal", "Marker Size", options=["Tiny", "Small", "Normal"], group=grp2)

markerSize = size.normal
if markerSizeInput == "Tiny"
    markerSize := size.tiny
else if markerSizeInput == "Small"
    markerSize := size.small

grp3 = "Cycle View"
showCycleRange      = input.bool(true, "Highlight Active Cycle Range", group=grp3)
showDaysCountdown   = input.bool(true, "Show Days In Projected Labels", group=grp3)
showOnlyLastSignals = input.bool(false, "Show Only Last Historical Buy/Sell", group=grp3)

grp4 = "Projected Labels"
futureBuyYFactor     = input.float(0.82, "Next Buy Y Factor", minval=0.05, step=0.01, group=grp4)
futureSellYFactor    = input.float(1.18, "Next Sell Y Factor", minval=0.05, step=0.01, group=grp4)
futureHalvingYFactor = input.float(1.00, "Next Halving Y Factor", minval=0.05, step=0.01, group=grp4)

grp5 = "Dashboard"
showDashboard = input.bool(true, "Show Dashboard", group=grp5)
dashPosInput = input.string("Bottom Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grp5)
dashTextSizeInput = input.string("Small", "Dashboard Text Size", options=["Tiny", "Small", "Normal"], group=grp5)

dashTextSize = size.small
if dashTextSizeInput == "Tiny"
    dashTextSize := size.tiny
else if dashTextSizeInput == "Normal"
    dashTextSize := size.normal

// ── DASHBOARD POSITION ───────────────────────────────
dashPos = position.bottom_right
if dashPosInput == "Top Right"
    dashPos := position.top_right
else if dashPosInput == "Top Left"
    dashPos := position.top_left
else if dashPosInput == "Bottom Left"
    dashPos := position.bottom_left

// ── CONSTANTS ────────────────────────────────────────
dayMs = 24 * 60 * 60 * 1000

// Known Bitcoin halving dates.
// The 2028 date is an estimated projection used only for timeline planning.
halving1 = timestamp("UTC", 2012, 11, 28, 0, 0)
halving2 = timestamp("UTC", 2016, 7, 9, 0, 0)
halving3 = timestamp("UTC", 2020, 5, 11, 0, 0)
halving4 = timestamp("UTC", 2024, 4, 20, 0, 0)
halving5 = timestamp("UTC", 2028, 4, 20, 0, 0)

buy1  = halving1 - daysBeforeInput * dayMs
sell1 = halving1 + daysAfterInput  * dayMs

buy2  = halving2 - daysBeforeInput * dayMs
sell2 = halving2 + daysAfterInput  * dayMs

buy3  = halving3 - daysBeforeInput * dayMs
sell3 = halving3 + daysAfterInput  * dayMs

buy4  = halving4 - daysBeforeInput * dayMs
sell4 = halving4 + daysAfterInput  * dayMs

buy5  = halving5 - daysBeforeInput * dayMs
sell5 = halving5 + daysAfterInput  * dayMs

// ── FUNCTIONS ────────────────────────────────────────
f_timeReached(_t) =>
    time >= _t and time[1] < _t

f_dateStr(_t) =>
    str.format("{0,date,dd MMM yyyy}", _t)

f_priceStr(_p) =>
    str.tostring(_p, format.mintick)

f_daysTo(_t) =>
    math.floor((_t - time) / dayMs)

f_labelText(_prefix, _price, _time) =>
    showPriceInLabels ? _prefix + " " + f_priceStr(_price) + "\n" + f_dateStr(_time) : _prefix + "\n" + f_dateStr(_time)

f_projectedText(_prefix, _time) =>
    showDaysCountdown ? _prefix + "\n" + f_dateStr(_time) + "\n" + str.tostring(f_daysTo(_time)) + " days" : _prefix + "\n" + f_dateStr(_time)

f_eventLine(_eventTime, _clr, _style) =>
    if time[1] < _eventTime and time >= _eventTime
        line.new(bar_index, low * 0.85, bar_index, high * 1.15, xloc=xloc.bar_index, extend=extendLines ? extend.both : extend.none, color=_clr, style=_style, width=1)

f_plotEventLabel(_cond, _isUp, _txt, _clr) =>
    if _cond
        label.new(
             bar_index,
             _isUp ? low : high,
             _txt,
             xloc=xloc.bar_index,
             style=_isUp ? label.style_label_up : label.style_label_down,
             color=_clr,
             textcolor=color.white,
             size=markerSize)

f_projectedLabel(_xTime, _y, _txt, _clr, _style) =>
    label.new(
         _xTime,
         _y,
         _txt,
         xloc=xloc.bar_time,
         style=_style,
         color=_clr,
         textcolor=color.white,
         size=size.small)

// ── ACTIVE CYCLE LOGIC ───────────────────────────────
var int nextHalving = na
var int nextBuy = na
var int nextSell = na
var string activeCycle = ""
var string marketPhase = ""

if time < halving1
    nextHalving := halving1
    nextBuy := buy1
    nextSell := sell1
    activeCycle := "Pre Cycle 1"
else if time >= halving1 and time < halving2
    nextHalving := halving2
    nextBuy := buy2
    nextSell := sell2
    activeCycle := "Cycle 2"
else if time >= halving2 and time < halving3
    nextHalving := halving3
    nextBuy := buy3
    nextSell := sell3
    activeCycle := "Cycle 3"
else if time >= halving3 and time < halving4
    nextHalving := halving4
    nextBuy := buy4
    nextSell := sell4
    activeCycle := "Cycle 4"
else if time >= halving4 and time < halving5
    nextHalving := halving5
    nextBuy := buy5
    nextSell := sell5
    activeCycle := "Cycle 5"
else
    nextHalving := halving5
    nextBuy := buy5
    nextSell := sell5
    activeCycle := "Post Cycle 5"

if time < nextBuy
    marketPhase := "Waiting Buy Window"
else if time >= nextBuy and time < nextHalving
    marketPhase := "Pre Halving Window"
else if time >= nextHalving and time < nextSell
    marketPhase := "Post Halving Window"
else
    marketPhase := "After Sell Window"

// ── ACTIVE RANGE HIGHLIGHT ───────────────────────────
inActiveWindow = time >= nextBuy and time <= nextSell
bgcolor(showCycleRange and inActiveWindow ? color.new(halvingColor, 92) : na)

// ── EVENT TRIGGERS ───────────────────────────────────
buy1Hit  = f_timeReached(buy1)
sell1Hit = f_timeReached(sell1)
hal1Hit  = f_timeReached(halving1)

buy2Hit  = f_timeReached(buy2)
sell2Hit = f_timeReached(sell2)
hal2Hit  = f_timeReached(halving2)

buy3Hit  = f_timeReached(buy3)
sell3Hit = f_timeReached(sell3)
hal3Hit  = f_timeReached(halving3)

buy4Hit  = f_timeReached(buy4)
sell4Hit = f_timeReached(sell4)
hal4Hit  = f_timeReached(halving4)

buy5Hit  = f_timeReached(buy5)
sell5Hit = f_timeReached(sell5)
hal5Hit  = f_timeReached(halving5)

// ── GUIDE LINES ──────────────────────────────────────
if showHistorical
    f_eventLine(buy1, bullColor, line.style_dotted)
    f_eventLine(halving1, halvingColor, line.style_solid)
    f_eventLine(sell1, bearColor, line.style_dotted)

    f_eventLine(buy2, bullColor, line.style_dotted)
    f_eventLine(halving2, halvingColor, line.style_solid)
    f_eventLine(sell2, bearColor, line.style_dotted)

    f_eventLine(buy3, bullColor, line.style_dotted)
    f_eventLine(halving3, halvingColor, line.style_solid)
    f_eventLine(sell3, bearColor, line.style_dotted)

    f_eventLine(buy4, bullColor, line.style_dotted)
    f_eventLine(halving4, halvingColor, line.style_solid)
    f_eventLine(sell4, bearColor, line.style_dotted)

if showFuture
    f_eventLine(buy5, bullColor, line.style_dashed)
    f_eventLine(halving5, halvingColor, line.style_dashed)
    f_eventLine(sell5, bearColor, line.style_dashed)

// ── HISTORICAL FILTER ────────────────────────────────
showBuy1  = showHistorical and not showOnlyLastSignals
showSell1 = showHistorical and not showOnlyLastSignals
showBuy2  = showHistorical and not showOnlyLastSignals
showSell2 = showHistorical and not showOnlyLastSignals
showBuy3  = showHistorical and not showOnlyLastSignals
showSell3 = showHistorical and not showOnlyLastSignals
showBuy4  = showHistorical
showSell4 = showHistorical

// ── HISTORICAL LABELS ────────────────────────────────
if showBuyLabels and showBuy1
    f_plotEventLabel(buy1Hit, true, f_labelText("BUY", close, buy1), bullColor)
if showSellLabels and showSell1
    f_plotEventLabel(sell1Hit, false, f_labelText("SELL", close, sell1), bearColor)
if showHalvingLabels and showHistorical
    f_plotEventLabel(hal1Hit, true, "HALVING\n" + f_dateStr(halving1), halvingColor)

if showBuyLabels and showBuy2
    f_plotEventLabel(buy2Hit, true, f_labelText("BUY", close, buy2), bullColor)
if showSellLabels and showSell2
    f_plotEventLabel(sell2Hit, false, f_labelText("SELL", close, sell2), bearColor)
if showHalvingLabels and showHistorical
    f_plotEventLabel(hal2Hit, true, "HALVING\n" + f_dateStr(halving2), halvingColor)

if showBuyLabels and showBuy3
    f_plotEventLabel(buy3Hit, true, f_labelText("BUY", close, buy3), bullColor)
if showSellLabels and showSell3
    f_plotEventLabel(sell3Hit, false, f_labelText("SELL", close, sell3), bearColor)
if showHalvingLabels and showHistorical
    f_plotEventLabel(hal3Hit, true, "HALVING\n" + f_dateStr(halving3), halvingColor)

if showBuyLabels and showBuy4
    f_plotEventLabel(buy4Hit, true, f_labelText("BUY", close, buy4), bullColor)
if showSellLabels and showSell4
    f_plotEventLabel(sell4Hit, false, f_labelText("SELL", close, sell4), bearColor)
if showHalvingLabels and showHistorical
    f_plotEventLabel(hal4Hit, true, "HALVING\n" + f_dateStr(halving4), halvingColor)

if showBuyLabels and showFuture
    f_plotEventLabel(buy5Hit, true, f_labelText("BUY", close, buy5), bullColor)
if showSellLabels and showFuture
    f_plotEventLabel(sell5Hit, false, f_labelText("SELL", close, sell5), bearColor)
if showHalvingLabels and showFuture
    f_plotEventLabel(hal5Hit, true, "HALVING\n" + f_dateStr(halving5), halvingColor)

// ── PROJECTED NEXT LABELS ────────────────────────────
var label nextBuyLbl = na
var label nextSellLbl = na
var label nextHalvingLbl = na

if barstate.islast and showProjectedLabels
    label.delete(nextBuyLbl)
    label.delete(nextSellLbl)
    label.delete(nextHalvingLbl)

    nextBuyLbl := f_projectedLabel(
         nextBuy,
         close * futureBuyYFactor,
         f_projectedText("Next Buy", nextBuy),
         bullColor,
         label.style_label_up)

    nextSellLbl := f_projectedLabel(
         nextSell,
         close * futureSellYFactor,
         f_projectedText("Next Sell", nextSell),
         bearColor,
         label.style_label_down)

    nextHalvingLbl := f_projectedLabel(
         nextHalving,
         close * futureHalvingYFactor,
         f_projectedText("Next Halving", nextHalving),
         halvingColor,
         label.style_label_left)

if barstate.islast and not showProjectedLabels
    label.delete(nextBuyLbl)
    label.delete(nextSellLbl)
    label.delete(nextHalvingLbl)

// ── ALERTS ───────────────────────────────────────────
alertcondition(buy1Hit or buy2Hit or buy3Hit or buy4Hit or buy5Hit, "Bitcoin Buy Window", "Bitcoin halving buy window reached.")
alertcondition(sell1Hit or sell2Hit or sell3Hit or sell4Hit or sell5Hit, "Bitcoin Sell Window", "Bitcoin halving sell window reached.")
alertcondition(hal1Hit or hal2Hit or hal3Hit or hal4Hit or hal5Hit, "Bitcoin Halving", "Bitcoin halving date reached.")

// ── DASHBOARD VALUES ─────────────────────────────────
phaseColor = marketPhase == "Waiting Buy Window" ? bullColor :
     marketPhase == "Pre Halving Window" ? bullColor :
     marketPhase == "Post Halving Window" ? halvingColor :
     bearColor

daysToBuy = f_daysTo(nextBuy)
daysToSell = f_daysTo(nextSell)
daysToHalving = f_daysTo(nextHalving)

distanceState = time < nextBuy ? "Before Buy" :
     time >= nextBuy and time < nextHalving ? "Before Halving" :
     time >= nextHalving and time < nextSell ? "Before Sell" : "After Sell"

distanceValue = time < nextBuy ? daysToBuy :
     time >= nextBuy and time < nextHalving ? daysToHalving :
     time >= nextHalving and time < nextSell ? daysToSell : math.abs(daysToSell)

distanceColor = time < nextBuy ? bullColor :
     time >= nextBuy and time < nextHalving ? halvingColor :
     time >= nextHalving and time < nextSell ? bearColor :
     lineColor

// ── DASHBOARD ────────────────────────────────────────
var table dash = table.new(dashPos, 2, 6, border_width=1)

if barstate.isfirst
    dash := table.new(dashPos, 2, 6, border_width=1)

if barstate.islast and showDashboard
    table.cell(dash, 0, 0, "State", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 0, marketPhase, text_color=phaseColor, text_halign=text.align_center, text_size=dashTextSize)

    table.cell(dash, 0, 1, "Cycle", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 1, activeCycle, text_color=textColor, text_halign=text.align_center, text_size=dashTextSize)

    table.cell(dash, 0, 2, "Next Buy", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 2, f_dateStr(nextBuy), text_color=bullColor, text_halign=text.align_center, text_size=dashTextSize)

    table.cell(dash, 0, 3, "Next Sell", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 3, f_dateStr(nextSell), text_color=bearColor, text_halign=text.align_center, text_size=dashTextSize)

    table.cell(dash, 0, 4, "Halving", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 4, f_dateStr(nextHalving), text_color=halvingColor, text_halign=text.align_center, text_size=dashTextSize)

    table.cell(dash, 0, 5, "Countdown", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 5, distanceState + " / " + str.tostring(distanceValue) + "d", text_color=distanceColor, text_halign=text.align_center, text_size=dashTextSize)

if barstate.islast and not showDashboard
    table.clear(dash, 0, 0, 1, 5)
````
