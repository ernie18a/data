# Key opns [Stealth] 

- url: https://www.tradingview.com/script/wlW7UAAI-Key-opns-Stealth/
- type: indicator
- pine_id: PUB;406eeec90e84458a9abd47964e53f102
- version: 3.0

## Description

Marks the key intraday opening prices that institutional and ICT-style traders watch, plotted as clean horizontal lines that extend across the session.

Three opens, all anchored to New York time (DST handled automatically):
- 9:30 AM – the equities cash open
- 10:00 AM – the post-open reference level
- Daily Open – defaults to midnight (00:00 NY), the ICT "midnight open," and is configurable to any time (e.g. 18:00 for the futures open)

Minute-accurate on any timeframe. Instead of snapping to bar boundaries, the script reads 1-minute intrabar data, so the 9:30 open lands exactly on 9:30 even on a 1-hour chart rather than getting buried inside the 9:00 or 10:00 candle.

Customization:
- Toggle each open independently
- Line color, width, and style (dotted / dashed / solid)
- Adjustable text size (Tiny to Large), custom label text, optional price in the label, and custom text color
- Label offset to keep text clear of the candles
- "Days to display" control to limit how far back levels draw

Timeframe-aware: levels only render on the 1-hour timeframe and below, where intraday opens are actionable, and stay out of the way on higher timeframes.

Built for index traders (NAS100, SPX, etc.) but works on any symbol. Pairs with the companion Indices Sessions script for London / NY / PM range boxes.

## Source Code

````pine
//@version=6
// =============================================================================
//  INDICES OPEN  — dotted open lines (9:30 / 10:00 / Daily) + day separators
//  All times in New York (DST automatic). Visible on H1 and lower only.
// =============================================================================
indicator("Key Opns [stealth]", overlay = true, max_lines_count = 500, max_labels_count = 500)

ny = "America/New_York"

// ------------------------------- TOGGLES / TIMES ----------------------------
gO = "Opens"
show930        = input.bool(true,  "9:30 AM open",  group = gO)
show1000       = input.bool(true,  "10:00 AM open", group = gO)
showDaily      = input.bool(true,  "Daily open",    group = gO)
dailyOpenTime  = input.session("0000-0000", "Daily open time", tooltip = "Start time is used as the daily open. 00:00 = ICT midnight. e.g. 1800-1800 for futures open.", group = gO)
daysBack       = input.int(20, "Days to display", minval = 1, maxval = 60, group = gO)

// ------------------------------- LINE STYLE ---------------------------------
gL = "Lines"
col930    = input.color(color.gray,   "9:30 line",  group = gL, inline = "c1")
col1000   = input.color(color.orange, "10:00 line", group = gL, inline = "c2")
colDaily  = input.color(color.purple, "Daily line", group = gL, inline = "c3")
lw        = input.int(1, "Line width", minval = 1, maxval = 5, group = gL)
lineStyle = input.string("Dotted", "Line style", options = ["Dotted", "Dashed", "Solid"], group = gL)

// ------------------------------- LABELS -------------------------------------
gT = "Labels"
showOpenLabels = input.bool(true, "Show labels", group = gT)
txtSize  = input.string("Tiny", "Text size", options = ["Tiny", "Small", "Normal", "Large"], group = gT)
showPrice= input.bool(false, "Show price in label", group = gT)
txt930   = input.string("9:30",       "9:30 text",  group = gT, inline = "t1")
txt1000  = input.string("10:00",      "10:00 text", group = gT, inline = "t2")
txtDaily = input.string("Daily Open", "Daily text", group = gT, inline = "t3")
useCustomTxtCol = input.bool(false, "Custom text color", group = gT, inline = "tc")
customTxtCol    = input.color(color.white, "", group = gT, inline = "tc")
labelXoff = input.int(2, "Label offset (bars right)", minval = 0, maxval = 50, tooltip = "Push labels further right of the line end.", group = gT)

// --------------------------- DAY / WEEK SEPARATORS --------------------------
gD = "Day Separators"
showSep    = input.bool(true, "Show day separators", group = gD)
sepTime    = input.session("0000-0000", "Separator time", tooltip = "Start time of the vertical line. 00:00 = midnight, 1800-1800 = futures day open.", group = gD)
sepCol     = input.color(color.new(color.gray, 40), "Separator color", group = gD, inline = "s1")
sepStyle   = input.string("Dotted", "Style", options = ["Dotted", "Dashed", "Solid"], group = gD, inline = "s1")
sepWidth   = input.int(1, "Width", minval = 1, maxval = 4, group = gD)
emphWeek   = input.bool(true, "Stronger line at week start", group = gD)
weekCol    = input.color(color.new(color.gray, 0), "Week color", group = gD, inline = "s2")
weekWidth  = input.int(2, "Week width", minval = 1, maxval = 5, group = gD, inline = "s2")
showDayLbl = input.bool(true, "Show day-of-week labels", group = gD)
dayLblCol  = input.color(color.new(color.gray, 30), "Day label color", group = gD)
dayLblSize = input.string("Small", "Day label size", options = ["Tiny", "Small", "Normal", "Large"], group = gD)
dayLblOff  = input.float(8.0, "Day label drop (% below low)", minval = 0, maxval = 50, step = 0.5, tooltip = "How far below the lowest visible candle the day names sit. Increase if price overlaps the day names.", group = gD)

// -------------------------------- MAPPERS -----------------------------------
f_size(s) => s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Normal" ? size.normal : size.large
sz        = f_size(txtSize)
dSz       = f_size(dayLblSize)

f_style(s) => s == "Dotted" ? line.style_dotted : s == "Dashed" ? line.style_dashed : line.style_solid
lStyle    = f_style(lineStyle)
sepLStyle = f_style(sepStyle)

// Timeframe lock: H1 and lower only
tfOK = timeframe.in_seconds() <= 3600

dOpenMin = int(str.tonumber(str.substring(dailyOpenTime, 0, 2))) * 60 + int(str.tonumber(str.substring(dailyOpenTime, 2, 4)))
sepMin   = int(str.tonumber(str.substring(sepTime, 0, 2))) * 60 + int(str.tonumber(str.substring(sepTime, 2, 4)))

var int   curDate = na
var bool  dDone   = false
var bool  sepDone = false
var line  lnD = na, var label lbD = na, var float pD  = na
var line  ln9 = na, var label lb9 = na, var float p9  = na
var line  ln10= na, var label lb10= na, var float p10 = na
var array<label> dayLbls = array.new<label>()
// Running extremes across ONLY the drawn region (so the day-name row is always below every candle)
var float dispLow  = na
var float dispHigh = na

[mt, mo] = request.security_lower_tf(syminfo.tickerid, "1", [time, open])
n = array.size(mt)
if n == 0
    mt := array.from(time)
    mo := array.from(open)
    n := 1

drawOK = tfOK and (timenow - time) <= daysBack * 86400000

if drawOK
    dispLow  := na(dispLow)  ? low  : math.min(dispLow,  low)
    dispHigh := na(dispHigh) ? high : math.max(dispHigh, high)

f_txtcol(base) => useCustomTxtCol ? customTxtCol : base
f_lbltxt(name, price) => showPrice ? name + "  " + str.tostring(price, format.mintick) : name

f_dow(t) =>
    dw = dayofweek(t, ny)
    dw == dayofweek.monday ? "Mon" : dw == dayofweek.tuesday ? "Tue" : dw == dayofweek.wednesday ? "Wed" : dw == dayofweek.thursday ? "Thu" : dw == dayofweek.friday ? "Fri" : dw == dayofweek.saturday ? "Sat" : "Sun"

for i = 0 to n - 1
    t  = array.get(mt, i)
    op = array.get(mo, i)
    mod = hour(t, ny) * 60 + minute(t, ny)
    d   = year(t, ny) * 10000 + month(t, ny) * 100 + dayofmonth(t, ny)

    if na(curDate) or d != curDate
        curDate := d
        ln9  := na
        ln10 := na
        dDone := false
        sepDone := false

    // ---- Day / week separator ----
    if showSep and drawOK and mod == sepMin and not sepDone
        sepDone := true
        isWeekStart = dayofweek(t, ny) == dayofweek.monday
        sCol = (emphWeek and isWeekStart) ? weekCol : sepCol
        sWid = (emphWeek and isWeekStart) ? weekWidth : sepWidth
        line.new(t, close, t, close, xloc = xloc.bar_time, extend = extend.both, color = sCol, style = sepLStyle, width = sWid)
        if showDayLbl
            // anchor at the MIDDLE of the day (separator + 12h); flat Y set on last bar
            dl = label.new(t + 43200000, low, f_dow(t), xloc = xloc.bar_time, style = label.style_none, textcolor = dayLblCol, size = dSz, textalign = text.align_center)
            array.push(dayLbls, dl)

    // ---- Daily open ----
    if showDaily and drawOK and mod == dOpenMin and not dDone
        dDone := true
        pD  := op
        lnD := line.new(t, op, t, op, xloc = xloc.bar_time, color = colDaily, width = lw, style = lStyle)
        lbD := showOpenLabels ? label.new(t, op, "", xloc = xloc.bar_time, style = label.style_none, textcolor = f_txtcol(colDaily), size = sz, textalign = text.align_center) : na

    // ---- 9:30 open ----
    if show930 and drawOK and mod == 570 and na(ln9)
        p9  := op
        ln9 := line.new(t, op, t, op, xloc = xloc.bar_time, color = col930, width = lw, style = lStyle)
        lb9 := showOpenLabels ? label.new(t, op, "", xloc = xloc.bar_time, style = label.style_none, textcolor = f_txtcol(col930), size = sz, textalign = text.align_center) : na

    // ---- 10:00 open ----
    if show1000 and drawOK and mod == 600 and na(ln10)
        p10  := op
        ln10 := line.new(t, op, t, op, xloc = xloc.bar_time, color = col1000, width = lw, style = lStyle)
        lb10 := showOpenLabels ? label.new(t, op, "", xloc = xloc.bar_time, style = label.style_none, textcolor = f_txtcol(col1000), size = sz, textalign = text.align_center) : na

// ---- Pin all day labels to one flat level below every drawn candle ----
if barstate.islast and array.size(dayLbls) > 0 and not na(dispLow)
    yPos = dispLow - (dispHigh - dispLow) * (dayLblOff / 100)
    for k = 0 to array.size(dayLbls) - 1
        label.set_y(array.get(dayLbls, k), yPos)

// ---- Extend open lines + position centered labels to the right of each end ----
xoff = labelXoff * timeframe.in_seconds() * 1000

if not na(lnD)
    line.set_x2(lnD, time_close)
    if not na(lbD)
        label.set_xy(lbD, time_close + xoff, pD)
        label.set_text(lbD, f_lbltxt(txtDaily, pD))
if not na(ln9)
    line.set_x2(ln9, time_close)
    if not na(lb9)
        label.set_xy(lb9, time_close + xoff, p9)
        label.set_text(lb9, f_lbltxt(txt930, p9))
if not na(ln10)
    line.set_x2(ln10, time_close)
    if not na(lb10)
        label.set_xy(lb10, time_close + xoff, p10)
        label.set_text(lb10, f_lbltxt(txt1000, p10))
````
