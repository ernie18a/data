# MOVE vs VIX - 1-Year Range Position

- url: https://www.tradingview.com/script/GJPzLnS3-MOVE-vs-VIX-1-Year-Range-Position/
- type: indicator
- pine_id: PUB;650e579d3b8041a5b11cd369df86955d
- version: 3.0

## Description

MOVE vs VIX - 1-Year Range Position compares how elevated Treasury-bond and equity volatility are within their own recent daily closing-value ranges.

MOVE and VIX have different scales, so subtracting their raw index levels does not make a useful like-for-like comparison. This indicator first expresses each index on the same 0-100 range-position scale, then subtracts VIX's position from MOVE's.

CALCULATION

For each index:
Range position = 100 x (latest daily close - lowest daily close in the window) / (highest daily close in the window - lowest daily close in the window).

The default window is 252 daily observations, including the evaluated day's close and the preceding 251 source sessions. This approximates one trading year. The extremes use daily CLOSING values, not intraday highs and lows.

Difference = MOVE range position - VIX range position.

A positive difference means MOVE is higher within its own recent range than VIX is within its own range. A negative difference means the reverse. For example, MOVE at 87% and VIX at 10% gives a difference of +77 percentage points.

This is range normalization, not statistical percentile rank. A reading of 87% means 87% of the distance from the lowest close to the highest close; it does not mean the reading exceeds 87% of historical observations.

SETUP AND DISPLAY

Use a standard 1D chart of TVC:MOVE. The default requested sources are TVC:MOVE and CBOE:VIX.

For the three-panel layout, add this same indicator three times. Set Panel to MOVE on the first instance, VIX on the second, and Difference on the third. Keep the symbols and window length identical across the instances.

The default fractional display uses 0-1: 0.87 means 87%. Disable Use 0-1 scale to show 0-100 units instead. The difference can be negative. The table always displays percentages and percentage points and shows the date of the latest matched pair.

Green columns show a positive difference; red columns show a negative difference. The orange reference defaults to +60 percentage points, displayed as 0.60 on the fractional scale. Orange marks on the price chart identify upward crossings of that threshold on consecutive valid chart bars. The threshold is a visual reference, not a calibrated trading signal.

The publication chart also shows the raw MOVE and VIX lines. To recreate those lines, use MOVE as the main chart and add VIX with TradingView's Compare function on a separate price scale. The Pine script supplies the normalized panels and table; it does not add the raw comparison line automatically.

DATA HANDLING AND LIMITATIONS

This implementation combines separate daily-source calculations, matching-trading-date checks, a dated summary table, and three selectable views. Each window is calculated in its index's own daily context. Missing values are not replaced by zero or forward-filled into the difference. An incomplete window or an unchanged, zero-width range returns no value.

Source trading dates must match each other and the chart bar. The table can retain an older complete pair during an interruption; check its As of date. The source windows can cover slightly different calendar spans, and VIX-only sessions do not appear on a MOVE chart even though they count in VIX's own window.

A session is plotted once its scheduled close has passed when the script runs. Pine runs when the chart updates, so a newly closed session and its crossing mark may require a chart reload. Data feeds can be delayed or revised. Crossing marks are not drawn across missing bars. Only standard daily charts are supported.

The indicator describes relative positions in historical ranges. It does not predict that one index will catch up with the other and contains no trade execution or tested trading strategy.

## Source Code

````pine
// This Pine Script code is subject to the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Copyright Heard_Floor
//@version=6
indicator("MOVE vs VIX - 1-Year Range Position", shorttitle="MOVE-VIX Range", overlay=false, precision=2)

// Fixed index sources: the displayed instrument NEVER supplies prices.
// Primary/comparison windows default to 252/504 DAILY closes on every chart.
// Carry the latest mapped matching pair across host-market holidays/weekends.
// Host trading hours can delay mapping: inspect the source date in the table.
// Reload after the source close if the date remains stale; updates need a tick.
// Component panels use matched dates too; unpaired source sessions are held.
// Use MOVE price / MOVE / VIX price / VIX for four compact stacked panes.
// MOVE/VIX oscillators compare their own primary and comparison ranges.
// Combined and Difference views retain the primary-window comparison.
string panel = input.string("Difference", "Panel", options=["MOVE", "VIX", "MOVE + VIX", "Difference", "MOVE price", "VIX price"], group="Display")
bool fractionScale = input.bool(true, "Use 0-1 scale", group="Display")
bool showTable = input.bool(true, "Show table when Panel is Difference", group="Display")
bool showComponentTable = input.bool(true, "Show compact component readings and date", group="Display")
bool highlightCrossings = input.bool(true, "Mark upward threshold crossings on the price chart", group="Display",
     tooltip="Crossings use the displayed samples. A weekly/monthly chart can omit crossings that happened between its samples; inspect the daily chart for those.")
string moveSymbol = input.symbol("TVC:MOVE", "MOVE symbol", group="Calculation")
string vixSymbol = input.symbol("TVC:VIX", "VIX symbol", group="Calculation")
int length = input.int(252, "Daily closes in window", minval=2, maxval=1250, group="Calculation")
int comparisonLength = input.int(504, "Comparison window (daily closes)", minval=2, maxval=2500, group="Calculation",
     tooltip="252 and 504 daily closing observations approximate one and two trading years. These are rolling close-to-close ranges, not statistical percentile ranks.")
float threshold = input.float(60.0, "Difference threshold (percentage points)", minval=0, maxval=100, step=1, group="Calculation")
color moveColor = input.color(color.rgb(160, 160, 160), "MOVE line", group="Colors")
color vixColor = input.color(color.rgb(230, 160, 55), "VIX line", group="Colors")
color comparisonColor = input.color(color.blue, "Comparison-window line", group="Colors")
color positiveColor = input.color(color.rgb(34, 139, 65), "Positive difference", group="Colors")
color negativeColor = input.color(color.rgb(180, 45, 45), "Negative difference", group="Colors")

if barstate.isfirst and (not chart.is_standard or str.contains(timeframe.period, "T"))
    runtime.error("Use a standard time-based chart (line, bars, or candles). Daily, weekly and other time intervals are supported.")

if barstate.isfirst and (str.length(moveSymbol) == 0 or str.length(vixSymbol) == 0)
    runtime.error("Choose explicit MOVE and VIX symbols. A blank source would use the chart symbol.")

dailyStats() =>
    float lo = ta.lowest(close, length)
    float hi = ta.highest(close, length)
    float valid = math.sum(na(close) ? 0.0 : 1.0, length)
    bool full = bar_index >= length - 1 and valid == length
    float position = full and hi > lo ? 100.0 * (close - lo) / (hi - lo) : na
    float comparisonLo = ta.lowest(close, comparisonLength)
    float comparisonHi = ta.highest(close, comparisonLength)
    float comparisonValid = math.sum(na(close) ? 0.0 : 1.0, comparisonLength)
    bool comparisonFull = bar_index >= comparisonLength - 1 and comparisonValid == comparisonLength
    float comparisonPosition = comparisonFull and comparisonHi > comparisonLo ? 100.0 * (close - comparisonLo) / (comparisonHi - comparisonLo) : na
    [position, time_tradingday, time_close, comparisonPosition, close, full ? lo : na, full ? hi : na, comparisonFull ? comparisonLo : na, comparisonFull ? comparisonHi : na]

// This entire snapshot executes on MOVE's DAILY bars. Nested requests keep each
// index's own daily history; only matching source dates can form a spread.
dailySnapshot() =>
    [m, md, me, mc, mp, ml, mh, mcl, mch] = request.security(moveSymbol, "1D", dailyStats(), gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_off, calc_bars_count=20000)
    [v, vd, ve, vc, vp, vl, vh, vcl, vch] = request.security(vixSymbol, "1D", dailyStats(), gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_off, calc_bars_count=20000)
    bool mr = not na(m) and not na(me) and me <= timenow and md == time_tradingday
    bool vr = not na(v) and not na(ve) and ve <= timenow and vd == time_tradingday
    bool paired = mr and vr and md == vd
    float difference = paired ? m - v : na
    var float lastM = na
    var float lastV = na
    var int lastDay = na
    var int lastEnd = na
    var float lastMC = na
    var float lastVC = na
    var float lastMP = na
    var float lastVP = na
    var float lastML = na
    var float lastMH = na
    var float lastVL = na
    var float lastVH = na
    var float lastMCL = na
    var float lastMCH = na
    var float lastVCL = na
    var float lastVCH = na
    if paired
        lastM := m
        lastV := v
        lastDay := md
        lastEnd := math.max(me, ve)
        lastMC := mc
        lastVC := vc
        lastMP := mp
        lastVP := vp
        lastML := ml
        lastMH := mh
        lastVL := vl
        lastVH := vh
        lastMCL := mcl
        lastMCH := mch
        lastVCL := vcl
        lastVCH := vch
    [mr ? m : na, vr ? v : na, difference, time_tradingday, lastM, lastV, lastDay, lastEnd, lastMC, lastVC, lastMP, lastVP, lastML, lastMH, lastVL, lastVH, lastMCL, lastMCH, lastVCL, lastVCH]

[dailyM, dailyV, dailySpread, dailyDay, lastM, lastV, lastDay, lastEnd, lastMC, lastVC, lastMP, lastVP, lastML, lastMH, lastVL, lastVH, lastMCL, lastMCH, lastVCL, lastVCH] = request.security(moveSymbol, "1D", dailySnapshot(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, calc_bars_count=20000)

// No comparison to the HOST's session date: that hid otherwise valid data.
// These held values and their date are produced inside MOVE's source context.
float moveRange = lastM
float vixRange = lastV
float spread = lastM - lastV
int sampleDay = lastDay
bool showMove = panel == "MOVE" or panel == "MOVE + VIX"
bool showVix = panel == "VIX" or panel == "MOVE + VIX"
bool moveComponent = panel == "MOVE" or panel == "MOVE price"
bool vixComponent = panel == "VIX" or panel == "VIX price"
bool showMovePrice = panel == "MOVE price"
bool showVixPrice = panel == "VIX price"
bool pricePanel = showMovePrice or showVixPrice
bool positionPanel = showMove or showVix
float divisor = fractionScale ? 100.0 : 1.0
bool differencePanel = panel == "Difference"

plot(showMove ? moveRange / divisor : na, "MOVE range position", color=moveColor, linewidth=1, style=plot.style_linebr, display=showMove ? display.all : display.none)
plot(showVix ? vixRange / divisor : na, "VIX range position", color=vixColor, linewidth=1, style=plot.style_linebr, display=showVix ? display.all : display.none)
plot(panel == "MOVE" ? lastMC / divisor : na, "MOVE comparison range position", color=comparisonColor, linewidth=1, style=plot.style_linebr, linestyle=plot.linestyle_dashed, display=panel == "MOVE" ? display.all : display.none)
plot(panel == "VIX" ? lastVC / divisor : na, "VIX comparison range position", color=comparisonColor, linewidth=1, style=plot.style_linebr, linestyle=plot.linestyle_dashed, display=panel == "VIX" ? display.all : display.none)
// Price guides show only the latest comparison range, not older rolling ranges.
plot(showMovePrice ? lastMP : na, "MOVE actual close", color=moveColor, linewidth=1, style=plot.style_linebr, display=showMovePrice ? display.all : display.none)
plot(showMovePrice ? lastMCL : na, "MOVE comparison-window low", color=color.new(chart.fg_color, 60), style=plot.style_linebr, trackprice=true, show_last=1, display=showMovePrice ? display.all : display.none)
plot(showMovePrice ? lastMCH : na, "MOVE comparison-window high", color=color.new(chart.fg_color, 60), style=plot.style_linebr, trackprice=true, show_last=1, display=showMovePrice ? display.all : display.none)
plot(showVixPrice ? lastVP : na, "VIX actual close", color=vixColor, linewidth=1, style=plot.style_linebr, display=showVixPrice ? display.all : display.none)
plot(showVixPrice ? lastVCL : na, "VIX comparison-window low", color=color.new(chart.fg_color, 60), style=plot.style_linebr, trackprice=true, show_last=1, display=showVixPrice ? display.all : display.none)
plot(showVixPrice ? lastVCH : na, "VIX comparison-window high", color=color.new(chart.fg_color, 60), style=plot.style_linebr, trackprice=true, show_last=1, display=showVixPrice ? display.all : display.none)
plot(differencePanel ? spread / divisor : na, "MOVE minus VIX", color=spread >= 0 ? positiveColor : negativeColor, style=plot.style_columns, histbase=0, display=differencePanel ? display.all : display.none)
plot(differencePanel ? spread / divisor : na, "Difference outline", color=chart.fg_color, linewidth=1, style=plot.style_linebr, display=differencePanel ? display.pane : display.none)
plot(moveRange, "Range MOVE (%)", display=display.data_window)
plot(vixRange, "Range VIX (%)", display=display.data_window)
plot(spread, "Range difference (pp)", display=display.data_window)
plot(lastMC, "Range MOVE comparison (%)", display=display.data_window)
plot(lastVC, "Range VIX comparison (%)", display=display.data_window)
plot(lastMP, "Range MOVE source close", display=display.data_window)
plot(lastVP, "Range VIX source close", display=display.data_window)
plot(lastML, "Range MOVE primary low", display=display.data_window)
plot(lastMH, "Range MOVE primary high", display=display.data_window)
plot(lastVL, "Range VIX primary low", display=display.data_window)
plot(lastVH, "Range VIX primary high", display=display.data_window)
plot(lastMCL, "Range MOVE comparison low", display=display.data_window)
plot(lastMCH, "Range MOVE comparison high", display=display.data_window)
plot(lastVCL, "Range VIX comparison low", display=display.data_window)
plot(lastVCH, "Range VIX comparison high", display=display.data_window)
float sourceDate = na(sampleDay) ? na : year(sampleDay, "UTC") * 10000 + month(sampleDay, "UTC") * 100 + dayofmonth(sampleDay, "UTC")
plot(sourceDate, "Range source date (YYYYMMDD)", display=display.data_window)
plot(sampleDay / 1000.0, "Range source session (Unix seconds)", display=display.data_window)
hline(0, "Zero", color=color.new(chart.fg_color, 50), display=pricePanel ? display.none : display.all)
hline(100.0 / divisor, "Range maximum", color=color.new(chart.fg_color, 80), display=positionPanel ? display.all : display.none)
hline(50.0 / divisor, "Range midpoint", color=color.new(chart.fg_color, 85), linestyle=hline.style_dotted, display=positionPanel ? display.all : display.none)
hline(threshold / divisor, "Positive difference threshold", color=color.orange, linestyle=hline.style_solid, display=differencePanel ? display.all : display.none)
bool crossedUp = ta.crossover(spread, threshold)
bgcolor(differencePanel and highlightCrossings and crossedUp ? color.new(color.orange, 35) : na, title="Threshold crossing (displayed samples)", force_overlay=true)

percentText(float value) =>
    na(value) ? "N/A" : str.tostring(value, "0.00") + "%"
spreadText(float value) =>
    na(value) ? "N/A" : (value > 0 ? "+" : "") + str.tostring(value, "0.00") + " pp"
numberText(float value) =>
    na(value) ? "N/A" : str.tostring(value, "0.00")

// Per-pane readings keep raw index units separate from normalized percentages.
// They use exactly the same held matched source day as the plotted lines.
var table component = table.new(position.top_right, 2, 3, bgcolor=color.new(chart.bg_color, 12))
if barstate.islast and showComponentTable and (moveComponent or vixComponent)
    string primaryName = length == 252 ? "1Y (252)" : str.tostring(length) + " closes"
    string comparisonName = comparisonLength == 504 ? "2Y (504)" : str.tostring(comparisonLength) + " closes"
    float rawValue = moveComponent ? lastMP : lastVP
    float primaryValue = moveComponent ? lastM : lastV
    float comparisonValue = moveComponent ? lastMC : lastVC
    float comparisonLow = moveComponent ? lastMCL : lastVCL
    float comparisonHigh = moveComponent ? lastMCH : lastVCH
    string asOf = na(lastDay) ? "N/A" : str.format_time(lastDay, "yyyy-MM-dd", "UTC")
    table.cell(component, 0, 0, pricePanel ? (moveComponent ? "MOVE close" : "VIX close") : primaryName, text_color=chart.fg_color, text_size=size.small)
    table.cell(component, 1, 0, pricePanel ? numberText(rawValue) : percentText(primaryValue), text_color=chart.fg_color, text_size=size.small)
    table.cell(component, 0, 1, pricePanel ? comparisonName + " L/H" : comparisonName, text_color=chart.fg_color, text_size=size.small)
    table.cell(component, 1, 1, pricePanel ? numberText(comparisonLow) + " / " + numberText(comparisonHigh) : percentText(comparisonValue), text_color=chart.fg_color, text_size=size.small)
    table.cell(component, 0, 2, "As of", text_color=chart.fg_color, text_size=size.small)
    table.cell(component, 1, 2, asOf, text_color=chart.fg_color, text_size=size.small)

var table values = table.new(position.top_right, 2, 7, bgcolor=color.new(chart.bg_color, 8), frame_color=color.new(chart.fg_color, 75), frame_width=1, force_overlay=true)
if barstate.islast and differencePanel and showTable
    float lastSpread = lastM - lastV
    string asOf = na(lastDay) ? "N/A" : str.format_time(lastDay, "yyyy-MM-dd", "UTC")
    string status = na(lastDay) ? "No valid matched pair / history / flat range" : "Held matched daily closes"
    table.cell(values, 0, 0, "MOVE range", text_color=chart.fg_color, text_size=size.small)
    table.cell(values, 1, 0, percentText(lastM), text_color=chart.fg_color, text_size=size.small)
    table.cell(values, 0, 1, "VIX range", text_color=chart.fg_color, text_size=size.small)
    table.cell(values, 1, 1, percentText(lastV), text_color=chart.fg_color, text_size=size.small)
    table.cell(values, 0, 2, "MOVE - VIX", text_color=chart.fg_color, text_size=size.small)
    table.cell(values, 1, 2, spreadText(lastSpread), text_color=na(lastSpread) ? chart.fg_color : lastSpread >= 0 ? positiveColor : negativeColor, text_size=size.small)
    table.cell(values, 0, 3, "As of", text_color=chart.fg_color, text_size=size.small)
    table.cell(values, 1, 3, asOf, text_color=chart.fg_color, text_size=size.small)
    table.cell(values, 0, 4, "Window", text_color=chart.fg_color, text_size=size.small)
    table.cell(values, 1, 4, str.tostring(length) + " daily closes", text_color=chart.fg_color, text_size=size.small)
    table.cell(values, 0, 5, "Status", text_color=chart.fg_color, text_size=size.small)
    table.cell(values, 1, 5, status, text_color=chart.fg_color, text_size=size.small)
    table.cell(values, 0, 6, "Feeds", text_color=chart.fg_color, text_size=size.small)
    table.cell(values, 1, 6, moveSymbol + " / " + vixSymbol, text_color=chart.fg_color, text_size=size.small)
````
