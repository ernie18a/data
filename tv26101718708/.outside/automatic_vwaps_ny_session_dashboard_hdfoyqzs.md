# Automatic VWAPs & NY Session Dashboard

- url: https://www.tradingview.com/script/hdFOYQzS-Automatic-VWAPs-NY-Session-Dashboard/
- type: indicator
- pine_id: PUB;bea366aba5fb46f6bfadcdad11af9a88
- version: 1.0

## Description

This indicator is built for index futures traders who want key session-based VWAP levels and opening range context in one place.

It combines several VWAP references that are useful during the New York session, especially for traders watching NQ, ES, and YM together. The script uses **OHLC4** as its VWAP source and is designed to give a cleaner read on where price is trading relative to important session anchors. The code includes a dashboard and opening range tools in addition to the plotted VWAP lines.

**Included levels**

Daily VWAP: resets from the futures day changeover at 6:00 PM New York time
NY VWAP: starts from the 9:30 AM New York session open
PD NY VWAP: based on the previous New York session anchor
HOD VWAP: anchored from the current futures-day high
LOD VWAP: anchored from the current futures-day low
Opening Range: based on 9:30–9:45 AM New York time and displayed with high/low boundaries and a box
Dashboard: compares the current chart symbol and up to two additional futures symbols using VWAP location, opening range status, and trend state.

How it works
The script separates full futures-day context from New York session context.

The Daily VWAP tracks the broader futures session from the prior evening’s 6:00 PM New York reset. The NY VWAP focuses only on the regular New York session beginning at 9:30 AM. The PD NY VWAP is intended to carry forward prior New York session context so traders can compare current price location against a previous session reference. The HOD and LOD VWAPs update from the futures-day high and low anchors, which can help show whether price is holding above or below important intraday extremes. The opening range section tracks the first 15 minutes of the New York session and displays whether price is still inside that range or has moved outside of it.

Dashboard
The dashboard is meant to provide a quick market context check across up to three futures symbols. It shows whether price is above or below major VWAP references, whether the market is inside or outside the opening range, and a simple trend state based on the combined VWAP positioning. This is useful for traders who want to compare whether NQ, ES, and YM are aligned or diverging during the New York session.

How to use it
This indicator is best used as a session-structure and context tool rather than a standalone entry system.

Some ways it can be used:

* Identify whether price is trading above or below current session VWAPs
* Compare current price to prior New York session context
* Use HOD and LOD VWAPs as dynamic intraday reference levels
* Track whether price is still inside the New York opening range or has broken out
* Check whether NQ, ES, and YM are showing aligned strength or weakness through the dashboard

Suggested use case
This script is most useful for traders focused on the New York session, especially index futures traders who want both:

1. a broader futures-day reference from the 6:00 PM reset, and
2. a more focused regular-session read from the 9:30 AM New York open.

It can help organize session bias, opening range structure, and cross-market confirmation into one chart.

This indicator is for chart analysis and market context. It does not generate trade advice by itself, and it should be used together with your own execution rules and risk management.

## Source Code

````pine
//@version=6
indicator("Automatic VWAPs", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=100)

// =========================
// INPUTS
// =========================
groupDash = "Dashboard"
showTable = input.bool(true, "Show Dashboard", group=groupDash)
dashPosInput = input.string("Top Right", "Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=groupDash)
sym1 = input.symbol("CME_MINI:NQ1!", "Symbol 1", group=groupDash)
sym2 = input.symbol("CME_MINI:ES1!", "Symbol 2", group=groupDash)
sym3 = input.symbol("CBOT_MINI:YM1!", "Symbol 3", group=groupDash)
groupVis = "Visibility"
showDaily  = input.bool(true,  "Daily VWAP (6 PM ET)", group=groupVis)
showNY     = input.bool(true,  "NY VWAP", group=groupVis)
showPDNY   = input.bool(true,  "PD NY VWAP", group=groupVis)
showHOD    = input.bool(true,  "High of Day VWAP", group=groupVis)
showLOD    = input.bool(true,  "Low of Day VWAP", group=groupVis)
showOR     = input.bool(true,  "Opening Range", group=groupVis)
showLabels = input.bool(true,  "Last-Bar Labels", group=groupVis)
showORBox  = input.bool(true,  "Opening Range Box", group=groupVis)

groupStyle = "Style"
colDaily = input.color(color.new(color.red, 0), "Daily VWAP", group=groupStyle)
colNY    = input.color(color.new(color.blue, 0), "NY VWAP", group=groupStyle)
colPDNY  = input.color(color.new(color.aqua, 0), "PD NY VWAP", group=groupStyle)
colHOD   = input.color(color.new(color.purple, 0), "HOD VWAP", group=groupStyle)
colLOD   = input.color(color.new(color.fuchsia, 0), "LOD VWAP", group=groupStyle)
colOR    = input.color(color.new(color.black, 0), "Opening Range", group=groupStyle)
orFill   = input.int(92, "OR Box Opacity", minval=0, maxval=100, group=groupStyle)

groupSess = "Sessions"
tz = input.string("America/New_York", "Timezone", group=groupSess)

// =========================
// SOURCE
// =========================
src = ohlc4

// =========================
// TIME LOGIC
// =========================
curHour   = hour(time, tz)
curMinute = minute(time, tz)
curYear   = year(time, tz)
curMonth  = month(time, tz)
curDay    = dayofmonth(time, tz)

prevHour   = hour(time[1], tz)
prevMinute = minute(time[1], tz)

is1800Reset = (curHour == 18 and curMinute == 0) and not (prevHour == 18 and prevMinute == 0)
is0930Reset = (curHour == 9 and curMinute == 30) and not (prevHour == 9 and prevMinute == 30)

inNYSession = ((curHour > 9) or (curHour == 9 and curMinute >= 30)) and (curHour < 16)
inOR        = ((curHour > 9) or (curHour == 9 and curMinute >= 30)) and ((curHour < 9) or (curHour == 9 and curMinute <= 45))

// =========================
// CUMULATIVE TOTALS
// =========================
cumPV = ta.cum(src * volume)
cumV  = ta.cum(volume)

f_vwap_from_base(_basePV, _baseV) =>
    den = cumV - _baseV
    den > 0 ? (cumPV - _basePV) / den : na

// =========================
// DAILY VWAP
// Reset at 6:00 PM ET
// =========================
var float dailyBasePV = 0.0
var float dailyBaseV  = 0.0

if barstate.isfirst
    dailyBasePV := 0.0
    dailyBaseV  := 0.0
else if is1800Reset
    dailyBasePV := nz(cumPV[1], 0.0)
    dailyBaseV  := nz(cumV[1], 0.0)

dailyVWAP = f_vwap_from_base(dailyBasePV, dailyBaseV)

// =========================
// NY VWAP + PD NY VWAP
// =========================
var float nyBasePV = na
var float nyBaseV  = na

var float pdNyBasePV = na
var float pdNyBaseV  = na

if is0930Reset
    pdNyBasePV := nyBasePV
    pdNyBaseV  := nyBaseV

    nyBasePV   := nz(cumPV[1], 0.0)
    nyBaseV    := nz(cumV[1], 0.0)

nyVWAP_full   = not na(nyBasePV)   ? f_vwap_from_base(nyBasePV, nyBaseV)     : na
pdNyVWAP_full = not na(pdNyBasePV) ? f_vwap_from_base(pdNyBasePV, pdNyBaseV) : na

nyVWAP   = inNYSession ? nyVWAP_full : na
pdNyVWAP = inNYSession ? pdNyVWAP_full : na

// =========================
// HOD / LOD VWAP
// Reset on futures day at 6:00 PM ET
// =========================
var float futHigh = na
var float futLow  = na

var float hodBasePV = na
var float hodBaseV  = na
var float lodBasePV = na
var float lodBaseV  = na

if barstate.isfirst or is1800Reset
    futHigh := high
    futLow  := low

    hodBasePV := nz(cumPV[1], 0.0)
    hodBaseV  := nz(cumV[1], 0.0)
    lodBasePV := nz(cumPV[1], 0.0)
    lodBaseV  := nz(cumV[1], 0.0)
else
    if high >= nz(futHigh, high)
        futHigh := high
        hodBasePV := nz(cumPV[1], 0.0)
        hodBaseV  := nz(cumV[1], 0.0)

    if low <= nz(futLow, low)
        futLow := low
        lodBasePV := nz(cumPV[1], 0.0)
        lodBaseV  := nz(cumV[1], 0.0)

hodVWAP = not na(hodBasePV) ? f_vwap_from_base(hodBasePV, hodBaseV) : na
lodVWAP = not na(lodBasePV) ? f_vwap_from_base(lodBasePV, lodBaseV) : na

// =========================
// OPENING RANGE 9:30 - 9:45 ET
// =========================
var float orHigh = na
var float orLow  = na
var box   orBox  = na

if is0930Reset
    orHigh := high
    orLow  := low

    if not na(orBox)
        box.delete(orBox)
        orBox := na

    if showOR and showORBox
        orBox := box.new(bar_index, high, bar_index, low, bgcolor=color.new(colOR, orFill), border_color=colOR)
else if inOR
    orHigh := na(orHigh) ? high : math.max(orHigh, high)
    orLow  := na(orLow)  ? low  : math.min(orLow, low)

    if showOR and showORBox and not na(orBox)
        box.set_top(orBox, orHigh)
        box.set_bottom(orBox, orLow)
        box.set_right(orBox, bar_index)

if showOR and showORBox and not na(orBox) and not inOR
    box.set_right(orBox, bar_index)
    box.set_top(orBox, orHigh)
    box.set_bottom(orBox, orLow)
// =========================
// DASHBOARD VALUES
// =========================
orStatus = na(orHigh) or na(orLow) ? "N/A" : close > orHigh ? "Outside Up" : close < orLow ? "Outside Down" : "Inside"

bullCount = 0
bullCount += not na(nyVWAP)   and close > nyVWAP   ? 1 : 0
bullCount += not na(dailyVWAP) and close > dailyVWAP ? 1 : 0
bullCount += not na(pdNyVWAP) and close > pdNyVWAP ? 1 : 0
bullCount += not na(lodVWAP)  and close > lodVWAP  ? 1 : 0
bullCount += not na(hodVWAP)  and close > hodVWAP  ? 1 : 0

trendText =
     bullCount >= 5 ? "Strong Up" :
     bullCount == 4 ? "Up" :
     bullCount == 3 ? "Mixed" :
     bullCount == 2 ? "Mixed" :
     bullCount == 1 ? "Down" :
     "Strong Down"

trendColor =
     bullCount >= 4 ? color.lime :
     bullCount <= 1 ? color.red :
     color.yellow
// =========================
// MULTI-SYMBOL DASHBOARD HELPERS
// Dashboard only — does not affect your plotted lines
// =========================
f_daily_vwap_dash() =>
    _src = ohlc4
    _cumPV = ta.cum(_src * volume)
    _cumV  = ta.cum(volume)

    _curHour   = hour(time, tz)
    _curMinute = minute(time, tz)
    _prevHour   = hour(time[1], tz)
    _prevMinute = minute(time[1], tz)

    _is1800Reset = (_curHour == 18 and _curMinute == 0) and not (_prevHour == 18 and _prevMinute == 0)

    var float _basePV = 0.0
    var float _baseV  = 0.0

    if barstate.isfirst
        _basePV := 0.0
        _baseV  := 0.0
    else if _is1800Reset
        _basePV := nz(_cumPV[1], 0.0)
        _baseV  := nz(_cumV[1], 0.0)

    _den = _cumV - _baseV
    _den > 0 ? (_cumPV - _basePV) / _den : na

f_ny_vwap_dash() =>
    _src = ohlc4
    _cumPV = ta.cum(_src * volume)
    _cumV  = ta.cum(volume)

    _curHour   = hour(time, tz)
    _curMinute = minute(time, tz)
    _prevHour   = hour(time[1], tz)
    _prevMinute = minute(time[1], tz)

    _is0930Reset = (_curHour == 9 and _curMinute == 30) and not (_prevHour == 9 and _prevMinute == 30)
    _inNY = ((_curHour > 9) or (_curHour == 9 and _curMinute >= 30)) and (_curHour < 16)

    var float _nyBasePV = na
    var float _nyBaseV  = na

    if _is0930Reset
        _nyBasePV := nz(_cumPV[1], 0.0)
        _nyBaseV  := nz(_cumV[1], 0.0)

    _den = _cumV - _nyBaseV
    _v = _den > 0 ? (_cumPV - _nyBasePV) / _den : na
    _inNY ? _v : na

f_pdny_vwap_dash() =>
    _src = ohlc4
    _cumPV = ta.cum(_src * volume)
    _cumV  = ta.cum(volume)

    _curHour   = hour(time, tz)
    _curMinute = minute(time, tz)
    _prevHour   = hour(time[1], tz)
    _prevMinute = minute(time[1], tz)

    _is0930Reset = (_curHour == 9 and _curMinute == 30) and not (_prevHour == 9 and _prevMinute == 30)
    _inNY = ((_curHour > 9) or (_curHour == 9 and _curMinute >= 30)) and (_curHour < 16)

    var float _nyBasePV = na
    var float _nyBaseV  = na
    var float _pdBasePV = na
    var float _pdBaseV  = na

    if _is0930Reset
        _pdBasePV := _nyBasePV
        _pdBaseV  := _nyBaseV
        _nyBasePV := nz(_cumPV[1], 0.0)
        _nyBaseV  := nz(_cumV[1], 0.0)

    _den = _cumV - _pdBaseV
    _v = _den > 0 ? (_cumPV - _pdBasePV) / _den : na
    _inNY ? _v : na

f_hod_vwap_dash() =>
    _src = ohlc4
    _cumPV = ta.cum(_src * volume)
    _cumV  = ta.cum(volume)

    _curHour   = hour(time, tz)
    _curMinute = minute(time, tz)
    _prevHour   = hour(time[1], tz)
    _prevMinute = minute(time[1], tz)

    _is1800Reset = (_curHour == 18 and _curMinute == 0) and not (_prevHour == 18 and _prevMinute == 0)

    var float _futHigh = na
    var float _basePV = na
    var float _baseV  = na

    if barstate.isfirst or _is1800Reset
        _futHigh := high
        _basePV := nz(_cumPV[1], 0.0)
        _baseV  := nz(_cumV[1], 0.0)
    else
        if high >= nz(_futHigh, high)
            _futHigh := high
            _basePV := nz(_cumPV[1], 0.0)
            _baseV  := nz(_cumV[1], 0.0)

    _den = _cumV - _baseV
    _den > 0 ? (_cumPV - _basePV) / _den : na

f_lod_vwap_dash() =>
    _src = ohlc4
    _cumPV = ta.cum(_src * volume)
    _cumV  = ta.cum(volume)

    _curHour   = hour(time, tz)
    _curMinute = minute(time, tz)
    _prevHour   = hour(time[1], tz)
    _prevMinute = minute(time[1], tz)

    _is1800Reset = (_curHour == 18 and _curMinute == 0) and not (_prevHour == 18 and _prevMinute == 0)

    var float _futLow = na
    var float _basePV = na
    var float _baseV  = na

    if barstate.isfirst or _is1800Reset
        _futLow := low
        _basePV := nz(_cumPV[1], 0.0)
        _baseV  := nz(_cumV[1], 0.0)
    else
        if low <= nz(_futLow, low)
            _futLow := low
            _basePV := nz(_cumPV[1], 0.0)
            _baseV  := nz(_cumV[1], 0.0)

    _den = _cumV - _baseV
    _den > 0 ? (_cumPV - _basePV) / _den : na

f_or_state_dash() =>
    _curHour   = hour(time, tz)
    _curMinute = minute(time, tz)
    _prevHour   = hour(time[1], tz)
    _prevMinute = minute(time[1], tz)

    _is0930Reset = (_curHour == 9 and _curMinute == 30) and not (_prevHour == 9 and _prevMinute == 30)
    _inOR = ((_curHour > 9) or (_curHour == 9 and _curMinute >= 30)) and ((_curHour < 9) or (_curHour == 9 and _curMinute <= 45))

    var float _orHigh = na
    var float _orLow  = na

    if _is0930Reset
        _orHigh := high
        _orLow  := low
    else if _inOR
        _orHigh := na(_orHigh) ? high : math.max(_orHigh, high)
        _orLow  := na(_orLow) ? low : math.min(_orLow, low)

    close > _orHigh ? 1 : close < _orLow ? -1 : 0

f_trend_score_dash() =>
    _close = close
    _ny    = f_ny_vwap_dash()
    _daily = f_daily_vwap_dash()
    _pdny  = f_pdny_vwap_dash()
    _lod   = f_lod_vwap_dash()
    _hod   = f_hod_vwap_dash()

    _bull = 0
    _bull += not na(_ny) and _close > _ny ? 1 : 0
    _bull += not na(_daily) and _close > _daily ? 1 : 0
    _bull += not na(_pdny) and _close > _pdny ? 1 : 0
    _bull += not na(_lod) and _close > _lod ? 1 : 0
    _bull += not na(_hod) and _close > _hod ? 1 : 0
    _bull
// =========================
// PLOTS
// =========================
plot(showDaily ? dailyVWAP : na, "Daily VWAP", color=colDaily, linewidth=2)
plot(showNY ? nyVWAP : na, "NY VWAP", color=colNY, linewidth=2)
plot(showPDNY ? pdNyVWAP : na, "PD NY VWAP", color=colPDNY, linewidth=2)
plot(showHOD ? hodVWAP : na, "HOD VWAP", color=colHOD, linewidth=2)
plot(showLOD ? lodVWAP : na, "LOD VWAP", color=colLOD, linewidth=2)

plot(showOR and not na(orHigh) ? orHigh : na, "OR High", color=colOR, linewidth=1)
plot(showOR and not na(orLow)  ? orLow  : na, "OR Low",  color=colOR, linewidth=1)

// =========================
// LIVE LABELS
// =========================
var label lblDaily = na
var label lblNY    = na
var label lblPDNY  = na
var label lblHOD   = na
var label lblLOD   = na
var label lblORH   = na
var label lblORL   = na

if barstate.islast
    // Daily
    if showLabels and showDaily and not na(dailyVWAP)
        if na(lblDaily)
            lblDaily := label.new(bar_index, dailyVWAP, "Daily VWAP", style=label.style_label_left, color=color.new(colDaily, 70), textcolor=color.white, size=size.small)
        else
            label.set_x(lblDaily, bar_index)
            label.set_y(lblDaily, dailyVWAP)
            label.set_text(lblDaily, "Daily VWAP")
            label.set_color(lblDaily, color.new(colDaily, 70))
            label.set_textcolor(lblDaily, color.white)
    else if not na(lblDaily)
        label.delete(lblDaily)
        lblDaily := na

    // NY
    if showLabels and showNY and inNYSession and not na(nyVWAP)
        if na(lblNY)
            lblNY := label.new(bar_index, nyVWAP, "NY VWAP", style=label.style_label_left, color=color.new(colNY, 70), textcolor=color.white, size=size.small)
        else
            label.set_x(lblNY, bar_index)
            label.set_y(lblNY, nyVWAP)
            label.set_text(lblNY, "NY VWAP")
            label.set_color(lblNY, color.new(colNY, 70))
            label.set_textcolor(lblNY, color.white)
    else if not na(lblNY)
        label.delete(lblNY)
        lblNY := na

    // PD NY
    if showLabels and showPDNY and inNYSession and not na(pdNyVWAP)
        if na(lblPDNY)
            lblPDNY := label.new(bar_index, pdNyVWAP, "PD NY VWAP", style=label.style_label_left, color=color.new(colPDNY, 70), textcolor=color.white, size=size.small)
        else
            label.set_x(lblPDNY, bar_index)
            label.set_y(lblPDNY, pdNyVWAP)
            label.set_text(lblPDNY, "PD NY VWAP")
            label.set_color(lblPDNY, color.new(colPDNY, 70))
            label.set_textcolor(lblPDNY, color.white)
    else if not na(lblPDNY)
        label.delete(lblPDNY)
        lblPDNY := na

    // HOD
    if showLabels and showHOD and not na(hodVWAP)
        if na(lblHOD)
            lblHOD := label.new(bar_index, hodVWAP, "HOD VWAP", style=label.style_label_left, color=color.new(colHOD, 70), textcolor=color.white, size=size.small)
        else
            label.set_x(lblHOD, bar_index)
            label.set_y(lblHOD, hodVWAP)
            label.set_text(lblHOD, "HOD VWAP")
            label.set_color(lblHOD, color.new(colHOD, 70))
            label.set_textcolor(lblHOD, color.white)
    else if not na(lblHOD)
        label.delete(lblHOD)
        lblHOD := na

    // LOD
    if showLabels and showLOD and not na(lodVWAP)
        if na(lblLOD)
            lblLOD := label.new(bar_index, lodVWAP, "LOD VWAP", style=label.style_label_left, color=color.new(colLOD, 70), textcolor=color.white, size=size.small)
        else
            label.set_x(lblLOD, bar_index)
            label.set_y(lblLOD, lodVWAP)
            label.set_text(lblLOD, "LOD VWAP")
            label.set_color(lblLOD, color.new(colLOD, 70))
            label.set_textcolor(lblLOD, color.white)
    else if not na(lblLOD)
        label.delete(lblLOD)
        lblLOD := na
// =========================
// MINI DASHBOARD - 3 SYMBOLS
// =========================
dashPos =
     dashPosInput == "Top Right" ? position.top_right :
     dashPosInput == "Top Left" ? position.top_left :
     dashPosInput == "Bottom Right" ? position.bottom_right :
     position.bottom_left

var table dash = table.new(dashPos, 4, 8, border_width=1)

f_bg() =>
    color.new(color.black, 15)

f_or_text(_state) => _state == 1 ? "Outside Up" : _state == -1 ? "Outside Down" : "Inside"

f_trend_text(_score) =>
     _score >= 5 ? "Strong Up" :
     _score == 4 ? "Up" :
     _score == 3 ? "Mixed" :
     _score == 2 ? "Mixed" :
     _score == 1 ? "Down" :
     "Strong Down"

f_trend_color(_score) =>
     _score >= 4 ? color.lime :
     _score <= 1 ? color.red :
     color.yellow

[s1Close, s1NY, s1Daily, s1PDNY, s1LOD, s1HOD, s1ORState, s1Trend] = request.security(sym1, timeframe.period, [close, f_ny_vwap_dash(), f_daily_vwap_dash(), f_pdny_vwap_dash(), f_lod_vwap_dash(), f_hod_vwap_dash(), f_or_state_dash(), f_trend_score_dash()])

[s2Close, s2NY, s2Daily, s2PDNY, s2LOD, s2HOD, s2ORState, s2Trend] = request.security(sym2, timeframe.period, [close, f_ny_vwap_dash(), f_daily_vwap_dash(), f_pdny_vwap_dash(), f_lod_vwap_dash(), f_hod_vwap_dash(), f_or_state_dash(), f_trend_score_dash()])

[s3Close, s3NY, s3Daily, s3PDNY, s3LOD, s3HOD, s3ORState, s3Trend] = request.security(sym3, timeframe.period, [close, f_ny_vwap_dash(), f_daily_vwap_dash(), f_pdny_vwap_dash(), f_lod_vwap_dash(), f_hod_vwap_dash(), f_or_state_dash(), f_trend_score_dash()])
if barstate.islast
    if showTable
        table.cell(dash, 0, 0, "Metric", text_color=color.white, bgcolor=color.new(color.blue, 80), text_size=size.tiny)
        table.cell(dash, 1, 0, str.replace(sym1, "CME_MINI:", ""), text_color=color.white, bgcolor=color.new(color.blue, 80), text_size=size.tiny)
        table.cell(dash, 2, 0, str.replace(sym2, "CME_MINI:", ""), text_color=color.white, bgcolor=color.new(color.blue, 80), text_size=size.tiny)
        table.cell(dash, 3, 0, str.replace(sym3, "CBOT_MINI:", ""), text_color=color.white, bgcolor=color.new(color.blue, 80), text_size=size.tiny)

        table.cell(dash, 0, 1, "NY VWAP", text_color=color.white, bgcolor=f_bg(), text_size=size.tiny)
        table.cell(dash, 1, 1, "●", text_color=not na(s1NY) and s1Close > s1NY ? color.lime : color.red, bgcolor=f_bg(), text_size=size.tiny)
        table.cell(dash, 2, 1, "●", text_color=not na(s2NY) and s2Close > s2NY ? color.lime : color.red, bgcolor=f_bg(), text_size=size.tiny)
        table.cell(dash, 3, 1, "●", text_color=not na(s3NY) and s3Close > s3NY ? color.lime : color.red, bgcolor=f_bg(), text_size=size.tiny)

        table.cell(dash, 0, 2, "Daily VWAP", text_color=color.white, bgcolor=f_bg(), text_size=size.tiny)
        table.cell(dash, 1, 2, "●", text_color=not na(s1Daily) and s1Close > s1Daily ? color.lime : color.red, bgcolor=f_bg(), text_size=size.tiny)
        table.cell(dash, 2, 2, "●", text_color=not na(s2Daily) and s2Close > s2Daily ? color.lime : color.red, bgcolor=f_bg(), text_size=size.tiny)
        table.cell(dash, 3, 2, "●", text_color=not na(s3Daily) and s3Close > s3Daily ? color.lime : color.red, bgcolor=f_bg(), text_size=size.tiny)

        table.cell(dash, 0, 3, "PD NY VWAP", text_color=color.white, bgcolor=f_bg(), text_size=size.tiny)
        table.cell(dash, 1, 3, "●", text_color=not na(s1PDNY) and s1Close > s1PDNY ? color.lime : color.red, bgcolor=f_bg(), text_size=size.tiny)
        table.cell(dash, 2, 3, "●", text_color=not na(s2PDNY) and s2Close > s2PDNY ? color.lime : color.red, bgcolor=f_bg(), text_size=size.tiny)
        table.cell(dash, 3, 3, "●", text_color=not na(s3PDNY) and s3Close > s3PDNY ? color.lime : color.red, bgcolor=f_bg(), text_size=size.tiny)

        table.cell(dash, 0, 4, "LOD VWAP", text_color=color.white, bgcolor=f_bg(), text_size=size.tiny)
        table.cell(dash, 1, 4, "●", text_color=not na(s1LOD) and s1Close > s1LOD ? color.lime : color.red, bgcolor=f_bg(), text_size=size.tiny)
        table.cell(dash, 2, 4, "●", text_color=not na(s2LOD) and s2Close > s2LOD ? color.lime : color.red, bgcolor=f_bg(), text_size=size.tiny)
        table.cell(dash, 3, 4, "●", text_color=not na(s3LOD) and s3Close > s3LOD ? color.lime : color.red, bgcolor=f_bg(), text_size=size.tiny)

        table.cell(dash, 0, 5, "HOD VWAP", text_color=color.white, bgcolor=f_bg(), text_size=size.tiny)
        table.cell(dash, 1, 5, "●", text_color=not na(s1HOD) and s1Close > s1HOD ? color.lime : color.red, bgcolor=f_bg(), text_size=size.tiny)
        table.cell(dash, 2, 5, "●", text_color=not na(s2HOD) and s2Close > s2HOD ? color.lime : color.red, bgcolor=f_bg(), text_size=size.tiny)
        table.cell(dash, 3, 5, "●", text_color=not na(s3HOD) and s3Close > s3HOD ? color.lime : color.red, bgcolor=f_bg(), text_size=size.tiny)

        table.cell(dash, 0, 6, "Opening Range", text_color=color.white, bgcolor=f_bg(), text_size=size.tiny)
        table.cell(dash, 1, 6, f_or_text(s1ORState), text_color=color.white, bgcolor=f_bg(), text_size=size.tiny)
        table.cell(dash, 2, 6, f_or_text(s2ORState), text_color=color.white, bgcolor=f_bg(), text_size=size.tiny)
        table.cell(dash, 3, 6, f_or_text(s3ORState), text_color=color.white, bgcolor=f_bg(), text_size=size.tiny)

        table.cell(dash, 0, 7, "Trend", text_color=color.white, bgcolor=f_bg(), text_size=size.tiny)
        table.cell(dash, 1, 7, f_trend_text(s1Trend), text_color=f_trend_color(s1Trend), bgcolor=f_bg(), text_size=size.tiny)
        table.cell(dash, 2, 7, f_trend_text(s2Trend), text_color=f_trend_color(s2Trend), bgcolor=f_bg(), text_size=size.tiny)
        table.cell(dash, 3, 7, f_trend_text(s3Trend), text_color=f_trend_color(s3Trend), bgcolor=f_bg(), text_size=size.tiny)
    else
        table.clear(dash, 0, 0, 3, 7)
````
