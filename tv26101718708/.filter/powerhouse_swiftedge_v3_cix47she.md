# PowerHouse SwiftEdge v3

- url: https://www.tradingview.com/script/CIX47ShE-PowerHouse-SwiftEdge-v3/
- type: indicator
- pine_id: PUB;eb9cef015c564b82b95cad27b8064c7c
- version: 1.0

## Description

PowerHouse SwiftEdge v3 is the third generation of PowerHouse. It keeps what made v2 popular (structure signals, Get Ready pre-signals, filters you choose yourself, take-profit levels and a multi-timeframe dashboard) and rebuilds every part of it. Each signal now comes with a quality grade and a complete trade plan, the trend ribbon fades to neutral when the market goes sideways, and a colour-coded Trend Matrix shows the bias across six timeframes at a glance.

SIGNALS

• Market structure: swing highs and lows are confirmed with a structure length on each side. A close beyond the last unbroken swing high is a bullish break, a close beyond the last unbroken swing low a bearish break.
  – CHoCH (change of character): the first break against the current structure, a possible reversal.
  – BOS (break of structure): a break in the direction of the structure, a continuation.
  Choose CHoCH + BOS, CHoCH only or BOS only. Structure lines with a CHoCH or BOS tag show where each break happened, and swing labels (HH, HL, LH, LL) show how the structure is building.
• Trigger levels: dotted lines at the unbroken swing high and low mark exactly where the next BUY and the next SELL would trigger.
• BUY and SELL labels print on the bar that closes beyond the level, when every enabled filter agrees. By default, only one signal per direction is shown until the opposite signal.
• Get Ready: a small pre-signal when price closes within a set ATR distance of the level that would trigger a signal and the enabled filters (except momentum and breakout) already agree.

FILTERS

Each filter can be switched on or off. Every enabled filter must agree with the signal:
  – Momentum: the move over N bars, measured in ATR.
  – Higher-timeframe trend: close vs EMA on a higher timeframe, from closed bars only.
  – Lower-timeframe trend: close vs EMA on a lower timeframe.
  – Volume: volume above a multiple of its 20-bar average.
  – Breakout: the signal bar also closes beyond the highest high (lowest low) of a lookback.
  – Order flow (CVD): cumulative volume delta over N bars points the same way. Delta is estimated from lower-timeframe candles.
  – Trend ribbon: the ribbon's trend score does not clearly point the other way. A neutral ribbon allows signals in both directions, so reversals (CHoCH) are not filtered out.
  – Session window (optional): signals only inside a chosen session.

GRADE A / B / C

Every signal is graded by how many of the seven checks agree with it, whether they are enabled or not: A for five or more, B for three or four, C for fewer. Hover a signal to see the full checklist.

TRADE PLAN

Each signal draws a plan:
  – Entry at the signal close.
  – Stop beyond the opposite swing (kept between a minimum and a maximum ATR distance) or a fixed ATR multiple.
  – TP1, TP2 and TP3 in R multiples, ATR multiples or points, each with its own switch.
The plan is drawn like a position tool: a risk zone, a reward band for each target and price tags on every level. The next target still to reach is highlighted, targets are ticked (✓) when reached and the stop is marked (✕). Optionally, each target label can show its historical hit rate on the chart.

TREND RIBBON

An adaptive, layered ribbon based on Kaufman's adaptive moving average. It speeds up in clean trends and slows down in choppy markets.
  – Its colour follows a smoothed trend score built from the baseline slope and the distance of price from the baseline. In consolidation the colour fades through neutral grey instead of jumping between red and green, and it turns green or red gradually as a trend builds.
  – The direction only changes when price closes beyond the baseline by a flip band (0.6 ATR by default) and the trend score agrees, which keeps the ribbon steady in ranges.
  – Width and brightness grow with conviction, and the candles are shaded with the same colour.

ICT LAYER

  – OTE zone: the optimal trade entry zone (0.62 to 0.79 retracement by default) of the current structure leg.
  – Equilibrium: the 50% level of the same leg, with the premium half and the discount half shaded.

DASHBOARD

  – Bias header: how many timeframes point the same way (for example BULLISH 5/6).
  – Trend Matrix: trend on six timeframes (5m, 15m, 1H, 4H, D and W by default) from closed bars, as colour-coded cells for strong or weak up or down.
  – Volatility: low, normal or high from the ATR percentile.
  – Trend ribbon: direction and conviction, or "Sideways" when there is no clear trend.
  – Signal: the latest signal, its grade and its progress.
  – Next BUY / Next SELL: the trigger levels and their distance in ATR.

HOW TO USE IT

• Start with the default filters (momentum, higher-timeframe trend and the ribbon), then switch filters on or off to match your style: fewer filters for more signals, more filters for stricter ones.
• Use the grade and the Trend Matrix to separate stronger signals from weaker ones. A grade A signal in the direction of a strong bias is the most aligned setup the script can show.
• A grey ribbon means the market has no clear trend. Treat signals there with extra caution and use the OTE zone, the equilibrium and the trigger levels for context.
• Use Get Ready labels to prepare, not to enter. Signals are only final on the bar close.
• Watch the trigger levels and the Next BUY / Next SELL distance to see how close the next structure break is.

NOTES AND LIMITATIONS

• Swings are confirmed a structure length after the high or low, so structure levels appear with that delay. Signals, Get Ready labels and target hits are decided on bar close and do not change afterwards. Higher-timeframe data uses closed bars only.
• Targets and stops are checked against each bar's high and low from the bar after the signal. When the stop and a target are both touched in the same bar, the stop counts first.
• Order-flow delta is an estimate from lower-timeframe candles, not true bid/ask data.
• Hit rates (optional on the target labels) describe the history loaded on your chart and depend on the settings, the symbol, the timeframe and the data feed. They are a measurement, not a forecast.

This script is for analysis and education. It does not provide trading advice, and past behaviour shown on the chart does not imply future results.

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════════════
//  PowerHouse SwiftEdge v3
//  Structure signals (CHoCH and BOS) with filters you choose, Get Ready
//  pre-signals, a trade plan on every signal (stop, TP1-TP3) with the
//  historical hit rate of each target, an adaptive trend ribbon, an OTE zone
//  and a multi-timeframe Trend Matrix.
//
//   • Signals: a close beyond the last confirmed swing high or low. Against
//     the current structure it is a CHoCH (change of character), with it a
//     BOS (break of structure).
//   • Filters (each on or off): momentum, higher-timeframe trend, lower-
//     timeframe trend, volume, breakout, order flow (CVD) and the trend
//     ribbon. Every enabled filter must agree. A session window is optional.
//   • Grade A / B / C: how many of the seven checks agree with the signal,
//     whether they are enabled or not.
//   • Trade plan: entry on the signal close, stop beyond the opposite swing
//     (or ATR), TP1-TP3 in R, ATR or points. Targets are ticked when hit and
//     show their hit rate from the chart's own history.
//   • Trend Matrix: trend and strength on six timeframes from closed bars.
//
//  Everything is decided on bar close. Higher-timeframe data uses closed
//  bars only. A research tool: statistics describe the loaded history only
//  and are not a forecast.
// ═══════════════════════════════════════════════════════════════════════════
indicator("PowerHouse SwiftEdge v3", "PowerHouse v3", overlay = true,
     max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500, max_bars_back = 500)

// ═══ Inputs ════════════════════════════════════════════════════════════════
grpS = "1 · Signals"
sigMode   = input.string("CHoCH + BOS", "Signals", options = ["CHoCH + BOS", "CHoCH only", "BOS only"], group = grpS,
     tooltip = "CHoCH: the first break against the current structure (a possible reversal). BOS: a break in the direction of the structure (continuation).")
pvLen     = input.int(5, "Structure length", minval = 2, maxval = 50, group = grpS,
     tooltip = "Bars on each side of a swing high or low. Lower = faster signals, higher = bigger structure.")
oneDir    = input.bool(true, "One signal per direction until the opposite signal", group = grpS)
showReady = input.bool(true, "Get Ready pre-signals", inline = "rd", group = grpS)
readyK    = input.float(0.5, "within ATR", minval = 0.05, step = 0.05, inline = "rd", group = grpS,
     tooltip = "Price is within this many ATR of the level that would trigger a signal and the enabled filters already agree.")
showGrade = input.bool(true, "Show grade on signals", group = grpS)
showStr   = input.bool(true, "Structure lines (CHoCH / BOS)", inline = "st", group = grpS)
showSw    = input.bool(true, "Swing labels (HH / HL / LH / LL)", inline = "st", group = grpS)
showTrig  = input.bool(true, "Next BUY / SELL trigger levels", group = grpS,
     tooltip = "Dotted lines at the unbroken swing high and low: a close beyond them is the next structure break.")

grpF = "2 · Filters (every enabled filter must agree)"
fMom   = input.bool(true, "Momentum", inline = "f1", group = grpF)
momLen = input.int(5, "bars", minval = 1, inline = "f1", group = grpF)
momK   = input.float(0.5, "ATR", minval = 0.0, step = 0.1, inline = "f1", group = grpF)
fHtf   = input.bool(true, "Higher-timeframe trend", inline = "f2", group = grpF)
htfTf  = input.timeframe("60", "", inline = "f2", group = grpF)
htfLen = input.int(50, "EMA", minval = 2, inline = "f2", group = grpF)
fLtf   = input.bool(false, "Lower-timeframe trend", inline = "f3", group = grpF)
ltfTf  = input.timeframe("1", "", inline = "f3", group = grpF)
ltfLen = input.int(20, "EMA", minval = 2, inline = "f3", group = grpF)
fVol   = input.bool(false, "Volume", inline = "f4", group = grpF)
volK   = input.float(1.2, "× average", minval = 0.1, step = 0.1, inline = "f4", group = grpF)
fBrk   = input.bool(false, "Breakout", inline = "f5", group = grpF,
     tooltip = "The signal candle also closes beyond the highest high (lowest low) of the lookback.")
brkLen = input.int(20, "bars", minval = 2, inline = "f5", group = grpF)
fFlow  = input.bool(false, "Order flow (CVD)", inline = "f6", group = grpF,
     tooltip = "Cumulative volume delta over the lookback points the same way. Delta is estimated from lower-timeframe candles.")
flowLen = input.int(20, "bars", minval = 2, inline = "f6", group = grpF)
fRib   = input.bool(true, "Trend ribbon", group = grpF,
     tooltip = "Blocks a signal only when the ribbon's trend score clearly points the other way. A neutral (grey) ribbon allows signals in both directions, so reversals (CHoCH) are not filtered out.")
fSes   = input.bool(false, "Session window", inline = "f8", group = grpF)
sesStr = input.session("0700-1600", "", inline = "f8", group = grpF)
sesTz  = input.string("America/New_York", "Session timezone", group = grpF)

grpR = "3 · Trend ribbon"
showRib = input.bool(true, "Ribbon", inline = "rb", group = grpR)
showBar = input.bool(true, "Candle colours", inline = "rb", group = grpR)
erLen   = input.int(10, "Adaptive length", minval = 2, inline = "kl", group = grpR)
slowLen = input.int(30, "slow", minval = 3, inline = "kl", group = grpR)
ribBand = input.float(0.6, "Flip band (ATR)", minval = 0.0, step = 0.1, group = grpR,
     tooltip = "The ribbon only changes direction when price closes this many ATR beyond the baseline and the trend score agrees. Higher = fewer flips in consolidation.")
ribSm   = input.int(10, "Colour smoothing (bars)", minval = 1, maxval = 50, group = grpR,
     tooltip = "The colour follows a smoothed trend score: it fades through neutral grey when the market goes sideways instead of jumping between red and green.")

grpT = "4 · Trade plan"
slType  = input.string("Structure", "Stop", options = ["Structure", "ATR ×"], inline = "sl", group = grpT,
     tooltip = "Structure: beyond the opposite swing, kept between the min and max ATR distance. ATR ×: a fixed ATR multiple.")
slAtr   = input.float(1.5, "", minval = 0.1, step = 0.1, inline = "sl", group = grpT)
minRisk = input.float(0.5, "Stop distance (ATR): min", minval = 0.1, step = 0.1, inline = "rk", group = grpT)
maxRisk = input.float(3.0, "max", minval = 0.2, step = 0.1, inline = "rk", group = grpT)
tpMode  = input.string("R multiple", "Targets in", options = ["R multiple", "ATR ×", "Points"], group = grpT)
tp1On   = input.bool(true, "TP1", inline = "t1", group = grpT)
tp1     = input.float(1.0, "", minval = 0.01, step = 0.25, inline = "t1", group = grpT)
tp2On   = input.bool(true, "TP2", inline = "t1", group = grpT)
tp2     = input.float(2.0, "", minval = 0.01, step = 0.25, inline = "t1", group = grpT)
tp3On   = input.bool(true, "TP3", inline = "t1", group = grpT)
tp3     = input.float(3.0, "", minval = 0.01, step = 0.25, inline = "t1", group = grpT)
showTP  = input.bool(true, "Show trade plan", inline = "sp", group = grpT)
showPct = input.bool(false, "Hit rate on targets", inline = "sp", group = grpT)
projBars = input.int(20, "Plan length (bars)", minval = 5, maxval = 200, group = grpT)
keepSig = input.int(5, "Signals kept on chart", minval = 1, maxval = 50, group = grpT)

grpI = "5 · ICT"
showOTE = input.bool(true, "OTE zone of the current leg", inline = "ot", group = grpI)
oteLo   = input.float(0.62, "", minval = 0.0, maxval = 1.0, step = 0.01, inline = "ot", group = grpI)
oteHi   = input.float(0.79, "to", minval = 0.0, maxval = 1.0, step = 0.01, inline = "ot", group = grpI)
showEQ  = input.bool(true, "Equilibrium (50%)", inline = "eq", group = grpI)
showPD  = input.bool(true, "Premium / discount shading", inline = "eq", group = grpI)

grpD = "6 · Dashboard"
showDash = input.bool(true, "Dashboard", inline = "db", group = grpD)
dashPos  = input.string("Top right", "", options = ["Top right", "Top left", "Bottom right", "Bottom left", "Middle right"], inline = "db", group = grpD)
dashSz   = input.string("Small", "Text size", options = ["Tiny", "Small", "Normal"], group = grpD)
mtf1 = input.timeframe("5", "Matrix", inline = "m1", group = grpD)
mtf2 = input.timeframe("15", "", inline = "m1", group = grpD)
mtf3 = input.timeframe("60", "", inline = "m1", group = grpD)
mtf4 = input.timeframe("240", "", inline = "m2", group = grpD)
mtf5 = input.timeframe("D", "", inline = "m2", group = grpD)
mtf6 = input.timeframe("W", "", inline = "m2", group = grpD)
mtfLen = input.int(50, "Matrix EMA", minval = 2, group = grpD)

grpC = "7 · Colours"
cBull  = input.color(#089981, "Buy", inline = "c1", group = grpC)
cBear  = input.color(#f23645, "Sell", inline = "c1", group = grpC)
cReady = input.color(#f5a623, "Get Ready", inline = "c1", group = grpC)
cChoch = input.color(#5b9cf6, "CHoCH", inline = "c2", group = grpC)
cBos   = input.color(#9598a1, "BOS", inline = "c2", group = grpC)
cTp    = input.color(#26a69a, "Targets", inline = "c3", group = grpC)
cSl    = input.color(#ef5350, "Stop", inline = "c3", group = grpC)
cEnt   = input.color(#b2b5be, "Entry", inline = "c3", group = grpC)

// ═══ Data ══════════════════════════════════════════════════════════════════
atr   = ta.atr(14)
tfSec = timeframe.in_seconds()

// lower-timeframe delta for the order-flow filter
autoLtf = tfSec <= 900 ? "1" : tfSec <= 3600 ? "5" : tfSec <= 14400 ? "15" : tfSec <= 86400 ? "60" : "240"
[lV, lC, lO] = request.security_lower_tf(syminfo.tickerid, autoLtf, [volume, close, open])
float bV = 0.0
float sV = 0.0
if array.size(lV) > 0
    for i = 0 to array.size(lV) - 1
        v = nz(array.get(lV, i))
        if array.get(lC, i) >= array.get(lO, i)
            bV += v
        else
            sV += v
else
    r0 = high - low
    bV := r0 > 0 ? nz(volume) * (close - low) / r0 : nz(volume) * 0.5
    sV := nz(volume) - bV
cvd = ta.cum(bV - sV)

// adaptive ribbon (Kaufman)
path  = math.sum(math.abs(nz(ta.change(close))), erLen)
effic = path > 0 ? math.abs(close - close[erLen]) / path : 0.0
scK   = math.pow(effic * (2.0 / 3 - 2.0 / (slowLen + 1)) + 2.0 / (slowLen + 1), 2)
var float kama = na
kama := na(kama) ? close : kama + scK * (close - kama)
// smoothed trend score −1..+1 from the baseline slope and price vs the baseline
kSlope = atr > 0 ? (kama - kama[5]) / atr : 0.0
rawSc  = atr > 0 ? math.max(-1.0, math.min(1.0, 0.6 * kSlope + 0.4 * (close - kama) / (2 * atr))) : 0.0
tScore = ta.ema(rawSc, ribSm)
// direction with hysteresis: a close beyond the flip band and a score past ±0.25
var int ribDir = 0
if close > kama + ribBand * atr and tScore > 0.25
    ribDir := 1
else if close < kama - ribBand * atr and tScore < -0.25
    ribDir := -1
// colour fades through neutral grey in consolidation
cNeu   = #787b86
ribCol = tScore >= 0 ? color.from_gradient(tScore, 0.0, 0.6, cNeu, cBull) : color.from_gradient(tScore, -0.6, 0.0, cBear, cNeu)
conv   = math.min(1.0, math.abs(tScore) / 0.6)
side   = ribDir == 0 ? 1 : ribDir
w      = 0.4 + conv
edge1  = kama - side * 0.35 * atr * w
edge2  = kama - side * 0.8 * atr * w
flipR  = ribDir != ribDir[1]
pK  = plot(showRib and not flipR ? kama : na, "Ribbon", color.new(ribCol, 5), 2, plot.style_linebr)
pE1 = plot(showRib and not flipR ? edge1 : na, "Ribbon inner edge", color.new(ribCol, 100), 1, plot.style_linebr)
pE2 = plot(showRib and not flipR ? edge2 : na, "Ribbon outer edge", color.new(ribCol, 70), 1, plot.style_linebr)
fill(pK, pE1, color.new(ribCol, int(78 - conv * 30)), "Ribbon core")
fill(pE1, pE2, color.new(ribCol, int(90 - conv * 18)), "Ribbon glow")
barcolor(showBar ? ribCol : na)

// filter inputs, all from closed data
momN = atr > 0 ? (close - close[momLen]) / atr : 0.0
[hC, hE] = request.security(syminfo.tickerid, htfTf, [close[1], ta.ema(close, htfLen)[1]], lookahead = barmerge.lookahead_on)
htfDir = hC > hE ? 1 : hC < hE ? -1 : 0
[lCl, lEm] = request.security(syminfo.tickerid, ltfTf, [close, ta.ema(close, ltfLen)])
ltfDir = lCl > lEm ? 1 : lCl < lEm ? -1 : 0
volR   = ta.sma(nz(volume), 20) > 0 ? nz(volume) / ta.sma(nz(volume), 20) : 0.0
brkUp  = close > ta.highest(high, brkLen)[1]
brkDn  = close < ta.lowest(low, brkLen)[1]
cvdDir = cvd - cvd[flowLen] > 0 ? 1 : cvd - cvd[flowLen] < 0 ? -1 : 0
inSes  = not na(time(timeframe.period, sesStr, sesTz))
atrPct = ta.percentrank(atr, 100)

NAMES = array.from("Momentum", "Higher-timeframe trend", "Lower-timeframe trend", "Volume", "Breakout", "Order flow (CVD)", "Trend ribbon")
ENAB  = array.from(fMom, fHtf, fLtf, fVol, fBrk, fFlow, fRib)

checks(int d) =>
    array.from(momN * d >= momK, htfDir == d, ltfDir == d, volR >= volK, d == 1 ? brkUp : brkDn, cvdDir == d, tScore * d > -0.2)

// all enabled filters agree; skipIdx lets Get Ready ignore momentum and breakout
passAll(int d, bool forReady) =>
    ag = checks(d)
    bool ok = true
    for i = 0 to 6
        if ENAB.get(i) and not ag.get(i) and not (forReady and (i == 0 or i == 4))
            ok := false
    ok and (not fSes or inSes)

grade(int d) =>
    ag = checks(d)
    int n = 0
    for i = 0 to 6
        n += ag.get(i) ? 1 : 0
    n >= 5 ? "A" : n >= 3 ? "B" : "C"

checkList(int d) =>
    ag = checks(d)
    string s = ""
    for i = 0 to 6
        s += "\n" + (ag.get(i) ? "✓ " : "– ") + NAMES.get(i) + (ENAB.get(i) ? "" : " (off)")
    s

sizeOf(string s) =>
    s == "Small" ? size.small : s == "Normal" ? size.normal : size.tiny

posOf(string s) =>
    s == "Top left" ? position.top_left : s == "Bottom right" ? position.bottom_right :
     s == "Bottom left" ? position.bottom_left : s == "Middle right" ? position.middle_right : position.top_right

// ═══ Structure ═════════════════════════════════════════════════════════════
ph = ta.pivothigh(high, pvLen, pvLen)
pl = ta.pivotlow(low, pvLen, pvLen)
var float pH = na
var int   pHb = na
var bool  pHx = true      // already broken
var bool  pHr = false     // Get Ready shown
var float pL = na
var int   pLb = na
var bool  pLx = true
var bool  pLr = false
var int   msDir = 0
var swQ = array.new_label()
if not na(ph)
    if showSw
        swQ.push(label.new(bar_index - pvLen, ph, na(pH) ? "H" : ph > pH ? "HH" : "LH", style = label.style_label_down, color = color(na),
             textcolor = color.new(#9598a1, 10), size = size.tiny))
    pH  := ph
    pHb := bar_index - pvLen
    pHx := false
    pHr := false
if not na(pl)
    if showSw
        swQ.push(label.new(bar_index - pvLen, pl, na(pL) ? "L" : pl < pL ? "LL" : "HL", style = label.style_label_up, color = color(na),
             textcolor = color.new(#9598a1, 10), size = size.tiny))
    pL  := pl
    pLb := bar_index - pvLen
    pLx := false
    pLr := false

while swQ.size() > 40
    label.delete(swQ.shift())

// ═══ Signals and trade plans ═══════════════════════════════════════════════
type Sig
    int   dir
    int   b0
    string grade
    float entry
    float sl
    float risk
    array<float> tp
    array<bool>  hit
    bool  stopped
    bool  closed
    array<line>  tLn
    array<label> tLb
    array<box>   bx
    line  eLn
    line  sLn
    label sLb
    label mark

var sigs   = array.new<Sig>()
var strQ   = array.new_line()
var strL   = array.new_label()
var rdyQ   = array.new_label()
var int lastDir = 0
// completed signals: n, hits per target, and the same for grade A
var int nDone = 0
var int nStop1 = 0
var hitN  = array.new_int(3, 0)
var int nA = 0
var hitA  = array.new_int(3, 0)
TPON = array.from(tp1On, tp2On, tp3On)
TPV  = array.from(tp1, tp2, tp3)

hitPct(int k) =>
    nDone > 0 ? hitN.get(k) * 100.0 / nDone : float(na)

tpText(Sig S, int k) =>
    p = hitPct(k)
    (S.hit.get(k) ? "✓ " : "") + "TP" + str.tostring(k + 1) + "  " + str.tostring(S.tp.get(k), format.mintick) +
     (showPct and nDone >= 20 and not na(p) ? "  ·  " + str.tostring(p, "#") + "%" : "")

method kill(Sig S) =>
    for b in S.bx
        box.delete(b)
    for l in S.tLn
        line.delete(l)
    for l in S.tLb
        label.delete(l)
    line.delete(S.eLn)
    line.delete(S.sLn)
    label.delete(S.sLb)
    true

method repaint(Sig S, bool active) =>
    fade = active ? 0 : 45
    x2 = active ? math.max(S.b0 + projBars, bar_index + 3) : math.max(S.b0 + 3, bar_index)
    if not na(S.eLn)
        line.set_x2(S.eLn, x2)
        line.set_color(S.eLn, color.new(cEnt, 30 + fade))
    if not na(S.sLn)
        line.set_x2(S.sLn, x2)
        line.set_color(S.sLn, color.new(cSl, (S.stopped ? 0 : 20) + fade))
        label.set_x(S.sLb, x2)
        label.set_text(S.sLb, (S.stopped ? "✕ " : "") + "SL  " + str.tostring(S.sl, format.mintick))
        label.set_textcolor(S.sLb, color.new(cSl, fade))
    for b in S.bx
        box.set_right(b, x2)
    if S.bx.size() > 0
        box.set_bgcolor(S.bx.get(0), color.new(cSl, 86 + fade / 4))
    if S.bx.size() > 1
        for j = 1 to S.bx.size() - 1
            box.set_bgcolor(S.bx.get(j), color.new(cTp, 84 + j * 3 + fade / 4))
    // the next target still to reach is emphasised while the plan is active
    int nxt = -1
    for k = 0 to 2
        if nxt < 0 and TPON.get(k) and not S.hit.get(k)
            nxt := k
    for k = 0 to math.max(0, S.tLn.size() - 1)
        ln = S.tLn.size() > 0 ? S.tLn.get(k) : line(na)
        if not na(ln)
            isNext = active and not S.stopped and k == nxt
            line.set_x2(ln, x2)
            line.set_color(ln, color.new(cTp, (S.hit.get(k) or isNext ? 0 : 40) + fade))
            line.set_width(ln, S.hit.get(k) or isNext ? 2 : 1)
            line.set_style(ln, S.hit.get(k) or isNext ? line.style_solid : line.style_dashed)
            lb = S.tLb.get(k)
            label.set_x(lb, x2)
            label.set_text(lb, tpText(S, k))
            label.set_textcolor(lb, color.new(cTp, (S.hit.get(k) ? 0 : 15) + fade))
    true

bool evBuy = false
bool evSell = false
bool evRdyB = false
bool evRdyS = false
bool evTP1 = false
bool evTP2 = false
bool evTP3 = false
bool evSL = false

if barstate.isconfirmed
    // 1) the active plan: stop first, then targets
    if sigs.size() > 0
        S = sigs.last()
        if not S.closed and bar_index > S.b0
            if S.dir == 1 ? low <= S.sl : high >= S.sl
                S.stopped := true
                S.closed := true
                evSL := true
            else
                for k = 0 to 2
                    if TPON.get(k) and not S.hit.get(k) and (S.dir == 1 ? high >= S.tp.get(k) : low <= S.tp.get(k))
                        S.hit.set(k, true)
                        evTP1 := evTP1 or k == 0
                        evTP2 := evTP2 or k == 1
                        evTP3 := evTP3 or k == 2
                bool all = true
                for k = 0 to 2
                    if TPON.get(k) and not S.hit.get(k)
                        all := false
                if all
                    S.closed := true
            if S.closed
                nDone += 1
                nA += S.grade == "A" ? 1 : 0
                for k = 0 to 2
                    if S.hit.get(k)
                        hitN.set(k, hitN.get(k) + 1)
                        if S.grade == "A"
                            hitA.set(k, hitA.get(k) + 1)
                nStop1 += S.stopped and not S.hit.get(0) ? 1 : 0
            S.repaint(not S.closed)
    // 2) breaks of structure
    upBreak = not na(pH) and not pHx and close > pH
    dnBreak = not na(pL) and not pLx and close < pL
    int sigD = 0
    string kind = ""
    if upBreak
        kind := msDir == -1 ? "CHoCH" : "BOS"
        msDir := 1
        pHx := true
        if showStr
            strQ.push(line.new(pHb, pH, bar_index, pH, color = color.new(kind == "CHoCH" ? cChoch : cBos, 20), style = line.style_dashed))
            strL.push(label.new(int(math.round((pHb + bar_index) / 2)), pH, kind, style = label.style_label_down, color = color(na),
                 textcolor = kind == "CHoCH" ? cChoch : cBos, size = size.tiny))
        if sigMode == "CHoCH + BOS" or (sigMode == "CHoCH only" and kind == "CHoCH") or (sigMode == "BOS only" and kind == "BOS")
            sigD := 1
    else if dnBreak
        kind := msDir == 1 ? "CHoCH" : "BOS"
        msDir := -1
        pLx := true
        if showStr
            strQ.push(line.new(pLb, pL, bar_index, pL, color = color.new(kind == "CHoCH" ? cChoch : cBos, 20), style = line.style_dashed))
            strL.push(label.new(int(math.round((pLb + bar_index) / 2)), pL, kind, style = label.style_label_up, color = color(na),
                 textcolor = kind == "CHoCH" ? cChoch : cBos, size = size.tiny))
        if sigMode == "CHoCH + BOS" or (sigMode == "CHoCH only" and kind == "CHoCH") or (sigMode == "BOS only" and kind == "BOS")
            sigD := -1
    while strQ.size() > keepSig * 4
        line.delete(strQ.shift())
    while strL.size() > keepSig * 4
        label.delete(strL.shift())
    // 3) a signal: filters, plan and drawings
    if sigD != 0 and passAll(sigD, false) and not (oneDir and sigD == lastDir)
        lastDir := sigD
        g = grade(sigD)
        if sigD == 1
            evBuy := true
        else
            evSell := true
        // the previous plan ends here
        if sigs.size() > 0
            P = sigs.last()
            if not P.closed
                P.closed := true
                nDone += 1
                nA += P.grade == "A" ? 1 : 0
                for k = 0 to 2
                    if P.hit.get(k)
                        hitN.set(k, hitN.get(k) + 1)
                        if P.grade == "A"
                            hitA.set(k, hitA.get(k) + 1)
            P.repaint(false)
        e     = close
        swing = sigD == 1 ? pL : pH
        rawR  = slType == "ATR ×" or na(swing) ? slAtr * atr : math.abs(e - swing) + 0.1 * atr
        risk  = slType == "ATR ×" ? slAtr * atr : math.max(minRisk * atr, math.min(maxRisk * atr, rawR))
        sl    = e - sigD * risk
        S = Sig.new(sigD, bar_index, g, e, sl, risk, array.new_float(), array.new_bool(), false, false, array.new_line(), array.new_label(), array.new_box())
        for k = 0 to 2
            dist = tpMode == "R multiple" ? TPV.get(k) * risk : tpMode == "ATR ×" ? TPV.get(k) * atr : TPV.get(k)
            S.tp.push(e + sigD * dist)
            S.hit.push(false)
        SZ = size.small
        S.mark := label.new(bar_index, sigD == 1 ? low : high, (sigD == 1 ? "BUY" : "SELL") + (showGrade ? " · " + g : ""),
             yloc = sigD == 1 ? yloc.belowbar : yloc.abovebar, style = sigD == 1 ? label.style_label_up : label.style_label_down,
             color = color.new(sigD == 1 ? cBull : cBear, g == "A" ? 0 : g == "B" ? 15 : 35), textcolor = color.white, size = SZ,
             tooltip = (sigD == 1 ? "Buy" : "Sell") + " · " + kind + " · grade " + g + "\nEntry " + str.tostring(e, format.mintick) +
             " · stop " + str.tostring(sl, format.mintick) + checkList(sigD))
        if showTP
            x2 = bar_index + projBars
            S.eLn := line.new(bar_index, e, x2, e, color = color.new(cEnt, 30))
            S.sLn := line.new(bar_index, sl, x2, sl, color = color.new(cSl, 20))
            S.sLb := label.new(x2, sl, "SL", style = label.style_label_left, color = color(na), textcolor = cSl, size = SZ)
            // risk zone, then one reward band per enabled target
            S.bx.push(box.new(bar_index, math.max(e, sl), x2, math.min(e, sl), border_color = color(na), bgcolor = color.new(cSl, 86)))
            float prev = e
            for k = 0 to 2
                if TPON.get(k)
                    tpk = S.tp.get(k)
                    S.bx.push(box.new(bar_index, math.max(prev, tpk), x2, math.min(prev, tpk), border_color = color(na), bgcolor = color.new(cTp, 87)))
                    prev := tpk
            for k = 0 to 2
                if TPON.get(k)
                    tp = S.tp.get(k)
                    S.tLn.push(line.new(bar_index, tp, x2, tp, color = color.new(cTp, 35), style = line.style_dashed))
                    S.tLb.push(label.new(x2, tp, "", style = label.style_label_left, color = color(na), textcolor = cTp, size = SZ))
                else
                    S.tLn.push(line(na))
                    S.tLb.push(label(na))
            S.repaint(true)
        sigs.push(S)
        if sigs.size() > keepSig
            old = sigs.shift()
            old.kill()
            label.delete(old.mark)
    // 4) Get Ready: close to the trigger level and the filters already agree
    if showReady and not na(pH) and not pHx and not pHr and close < pH and close >= pH - readyK * atr and passAll(1, true) and not (oneDir and lastDir == 1)
        pHr := true
        evRdyB := true
        rdyQ.push(label.new(bar_index, high, "Ready", yloc = yloc.abovebar, style = label.style_label_down, color = color.new(cReady, 20),
             textcolor = color.black, size = size.tiny, tooltip = "Get Ready BUY: price is within " + str.tostring(readyK) + " ATR of the swing high at " +
             str.tostring(pH, format.mintick) + " and the enabled filters agree."))
    if showReady and not na(pL) and not pLx and not pLr and close > pL and close <= pL + readyK * atr and passAll(-1, true) and not (oneDir and lastDir == -1)
        pLr := true
        evRdyS := true
        rdyQ.push(label.new(bar_index, low, "Ready", yloc = yloc.belowbar, style = label.style_label_up, color = color.new(cReady, 20),
             textcolor = color.black, size = size.tiny, tooltip = "Get Ready SELL: price is within " + str.tostring(readyK) + " ATR of the swing low at " +
             str.tostring(pL, format.mintick) + " and the enabled filters agree."))
    while rdyQ.size() > keepSig * 2
        label.delete(rdyQ.shift())

// keep target labels of older plans in step with the latest hit rates
if barstate.islast and sigs.size() > 1
    for i = 0 to sigs.size() - 2
        S = sigs.get(i)
        for k = 0 to math.max(0, S.tLb.size() - 1)
            lb = S.tLb.size() > 0 ? S.tLb.get(k) : label(na)
            if not na(lb)
                label.set_text(lb, tpText(S, k))

// ═══ ICT: OTE zone and equilibrium of the current leg ══════════════════════
var box  oteBx = na
var line eqLn  = na
var label eqLb = na
var box  pdHi = na
var box  pdLo = na
if barstate.islast
    box.delete(pdHi)
    box.delete(pdLo)
    pdHi := na
    pdLo := na
    box.delete(oteBx)
    line.delete(eqLn)
    label.delete(eqLb)
    oteBx := na
    eqLn := na
    eqLb := na
    a  = msDir == 1 ? pL : msDir == -1 ? pH : na
    ab = msDir == 1 ? pLb : msDir == -1 ? pHb : na
    if (showOTE or showEQ) and not na(a) and not na(ab) and bar_index - ab < 490
        float ext = a
        int extB = ab
        for k = 0 to bar_index - ab
            v = msDir == 1 ? high[k] : low[k]
            if msDir == 1 ? v > ext : v < ext
                ext := v
                extB := bar_index - k
        legR = math.abs(ext - a)
        if legR > 0
            c = msDir == 1 ? cBull : cBear
            if showOTE
                z1 = ext - msDir * legR * oteLo
                z2 = ext - msDir * legR * oteHi
                oteBx := box.new(extB, math.max(z1, z2), bar_index + 15, math.min(z1, z2), border_color = color.new(c, 60), bgcolor = color.new(c, 88),
                     text = "OTE", text_color = color.new(c, 20), text_size = size.small, text_halign = text.align_right)
            if showPD
                top = math.max(ext, a)
                bot = math.min(ext, a)
                mid = (top + bot) / 2
                pdHi := box.new(extB, top, bar_index + 15, mid, border_color = color(na), bgcolor = color.new(cBear, 95),
                     text = "Premium", text_color = color.new(cBear, 45), text_size = size.tiny, text_halign = text.align_right, text_valign = text.align_top)
                pdLo := box.new(extB, mid, bar_index + 15, bot, border_color = color(na), bgcolor = color.new(cBull, 95),
                     text = "Discount", text_color = color.new(cBull, 45), text_size = size.tiny, text_halign = text.align_right, text_valign = text.align_bottom)
            if showEQ
                eq = ext - msDir * legR * 0.5
                eqLn := line.new(extB, eq, bar_index + 15, eq, color = color.new(#9598a1, 40), style = line.style_dotted)
                eqLb := label.new(bar_index + 15, eq, "EQ", style = label.style_label_left, color = color(na), textcolor = #9598a1, size = size.tiny)

var trgL = array.new_line()
var trgB = array.new_label()
if barstate.islast
    for l in trgL
        line.delete(l)
    for l in trgB
        label.delete(l)
    trgL.clear()
    trgB.clear()
    if showTrig
        if not na(pH) and not pHx
            trgL.push(line.new(pHb, pH, bar_index + 15, pH, color = color.new(cBull, 35), style = line.style_dotted, width = 1))
            trgB.push(label.new(bar_index + 15, pH, "BUY trigger  " + str.tostring(pH, format.mintick), style = label.style_label_left,
                 color = color(na), textcolor = color.new(cBull, 10), size = size.small))
        if not na(pL) and not pLx
            trgL.push(line.new(pLb, pL, bar_index + 15, pL, color = color.new(cBear, 35), style = line.style_dotted, width = 1))
            trgB.push(label.new(bar_index + 15, pL, "SELL trigger  " + str.tostring(pL, format.mintick), style = label.style_label_left,
                 color = color(na), textcolor = color.new(cBear, 10), size = size.small))

// ═══ Trend Matrix ══════════════════════════════════════════════════════════
mtfGet(string tf) =>
    request.security(syminfo.tickerid, tf, [close[1], ta.ema(close, mtfLen)[1], ta.ema(close, mtfLen)[2]], lookahead = barmerge.lookahead_on)

[m1c, m1e, m1p] = mtfGet(mtf1)
[m2c, m2e, m2p] = mtfGet(mtf2)
[m3c, m3e, m3p] = mtfGet(mtf3)
[m4c, m4e, m4p] = mtfGet(mtf4)
[m5c, m5e, m5p] = mtfGet(mtf5)
[m6c, m6e, m6p] = mtfGet(mtf6)

trendOf(float c, float e, float p) =>
    na(c) or na(e) ? 0 : c > e and e > p ? 2 : c > e ? 1 : c < e and e < p ? -2 : c < e ? -1 : 0

tfName(string tf) =>
    s = timeframe.in_seconds(tf)
    s < 3600 ? str.tostring(math.round(s / 60)) + "m" : s < 86400 ? str.tostring(math.round(s / 3600)) + "H" : s < 604800 ? "D" : s < 2592000 ? "W" : "M"

// ═══ Dashboard ═════════════════════════════════════════════════════════════
cTxt  = #d1d4dc
cMute = #787b86
cHead = #9598a1

cellT(table t, int c, int r, string txt, color col, bool left, sz, string tip) =>
    table.cell(t, c, r, txt, text_color = col, text_size = sz, text_halign = left ? text.align_left : text.align_right, tooltip = tip)
    true

var table dt = na
if barstate.islast and showDash
    if not na(dt)
        table.delete(dt)
    PS = sizeOf(dashSz)
    dt := table.new(posOf(dashPos), 2, 14, bgcolor = color.new(#131722, 6), frame_color = #2a2e39, frame_width = 1, border_color = color.new(#131722, 0), border_width = 2)
    tfs = array.from(mtf1, mtf2, mtf3, mtf4, mtf5, mtf6)
    trs = array.from(trendOf(m1c, m1e, m1p), trendOf(m2c, m2e, m2p), trendOf(m3c, m3e, m3p), trendOf(m4c, m4e, m4p), trendOf(m5c, m5e, m5p), trendOf(m6c, m6e, m6p))
    int bulls = 0
    int bears = 0
    int nTf = 0
    for i = 0 to 5
        if timeframe.in_seconds(tfs.get(i)) >= tfSec
            nTf += 1
            bulls += trs.get(i) > 0 ? 1 : 0
            bears += trs.get(i) < 0 ? 1 : 0
    bias  = bulls > bears ? 1 : bears > bulls ? -1 : 0
    biasC = bias == 1 ? cBull : bias == -1 ? cBear : #787b86
    biasT = (bias == 1 ? "BULLISH " : bias == -1 ? "BEARISH " : "MIXED ") + str.tostring(math.max(bulls, bears)) + "/" + str.tostring(nTf)
    table.cell(dt, 0, 0, "PowerHouse v3", text_color = cTxt, text_size = PS, text_halign = text.align_left, bgcolor = color.new(#2a2e39, 30))
    table.cell(dt, 1, 0, biasT, text_color = color.white, text_size = PS, text_halign = text.align_center, bgcolor = color.new(biasC, 25),
         tooltip = "Timeframes in the Trend Matrix pointing the same way.")
    for i = 0 to 5
        low_ = timeframe.in_seconds(tfs.get(i)) < tfSec
        t = low_ ? 0 : trs.get(i)
        c = t > 0 ? cBull : t < 0 ? cBear : #787b86
        table.cell(dt, 0, 1 + i, tfName(tfs.get(i)), text_color = cMute, text_size = PS, text_halign = text.align_left)
        table.cell(dt, 1, 1 + i, low_ ? "n/a" : t == 2 ? "▲  Strong" : t == 1 ? "▲  Weak" : t == -2 ? "▼  Strong" : t == -1 ? "▼  Weak" : "—",
             text_color = low_ or t == 0 ? cMute : color.white, text_size = PS, text_halign = text.align_center,
             bgcolor = low_ or t == 0 ? color.new(#2a2e39, 60) : color.new(c, math.abs(t) == 2 ? 30 : 65),
             tooltip = low_ ? "Below the chart timeframe." : "Close vs EMA " + str.tostring(mtfLen) + " on closed bars; strong when the EMA also points the same way.")
    vTxt = na(atrPct) ? "—" : atrPct < 30 ? "Low" : atrPct > 70 ? "High" : "Normal"
    table.cell(dt, 0, 7, "Volatility", text_color = cMute, text_size = PS, text_halign = text.align_left)
    table.cell(dt, 1, 7, vTxt, text_color = cTxt, text_size = PS, text_halign = text.align_center, tooltip = "ATR percentile over the last 100 bars: " + (na(atrPct) ? "—" : str.tostring(atrPct, "#")))
    table.cell(dt, 0, 8, "Trend ribbon", text_color = cMute, text_size = PS, text_halign = text.align_left)
    table.cell(dt, 1, 8, conv < 0.25 ? "Sideways" : (tScore > 0 ? "▲ " : "▼ ") + str.tostring(conv * 100, "#") + "%", text_color = conv < 0.25 ? cMute : tScore > 0 ? cBull : cBear,
         text_size = PS, text_halign = text.align_center, tooltip = "Direction and conviction of the adaptive ribbon.")
    string sTxt = "—"
    color sCol = #787b86
    if sigs.size() > 0
        S = sigs.last()
        int nh = 0
        for k = 0 to 2
            nh += S.hit.get(k) ? 1 : 0
        sTxt := (S.dir == 1 ? "BUY" : "SELL") + " · " + S.grade + (S.stopped ? " · SL" : nh > 0 ? " · TP" + str.tostring(nh) + " ✓" : S.closed ? "" : " · live")
        sCol := S.dir == 1 ? cBull : cBear
    table.cell(dt, 0, 9, "Signal", text_color = cMute, text_size = PS, text_halign = text.align_left)
    table.cell(dt, 1, 9, sTxt, text_color = color.white, text_size = PS, text_halign = text.align_center, bgcolor = color.new(sCol, 35))
    dUp = not na(pH) and not pHx and atr > 0 ? (pH - close) / atr : float(na)
    dDn = not na(pL) and not pLx and atr > 0 ? (close - pL) / atr : float(na)
    table.cell(dt, 0, 10, "Next BUY", text_color = cMute, text_size = PS, text_halign = text.align_left)
    table.cell(dt, 1, 10, na(dUp) ? "—" : str.tostring(pH, format.mintick) + " · " + str.tostring(dUp, "#.#") + " ATR", text_color = cBull, text_size = PS,
         text_halign = text.align_center, tooltip = "A close above the unbroken swing high triggers the next bullish break.")
    table.cell(dt, 0, 11, "Next SELL", text_color = cMute, text_size = PS, text_halign = text.align_left)
    table.cell(dt, 1, 11, na(dDn) ? "—" : str.tostring(pL, format.mintick) + " · " + str.tostring(dDn, "#.#") + " ATR", text_color = cBear, text_size = PS,
         text_halign = text.align_center, tooltip = "A close below the unbroken swing low triggers the next bearish break.")

// ═══ Alerts ════════════════════════════════════════════════════════════════
alertcondition(evBuy, "BUY signal", "PowerHouse v3: BUY signal")
alertcondition(evSell, "SELL signal", "PowerHouse v3: SELL signal")
alertcondition(evRdyB, "Get Ready BUY", "PowerHouse v3: Get Ready BUY")
alertcondition(evRdyS, "Get Ready SELL", "PowerHouse v3: Get Ready SELL")
alertcondition(evTP1, "TP1 hit", "PowerHouse v3: TP1 hit")
alertcondition(evTP2, "TP2 hit", "PowerHouse v3: TP2 hit")
alertcondition(evTP3, "TP3 hit", "PowerHouse v3: TP3 hit")
alertcondition(evSL, "Stop hit", "PowerHouse v3: stop hit")
````
