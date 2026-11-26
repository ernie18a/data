# IST Trading Sessions

- url: https://www.tradingview.com/script/0aBOnN13-IST-Trading-Sessions/
- type: indicator
- pine_id: PUB;09a8ed025e054aa58a9f95f84c3dd8e0
- version: 3.0

## Description

Session ranges plotted in Indian Standard Time (UTC+5:30).

This is for traders trading forex in IST hours. 

WHAT IT DRAWS

- A live box around each session's high and low, labelled inside the box 
  with the session name and its current range in dollars. No floating 
  labels cluttering the chart.

- Two dotted lines carrying the last completed session's high and low 
  forward, so you can see whether price is reacting to the Tokyo high or 
  the London low without scrolling back.

- Killzone shading over the first 90 minutes of the London and New York 
  opens.

- Previous day high and low.

- A summary table with each session's range in dollars and pips, and a 
  marker showing which session is currently live.

DEFAULT TIMES (IST)

Tokyo    05:30 – 14:30
London   12:30 – 21:30
New York 17:30 – 02:30

DAYLIGHT SAVING

India does not observe daylight saving, but London and New York do. The 
defaults above are set for summer (BST / EDT), roughly mid-March to late 
October. During winter, add one hour to the London and New York session 
inputs. All three sessions are editable, so you can also set them to 
whatever windows you actually trade.

KEEPING IT READABLE

Boxes are only drawn for the last N days, adjustable, which stops the 
chart filling up on long scrollbacks. Carry-forward lines extend a set 
number of bars and older ones are removed automatically. Background tint 
is off by default; turn it on if you prefer shading over boxes.

NOTES

This is a visual reference tool. It generates no signals and makes no 
suggestion about direction. Works on any intraday timeframe, though 
session boxes are most useful on 5m to 1h.

## Source Code

````pine
//@version=6
// ══════════════════════════════════════════════════════════════════════
//  IST TRADING SESSIONS  v3
//
//  v3 adds:
//   - Larger, size-configurable info table
//   - Previous day total range (high - low) with divisor projections:
//         (prev day range / divisor) x multiplier
//     Three configurable divisor rows, each with its own text tag so you
//     can note which chart timeframe you use it on.
//
//  DST: India has no daylight saving; London and New York do. Defaults
//  are SUMMER (BST / EDT). In winter add 1 hour to London and New York.
// ══════════════════════════════════════════════════════════════════════

indicator("IST Trading Sessions and Range", overlay = true,
     max_boxes_count = 500, max_lines_count = 500, max_labels_count = 100)

TZ = "Asia/Kolkata"

// ─────────────────────────────── INPUTS ───────────────────────────────
g1 = "Sessions (IST)"
tokOn  = input.bool  (true,        "Tokyo   ", inline = "tok", group = g1)
tokSpc = input.session("0530-1430", "",        inline = "tok", group = g1)
tokCol = input.color (#3b82f6,      "",        inline = "tok", group = g1)

ldnOn  = input.bool  (true,        "London  ", inline = "ldn", group = g1)
ldnSpc = input.session("1230-2130", "",        inline = "ldn", group = g1)
ldnCol = input.color (#f59e0b,      "",        inline = "ldn", group = g1)

nyOn   = input.bool  (true,        "New York", inline = "ny",  group = g1)
nySpc  = input.session("1730-0230", "",        inline = "ny",  group = g1)
nyCol  = input.color (#14b8a6,      "",        inline = "ny",  group = g1)

g2 = "Killzones"
kzOn  = input.bool  (true,        "Shade first 90 min of majors", group = g2)
kzAlpha = input.int (82,          "Killzone fill transparency", minval = 50, maxval = 100, group = g2)
kzLdn = input.session("1230-1400", "London open", group = g2)
kzNy  = input.session("1730-1900", "NY open",     group = g2)

// ── Previous-day range projections ────────────────────────────────────
g5 = "Previous day range projections"
projOn = input.bool (true, "Show projections", group = g5)
projMlt= input.float(2.0,  "Multiplier", step = 0.1, group = g5)

d1On = input.bool  (true,  "Row 1", inline = "d1", group = g5)
d1   = input.float (4.58,  "/",     inline = "d1", step = 0.001, group = g5)
d1Tg = input.string("5M",  "tag",   inline = "d1", group = g5)

d2On = input.bool  (true,  "Row 2", inline = "d2", group = g5)
d2   = input.float (2.75,  "/",     inline = "d2", step = 0.001, group = g5)
d2Tg = input.string("5M",  "tag",   inline = "d2", group = g5)

d3On = input.bool  (true,  "Row 3", inline = "d3", group = g5)
d3   = input.float (3.618, "/",     inline = "d3", step = 0.001, group = g5)
d3Tg = input.string("3M",  "tag",   inline = "d3", group = g5)

g3 = "Display"
histDays = input.int (10,   "Only draw last N days", minval = 1, maxval = 60, group = g3)
boxAlpha = input.int (94,   "Box fill transparency", minval = 60, maxval = 100, group = g3)
showTxt  = input.bool(true, "Name + range inside box", group = g3)
carryOn  = input.bool(true, "Carry last session H/L forward", group = g3)
carryLen = input.int (60,   "Carry forward N bars", minval = 10, maxval = 300, group = g3)
showBg   = input.bool(false,"Session background tint", group = g3)
showPD   = input.bool(true, "Previous day H/L lines", group = g3)

g4 = "Table"
showTbl  = input.bool  (true, "Show table", group = g4)
unitMode = input.string("Price", "Units", options = ["Price", "Pips (x10)"], group = g4)
tblSize  = input.string("Normal", "Text size",
     options = ["Tiny", "Small", "Normal", "Large"], group = g4)
tblPos   = input.string("Top right", "Position",
     options = ["Top right", "Top left", "Bottom right", "Bottom left", "Middle right"], group = g4)
tblBg    = input.color (#0b0f14, "Background", group = g4)

g6 = "Validation point label"
vpOn   = input.bool (true, "Show label", group = g6)
vpHour = input.int  (6,    "Hour (IST, 24h)", minval = 0, maxval = 23, group = g6)
vpMin  = input.int  (30,   "Minute",          minval = 0, maxval = 59, group = g6)
vpText = input.string("Validation Point", "Label text", group = g6)
vpCol  = input.color(color.yellow, "Color", group = g6)
inTok = tokOn and not na(time(timeframe.period, tokSpc, TZ))
inLdn = ldnOn and not na(time(timeframe.period, ldnSpc, TZ))
inNy  = nyOn  and not na(time(timeframe.period, nySpc,  TZ))
inKzL = kzOn  and not na(time(timeframe.period, kzLdn,  TZ))
inKzN = kzOn  and not na(time(timeframe.period, kzNy,   TZ))

recent = time >= timenow - histDays * 86400000

// ───────────────────────── VALIDATION POINT ───────────────────────────
// Fires once per day on the bar whose IST time window contains the
// chosen hour:minute. Works on any intraday timeframe since it checks
// a range, not an exact open-time equality.
vpBarStart = hour(time,       TZ) * 60 + minute(time,       TZ)
vpBarEnd   = hour(time_close, TZ) * 60 + minute(time_close, TZ)
vpTarget   = vpHour * 60 + vpMin
vpWrapEnd  = vpBarEnd == 0 ? 1440 : vpBarEnd   // handle bars crossing midnight IST
vpHit      = vpOn and vpTarget >= vpBarStart and vpTarget < vpWrapEnd

var bool vpFiredToday = false
vpNewDay = hour(time, TZ) == 0 and minute(time, TZ) < 30
if vpNewDay
    vpFiredToday := false

if vpHit and not vpFiredToday
    vpFiredToday := true
    label.new(bar_index, high, vpText,
         style     = label.style_label_down,
         color     = color.new(vpCol, 15),
         textcolor = color.black,
         size      = size.small)

// ──────────────────────────── SESSION TYPE ────────────────────────────
type Sess
    string name
    color  col
    float  hi   = na
    float  lo   = na
    box    bx   = na
    line   lnH  = na
    line   lnL  = na
    float  rng  = na

var array<Sess> S = array.new<Sess>()
if barstate.isfirst
    array.push(S, Sess.new(name = "Tokyo",  col = tokCol))
    array.push(S, Sess.new(name = "London", col = ldnCol))
    array.push(S, Sess.new(name = "NY",     col = nyCol))

onArr   = array.from(tokOn,    ldnOn,    nyOn)
nowArr  = array.from(inTok,    inLdn,    inNy)
prevArr = array.from(inTok[1], inLdn[1], inNy[1])

// ────────────────────────── BUILD / UPDATE ────────────────────────────
if array.size(S) == 3
    for i = 0 to 2
        Sess s   = array.get(S, i)
        bool on  = array.get(onArr,   i)
        bool inN = array.get(nowArr,  i)
        bool inP = array.get(prevArr, i)

        if on
            if inN and not inP
                s.hi := high
                s.lo := low
                if recent
                    s.bx := box.new(bar_index, high, bar_index, low,
                         border_color = color.new(s.col, 40),
                         bgcolor      = color.new(s.col, boxAlpha),
                         border_width = 1,
                         text         = showTxt ? s.name : "",
                         text_size    = size.tiny,
                         text_color   = color.new(s.col, 15),
                         text_halign  = text.align_left,
                         text_valign  = text.align_top)

            else if inN
                s.hi  := math.max(nz(s.hi, high), high)
                s.lo  := math.min(nz(s.lo, low),  low)
                s.rng := s.hi - s.lo
                if not na(s.bx)
                    box.set_top   (s.bx, s.hi)
                    box.set_bottom(s.bx, s.lo)
                    box.set_right (s.bx, bar_index)
                    if showTxt
                        box.set_text(s.bx, s.name + "  $" + str.tostring(s.rng, "#.#"))

            else if inP and not inN and carryOn and recent and not na(s.hi)
                if not na(s.lnH)
                    line.delete(s.lnH)
                if not na(s.lnL)
                    line.delete(s.lnL)
                s.lnH := line.new(bar_index, s.hi, bar_index + carryLen, s.hi,
                     color = color.new(s.col, 45), style = line.style_dotted, width = 1)
                s.lnL := line.new(bar_index, s.lo, bar_index + carryLen, s.lo,
                     color = color.new(s.col, 45), style = line.style_dotted, width = 1)

// ───────────────────────── KILLZONE BOXES ─────────────────────────────
// Bounded to the killzone's own high/low instead of shading the whole
// chart height, so they sit inside the session box rather than over it.
var array<Sess> KZ = array.new<Sess>()
if barstate.isfirst
    array.push(KZ, Sess.new(name = "LDN KZ", col = ldnCol))
    array.push(KZ, Sess.new(name = "NY KZ",  col = nyCol))

kzNow  = array.from(inKzL,    inKzN)
kzPrev = array.from(inKzL[1], inKzN[1])

if array.size(KZ) == 2
    for i = 0 to 1
        Sess k   = array.get(KZ, i)
        bool inN = array.get(kzNow,  i)
        bool inP = array.get(kzPrev, i)

        if inN and not inP
            k.hi := high
            k.lo := low
            if recent
                k.bx := box.new(bar_index, high, bar_index, low, border_color = color.new(k.col, 20), bgcolor = color.new(k.col, kzAlpha), border_width = 1, border_style = line.style_dashed)

        else if inN
            k.hi := math.max(nz(k.hi, high), high)
            k.lo := math.min(nz(k.lo, low),  low)
            if not na(k.bx)
                box.set_top   (k.bx, k.hi)
                box.set_bottom(k.bx, k.lo)
                box.set_right (k.bx, bar_index)

// ───────────────────────────── TINTS ──────────────────────────────────
bgSess = inNy ? color.new(nyCol, 95) : inLdn ? color.new(ldnCol, 95) : inTok ? color.new(tokCol, 95) : na
bgcolor(showBg ? bgSess : na, title = "Session tint")

// ──────────────────── PREVIOUS DAY RANGE + PROJECTIONS ────────────────
pdh = request.security(syminfo.tickerid, "D", high [1], lookahead = barmerge.lookahead_on)
pdl = request.security(syminfo.tickerid, "D", low  [1], lookahead = barmerge.lookahead_on)
plot(showPD ? pdh : na, "PDH", color = color.new(color.gray, 25), style = plot.style_linebr, display = display.pane)
plot(showPD ? pdl : na, "PDL", color = color.new(color.gray, 25), style = plot.style_linebr, display = display.pane)

pdRange = na(pdh) or na(pdl) ? na : pdh - pdl

f_proj(float divisor) =>
    na(pdRange) or divisor == 0 ? na : pdRange / divisor * projMlt

p1 = f_proj(d1)
p2 = f_proj(d2)
p3 = f_proj(d3)

// ─────────────────────────── TABLE RENDER ─────────────────────────────
tSize = tblSize == "Tiny" ? size.tiny : tblSize == "Small" ? size.small : tblSize == "Large" ? size.large : size.normal

tPos = tblPos == "Top right" ? position.top_right : tblPos == "Top left" ? position.top_left : tblPos == "Bottom right" ? position.bottom_right : tblPos == "Middle right" ? position.middle_right : position.bottom_left

// Formats a dollar/price value per the Units setting.
// "Price"      -> 105.79   (matches TradingView's Date & Price Range tool)
// "Pips (x10)" -> 1058
f_fmt(float v) =>
    na(v) ? "–" : unitMode == "Price" ? str.tostring(v, "#.##") : str.tostring(v * 10, "#")

colHdr = unitMode == "Price" ? "Range" : "pips"

var table tb = table.new(tPos, 3, 11, border_width = 1,
     frame_color = color.new(color.gray, 55), frame_width = 1,
     border_color = color.new(color.gray, 75))

f_hdr(int c, int r, string t) =>
    table.cell(tb, c, r, t, text_size = tSize, text_color = color.new(color.white, 25),
         bgcolor = color.new(color.gray, 55), text_halign = text.align_center)

if barstate.islast and showTbl and array.size(S) == 3
    // header
    f_hdr(0, 0, "Session")
    f_hdr(1, 0, colHdr)
    f_hdr(2, 0, "")

    // session rows
    for i = 0 to 2
        Sess s   = array.get(S, i)
        bool inN = array.get(nowArr, i)
        string p = f_fmt(s.rng)
        color bg = color.new(s.col, 84)
        table.cell(tb, 0, i + 1, s.name, text_size = tSize, text_color = color.white, bgcolor = bg, text_halign = text.align_left)
        table.cell(tb, 1, i + 1, p,      text_size = tSize, text_color = color.white, bgcolor = bg, text_halign = text.align_right)
        table.cell(tb, 2, i + 1, inN ? "●" : "", text_size = tSize, text_color = color.lime, bgcolor = bg, text_halign = text.align_center)

    // previous day block
    if projOn
        f_hdr(0, 4, "Prev day")
        f_hdr(1, 4, colHdr)
        f_hdr(2, 4, "TF")

        string rPip = f_fmt(pdRange)
        table.cell(tb, 0, 5, "Total range", text_size = tSize, text_color = color.white, bgcolor = tblBg, text_halign = text.align_left)
        table.cell(tb, 1, 5, rPip,          text_size = tSize, text_color = color.yellow, bgcolor = tblBg, text_halign = text.align_right)
        table.cell(tb, 2, 5, "",            text_size = tSize, bgcolor = tblBg)

        rows = array.from(d1On, d2On, d3On)
        divs = array.from(d1,   d2,   d3)
        vals = array.from(p1,   p2,   p3)
        tags = array.from(d1Tg, d2Tg, d3Tg)

        for i = 0 to 2
            int  rIdx = 6 + i
            bool on   = array.get(rows, i)
            float v   = array.get(vals, i)
            string lbl = "/ " + str.tostring(array.get(divs, i), "#.###") + " × " + str.tostring(projMlt, "#.##")
            string vPp = not on ? "–" : f_fmt(v)
            color  fg  = on ? color.new(color.aqua, 0) : color.new(color.gray, 40)
            table.cell(tb, 0, rIdx, lbl,  text_size = tSize, text_color = color.new(color.white, 20), bgcolor = tblBg, text_halign = text.align_left)
            table.cell(tb, 1, rIdx, vPp,  text_size = tSize, text_color = fg, bgcolor = tblBg, text_halign = text.align_right)
            table.cell(tb, 2, rIdx, array.get(tags, i), text_size = tSize, text_color = color.new(color.white, 40), bgcolor = tblBg, text_halign = text.align_center)

    // footer
    table.cell(tb, 0, 9, "IST", text_size = tSize, text_color = color.silver, bgcolor = color.new(color.black, 55), text_halign = text.align_left)
    table.cell(tb, 1, 9, str.format_time(time_close, "HH:mm", TZ), text_size = tSize, text_color = color.silver, bgcolor = color.new(color.black, 55), text_halign = text.align_right)
    table.cell(tb, 2, 9, "", bgcolor = color.new(color.black, 55))
````
