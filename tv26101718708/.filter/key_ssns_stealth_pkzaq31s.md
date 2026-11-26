# Key ssns [stealth]

- url: https://www.tradingview.com/script/PkzAq31s-Key-ssns-stealth/
- type: indicator
- pine_id: PUB;9a6c3810610e4bcf9ecfdcfa8c29b4cf
- version: 1.0

## Description

Indices Sessions

A clean session-range tool built specifically for index trading (NAS100, SPX, US30, GER40, etc.). It draws a dotted box around each trading session, capturing the high-to-low range, with the session name and pip range labeled neatly on top.

Note: this indicator is designed for indices only. The session windows and pip-range math are tuned to index trading, so it is not intended for forex, crypto, or other instruments.

Three sessions, all anchored to New York time (DST handled automatically):
- London – 03:00–05:00
- NY – 09:30–12:00
- PM – 13:00–16:00

Each session is plotted as a transparent dotted box spanning that window's high and low, so you can instantly read where each session expanded, contracted, or was raided — without any fill cluttering the chart.

Minute-accurate range capture. The script reads 1-minute intrabar data rather than relying on bar boundaries, so the box edges (especially the 09:30 NY open) land exactly on time even on higher intraday timeframes instead of snapping to the nearest candle.

Labels:
- Session name plus range in pips, shown above each box and centered to stay within the box width
- Tiny by default, with size options (Tiny / Small / Normal)
- Pip display can be toggled off for a cleaner look
- Configurable pip size (NAS100 on FXCM ≈ 0.1)

Customization:
- Toggle each session independently
- Edit any session's time window directly in settings
- Box border color, style (dotted / dashed / solid), and width
- Label color and size
- "Days to display" control to limit how far back boxes draw

Timeframe-aware: boxes only render on timeframes below the 1-hour, where intraday session structure is actionable, and stay out of the way on higher timeframes.

Pairs with the companion Indices Open script for 9:30 / 10:00 / daily opens and day-of-week separators.

## Source Code

````pine
//@version=6
// =============================================================================
//  INDICES SESSIONS — dotted range boxes (transparent) with pip labels
//  London / NY / PM (NY time). Visible only on timeframes LOWER than H1.
// =============================================================================
indicator("Key ssns [stealth]", overlay = true, max_boxes_count = 500, max_labels_count = 500)

ny = "America/New_York"

gS = "Sessions"
showLon  = input.bool(true, "London",  group = gS, inline = "L")
lonSess  = input.session("0300-0500", "", group = gS, inline = "L")
showNY   = input.bool(true, "NY    ",  group = gS, inline = "N")
nySess   = input.session("0930-1200", "", group = gS, inline = "N")
showPM   = input.bool(true, "PM    ",  group = gS, inline = "P")
pmSess   = input.session("1300-1600", "", group = gS, inline = "P")

gB = "Boxes"
borderCol  = input.color(color.new(color.gray, 25), "Box border", group = gB)
borderStyle= input.string("Dotted", "Border style", options = ["Dotted", "Dashed", "Solid"], group = gB)
borderWidth= input.int(1, "Border width", minval = 1, maxval = 3, group = gB)

gL = "Labels"
showSessLabels = input.bool(true, "Session range labels", group = gL)
lblCol   = input.color(color.new(color.gray, 0), "Label text color", group = gL)
lblSize  = input.string("Tiny", "Label size", options = ["Tiny", "Small", "Normal"], group = gL)
showPips = input.bool(true, "Show pips", group = gL)
pipSize  = input.float(0.1, "Pip size", tooltip = "pips = range_in_points / pip_size. NAS100 on FXCM ≈ 0.1", group = gL)

gM = "Misc"
daysBack = input.int(20, "Days to display", minval = 1, maxval = 60, group = gM)

// Timeframe lock: below H1 only
tfOK = timeframe.in_seconds() < 3600

bStyle = borderStyle == "Dotted" ? line.style_dotted : borderStyle == "Dashed" ? line.style_dashed : line.style_solid
lSize  = lblSize == "Tiny" ? size.tiny : lblSize == "Small" ? size.small : size.normal

parseSess(string s) =>
    sh = int(str.tonumber(str.substring(s, 0, 2)))
    sm = int(str.tonumber(str.substring(s, 2, 4)))
    eh = int(str.tonumber(str.substring(s, 5, 7)))
    em = int(str.tonumber(str.substring(s, 7, 9)))
    [sh * 60 + sm, eh * 60 + em]

[lonS, lonE] = parseSess(lonSess)
[nyS,  nyE ] = parseSess(nySess)
[pmS,  pmE ] = parseSess(pmSess)

type Sess
    string name
    int    sMin
    int    eMin
    bool   show
    bool   active = false
    float  hi     = na
    float  lo     = na
    int    startT = na
    box    bx     = na
    label  lbl    = na

var array<Sess> sess = array.new<Sess>()
if barstate.isfirst
    array.push(sess, Sess.new("lo", lonS, lonE, showLon))
    array.push(sess, Sess.new("ny", nyS,  nyE,  showNY))
    array.push(sess, Sess.new("pm", pmS,  pmE,  showPM))

var int curDate = na

[mt, mh, ml] = request.security_lower_tf(syminfo.tickerid, "1", [time, high, low])
n = array.size(mt)
if n == 0
    mt := array.from(time)
    mh := array.from(high)
    ml := array.from(low)
    n := 1

drawOK = tfOK and (timenow - time) <= daysBack * 86400000

for i = 0 to n - 1
    t  = array.get(mt, i)
    hi = array.get(mh, i)
    lo = array.get(ml, i)
    mod = hour(t, ny) * 60 + minute(t, ny)
    d   = year(t, ny) * 10000 + month(t, ny) * 100 + dayofmonth(t, ny)

    if na(curDate) or d != curDate
        curDate := d
        for j = 0 to array.size(sess) - 1
            sj = array.get(sess, j)
            sj.active := false

    for j = 0 to array.size(sess) - 1
        s = array.get(sess, j)
        inWin = s.show and drawOK and mod >= s.sMin and mod < s.eMin
        if inWin
            if not s.active
                s.active := true
                s.hi     := hi
                s.lo     := lo
                s.startT := t
                s.bx     := box.new(t, hi, t, lo, xloc = xloc.bar_time, border_color = borderCol, border_style = bStyle, border_width = borderWidth, bgcolor = color.new(color.gray, 100))
                // style_label_down => anchor at the box top, text floats ABOVE it
                s.lbl    := showSessLabels ? label.new(t, hi, "", xloc = xloc.bar_time, style = label.style_label_down, color = color.new(color.gray, 100), textcolor = lblCol, size = lSize) : na
            else
                s.hi := math.max(s.hi, hi)
                s.lo := math.min(s.lo, lo)
            if not na(s.bx)
                box.set_top(s.bx, s.hi)
                box.set_bottom(s.bx, s.lo)
                box.set_right(s.bx, t)
            if not na(s.lbl)
                // anchor at the HORIZONTAL CENTER of the box so text stays within its width
                midT = s.startT + (t - s.startT) / 2
                label.set_xy(s.lbl, midT, s.hi)
                txt = showPips ? s.name + " • " + str.tostring((s.hi - s.lo) / pipSize, "#.#") + " pips" : s.name
                label.set_text(s.lbl, txt)
        else
            s.active := false
````
