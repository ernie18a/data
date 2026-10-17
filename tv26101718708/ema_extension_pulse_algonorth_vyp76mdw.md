# EMA Extension Pulse [AlgoNorth]

- url: https://www.tradingview.com/script/VYp76mdw-EMA-Extension-Pulse-AlgoNorth/
- type: indicator
- pine_id: PUB;1602452fcfba4663bfe389cf860ee1fb
- version: 1.0

## Description

EMA Extension Pulse

Every trader faces the same moment: price is far from its average and you have to decide what that means. Chase it, fade it, or leave it alone. Most tools answer with one number, "how far", and treat every stretch the same. But a move that walked out in a straight line and a move that lurched out through chop are not the same event. Does that difference matter on the chart you trade? That is what this script measures.

EMA Extension Pulse shows both at once. Column height is how far price has stretched from its 20 EMA in ATR; column brightness is how cleanly it got there. When a stretch reaches the gold guide in a straight line, a gold dot marks it on the pane and on the price chart, once per move. Then a live panel keeps score: how often clean and messy stretches kept going on the exact chart you are looking at. No borrowed rules of thumb, no guessing, just your own symbol and timeframe showing you how its stretches have played out.

🔶 USAGE

🔸 Watch the columns. Height is the stretch from the EMA in ATR: above zero is above the mean, below zero is below it. Brightness is efficiency, so a bright column is a move travelling in a straight line and a faint one is a move grinding through chop.

🔸 Follow the white line. It is a smoothed read of the stretch, drawn through the columns, so the rhythm of each push and pullback is easy to see.

🔸 Check the gold guides. The dashed lines sit at ±2 ATR, labelled on the scale. A move whose column crosses one is a stretch.

🔸 Look for the gold dots. A dot marks a stretch that reached the guide cleanly, once per move, on both the pane and the price chart. A dashed stem joins each price dot to its candle.

🔸 Read the panel. It shows the stretch and efficiency right now, then how often clean and messy stretches kept going 10 bars later on this chart, with the median move, average move and count for each.

🔸 Alerts: clean stretch up, clean stretch down.

🔶 DETAILS

🔸 Stretch. (close − EMA 20) ÷ ATR 14. Measuring in ATR makes the columns read the same on any symbol or timeframe.

🔸 Efficiency. Net price travel ÷ total price travel over the last 14 bars, the efficiency ratio introduced by Perry Kaufman. 1.0 is a straight line; values near 0 are chop.

🔸 One stretch per move. A stretch is recorded on the first bar that closes beyond the ±2 ATR guide. The next one can only start once stretch has come back inside ±1 ATR, so one long push, or a small dip near the guide, is counted once.

🔸 Grading. A stretch is graded clean when efficiency reaches 0.50 on the crossing bar or either of the next two bars while price is still beyond the guide. The gold dot goes on the first bar that qualifies. Otherwise the stretch is graded messy and carries no dot.

🔸 Measurement. Clean and messy stretches are both measured from the bar that first reached the guide and checked 10 bars later: did price keep going in the stretch direction, and by how many ATR. Both groups share the same starting point, so the two panel rows compare like with like.

🔸 Colours. The palette follows your chart theme automatically, with a dark set and a light set.

🔶 SETTINGS

🔸 Extension: Mean length (EMA), ATR length, Efficiency lookback, Messiest column transparency, Line smoothing. The first three set the measurements. Messiest column transparency is how faint a column tip gets at zero efficiency; tips at or above the clean threshold are always fully bright.

🔸 Clean stretches: Stretch guide (ATR), Reset below (ATR), Clean when efficiency is at least, Clean check window (bars), Measure after (bars). The guide is the distance a move must reach; Reset below is how far back toward the mean it must return before a new move can be counted; the threshold and window set the grading, and the threshold is also the efficiency at which column tips reach full brightness; Measure after is how many bars later each stretch is checked.

🔸 Marks: Mark clean stretches, Dot gap beyond the column tip, Mark clean stretches on price, Price dot distance (× ATR). Switch each dot on or off and set how far it sits from the column tip or the candle.

🔸 Panel: Show panel, Panel position. Four positions, for when more than one copy is loaded.

🔸 Colours: above, below and clean-stretch marks, one set for dark charts and one for light. The script picks the set from your chart theme.

🔶 NOTES

🔸 Every dot, alert and panel count is set when its bar closes and never changes afterwards. A dot lands on the crossing bar, or up to two bars later when the clean check window is in use.

🔸 The panel is learned from the history loaded on your chart, so each symbol and timeframe builds its own reading, and the more history you load, the steadier it gets.

🔸 The panel's date row is shown in exchange time, named in the row, which can differ from your chart's display timezone.

🔸 On very long histories the most recent 500 price-chart stems are kept; every dot stays on the chart.

🔸 Built for standard candle and bar charts. Renko, Kagi and Point & Figure charts can rebuild past bars, which changes the stretch history behind the counts. 

🔶 SUMMARY

Price is far from its average, and you have to decide what that means. EMA Extension Pulse shows you two things at once: how far price has stretched from its 20 EMA, and how cleanly it got there. Clean stretches are marked with a gold dot, once per move, and a live panel keeps score of what clean and messy stretches did next on the chart you are looking at. Not a rule of thumb: your own symbol and timeframe, showing you how its stretches have played out.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © AlgoNorth
//@version=6
indicator("EMA Extension Pulse [AlgoNorth]", overlay = false, precision = 2, max_lines_count = 500)

// ─── Inputs ──────────────────────────────────────────────────────────────
const string G_COL = "Colours"
const string G_AUR = "Extension"
const string G_EVT = "Clean stretches"
const string G_TBL = "Panel"
const int    SEG   = 5

color  upDark    = input.color(#2ad4e8, "Above the mean (dark chart)", group = G_COL, tooltip = "Used when the chart theme is dark. The script picks the set automatically from your chart theme.")
color  dnDark    = input.color(#f2456b, "Below the mean (dark chart)", group = G_COL, tooltip = "Used when the chart theme is dark. The script picks the set automatically from your chart theme.")
color  goldDark  = input.color(#ffd23f, "Clean-stretch marks (dark chart)", group = G_COL, tooltip = "Used when the chart theme is dark. The script picks the set automatically from your chart theme.")
color  upLight   = input.color(#1a818e, "Above the mean (light chart)", group = G_COL, tooltip = "Used when the chart theme is light. The script picks the set automatically from your chart theme.")
color  dnLight   = input.color(#d53d5e, "Below the mean (light chart)", group = G_COL, tooltip = "Used when the chart theme is light. The script picks the set automatically from your chart theme.")
color  goldLight = input.color(#7d6720, "Clean-stretch marks (light chart)", group = G_COL, tooltip = "Used when the chart theme is light. The script picks the set automatically from your chart theme.")

int    meanLen   = input.int(20, "Mean length (EMA)", minval = 2, maxval = 500, group = G_AUR, tooltip = "The mean that stretch is measured from. Column height is how far the close sits from this EMA, in ATR.")
int    atrLen    = input.int(14, "ATR length", minval = 2, maxval = 200, group = G_AUR, tooltip = "ATR used to express stretch in volatility units, so the columns read the same on any symbol.")
int    effLen    = input.int(14, "Efficiency lookback", minval = 2, maxval = 200, group = G_AUR, tooltip = "Efficiency is net travel divided by total travel over this many bars. 1 is a straight line, near 0 is chop. It sets how brightly each column tip glows: tips at or above the clean threshold are fully bright, and tips fade as efficiency falls towards 0. Every column fades from its tip down to the zero line.")
int    dimTr     = input.int(75, "Messiest column transparency", minval = 0, maxval = 95, group = G_AUR, tooltip = "How faint a column tip gets when efficiency is 0. Tips at or above the clean threshold are always fully bright; everything between fades in proportion. Lower makes the messier columns brighter.")
int    lineLen   = input.int(5, "Line smoothing", minval = 1, maxval = 50, group = G_AUR, tooltip = "Smoothing of the line drawn through the columns. The line takes the chart's foreground colour, so it is light on a dark chart and dark on a light one.")

float  guide     = input.float(2.0, "Stretch guide (ATR)", minval = 0.5, maxval = 10.0, step = 0.25, group = G_EVT, tooltip = "Dashed guide lines sit at plus and minus this stretch. Each move that reaches it is filed once as a stretch, subject to the reset below.")
float  resetLvl  = input.float(1.0, "Reset below (ATR)", minval = 0.25, maxval = 10.0, step = 0.25, group = G_EVT, tooltip = "After a stretch reaches the guide, the next one can only start once stretch has come back inside plus or minus this level. Keeps one long push, and small dips near the guide, from being filed more than once. Capped at the guide.")
float  cleanThr  = input.float(0.5, "Clean when efficiency is at least", minval = 0.1, maxval = 0.95, step = 0.05, group = G_EVT, tooltip = "A stretch is filed as clean when efficiency reaches this level inside the clean check window, and as messy otherwise. It also sets the column brightness scale: tips reach full brightness at this efficiency.")
int    gradeBars = input.int(3, "Clean check window (bars)", minval = 1, maxval = 5, group = G_EVT, tooltip = "How many bars, starting with the bar that reaches the guide, a stretch has to show a clean efficiency while still beyond the guide. The gold dot goes on the first bar that qualifies. 1 grades on the reaching bar only.")
int    horizon   = input.int(10, "Measure after (bars)", minval = 5, maxval = 200, group = G_EVT, tooltip = "Each filed stretch is checked this many bars after it first reached the guide: did price keep going in the stretch direction. Clean and messy stretches are measured from the same point.")
bool   showTips  = input.bool(true, "Mark clean stretches", group = G_EVT, tooltip = "Places a gold dot just beyond the tip of the column where a stretch is graded clean.")
float  tipGap    = input.float(0.3, "Dot gap beyond the column tip", minval = 0.0, maxval = 2.0, step = 0.05, group = G_EVT, tooltip = "Space between the column tip and its gold dot, in the pane's ATR units.")
bool   showPx    = input.bool(true, "Mark clean stretches on price", group = G_EVT, tooltip = "Places a matching gold dot on the price chart, above the candle for an upward stretch and below it for a downward one, with a dashed stem running from the dot back towards the candle and stopping just short of it.")
float  pxDist    = input.float(1.0, "Price dot distance (× ATR)", minval = 0.2, maxval = 5.0, step = 0.1, group = G_EVT, tooltip = "How far the price-chart dot sits beyond the candle's high (or low).")

bool   showTbl   = input.bool(true, "Show panel", group = G_TBL, tooltip = "Live panel on the price chart with the current reading, the measured stretches and the window of bars they cover.")
string tblPos    = input.string("Top Right", "Panel position", options = ["Top Right", "Middle Right", "Bottom Right", "Bottom Left"], group = G_TBL, tooltip = "Where the panel sits on the price chart. Pick different positions when more than one copy is loaded.")

// ─── Theme ───────────────────────────────────────────────────────────────
float fgLum   = 0.2126 * color.r(chart.fg_color) + 0.7152 * color.g(chart.fg_color) + 0.0722 * color.b(chart.fg_color)
bool  isLight = fgLum < 128
color upCol   = isLight ? upLight   : upDark
color dnCol   = isLight ? dnLight   : dnDark
color GOLD    = isLight ? goldLight : goldDark

// ─── Measurements ────────────────────────────────────────────────────────
float atrV    = ta.atr(atrLen)
float meanV   = ta.ema(close, meanLen)
float stretch = atrV > 0 ? (close - meanV) / atrV : 0.0
float pathLen = math.sum(math.abs(close - close[1]), effLen)
float eff     = pathLen > 0 ? math.abs(close - close[effLen]) / pathLen : 0.0
float lineV   = ta.ema(stretch, lineLen)

// ─── Extension columns ───────────────────────────────────────────────────
color baseCol = stretch >= 0 ? upCol : dnCol
float tipTr   = dimTr * (1 - math.min(eff / cleanThr, 1.0))
color noLine  = color.new(color.white, 100)

f_tr(int s) =>
    tipTr + (92 - tipTr) * math.pow((SEG - s) / float(SEG), 1.3)

float a0 = 0.0
float a1 = stretch * 1 / 6
float a2 = stretch * 2 / 6
float a3 = stretch * 3 / 6
float a4 = stretch * 4 / 6
float a5 = stretch * 5 / 6
float a6 = stretch

hline(0, "Zero", color = color.new(chart.fg_color, 75), linestyle = hline.style_solid)
plot(guide, "Upper guide", color = color.new(GOLD, 25), linestyle = plot.linestyle_dashed, display = display.pane + display.price_scale)
plot(-guide, "Lower guide", color = color.new(GOLD, 25), linestyle = plot.linestyle_dashed, display = display.pane + display.price_scale)

plotcandle(a0, math.max(a0, a1), math.min(a0, a1), a1, "Column 1", color = color.new(baseCol, f_tr(0)), wickcolor = noLine, bordercolor = noLine, display = display.pane)
plotcandle(a1, math.max(a1, a2), math.min(a1, a2), a2, "Column 2", color = color.new(baseCol, f_tr(1)), wickcolor = noLine, bordercolor = noLine, display = display.pane)
plotcandle(a2, math.max(a2, a3), math.min(a2, a3), a3, "Column 3", color = color.new(baseCol, f_tr(2)), wickcolor = noLine, bordercolor = noLine, display = display.pane)
plotcandle(a3, math.max(a3, a4), math.min(a3, a4), a4, "Column 4", color = color.new(baseCol, f_tr(3)), wickcolor = noLine, bordercolor = noLine, display = display.pane)
plotcandle(a4, math.max(a4, a5), math.min(a4, a5), a5, "Column 5", color = color.new(baseCol, f_tr(4)), wickcolor = noLine, bordercolor = noLine, display = display.pane)
plotcandle(a5, math.max(a5, a6), math.min(a5, a6), a6, "Column tip", color = color.new(baseCol, f_tr(5)), wickcolor = noLine, bordercolor = noLine, display = display.pane)

plot(lineV, "Line glow", color = color.new(chart.fg_color, 70), linewidth = 7, display = display.pane)
plot(lineV, "Line", color = chart.fg_color, linewidth = 3, display = display.pane)

// ─── Clean and messy stretches ───────────────────────────────────────────
bool  beyond  = math.abs(stretch) >= guide
bool  isClean = eff >= cleanThr
int   curDir  = stretch > 0 ? 1 : -1
float rearm   = math.min(resetLvl, guide)

var bool  armed   = true
var int   winLeft = 0      // bars left to grade the open stretch; 0 = none open
var int   evDir   = 0
var int   evIdx   = 0
var float evPx    = 0.0
var float evAtr   = 0.0
var int   tFirst  = time

var array<int>   pIdx   = array.new_int()
var array<float> pPx    = array.new_float()
var array<float> pAtr   = array.new_float()
var array<int>   pDir   = array.new_int()
var array<int>   pKind  = array.new_int()
var array<int>   nCont  = array.from(0, 0)
var array<float> vClean = array.new_float()
var array<float> vMessy = array.new_float()

f_file(bool clean) =>
    array.push(pIdx, evIdx)
    array.push(pPx, evPx)
    array.push(pAtr, evAtr)
    array.push(pDir, evDir)
    array.push(pKind, clean ? 0 : 1)

if barstate.isconfirmed
    int k = array.size(pIdx) - 1
    while k >= 0
        if bar_index - array.get(pIdx, k) >= horizon
            int   kind = array.get(pKind, k)
            float move = (close - array.get(pPx, k)) * array.get(pDir, k) / array.get(pAtr, k)
            array.push(kind == 0 ? vClean : vMessy, move)
            if move > 0
                array.set(nCont, kind, array.get(nCont, kind) + 1)
            array.remove(pIdx, k)
            array.remove(pPx, k)
            array.remove(pAtr, k)
            array.remove(pDir, k)
            array.remove(pKind, k)
        k -= 1

bool cleanEv = false
bool settled = false
if barstate.isconfirmed
    if not armed and math.abs(stretch) < rearm
        armed := true
    if winLeft > 0
        bool still = stretch * evDir >= guide
        cleanEv := still and isClean
        winLeft := (cleanEv or not still) ? 0 : winLeft - 1
        settled := winLeft == 0
    else if armed and beyond
        armed   := false
        evDir   := curDir
        evIdx   := bar_index
        evPx    := close
        evAtr   := atrV
        cleanEv := isClean
        winLeft := cleanEv ? 0 : gradeBars - 1
        settled := winLeft == 0
    if settled
        f_file(cleanEv)

bool cleanUp = cleanEv and evDir > 0
bool cleanDn = cleanEv and evDir < 0

// Pane dot: just beyond the column tip
plotshape(showTips and cleanEv ? stretch + (cleanUp ? tipGap : -tipGap) : na, "Clean stretch", style = shape.circle, location = location.absolute, color = GOLD, size = size.small, display = display.pane)

// Price dot: beyond the candle, joined by a dashed stem
float pxDot = cleanUp ? high + pxDist * atrV : low - pxDist * atrV
plotshape(showPx and cleanEv ? pxDot : na, "Clean stretch on price", style = shape.circle, location = location.absolute, color = GOLD, size = size.small, display = display.pane, force_overlay = true)
if showPx and cleanEv
    float stemStart = cleanUp ? high + 0.1 * atrV : low - 0.1 * atrV
    line.new(bar_index, stemStart, bar_index, pxDot, color = color.new(GOLD, 25), style = line.style_dashed, width = 1, force_overlay = true)

// ─── Panel (on the price chart) ──────────────────────────────────────────
f_pos(string p) =>
    switch p
        "Middle Right" => position.middle_right
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.top_right

f_sgn(float x) =>
    float v = math.round(x * 100) / 100
    (v >= 0 ? "+" : "−") + str.tostring(math.abs(v), "0.00")

f_rate(int kind) =>
    array<float> mv = kind == 0 ? vClean : vMessy
    int n = array.size(mv)
    n > 0 ? str.tostring(math.round(100.0 * array.get(nCont, kind) / n)) + "% · med " + f_sgn(array.median(mv)) + " · avg " + f_sgn(array.avg(mv)) + " ATR · n " + str.tostring(n) : "– · n 0"

var table tb = table.new(f_pos(tblPos), 2, 6, bgcolor = color.new(chart.bg_color, 6), border_color = color.new(chart.fg_color, 88), border_width = 1, force_overlay = true)
if barstate.isfirst
    table.merge_cells(tb, 0, 0, 1, 0)

f_row(int row, string key, string val, color valCol) =>
    table.cell(tb, 0, row, key, text_color = color.new(chart.fg_color, 35), text_halign = text.align_left, text_size = size.small)
    table.cell(tb, 1, row, val, text_color = valCol, text_halign = text.align_right, text_size = size.small)

if showTbl and barstate.islast
    string hdr = "EMA Extension Pulse · EMA " + str.tostring(meanLen) + " · ATR " + str.tostring(atrLen) + " · eff " + str.tostring(effLen) + " · ±" + str.tostring(guide, "0.0#") + " ATR · reset ±" + str.tostring(rearm, "0.0#") + " · clean ≥ " + str.tostring(cleanThr, "0.00") + " in " + str.tostring(gradeBars) + " · +" + str.tostring(horizon) + " bars"
    table.cell(tb, 0, 0, hdr, text_color = #0b0d12, bgcolor = #a67cf0, text_halign = text.align_left, text_size = size.small)
    string hz = str.tostring(horizon)
    f_row(1, "Stretch now", f_sgn(stretch) + " ATR", stretch >= 0 ? upCol : dnCol)
    f_row(2, "Efficiency now", str.tostring(eff, "0.000") + (isClean ? " · clean" : " · messy"), isClean ? GOLD : chart.fg_color)
    f_row(3, "Clean stretches · kept going " + hz + " bars on", f_rate(0), GOLD)
    f_row(4, "Messy stretches · kept going " + hz + " bars on", f_rate(1), chart.fg_color)
    f_row(5, "Bars · window (" + syminfo.timezone + ")", str.tostring(bar_index + 1) + " · " + str.format_time(tFirst, "yyyy-MM-dd", syminfo.timezone) + " → " + str.format_time(time, timeframe.isintraday ? "yyyy-MM-dd HH:mm" : "yyyy-MM-dd", syminfo.timezone), chart.fg_color)

// ─── Alerts ──────────────────────────────────────────────────────────────
alertcondition(cleanUp, "Clean stretch up", "EMA Extension Pulse: {{ticker}} was graded clean at the upper guide")
alertcondition(cleanDn, "Clean stretch down", "EMA Extension Pulse: {{ticker}} was graded clean at the lower guide")
````
