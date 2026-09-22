<!-- tradingview-pine-id: PUB;3c21e8b5d23e4c0bb142b081e9f34640 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# JoulTrades - ICT PDH/PDL Eighths

Source: https://www.tradingview.com/script/xN3yv39C-JoulTrades-ICT-PDH-PDL-Eighths/

## Description

OVERVIEW
This indicator marks the previous day's high (PDH) and low (PDL) and grades the range between them in eighths, the way ICT (Inner Circle Trader) teaches traders to grade a range: quadrants, octants and a black equilibrium line. It is a level-marking tool for study and chart preparation. It does not generate signals, entries or bias.

WHAT IT DRAWS
- PDH and PDL, extended to the right with labels and price-axis tags.
- Seven graded levels between them: 0.125, 0.25, 0.375, 0.5, 0.625, 0.75 and 0.875.
- The 0.5 level (equilibrium, also called consequent encroachment or CE) in black. Every other level uses one grey, so the midpoint stands out.
- Optional: the previous week's high and low as dashed lines.

HOW IT WORKS
- The range is always measured from the low to the high, whatever the trend. The levels do not move when the market turns.
- Each level is PDL + fraction x (PDH - PDL).
- No separate 0 and 1 lines are drawn, because PDH and PDL already sit there. A range's own edge is not drawn twice.
- The previous day is final once it has closed, so its levels do not repaint. The lines are redrawn on the latest bar only so they stay attached to the current price area and do not pile up on the chart.
- It works on every intraday timeframe and on the daily. Nothing is drawn on weekly or monthly charts.

WHAT COUNTS AS "PREVIOUS DAY"
Traders use two definitions, and they can give different prices:
- Full day (default): the daily candle. On CME futures that is 18:00 to 17:00 New York time, including the overnight session.
- RTH session only: the regular trading hours set in the settings (default 09:30-16:00 New York). The labels change to "RTH PDH" and "RTH PDL" so a screenshot always shows which one is in use.
On charts above 30 minutes, the RTH range is read from 30-minute data so the session edges are exact.

NUMBERING
- ICT ladder (default): 0 is the low and 1 is the high, so 0.875 is the highest octant, next to PDH.
- TradingView fib: matches the built-in fib retracement tool drawn from low to high, which puts 0 at the high.
The prices are identical in both modes. Only the numbers attached to them change. Pick the one that matches the way you read levels.

LABELS
Labels can show the number, the ICT name, or both:
0.875 highest octant, 0.75 upper quadrant, 0.625 second octant, 0.5 CE, 0.375 lower octant, 0.25 lower quadrant, 0.125 lowest octant.
Hover over any label for a short explanation of that level. This is meant to help newer traders learn the vocabulary while they look at the chart.

HOW TO READ IT
- Above 0.5, price is in the premium half of yesterday's range. Below 0.5, it is in the discount half.
- ICT treats quadrants and octants as reference levels that price can be drawn to, not as decoration.
- PDH and PDL are where resting liquidity is commonly assumed to sit until price trades through them.
- A level carries more information when it lines up with a level from a different range, for example an opening gap or a key open landing on the same price.
Use these levels as a map for your own analysis. They are not trade signals on their own.

SETTINGS
- Range: previous day definition, RTH session and timezone, eighths on or off.
- Labels: numbering, label text, price in labels, label size, label distance from price.
- Style: level colour, equilibrium colour, line widths. The defaults are grey #636363 levels, a black equilibrium, and thicker PDH/PDL lines.
- Previous week: high and low on or off, and their colour.

LIMITATIONS
- The default RTH session fits US index futures and US stocks. For other markets, set the session and timezone to match.
- Full day follows the chart's own daily session. On symbols that trade around the clock, "previous day" is whatever the exchange defines as the daily candle.
- RTH mode on the daily chart depends on the 30-minute history TradingView loads for your plan.
- These are reference levels. The indicator makes no claim about how often price reacts at any of them. Test them on your own market and timeframe before relying on them.

This script is open source and published for educational purposes. It is not financial advice.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// (c) jolianos
//@version=6
// =============================================================================
//  ICT PDH / PDL EIGHTHS
// -----------------------------------------------------------------------------
//  Previous day high and low, with the range between them graded in eighths
//  the way ICT grades a range: quadrants, octants and a black equilibrium.
//
//  Marking only.  No signals, no entries, no bias.
//
//  Conventions:
//      - The range is always measured from the low to the high, whatever the
//        trend, so the levels never move when the market turns.
//      - No 0 / 1 lines: PDH and PDL already sit there.  A range's own edge
//        is never drawn twice.
//      - Equilibrium (0.5) in black for contrast, every other level one grey.
//      - Labels on the right, so they stay readable on a 1m chart.
//
//  Numbering: "ICT ladder" puts 0 at the low, so 0.875 is the highest octant
//  next to PDH.  "TradingView fib" matches the built-in fib tool drawn low to
//  high, which puts 0 at the high.  The prices are identical either way.
//
//  STYLE NOTE: single-line calls, no multi-line ternaries.  Do not re-wrap.
// =============================================================================

indicator("JoulTrades - ICT PDH/PDL Eighths", "PD Eighths", overlay = true, max_lines_count = 50, max_labels_count = 50)

// ============================== INPUTS =======================================
G_R = "1 - Range"
G_L = "2 - Labels"
G_S = "3 - Style"
G_W = "4 - Previous week"

MODE_FULL = "Full day (daily candle)"
MODE_RTH  = "RTH session only"
NUM_ICT   = "ICT ladder (0 = low)"
NUM_TV    = "TradingView fib (0 = high)"
TXT_NUM   = "Number"
TXT_NAME  = "ICT name"
TXT_BOTH  = "Number + ICT name"

mode      = input.string(MODE_FULL, "Previous day is", options = [MODE_FULL, MODE_RTH], group = G_R, tooltip = "Full day = the daily candle, e.g. 18:00-17:00 ET on CME futures. RTH = the regular session below only. They can be different prices; the PDH/PDL label says which one is in use.")
rthSess   = input.session("0930-1600", "RTH session", group = G_R)
tz        = input.string("America/New_York", "RTH timezone", group = G_R)
showFib   = input.bool(true, "Grade the range in eighths", group = G_R)

numbering = input.string(NUM_ICT, "Numbering", options = [NUM_ICT, NUM_TV], group = G_L)
txtMode   = input.string(TXT_NUM, "Label text", options = [TXT_NUM, TXT_NAME, TXT_BOTH], group = G_L)
showPrice = input.bool(true, "Price in the labels", group = G_L)
lblSize   = input.string(size.small, "Label size", options = [size.tiny, size.small, size.normal], group = G_L)
lblOff    = input.int(10, "Labels sit this many bars right of price", minval = 1, maxval = 200, group = G_L)

cLvl     = input.color(#636363, "Levels", group = G_S, inline = "c")
cEq      = input.color(#000000, "Equilibrium", group = G_S, inline = "c")
wPd      = input.int(2, "PDH / PDL width", minval = 1, maxval = 4, group = G_S)
wFib     = input.int(1, "Eighths width", minval = 1, maxval = 4, group = G_S)
wEq      = input.int(1, "Equilibrium width", minval = 1, maxval = 4, group = G_S)

wkOn     = input.bool(false, "Previous week high / low", group = G_W)
cWk      = input.color(#636363, "Colour", group = G_W)

// ============================== FULL DAY =====================================
// Tracked bar by bar, so it is exact on every intraday timeframe and on the
// daily itself (where every bar is a new day and this reduces to high[1] / low[1]).
newDay = timeframe.change("D")

var float dCurH = na
var float dCurL = na
var int   dCurT = na
var float dPrvH = na
var float dPrvL = na
var int   dPrvT = na

if newDay
    dPrvH := dCurH
    dPrvL := dCurL
    dPrvT := dCurT
    dCurH := high
    dCurL := low
    dCurT := time
else
    dCurH := math.max(nz(dCurH, high), high)
    dCurL := math.min(nz(dCurL, low), low)

// ============================== RTH ==========================================
// Returns the last COMPLETED RTH session.  Rolls over at the session close, so
// the evening already references the session that just ended.
f_rth() =>
    inS = not na(time(timeframe.period, rthSess, tz))
    var float cH = na
    var float cL = na
    var int   cT = na
    var float pH = na
    var float pL = na
    var int   pT = na
    if inS and not inS[1]
        cH := high
        cL := low
        cT := time
    else if inS
        cH := math.max(cH, high)
        cL := math.min(cL, low)
    if not inS and inS[1]
        pH := cH
        pL := cL
        pT := cT
    [pH, pL, pT]

// At 30m and below the chart's own bars align with the session open and close.
// Above that (1H, 4H, D) they may not, so the session is read off 30m bars.
[rNatH, rNatL, rNatT] = f_rth()
[rReqH, rReqL, rReqT] = request.security(syminfo.tickerid, "30", f_rth())
useNative = timeframe.isintraday and timeframe.in_seconds() <= 1800

// ============================== WEEK =========================================
newWeek = timeframe.change("W")

var float wCurH = na
var float wCurL = na
var int   wCurT = na
var float wPrvH = na
var float wPrvL = na
var int   wPrvT = na

if newWeek
    wPrvH := wCurH
    wPrvL := wCurL
    wPrvT := wCurT
    wCurH := high
    wCurL := low
    wCurT := time
else
    wCurH := math.max(nz(wCurH, high), high)
    wCurL := math.min(nz(wCurL, low), low)

// ============================== SELECT =======================================
okTf = timeframe.isintraday or timeframe.isdaily

float pdh = dPrvH
float pdl = dPrvL
int   pdt = dPrvT
string tagH = "PDH"
string tagL = "PDL"
if mode == MODE_RTH
    tagH := "RTH PDH"
    tagL := "RTH PDL"
    if useNative
        pdh := rNatH
        pdl := rNatL
        pdt := rNatT
    else
        pdh := rReqH
        pdl := rReqL
        pdt := rReqT

// Price-axis tags, so the axis highlights the level even when the label is
// off-screen.  No line is plotted; the drawings below do that.
plot(okTf ? pdh : na, "PDH", cLvl, display = display.price_scale)
plot(okTf ? pdl : na, "PDL", cLvl, display = display.price_scale)
plot(okTf and wkOn ? wPrvH : na, "PWH", cWk, display = display.price_scale)
plot(okTf and wkOn ? wPrvL : na, "PWL", cWk, display = display.price_scale)

// ============================== TEXT =========================================
TIP_OCT = " Octants sit halfway between an extreme and a quadrant; ICT uses them as targets."
TIP_QUA = " Quadrants split the range into quarters."
TIP_EQ  = "Equilibrium / consequent encroachment (CE): the midpoint of the previous day's range. Above it is premium, below it is discount."
TIP_PDH = "Previous day high: resting buy-side liquidity until price trades through it."
TIP_PDL = "Previous day low: resting sell-side liquidity until price trades through it."
TIP_PWH = "Previous week high."
TIP_PWL = "Previous week low."

// f is always the fraction measured up from the low.  Names follow position,
// not numbering, so "highest octant" is next to the high in both modes.
f_name(float f) =>
    string n = ""
    if f == 0.875
        n := "highest octant"
    else if f == 0.75
        n := "upper quadrant"
    else if f == 0.625
        n := "second octant"
    else if f == 0.5
        n := "CE"
    else if f == 0.375
        n := "lower octant"
    else if f == 0.25
        n := "lower quadrant"
    else if f == 0.125
        n := "lowest octant"
    n

f_tip(float f) =>
    string t = ""
    if f == 0.5
        t := TIP_EQ
    else
        t := f_name(f) + ": " + str.tostring(f * 100) + "% of the way from the low to the high."
        if f == 0.25 or f == 0.75
            t := t + TIP_QUA
        else
            t := t + TIP_OCT
    t

f_fmt() =>
    array<string> parts = str.split(str.tostring(syminfo.mintick), ".")
    int dec = array.size(parts) > 1 ? str.length(array.get(parts, 1)) : 0
    dec > 0 ? "#,##0." + str.repeat("0", dec) : "#,##0"

var string PFMT = f_fmt()

f_text(float f, float y) =>
    float shown = numbering == NUM_ICT ? f : 1.0 - f
    string num = str.tostring(shown)
    string t = num
    if txtMode == TXT_NAME
        t := f_name(f)
    else if txtMode == TXT_BOTH
        t := num + " " + f_name(f)
    if showPrice
        t := t + " (" + str.tostring(y, PFMT) + ")"
    t

// ============================== DRAWING ======================================
var array<line>  lns = array.new<line>()
var array<label> lbs = array.new<label>()

f_level(int x1, int x2, float y, color c, int w, string st, string txt, string tip) =>
    array.push(lns, line.new(x1, y, x2, y, xloc.bar_time, extend.none, c, st, w))
    array.push(lbs, label.new(x2, y, txt, xloc.bar_time, yloc.price, color.new(c, 100), label.style_label_left, c, lblSize, tooltip = tip))

// Visual only: everything is deleted and redrawn on the last bar, so drawings
// never accumulate.  The level values above are computed on every bar.
if barstate.islast
    for l in lns
        line.delete(l)
    for b in lbs
        label.delete(b)
    array.clear(lns)
    array.clear(lbs)

    xR = time + lblOff * timeframe.in_seconds() * 1000

    if okTf and not na(pdh) and not na(pdl) and not na(pdt)
        f_level(pdt, xR, pdh, cLvl, wPd, line.style_solid, tagH, TIP_PDH)
        f_level(pdt, xR, pdl, cLvl, wPd, line.style_solid, tagL, TIP_PDL)
        if showFib
            for f in array.from(0.875, 0.75, 0.625, 0.5, 0.375, 0.25, 0.125)
                y = pdl + f * (pdh - pdl)
                isEq = f == 0.5
                c = isEq ? cEq : cLvl
                w = isEq ? wEq : wFib
                f_level(pdt, xR, y, c, w, line.style_solid, f_text(f, y), f_tip(f))

    if okTf and wkOn and not na(wPrvH) and not na(wPrvT)
        f_level(wPrvT, xR, wPrvH, cWk, wPd, line.style_dashed, "PWH", TIP_PWH)
        f_level(wPrvT, xR, wPrvL, cWk, wPd, line.style_dashed, "PWL", TIP_PWL)
````
