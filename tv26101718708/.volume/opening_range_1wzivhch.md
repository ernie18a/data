# Opening Range

- url: https://www.tradingview.com/script/1wzivhCH-Opening-Range/
- type: indicator
- pine_id: PUB;8d233bda82954bc987e1648f1e9a0c77
- version: 1.0

## Description

9:30 Opening Range volume table and lines. Has many options for customization of the ORB and also open source for anyone that wants to change it.

## Source Code

````pine
//@version=6
indicator("9:30–9:35 ORB + Historical Comparison", shorttitle = "ORB 9:35 + Stats", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

showHist = input.bool(true, title = "Show Historical Data", group = "Historical Display", tooltip = "Displays All Data from Previous Sessions")

crSesh = "0930-0935"
tz     = input.string("UTC-4", title = "Timezone (EDT=UTC-4, EST=UTC-5)", group = "Opening Range",
     options = ["UTC-5","UTC-4"], tooltip = "Use UTC-4 during Daylight Saving Time (Mar–Nov). Use UTC-5 in winter (Nov–Mar).")

extremeTol = input.float(0.1, title = "Open Extreme Tolerance %", group = "Opening Range",
     tooltip = "How close the open must be to the bar high or low to qualify as an extreme. 0.1 = within 10% of the bar range from either end.") * 0.01

sigTog       = input.bool(true,   title = "Show Breakout Signals",   group = "Breakout Signals")
useBias      = input.string("No Bias", title = "Signal Bias", options = ["No Bias","Daily Bias"], group = "Breakout Signals") == "No Bias" ? false : true
sigSize      = str.lower(input.string("Small", title = "Signal Size", options = ["Tiny","Small","Normal","Large","Huge"], group = "Breakout Signals"))
upSigColor   = input.color(#089981, title = "Up Color",   group = "Breakout Signals", inline = "Colors")
downSigColor = input.color(#f23645, title = "Down Color", group = "Breakout Signals", inline = "Colors")

boCandleTog     = input.bool(false,         title = "Color Breakout Candle", group = "Breakout Signals")
boCandleUpColor = input.color(color.yellow, title = "  Up Breakout Candle", group = "Breakout Signals", inline = "BoCandle")
boCandleDnColor = input.color(color.fuchsia,title = "Down Breakout Candle", group = "Breakout Signals", inline = "BoCandle")

tTog     = input.bool(true,   title = "Show Targets",         group = "Targets")
tPer     = input.float(50, minval = 1, title = "Target % of Range", group = "Targets") * 0.01
tSrc     = input.string("Close", title = "Target Cross Source", options = ["Close","Highs/Lows"], group = "Targets")
tDispType= input.string("Adaptive", title = "Target Display", options = ["Adaptive","Extended"], group = "Targets")

maTog   = input.bool(false, title = "", inline = "MA", group = "Session Moving Average")
maLen   = input.int(20,     title = "", inline = "MA", group = "Session Moving Average")
maType  = input.string("EMA", title = "", options=["SMA","EMA","RMA","WMA","VWMA"], inline = "MA", group = "Session Moving Average")
maColor = input.color(color.orange, title = "", inline = "MA", group = "Session Moving Average")

green      = input.color(color.new(#089981,60), title = " Bull Target Color", group = "Style", inline = "Bull")
red        = input.color(color.new(#f23645,60), title = "Bear Target Color",  group = "Style", inline = "Bear")
greenFill  = input.color(color.new(#089981,80), title = " Bull Fill Color",   group = "Style", inline = "Bull")
redFill    = input.color(color.new(#f23645,80), title = "Bear Fill Color",    group = "Style", inline = "Bear")
orColor    = input.color(#787b86,               title = "   OR Levels Color", group = "Style", inline = "Range")
orFillColor= input.color(color.new(color.gray,60), title = "OR Highlight Color", group = "Style", inline = "Range")
tStyle     = input.string("___", title = "Target Style", options = ["___","- - -",". . ."], group = "Style")
txtSize    = str.lower(input.string("Small", title = "Text Size", options = ["Tiny","Small","Normal","Large","Huge"], group = "Style"))

show1mORB  = input.bool(false, title = "Show 1-Min ORB Levels", group = "1-Min ORB")
orb1mColor = input.color(color.new(color.aqua, 0), title = "1-Min ORB Color", group = "1-Min ORB")
orb1mThick = input.int(2,  title = "1-Min ORB Thickness", group = "1-Min ORB", minval = 1, maxval = 4)
orb1mStyle = input.string("- - -", title = "1-Min ORB Style", options = ["___","- - -",". . ."], group = "1-Min ORB")

showStatsTable = input.bool(true, title = "Show Table", group = "Historical Comparison Table")
numHistBars    = input.int(10, minval = 2, maxval = 50, title = "Sessions to Average", group = "Historical Comparison Table")
tblTextSize    = input.string("Normal", title = "Table Text Size", options = ["Tiny","Small","Normal","Large","Huge"], group = "Historical Comparison Table")
tblPos         = input.string("Top Right", title = "Table Position",
     options = ["Top Right","Top Left","Top Center","Bottom Right","Bottom Left","Bottom Center","Middle Right","Middle Left"],
     group = "Historical Comparison Table")

tblHeaderBg   = input.color(color.new(#2a2a2a, 10), title = "Header Background", group = "Historical Comparison Table", inline = "bg1")
tblRowBg      = input.color(color.new(#1a1a1a, 20), title = "Row Background",     group = "Historical Comparison Table", inline = "bg1")
tblHeaderTxt  = input.color(color.white,                title = "Header Text", group = "Historical Comparison Table", inline = "txt1")
tblLabelTxt   = input.color(color.new(color.white, 20), title = "Label Text",  group = "Historical Comparison Table", inline = "txt1")
tblValueTxt   = input.color(color.white,                title = "Value Text",  group = "Historical Comparison Table", inline = "txt1")

tblLowColor    = input.color(#089981, title = "Low Color    (<75%)",    group = "Historical Comparison Table", inline = "pct")
tblNormalColor = input.color(#e2a63a, title = "Normal Color (75–125%)", group = "Historical Comparison Table", inline = "pct")
tblHighColor   = input.color(#f23645, title = "High Color   (>125%)",   group = "Historical Comparison Table", inline = "pct")

tblBorderColor = input.color(color.new(color.gray, 40), title = "Border Color", group = "Historical Comparison Table")

invis = color.rgb(0,0,0,100)

if timeframe.in_seconds(timeframe.period) >= timeframe.in_seconds("D")
    runtime.error("Timeframe is too High! Please Reduce Timeframe to be Less-Than 1 Day.")

fz(_val) => _val == 0 ? 1 : _val

day_ma(_start,_type,s,l) =>
    bs_nd = fz(ta.barssince(_start))
    v_len = bs_nd < l ? bs_nd : l
    var float ma = na
    if _type == "EMA"
        k = 2/(v_len + 1)
        ma := (s*k) + (nz(ma[1])*(1-k))
    if _type == "RMA"
        a = (1/v_len)
        ma := a * s + (1 - a) * nz(ma[1])
    if _type == "SMA"
        ma := ta.sma(s,v_len)
    if _type == "WMA"
        ma := ta.wma(s,v_len)
    if _type == "VWMA"
        ma := ta.vwma(s,v_len)
    ma

linestyle(_input) =>
    _input == "___"   ? line.style_solid  :
     _input == "- - -" ? line.style_dashed :
     _input == ". . ." ? line.style_dotted : na

get_1up(_val) => (_val - math.floor(_val)) > 0 ? int(math.floor(_val) + 1) : int(_val)

tbl_size(_s) =>
    _s == "Tiny"   ? size.tiny   :
     _s == "Small"  ? size.small  :
     _s == "Normal" ? size.normal :
     _s == "Large"  ? size.large  :
     _s == "Huge"   ? size.huge   : size.normal

tbl_pos(_p) =>
    _p == "Top Right"     ? position.top_right     :
     _p == "Top Left"      ? position.top_left      :
     _p == "Top Center"    ? position.top_center    :
     _p == "Bottom Right"  ? position.bottom_right  :
     _p == "Bottom Left"   ? position.bottom_left   :
     _p == "Bottom Center" ? position.bottom_center :
     _p == "Middle Right"  ? position.middle_right  :
     _p == "Middle Left"   ? position.middle_left   : position.top_right

type target
    line  ln
    label lab

var up_targs   = array.new<target>(na)
var down_targs = array.new<target>(na)
var signals    = array.new_label()

var bool or_sesh  = false
var bool or_token = false

var float orh      = na
var float orl      = na
var float hst      = na
var float lst      = na
var float prev_orm = na
var float day_open = na

var int up_count   = na
var int down_count = na
var box or_bx      = na
var int day_dir    = 0
var down_check     = false
var up_check       = false
down_signal        = false
up_signal          = false

var target h_ln = target.new(na,na)
var target l_ln = target.new(na,na)
var int or_start_bar = na

var line orb1m_high_line = na
var line orb1m_low_line  = na
var float orb1m_h = na
var float orb1m_l = na

// Volume tracking
var hist_volumes    = array.new_float(0)
var float orb_vol   = na
var bool  in_or_vol = false

var table stats_tbl = na
var bool open_at_extreme = false
var bool is_ee_candle    = false

[is1mFirst, high1m, low1m] = request.security(
     syminfo.tickerid, "1",
     [session.isfirstbar, high, low],
     gaps      = barmerge.gaps_off,
     lookahead = barmerge.lookahead_on)

if is1mFirst and show1mORB
    orb1m_h := high1m
    orb1m_l := low1m
    line.delete(orb1m_high_line)
    line.delete(orb1m_low_line)
    orb1m_high_line := line.new(bar_index, orb1m_h, bar_index + 2, orb1m_h,
         color = orb1mColor, width = orb1mThick, style = linestyle(orb1mStyle))
    orb1m_low_line  := line.new(bar_index, orb1m_l, bar_index + 2, orb1m_l,
         color = orb1mColor, width = orb1mThick, style = linestyle(orb1mStyle))

if show1mORB and not na(orb1m_high_line)
    line.set_x2(orb1m_high_line, bar_index + 2)
    line.set_x2(orb1m_low_line,  bar_index + 2)

orm = not na(orh) and not na(orl) ? math.avg(orh, orl) : na

h_src = tSrc == "Close" ? close : high
l_src = tSrc == "Close" ? close : low

or_sesh := not na(time(timeframe.period, crSesh, tz))
or_start = or_sesh and not or_sesh[1]
or_end   = or_sesh[1] and not or_sesh

if or_start
    or_start_bar    := bar_index
    day_open        := open
    open_at_extreme := false
    is_ee_candle    := false
    orb_vol         := 0.0
    in_or_vol       := true

    for targ in up_targs
        if showHist == false
            targ.ln.delete()
        targ.lab.delete()
    for targ in down_targs
        if showHist == false
            targ.ln.delete()
        targ.lab.delete()
    for lab in signals
        if showHist == false
            lab.delete()
    if showHist == false
        or_bx.delete()
        h_ln.ln.delete()
        l_ln.ln.delete()
    h_ln.lab.delete()
    l_ln.lab.delete()
    up_targs.clear()
    down_targs.clear()
    orh        := high
    orl        := low
    prev_orm   := orm[1]
    up_count   := 0
    down_count := 0
    up_check   := true
    down_check := true
    or_bx    := box.new(bar_index, high, bar_index, low, bgcolor = orFillColor, border_width = 0)
    or_token := false

if or_sesh
    if high > orh
        orh := high
    if low < orl
        orl := low
    or_bx.set_top(orh)
    or_bx.set_bottom(orl)
    or_bx.set_right(bar_index)
    if orh != orl
        or_token := true
    // Accumulate volume during ORB session
    if in_or_vol
        orb_vol := nz(orb_vol) + volume

if or_end and or_token
    in_or_vol := false
    h_ln := target.new(
         line.new(or_start_bar, orh, bar_index + 2, orh, color = orColor),
         label.new(bar_index + 2, orh, text = "ORH", tooltip = str.tostring(orh, format.mintick),
              style = label.style_label_left, color = invis, textcolor = color.new(orColor,0), size = txtSize))
    l_ln := target.new(
         line.new(or_start_bar, orl, bar_index + 2, orl, color = orColor),
         label.new(bar_index + 2, orl, text = "ORL", tooltip = str.tostring(orl, format.mintick),
              style = label.style_label_left, color = invis, textcolor = color.new(orColor,0), size = txtSize))

    completed_range = math.abs(orh - orl)
    hst := orh + (completed_range * tPer)
    lst := orl - (completed_range * tPer)

    day_dir := orm > prev_orm ? 1 : orm < prev_orm ? -1 : 0
    linefill.new(h_ln.ln, l_ln.ln, day_dir == 1 ? greenFill : day_dir == -1 ? redFill : invis)

    // Store ORB volume for this session
    if not na(orb_vol) and orb_vol > 0
        hist_volumes.push(orb_vol)
        if hist_volumes.size() > numHistBars
            hist_volumes.shift()

    tol_pts         = completed_range * extremeTol
    open_at_extreme := day_open <= (orl + tol_pts) or day_open >= (orh - tol_pts)
    is_ee_candle    := open_at_extreme

if not or_sesh and or_token
    h_ln.ln.set_x2(bar_index + 2)
    l_ln.ln.set_x2(bar_index + 2)
    h_ln.lab.set_x(bar_index + 2)
    l_ln.lab.set_x(bar_index + 2)

market_close = session.ismarket[1] and not session.ismarket

if market_close and or_token
    if not na(or_bx)
        or_bx.delete()
    if not na(h_ln.ln)
        h_ln.ln.delete()
        h_ln.lab.delete()
    if not na(l_ln.ln)
        l_ln.ln.delete()
        l_ln.lab.delete()
    for targ in up_targs
        targ.ln.delete()
        targ.lab.delete()
    for targ in down_targs
        targ.ln.delete()
        targ.lab.delete()
    for lab in signals
        lab.delete()
    up_targs.clear()
    down_targs.clear()
    or_token := false

cur_range = not na(orh) and not na(orl) ? math.abs(orh - orl) : na

if not na(hst) and h_src > hst
    hst := h_src
if not na(lst) and l_src < lst
    lst := l_src

up_max   = not na(cur_range) and cur_range > 0 ? get_1up((nz(hst) - orh) / (cur_range * tPer)) : 0
down_max = not na(cur_range) and cur_range > 0 ? get_1up((orl - nz(lst)) / (cur_range * tPer)) : 0
up_cur   = not na(cur_range) and cur_range > 0 ? math.max(0, get_1up((h_src - orh) / (cur_range * tPer))) : 0
down_cur = not na(cur_range) and cur_range > 0 ? math.max(0, get_1up((orl - l_src) / (cur_range * tPer))) : 0

if (close > orm and down_check == false)
    down_check := true
xdown  = ta.crossunder(close, orl)
xdown2 = not na(cur_range) ? ta.crossunder(close, orl - cur_range * tPer) : false
if (useBias ? ((day_dir != 1 and xdown) or (day_dir == 1 and xdown2)) : ta.crossunder(close, orl)) and down_check
    down_signal := true
    down_check  := false

if (close < orm and up_check == false)
    up_check := true
xup  = ta.crossover(close, orh)
xup2 = not na(cur_range) ? ta.crossover(close, orh + cur_range * tPer) : false
if (useBias ? ((day_dir != -1 and xup) or (day_dir == -1 and xup2)) : ta.crossover(close, orh)) and up_check
    up_signal := true
    up_check  := false

barcolor(is_ee_candle and or_end ? color.new(color.orange, 0) : na, offset = -1, title = "EE ORB Candle")

// ── Volume table calculations ─────────────────────────────────────────────────
// Current live ORB volume (accumulating during session, or completed)
live_orb_vol = in_or_vol ? nz(orb_vol) : na
hist_vol_avg = hist_volumes.size() > 0 ? hist_volumes.avg() : na

// Use live vol during session, otherwise use last completed orb_vol for % calc
cur_vol_for_pct = in_or_vol ? nz(orb_vol) : orb_vol
pct_of_avg_vol  = not na(cur_vol_for_pct) and not na(hist_vol_avg) and hist_vol_avg > 0
     ? (cur_vol_for_pct / hist_vol_avg) * 100 : na

pct_vol_clr = not na(pct_of_avg_vol)
     ? (pct_of_avg_vol < 75  ? tblLowColor    :
         pct_of_avg_vol < 125 ? tblNormalColor :
         tblHighColor)
     : tblValueTxt

// Format volume with K/M suffix
fmt_vol(_v) =>
    _v >= 1000000 ? str.tostring(math.round(_v / 1000000, 2)) + "M" :
     _v >= 1000    ? str.tostring(math.round(_v / 1000, 1))   + "K" :
     str.tostring(math.round(_v, 0))

ts = tbl_size(tblTextSize)

if showStatsTable and barstate.islast
    if na(stats_tbl)
        stats_tbl := table.new(tbl_pos(tblPos), columns = 2, rows = 4,
             bgcolor      = tblRowBg,
             border_color = tblBorderColor,
             border_width = 1,
             frame_color  = tblBorderColor,
             frame_width  = 1)

    tbl = stats_tbl

    // Header
    table.cell(tbl, 0, 0, "ORB Vol", text_color = tblHeaderTxt,
         bgcolor = tblHeaderBg, text_size = ts, text_halign = text.align_center)
    table.merge_cells(tbl, 0, 0, 1, 0)

    // Avg Vol row
    avg_label = hist_volumes.size() > 0
         ? str.tostring(hist_volumes.size()) + "-Session Avg Vol"
         : "Avg (building...)"
    table.cell(tbl, 0, 1, avg_label, text_color = tblLabelTxt,
         bgcolor = tblRowBg, text_size = ts)
    table.cell(tbl, 1, 1,
         not na(hist_vol_avg) ? fmt_vol(hist_vol_avg) : "—",
         text_color = tblValueTxt, bgcolor = tblRowBg,
         text_size = ts, text_halign = text.align_right)

    // % of Avg row
    table.cell(tbl, 0, 2, "% of Avg", text_color = tblLabelTxt,
         bgcolor = tblRowBg, text_size = ts)
    table.cell(tbl, 1, 2,
         not na(pct_of_avg_vol) ? str.tostring(math.round(pct_of_avg_vol, 1)) + "%" : "—",
         text_color = pct_vol_clr, bgcolor = tblRowBg,
         text_size = ts, text_halign = text.align_right)

    // Status row
    status_txt = not na(pct_of_avg_vol)
         ? (pct_of_avg_vol < 75  ? "Low"     :
             pct_of_avg_vol < 125 ? "Average" :
             "High")
         : hist_volumes.size() == 0 ? "Awaiting history" : "Calculating..."
    table.cell(tbl, 0, 3, status_txt, text_color = pct_vol_clr,
         bgcolor = tblHeaderBg, text_size = ts, text_halign = text.align_center)
    table.merge_cells(tbl, 0, 3, 1, 3)

if not or_sesh and or_token
    if up_count < up_max and tTog
        for i = (up_count + 1) to up_max
            up_targs.push(target.new(
              line.new(bar_index-1, (orh + cur_range * tPer * i), bar_index, (orh + cur_range * tPer * i), color = green, style = linestyle(tStyle)),
              label.new(bar_index,  (orh + cur_range * tPer * i), text = str.tostring(i), tooltip = str.tostring(orh + cur_range * tPer * i, format.mintick),
                   style = label.style_label_left, color = invis, textcolor = color.new(green,0), size = txtSize)))
            if i == up_max
                up_count := up_max
    if down_count < down_max and tTog
        for i = (down_count + 1) to down_max
            down_targs.push(target.new(
              line.new(bar_index-1, (orl - cur_range * tPer * i), bar_index, (orl - cur_range * tPer * i), color = red, style = linestyle(tStyle)),
              label.new(bar_index,  (orl - cur_range * tPer * i), text = str.tostring(i), tooltip = str.tostring(orl - cur_range * tPer * i, format.mintick),
                   style = label.style_label_left, color = invis, textcolor = color.new(red,0), size = txtSize)))
            if i == down_max
                down_count := down_max

if tDispType == "Extended" and tTog
    for targ in up_targs
        targ.ln.set_x2(bar_index)
        targ.lab.set_x(bar_index)
    for targ in down_targs
        targ.ln.set_x2(bar_index)
        targ.lab.set_x(bar_index)

if tDispType == "Adaptive" and tTog
    for targ in up_targs
        if targ.ln.get_y1() <= (orh + cur_range * tPer * up_cur) and targ.ln.get_y1() >= (orh + cur_range * tPer * (up_cur - 2))
            targ.ln.set_x2(bar_index + 1)
            targ.lab.set_x(bar_index + 1)
    for targ in down_targs
        if targ.ln.get_y1() <= (orl - cur_range * tPer * (down_cur - 2)) and targ.ln.get_y1() >= (orl - cur_range * tPer * down_cur)
            targ.ln.set_x2(bar_index + 1)
            targ.lab.set_x(bar_index + 1)

ma = day_ma(or_start, maType, close, maLen)
plot(or_start ? na : ma, style = plot.style_linebr, color = maColor,
     display = maTog ? display.all : display.none, title = "Moving Average", editable = false)

if up_signal and sigTog
    signals.push(label.new(bar_index, orl,
      style = label.style_label_center, text = "\n▲",
      color = invis, textcolor = upSigColor, size = sigSize))

if down_signal and sigTog
    signals.push(label.new(bar_index, orh,
      style = label.style_label_center, text = "▼\n",
      color = invis, textcolor = downSigColor, size = sigSize))

is_current_day = year == year(timenow) and month == month(timenow) and dayofmonth == dayofmonth(timenow)
barcolor(boCandleTog and is_current_day ? (up_signal ? boCandleUpColor : down_signal ? boCandleDnColor : na) : na, title = "Breakout Candle")
````
