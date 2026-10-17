# ONR & Silver Bullet+ (M1D)

- url: https://www.tradingview.com/script/FcAJ3joL-ONR-Silver-Bullet-M1D/
- type: indicator
- pine_id: PUB;862eca4418b14875981201eed8deba89
- version: 1.0

## Description

ONR & Silver Bullet+ puts two things on one chart: the three ICT Silver Bullet hours of the New York day, and the overnight range that forms before the New York open, projected out as standard deviations. The Silver Bullet model and the practice of projecting a range in multiples of itself follow ICT (Michael J. Huddleston) convention. The script draws the time and the price framework the model is read inside; it does not detect setups, grade them or decide anything.

[b]The concept: what a Silver Bullet is[/b]

The Silver Bullet is a time-based model. ICT names three one-hour windows on the New York clock and teaches one trade shape inside each of them, taken the same way every day. That is where the name comes from: one simple, repeatable tool, used at one time.

The three windows are the London open, 03:00 to 04:00; the New York morning, 10:00 to 11:00, the most widely traded of the three; and the New York afternoon, 14:00 to 15:00. They sit where order flow is heaviest in each session, which is why the model expects a clean move inside them.

The shape ICT teaches inside the hour runs in a fixed order:

[b]Before the hour.[/b] 
The resting liquidity is marked on the 15 minute chart: buyside above old highs, sellside below old lows, and the prior session's high and low. This gives the bias and the draw, the pool price is expected to reach.

[b]Inside the hour.[/b] 
Price runs one side's liquidity, then displaces the other way with a market structure shift. The displacement leaves a fair value gap, three candles where the first candle's range and the third candle's range do not overlap. The gap has to form inside the hour. The first gap is the one the model uses; taking the second, third or fourth is the error it warns against.

[b]The entry.[/b] 
Price is allowed to trade back into the gap on the 1, 3 or 5 minute chart rather than chased. The stop sits beyond the candle that formed the gap, and the target is the opposing liquidity pool, commonly a minimum of five handles on index futures or fifteen pips on currencies.

[b]The rule that defines it.[/b] 
A setup outside the window is not a Silver Bullet, however similar it looks. The time is part of the model, not a filter on top of it.

This script draws the windows so that rule is visible at a glance: whether a sweep, a shift or a gap printed inside the hour or outside it can be read straight off the chart, without counting candles or marking it yourself if used in a consistent manner. 

[b]The overnight range[/b]

The overnight range (ONR) is 05:00 to 09:00 New York: the hours after the London Silver Bullet and before the New York session opens. By 09:00 it has built a high and a low that the New York morning trades against, and those two extremes are resting liquidity the New York morning, and its Silver Bullet hour, can run.

Its size is measured and projected. The -1 standard deviation sits half a range beyond each edge and the -2 one full range beyond, the same way ICT projects a defined range to frame how far a move out of it may extend. The projections are reference levels, not predictions.

[b]What it does[/b]

[b]1 · Silver Bullet hours.[/b] Each hour is boxed from its own high to its own low, with a thin vertical line at its start and its end running the full height of the chart, and its name written large and faint inside the box. Each hour is one switch and each time can be moved.

[b]2 · Overnight range.[/b] Boxed from its high to its low with its name large and faint inside and its equilibrium, the midpoint of the high and low, drawn dotted.

[b]3 · Standard deviations.[/b] 
-1 SD dashed and -2 SD solid, above the high and below the low, each with a small name at its left end, on its price. Worked example: a range from 31,000 down to 30,870 is 130 points, so -1 SD sits at 31,065 and 30,805, and -2 SD at 31,130 and 30,740. Both distances are settings.

[b]4 · The table.[/b] 
Top right by default: the instrument, the chart timeframe, the size of the latest overnight range in points (marked live while it is still forming), its high and its low, and the average size of the last ten finished overnight ranges on the chart with today's range as a share of it. A 130 point range against a 104 point average reads 125%, a wider night than usual; 70% reads a quiet one.

[b]Visual grammar[/b]

Silver Bullet hours are soft lavender and the overnight range grey, so the two read apart at a glance; neither wears the purple or magenta that mean direction in the M1D suite. Box names are large and faint so they identify the window without covering the candles. Deviation lines are dashed at -1 and solid at -2. The table is two columns in black on white with a purple title row, names in italic and values in bold.

[b]Method & repainting[/b]

Every window is read from the New York clock by name, so it follows daylight saving on its own and does not depend on the chart's timezone. A box grows with its window while the window is open and holds once it closes; the overnight range's equilibrium and deviations move with it until 09:00 and are fixed from then on. The average is taken only over overnight ranges that have finished and only from the bars loaded on the chart, and the table says how many it used. [b]Drawn on 1 hour charts and below; the model itself is read on the 1 to 5 minute charts.[/b]

[b]Settings[/b]

Each Silver Bullet hour on or off and its time; the overnight range on or off and its time; the equilibrium, the deviations, their distances and their labels; the start and end lines; every fill and line colour, the name colour and size, the label colour and size; how many days stay on the chart; the table on or off, its position, its size, how many ranges the average covers, and its colours. The script fires no alerts.

[b]Disclaimer[/b]

This is a charting tool. It draws what a chart already contains and produces no entries, targets or stops. It is not financial advice, and no market's past behaviour is indicative of future results.

## Source Code

````pine
//@version=6
indicator("ONR & Silver Bullet+ (M1D)", "Silver Bullet+", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

const string TZ = "America/New_York"

// == INPUTS ==================================================================

const string G_SB  = "Silver Bullet"
const string G_ONS = "Overnight Range"
const string G_TBL = "Table"
const string G_STY = "Style"

bool   sb1On = input.bool(true, "SB 1", group = G_SB, inline = "sb1")
string sb1   = input.session("0300-0400", "", group = G_SB, inline = "sb1", active = sb1On)
bool   sb2On = input.bool(true, "SB 2", group = G_SB, inline = "sb2")
string sb2   = input.session("1000-1100", "", group = G_SB, inline = "sb2", active = sb2On)
bool   sb3On = input.bool(true, "SB 3", group = G_SB, inline = "sb3")
string sb3   = input.session("1400-1500", "", group = G_SB, inline = "sb3", active = sb3On)
string sbTxt = input.string("SB", "Name", group = G_SB)
bool   sbVln = input.bool(true, "Start and end lines", group = G_SB, tooltip = "A thin vertical line at the start and the end of each Silver Bullet hour, the full height of the chart.")

bool   onsOn  = input.bool(true, "ONR", group = G_ONS, inline = "ons")
string onsSs  = input.session("0500-0900", "", group = G_ONS, inline = "ons", active = onsOn)
string onsTxt = input.string("ONR", "Name", group = G_ONS)
bool   onsEq  = input.bool(true, "Equilibrium", group = G_ONS)
bool   onsSd  = input.bool(true, "Standard deviations", group = G_ONS, tooltip = "-1 SD sits half the box height past each edge, -2 SD one full box height past each edge.")
float  sd1M   = input.float(0.5, "-1 SD", minval = 0.0, step = 0.25, group = G_ONS, inline = "sdm", tooltip = "Distance past the box edge, in box heights.")
float  sd2M   = input.float(1.0, "-2 SD", minval = 0.0, step = 0.25, group = G_ONS, inline = "sdm")
bool   sdLbl  = input.bool(true, "Deviation labels", group = G_ONS)

color  sbFill  = input.color(color.new(#9C8AD0, 80), "SB", group = G_STY, inline = "c1")
color  sbLine  = input.color(color.new(#7e64ce, 65), "Lines", group = G_STY, inline = "c1")
color  onsFill = input.color(color.new(#9E9E9E, 82), "ONR", group = G_STY, inline = "c2")
color  onsLvl  = input.color(color.new(#9E9E9E, 25), "Levels", group = G_STY, inline = "c2")
color  wmCol   = input.color(color.new(#9E9E9E, 60), "Name", group = G_STY, inline = "c3")
color  lblCol  = input.color(#000000, "Labels", group = G_STY, inline = "c3")
string wmSzIn  = input.string("huge", "Name size", options = ["normal", "large", "huge"], group = G_STY, inline = "sz")
string lblSzIn = input.string("tiny", "Label size", options = ["tiny", "small", "normal"], group = G_STY, inline = "sz")
int    keepN   = input.int(3, "Days to keep", minval = 1, maxval = 20, group = G_STY)

bool   tblOn   = input.bool(true, "Show table", group = G_TBL)
string tblPos  = input.string("Top Right", "Position", options = ["Top Right", "Middle Right", "Bottom Right", "Top Left", "Bottom Left"], group = G_TBL, inline = "tb")
string tblSzIn = input.string("small", "Size", options = ["tiny", "small", "normal", "large"], group = G_TBL, inline = "tb")
int    avgN    = input.int(10, "Average of the last", minval = 1, maxval = 50, group = G_TBL, tooltip = "How many finished overnight ranges the average is taken over.")
color  tblHead = input.color(color.new(#cd82ff, 49), "Title", group = G_TBL, inline = "tc")
color  tblInk  = input.color(#000000, "Text", group = G_TBL, inline = "tc")

// == HELPERS =================================================================

//@function Resolves a size name to the size constant.
//@param s (string) "tiny", "small", "normal", "large" or "huge".
//@returns (string) The size constant.
f_size(string s) =>
    switch s
        "tiny"  => size.tiny
        "small" => size.small
        "large" => size.large
        "huge"  => size.huge
        =>         size.normal

string WM_SZ  = f_size(wmSzIn)
string LBL_SZ = f_size(lblSzIn)
string TBL_SZ = f_size(tblSzIn)
bool   TF_OK  = timeframe.isintraday and timeframe.in_seconds() <= 3600

//@function The New York time today at the END of a session string such as "1000-1100".
//@param sess (string) The session.
//@returns (int) UNIX time of the session's end.
f_endTime(string sess) =>
    int h = int(str.tonumber(str.substring(sess, 5, 7)))
    int m = int(str.tonumber(str.substring(sess, 7, 9)))
    timestamp(TZ, year(time, TZ), month(time, TZ), dayofmonth(time, TZ), h, m)

//@variable One drawn window: its box, its vertical lines, its levels and their labels.
type Win
    box          bx
    line         v1
    line         v2
    array<line>  lv
    array<label> lb
    float        hi
    float        lo
    int          t0
    int          t1

//@function Deletes every object a window drew.
//@param w (Win) The window.
//@returns (bool) Always true.
method wipe(Win w) =>
    box.delete(w.bx)
    line.delete(w.v1)
    line.delete(w.v2)
    for l in w.lv
        line.delete(l)
    for b in w.lb
        label.delete(b)
    true

//@function Places the ONR levels and their labels at the window's current high and low.
//@param w (Win) The window.
//@returns (bool) Always true.
method levels(Win w) =>
    float rng = w.hi - w.lo
    array<float> ys = array.from(math.avg(w.hi, w.lo), w.hi + rng * sd1M, w.lo - rng * sd1M, w.hi + rng * sd2M, w.lo - rng * sd2M)
    for [i, l] in w.lv
        line.set_y1(l, ys.get(i))
        line.set_y2(l, ys.get(i))
    for [i, b] in w.lb
        label.set_y(b, ys.get(i + 1))
    true

//@function Runs one window: opens it, follows it while it forms, keeps the last few.
//@param sess (string) Session string, New York time.
//@param on (bool) Whether the window draws.
//@param isOns (bool) True for the Overnight Session, false for a Silver Bullet hour.
//@param store (array<Win>) This window's history, oldest first.
//@param onrSizes (array<float>) Sizes of finished overnight ranges, oldest first.
//@returns (bool) Always true.
f_run(string sess, bool on, bool isOns, array<Win> store, array<float> onrSizes) =>
    bool inW   = on and TF_OK and not na(time(timeframe.period, sess, TZ))
    bool first = inW and not inW[1]
    if first
        int t1 = f_endTime(sess)
        if isOns and store.size() > 0
            Win pw = store.last()
            onrSizes.push(pw.hi - pw.lo)
            if onrSizes.size() > 50
                onrSizes.shift()
        Win w = Win.new(lv = array.new<line>(), lb = array.new<label>(), hi = high, lo = low, t0 = time, t1 = t1)
        w.bx := box.new(time, high, t1, low, xloc = xloc.bar_time, border_color = color.new(#FFFFFF, 100), border_width = 0, bgcolor = isOns ? onsFill : sbFill,
             text = isOns ? onsTxt : sbTxt, text_size = WM_SZ, text_color = wmCol, text_halign = text.align_center, text_valign = text.align_center)
        if not isOns and sbVln
            w.v1 := line.new(time, high, time, high + syminfo.mintick, xloc = xloc.bar_time, extend = extend.both, color = sbLine, width = 1)
            w.v2 := line.new(t1, high, t1, high + syminfo.mintick, xloc = xloc.bar_time, extend = extend.both, color = sbLine, width = 1)
        if isOns
            if onsEq
                w.lv.push(line.new(time, high, t1, high, xloc = xloc.bar_time, color = onsLvl, width = 1, style = line.style_dotted))
            else
                w.lv.push(line.new(time, high, t1, high, xloc = xloc.bar_time, color = color.new(#FFFFFF, 100), width = 1))
            if onsSd
                for s in array.from(line.style_dashed, line.style_dashed, line.style_solid, line.style_solid)
                    w.lv.push(line.new(time, high, t1, high, xloc = xloc.bar_time, color = onsLvl, width = 1, style = s))
                if sdLbl
                    for txt in array.from("-1 SD", "-1 SD", "-2 SD", "-2 SD")
                        w.lb.push(label.new(time, high, txt, xloc = xloc.bar_time, style = label.style_label_right, color = color.new(#FFFFFF, 100),
                             textcolor = lblCol, size = LBL_SZ, textalign = text.align_right, text_font_family = font.family_monospace))
            w.levels()
        store.push(w)
        if store.size() > keepN
            store.shift().wipe()
    else if inW and store.size() > 0
        Win w = store.last()
        w.hi := math.max(w.hi, high)
        w.lo := math.min(w.lo, low)
        box.set_top(w.bx, w.hi)
        box.set_bottom(w.bx, w.lo)
        if isOns
            w.levels()
    true

var array<Win> sbA  = array.new<Win>()
var array<Win> sbB  = array.new<Win>()
var array<Win> sbC  = array.new<Win>()
var array<Win> onsA = array.new<Win>()
var array<float> onrSz = array.new<float>()

f_run(sb1, sb1On, false, sbA, onrSz)
f_run(sb2, sb2On, false, sbB, onrSz)
f_run(sb3, sb3On, false, sbC, onrSz)
f_run(onsSs, onsOn, true, onsA, onrSz)

// == TIMEFRAME NOTICE ========================================================

var label tfWarn = na
if barstate.islast
    if not TF_OK
        if na(tfWarn)
            tfWarn := label.new(bar_index, high, "ONR & SB: use 1 hour or lower", style = label.style_label_down, color = color.new(#FFFFFF, 100), textcolor = lblCol, size = size.small, text_font_family = font.family_monospace)
        else
            label.set_xy(tfWarn, bar_index, high)
    else if not na(tfWarn)
        label.delete(tfWarn)
        tfWarn := na

// == TABLE ===================================================================

//@function The chart timeframe as a short tag: 1m, 5m, 1h.
//@returns (string) The tag.
f_tfTag() =>
    int m = timeframe.multiplier
    timeframe.isseconds ? str.tostring(m) + "s" : timeframe.isminutes ? (m % 60 == 0 ? str.tostring(m / 60) + "h" : str.tostring(m) + "m") : timeframe.period

//@function A price distance in points, to the instrument's tick.
//@param v (float) The distance.
//@returns (string) The points text.
f_pts(float v) =>
    na(v) ? "-" : str.tostring(math.round_to_mintick(v)) + " pts"

//@function Writes one name and value row.
//@param t (table) The table.
//@param r (int) Row.
//@param name (string) Name, left.
//@param val (string) Value, right.
//@param tip (string) Tooltip on both cells.
//@returns (bool) Always true.
f_row(table t, int r, string name, string val, string tip) =>
    table.cell(t, 0, r, " " + name, text_color = tblInk, text_size = TBL_SZ, text_halign = text.align_left, text_font_family = font.family_monospace, text_formatting = text.format_italic, tooltip = tip)
    table.cell(t, 1, r, val + " ", text_color = tblInk, text_size = TBL_SZ, text_halign = text.align_right, text_font_family = font.family_monospace, text_formatting = text.format_bold, tooltip = tip)
    true

//@function Resolves a position name to the position constant.
//@param s (string) The position name.
//@returns (string) The position constant.
f_pos(string s) =>
    switch s
        "Middle Right" => position.middle_right
        "Bottom Right" => position.bottom_right
        "Top Left"     => position.top_left
        "Bottom Left"  => position.bottom_left
        =>                position.top_right

var table tbl = na
if barstate.islast
    if tblOn and onsOn
        if na(tbl)
            tbl := table.new(f_pos(tblPos), 2, 7, bgcolor = #FFFFFF, frame_color = #000000, frame_width = 1, border_color = #000000, border_width = 1)
            table.merge_cells(tbl, 0, 0, 1, 0)
        table.cell(tbl, 0, 0, " M1D · ONR & SILVER BULLET+ ", text_color = tblInk, text_size = TBL_SZ, text_halign = text.align_center, text_font_family = font.family_monospace, text_formatting = text.format_bold, bgcolor = tblHead, tooltip = "@maybeonedayy")
        bool   has  = onsA.size() > 0
        float  oHi  = na
        float  oLo  = na
        bool   live = false
        if has
            Win o = onsA.last()
            oHi  := o.hi
            oLo  := o.lo
            live := time < o.t1
        float  sz   = oHi - oLo
        int    n    = math.min(avgN, onrSz.size())
        float  avg  = n > 0 ? onrSz.slice(onrSz.size() - n, onrSz.size()).avg() : na
        string vsA  = na(sz) or na(avg) or avg == 0 ? "-" : str.tostring(math.round(sz / avg * 100)) + "%"
        f_row(tbl, 1, "INSTRUMENT", syminfo.ticker, syminfo.description)
        f_row(tbl, 2, "TIMEFRAME", f_tfTag(), "")
        f_row(tbl, 3, live ? "ONR SIZE · LIVE" : "ONR SIZE", f_pts(sz), has ? "High " + str.tostring(oHi, format.mintick) + " · Low " + str.tostring(oLo, format.mintick) : "No overnight range on the chart yet.")
        f_row(tbl, 4, "HIGH", has ? str.tostring(oHi, format.mintick) : "-", "")
        f_row(tbl, 5, "LOW", has ? str.tostring(oLo, format.mintick) : "-", "")
        f_row(tbl, 6, "AVG " + str.tostring(n) + " DAYS", f_pts(avg) + " · " + vsA, "The average size of the last " + str.tostring(n) + " finished overnight ranges on this chart, and today's size as a share of it.")
    else if not na(tbl)
        table.delete(tbl)
        tbl := na
````
