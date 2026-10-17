# Gold Fibonacci Multiple Grid

- url: https://www.tradingview.com/script/219m7Wtj-Gold-Fibonacci-Multiple-Grid/
- type: indicator
- pine_id: PUB;d7d7301aa1c046cdb1d6c36d5c4bca87
- version: 1.0

## Description

█ OVERVIEW

Gold Fibonacci Multiple Grid draws, on the price chart, a static grid of horizontal levels at Fibonacci-number multiples of a fixed base price, 35 currency units per ounce by default. The thesis under examination is an observation from technical analysis literature that gold has tended to reverse near prices equal to Fibonacci numbers times the 35 dollar official price fixed in 1934. The script renders the grid, identifies the nearest levels above and below the current price, and flags proximity; it does not assert that the observation is valid.

█ HISTORY / BACKGROUND

The Gold Reserve Act of 1934 fixed the official US dollar price of gold at 35 dollars per troy ounce. That price held through the two-tier market of 1968 and ended with the suspension of dollar convertibility in 1971, after which gold floated. Because 35 dollars was the last administratively fixed price, some technicians, including Robert Prechter, have used it as a permanent anchor and observed that subsequent multi-year turning points in gold have clustered near Fibonacci-number multiples of it, for example 55 times 35 equals 1925, 89 times 35 equals 3115, and 144 times 35 equals 5040. The observation is two sided: certain multiples have coincided with major highs while others have coincided with major lows, so each multiple carries a role, not just a price. Whether that clustering exceeds what random level placement would produce is an open empirical question. This script is a visualization of the hypothesis, built so the reader can inspect the historical record directly.

█ HOW IT WORKS

• On the first bar, the script generates the sequence of distinct Fibonacci numbers, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, 987 and onward, up to the configured count.
• Each level equals the base price times one Fibonacci number. The level prices are constants that never move or depend on price history. To keep the price scale usable, only levels inside the visible price range expanded by the range margin are drawn as horizontal lines extended across the whole chart. The possible turning multiples are exempt from the margin when the always-draw option is on, or automatically when the chart is zoomed out so the visible window spans at least the configured number of years; zooming back in hides them again. The script recalculates when the chart is scrolled or zoomed, so the drawn set follows the current view; levels outside the band remain part of every calculation.
• On every bar, the script computes the percent distance from the closing price to each level, records the nearest level, the nearest level above and the nearest level below, and detects whether the close crossed any level relative to the prior close.
• When the distance to the nearest level is at or below the proximity threshold, that level's line and label switch to the proximity color and gain width, and an alert condition becomes true on the first bar of the approach. A second alert condition fires on any bar whose close crossed a level. Every other drawn level is colored by its assigned role: three user-editable lists designate each multiple as a high target, a low target or a possible future turning level, multiples on no list use the neutral color, possible turning levels draw dashed, and labels append the assigned role.
• An optional table shows the nearest level above and below with their multiples and percent distances, the nearest possible turning level at or above the current price, and the distance to the nearest level. The exact distance is also exposed in the data window.

█ HOW TO USE

In plain terms, the script draws a ladder of fixed price rungs. Every rung is the old 35 dollar gold price multiplied by a Fibonacci number, so the rungs get further apart as price rises, roughly 62 percent apart, matching the way gold's swings have grown with its price. The claim being examined is that gold tends to stall or turn near these rungs. Scroll back through history and judge for yourself how often turns landed near a rung and how often they ignored the grid entirely. The table always tells you the next rung overhead, the next rung underneath, and how far away the closest one is. When price gets within the threshold of a rung, that rung lights up.

The grid is designed for charts quoted in US dollars per troy ounce of gold: spot gold, gold futures, or a gold index. The levels are timeframe independent; daily and weekly charts are the practical choices because the observation concerns multi-year turning points. Treat a highlighted level as a location of interest for confluence with independent analysis, not as a prediction of reversal. A level is one price; nothing in the script measures whether price will respect it.

█ SETTINGS

• Base price, currency units per ounce. Default 35. Every level is this value times a Fibonacci number. Changing it repurposes the grid for any anchored-multiple study.
• Number of Fibonacci multiples. Default 15, which spans 35 to 34545 at the default base. Maximum 20.
• Proximity threshold, percent of level. Default 2. Price within this percent of a level counts as at the level.
• Range margin, percent. Default 20. A level beyond the visible price extremes is drawn only when it lies within this percent of them, so the price scale stays close to the price data on arithmetic charts and a level appears overhead or underneath as price approaches it. Raising the margin draws more of the grid at the cost of scale headroom. Undrawn levels still participate in every calculation and in the table.
• High target multiples, comma separated. Default 21, 55, 144. Levels at these multiples always draw in the high target color.
• Low target multiples, comma separated. Default 1, 3, 8, 34, 89. Levels at these multiples always draw in the low target color. Multiples on no list draw in the neutral color.
• Possible turning multiples, comma separated. Default 233, 377, 610. Unreached multiples treated as possible future turning levels, drawn dashed in the possible turning color.
• Always draw possible turning levels. Default off. Forces the possible turning multiples on screen regardless of zoom, which expands the price axis on an arithmetic scale; a logarithmic scale is recommended while enabled. When off, the nearest possible turning level is still reported in the table.
• Auto-show possible levels when visible span exceeds, years. Default 10. When the visible window spans at least this many years, the possible turning multiples draw even though they lie beyond the range margin, and they hide again when the chart is zoomed back in.
• Show level labels. Default on. Each label states the multiple, the base, the resulting price and the assigned role.
• Show nearest-level table. Default on.
• High target color, Low target color, Possible turning color, Unassigned level color and Proximity color. Defaults red, green, blue, gray and orange. The table rows for the nearest level above and below inherit the role color of that level; the proximity color overrides the nearest level when price is within the threshold.

█ WHAT MAKES IT ORIGINAL

Fibonacci tools on this platform are almost always relative: retracements, extensions and fans measured between two user-selected swing points, which move whenever the anchors change. This grid is absolute. Every level is a constant derived from one historically fixed price and the integer Fibonacci sequence, so the entire level set is defined before any chart data is read, identical on every symbol and timeframe, and immune to anchor-selection bias. The script adds mechanical proximity detection, crossing detection and nearest-level reporting on top of the static grid, which turns a qualitative literature observation into an inspectable, falsifiable chart object.

█ NOTES / LIMITATIONS

• The levels are meaningful only on series quoted in US dollars per troy ounce. On gold ETFs, gold miners, or gold quoted in other currencies, the default grid does not correspond to the underlying observation; the base price would need to be redefined.
• The level prices are static constants and there are no lookahead or higher-timeframe requests. Which levels are drawn depends on the visible price range, so the drawn subset changes as the chart is scrolled or zoomed, and the script recalculates on each change of the visible range. Calculations, alerts and the table always use the full level set and are unaffected by the view.
• Proximity and crossing calculations use closing prices. On the developing bar they update until the close and do not change afterward.
• Labels are positioned a few bars past the last bar and reposition as new bars print. The table renders on the last bar only.
• The script draws at most 20 lines and 20 labels, far below platform object limits.
• Level spacing follows the Fibonacci sequence, so consecutive levels are roughly 62 percent apart at scale. Between rungs the script is silent by design.
• The default role assignments restate a published observation about which multiples coincided with historical highs and lows. The script does not verify the assignments, and both lists are editable.
• The script visualizes a hypothesis. It performs no statistical test of whether reversals near these levels occur more often than chance would produce.

## Source Code

````pine
//@version=6
indicator("Gold Fibonacci Multiple Grid", shorttitle="GFMG", overlay=true)

// ── Inputs ───────────────────────────────────────────────────────────────────
string GRP_L = "Levels"
float base      = input.float(35.0, "Base price, currency units per ounce", minval=0.0001, group=GRP_L,
     tooltip="The fixed reference price from which every grid level is derived. Default is 35, the official US dollar gold price set in 1934.")
int   numLevels = input.int(15, "Number of Fibonacci multiples", minval=3, maxval=20, group=GRP_L,
     tooltip="Levels are the base price times 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, 987 and so on.")
float proxPct   = input.float(2.0, "Proximity threshold, percent of level", minval=0.05, step=0.05, group=GRP_L,
     tooltip="Price within this percent of a level counts as at the level. Highlights the level and drives the proximity alert.")
float marginPct = input.float(20.0, "Range margin, percent", minval=0.0, step=5.0, group=GRP_L,
     tooltip="A level beyond the visible price extremes is drawn only when it lies within this percent of them, which keeps the price scale close to the price data on arithmetic charts. The grid redraws as the chart is scrolled or zoomed. Undrawn levels still participate in every calculation and in the table.")
string highList = input.string("21,55,144", "High target multiples, comma separated", group=GRP_L,
     tooltip="Multiples assigned as high targets. These levels always draw in the high target color regardless of where price sits.")
string lowList  = input.string("1,3,8,34,89", "Low target multiples, comma separated", group=GRP_L,
     tooltip="Multiples assigned as low targets. These levels always draw in the low target color. Multiples on neither list use the neutral color.")
string possList = input.string("233,377,610", "Possible turning multiples, comma separated", group=GRP_L,
     tooltip="Unreached multiples treated as possible future turning levels. Drawn dashed in the possible turning color.")
bool   drawPoss = input.bool(false, "Always draw possible turning levels", group=GRP_L,
     tooltip="Forces the possible turning multiples on screen regardless of zoom. On an arithmetic scale this expands the price axis; a logarithmic scale is recommended while enabled. When off, the nearest possible turning level is still reported in the table.")
float  possYears = input.float(10.0, "Auto-show possible levels when visible span exceeds, years", minval=0.5, step=0.5, group=GRP_L,
     tooltip="When the chart is zoomed out so the visible window spans at least this many years, the possible turning multiples draw even though they lie beyond the range margin. Zooming back in hides them again.")

string GRP_V = "Display"
bool  showLabels = input.bool(true, "Show level labels", group=GRP_V)
bool  showTable  = input.bool(true, "Show nearest-level table", group=GRP_V)
color colHigh    = input.color(color.new(#f23645, 0), "High target color", group=GRP_V)
color colLow     = input.color(color.new(#089981, 0), "Low target color", group=GRP_V)
color colPoss    = input.color(color.new(#2962ff, 0), "Possible turning color", group=GRP_V)
color colNeutral = input.color(color.new(#787b86, 0), "Unassigned level color", group=GRP_V)
color colProx    = input.color(color.new(#ff9800, 0), "Proximity color", group=GRP_V)

// ── Fibonacci multiples ──────────────────────────────────────────────────────
// Distinct Fibonacci numbers: 1, 2, 3, 5, 8, ...
var array<int> mults = array.new<int>()
if barstate.isfirst
    array.push(mults, 1)
    array.push(mults, 2)
    while array.size(mults) < numLevels
        int n = array.size(mults)
        array.push(mults, array.get(mults, n - 1) + array.get(mults, n - 2))

// ── Target roles ─────────────────────────────────────────────────────────────
f_parseList(string s) =>
    array<int> out = array.new<int>()
    array<string> parts = str.split(s, ",")
    if array.size(parts) > 0
        for k = 0 to array.size(parts) - 1
            float v = str.tonumber(str.trim(array.get(parts, k)))
            if not na(v)
                array.push(out, int(v))
    out

var array<int> highM = f_parseList(highList)
var array<int> lowM  = f_parseList(lowList)
var array<int> possM = f_parseList(possList)

f_role(int m) =>
    array.includes(highM, m) ? 1 : array.includes(lowM, m) ? -1 : array.includes(possM, m) ? 2 : 0

f_roleColor(int r) =>
    r == 1 ? colHigh : r == -1 ? colLow : r == 2 ? colPoss : colNeutral

// ── Grid objects, bounded to the visible price range ─────────────────────────
var array<line>  lns      = array.new<line>()
var array<label> lbs      = array.new<label>()
var array<int>   drawnIdx = array.new<int>()
var string       drawnSig = ""

var float visHi = na
var float visLo = na
if time >= chart.left_visible_bar_time and time <= chart.right_visible_bar_time
    visHi := na(visHi) ? high : math.max(visHi, high)
    visLo := na(visLo) ? low : math.min(visLo, low)
float marginF = 1.0 + marginPct / 100.0
float hiBound = na(visHi) ? na : visHi * marginF
float loBound = na(visLo) ? na : visLo / marginF
float visYears = (chart.right_visible_bar_time - chart.left_visible_bar_time) / 31557600000.0
bool  drawPossNow = drawPoss or visYears >= possYears

// ── Proximity and crossings ──────────────────────────────────────────────────
float distNear   = na
int   idxNear    = -1
float lvAbove    = na
float lvBelow    = na
int   mAbove     = na
int   mBelow     = na
bool  crossedAny = false

for i = 0 to numLevels - 1
    float lv = base * array.get(mults, i)
    float d  = 100.0 * math.abs(close - lv) / lv
    if na(distNear) or d < distNear
        distNear := d
        idxNear  := i
    if lv >= close and (na(lvAbove) or lv < lvAbove)
        lvAbove := lv
        mAbove  := array.get(mults, i)
    if lv <= close and (na(lvBelow) or lv > lvBelow)
        lvBelow := lv
        mBelow  := array.get(mults, i)
    if not na(close[1]) and (close - lv) * (close[1] - lv) < 0
        crossedAny := true

bool inProx = not na(distNear) and distNear <= proxPct

float lvPoss = na
int   mPoss  = na
if array.size(possM) > 0
    for k = 0 to array.size(possM) - 1
        int   pm = array.get(possM, k)
        float pl = base * pm
        if pl >= close and (na(lvPoss) or pl < lvPoss)
            lvPoss := pl
            mPoss  := pm

plot(distNear, "Distance to nearest multiple, percent", display=display.data_window)

// ── Last-bar visuals ─────────────────────────────────────────────────────────
if barstate.islast
    string sig = ""
    for i = 0 to numLevels - 1
        int   mI = array.get(mults, i)
        float lv = base * mI
        sig += (lv >= loBound and lv <= hiBound) or (drawPossNow and f_role(mI) == 2) ? "1" : "0"
    if sig != drawnSig
        while array.size(lns) > 0
            line.delete(array.pop(lns))
        while array.size(lbs) > 0
            label oldLb = array.pop(lbs)
            if not na(oldLb)
                label.delete(oldLb)
        array.clear(drawnIdx)
        for i = 0 to numLevels - 1
            int   m  = array.get(mults, i)
            float lv = base * m
            int   rM = f_role(m)
            if (lv >= loBound and lv <= hiBound) or (drawPossNow and rM == 2)
                array.push(drawnIdx, i)
                color  cM  = f_roleColor(rM)
                string tag = rM == 1 ? "  high" : rM == -1 ? "  low" : rM == 2 ? "  possible" : ""
                array.push(lns, line.new(bar_index, lv, bar_index + 1, lv, extend=extend.both, color=cM, width=1, style=rM == 2 ? line.style_dashed : line.style_solid))
                label lb = na
                if showLabels
                    lb := label.new(bar_index + 10, lv, str.tostring(m) + " x " + str.tostring(base, "#.##") + " = " + str.tostring(lv, "#.##") + tag, style=label.style_label_left, textcolor=cM, color=color.new(color.black, 100), size=size.small)
                array.push(lbs, lb)
        drawnSig := sig
    if array.size(lns) > 0
        for j = 0 to array.size(lns) - 1
            color cLv = f_roleColor(f_role(array.get(mults, array.get(drawnIdx, j))))
            bool  hot = inProx and array.get(drawnIdx, j) == idxNear
            line.set_color(array.get(lns, j), hot ? colProx : cLv)
            line.set_width(array.get(lns, j), hot ? 2 : 1)
            label lb = array.get(lbs, j)
            if not na(lb)
                label.set_x(lb, bar_index + 10)
                label.set_textcolor(lb, hot ? colProx : cLv)

var table tb = na
if showTable and barstate.islast
    if na(tb)
        tb := table.new(position.top_right, 2, 4, border_width=1, border_color=color.new(color.gray, 80))
    table.cell(tb, 0, 0, "Above",   text_size=size.small)
    table.cell(tb, 1, 0, na(lvAbove) ? "-" : str.tostring(mAbove) + " x = " + str.tostring(lvAbove, "#.##") + "  +" + str.tostring(100.0 * (lvAbove - close) / close, "#.#") + "%", text_size=size.small, text_color=f_roleColor(f_role(mAbove)))
    table.cell(tb, 0, 1, "Below",   text_size=size.small)
    table.cell(tb, 1, 1, na(lvBelow) ? "-" : str.tostring(mBelow) + " x = " + str.tostring(lvBelow, "#.##") + "  -" + str.tostring(100.0 * (close - lvBelow) / close, "#.#") + "%", text_size=size.small, text_color=f_roleColor(f_role(mBelow)))
    table.cell(tb, 0, 2, "Possible", text_size=size.small)
    table.cell(tb, 1, 2, na(lvPoss) ? "-" : str.tostring(mPoss) + " x = " + str.tostring(lvPoss, "#.##") + "  +" + str.tostring(100.0 * (lvPoss - close) / close, "#.#") + "%", text_size=size.small, text_color=colPoss)
    table.cell(tb, 0, 3, "Nearest", text_size=size.small)
    table.cell(tb, 1, 3, na(distNear) ? "-" : str.tostring(distNear, "#.##") + "% away", text_size=size.small, text_color=inProx ? colProx : color.new(color.gray, 0))

// ── Alerts ───────────────────────────────────────────────────────────────────
alertcondition(inProx and not inProx[1], "Fibonacci multiple proximity", "Gold Fibonacci Multiple Grid: price moved within the proximity threshold of a Fibonacci multiple of the base price")
alertcondition(crossedAny, "Fibonacci multiple crossed", "Gold Fibonacci Multiple Grid: price crossed a Fibonacci multiple of the base price on this bar")
````
