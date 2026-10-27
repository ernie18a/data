# Multi-VWAP Dashboard V3 [NY/ON/PD/LOD/HOD + OR]

- url: https://www.tradingview.com/script/YTJlOcUT-Multi-VWAP-Dashboard-V3-NY-ON-PD-LOD-HOD-OR/
- type: indicator
- pine_id: PUB;47d536ed4ed24d3ca20b8c7840d78cc1
- version: 2.0

## Description

Indicator showing different VWAPS v3. Useful for trading VWAP bounce/break with ORB 15 min.

## Source Code

````pine
//@version=5
indicator("Multi-VWAP Dashboard [NY/ON/PD/LOD/HOD + OR]", shorttitle="Multi-VWAP", overlay=true, max_lines_count=500, max_boxes_count=500, max_labels_count=500, max_polylines_count=100)

// ============================================================================
// INPUTS
// ============================================================================

grpSym = "Symbols"
sym2Enable = input.bool(true, "Show 2nd symbol column", group=grpSym)
sym2       = input.symbol("CME_MINI:MES1!", "2nd symbol", group=grpSym, tooltip="Dashboard-only — no lines on chart.")
sym3Enable = input.bool(true, "Show 3rd symbol column", group=grpSym)
sym3       = input.symbol("CME_MINI:MYM1!", "3rd symbol", group=grpSym, tooltip="Dashboard-only — no lines on chart.")

grpSess = "Session Times (America/New_York)"
nyOpenTime    = input.session("0930-1600", "NY RTH Session", group=grpSess)
overnightOpen = input.session("1800-0929", "Overnight / ETH Session (info only)", group=grpSess, tooltip="Informational only. Overnight VWAP is now anchored at 18:00 ET directly (detected by clock) for reliability across midnight.")
orMinutes     = input.int(15,  "15-min Opening Range Duration (minutes)", minval=1, maxval=120, group=grpSess)
or1hMinutes   = input.int(60,  "1-Hour Opening Range Duration (minutes)", minval=1, maxval=240, group=grpSess)

grpSrc = "VWAP Source"
srcChoice = input.string("(H+L+C)/3", "Source", options=["Open","High","Low","Close","(H+L)/2","(H+L+C)/3","(O+H+L+C)/4","(H+L+C+C)/4"], group=grpSrc)

grpLines = "Line Styling (chart symbol only)"
showNY  = input.bool(true, "NY VWAP",        group=grpLines, inline="ny")
colNY   = input.color(color.new(#000000, 0), "Color", group=grpLines, inline="ny")
widNY   = input.int(2, "Width", minval=1, maxval=5, group=grpLines, inline="ny")

showON  = input.bool(true, "Overnight VWAP", group=grpLines, inline="on")
colON   = input.color(color.new(color.orange, 0), "Color", group=grpLines, inline="on")
widON   = input.int(2, "Width", minval=1, maxval=5, group=grpLines, inline="on")

showPD  = input.bool(true, "PD NY VWAP",     group=grpLines, inline="pd")
colPD   = input.color(color.new(color.blue, 0), "Color", group=grpLines, inline="pd")
widPD   = input.int(2, "Width", minval=1, maxval=5, group=grpLines, inline="pd")

showLOD = input.bool(true, "LOD VWAP",       group=grpLines, inline="lod")
colLOD  = input.color(color.new(color.purple, 0), "Color", group=grpLines, inline="lod")
widLOD  = input.int(2, "Width", minval=1, maxval=5, group=grpLines, inline="lod")

showHOD = input.bool(true, "HOD VWAP",       group=grpLines, inline="hod")
colHOD  = input.color(color.new(color.fuchsia, 0), "Color", group=grpLines, inline="hod")
widHOD  = input.int(2, "Width", minval=1, maxval=5, group=grpLines, inline="hod")

showOR  = input.bool(true, "15-min Opening Range", group=grpLines, inline="or")
colOR   = input.color(color.new(color.yellow, 70), "Fill",  group=grpLines, inline="or")
colORL  = input.color(color.new(color.yellow, 0),  "Line",  group=grpLines, inline="or")
widOR   = input.int(1, "Width", minval=1, maxval=5, group=grpLines, inline="or")

showOR1h = input.bool(true, "1-Hour Opening Range",  group=grpLines, inline="or1h")
colOR1h  = input.color(color.new(color.teal, 70),    "Fill",  group=grpLines, inline="or1h")
colOR1hL = input.color(color.new(color.teal, 0),     "Line",  group=grpLines, inline="or1h")
widOR1h  = input.int(1, "Width", minval=1, maxval=5, group=grpLines, inline="or1h")

grpDash = "Dashboard"
showDash    = input.bool(true, "Show Dashboard", group=grpDash)
showNearRow = input.bool(true, "Show 'Near NY VWAP' row", group=grpDash)
showORRow   = input.bool(true, "Show '15-min OR' row", group=grpDash)
showOR1hRow = input.bool(true, "Show '1-Hour OR' row", group=grpDash)
showXARow   = input.bool(true, "Show '15-min Crossed Above' row", group=grpDash)
showXBRow   = input.bool(true, "Show '15-min Crossed Below' row", group=grpDash)
showTrendRow= input.bool(true, "Show 'Trend' row", group=grpDash)
dashPos     = input.string("Bottom Right", "Position", options=["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group=grpDash)
dashSize    = input.string("Small", "Text Size", options=["Tiny","Small","Normal","Large"], group=grpDash)
proxUnit    = input.string("Ticks", "Near NY VWAP — unit", options=["Ticks","Points"], group=grpDash, inline="prox")
proxValue   = input.float(40.0, "threshold", minval=0.1, step=1.0, group=grpDash, inline="prox")

// ============================================================================
// HELPER FUNCTION — computes all 5 VWAPs + OR state given OHLCV
// ============================================================================

f_vwapSrc(o, h, l, c, choice) =>
    choice == "Open" ? o : choice == "High" ? h : choice == "Low" ? l : choice == "Close" ? c : choice == "(H+L)/2" ? (h+l)/2 : choice == "(H+L+C)/3" ? (h+l+c)/3 : choice == "(O+H+L+C)/4" ? (o+h+l+c)/4 : choice == "(H+L+C+C)/4" ? (h+l+c+c)/4 : (h+l+c)/3

f_computeAll(o, h, l, c, v, nyOpen, onOpen, orMin, or1hMin, srcCh) =>
    src = f_vwapSrc(o, h, l, c, srcCh)
    inNY_    = not na(time(timeframe.period, nyOpen, "America/New_York"))
    nyStart_ = inNY_  and not inNY_[1]
    nyEnd_   = not inNY_ and inNY_[1]

    // Detect 18:00 ET directly (more reliable than session strings that cross midnight).
    // We trigger onStart at the FIRST bar at or after 18:00 ET on each calendar day.
    nyHour   = hour(time, "America/New_York")
    nyMin    = minute(time, "America/New_York")
    nyDay    = dayofmonth(time, "America/New_York")
    is18etBar = nyHour == 18 and nyMin < 60   // any bar in the 18:00 hour
    // Mark first bar of a new "overnight day" — the first bar of the 18:00 hour each calendar day
    var int  lastOnAnchorDay = na
    onStart_ = false
    if is18etBar and (na(lastOnAnchorDay) or nyDay != lastOnAnchorDay)
        onStart_ := true
        lastOnAnchorDay := nyDay

    // NY VWAP
    var float ny_pv = 0.0
    var float ny_v  = 0.0
    if nyStart_
        ny_pv := src * v
        ny_v  := v
    else if inNY_
        ny_pv += src * v
        ny_v  += v
    ny_out = inNY_ and ny_v > 0 ? ny_pv / ny_v : na

    // Overnight VWAP
    var float on_pv = 0.0
    var float on_v  = 0.0
    var bool  on_active_ = false
    if onStart_
        on_pv := src * v
        on_v  := v
        on_active_ := true
    else
        on_pv += src * v
        on_v  += v
    if nyEnd_
        on_active_ := false
    on_out = on_active_ and on_v > 0 ? on_pv / on_v : na

    // Rolling NY VWAP
    var float rny_pv = 0.0
    var float rny_v  = 0.0
    if nyStart_
        rny_pv := src * v
        rny_v  := v
    else
        rny_pv += src * v
        rny_v  += v

    // PD NY VWAP
    var float pd_pv = 0.0
    var float pd_v  = 0.0
    var bool  pd_active_ = false
    if nyStart_
        pd_pv := nz(rny_pv[1], 0.0)
        pd_v  := nz(rny_v[1],  0.0)
        pd_active_ := true
    else
        pd_pv += src * v
        pd_v  += v
    if nyEnd_
        pd_active_ := false
    pd_out = pd_active_ and pd_v > 0 ? pd_pv / pd_v : na

    // LOD VWAP
    var float dayLow_ = na
    var float lod_pv  = 0.0
    var float lod_v   = 0.0
    if nyStart_
        dayLow_ := l
        lod_pv  := src * v
        lod_v   := v
    else if inNY_
        if l < nz(dayLow_, l + 1)
            dayLow_ := l
            lod_pv  := src * v
            lod_v   := v
        else
            lod_pv += src * v
            lod_v  += v
    lod_out = inNY_ and lod_v > 0 ? lod_pv / lod_v : na

    // HOD VWAP
    var float dayHigh_ = na
    var float hod_pv   = 0.0
    var float hod_v    = 0.0
    if nyStart_
        dayHigh_ := h
        hod_pv   := src * v
        hod_v    := v
    else if inNY_
        if h > nz(dayHigh_, h - 1)
            dayHigh_ := h
            hod_pv   := src * v
            hod_v    := v
        else
            hod_pv += src * v
            hod_v  += v
    hod_out = inNY_ and hod_v > 0 ? hod_pv / hod_v : na

    // Opening Range
    var int   orEndTime_ = na
    var float orHigh_    = na
    var float orLow_     = na
    if nyStart_
        orEndTime_ := time + orMin * 60 * 1000
        orHigh_    := h
        orLow_     := l
    inORWin = inNY_ and not na(orEndTime_) and time < orEndTime_
    if inORWin
        orHigh_ := math.max(nz(orHigh_, h), h)
        orLow_  := math.min(nz(orLow_,  l), l)

    or_valid_ = not na(orHigh_) and not na(orLow_)
    or_mid_   = or_valid_ ? (orHigh_ + orLow_) / 2 : na
    or_state_ = not or_valid_ ? 0 : c > orHigh_ ? 1 : c > or_mid_ ? 2 : c >= orLow_ ? 3 : 4

    // ----- 15-min Cross counters
    var int xAbove_ = 0
    var int xBelow_ = 0
    if nyStart_
        xAbove_ := 0
        xBelow_ := 0
    or_locked_ = inNY_ and not na(orEndTime_) and time >= orEndTime_
    if or_locked_ and or_valid_
        prevC = c[1]
        if not na(prevC)
            if prevC <= orHigh_ and c > orHigh_
                xAbove_ += 1
            if prevC >= orLow_  and c < orLow_
                xBelow_ += 1

    // ----- 1-Hour Opening Range
    var int   or1hEndTime_ = na
    var float or1hHigh_    = na
    var float or1hLow_     = na
    if nyStart_
        or1hEndTime_ := time + or1hMin * 60 * 1000
        or1hHigh_    := h
        or1hLow_     := l
    inOR1hWin = inNY_ and not na(or1hEndTime_) and time < or1hEndTime_
    if inOR1hWin
        or1hHigh_ := math.max(nz(or1hHigh_, h), h)
        or1hLow_  := math.min(nz(or1hLow_,  l), l)

    or1h_valid_ = not na(or1hHigh_) and not na(or1hLow_)
    or1h_mid_   = or1h_valid_ ? (or1hHigh_ + or1hLow_) / 2 : na
    or1h_state_ = not or1h_valid_ ? 0 : c > or1hHigh_ ? 1 : c > or1h_mid_ ? 2 : c >= or1hLow_ ? 3 : 4

    // ----- 1-Hour Cross counters
    var int x1hAbove_ = 0
    var int x1hBelow_ = 0
    if nyStart_
        x1hAbove_ := 0
        x1hBelow_ := 0
    or1h_locked_ = inNY_ and not na(or1hEndTime_) and time >= or1hEndTime_
    if or1h_locked_ and or1h_valid_
        prevC1h = c[1]
        if not na(prevC1h)
            if prevC1h <= or1hHigh_ and c > or1hHigh_
                x1hAbove_ += 1
            if prevC1h >= or1hLow_  and c < or1hLow_
                x1hBelow_ += 1

    [ny_out, on_out, pd_out, lod_out, hod_out, or_state_, orHigh_, orLow_, on_active_, pd_active_, nyStart_, nyEnd_, inNY_, inORWin, orEndTime_, xAbove_, xBelow_, or1h_state_, or1hHigh_, or1hLow_, inOR1hWin, or1hEndTime_, x1hAbove_, x1hBelow_]

// ============================================================================
// COMPUTE FOR CHART SYMBOL (native)
// ============================================================================

[ny_vwap, on_vwap, pd_vwap, lod_vwap, hod_vwap, or_state, orHigh, orLow, on_active, pd_active, nyStart, nyEnd, inNY, inORWindow, orEndTime, s1_xAbove, s1_xBelow, or1h_state, or1hHigh, or1hLow, inOR1hWindow, or1hEndTime, s1_x1hAbove, s1_x1hBelow] = f_computeAll(open, high, low, close, volume, nyOpenTime, overnightOpen, orMinutes, or1hMinutes, srcChoice)

// ============================================================================
// COMPUTE FOR SYMBOL 2 (via request.security)
// ============================================================================

f_sym2() =>
    [ny2, on2, pd2, lod2, hod2, or2, orH2, orL2, _ona, _pda, _ns, _ne, _iny, _iow, _oet, xa2, xb2, or1h2, or1hH2, or1hL2, _i1hw, _1het, x1ha2, x1hb2] = f_computeAll(open, high, low, close, volume, nyOpenTime, overnightOpen, orMinutes, or1hMinutes, srcChoice)
    a_ny  = not na(ny2)  and close > ny2
    a_on  = not na(on2)  and close > on2
    a_pd  = not na(pd2)  and close > pd2
    a_lod = not na(lod2) and close > lod2
    a_hod = not na(hod2) and close > hod2
    [a_ny, a_on, a_pd, a_lod, a_hod, or2, close, ny2, xa2, xb2, or1h2, x1ha2, x1hb2]

[s2_ny, s2_on, s2_pd, s2_lod, s2_hod, s2_or, s2_close, s2_nyv, s2_xAbove, s2_xBelow, s2_or1h, s2_x1hAbove, s2_x1hBelow] = request.security(sym2, timeframe.period, f_sym2(), lookahead=barmerge.lookahead_off)
[s3_ny, s3_on, s3_pd, s3_lod, s3_hod, s3_or, s3_close, s3_nyv, s3_xAbove, s3_xBelow, s3_or1h, s3_x1hAbove, s3_x1hBelow] = request.security(sym3, timeframe.period, f_sym2(), lookahead=barmerge.lookahead_off)

// ============================================================================
// OPENING RANGE DRAWING (chart symbol only)
// ============================================================================

var int   orStartTime  = na
var bool  orLocked     = false
var box   orBox        = na
var line  orHighLine   = na
var line  orLowLine    = na
var int   rthCloseTime = na

if nyStart
    orStartTime  := time
    orLocked     := false
    rthCloseTime := time + 6 * 60 * 60 * 1000 + 30 * 60 * 1000
    if not na(orBox)
        box.delete(orBox)
        orBox := na
    if not na(orHighLine)
        line.delete(orHighLine)
        orHighLine := na
    if not na(orLowLine)
        line.delete(orLowLine)
        orLowLine := na

if inNY and not na(orEndTime) and time >= orEndTime and not orLocked
    orLocked := true

if showOR and inORWindow
    if na(orBox)
        orBox := box.new(left=orStartTime, top=orHigh, right=orEndTime, bottom=orLow, xloc=xloc.bar_time, border_color=colORL, bgcolor=colOR)
    else
        box.set_top(orBox, orHigh)
        box.set_bottom(orBox, orLow)

if showOR and orLocked and na(orHighLine) and not na(orBox)
    orHighLine := line.new(x1=orStartTime, y1=orHigh, x2=rthCloseTime, y2=orHigh, xloc=xloc.bar_time, color=colORL, width=widOR)
    orLowLine  := line.new(x1=orStartTime, y1=orLow,  x2=rthCloseTime, y2=orLow,  xloc=xloc.bar_time, color=colORL, width=widOR)

// ============================================================================
// 1-HOUR OPENING RANGE DRAWING (chart symbol only)
// ============================================================================

var int   or1hStartTime = na
var bool  or1hLocked    = false
var box   or1hBox       = na
var line  or1hHighLine  = na
var line  or1hLowLine   = na

if nyStart
    or1hStartTime := time
    or1hLocked    := false
    if not na(or1hBox)
        box.delete(or1hBox)
        or1hBox := na
    if not na(or1hHighLine)
        line.delete(or1hHighLine)
        or1hHighLine := na
    if not na(or1hLowLine)
        line.delete(or1hLowLine)
        or1hLowLine := na

if inNY and not na(or1hEndTime) and time >= or1hEndTime and not or1hLocked
    or1hLocked := true

if showOR1h and inOR1hWindow
    if na(or1hBox)
        or1hBox := box.new(left=or1hStartTime, top=or1hHigh, right=or1hEndTime, bottom=or1hLow, xloc=xloc.bar_time, border_color=colOR1hL, bgcolor=colOR1h)
    else
        box.set_top(or1hBox, or1hHigh)
        box.set_bottom(or1hBox, or1hLow)

if showOR1h and or1hLocked and na(or1hHighLine) and not na(or1hBox)
    or1hHighLine := line.new(x1=or1hStartTime, y1=or1hHigh, x2=rthCloseTime, y2=or1hHigh, xloc=xloc.bar_time, color=colOR1hL, width=widOR1h)
    or1hLowLine  := line.new(x1=or1hStartTime, y1=or1hLow,  x2=rthCloseTime, y2=or1hLow,  xloc=xloc.bar_time, color=colOR1hL, width=widOR1h)

// ============================================================================
// LOD/HOD POLYLINE DRAWING (chart symbol)
// ============================================================================

var float dlow_track  = na
var float dhigh_track = na
var array<chart.point> lod_pts = array.new<chart.point>()
var polyline lod_pl = na
var array<chart.point> hod_pts = array.new<chart.point>()
var polyline hod_pl = na

if nyStart
    dlow_track  := low
    dhigh_track := high
    array.clear(lod_pts)
    array.clear(hod_pts)
    if not na(lod_pl)
        polyline.delete(lod_pl)
        lod_pl := na
    if not na(hod_pl)
        polyline.delete(hod_pl)
        hod_pl := na
else if inNY
    if low < nz(dlow_track, low + 1)
        dlow_track := low
        array.clear(lod_pts)
        if not na(lod_pl)
            polyline.delete(lod_pl)
            lod_pl := na
    if high > nz(dhigh_track, high - 1)
        dhigh_track := high
        array.clear(hod_pts)
        if not na(hod_pl)
            polyline.delete(hod_pl)
            hod_pl := na

if showLOD and inNY and not na(lod_vwap)
    array.push(lod_pts, chart.point.new(time, bar_index, lod_vwap))
    if not na(lod_pl)
        polyline.delete(lod_pl)
    if array.size(lod_pts) >= 2
        lod_pl := polyline.new(lod_pts, line_color=colLOD, line_width=widLOD, xloc=xloc.bar_time)

if showHOD and inNY and not na(hod_vwap)
    array.push(hod_pts, chart.point.new(time, bar_index, hod_vwap))
    if not na(hod_pl)
        polyline.delete(hod_pl)
    if array.size(hod_pts) >= 2
        hod_pl := polyline.new(hod_pts, line_color=colHOD, line_width=widHOD, xloc=xloc.bar_time)

// ============================================================================
// PLOTS — chart symbol
// ============================================================================

pd_plot = showPD and pd_active and not na(pd_vwap) ? pd_vwap : na

plot(showNY  and inNY      ? ny_vwap : na, "NY VWAP",        color=colNY, linewidth=widNY, style=plot.style_linebr)
plot(showON  and on_active ? on_vwap : na, "Overnight VWAP", color=colON, linewidth=widON, style=plot.style_linebr)
plot(pd_plot,                              "PD NY VWAP",     color=colPD, linewidth=widPD, style=plot.style_linebr)

// ============================================================================
// STATUS
// ============================================================================

proxDistance = proxUnit == "Ticks" ? proxValue * syminfo.mintick : proxValue

s1_ny  = not na(ny_vwap)  and close > ny_vwap
s1_on  = not na(on_vwap)  and close > on_vwap
s1_pd  = not na(pd_vwap)  and close > pd_vwap
s1_lod = not na(lod_vwap) and close > lod_vwap
s1_hod = not na(hod_vwap) and close > hod_vwap
s1_near = not na(ny_vwap) and math.abs(close - ny_vwap) <= proxDistance

// Count of ENABLED VWAPs and their greens. Trend now adapts to what's shown.
nEnabled = (showNY ? 1 : 0) + (showON ? 1 : 0) + (showPD ? 1 : 0) + (showLOD ? 1 : 0) + (showHOD ? 1 : 0)

s1_greens = (showNY and s1_ny ? 1 : 0) + (showON and s1_on ? 1 : 0) + (showPD and s1_pd ? 1 : 0) + (showLOD and s1_lod ? 1 : 0) + (showHOD and s1_hod ? 1 : 0)
s1_reds   = nEnabled - s1_greens
s1_trendText  = nEnabled == 0 ? "—" : s1_greens == nEnabled ? "Strong Up" : s1_reds == nEnabled ? "Strong Down" : (nEnabled >= 4 and s1_reds == nEnabled - 1) ? "Up" : (nEnabled >= 4 and s1_greens == nEnabled - 1) ? "Down" : "Mixed"
s1_trendColor = nEnabled == 0 ? color.new(color.gray, 0) : s1_greens == nEnabled ? color.new(color.lime, 0) : s1_reds == nEnabled ? color.new(color.red, 0) : (nEnabled >= 4 and s1_reds == nEnabled - 1) ? color.new(color.green, 0) : (nEnabled >= 4 and s1_greens == nEnabled - 1) ? color.new(color.maroon, 0) : color.new(color.gray, 0)

s2_near = not na(s2_nyv) and math.abs(s2_close - s2_nyv) <= proxDistance
s2_greens = (showNY and s2_ny ? 1 : 0) + (showON and s2_on ? 1 : 0) + (showPD and s2_pd ? 1 : 0) + (showLOD and s2_lod ? 1 : 0) + (showHOD and s2_hod ? 1 : 0)
s2_reds   = nEnabled - s2_greens
s2_trendText  = nEnabled == 0 ? "—" : s2_greens == nEnabled ? "Strong Up" : s2_reds == nEnabled ? "Strong Down" : (nEnabled >= 4 and s2_reds == nEnabled - 1) ? "Up" : (nEnabled >= 4 and s2_greens == nEnabled - 1) ? "Down" : "Mixed"
s2_trendColor = nEnabled == 0 ? color.new(color.gray, 0) : s2_greens == nEnabled ? color.new(color.lime, 0) : s2_reds == nEnabled ? color.new(color.red, 0) : (nEnabled >= 4 and s2_reds == nEnabled - 1) ? color.new(color.green, 0) : (nEnabled >= 4 and s2_greens == nEnabled - 1) ? color.new(color.maroon, 0) : color.new(color.gray, 0)

s3_near = not na(s3_nyv) and math.abs(s3_close - s3_nyv) <= proxDistance
s3_greens = (showNY and s3_ny ? 1 : 0) + (showON and s3_on ? 1 : 0) + (showPD and s3_pd ? 1 : 0) + (showLOD and s3_lod ? 1 : 0) + (showHOD and s3_hod ? 1 : 0)
s3_reds   = nEnabled - s3_greens
s3_trendText  = nEnabled == 0 ? "—" : s3_greens == nEnabled ? "Strong Up" : s3_reds == nEnabled ? "Strong Down" : (nEnabled >= 4 and s3_reds == nEnabled - 1) ? "Up" : (nEnabled >= 4 and s3_greens == nEnabled - 1) ? "Down" : "Mixed"
s3_trendColor = nEnabled == 0 ? color.new(color.gray, 0) : s3_greens == nEnabled ? color.new(color.lime, 0) : s3_reds == nEnabled ? color.new(color.red, 0) : (nEnabled >= 4 and s3_reds == nEnabled - 1) ? color.new(color.green, 0) : (nEnabled >= 4 and s3_greens == nEnabled - 1) ? color.new(color.maroon, 0) : color.new(color.gray, 0)

f_orText(st)  => st == 0 ? "—" : st == 1 ? "Above" : st == 2 ? "Upper Half" : st == 3 ? "Lower Half" : "Below"
f_orColor(st) => st == 0 ? color.new(color.gray, 0) : st == 1 ? color.new(color.lime, 0) : st == 2 ? color.new(color.green, 0) : st == 3 ? color.new(color.orange, 0) : color.new(color.red, 0)

// ============================================================================
// DASHBOARD
// ============================================================================

f_dashPos(p) => p == "Top Right" ? position.top_right : p == "Top Left" ? position.top_left : p == "Bottom Right" ? position.bottom_right : p == "Bottom Left" ? position.bottom_left : position.middle_right
f_size(s)    => s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Large" ? size.large : size.normal
f_dot(g)     => g ? "🟢" : "🔴"

f_shortTicker(s) =>
    parts = str.split(s, ":")
    array.size(parts) > 1 ? array.get(parts, 1) : s

var table dash = na
if showDash and barstate.islast
    if not na(dash)
        table.delete(dash)

    nCols = 2 + (sym2Enable ? 1 : 0) + (sym3Enable ? 1 : 0)

    // Count rows that will be rendered: header + enabled VWAPs + optional rows
    nRows = 1 + nEnabled + (showORRow ? 1 : 0) + (showOR1hRow ? 1 : 0) + (showXARow ? 1 : 0) + (showXBRow ? 1 : 0) + (showNearRow ? 1 : 0) + (showTrendRow ? 1 : 0)

    // Guard: table.new requires at least 1 row
    nRowsSafe = math.max(nRows, 1)

    dash := table.new(position=f_dashPos(dashPos), columns=nCols, rows=nRowsSafe, border_width=0, frame_color=color.new(color.gray, 50), frame_width=1)
    txt = f_size(dashSize)
    bgH = color.new(#0a1a2f, 0)
    bgR = color.new(#0a1a2f, 20)
    tc  = color.new(color.white, 0)

    sym1Label = syminfo.ticker
    sym2Label = f_shortTicker(sym2)
    sym3Label = f_shortTicker(sym3)
    s3col = sym2Enable ? 3 : 2

    // Running row index — increments as we add each row
    int r = 0

    // ---- Header ----
    table.cell(dash, 0, r, "Ticker",            bgcolor=bgH, text_color=tc, text_size=txt)
    table.cell(dash, 1, r, sym1Label,           bgcolor=bgH, text_color=color.yellow, text_size=txt)
    if sym2Enable
        table.cell(dash, 2, r, sym2Label,       bgcolor=bgH, text_color=color.yellow, text_size=txt)
    if sym3Enable
        table.cell(dash, s3col, r, sym3Label,   bgcolor=bgH, text_color=color.yellow, text_size=txt)
    r += 1

    // ---- NY VWAP ----
    if showNY
        table.cell(dash, 0, r, "NY VWAP",       bgcolor=bgR, text_color=tc, text_size=txt)
        table.cell(dash, 1, r, f_dot(s1_ny),    bgcolor=bgR, text_size=txt)
        if sym2Enable
            table.cell(dash, 2, r, f_dot(s2_ny),    bgcolor=bgR, text_size=txt)
        if sym3Enable
            table.cell(dash, s3col, r, f_dot(s3_ny),bgcolor=bgR, text_size=txt)
        r += 1

    // ---- Overnight VWAP ----
    if showON
        table.cell(dash, 0, r, "Overnight VWAP",bgcolor=bgR, text_color=tc, text_size=txt)
        table.cell(dash, 1, r, f_dot(s1_on),    bgcolor=bgR, text_size=txt)
        if sym2Enable
            table.cell(dash, 2, r, f_dot(s2_on),    bgcolor=bgR, text_size=txt)
        if sym3Enable
            table.cell(dash, s3col, r, f_dot(s3_on),bgcolor=bgR, text_size=txt)
        r += 1

    // ---- PD NY VWAP ----
    if showPD
        table.cell(dash, 0, r, "PD NY VWAP",    bgcolor=bgR, text_color=tc, text_size=txt)
        table.cell(dash, 1, r, f_dot(s1_pd),    bgcolor=bgR, text_size=txt)
        if sym2Enable
            table.cell(dash, 2, r, f_dot(s2_pd),    bgcolor=bgR, text_size=txt)
        if sym3Enable
            table.cell(dash, s3col, r, f_dot(s3_pd),bgcolor=bgR, text_size=txt)
        r += 1

    // ---- LOD VWAP ----
    if showLOD
        table.cell(dash, 0, r, "LOD VWAP",      bgcolor=bgR, text_color=tc, text_size=txt)
        table.cell(dash, 1, r, f_dot(s1_lod),   bgcolor=bgR, text_size=txt)
        if sym2Enable
            table.cell(dash, 2, r, f_dot(s2_lod),   bgcolor=bgR, text_size=txt)
        if sym3Enable
            table.cell(dash, s3col, r, f_dot(s3_lod),bgcolor=bgR, text_size=txt)
        r += 1

    // ---- HOD VWAP ----
    if showHOD
        table.cell(dash, 0, r, "HOD VWAP",      bgcolor=bgR, text_color=tc, text_size=txt)
        table.cell(dash, 1, r, f_dot(s1_hod),   bgcolor=bgR, text_size=txt)
        if sym2Enable
            table.cell(dash, 2, r, f_dot(s2_hod),   bgcolor=bgR, text_size=txt)
        if sym3Enable
            table.cell(dash, s3col, r, f_dot(s3_hod),bgcolor=bgR, text_size=txt)
        r += 1

    // ---- 15-min Opening Range state ----
    if showORRow
        table.cell(dash, 0, r, "15m OR",            bgcolor=bgR, text_color=tc, text_size=txt)
        table.cell(dash, 1, r, f_orText(or_state),  bgcolor=bgR, text_color=f_orColor(or_state), text_size=txt)
        if sym2Enable
            table.cell(dash, 2, r, f_orText(s2_or), bgcolor=bgR, text_color=f_orColor(s2_or), text_size=txt)
        if sym3Enable
            table.cell(dash, s3col, r, f_orText(s3_or), bgcolor=bgR, text_color=f_orColor(s3_or), text_size=txt)
        r += 1

    // ---- 15-min Crossed Above ----
    if showXARow
        table.cell(dash, 0, r, "15m Above OR",      bgcolor=bgR, text_color=tc, text_size=txt)
        table.cell(dash, 1, r, str.tostring(s1_xAbove), bgcolor=bgR, text_color=color.lime, text_size=txt)
        if sym2Enable
            table.cell(dash, 2, r, str.tostring(s2_xAbove), bgcolor=bgR, text_color=color.lime, text_size=txt)
        if sym3Enable
            table.cell(dash, s3col, r, str.tostring(s3_xAbove), bgcolor=bgR, text_color=color.lime, text_size=txt)
        r += 1

    // ---- 15-min Crossed Below ----
    if showXBRow
        table.cell(dash, 0, r, "15m Below OR",      bgcolor=bgR, text_color=tc, text_size=txt)
        table.cell(dash, 1, r, str.tostring(s1_xBelow), bgcolor=bgR, text_color=color.red, text_size=txt)
        if sym2Enable
            table.cell(dash, 2, r, str.tostring(s2_xBelow), bgcolor=bgR, text_color=color.red, text_size=txt)
        if sym3Enable
            table.cell(dash, s3col, r, str.tostring(s3_xBelow), bgcolor=bgR, text_color=color.red, text_size=txt)
        r += 1

    // ---- 1-Hour OR State ----
    if showOR1hRow
        table.cell(dash, 0, r, "1H OR",             bgcolor=bgR, text_color=tc, text_size=txt)
        table.cell(dash, 1, r, f_orText(or1h_state),bgcolor=bgR, text_color=f_orColor(or1h_state), text_size=txt)
        if sym2Enable
            table.cell(dash, 2, r, f_orText(s2_or1h), bgcolor=bgR, text_color=f_orColor(s2_or1h), text_size=txt)
        if sym3Enable
            table.cell(dash, s3col, r, f_orText(s3_or1h), bgcolor=bgR, text_color=f_orColor(s3_or1h), text_size=txt)
        r += 1

    // ---- Near NY VWAP ----
    if showNearRow
        table.cell(dash, 0, r, "Near NY VWAP",  bgcolor=bgR, text_color=tc, text_size=txt)
        table.cell(dash, 1, r, f_dot(s1_near),  bgcolor=bgR, text_size=txt)
        if sym2Enable
            table.cell(dash, 2, r, f_dot(s2_near),  bgcolor=bgR, text_size=txt)
        if sym3Enable
            table.cell(dash, s3col, r, f_dot(s3_near),bgcolor=bgR, text_size=txt)
        r += 1

    // ---- Trend ----
    if showTrendRow
        table.cell(dash, 0, r, "Trend",         bgcolor=bgH, text_color=tc, text_size=txt)
        table.cell(dash, 1, r, s1_trendText,    bgcolor=bgH, text_color=s1_trendColor, text_size=txt)
        if sym2Enable
            table.cell(dash, 2, r, s2_trendText,    bgcolor=bgH, text_color=s2_trendColor, text_size=txt)
        if sym3Enable
            table.cell(dash, s3col, r, s3_trendText,bgcolor=bgH, text_color=s3_trendColor, text_size=txt)
        r += 1
````
