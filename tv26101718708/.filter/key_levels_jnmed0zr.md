# Key Levels

- url: https://www.tradingview.com/script/JNmeD0zr-Key-Levels/
- type: indicator
- pine_id: PUB;4a098c04c58745d09a667839cc654d19
- version: 1.0

## Description

Here's a publication description you can drop into TradingView:

---

**Key Levels + Battle Line**

A clean intraday levels indicator that maps the day's most-watched price reference points and identifies the central level bulls and bears are fighting over.

At the 9:30 cash open, the script locks in and plots seven key levels, each extending fully across the chart:

- **Premarket High / Low** — the range built before the open
- **Yesterday's High / Low / Close** — prior-session reference points
- **Premarket Mid** and **Yesterday Mid** — the equilibrium of each range

It then calculates a **Battle Line** — the central pivot of the whole structure. You can set this to either the *range equilibrium* (midpoint between the highest and lowest key level) or a *5-level average* (mean of premarket high/low and yesterday's high/low/close), which behaves more like a center-of-gravity pivot. The idea is simple: price tends to chop around this line while neither side has control, and a decisive break tends to resolve in that direction.

When price closes through the Battle Line, the indicator marks the break with an arrow and flips the directional bias — close above for bullish, close below for bearish. By default, breaks are confirmed on the bar **close** rather than wicks, so you're reacting to commitment rather than noise. An optional background shade colors the session by current bias, and built-in alerts fire on each break.

**Settings**
- Fully adjustable premarket and regular session times plus timezone (default 9:30 = US cash open)
- Toggle any level on or off
- Custom colors, line widths, and label offset
- Choose the Battle Line basis and switch break confirmation between close and wick
- Optional break arrows and bias background shading

**Notes**
- Designed for intraday timeframes; built and tested on 15-minute charts
- Yesterday's values are pulled from the daily timeframe
- Levels anchor at the open, so load a recent regular-session day to see them

This is an analysis tool, not financial advice. Always confirm setups with your own plan and risk management.

## Source Code

````pine
//@version=6
// =============================================================================
// Key Levels + Battle Line
// Anchored at the 9:30 cash open, draws lines that extend BOTH directions
// (back across prior bars and forward into the future):
//   Premarket High / Low, Yesterday High / Low / Close,
//   Premarket Mid, Yesterday Mid, and a central "Battle Line".
//   A bar close through the Battle Line flips bias in that direction.
// Use on an intraday timeframe (15m recommended).
// Default 9:30 = US cash open (08:30 CT).
// =============================================================================
indicator("Key Levels + Battle Line", "KeyLevels", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ----------------------------- Inputs ---------------------------------------
gS = "Sessions / Timezone"
tz      = input.string("America/New_York", "Timezone", group = gS)
pmSess  = input.session("0400-0930", "Premarket session", group = gS)
rthSess = input.session("0930-1600", "Regular session", group = gS)

gL = "Levels"
showPMH = input.bool(true, "Premarket High",  group = gL)
showPML = input.bool(true, "Premarket Low",   group = gL)
showYDH = input.bool(true, "Yesterday High",  group = gL)
showYDL = input.bool(true, "Yesterday Low",   group = gL)
showYDC = input.bool(true, "Yesterday Close", group = gL)
showPMM = input.bool(true, "Premarket Mid",   group = gL)
showYDM = input.bool(true, "Yesterday Mid",   group = gL)
showBL  = input.bool(true, "Battle Line",     group = gL)

gT = "Style"
showLbl    = input.bool(true, "Show labels", group = gT)
lblOff     = input.int(3, "Label offset (bars)", minval = 0, group = gT)
lblSizeStr = input.string("Large", "Label text size", options = ["Small", "Normal", "Large", "Huge"], group = gT)
lw         = input.int(3, "Line width", minval = 1, maxval = 10, group = gT)
cPM  = input.color(color.teal,    "Premarket", group = gT)
cYD  = input.color(color.orange,  "Yesterday", group = gT)
cYDC = input.color(color.gray,    "YD Close",  group = gT)
cMid = input.color(color.new(color.blue, 20), "Mids", group = gT)
cBL  = input.color(color.fuchsia, "Battle Line", group = gT)

gB = "Battle Line"
blMode     = input.string("Range equilibrium", "Basis", options = ["Range equilibrium", "5-level average"], group = gB)
useClose   = input.bool(true,  "Confirm breaks on close (not wicks)", group = gB)
showBreaks = input.bool(true,  "Show break arrows", group = gB)
shadeBias  = input.bool(false, "Shade background by bias", group = gB)

// Map label size string to a size constant
lblSize = lblSizeStr == "Small" ? size.small : lblSizeStr == "Normal" ? size.normal : lblSizeStr == "Huge" ? size.huge : size.large

// Line widths derived from the base width
wMain = lw
wMid  = math.max(1, lw - 1)
wBL   = lw + 2

// ------------------------- Prior-day values ----------------------------------
ydh = request.security(syminfo.tickerid, "D", high[1],  lookahead = barmerge.lookahead_off)
ydl = request.security(syminfo.tickerid, "D", low[1],   lookahead = barmerge.lookahead_off)
ydc = request.security(syminfo.tickerid, "D", close[1], lookahead = barmerge.lookahead_off)

// ------------------------- Session detection ---------------------------------
tPM     = time(timeframe.period, pmSess, tz)
inPM    = not na(tPM)
pmStart = inPM and na(tPM[1])

tR      = time(timeframe.period, rthSess, tz)
inRTH   = not na(tR)
rthOpen = inRTH and na(tR[1])

// ------------------------- Premarket high / low ------------------------------
var float pmh = na
var float pml = na
if pmStart
    pmh := high
    pml := low
else if inPM
    pmh := math.max(pmh, high)
    pml := math.min(pml, low)

// ------------------- Lock levels at the 9:30 open ----------------------------
var float L_PMH = na
var float L_PML = na
var float L_YDH = na
var float L_YDL = na
var float L_YDC = na
var float L_PMM = na
var float L_YDM = na
var float L_BL  = na

if rthOpen
    L_PMH := pmh
    L_PML := pml
    L_YDH := ydh
    L_YDL := ydl
    L_YDC := ydc
    L_PMM := (pmh + pml) / 2
    L_YDM := (ydh + ydl) / 2
    hi   = math.max(pmh, ydh, ydc)
    lo   = math.min(pml, ydl, ydc)
    avg5 = (pmh + pml + ydh + ydl + ydc) / 5
    L_BL := blMode == "Range equilibrium" ? (hi + lo) / 2 : avg5

// ----------------------------- Lines -----------------------------------------
f_line(_show, _y, _col, _w, _style) =>
    var line ln = na
    if rthOpen
        if not na(ln)
            line.delete(ln)
        ln := _show and not na(_y) ? line.new(bar_index, _y, bar_index + 1, _y, xloc = xloc.bar_index, extend = extend.both, color = _col, width = _w, style = _style) : na
    ln

f_line(showPMH, L_PMH, cPM,  wMain, line.style_solid)
f_line(showPML, L_PML, cPM,  wMain, line.style_solid)
f_line(showYDH, L_YDH, cYD,  wMain, line.style_solid)
f_line(showYDL, L_YDL, cYD,  wMain, line.style_solid)
f_line(showYDC, L_YDC, cYDC, wMain, line.style_dashed)
f_line(showPMM, L_PMM, cMid, wMid,  line.style_dotted)
f_line(showYDM, L_YDM, cMid, wMid,  line.style_dotted)
f_line(showBL,  L_BL,  cBL,  wBL,   line.style_solid)

// ----------------------------- Labels ----------------------------------------
f_lab(_cond, _y, _txt, _col) =>
    var label lb = na
    if _cond and not na(_y)
        if na(lb)
            lb := label.new(bar_index + lblOff, _y, _txt, xloc = xloc.bar_index, style = label.style_label_left, color = color.new(color.black, 100), textcolor = _col, size = lblSize)
        label.set_xy(lb, bar_index + lblOff, _y)
        label.set_text(lb, _txt)
        label.set_textcolor(lb, _col)
        label.set_size(lb, lblSize)

f_lab(showLbl and showPMH, L_PMH, "PMH "    + str.tostring(L_PMH, format.mintick), cPM)
f_lab(showLbl and showPML, L_PML, "PML "    + str.tostring(L_PML, format.mintick), cPM)
f_lab(showLbl and showYDH, L_YDH, "YDH "    + str.tostring(L_YDH, format.mintick), cYD)
f_lab(showLbl and showYDL, L_YDL, "YDL "    + str.tostring(L_YDL, format.mintick), cYD)
f_lab(showLbl and showYDC, L_YDC, "YDc "    + str.tostring(L_YDC, format.mintick), cYDC)
f_lab(showLbl and showPMM, L_PMM, "PM mid " + str.tostring(L_PMM, format.mintick), cMid)
f_lab(showLbl and showYDM, L_YDM, "YD mid " + str.tostring(L_YDM, format.mintick), cMid)
f_lab(showLbl and showBL,  L_BL,  "BATTLE " + str.tostring(L_BL,  format.mintick), cBL)

// ------------------------ Battle-line break / bias ---------------------------
brokeUp   = (useClose ? ta.crossover(close, L_BL)  : ta.crossover(high, L_BL))  and inRTH and not na(L_BL)
brokeDown = (useClose ? ta.crossunder(close, L_BL) : ta.crossunder(low, L_BL)) and inRTH and not na(L_BL)

var int bias = 0
if rthOpen
    bias := 0
if brokeUp
    bias := 1
if brokeDown
    bias := -1

plotshape(showBreaks and brokeUp,   "Break Up",   shape.triangleup,   location.belowbar, color.lime, size = size.small)
plotshape(showBreaks and brokeDown, "Break Down", shape.triangledown, location.abovebar, color.red,  size = size.small)

bgcolor(shadeBias and inRTH ? (bias == 1 ? color.new(color.green, 90) : bias == -1 ? color.new(color.red, 90) : na) : na, title = "Bias shade")

alertcondition(brokeUp,   "Battle Line broken UP",   "Close above the Battle Line - bullish bias")
alertcondition(brokeDown, "Battle Line broken DOWN", "Close below the Battle Line - bearish bias")
````
