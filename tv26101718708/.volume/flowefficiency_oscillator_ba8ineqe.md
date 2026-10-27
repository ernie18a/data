# Flow-Efficiency Oscillator

- url: https://www.tradingview.com/script/Ba8INEqE-Flow-Efficiency-Oscillator/
- type: indicator
- pine_id: PUB;607a8e9ea5e7479aad222819fd0cb42f
- version: 2.0

## Description

Flow-Efficiency Oscillator

Overview

How much order flow did it cost to move price one tick? It measures signed volume (delta) consumed per tick of travel, then percentile-ranks that cost into a 0–100 read. High = expensive / heavy (lots of delta, little movement — the signature of absorption). Low = cheap / efficient (little delta, large movement — thin, frictionless travel). A study of effort-versus-result in the tape — not a directional signal.

Why these parts are ONE tool (mashup rationale)

A CVD line shows net flow; a volume study shows size; neither expresses the exchange rate between flow and price — and that ratio is where absorption hides. This chains: lower-timeframe delta reconstructs intrabar effort → a cost ratio divides effort by tick travel → percentile ranking makes it universal (0–100) → an absorption flag fires only when cost is high and flow leaned hard one way yet price stalled → the harness tests whether price then moves against the absorbed aggressor. Effort alone is just volume; the ratio without ranking isn't comparable; the flag without calibration is folklore.

How it works

Inside each bar, lower-timeframe bars are signed by the tick rule and summed into a bar delta; their absolute volume is total aggression. Cost = |delta| / max(tick travel, floor), smoothed, then percentile-ranked over a lookback (50 = median cost). Absorption arms when cost is in the high band while net delta is strongly one-sided. The harness logs each event and checks a ≥ k×ATR move against the aggressor a fixed horizon later.

How to use

High band (above the upper guide) = absorption / heavy tape, where a strong push is being eaten and reversals have context; low band = efficient tape, where moves travel freely and continuation is favoured. The absorption dots mark high-cost, one-sided stalls. Then read the Edge row. Context, never a standalone trigger.

Originality

CVD and the tick rule are public; the original work is the cost-per-tick exchange rate, its percentile normalisation, the absorption logic, and the forward calibration of absorption→reversal. No third-party code is reused.

Concept credit

Tick-rule trade sign — Lee & Ready (1991). Flow-toxicity / cost-of-trading framing draws on Easley, López de Prado & O'Hara. The ratio, percentile read and harness are this script's own.

Honesty / limitations

The buy/sell split is a tick-rule estimate from lower-timeframe bars, not true bid/ask data — delta is approximate. This is an intraday tool: it needs a timeframe below the chart's, warms up slowly, and is heavier than a single-series oscillator; on daily+ or volume-less feeds the read degrades. Edge figures are in-sample, no costs — context, not a backtest.

Disclaimer

Research / educational only. NOT financial advice; no guarantee of profitability. Trading carries risk of loss. Test out-of-sample. The author accepts no liability.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
// ══════════════════════════════════════════════════════════════════════════════════════════════
// © Market_Logic_India                                                       MPL-2.0
// FLOW-EFFICIENCY OSCILLATOR                                                              v1.0
// ────────────────────────────────────────────────────────────────────────────────────────────
// OVERVIEW
//   How much order flow did it cost to move price one tick? This oscillator measures the signed
//   volume (delta) consumed per tick of price travel, then percentile-ranks that cost against its
//   own recent history into a 0-100 read. HIGH = expensive / heavy: lots of delta, little price
//   movement - the signature of ABSORPTION. LOW = cheap / efficient: little delta, large movement
//   - thin, frictionless travel. It is an analytical study of effort-versus-result in the tape -
//   not a directional signal and not a strategy.
//
// WHAT MAKES IT DIFFERENT  (why these parts are ONE tool, not three studies)
//   A CVD line tells you net flow; a volume study tells you size; neither tells you the EXCHANGE
//   RATE between flow and price - and that ratio is where absorption hides. The parts chain to
//   make it readable and testable:
//     - LOWER-TIMEFRAME DELTA reconstructs signed flow inside each bar (the raw effort), more
//       faithfully than a single bar's volume.
//     - THE COST RATIO divides that effort by the tick travel it produced - the exchange rate a
//       plain CVD or volume plot can't express.
//     - PERCENTILE RANKING turns an instrument-specific raw number into a universal 0-100 read,
//       so "expensive" means the same thing on any symbol.
//     - AN ABSORPTION FLAG fires only when cost is high AND flow leaned hard one way yet price
//       stalled - i.e. the aggressor was absorbed - turning the ratio into a located event.
//     - THE CALIBRATION HARNESS then tests, on YOUR instrument, whether price subsequently moves
//       AGAINST the absorbed aggressor - reporting Edge vs the unconditional base rate.
//   Effort alone is just volume; the ratio without ranking isn't comparable; the flag without
//   calibration is folklore. Chained, they answer one question: was this move cheap or absorbed,
//   and has absorption reversed price before on this symbol?
//
// HOW IT WORKS
//   1. Inside each chart bar, lower-timeframe bars are signed by the tick rule (up-tick volume
//      positive, down-tick negative) and summed into a bar DELTA; their absolute volume is the
//      bar's total aggression.
//   2. COST = |delta| / max(tick travel, floor). It is smoothed, then percentile-ranked over a
//      lookback to produce the 0-100 oscillator (50 = median cost).
//   3. ABSORPTION arms when cost sits in the high band while net delta is strongly one-sided.
//   4. The harness logs each absorption event and checks a >= k x ATR move AGAINST the aggressor a
//      fixed horizon later.
//
// HOW TO USE
//   Read the band: high (above the upper guide) = absorption / heavy tape, where a strong push is
//   being eaten and reversals have the most context; low (below the lower guide) = efficient tape,
//   where moves travel freely and continuation is favoured; mid = ordinary cost. The absorption
//   dots mark high-cost, one-sided stalls. Then read the Edge row - an absorption read only earns
//   its keep if fades after it beat the base rate. Context, never a standalone trigger.
//
// UNIVERSAL ACROSS MARKETS  (configurable data source)
//   Runs on any instrument that has volume and supports an intrabar timeframe. Defaults target
//   intraday index futures (e.g. NSE NIFTY). NOTE: this is an INTRADAY tool - it needs a lower
//   timeframe below the chart's, and is heavier than a single-series oscillator. On daily+ charts
//   or volume-less feeds the read degrades.
//
// CONCEPT CREDIT
//   Cumulative Volume Delta and the tick-rule trade sign - market-microstructure tradition (Lee &
//   Ready, 1991, for the trade-classification idea). Flow-toxicity / cost-of-trading framing draws
//   on the order-flow literature of Easley, Lopez de Prado & O'Hara. The cost-per-tick ratio, the
//   percentile read and the calibration harness are this script's own work. No third-party code is
//   reused; not affiliated with, nor endorsed by, any third party.
//
// HONESTY / LIMITATIONS
//   The buy/sell split is a tick-rule ESTIMATE from lower-timeframe bars, not true bid/ask trade
//   data, so delta is approximate. Lower-timeframe history is limited, so the read warms up and
//   may be unavailable far back. The Edge figures are in-sample, close-to-close, with overlapping
//   forward windows and no costs - descriptive context, not a verified backtest. Nothing here
//   predicts direction on its own.
//
// DISCLAIMER
//   Research and educational tool only. NOT financial advice and NO guarantee of profitability or
//   accuracy. Indicators describe past behaviour; they do not predict the future. Trading carries
//   risk of loss. Test out-of-sample and make your own decisions. The author accepts no liability.
// ══════════════════════════════════════════════════════════════════════════════════════════════
indicator("Flow-Efficiency Oscillator", "FlowEff", overlay = false, max_labels_count = 120, dynamic_requests = true)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                          INPUTS
// ═════════════════════════════════════════════════════════════════════════════════════════
// ── 01 · DATA & SOURCE ──────────────────────────────────────────────────────────────────
g0 = "01 · Data & source"
ltf = input.timeframe("1", "Intrabar timeframe", group = g0, tooltip = "Lower timeframe used to reconstruct signed delta inside each chart bar. Must be below the chart timeframe. 1 minute suits intraday charts.")

// ── 02 · FLOW EFFICIENCY ────────────────────────────────────────────────────────────────
g1 = "02 · Flow efficiency"
costSmooth = input.int(3, "Cost smoothing (EMA)", minval = 1, maxval = 50, group = g1, tooltip = "Smooths the raw cost-per-tick before ranking. Higher = steadier.")
pctLen = input.int(200, "Percentile lookback", minval = 30, maxval = 1000, group = g1, tooltip = "Window the cost is ranked against to produce the 0-100 read.")
tickFloor = input.float(1.0, "Tick-travel floor", minval = 0.1, step = 0.1, group = g1, tooltip = "Minimum tick travel used in the ratio, so tiny-range bars don't make cost explode.")

// ── 03 · ABSORPTION SIGNAL ──────────────────────────────────────────────────────────────
g2 = "03 · Absorption signal"
hiThr = input.int(80, "Absorption above (cost %)", minval = 50, maxval = 100, group = g2)
loThr = input.int(20, "Efficient below (cost %)", minval = 0, maxval = 50, group = g2)
deltaThr = input.float(0.55, "One-sided delta (share)", minval = 0.5, maxval = 1.0, step = 0.01, group = g2, tooltip = "Net delta must be at least this share of the bar's total aggression for the flow to count as one-sided.")
showAbs = input.bool(true, "Mark absorption events", group = g2)

// ── 04 · CALIBRATION HARNESS ────────────────────────────────────────────────────────────
g4 = "04 · Calibration harness"
calibOn = input.bool(true, "Run calibration", group = g4, tooltip = "Logs every absorption event and, a fixed horizon later, checks whether price moved >= k x ATR AGAINST the absorbed aggressor. Reports Hit %, unconditional Base %, and Edge = Hit - Base.")
calHor  = input.int(10, "Forward horizon (bars)", minval = 2, maxval = 100, group = g4)
calMove = input.float(0.6, "Move threshold (x ATR)", minval = 0.1, step = 0.1, group = g4)
calAtrLen = input.int(14, "ATR length", minval = 1, group = g4)

// ── 05 · VISUAL STYLE ───────────────────────────────────────────────────────────────────
g5 = "05 · Visual style"
visStyle = input.string("Gradient area + glow", "Line style", options = ["Gradient area + glow","Histogram","Line"], group = g5)
colEff   = input.color(#2ebd85, "Efficient", inline = "cc", group = g5)
colAbs   = input.color(#f6465d, "Absorption", inline = "cc", group = g5)
colMid   = input.color(#f7c948, "Midline", group = g5)

// ── 06 · DASHBOARD & THEME ──────────────────────────────────────────────────────────────
g6 = "06 · Dashboard & theme"
showPanel = input.bool(true, "Show dashboard", group = g6)
panelPos  = input.string("Bottom Right", "Dashboard position", options = ["Bottom Left","Bottom Right","Top Left","Top Right","Middle Right"], group = g6)
themeOpt  = input.string("Auto (match chart)", "Theme", options = ["Auto (match chart)","Dark","Light"], group = g6)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                          ENGINE · lower-timeframe delta & cost
// ═════════════════════════════════════════════════════════════════════════════════════════
[arrSigned, arrVol] = request.security_lower_tf(syminfo.tickerid, ltf, [volume * math.sign(close - close[1]), volume])

float barDelta = 0.0
float barAgg = 0.0
if not na(arrSigned) and array.size(arrSigned) > 0
    for v in arrSigned
        barDelta += nz(v)
if not na(arrVol) and array.size(arrVol) > 0
    for v in arrVol
        barAgg += nz(v)
// fallback to chart volume if no intrabar data
if barAgg == 0 and volume > 0
    barDelta := volume * math.sign(close - close[1])
    barAgg := volume

float tickMove = math.max(tickFloor, math.abs(close - close[1]) / syminfo.mintick)
float costRaw = math.abs(barDelta) / tickMove
float costS = ta.ema(costRaw, costSmooth)
float costPct = ta.percentrank(costS, pctLen)

// ===== Price-impact slope (Kyle 1985 lambda) + order-flow imbalance (Cont-Kukanov-Stoikov) =====
lamLen = input.int(50, "Price-impact (lambda) window", minval = 10, group = "Z2 · Advanced calibration")
float dPx = close - close[1]
float lamCorr = ta.correlation(dPx, barDelta, lamLen)
float sdP = ta.stdev(dPx, lamLen)
float sdD = ta.stdev(barDelta, lamLen)
float lamSlope = na(lamCorr) ? na : lamCorr * sdP / math.max(sdD, 1e-9)
float lamR2 = na(lamCorr) ? na : lamCorr * lamCorr

float deltaShare = barAgg > 0 ? barDelta / barAgg : 0.0
bool oneSidedBuy  = deltaShare >=  deltaThr
bool oneSidedSell = deltaShare <= -deltaThr

bool absHigh = costPct >= hiThr
// buyers spent heavily yet price did not follow through -> absorbed offer -> down bias
bool absShort = absHigh and oneSidedBuy
// sellers spent heavily yet price held -> absorbed bid -> up bias
bool absLong  = absHigh and oneSidedSell

string state = na(costPct) ? "n/a" : costPct >= hiThr ? "absorption" : costPct <= loThr ? "efficient" : "normal"

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                          PLOTS
// ═════════════════════════════════════════════════════════════════════════════════════════
plot(50.0, "Mid glow", color = color.new(colMid, 80), linewidth = 6, display = display.pane)
hline(50, "Median cost", color = color.new(colMid, 0), linestyle = hline.style_solid)
hline(hiThr, "Absorption", color = color.new(colAbs, 55), linestyle = hline.style_dotted)
hline(loThr, "Efficient", color = color.new(colEff, 55), linestyle = hline.style_dotted)
hline(100, "Max", color = color.new(colAbs, 75), linestyle = hline.style_dashed)
hline(0, "Min", color = color.new(colEff, 75), linestyle = hline.style_dashed)

pAbsEdge = plot(float(hiThr), "z abs edge", color = na, display = display.none, editable = false)
pTop     = plot(100.0,        "z top",      color = na, display = display.none, editable = false)
pEffEdge = plot(float(loThr), "z eff edge", color = na, display = display.none, editable = false)
pBot     = plot(0.0,          "z bot",      color = na, display = display.none, editable = false)
fill(pAbsEdge, pTop, 100.0, float(hiThr), color.new(colAbs, 32), color.new(colAbs, 90), title = "Absorption zone")
fill(pEffEdge, pBot, float(loThr), 0.0, color.new(colEff, 90), color.new(colEff, 32), title = "Efficient zone")

color oCol = na(costPct) ? color.gray : costPct >= 50 ? colAbs : colEff
bool isArea = visStyle == "Gradient area + glow"
bool isHist = visStyle == "Histogram"
bool isLine = visStyle == "Line"
bool showLine = isArea or isLine
plot(showLine ? costPct : na, "glow outer", color = color.new(oCol, 82), linewidth = 8, display = display.pane)
plot(showLine ? costPct : na, "glow inner", color = color.new(oCol, 55), linewidth = 4, display = display.pane)
pMain = plot(showLine ? costPct : na, "Cost percentile", color = oCol, linewidth = 2, display = display.pane)
plot(isHist ? costPct : na, "Histogram", color = color.new(oCol, 25), style = plot.style_columns, display = display.pane)
pBase = plot(isArea ? 50.0 : na, "area base", color = na, display = display.none, editable = false)
fill(pMain, pBase, color = isArea ? color.new(oCol, 80) : na, title = "Area")

plotshape(showAbs and absShort ? costPct : na, "Absorbed offer", shape.triangledown, location.absolute, color.new(colAbs, 0), size = size.tiny)
plotshape(showAbs and absLong  ? costPct : na, "Absorbed bid",   shape.triangleup,   location.absolute, color.new(colEff, 0), size = size.tiny)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                       CALIBRATION
// ═════════════════════════════════════════════════════════════════════════════════════════
float atrC = ta.atr(calAtrLen)
var int sigN = 0
var int hitN = 0
var int baseTot = 0
var int baseUp = 0
var int baseDn = 0
float fwdMv  = close - close[calHor]
float fwdAtr = atrC[calHor]
if calibOn and barstate.isconfirmed and bar_index > calHor and not na(fwdAtr) and fwdAtr > 0
    if absLong[calHor]
        sigN += 1
        if fwdMv >= calMove * fwdAtr
            hitN += 1
    if absShort[calHor]
        sigN += 1
        if -fwdMv >= calMove * fwdAtr
            hitN += 1
    baseTot += 1
    if fwdMv >= calMove * fwdAtr
        baseUp += 1
    if -fwdMv >= calMove * fwdAtr
        baseDn += 1

float hitP  = sigN > 0 ? hitN * 100.0 / sigN : na
float baseP = baseTot > 0 ? (baseUp + baseDn) * 100.0 / (2.0 * baseTot) : na
float edge  = (not na(hitP) and not na(baseP)) ? hitP - baseP : na

// ===== FORWARD-STATISTICS UPGRADE  (Wilson interval + significance) =====
f_wilson(float w, float n, float zc) =>
    float r = na
    if n > 0.0
        float pp = w / n
        float den = 1.0 + zc * zc / n
        r := zc * math.sqrt(pp * (1.0 - pp) / n + zc * zc / (4.0 * n * n)) / den
    r
float ciPct   = f_wilson(hitN, sigN, 1.96) * 100.0
bool  sigStar = sigN >= 20 and not na(hitP) and not na(baseP) and (hitP - ciPct) > baseP

// ===== CUSUM event-sampling + Wald-Wolfowitz runs-test + Wilson edge floor =====
cusumK = input.float(1.0, "CUSUM event threshold (x ATR)", minval = 0.1, step = 0.1, group = "Z2 · Advanced calibration")
var float csPos = 0.0
var float csNeg = 0.0
float csRet = close - close[1]
csPos := math.max(0.0, csPos + csRet)
csNeg := math.min(0.0, csNeg + csRet)
bool cusumEvt = not na(atrC) and atrC > 0 and (csPos >= cusumK * atrC or csNeg <= -cusumK * atrC)
if cusumEvt
    csPos := 0.0
    csNeg := 0.0
var array<int>   rtDir  = array.new<int>()
var array<int>   rtBar  = array.new<int>()
var array<float> rtEnt  = array.new<float>()
var array<float> rtAtr0 = array.new<float>()
var int rtPrev = 0
var int rtRuns = 0
var int rtW = 0
var int rtL = 0
if calibOn and barstate.isconfirmed and not na(atrC) and atrC > 0
    if cusumEvt and (absLong)
        rtDir.push(1), rtBar.push(bar_index), rtEnt.push(close), rtAtr0.push(atrC)
    if cusumEvt and (absShort)
        rtDir.push(-1), rtBar.push(bar_index), rtEnt.push(close), rtAtr0.push(atrC)
    if rtBar.size() > 0
        for i = rtBar.size() - 1 to 0
            if bar_index - rtBar.get(i) >= calHor
                float fwd = (close - rtEnt.get(i)) * rtDir.get(i)
                int wlab = fwd >= calMove * rtAtr0.get(i) ? 1 : -1
                rtRuns := rtPrev == 0 ? 1 : (wlab != rtPrev ? rtRuns + 1 : rtRuns)
                rtPrev := wlab
                rtW := wlab == 1 ? rtW + 1 : rtW
                rtL := wlab == -1 ? rtL + 1 : rtL
                rtDir.remove(i), rtBar.remove(i), rtEnt.remove(i), rtAtr0.remove(i)
float rtNn = rtW + rtL
float rtMu = rtNn > 0 ? 2.0 * rtW * rtL / rtNn + 1.0 : na
float rtVr = rtNn > 1 ? 2.0 * rtW * rtL * (2.0 * rtW * rtL - rtNn) / (rtNn * rtNn * (rtNn - 1.0)) : na
float runsZ = (not na(rtMu) and not na(rtVr) and rtVr > 0) ? (rtRuns - rtMu) / math.sqrt(rtVr) : na
float edgeLB = (not na(hitP) and not na(baseP) and not na(ciPct)) ? (hitP - ciPct) - baseP : na

// ═════════════════════════════════════════════════════════════════════════════════════════
//                              DASHBOARD  (theme-adaptive zebra)
// ═════════════════════════════════════════════════════════════════════════════════════════
f_lum(color cc) => na(cc) ? 0.0 : (0.299 * color.r(cc) + 0.587 * color.g(cc) + 0.114 * color.b(cc))
bool darkUI = themeOpt == "Dark" ? true : themeOpt == "Light" ? false : f_lum(chart.bg_color) < 140
color panelBg = darkUI ? color.rgb(17, 22, 28)    : color.rgb(244, 246, 248)
color rowAlt  = darkUI ? color.rgb(25, 31, 39)    : color.rgb(232, 236, 240)
color txtMain = darkUI ? color.white              : color.rgb(16, 20, 24)
color txtSub  = darkUI ? color.rgb(154, 166, 178) : color.rgb(74, 82, 91)
color txtMut  = darkUI ? color.rgb(110, 120, 132) : color.rgb(140, 148, 156)
color frameC  = darkUI ? color.rgb(58, 70, 84)    : color.rgb(196, 204, 212)
color cAbs2   = darkUI ? colAbs : color.rgb(198, 40, 40)
color cEff2   = darkUI ? colEff : color.rgb(14, 124, 90)

f_pos(string s) => s == "Bottom Left" ? position.bottom_left : s == "Top Left" ? position.top_left : s == "Top Right" ? position.top_right : s == "Middle Right" ? position.middle_right : position.bottom_right
var table T = table.new(f_pos(panelPos), 2, 9, frame_width = 1, border_width = 1)
f_row(int r, string k, string v, color vc, color rbg) =>
    table.cell(T, 0, r, k, text_color = txtSub, text_size = size.small, text_halign = text.align_left,  bgcolor = rbg)
    table.cell(T, 1, r, v, text_color = vc,     text_size = size.small, text_halign = text.align_right, bgcolor = rbg)

if showPanel and barstate.islast
    table.set_bgcolor(T, panelBg)
    table.set_frame_color(T, frameC)
    table.set_border_color(T, frameC)
    color hdr = color.new(costPct >= hiThr ? colAbs : costPct <= loThr ? colEff : color.gray, 0)
    table.cell(T, 0, 0, "FLOW EFFICIENCY", text_color = f_lum(hdr) > 140 ? color.rgb(10,10,10) : color.white, bgcolor = hdr, text_size = size.small)
    table.cell(T, 1, 0, na(costPct) ? "warming" : str.tostring(costPct, "0") + "%", text_color = f_lum(hdr) > 140 ? color.rgb(10,10,10) : color.white, bgcolor = hdr, text_size = size.small)
    f_row(1, "State", state, costPct >= hiThr ? cAbs2 : costPct <= loThr ? cEff2 : txtMain, rowAlt)
    f_row(2, "Delta side", barDelta > 0 ? "buyers" : barDelta < 0 ? "sellers" : "balanced", barDelta > 0 ? cEff2 : barDelta < 0 ? cAbs2 : txtMut, panelBg)
    f_row(3, "Events (n)", str.tostring(sigN), txtMain, rowAlt)
    f_row(4, "Hit %", sigN < 20 ? "warming" : str.tostring(hitP, "0") + "% +/-" + str.tostring(ciPct, "0"), sigN < 20 ? txtMut : txtMain, panelBg)
    f_row(5, "Edge", sigN < 20 or na(edge) ? "warming" : str.tostring(edge, "+0.0;-0.0") + " pts" + (sigStar ? " *" : ""), (sigN < 20 or na(edge)) ? txtMut : edge > 3 ? cEff2 : edge < -3 ? cAbs2 : txtMain, rowAlt)
    f_row(6, "Runs-Z (streak)", na(runsZ) ? "warming" : str.tostring(runsZ, "0.0"), math.abs(nz(runsZ)) > 2.0 ? cAbs2 : txtMut, panelBg)
    f_row(7, "Edge floor", na(edgeLB) ? "warming" : str.tostring(edgeLB, "+0.0;-0.0"), na(edgeLB) ? txtMut : edgeLB > 0 ? cEff2 : cAbs2, rowAlt)
    f_row(8, "Impact lambda", na(lamSlope) ? "warming" : str.tostring(lamSlope, "0.0000") + "  R" + str.tostring(lamR2, "0.00"), txtMain, panelBg)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                          ALERTS
// ═════════════════════════════════════════════════════════════════════════════════════════

// ===== IDENTITY STRIP  (name, symbol, timeframe) =====
showId = input.bool(true, "Show identity strip (name, symbol, timeframe)", group = "Z · Identity & exports")
var table idT = table.new(position.bottom_center, 1, 1, force_overlay = true)
if showId and barstate.islast
    color bgI  = chart.bg_color
    float lumI = na(bgI) ? 0.0 : color.r(bgI) * 0.299 + color.g(bgI) * 0.587 + color.b(bgI) * 0.114
    bool  dkI  = themeOpt == "Dark" ? true : themeOpt == "Light" ? false : (na(bgI) or lumI < 140)
    table.cell(idT, 0, 0, "Flow-Efficiency Oscillator   -   " + syminfo.ticker + "   -   " + timeframe.period, text_color = dkI ? color.new(#c8d0da, 10) : color.new(#2a2f37, 10), text_size = size.small, text_halign = text.align_center, bgcolor = color.new(color.gray, 100))

// ===== EXP_* EXPORTS  (Data Window, generic names for input.source) =====
showEXP = input.bool(true, "Emit EXP_* exports", group = "Z · Identity & exports")
color exC_ = color.new(color.gray, 100)
plot(showEXP ? (costPct) : na, "EXP_Cost", color = exC_, display = display.data_window)
plot(showEXP ? (math.max(-100.0, math.min(100.0, deltaShare * 100.0))) : na, "EXP_FlowBias", color = exC_, display = display.data_window)
plot(showEXP ? (costPct >= hiThr ? 1 : costPct <= loThr ? -1 : 0) : na, "EXP_Zone", color = exC_, display = display.data_window)
plot(showEXP ? (absLong ? 1 : absShort ? -1 : 0) : na, "EXP_Absorption", color = exC_, display = display.data_window)
plot(showEXP ? (edge) : na, "EXP_Edge", color = exC_, display = display.data_window)
plot(showEXP ? (na(costPct) ? 0 : 1) : na, "EXP_DataLive", color = exC_, display = display.data_window)

plot(showEXP ? (lamSlope) : na, "EXP_Lambda", color = exC_, display = display.data_window)
plot(showEXP ? (deltaShare * 100.0) : na, "EXP_OFI", color = exC_, display = display.data_window)
plot(showEXP ? (runsZ) : na, "EXP_RunsZ", color = exC_, display = display.data_window)
plot(showEXP ? (edgeLB) : na, "EXP_EdgeLB", color = exC_, display = display.data_window)
plot(showEXP ? (cusumEvt ? 1 : 0) : na, "EXP_CUSUM", color = exC_, display = display.data_window)
alertcondition(ta.crossover(costPct, float(hiThr)),  "Into absorption", "Flow Efficiency: cost rose into the absorption band.")
alertcondition(ta.crossunder(costPct, float(loThr)), "Into efficiency", "Flow Efficiency: cost fell into the efficient band.")
alertcondition(absLong,  "Absorbed bid (up bias)",   "Flow Efficiency: heavy selling absorbed; price held.")
alertcondition(absShort, "Absorbed offer (down bias)","Flow Efficiency: heavy buying absorbed; price stalled.")
````
