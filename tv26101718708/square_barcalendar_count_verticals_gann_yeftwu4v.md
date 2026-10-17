# Square Bar/Calendar Count Verticals (Gann)

- url: https://www.tradingview.com/script/YefTwU4v-Square-Bar-Calendar-Count-Verticals-Gann/
- type: indicator
- pine_id: PUB;08975284dd2343fdab336604a9f3d5fc
- version: 2.0

## Description

█ OVERVIEW

Square Bar/Calendar Count Verticals plots vertical time lines on the chart at squared counts measured from user-selected pivot anchors, in two independent units: trading bars and calendar days. The thesis, drawn from W.D. Gann's time-counting methods, is that elapsed time from a significant price extreme reaching a perfect square (81, 100, 121, 144, 289, 361) marks a date of elevated probability for a trend pause, inflection, or termination, and that the strongest of these dates occur where a bar-count square and a calendar-day square coincide.


█ HISTORY / BACKGROUND

Counting time in squares from major highs and lows originates with W.D. Gann, who treated time and price as interchangeable quantities and used the squares of small integers as recurring measures of trend duration. Constance Brown's published work on Gann analysis demonstrates the method in modern markets: bar counts of 9², 10², 11², and 12² projected from a swing extreme, a 17² calendar-day count from a significant low, repeats of the 144 count monitored from key pivots, and the square of 19 tracked as a separate helix cycle. This indicator implements that specific working set as a chart tool.

The conceptual basis is that these verticals are time factors only. They carry no directional information. Their value is realized when a squared count expires while price is simultaneously at a level identified by independent price-based methods.


█ HOW IT WORKS

1 — The user supplies a comma-separated list of roots (default 9,10,11,12,17,19). At the first bar the script parses the list and computes the square of each root.

2 — Each of up to three anchors is a timestamp selected on the chart. The anchor is resolved to a bar by containment: the anchor bar is the first bar whose closing time exceeds the anchor timestamp. This makes resolution independent of exchange timezone and safe when the timestamp falls on a weekend or holiday.

3 — For every anchor and every square s, the script computes two targets:
 - a trading-bar target at anchor bar index + s (bar unit follows the chart timeframe), and
 - a calendar-day target at anchor time + s days (independent of timeframe).
 With inclusive counting enabled (default) the anchor bar or anchor day is counted as 1, so targets land at s minus 1 units after the anchor.

4 — When the root 12 is present and the repeat setting exceeds 1, additional verticals are drawn at 288, 432, and further multiples of 144, in both units, up to the chosen repeat count.

5 — On the last bar the script draws the verticals once: solid lines in bar-index coordinates for bar squares (projected up to roughly 490 bars into the future) and dashed lines in time coordinates for calendar squares (projectable to any future date). Each line carries a label naming the root, the square, and the unit. The anchor itself is marked with a heavier line and a date label.

6 — A status table reports, per active anchor, the elapsed count in both units and the next upcoming square in each unit, with the bars remaining and the calendar date.

7 — Three alert conditions fire on the bar that completes a bar-count square, the bar that contains a calendar-day square date, and the bar on which both occur together.


█ HOW TO USE

The verticals are appointments in time, not signals. The intended workflow:

 - Anchor each slot on a significant swing extreme. Significance is an analytical judgment; the script deliberately performs no automatic pivot detection.
 - Validate an anchor by inspecting the verticals already in the past. If historical squared counts from that anchor align with real pivots, the anchor is worth keeping. If they align with nothing, move or disable it.
 - When price approaches an upcoming vertical, consult independent price analysis. A squared count expiring while price sits at a level derived from other methods is the condition of interest. A squared count expiring in open space warns at most of a pause or stall.
 - The highest-weight event this tool can flag is the third alert: a bar square and a calendar square completing on the same bar.

Bar counts are timeframe-relative by design: the same anchor produces different bar-square dates on daily and weekly charts, and both are legitimate counts on their own timeframe. Calendar-day counts are identical on every timeframe. The tool is designed for daily and weekly swing analysis, where Gann's counts were applied; on intraday charts the calendar counts remain valid but bar counts become session-dependent.

Visual elements: solid vertical lines are trading-bar squares, dashed vertical lines are calendar-day squares, the heavy line with a date label is the anchor, labels above price name bar counts, labels below price name calendar counts, and the top-right table summarizes elapsed and upcoming counts.


█ SETTINGS

 - Square roots: comma-separated integer roots to square. Default 9,10,11,12,17,19.
 - Inclusive count: anchor bar or day counts as 1 when enabled. Default on.
 - Trading-bar squares: show or hide bar-count verticals. Default on.
 - Calendar-day squares: show or hide calendar-count verticals. Default on.
 - 144-cycle repeats: number of 144 multiples to project; 1 disables repeats. Default 3.
 - Anchor 1, 2, 3: enable flag, pivot timestamp (Anchor 1 prompts for a chart click on load), and line color per anchor. Defaults: Anchor 1 enabled, Anchors 2 and 3 disabled.
 - Status table: show or hide the summary table. Default on.
 - Label size: tiny, small, or normal. Default small.


█ WHAT MAKES IT ORIGINAL

Most Gann-count scripts plot a single count series in a single unit. This implementation differs in three specific ways. First, it runs trading-bar and calendar-day counts in parallel from the same anchor and explicitly detects their coincidence, which is the confluence condition emphasized in the source methodology rather than an afterthought. Second, anchor resolution uses closing-time containment instead of naive date equality, so anchors survive timezone differences, weekends, and holidays without silently shifting by one bar. Third, projection is handled correctly per unit: calendar squares are drawn in time coordinates and can therefore mark dates arbitrarily far in the future, while bar squares are drawn in bar coordinates and are projected only within the platform's future-bar range, keeping both unit systems accurate to their own definition.


█ NOTES / LIMITATIONS

 - Drawings are created once per script load on the last bar. As new realtime bars form, elapsed counts in the table and newly reachable verticals refresh only when the script recalculates, for example after a settings change or chart reload.
 - Bar-count verticals can be projected at most about 490 bars beyond the current bar, a platform ceiling on future bar-index coordinates. Calendar-day verticals have no such ceiling.
 - The script draws up to 500 lines and 500 labels. Many roots combined with three anchors, both units, and repeats can reach this ceiling, at which point the oldest objects are removed.
 - If an anchor timestamp predates the symbol's available history, the anchor resolves to the first available bar and every count measures from there, which is unlikely to be the intended pivot.
 - Bar counts depend on the chart timeframe and on the symbol's session definition. Symbols with irregular sessions or many holidays will show bar squares and calendar squares diverging substantially, which is expected behavior, not an error.
 - The indicator plots time factors only. It produces no directional forecast, and no claim is made about the outcome of price at any vertical.

## Source Code

````pine
//@version=6
indicator("Square Bar/Calendar Count Verticals (Gann-Brown)",
     shorttitle = "SQ COUNTS",
     overlay = true,
     max_lines_count = 500, max_labels_count = 500, max_boxes_count = 100)

// v2
// - Separate root sets for trading-bar and calendar-day counts; bar squares draw above 1D only by default
// - Calendar counts run on trading dates, so they match on every timeframe
// - Exclusive count is the default (square n lands n units after the anchor)
// - Confluence windows (squares from two or more different anchors) are detected and projected ahead
// - Future calendar squares are placed using last year's holiday pattern on daily charts
// - Drawings and table refresh on every new bar
// - Table and alerts include the 144 repeats; "next square" is the true minimum

// ═══════════════════════════ INPUTS ═══════════════════════════
grpS = "Squares"
barRootsStr = input.string("9,10,11,12,19", "Trading-bar roots", group = grpS,
     tooltip = "Brown's bar-count set from a major extreme: 9², 10², 11², 12², plus 19² for the helix cycle (Thirty-Second Jewel, Fig. 28.2).")
cdRootsStr  = input.string("7,8,9,10,11,12,13,14,15,16,17,18,19", "Calendar-day roots", group = grpS,
     tooltip = "Gann's running count of every square in calendar days from a pivot (Thirty-Second Jewel, Figs. 26.1, 26.3, 28.9).")
inclusive   = input.bool(false, "Inclusive count (anchor = bar/day 1)", group = grpS,
     tooltip = "Off: square n lands n units after the anchor (Brown: Apr 2 + 144 days = Aug 24). On: the anchor counts as 1, so every square lands one unit earlier.")
barMode     = input.string("Auto", "Trading-bar squares", options = ["Auto", "On", "Off"], group = grpS,
     tooltip = "Auto: drawn only on charts above 1D (weekly, 2-week, monthly). Brown counts bars on her 2-week charts and calendar days on daily charts, and on 24/7 daily charts bar squares duplicate calendar squares.")
showCD      = input.bool(true, "Calendar-day squares", group = grpS)
rep144      = input.int(3, "144 repeats (1 = off)", minval = 1, maxval = 10, group = grpS,
     tooltip = "Adds 288, 432 and further multiples of 144 from each anchor.")
repUnit     = input.string("Bars only", "144 repeats apply to", options = ["Bars only", "Bars and calendar days"], group = grpS,
     tooltip = "Brown: 'I do monitor 144 bar repeats from a key pivot.'")

grpC = "Confluence"
showConf = input.bool(true, "Mark confluence windows", group = grpC)
tol      = input.int(1, "Window (± bars)", minval = 0, maxval = 5, group = grpC,
     tooltip = "Squares from two or more different anchors that land within this many bars of each other form one window. A bar square and a calendar square from the same anchor do not count, because the trading calendar fixes their spacing. Brown's own 2018 examples differ by a day in how they count, so 0 is stricter than the source.")

grpA1 = "Anchor 1"
a1On  = input.bool(true, "Enable", group = grpA1)
a1T   = input.time(timestamp("2024-01-02T00:00:00"), "Pivot", confirm = true, group = grpA1)
a1Col = input.color(color.orange, "Color", group = grpA1)

grpA2 = "Anchor 2"
a2On  = input.bool(false, "Enable", group = grpA2)
a2T   = input.time(timestamp("2024-06-03T00:00:00"), "Pivot", group = grpA2)
a2Col = input.color(color.aqua, "Color", group = grpA2)

grpA3 = "Anchor 3"
a3On  = input.bool(false, "Enable", group = grpA3)
a3T   = input.time(timestamp("2024-09-02T00:00:00"), "Pivot", group = grpA3)
a3Col = input.color(color.fuchsia, "Color", group = grpA3)

grpT = "Display"
showTable = input.bool(true, "Status table", group = grpT)
emph19    = input.bool(true, "Emphasize 19² (361)", group = grpT,
     tooltip = "Brown: 361 calendar days from a major pivot 'is always a major date to watch closely.'")
lblSize   = input.string("small", "Label size", options = ["tiny", "small", "normal"], group = grpT)

// ═══════════════════════════ CONSTANTS ═══════════════════════════
int    MS_DAY   = 86400000
int    FUT_MAX  = 490
int    off      = inclusive ? 1 : 0
string sz       = lblSize == "tiny" ? size.tiny : lblSize == "small" ? size.small : size.normal

// ═══════════════════════════ DATE HELPERS ═══════════════════════════
// Civil day number (days since 1970-01-01) of a timestamp, in the exchange time zone.
f_dayNum(int t) =>
    math.round(timestamp("UTC", year(t), month(t), dayofmonth(t), 0, 0) / MS_DAY)

// Exchange-time-zone midnight of a civil day number.
f_dayStart(int dn) =>
    int u = dn * MS_DAY
    timestamp(syminfo.timezone, year(u, "UTC"), month(u, "UTC"), dayofmonth(u, "UTC"), 0, 0)

// Trading date of a bar-open timestamp. Sessions that open in the evening (futures, FX)
// belong to the next day, as TradingView's daily bars do.
f_tradeDay(int t) =>
    f_dayNum(t) + (hour(t) >= 15 ? 1 : 0)

// Weekday of a civil day number: 0 = Monday ... 6 = Sunday.
f_wd(int dn) =>
    int x = dn + 3
    x - int(math.floor(x / 7)) * 7

// Count of weekdays from a fixed Monday origin through dn. Difference of two calls = weekdays in (d1, d2].
f_wkCount(int dn) =>
    int x = dn + 3
    int q = int(math.floor(x / 7))
    q * 5 + math.min(x - q * 7 + 1, 5)

// Saturday and Sunday roll forward to Monday, matching bar containment.
f_nextWeekday(int dn) =>
    int w = f_wd(dn)
    w == 5 ? dn + 2 : w == 6 ? dn + 1 : dn

f_addWk(int dn, int k) =>
    int x = dn
    int c = 0
    while c < k
        x += 1
        if f_wd(x) < 5
            c += 1
    x

// ═══════════════════════════ ROOTS ═══════════════════════════
f_parse(string s) =>
    array<int> out = array.new<int>()
    for p in str.split(str.replace_all(s, " ", ""), ",")
        float v = str.tonumber(p)
        if not na(v) and v >= 2
            int r = int(v)
            if not out.includes(r)
                out.push(r)
    out.sort(order.ascending)
    out

var array<int> barRoots = f_parse(barRootsStr)
var array<int> cdRoots  = f_parse(cdRootsStr)

// ═══════════════════════════ PER-BAR CONTEXT ═══════════════════════════
// Trading date of the bar. time_tradingday handles sessions that open the evening before (futures, FX).
bool tfLE1D   = timeframe.isintraday or (timeframe.isdaily and timeframe.multiplier == 1)
bool showBars = barMode == "On" or (barMode == "Auto" and not tfLE1D)
int  barDay = tfLE1D ? math.round(time_tradingday / MS_DAY) : f_tradeDay(time)

var int  firstTime = time
var bool wkend     = false
if timeframe.isdaily and timeframe.multiplier == 1 and f_wd(barDay) >= 5
    wkend := true
bool  dailyWk  = timeframe.isdaily and timeframe.multiplier == 1 and not wkend
float avgBarMs = bar_index >= 100 ? (time - time[100]) / 100.0 : timeframe.in_seconds() * 1000.0

// Trading dates of every daily bar, used to replay last year's holiday pattern when projecting.
var array<int> dayHist = array.new<int>()
if timeframe.isdaily and timeframe.multiplier == 1
    dayHist.push(barDay)

// First index in dayHist with a date >= x.
f_lb(int x) =>
    int lo = 0
    int hi = dayHist.size()
    while lo < hi
        int mid = int(math.floor((lo + hi) / 2))
        if dayHist.get(mid) < x
            lo := mid + 1
        else
            hi := mid
    lo

int   lookN = math.min(bar_index + 1, 300)
float yTop  = ta.highest(high, lookN)
float yBot  = ta.lowest(low, lookN)

// ═══════════════════════════ TARGETS ═══════════════════════════
type Tgt
    int  anc     // 1..3
    int  unit    // 0 = trading bars, 1 = calendar days
    int  root    // 0 for a 144 repeat
    int  cnt     // squared count or k*144
    int  dn      // target trading date (calendar: fixed; bar: set when the bar prints)
    int  tT      // calendar target: exchange-time-zone midnight of dn
    int  xBar    // bar index (bar: exact; calendar: containing bar once reached)
    int  xTime   // open time of xBar once it has printed
    bool valid = true

var array<Tgt> tgts = array.new<Tgt>()

f_name(Tgt t) =>
    (t.root > 0 ? str.tostring(t.root) + "²" : str.tostring(int(t.cnt / 144)) + "×144") + (t.unit == 0 ? "b" : "cd")

f_lineTxt(Tgt t) =>
    t.root > 0 ? str.tostring(t.root) + "² = " + str.tostring(t.cnt) + (t.unit == 0 ? "b" : "cd") : f_name(t)

f_col(int anc) =>
    anc == 1 ? a1Col : anc == 2 ? a2Col : a3Col

// ═══════════════════ ANCHOR RESOLUTION (bar containment) ═══════════════════
// Bar counts start at the first bar whose close passes the anchor timestamp.
// Calendar counts start at the anchor's trading date. If the anchor predates loaded
// history, bar counts are suppressed and calendar counts still run from the true date.
f_resolve(int aT, bool pre) =>
    var int aBar  = na
    var int aTime = na
    var int aDay  = na
    if pre
        if na(aDay)
            aDay := f_tradeDay(aT)
    else if na(aBar) and time_close > aT
        aBar  := bar_index
        aTime := time
        aDay  := tfLE1D ? barDay : f_tradeDay(aT)
    [aBar, aTime, aDay]

f_build(int anc, bool en, bool pre, int aBar, int aDay) =>
    bool fresh = en and not na(aDay) and (pre ? barstate.isfirst : (not na(aBar) and aBar == bar_index))
    if fresh and showCD
        for r in cdRoots
            int dn = aDay + r * r - off
            tgts.push(Tgt.new(anc, 1, r, r * r, dn, f_dayStart(dn), na))
        if repUnit == "Bars and calendar days" and rep144 > 1
            for k = 2 to rep144
                int dn = aDay + k * 144 - off
                tgts.push(Tgt.new(anc, 1, 0, k * 144, dn, f_dayStart(dn), na))
    if fresh and showBars and not pre
        for r in barRoots
            tgts.push(Tgt.new(anc, 0, r, r * r, na, na, aBar + r * r - off))
        if rep144 > 1
            for k = 2 to rep144
                tgts.push(Tgt.new(anc, 0, 0, k * 144, na, na, aBar + k * 144 - off))
    fresh

bool a1Pre = a1T < firstTime
bool a2Pre = a2T < firstTime
bool a3Pre = a3T < firstTime

[a1Bar, a1Time, a1Day] = f_resolve(a1T, a1Pre)
[a2Bar, a2Time, a2Day] = f_resolve(a2T, a2Pre)
[a3Bar, a3Time, a3Day] = f_resolve(a3T, a3Pre)

f_build(1, a1On, a1Pre, a1Bar, a1Day)
f_build(2, a2On, a2Pre, a2Bar, a2Day)
f_build(3, a3On, a3Pre, a3Bar, a3Day)

// ═══════════════════ PER-BAR HITS ═══════════════════
bool barHitNow = false
bool cdHitNow  = false
// Calendar target reached: on charts up to 1D, the first bar of its trading date (weekend and
// holiday dates roll to the next session); above 1D, the bar whose span contains the date.
for t in tgts
    if t.unit == 1
        if t.valid and na(t.xBar)
            bool reached = tfLE1D ? barDay >= t.dn : time_close > t.tT
            if reached
                if barstate.isfirst and (tfLE1D ? barDay > t.dn : t.tT < time)
                    t.valid := false
                else
                    t.xBar   := bar_index
                    t.xTime  := time
                    cdHitNow := true
    else if not na(t.xBar) and t.xBar == bar_index
        t.dn      := barDay
        t.xTime   := time
        barHitNow := true

// ═══════════════════ PROJECTION ═══════════════════
// Bars ahead of the last bar to the bar that will contain a future calendar target.
// Daily, weekday-only: count the bars in the same window shifted back a whole number of
// 52-week years, so weekends line up and last year's holidays stand in for this year's.
// Elsewhere: estimate from the average bar duration.
f_projK(Tgt t) =>
    int k = 0
    if dailyWk
        int S = 364 * int(math.ceil((t.dn - barDay + 7) / 364))
        if dayHist.size() > 0 and barDay - S >= dayHist.first()
            k := f_lb(t.dn - S) - f_lb(barDay - S + 1) + 1
        else
            k := f_wkCount(f_nextWeekday(t.dn)) - f_wkCount(barDay)
    else if t.tT >= time_close
        k := int(math.floor((t.tT - time_close) / avgBarMs)) + 1
    k

// Approximate trading date of the bar k bars after the last bar (same replay idea).
f_futDay(int k) =>
    int d = na
    if dailyWk
        int S = 364 * int(math.ceil((k * 1.5 + 14) / 364))
        int j = f_lb(barDay - S + 1) + k - 1
        if dayHist.size() > 0 and barDay - S >= dayHist.first() and j < dayHist.size() - 1
            d := dayHist.get(j) + S
        else
            d := f_addWk(barDay, k)
    else
        int tf = time + int(k * avgBarMs)
        d := timeframe.isintraday ? f_dayNum(tf) : f_tradeDay(tf)
    d

// ═══════════════════ DRAWING ═══════════════════
var array<line>  dLines  = array.new<line>()
var array<label> dLabels = array.new<label>()
var array<box>   dBoxes  = array.new<box>()
var table        tb      = na

if barstate.isfirst and showTable
    tb := table.new(position.top_right, 4, 5, border_width = 1,
         bgcolor = color.new(color.black, 15), frame_color = color.gray)
    table.merge_cells(tb, 0, 4, 3, 4)

f_vline(int x, string xl, color col, int w, string lst, string txt, float yLab, string lbst) =>
    dLines.push(line.new(x, yBot, x, yTop, xloc = xl, extend = extend.both, color = col, style = lst, width = w))
    dLabels.push(label.new(x, yLab, txt, xloc = xl, style = lbst, color = col, textcolor = color.white, size = sz))
    0

// Past objects are placed by bar time, future ones by bar index: bar-index coordinates far in
// the past hit the platform's 10,000-bar limit and history-buffer errors on realtime redraws.
f_anchor(int anc, bool en, bool pre, int aTime, int aDay, float span) =>
    if en and not pre and not na(aTime)
        color col = f_col(anc)
        dLines.push(line.new(aTime, yBot, aTime, yTop, xloc = xloc.bar_time, extend = extend.both, color = col, width = 2))
        dLabels.push(label.new(aTime, yTop + span * (0.28 + 0.05 * (anc - 1)),
             "◆ A" + str.tostring(anc) + " " + str.format_time(f_dayStart(aDay), "yyyy-MM-dd"),
             xloc = xloc.bar_time, style = label.style_label_down, color = col, textcolor = color.black, size = sz))
    0

// Summarize one candidate window:
// [qualifies, lo, hi, date, projected, members, center bar, lo time, hi time, center time]
f_group(array<int> ord, array<int> cx, array<int> ci, array<int> ct, int g0, int g1) =>
    array<int> srcs = array.new<int>()
    string txt = ""
    int    lo  = na
    int    hi  = na
    int    gd  = na
    bool   pj  = false
    for m = g0 to g1
        int x   = cx.get(ord.get(m))
        Tgt t   = tgts.get(ci.get(ord.get(m)))
        if not srcs.includes(t.anc)
            srcs.push(t.anc)
        lo := na(lo) ? x : math.min(lo, x)
        hi := na(hi) ? x : math.max(hi, x)
        if na(gd) and not na(t.dn)
            gd := t.dn
        if t.unit == 1 and na(t.xBar)
            pj := true
        txt := (txt == "" ? "" : txt + " · ") + "A" + str.tostring(t.anc) + " " + f_name(t)
    int xm   = math.round((lo + hi) / 2)
    int cT   = na
    int best = na
    for m = g0 to g1
        int dd = math.abs(cx.get(ord.get(m)) - xm)
        if na(best) or dd < best
            best := dd
            cT   := ct.get(ord.get(m))
    [srcs.size() >= 2, lo, hi, gd, pj, txt, xm, ct.get(ord.get(g0)), ct.get(ord.get(g1)), cT]

f_row(int row, int anc, bool en, bool pre, int aBar, int aDay, int today) =>
    if en and not na(aDay)
        string nm  = "A" + str.tostring(anc) + " " + str.format_time(f_dayStart(aDay), "yy-MM-dd") + (pre ? " ⚠" : "")
        string el  = (pre or na(aBar) ? "–" : str.tostring(bar_index - aBar + off)) + "b / " + str.tostring(today - aDay + off) + "cd"
        int    nb  = na
        string nbt = ""
        int    nd  = na
        string ndt = ""
        for t in tgts
            if t.anc == anc and t.valid
                if t.unit == 0 and t.xBar >= bar_index and (na(nb) or t.xBar < nb)
                    nb  := t.xBar
                    nbt := f_name(t)
                if t.unit == 1 and t.dn >= today and (na(nd) or t.dn < nd)
                    nd  := t.dn
                    ndt := f_name(t)
        string sBar = pre ? "before data" :
             na(nb) ? (showBars ? "none ahead" : barMode == "Auto" ? "above 1D only" : "off") :
             nb == bar_index ? nbt + " today" :
             nbt + " in " + str.tostring(nb - bar_index) + " bars (~" + str.format_time(f_dayStart(f_futDay(nb - bar_index)), "MM-dd") + ")"
        string sCd  = na(nd) ? (showCD ? "none ahead" : "off") :
             nd == today ? ndt + " today" :
             ndt + " on " + str.format_time(f_dayStart(nd), "yy-MM-dd")
        table.cell(tb, 0, row, nm,   text_color = f_col(anc),  text_size = size.small)
        table.cell(tb, 1, row, el,   text_color = color.white, text_size = size.small)
        table.cell(tb, 2, row, sBar, text_color = color.white, text_size = size.small)
        table.cell(tb, 3, row, sCd,  text_color = color.white, text_size = size.small)
    0

bool   confNow  = false
string nextConf = ""

if barstate.islast
    // Redraw every bar so new squares, projections and elapsed counts stay current.
    for l in dLines
        l.delete()
    dLines.clear()
    for lb in dLabels
        lb.delete()
    dLabels.clear()
    for bx in dBoxes
        bx.delete()
    dBoxes.clear()

    float span = math.max(yTop - yBot, syminfo.mintick * 10)
    int   maxX = bar_index + FUT_MAX
    int   tod  = time - f_dayStart(barDay)   // session open offset from midnight of the trading date

    f_anchor(1, a1On, a1Pre, a1Time, a1Day, span)
    f_anchor(2, a2On, a2Pre, a2Time, a2Day, span)
    f_anchor(3, a3On, a3Pre, a3Time, a3Day, span)

    // Square verticals. Solid = trading bars (labels above), dashed = calendar days (labels below).
    array<int> cx = array.new<int>()   // bar position of each drawable target
    array<int> ci = array.new<int>()   // index into tgts
    array<int> ct = array.new<int>()   // bar time once printed, else na
    for [i, t] in tgts
        if t.valid
            color  col = f_col(t.anc)
            int    w   = emph19 and t.cnt == 361 ? 2 : 1
            float  yo  = span * (0.03 + 0.05 * (t.anc - 1))
            string tx  = f_lineTxt(t)
            if t.unit == 0
                if t.xBar <= bar_index
                    f_vline(t.xTime, xloc.bar_time, color.new(col, 25), w, line.style_solid, tx, yTop + yo, label.style_label_down)
                else if t.xBar <= maxX
                    f_vline(t.xBar, xloc.bar_index, color.new(col, 25), w, line.style_solid, tx, yTop + yo, label.style_label_down)
                if t.xBar <= maxX
                    cx.push(t.xBar)
                    ci.push(i)
                    ct.push(t.xTime)
            else if not na(t.xBar)
                f_vline(t.xTime, xloc.bar_time, color.new(col, 45), w, line.style_dashed, tx, yBot - yo, label.style_label_up)
                cx.push(t.xBar)
                ci.push(i)
                ct.push(t.xTime)
            else
                // Future calendar square: projected bar inside the future-bar range, else by date.
                // The label carries the date because the future time axis is itself an estimate.
                int    k   = f_projK(t)
                string txf = tx + "\n" + str.format_time(t.tT, "yy-MM-dd")
                if bar_index + k <= maxX
                    f_vline(bar_index + k, xloc.bar_index, color.new(col, 45), w, line.style_dashed, txf, yBot - yo, label.style_label_up)
                    cx.push(bar_index + k)
                    ci.push(i)
                    ct.push(na)
                else
                    int xt = dailyWk ? f_dayStart(f_nextWeekday(t.dn)) + tod : t.tT
                    f_vline(xt, xloc.bar_time, color.new(col, 45), w, line.style_dashed, txf, yBot - yo, label.style_label_up)

    // Confluence windows: squares from two or more different anchors chained within ±tol bars,
    // total span capped at 2×tol. Same-anchor bar/calendar pairs are excluded because their
    // spacing is set by the exchange calendar (100 trading days ≈ 144 calendar days), not the market.
    if showConf and cx.size() > 1
        array<int> ord = cx.sort_indices(order.ascending)
        int g0 = 0
        for j = 1 to ord.size()
            bool brk = j == ord.size()
            if not brk
                int xj = cx.get(ord.get(j))
                brk := xj - cx.get(ord.get(j - 1)) > tol or xj - cx.get(ord.get(g0)) > 2 * tol
            if brk
                [ok, lo, hi, gd0, pj0, gtxt, xm, loT, hiT, cT] = f_group(ord, cx, ci, ct, g0, j - 1)
                if ok
                    bool   pj   = pj0 or na(gd0)
                    int    gd   = na(gd0) ? f_futDay(lo - bar_index) : gd0
                    string dstr = (pj ? "~" : "") + str.format_time(f_dayStart(gd), "yyyy-MM-dd")
                    // Fully printed windows are placed by time, windows touching the future by bar index.
                    bool   past = hi <= bar_index
                    string xl   = past ? xloc.bar_time : xloc.bar_index
                    int    xc   = past ? cT  : xm
                    int    xa   = past ? loT : lo
                    int    xb   = past ? hiT : hi
                    dLines.push(line.new(xc, yBot, xc, yTop, xloc = xl, extend = extend.both,
                         color = color.new(color.white, 10), width = 2))
                    if hi > lo
                        dBoxes.push(box.new(xa, yTop + span * 0.3, xb, yBot - span * 0.3, xloc = xl,
                             border_color = color.new(color.white, 70), bgcolor = color.new(color.white, 88)))
                    dLabels.push(label.new(xc, yTop + span * 0.20, "✕ " + dstr + "\n" + gtxt,
                         xloc = xl, style = label.style_label_down,
                         color = color.new(color.white, 10), textcolor = color.black, size = sz))
                    if lo == bar_index
                        confNow := true
                    if hi >= bar_index and nextConf == ""
                        nextConf := (lo <= bar_index ? "✕ window open: " : "Next ✕ ") + dstr + "  " + gtxt
                g0 := j

    if showTable and not na(tb)
        int today = f_dayNum(timenow)
        table.cell(tb, 0, 0, "Anchor",    text_color = color.silver, text_size = size.small)
        table.cell(tb, 1, 0, "Elapsed",   text_color = color.silver, text_size = size.small)
        table.cell(tb, 2, 0, "Next bar²", text_color = color.silver, text_size = size.small)
        table.cell(tb, 3, 0, "Next cd²",  text_color = color.silver, text_size = size.small)
        f_row(1, 1, a1On, a1Pre, a1Bar, a1Day, today)
        f_row(2, 2, a2On, a2Pre, a2Bar, a2Day, today)
        f_row(3, 3, a3On, a3Pre, a3Bar, a3Day, today)
        int    nAnc    = (a1On and not na(a1Day) ? 1 : 0) + (a2On and not na(a2Day) ? 1 : 0) + (a3On and not na(a3Day) ? 1 : 0)
        string confTxt = not showConf ? "Confluence off" : nAnc < 2 ? "✕ needs two or more anchors" : nextConf == "" ? "No ✕ within " + str.tostring(FUT_MAX) + " bars" : nextConf
        table.cell(tb, 0, 4, confTxt, text_color = color.yellow, text_size = size.small, text_halign = text.align_left)

// ═══════════════════════════ ALERTS ═══════════════════════════
alertcondition(barHitNow, "Bar square hit",                 "SQ COUNTS: a trading-bar square from an anchor completes on this bar")
alertcondition(cdHitNow,  "Calendar square hit",            "SQ COUNTS: a calendar-day square date falls in this bar")
alertcondition(confNow,   "Square confluence window opens", "SQ COUNTS: squares from two or more anchors converge in a window that starts on this bar")
````
