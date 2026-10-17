# Variance Risk Premium Oscillator

- url: https://www.tradingview.com/script/mfxVHTaR-Variance-Risk-Premium-Oscillator/
- type: indicator
- pine_id: PUB;5a9b753847c74e8b90c1e424388c80b2
- version: 2.0

## Description

Variance Risk Premium Oscillator 

What it does

The Variance Risk Premium Oscillator measures the gap between implied volatility (a volatility index such as India VIX) and realized volatility, scaled in standard-deviation (σ) units. That gap — the variance risk premium (VRP) — tells you whether option protection is currently rich (expensive, complacent) or cheap (underpriced, stressed). A vol-of-vol read is shown alongside as an instability gauge.

Why this is different (and original)

Most volatility tools on charts forecast or display realized volatility (ATR, standard-deviation bands, historical-vol plots). This one reads something different: the price of volatility insurance. Decades of research show implied volatility systematically exceeds the volatility that is subsequently realized, so the premium is, on average, positive — investors pay up for protection. When that premium stretches unusually high, protection is expensive and the crowd is complacent; when it collapses or turns negative, fear is being paid for and volatility is cheap. Presenting this premium as a clean, self-normalizing mean-reversion oscillator with a built-in edge test is what makes it original — it is not a realized-vol band and not a VIX plot.

How it works


Realized volatility = annualized standard deviation of log-returns over the chosen window.
Implied volatility = the volatility index you point it at.
VRP = Implied − Realized.
The VRP series is z-scored over the normalization window into the σ oscillator. Vol-of-vol (the standard deviation of the implied index) is tracked separately as an instability read in the dashboard.


How to use it


Above the upper (red) band = vol RICH / complacency — protection expensive.
Below the lower (green) band = vol CHEAP / stress — protection underpriced.
Turns out of an extreme (triangles) are the mean-reversion events: a turn up from the cheap zone often coincides with stress easing; a turn down from the rich zone with complacency ending.
Read the EDGE row. The harness checks whether, after a cheap-zone turn, price actually rallied (and after a rich-zone turn, faded) by ≥ k×ATR within the horizon, versus the unconditional Base %. EDGE = Hit − Base. If it is near zero on your market, the mean-reversion read is not paying there.


Settings guide


01 · Data & Volatility — implied-vol symbol, realized-vol length, annualization (252 for daily; bars-per-year for intraday), vol-of-vol length, universal price source.
02 · Normalization — z-score window, output smoothing.
03 · Calibration — horizon, favourable-move threshold (×ATR), base-rate window.
04 · Bands — stretch and extreme σ bands; divergence pivot.
05 · Display & Theme — visual style, regime tint, dashboard, colors.


Non-repaint

The implied-vol index is requested with lookahead_off and settles on its bar's close — no future leak.

Concept credit


Variance risk premium and its return predictability — Bakshi & Kapadia (2003); Carr & Wu (2009); Bollerslev, Tauchen & Zhou (2009); Coval & Shumway (2001).


Disclaimer

For research and education only. Not financial advice, not a recommendation, and not a guarantee of future results. A stretched premium does not guarantee reversion — regimes can stay rich or cheap for long stretches. All statistics are in-sample, close-to-close, and exclude costs. Do your own research and manage your own risk.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Market_Logic_India
//@version=6
// ═════════════════════════════════════════════════════════════════════════════════════════════════
//  VARIANCE-RISK-PREMIUM / VOL-OF-VOL OSCILLATOR
// ─────────────────────────────────────────────────────────────────────────────────────────────────
//  OVERVIEW
//    A mean-reverting oscillator measuring the gap between IMPLIED volatility (a volatility index) and
//    REALIZED volatility — the variance risk premium (VRP) — together with a vol-of-vol read. It shows
//    whether option protection is rich (complacency) or cheap (stress).
//
//  WHAT MAKES IT DIFFERENT
//    This is not a volatility FORECASTER. It reads the PRICE of volatility insurance. Implied vol
//    systematically exceeds the volatility that is later realized, so the premium is usually positive;
//    when it stretches high, protection is expensive and the crowd is complacent; when it collapses or
//    goes negative, fear is being paid for and vol is cheap. Distinct from realized-vol bands or ATR.
//
//  HOW IT WORKS
//    Realized vol = annualized standard deviation of log-returns over the chosen window. Implied vol =
//    the volatility index. VRP = Implied − Realized. The VRP series is z-scored over the normalization
//    window into a standard-deviation (σ) oscillator. Vol-of-vol (stdev of the implied index) is tracked
//    as a secondary instability read in the dashboard.
//
//  HOW TO USE
//    Above the upper band = vol RICH / complacency (insurance expensive); below the lower band = vol
//    CHEAP / stress (insurance underpriced). Turns OUT of an extreme (triangles) are the mean-reversion
//    events: a turn up from the cheap zone often coincides with stress easing; a turn down from the rich
//    zone with complacency ending. Read the EDGE row to see whether those turns actually paid.
//
//  UNIVERSAL / SOURCES
//    Implied-vol symbol, realized-vol length, annualization factor and normalization are all inputs.
//    Defaults target NIFTY / India VIX; point the vol symbol at any implied-vol index (VIX, VXN, ...)
//    and set annualization to the bars-per-year of your timeframe for non-daily charts.
//
//  CONCEPT CREDIT (full references in the published description)
//    Variance risk premium and its return predictability — Bakshi & Kapadia (2003); Carr & Wu (2009);
//    Bollerslev, Tauchen & Zhou (2009); Coval & Shumway (2001).
//
//  HONESTY
//    Descriptive. A stretched premium does not guarantee reversion — regimes can stay rich or cheap.
//    Statistics are in-sample, close-to-close, without costs. Read the Edge row.
//
//  DISCLAIMER
//    For research and education only. NOT financial advice, NOT a recommendation, NOT a guarantee of
//    future results. Do your own research and manage your own risk.
//
//  Non-repaint: the implied-vol index is requested with lookahead_off and settles on close.
// ═════════════════════════════════════════════════════════════════════════════════════════════════
indicator("Variance Risk Premium Oscillator", "VRP / Vol-of-Vol", overlay = false, max_labels_count = 500)

// ═════ Z · IDENTITY & EXPORTS ════════════════════════════════════════════════════════════════
gZ = "Z · Identity & exports"
showId  = input.bool(true, "Show identity strip", group = gZ)
showEXP = input.bool(true, "Publish EXP_* outputs (Data Window)", group = gZ, tooltip = "Generic export bus: surfaces in the Data Window and in other scripts via input.source().")
var table idT = table.new(position.bottom_center, 1, 1, force_overlay = true)
if barstate.islast and showId
    bool idDark = (0.299 * color.r(chart.bg_color) + 0.587 * color.g(chart.bg_color) + 0.114 * color.b(chart.bg_color)) < 140
    table.cell(idT, 0, 0, "VRP / VOL-OF-VOL · " + syminfo.ticker + " · " + timeframe.period, text_size = size.tiny, text_color = idDark ? color.white : color.black, bgcolor = color.new(idDark ? color.black : color.white, 15))

// ─── 01 · DATA & VOLATILITY ────────────────────────────────────────────────────────────────────
g1 = "01 · Data & Volatility"
vixSym  = input.symbol("NSE:INDIAVIX", "Implied-Vol Index", group = g1, tooltip = "Implied-volatility index (e.g. INDIAVIX, VIX, VXN). Change for other markets.")
rvLen   = input.int(20,  "Realized-Vol Length", minval = 5, group = g1, tooltip = "Window of log-returns for realized volatility.")
annual  = input.float(252.0, "Annualization (bars/yr)", minval = 1, group = g1, tooltip = "252 for daily. Intraday: bars-per-year of your timeframe (e.g. 252×75 for 5m NIFTY).")
vovLen  = input.int(20,  "Vol-of-Vol Length", minval = 5, group = g1)
srcPrice= input.source(close, "Price Source (for Edge/divergence)", group = g1)

// ─── 02 · NORMALIZATION ────────────────────────────────────────────────────────────────────────
g2 = "02 · Normalization"
normLen  = input.int(100, "Z-Score Window",   minval = 20, group = g2)
smoothLen= input.int(3,   "Output Smoothing", minval = 1,  group = g2)

// ─── 03 · CALIBRATION (Hit / Base / EDGE) ──────────────────────────────────────────────────────
g3 = "03 · Calibration Harness"
calcCal = input.bool(true, "Measure Edge",          group = g3, tooltip = "After a cheap-vol turn did price rally; after a rich-vol turn did it fade?")
calH    = input.int(10,  "Horizon (bars)",          minval = 1, group = g3)
calK    = input.float(1.0,"Favourable move (×ATR)", minval = 0.1, step = 0.1, group = g3)
calWin  = input.int(500, "Base-rate window",        minval = 50, group = g3)

// ─── 04 · BANDS ────────────────────────────────────────────────────────────────────────────────
g4 = "04 · Bands"
obSigma  = input.float(1.5, "Stretch Band (σ)", minval = 0.5, step = 0.1, group = g4)
extSigma = input.float(2.5, "Extreme Band (σ)", minval = 0.5, step = 0.1, group = g4)
showDiv  = input.bool(true, "Show Divergences", group = g4)
divLb    = input.int(5, "Divergence Pivot", minval = 2, group = g4)

// ─── 05 · DISPLAY & THEME ──────────────────────────────────────────────────────────────────────
g5 = "05 · Display & Theme"
vizStyle = input.string("Gradient area + glow", "Visual style", options = ["Gradient area + glow", "Histogram", "Line"], group = g5)
showRegime = input.bool(true, "Background regime tint", group = g5)
showDash   = input.bool(true, "Show Dashboard",         group = g5)
bullCol  = input.color(#2ebd85, "Cheap / Bounce", group = g5)
bearCol  = input.color(#f6465d, "Rich / Fade",    group = g5)
midCol   = input.color(#f7c948, "Midline Glow",   group = g5)
upperBandCol = input.color(#f6465d, "Upper Band (rich)",  group = g5, tooltip = "Top extreme zone — red (vol expensive / complacency).")
lowerBandCol = input.color(#2ebd85, "Lower Band (cheap)", group = g5, tooltip = "Bottom extreme zone — green (vol cheap / stress).")

// ─── HELPERS ──────────────────────────────────────────────────────────────────────────────────
f_z(float v, float m, float s) => s > 0 ? (v - m) / s : 0.0
// ─── Wilson interval (significance of the Edge) ───────────────────────────────────────────────
f_wilson(float w, float n, float zc) =>
    if n <= 0
        na
    else
        float p = w / n
        float z2 = zc * zc
        float c = (p + z2 / (2.0 * n)) / (1.0 + z2 / n)
        float hw = (zc * math.sqrt(p * (1.0 - p) / n + z2 / (4.0 * n * n))) / (1.0 + z2 / n)
        hw

// ─── VOL ENGINE ───────────────────────────────────────────────────────────────────────────────
iv  = request.security(vixSym, timeframe.period, close, lookahead = barmerge.lookahead_off)
ret = math.log(close / close[1])
rv  = ta.stdev(ret, rvLen) * math.sqrt(annual) * 100.0
vrp = iv - rv
vov = ta.stdev(iv, vovLen)
// per-topic: downside / upside realized-vol decomposition (semivariance split)
float retNeg = math.min(ret, 0.0)
float retPos = math.max(ret, 0.0)
float dnVar  = ta.sma(retNeg * retNeg, rvLen)
float upVar  = ta.sma(retPos * retPos, rvLen)
float rvDn   = math.sqrt(dnVar * annual) * 100.0 * math.sqrt(2.0)
float rvUp   = math.sqrt(upVar * annual) * 100.0 * math.sqrt(2.0)
float vrpDn  = iv - rvDn
float vrpUp  = iv - rvUp
float dnShare= (dnVar + upVar) > 0 ? dnVar / (dnVar + upVar) * 100.0 : na

// positive = vol RICH (complacency); negative = vol CHEAP (stress)
osc = ta.ema(f_z(vrp, ta.sma(vrp, normLen), ta.stdev(vrp, normLen)), smoothLen)

// ─── DIVERGENCE ───────────────────────────────────────────────────────────────────────────────
ph = ta.pivothigh(osc, divLb, divLb)
pl = ta.pivotlow(osc, divLb, divLb)
var float pOscH = na, var float pOscL = na, var float pPrcH = na, var float pPrcL = na
bool bullDiv = false, bool bearDiv = false
if not na(pl)
    float pr = low[divLb]
    if not na(pOscL)
        bullDiv := pl > pOscL and pr < pPrcL
    pOscL := pl
    pPrcL := pr
if not na(ph)
    float pr = high[divLb]
    if not na(pOscH)
        bearDiv := ph < pOscH and pr > pPrcH
    pOscH := ph
    pPrcH := pr

// ─── MEAN-REVERSION SIGNALS ───────────────────────────────────────────────────────────────────
cheapRev = ta.crossover(osc, -obSigma)   // turning up from cheap/stress  -> expect price up
richRev  = ta.crossunder(osc,  obSigma)  // turning down from rich/complacency -> expect price down
var int lastSigBar = na
var int lastSigDir = 0
if cheapRev
    lastSigBar := bar_index
    lastSigDir := 1
if richRev
    lastSigBar := bar_index
    lastSigDir := -1

// ─── CALIBRATION HARNESS (na-safe) ─────────────────────────────────────────────────────────────
atr    = ta.atr(14)
upEvt  = srcPrice >= srcPrice[calH] + calK * atr[calH]
dnEvt  = srcPrice <= srcPrice[calH] - calK * atr[calH]
baseUp = ta.sma(upEvt ? 1.0 : 0.0, calWin) * 100.0
baseDn = ta.sma(dnEvt ? 1.0 : 0.0, calWin) * 100.0

var int[]   cBar  = array.new_int()
var int[]   cDir  = array.new_int()
var float[] cEnt  = array.new_float()
var float[] cAtr  = array.new_float()
var float[] cBase = array.new_float()
var int hits = 0, var int tot = 0, var int baseN = 0
var float sumBase = 0.0
var int rtRuns = 0
var int rtLast = -1
var int rtN = 0
var int rtN1 = 0
var int rtN0 = 0

if calcCal and cheapRev and not na(baseUp)
    cBar.push(bar_index), cDir.push(1),  cEnt.push(srcPrice), cAtr.push(atr), cBase.push(baseUp)
if calcCal and richRev and not na(baseDn)
    cBar.push(bar_index), cDir.push(-1), cEnt.push(srcPrice), cAtr.push(atr), cBase.push(baseDn)

if cBar.size() > 0
    for i = cBar.size() - 1 to 0
        if bar_index - cBar.get(i) >= calH
            int d = cDir.get(i)
            float fav = d == 1 ? srcPrice - cEnt.get(i) : cEnt.get(i) - srcPrice
            if fav >= calK * cAtr.get(i)
                hits += 1
            tot += 1
            int rtO = fav >= calK * cAtr.get(i) ? 1 : 0
            if rtN > 0 and rtO != rtLast
                rtRuns += 1
            rtLast := rtO
            rtN += 1
            if rtO == 1
                rtN1 += 1
            else
                rtN0 += 1
            float b = cBase.get(i)
            if not na(b)
                sumBase += b
                baseN += 1
            cBar.remove(i), cDir.remove(i), cEnt.remove(i), cAtr.remove(i), cBase.remove(i)

float hitPct  = tot   > 0 ? hits / tot * 100.0 : na
float basePct = baseN > 0 ? sumBase / baseN     : na
float edge    = not na(hitPct) and not na(basePct) ? hitPct - basePct : na

// ─── Wilson significance + edge-floor + runs-test ────────────────────────────────────────────
float ciPct  = f_wilson(hits, tot, 1.96) * 100.0
bool  sigStar = not na(ciPct) and not na(edge) and (edge - ciPct) > 0
float edgeLB = not na(hitPct) and not na(ciPct) and not na(basePct) ? (hitPct - ciPct) - basePct : na
float rtMu  = rtN > 1 ? 2.0 * rtN1 * rtN0 / rtN + 1.0 : na
float rtVar = rtN > 1 ? 2.0 * rtN1 * rtN0 * (2.0 * rtN1 * rtN0 - rtN) / (rtN * rtN * (rtN - 1.0)) : na
float runsZ = not na(rtVar) and rtVar > 0 ? (rtRuns - rtMu) / math.sqrt(rtVar) : na

// ─── RENDER STYLE ──────────────────────────────────────────────────────────────────────────────
isGrad = vizStyle == "Gradient area + glow"
isHist = vizStyle == "Histogram"
oscCol = color.from_gradient(osc, -extSigma, extSigma, bullCol, bearCol)   // cheap(green) -> rich(red)
float intensity = math.min(math.abs(osc) / math.max(extSigma, 0.0001), 1.0)

bgcolor(showRegime and osc >= extSigma ? color.new(bearCol, 90) : showRegime and osc <= -extSigma ? color.new(bullCol, 90) : na, title = "Regime tint")

hline(0, "Fair", color.new(chart.fg_color, 70))
pUpLean = plot(obSigma,   "Upper Lean Line",    color.new(upperBandCol, 55), 1, display = display.pane, editable = false)
pUpExt  = plot(extSigma,  "Upper Extreme Line", color.new(upperBandCol, 70), 1, display = display.pane, editable = false)
pDnLean = plot(-obSigma,  "Lower Lean Line",    color.new(lowerBandCol, 55), 1, display = display.pane, editable = false)
pDnExt  = plot(-extSigma, "Lower Extreme Line", color.new(lowerBandCol, 70), 1, display = display.pane, editable = false)
fill(pUpExt, pUpLean,  extSigma,  obSigma,  color.new(upperBandCol, 55), color.new(upperBandCol, 90), title = "Upper Band (rich)")
fill(pDnLean, pDnExt, -obSigma, -extSigma, color.new(lowerBandCol, 90), color.new(lowerBandCol, 55), title = "Lower Band (cheap)")

plot(0, "Midline glow", color.new(midCol, 80), 3, display = display.pane)
plot(0, "Midline",      color.new(midCol, 45), 1, display = display.pane)

mid = plot(0, "base", display = display.none, editable = false)
op  = plot(isGrad ? osc : na, "area", display = display.none, editable = false)
fill(op, mid, color.new(oscCol, 92 - int(intensity * 55)), title = "Gradient area")

plot(isHist ? osc : na, "Histogram", color.new(oscCol, 35), style = plot.style_columns)

plot(not isHist ? osc : na, "glow outer", color.new(oscCol, 88), 6, display = display.pane)
plot(not isHist ? osc : na, "glow inner", color.new(oscCol, 70), 3, display = display.pane)
plot(not isHist ? osc : na, "VRP", oscCol, 2)

plotshape(cheapRev, "Cheap Reversal", shape.triangleup,   location.bottom, bullCol, size = size.tiny)
plotshape(richRev,  "Rich Reversal",  shape.triangledown, location.top,    bearCol, size = size.tiny)
plotshape(showDiv and bullDiv ? osc[divLb] : na, "Bull Div", shape.circle, location.absolute, bullCol, -divLb, size = size.tiny)
plotshape(showDiv and bearDiv ? osc[divLb] : na, "Bear Div", shape.circle, location.absolute, bearCol, -divLb, size = size.tiny)

// ─── DASHBOARD (theme-adaptive, zebra) ─────────────────────────────────────────────────────────
f_row(int r) => color.new(chart.fg_color, r % 2 == 0 ? 92 : 96)
var table dash = table.new(position.top_right, 2, 11, frame_color = color.new(chart.fg_color, 60), frame_width = 1, border_color = color.new(chart.fg_color, 80), border_width = 1)
if barstate.islast and showDash
    string zone = osc >= extSigma ? "Vol Rich +" : osc >= obSigma ? "Rich" : osc <= -extSigma ? "Vol Cheap -" : osc <= -obSigma ? "Cheap" : "Fair"
    color  zc   = osc >= obSigma ? bearCol : osc <= -obSigma ? bullCol : color.new(chart.fg_color, 25)
    string sigTxt = na(lastSigBar) ? "—" : (lastSigDir == 1 ? "Cheap " : "Rich ") + str.tostring(bar_index - lastSigBar) + "b"
    table.cell(dash, 0, 0, "VARIANCE RISK PREMIUM", text_color = chart.bg_color, bgcolor = zc, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 0, zone, text_color = chart.bg_color, bgcolor = zc, text_size = size.tiny)
    table.cell(dash, 0, 1, "Value (σ)", text_color = chart.fg_color, bgcolor = f_row(1), text_halign = text.align_left, text_size = size.tiny)
    table.cell(dash, 1, 1, str.tostring(osc, "#.##"), text_color = zc, bgcolor = f_row(1), text_size = size.tiny)
    table.cell(dash, 0, 2, "Implied Vol", text_color = chart.fg_color, bgcolor = f_row(2), text_halign = text.align_left, text_size = size.tiny)
    table.cell(dash, 1, 2, str.tostring(iv, "#.##"), text_color = chart.fg_color, bgcolor = f_row(2), text_size = size.tiny)
    table.cell(dash, 0, 3, "Realized Vol", text_color = chart.fg_color, bgcolor = f_row(3), text_halign = text.align_left, text_size = size.tiny)
    table.cell(dash, 1, 3, str.tostring(rv, "#.##"), text_color = chart.fg_color, bgcolor = f_row(3), text_size = size.tiny)
    table.cell(dash, 0, 4, "VRP (IV−RV)", text_color = chart.fg_color, bgcolor = f_row(4), text_halign = text.align_left, text_size = size.tiny)
    table.cell(dash, 1, 4, str.tostring(vrp, "#.##"), text_color = vrp >= 0 ? bearCol : bullCol, bgcolor = f_row(4), text_size = size.tiny)
    table.cell(dash, 0, 5, "Vol-of-Vol", text_color = chart.fg_color, bgcolor = f_row(5), text_halign = text.align_left, text_size = size.tiny)
    table.cell(dash, 1, 5, str.tostring(vov, "#.##"), text_color = chart.fg_color, bgcolor = f_row(5), text_size = size.tiny)
    table.cell(dash, 0, 6, "Hit %", text_color = chart.fg_color, bgcolor = f_row(6), text_halign = text.align_left, text_size = size.tiny)
    table.cell(dash, 1, 6, na(hitPct) ? "—" : str.tostring(hitPct, "#.#") + "%", text_color = chart.fg_color, bgcolor = f_row(6), text_size = size.tiny)
    table.cell(dash, 0, 7, "Base %", text_color = chart.fg_color, bgcolor = f_row(7), text_halign = text.align_left, text_size = size.tiny)
    table.cell(dash, 1, 7, na(basePct) ? "—" : str.tostring(basePct, "#.#") + "%", text_color = color.new(chart.fg_color, 30), bgcolor = f_row(7), text_size = size.tiny)
    table.cell(dash, 0, 8, "EDGE", text_color = chart.fg_color, bgcolor = f_row(8), text_halign = text.align_left, text_size = size.tiny)
    table.cell(dash, 1, 8, na(edge) ? "—" : (edge >= 0 ? "+" : "") + str.tostring(edge, "#.#") + "%", text_color = chart.bg_color, bgcolor = na(edge) ? f_row(8) : (edge > 0 ? bullCol : bearCol), text_size = size.tiny)
    table.cell(dash, 0, 9, "Down VRP", text_color = chart.fg_color, bgcolor = f_row(9), text_halign = text.align_left, text_size = size.tiny)
    table.cell(dash, 1, 9, na(vrpDn) ? "—" : str.tostring(vrpDn, "#.##"), text_color = chart.fg_color, bgcolor = f_row(9), text_size = size.tiny)
    table.cell(dash, 0, 10, "Edge floor", text_color = chart.fg_color, bgcolor = f_row(10), text_halign = text.align_left, text_size = size.tiny)
    table.cell(dash, 1, 10, na(edgeLB) ? "—" : (sigStar ? "★ " : "") + (edgeLB >= 0 ? "+" : "") + str.tostring(edgeLB, "#.#") + "%", text_color = chart.bg_color, bgcolor = na(edgeLB) ? f_row(10) : (edgeLB > 0 ? bullCol : bearCol), text_size = size.tiny)

// ─── EXP_* EXPORT BUS (generic; Data Window) ─────────────────────────────────────────────────
plot(showEXP ? osc    : na, "EXP_Bias",    color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? vrp    : na, "EXP_VRP",     color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? vrpDn  : na, "EXP_DownVRP", color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? vrpUp  : na, "EXP_UpVRP",   color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? dnShare: na, "EXP_DownShare",color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? vov    : na, "EXP_VoV",     color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? edge   : na, "EXP_Edge",    color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? edgeLB : na, "EXP_EdgeLB",  color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? runsZ  : na, "EXP_RunsZ",   color = color.new(color.gray, 100), display = display.data_window)

// ─── ALERTS ───────────────────────────────────────────────────────────────────────────────────
alertcondition(cheapRev, "Vol-cheap reversal", "VRP turning up from the cheap/stress extreme")
alertcondition(richRev,  "Vol-rich reversal",  "VRP turning down from the rich/complacency extreme")
````
