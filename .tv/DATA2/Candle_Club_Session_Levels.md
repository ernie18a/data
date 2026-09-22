<!-- tradingview-pine-id: PUB;1fb1f868e7d546c38177cc44b31fe51d -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Candle Club - Session Levels

Source: https://www.tradingview.com/script/UsCE5eHM-Candle-Club-Session-Levels/

## Description

Yesterday's high, the overnight range and today's open, drawn where they formed and kept on the chart so you can see what price did there.

WHAT IT DRAWS
Prior day high, low and close; overnight high and low; the cash-session open; an optional prior-day midline and round-number reference lines; and shelf zones, shaded pockets where recent session highs and lows cluster. Each day's lines start when that level becomes known and stop when the next one replaces it, so history stays readable.

THE IDEA
A session extreme is a place the market reached and turned away from; the overnight range is the path it took while the cash session was shut. Many traders watch these places, and this tool's only job is to put them on your chart where you can see them. It makes no claim about what price does when it returns there; what you do at a level is your call.

WHAT IS ORIGINAL
Shelf zones. The script banks each completed session's high and low, sorts the last few days of them, and groups any within your chosen width of each other. Two or more in one pocket become a box starting where its oldest member formed. One extreme is a number; a cluster is a shelf the market has revisited.

HOW TO USE
Set the cash session and timezone for your market (default: US index futures and stocks) and how many days to keep. Read it top down: the table lists every level and how far it sits from the last price, so you can see at a glance what is above and below you. Shaded boxes are shelf zones - the more session extremes stacked in one, the more times the market has stopped in that pocket. Set one alert per level, or the "any level" alert, to be told when price crosses one instead of watching. Best on 1-minute to 15-minute charts; it draws nothing on daily and above.

SETTINGS
One group per family: prior day, overnight, open, shelf zones, round lines, each with an on/off switch and colour on one row, then width and style. Neutral lines follow your chart theme. Prior day can use the exchange's daily bar or the previous cash session only.

LIMITATIONS
Intraday charts only. On stocks the overnight means the pre- and post-market bars on your chart, so extended hours must be on. The cash-session option needs one completed session first. Overnight here means everything outside the cash session you set, so if you also run a tool that starts its overnight at a fixed hour the two will not always draw the same line. The round-number lines are an evenly spaced grid, off by default. They are drawn for reference only and nothing here claims price behaves differently at them.

A standalone drawing tool with no buy or sell signals.

---

## Source Code

````pine
// This Pine Script code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Candle_Club
//@version=6

// =====================================================================
//  Candle Club - Session Levels
//
//  WHAT IT DRAWS
//    A small set of price levels that come from where the market has
//    actually traded, and nothing else:
//      - the prior day's high, low and close
//      - the overnight high and low (the range that formed while the
//        cash session was shut)
//      - today's cash-session open
//      - shelf zones: pockets where session highs and lows from the
//        last few days sit within a short distance of each other
//      - optional round-number reference lines and a prior-day midline
//    Each day's lines start when that level becomes known and stop when
//    the next one replaces it, so you can look back and see how price
//    behaved at yesterday's high, not just today's.
//
//  THE IDEA
//    A moving average is a calculation that follows price. A session
//    extreme is a place: the highest and lowest price the market
//    accepted before it turned. Many traders watch these places, and
//    this tool's only job is to put them on your chart where you can
//    see them. It makes no claim about what price does when it returns
//    there; how you use the levels is up to you.
//
//  SHELF ZONES (the original part)
//    Every cash session leaves two extremes. The script keeps the last
//    N sessions' highs and lows, sorts them, and groups any that fall
//    within your chosen width of each other. A group of two or more
//    becomes a shaded box, drawn from the bar where its oldest member
//    formed. One extreme is a number; several stacked in one pocket is
//    a shelf the market has come back to more than once.
//
//  SETTINGS OVERVIEW
//    Session: cash hours, timezone, how many days of history to keep,
//    whether today's lines run to the right edge.
//    One group per family (prior day, overnight, open, shelf zones,
//    round lines): an on/off switch with its colour on the same row,
//    then line width and style.
//    Labels & table: label size, and a small table listing each level's
//    price and its distance from the last price.
//    Alerts: one alert per level being crossed, plus an "any level" one.
//
//  LIMITATIONS
//    - Intraday charts only. On daily and above the script draws nothing
//      but a note.
//    - On stocks, "overnight" means the pre- and post-market bars shown
//      on your chart. With extended hours switched off there are no
//      such bars, so the overnight levels stay empty.
//    - Prior day levels come from the exchange's daily bar by default.
//      For futures that daily bar includes the overnight. Switch on
//      "Prior day = cash session only" to use the previous cash session
//      instead; that option needs at least one completed session on
//      the chart before it can draw.
//    - The cash session must be shorter than the trading day for an
//      overnight range to exist.
//    - This is a standalone drawing tool. It has no buy or sell arrows
//      and does not tell you what to do at a level.
// =====================================================================
indicator("Candle Club - Session Levels", "CC Levels", overlay = true,
     max_lines_count = 160, max_labels_count = 160, max_boxes_count = 40)

// ---------------------------------------------------------------- inputs
grpS = "Session"
rthSess     = input.session("0930-1600", "Cash session", group = grpS,
     tooltip = "Regular trading hours of the market you trade, written in the session timezone below. Everything outside this window counts as overnight. The default fits US index futures and US stocks.")
tzChoice    = input.string("Exchange", "Session timezone", group = grpS,
     options = ["Exchange", "America/New_York", "America/Chicago", "Europe/London", "Asia/Tokyo"],
     tooltip = "Timezone the cash session times are written in. Exchange uses the symbol's own exchange timezone, which is right for most charts.")
daysShow    = input.int(3, "Days to show", minval = 1, maxval = 20, group = grpS,
     tooltip = "How many days of levels stay on the chart, counting today. Older lines and labels are removed.")
extendRight = input.bool(true, "Extend lines right", group = grpS,
     tooltip = "On: today's lines run to the right edge of the chart. Off: they stop at the last bar.")

grpPD = "Prior day"
showPD   = input.bool(true, "Prior day high / low / close", inline = "pd1", group = grpPD,
     tooltip = "Draws the previous day's high, low and close. The colour picker beside it sets the colour of those lines and labels.")
colPD    = input.color(color.orange, "", inline = "pd1", group = grpPD,
     tooltip = "Colour of the prior day lines and labels.")
wPD      = input.int(1, "PD width", minval = 1, maxval = 3, inline = "pd2", group = grpPD,
     tooltip = "Line width for the prior day levels.")
stPDIn   = input.string("Solid", "PD style", options = ["Solid", "Dashed", "Dotted"], inline = "pd2", group = grpPD,
     tooltip = "Line style for the prior day high and low. The prior day close is always dotted so it stands apart at a glance.")
showMid  = input.bool(false, "Prior day midline", group = grpPD,
     tooltip = "Draws the halfway point between the prior day high and low as a dotted line in the prior day colour.")
pdCash   = input.bool(false, "Prior day = cash session only", group = grpPD,
     tooltip = "Off: prior day levels come from the exchange's daily bar, which for futures includes the overnight. On: they come from the previous cash session only, as set in the Session group.")

grpON = "Overnight"
showON   = input.bool(true, "Overnight high / low", inline = "on1", group = grpON,
     tooltip = "Draws the high and low of the bars between one cash close and the next cash open. While the overnight is still running the lines follow it live. On stocks this needs extended hours switched on.")
colON    = input.color(color.blue, "", inline = "on1", group = grpON,
     tooltip = "Colour of the overnight lines and labels.")
wON      = input.int(1, "ON width", minval = 1, maxval = 3, inline = "on2", group = grpON,
     tooltip = "Line width for the overnight levels.")
stONIn   = input.string("Dashed", "ON style", options = ["Solid", "Dashed", "Dotted"], inline = "on2", group = grpON,
     tooltip = "Line style for the overnight levels.")

grpOP = "Session open"
showOpen = input.bool(true, "Session open", inline = "op1", group = grpOP,
     tooltip = "Draws the open of the current cash session from its first bar.")
colOpenIn = input.color(color.gray, "", inline = "op1", group = grpOP,
     tooltip = "Colour of the open line and label. Only used when 'Neutral lines follow chart theme' is off.")
wOpen    = input.int(1, "Open width", minval = 1, maxval = 3, inline = "op2", group = grpOP,
     tooltip = "Line width for the session open.")
stOpenIn = input.string("Dotted", "Open style", options = ["Solid", "Dashed", "Dotted"], inline = "op2", group = grpOP,
     tooltip = "Line style for the session open.")
themeNeutral = input.bool(true, "Neutral lines follow chart theme", group = grpOP,
     tooltip = "On: the open line and the round reference lines take the chart's text colour, so they read on dark and light charts alike. Off: they use their colour pickers.")
shadeRTH = input.bool(false, "Shade cash session", group = grpOP,
     tooltip = "Lightly tints the background during the cash session so the overnight stands out.")

grpZ = "Shelf zones"
showShelf = input.bool(true, "Show shelf zones", inline = "sh1", group = grpZ,
     tooltip = "Shades pockets where two or more recent session highs or lows sit within the cluster width of each other. Zones are rebuilt once per session close.")
colShelf  = input.color(color.new(color.orange, 88), "", inline = "sh1", group = grpZ,
     tooltip = "Fill colour of the shelf boxes. The border uses the same colour, less transparent.")
lookDays  = input.int(5, "Days of extremes to cluster", minval = 2, maxval = 20, group = grpZ,
     tooltip = "How many completed cash sessions contribute their high and low to the clustering.")
clusterD  = input.float(40., "Cluster width (price)", minval = 1, group = grpZ,
     tooltip = "Two session extremes within this many price units of each other count as one shelf.")

grpR = "Round reference lines"
showRound = input.bool(false, "Nearest round numbers", inline = "rd1", group = grpR,
     tooltip = "Draws evenly spaced reference lines at round multiples of the step nearest to the last price. Plain reference lines, off by default.")
colRoundIn = input.color(color.new(color.gray, 55), "", inline = "rd1", group = grpR,
     tooltip = "Colour of the round reference lines. Only used when 'Neutral lines follow chart theme' is off.")
roundStep = input.float(100., "Round number step", minval = 1, group = grpR,
     tooltip = "Spacing between round reference lines, in price units.")
roundN    = input.int(2, "How many each side", minval = 1, maxval = 6, group = grpR,
     tooltip = "How many round lines to draw above and below the nearest one.")
wRound    = input.int(1, "Round width", minval = 1, maxval = 3, inline = "rd2", group = grpR,
     tooltip = "Line width for the round reference lines.")
stRoundIn = input.string("Dotted", "Round style", options = ["Solid", "Dashed", "Dotted"], inline = "rd2", group = grpR,
     tooltip = "Line style for the round reference lines.")

grpT = "Labels & table"
showLbl   = input.bool(true, "Labels", group = grpT,
     tooltip = "Shows a name and price label at the right end of every level line.")
lblSizeIn = input.string("Small", "Label size", options = ["Tiny", "Small", "Normal"], group = grpT,
     tooltip = "Text size of the level labels.")
showTbl   = input.bool(true, "Show level table", group = grpT,
     tooltip = "Shows a table with each level's price and its distance from the last price. Plus means the level is above price.")
tblPosIn  = input.string("Top right", "Table position", group = grpT,
     options = ["Top left", "Top center", "Top right", "Middle left", "Middle center", "Middle right", "Bottom left", "Bottom center", "Bottom right"],
     tooltip = "Where the level table sits on the chart.")

// ------------------------------------------------------- derived settings
// @function Maps a style option to the matching line style constant.
// @param s (string) One of "Solid", "Dashed", "Dotted".
// @returns (string) A line.style_* constant.
f_style(string s) =>
    switch s
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

// @function Maps a position option to the matching table position constant.
// @param s (string) One of the "Table position" options.
// @returns (string) A position.* constant.
f_pos(string s) =>
    switch s
        "Top left"      => position.top_left
        "Top center"    => position.top_center
        "Middle left"   => position.middle_left
        "Middle center" => position.middle_center
        "Middle right"  => position.middle_right
        "Bottom left"   => position.bottom_left
        "Bottom center" => position.bottom_center
        "Bottom right"  => position.bottom_right
        => position.top_right

isOK     = timeframe.isintraday
tz       = tzChoice == "Exchange" ? syminfo.timezone : tzChoice
lineExt  = extendRight ? extend.right : extend.none
stPD     = f_style(stPDIn)
stON     = f_style(stONIn)
stOpen   = f_style(stOpenIn)
stRound  = f_style(stRoundIn)
colOpen  = themeNeutral ? color.new(chart.fg_color, 30) : colOpenIn
colRound = themeNeutral ? color.new(chart.fg_color, 70) : colRoundIn
lblSz    = switch lblSizeIn
    "Tiny"   => size.tiny
    "Normal" => size.normal
    => size.small
tblPos   = f_pos(tblPosIn)

// label x-offset per family, in bars, so labels of different families
// do not sit on top of each other when their prices are close. The tags end
// at the last bar and grow LEFTWARDS, so an offset moves a family further
// back into the chart, never out towards the price scale where it would be
// cut off. Prior day sits at the right edge, overnight one step back, the
// session open one more - the overnight high and the open are often only a
// few points apart and would otherwise be one unreadable stack.
OFF_PD = 0
OFF_ON = 14
OFF_OP = 28
// how far back the round reference lines start
ROUND_BACK = 20
COL_UP = #26a69a
COL_DN = #ef5350

// ---------------------------------------------------------- level sets
// @type One family's lines and labels for one day.
// @field lines  The level lines, in the order they were added.
// @field labels The matching labels (empty when labels are off).
// @field offs   Label x-offset in bars, one per label.
type LevelSet
    array<line>  lines
    array<label> labels
    array<int>   offs

// @function Creates an empty level set.
// @returns (LevelSet) A set with empty arrays.
f_newSet() =>
    LevelSet.new(array.new<line>(), array.new<label>(), array.new<int>())

// @function Adds one horizontal level to the set, starting at the current bar.
// @param s     (LevelSet) The set to add to.
// @param y     (float) The price. Nothing is added when it is na.
// @param name  (string) Label text before the price.
// @param col   (color) Line and label colour.
// @param width (int) Line width.
// @param sty   (string) A line.style_* constant.
// @param off   (int) Label x-offset in bars.
// @returns (void)
method add(LevelSet s, float y, string name, color col, int width, string sty, int off) =>
    if not na(y)
        array.push(s.lines, line.new(bar_index, y, bar_index + 1, y, extend = lineExt,
             color = col, style = sty, width = width))
        if showLbl
            // The tag ENDS at the last bar and grows leftwards (label_right
            // puts the pointer on the right). A label anchored past the last
            // bar runs into the price scale and gets cut off there - measured
            // on a default chart, "PD Low 29001.75" lost its price. Solid
            // fill in the level's colour with the chart's own background as
            // the text colour, so it reads on a dark chart and a light one.
            array.push(s.labels, label.new(math.max(bar_index - off, 0), y,
                 name + " " + str.tostring(y, format.mintick),
                 style = label.style_label_right, color = col,
                 textcolor = chart.bg_color, size = lblSz))
            array.push(s.offs, off)

// @function Moves level i of the set to a new price and refreshes its label.
// @param s    (LevelSet) The set.
// @param i    (int) Index of the level, in the order it was added.
// @param y    (float) The new price.
// @param name (string) Label text before the price.
// @returns (void)
method setLevel(LevelSet s, int i, float y, string name) =>
    if i < array.size(s.lines)
        l = array.get(s.lines, i)
        line.set_y1(l, y)
        line.set_y2(l, y)
    if i < array.size(s.labels)
        lb = array.get(s.labels, i)
        label.set_y(lb, y)
        label.set_text(lb, name + " " + str.tostring(y, format.mintick))

// @function Stops every line in the set at bar x and drops its labels.
// History keeps the lines, never the labels: a finished day's label would
// otherwise sit in the middle of the bars that came after it, on top of the
// candles, showing a price that is no longer the live one. Only the current
// day's levels are named; the older ones are lines you can look back at.
// @param s (LevelSet) The set.
// @param x (int) The bar index where the lines end.
// @returns (void)
method finish(LevelSet s, int x) =>
    for l in s.lines
        line.set_x2(l, x)
        line.set_extend(l, extend.none)
    for lb in s.labels
        label.delete(lb)
    array.clear(s.labels)
    array.clear(s.offs)

// @function Keeps a live set's labels (and, with extension off, its lines) at the last bar.
// @param s (LevelSet) The set.
// @param x (int) The last bar index.
// @returns (void)
method follow(LevelSet s, int x) =>
    if not extendRight
        for l in s.lines
            line.set_x2(l, math.max(x, line.get_x1(l) + 1))
    for [i, lb] in s.labels
        label.set_x(lb, math.max(x - array.get(s.offs, i), 0))

// @function Deletes every drawing in the set.
// @param s (LevelSet) The set.
// @returns (void)
method erase(LevelSet s) =>
    for l in s.lines
        line.delete(l)
    for lb in s.labels
        label.delete(lb)

// @function Closes the live set at bar x, files it in history, drops the oldest beyond keep, and returns a fresh set.
// @param cur  (LevelSet) The live set.
// @param hist (array<LevelSet>) Finished sets, oldest first.
// @param x    (int) The bar index where the live set ends.
// @param keep (int) How many finished sets to keep.
// @returns (LevelSet) A new empty set to draw into.
f_rotate(LevelSet cur, array<LevelSet> hist, int x, int keep) =>
    if array.size(cur.lines) > 0
        cur.finish(x)
        array.push(hist, cur)
    while array.size(hist) > keep
        old = array.shift(hist)
        old.erase()
    f_newSet()

// --------------------------------------------------------- session bits
inRTH   = not na(time(timeframe.period, rthSess, tz))
dayRoll = timeframe.change("D")
// a session also starts when one cash day follows another with no
// overnight bars in between (stocks with extended hours off)
newRTH  = inRTH and (not inRTH[1] or dayRoll)
sessEnd = inRTH[1] and (not inRTH or newRTH)

// prior day from the exchange's daily bar: one call, previous completed
// day, the standard non-repainting idiom
[pdhD, pdlD, pdcD] = request.security(syminfo.tickerid, "D", [high[1], low[1], close[1]],
     lookahead = barmerge.lookahead_on)

// this session's running extremes and where they formed
var float curH    = na
var float curL    = na
var int   curHBar = na
var int   curLBar = na

// the last completed cash session, banked when it ends
var float cashH = na
var float cashL = na
var float cashC = na

// banked session extremes for the shelf zones, oldest first
var array<float> exts    = array.new<float>()
var array<int>   extBars = array.new<int>()

// bank the session that just ended BEFORE the running extremes reset
if sessEnd and not na(curH)
    cashH := curH
    cashL := curL
    cashC := close[1]
    array.push(exts, curH)
    array.push(extBars, curHBar)
    array.push(exts, curL)
    array.push(extBars, curLBar)
    while array.size(exts) > lookDays * 2
        array.shift(exts)
        array.shift(extBars)

if newRTH
    curH    := high
    curL    := low
    curHBar := bar_index
    curLBar := bar_index
else if inRTH and not na(curH)
    if high > curH
        curH    := high
        curHBar := bar_index
    if low < curL
        curL    := low
        curLBar := bar_index

pdh = pdCash ? cashH : pdhD
pdl = pdCash ? cashL : pdlD
pdc = pdCash ? cashC : pdcD
pdNew = not na(pdh) and not na(pdl) and not na(pdc) and
     (na(pdh[1]) or pdh != pdh[1] or pdl != pdl[1] or pdc != pdc[1])

// overnight = everything between one cash close and the next cash open
var float onH = na
var float onL = na
onStart = not inRTH and (inRTH[1] or na(onH))
if onStart
    onH := high
    onL := low
else if not inRTH
    onH := math.max(onH, high)
    onL := math.min(onL, low)

var float sessOpen = na
if newRTH
    sessOpen := open

// ---------------------------------------------------------------- draw
var LevelSet        pdSet  = f_newSet()
var array<LevelSet> pdHist = array.new<LevelSet>()
var LevelSet        onSet  = f_newSet()
var array<LevelSet> onHist = array.new<LevelSet>()
var LevelSet        opSet  = f_newSet()
var array<LevelSet> opHist = array.new<LevelSet>()

// prior day: a new set whenever the prior day values change
if isOK and pdNew
    pdSet := f_rotate(pdSet, pdHist, bar_index, daysShow - 1)
    if showPD
        pdSet.add(pdh, "PD High", colPD, wPD, stPD, OFF_PD)
        pdSet.add(pdl, "PD Low", colPD, wPD, stPD, OFF_PD)
        pdSet.add(pdc, "PD Close", colPD, wPD, line.style_dotted, OFF_PD)
    if showMid
        pdSet.add((pdh + pdl) / 2, "PD Mid", colPD, 1, line.style_dotted, OFF_PD)

// overnight: a new set when the overnight starts, kept live until the open
if isOK and onStart
    onSet := f_rotate(onSet, onHist, bar_index, daysShow - 1)
    if showON
        onSet.add(onH, "ON High", colON, wON, stON, OFF_ON)
        onSet.add(onL, "ON Low", colON, wON, stON, OFF_ON)
else if isOK and not inRTH and showON
    if onH != onH[1]
        onSet.setLevel(0, onH, "ON High")
    if onL != onL[1]
        onSet.setLevel(1, onL, "ON Low")

// session open: a new set at every cash open
if isOK and newRTH
    opSet := f_rotate(opSet, opHist, bar_index, daysShow - 1)
    if showOpen
        opSet.add(sessOpen, "Open", colOpen, wOpen, stOpen, OFF_OP)

// keep the live sets pinned to the last bar
if isOK and barstate.islast
    pdSet.follow(bar_index)
    onSet.follow(bar_index)
    opSet.follow(bar_index)

// ------------------------------------------------------------ shelf zones
// @function Rebuilds the shelf boxes from the banked session extremes.
// @param px    (array<float>) Session extremes.
// @param bars  (array<int>) Bar index where each extreme formed, same order.
// @param out   (array<box>) The boxes; cleared and refilled.
// @param width (float) Cluster width in price units.
// @param fill  (color) Box fill colour.
// @returns (void)
f_buildShelves(array<float> px, array<int> bars, array<box> out, float width, color fill) =>
    while array.size(out) > 0
        box.delete(array.pop(out))
    idx = array.sort_indices(px, order.ascending)
    n = array.size(idx)
    i = 0
    while i < n
        k0   = array.get(idx, i)
        lo   = array.get(px, k0)
        hi   = lo
        left = array.get(bars, k0)
        j = i + 1
        while j < n and array.get(px, array.get(idx, j)) - lo <= width
            k = array.get(idx, j)
            hi   := array.get(px, k)
            left := math.min(left, array.get(bars, k))
            j += 1
        if j - i >= 2
            array.push(out, box.new(left, hi, bar_index, lo, border_color = color.new(fill, 40),
                 bgcolor = fill, extend = extend.right))
        i := j

var array<box> shelves = array.new<box>()
if isOK and showShelf and sessEnd and array.size(exts) >= 2
    f_buildShelves(exts, extBars, shelves, clusterD, colShelf)

// -------------------------------------------------- round reference lines
var array<line> roundLines = array.new<line>()
if isOK and showRound and barstate.islast
    base = math.round(close / roundStep) * roundStep
    x1 = math.max(bar_index - ROUND_BACK, 0)
    for i = -roundN to roundN
        y = base + i * roundStep
        k = i + roundN
        if k >= array.size(roundLines)
            array.push(roundLines, line.new(x1, y, bar_index, y, extend = lineExt,
                 color = colRound, style = stRound, width = wRound))
        else
            l = array.get(roundLines, k)
            line.set_xy1(l, x1, y)
            line.set_xy2(l, bar_index, y)

// ------------------------------------------------------------ level table
// @function Writes one level row into the table.
// @param t    (table) The table.
// @param row  (int) Row number.
// @param name (string) Level name.
// @param y    (float) Level price.
// @param col  (color) Name colour.
// @param ref  (float) The price the distance is measured from.
// @returns (void)
f_row(table t, int row, string name, float y, color col, float ref) =>
    away = y - ref
    priceTxt = na(y) ? "n/a" : str.tostring(y, format.mintick)
    awayTxt  = na(y) ? "" : (away >= 0 ? "+" : "") + str.tostring(away, format.mintick)
    table.cell(t, 0, row, name, text_color = col, text_size = size.small, text_halign = text.align_left)
    table.cell(t, 1, row, priceTxt, text_color = chart.fg_color, text_size = size.small, text_halign = text.align_right)
    table.cell(t, 2, row, awayTxt, text_color = away >= 0 ? COL_UP : COL_DN, text_size = size.small, text_halign = text.align_right)

if isOK and showTbl and barstate.islast
    var table tbl = table.new(tblPos, 3, 7, bgcolor = color.new(chart.bg_color, 0),
         frame_color = color.new(chart.fg_color, 70), frame_width = 1,
         border_color = color.new(chart.fg_color, 85), border_width = 1)
    table.cell(tbl, 0, 0, "Level", text_color = chart.fg_color, text_size = size.small, text_halign = text.align_left)
    table.cell(tbl, 1, 0, "Price", text_color = chart.fg_color, text_size = size.small, text_halign = text.align_right)
    table.cell(tbl, 2, 0, "Away", text_color = chart.fg_color, text_size = size.small, text_halign = text.align_right,
         tooltip = "Level minus last price. Plus means the level is above price.")
    f_row(tbl, 1, "PD High",  pdh,      colPD,   close)
    f_row(tbl, 2, "PD Low",   pdl,      colPD,   close)
    f_row(tbl, 3, "PD Close", pdc,      colPD,   close)
    f_row(tbl, 4, "ON High",  onH,      colON,   close)
    f_row(tbl, 5, "ON Low",   onL,      colON,   close)
    f_row(tbl, 6, "Open",     sessOpen, colOpen, close)

// ---------------------------------------------------------------- alerts
// a cross only counts on a bar where the level itself did not move, so a
// level jumping to its new value at the day roll never fires an alert
// and the session-open alert is armed only during the cash session: its
// level is not replaced until the next open, so without that guard it would
// still be firing at 2am on a session that ended hours ago
xPDH = ta.cross(close, pdh)
xPDL = ta.cross(close, pdl)
xPDC = ta.cross(close, pdc)
xONH = ta.cross(close, onH)
xONL = ta.cross(close, onL)
xOPN = ta.cross(close, sessOpen)
aPDH = isOK and xPDH and not na(pdh[1]) and pdh == pdh[1]
aPDL = isOK and xPDL and not na(pdl[1]) and pdl == pdl[1]
aPDC = isOK and xPDC and not na(pdc[1]) and pdc == pdc[1]
aONH = isOK and xONH and not na(onH[1]) and onH == onH[1]
aONL = isOK and xONL and not na(onL[1]) and onL == onL[1]
aOPN = isOK and inRTH and xOPN and not na(sessOpen[1]) and sessOpen == sessOpen[1]
alertcondition(aPDH, "PD High touched", "{{ticker}} crossed the prior day high at {{close}}")
alertcondition(aPDL, "PD Low touched", "{{ticker}} crossed the prior day low at {{close}}")
alertcondition(aPDC, "PD Close touched", "{{ticker}} crossed the prior day close at {{close}}")
alertcondition(aONH, "ON High touched", "{{ticker}} crossed the overnight high at {{close}}")
alertcondition(aONL, "ON Low touched", "{{ticker}} crossed the overnight low at {{close}}")
alertcondition(aOPN, "Open touched", "{{ticker}} crossed the session open at {{close}}")
alertcondition(aPDH or aPDL or aPDC or aONH or aONL or aOPN, "Any key level touched", "{{ticker}} crossed a session level at {{close}}")

// ------------------------------------------------------- shading + guard
bgcolor(shadeRTH and isOK and inRTH ? color.new(chart.fg_color, 96) : na)

if not isOK and barstate.islast
    var label warn = label.new(bar_index, close, "Intraday charts only",
         style = label.style_label_left, color = color.new(chart.fg_color, 100),
         textcolor = chart.fg_color, size = size.small)
    label.set_xy(warn, bar_index, close)
````
