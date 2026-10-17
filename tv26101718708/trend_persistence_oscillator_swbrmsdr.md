# Trend Persistence Oscillator

- url: https://www.tradingview.com/script/sWBrmSdr-Trend-Persistence-Oscillator/
- type: indicator
- pine_id: PUB;bbf3cbfcbdc745418befdb53cc3c9b25
- version: 4.0

## Description

Trend Persistence Oscillator

OVERVIEW

Most oscillators answer "is price stretched?" This one answers the prior question almost everyone skips: "is the market even in a state where a stretch should snap back?" It plots a rolling persistence exponent of price around the 0.5 line. ~0.5 is a random walk; above 0.5 the series is persistent (moves tend to continue → trending); below 0.5 it is anti-persistent (moves tend to reverse → mean-reverting). It is an analytical study of market state — not a directional signal and not a strategy.

WHY THESE COMPONENTS BELONG IN ONE SCRIPT (mashup rationale)

Three parts that chain into one testable idea — is a reversion likely here, and has that held before?


The persistence exponent classifies the regime (trending / random / reverting). Research finds price reverts to its mean significantly faster when the local exponent is anti-persistent, so a low reading is a green light for fades and a high reading is a warning that a reversion will likely fail.
A stretch z-score measures how far price sits from its rolling mean — the "is it extended?" half a regime read alone can't supply.
A fade flag arms only when both agree (anti-persistent regime and stretched), turning the research claim into a concrete, located event.
The calibration harness proves or disproves the claim on your instrument: it logs each fade and checks, a fixed horizon later, whether price actually reverted — reporting Edge versus the unconditional base rate.


A regime read without a stretch is just a state label; a stretch without the regime is a naive fade; either without calibration is an untested assertion. Chained, they answer one question end to end. Remove a part and the chain breaks.

HOW IT WORKS


The exponent is estimated by the structure-function (generalized-Hurst) method: for several lags, the windowed mean of |log-price(t) − log-price(t−lag)| scales like lag^H, so the exponent is the slope of log(mean|Δ|) against log(lag). The first-moment (absolute) form is used deliberately because it is the variant most robust to the heavy tails of financial returns — Monte-Carlo studies find the generalized-Hurst approach gives the lowest bias and variance of the common estimators on heavy-tailed data.
A short optional smoothing tames the noise inherent to short-window local estimates (very short windows are known to produce volatile readings and false alarms).
A stretch z-score and the regime thresholds combine into the fade flag.
The harness logs each fade and, a fixed horizon later, checks a ≥ k × ATR reversion.


HOW TO USE

Read the line for regime: in the green (reverting) zone, mean-reversion / fade setups have the wind behind them; in the gold (trending) zone, expect continuation and treat reversion setups with suspicion; near 0.5 the tape is effectively random. The fade dots mark reverting-and-stretched moments. Then read the Edge row — a regime filter only earns its keep if fades taken inside it beat the unconditional base rate. Context, never a standalone trigger.

Three visual styles are provided (Gradient area + glow / Histogram / Line).

UNIVERSAL ACROSS MARKETS

The price source is an input, so the engine runs on any instrument and timeframe. Defaults target intraday index futures (e.g. NSE NIFTY); change the source for any other market. The reading is self-normalising around 0.5, so the same regime bands work everywhere.

ORIGINALITY

The exponent itself is a standard public statistic, credited below. The original work is the assembly: a structure-function persistence estimator chosen for heavy-tail robustness and smoothed against short-window noise, gated against a stretch z-score into a located fade event, and tied to a forward base-rate calibration so the regime claim is tested on each instrument rather than asserted. It is a regime and validation tool, not a plain exponent plot. No third-party Pine code is reused.

CONCEPT CREDIT

The scaling exponent and rescaled-range analysis — Harold E. Hurst (1951). Fractional / self-similar processes and the generalized exponent — Benoit Mandelbrot. The structure-function (generalized-Hurst) estimator is the variant most robust to heavy-tailed financial data. The anti-persistence-anticipates-reversion application follows recent local-exponent mean-reversion research (2024). Not affiliated with, nor endorsed by, any third party.

HONESTY / LIMITATIONS

The exponent is an estimate from a finite window — it is noisy and lags, and short windows can raise false alarms (which is why a smoothing control is provided, on by default). A low reading is context, not a trigger. The Edge figures are in-sample, close-to-close, with overlapping forward windows and no costs — descriptive context, not a verified backtest. An Edge near zero or negative is the harness honestly reporting that the regime read isn't helping here; do not tune until it turns green — that is curve-fitting. Nothing here predicts direction.

DISCLAIMER

Research and educational tool only. NOT financial advice and NO guarantee of profitability or accuracy. Indicators describe past behaviour; they do not predict the future. Trading carries risk of loss. Test out-of-sample and make your own decisions. The author accepts no liability for any use of this script.

## Source Code

````pine
//@version=6
// ══════════════════════════════════════════════════════════════════════════════════════════════
// PERSISTENCE DIVERGENCE OSCILLATOR                                                      v0.1
// ────────────────────────────────────────────────────────────────────────────────────────────
// WHAT IT IS  Measures trend PERSISTENCE (a rescaled-range Hurst exponent blended with a variance
//   ratio) and looks for it to diverge from price: a higher price high made on FALLING persistence
//   means the trend that produced the high is losing memory — an exhaustion footprint. A forward-
//   calibration harness scores whether the divergences follow through on the symbol.
//
// HOW IT WORKS  persistence = blend of (Hurst-0.5) and (VR-1), z-scored and soft-bounded.
//   Divergence is detected from confirmed price pivots vs the persistence oscillator. Bull
//   divergence = long; bear = short.
//
// NON-REPAINT  Pivots confirm pivLen bars later; calibration logs/resolves on barstate.isconfirmed.
//
// CONCEPT CREDIT  Rescaled-range / Hurst exponent — H. E. Hurst. Variance-ratio test — A. W. Lo &
//   A. C. MacKinlay. Divergence — standard public technique. Original implementation.
//
// DISCLAIMER  Research/education only. Edge figures are in-sample, overlapping, no costs — context,
//   not a backtest. Not financial advice. Markets carry risk; do your own work.
// ══════════════════════════════════════════════════════════════════════════════════════════════
indicator("Persistence Divergence Oscillator", "Pers Div", overlay = false, max_lines_count = 100, max_labels_count = 200)

// R1 · honest-stats standardization — the Wilson confidence math (and hit-rate) is now routed through the
// published calibration library, byte-identical to the prior local helper, so the oscillator, the divergence
// marks and every calibration number are UNCHANGED — only where the math is computed moves into the library.
// Pinned to the exact published v2 version so a later library update can't silently change this script.
import Market_Logic_India/ml_calib/2 as calib

gData    = "1 · Data source"
srcPrice = input.source(close, "Price source", group = gData)
srcHigh  = input.source(high,  "High source",  group = gData)
srcLow   = input.source(low,   "Low source",   group = gData)

gEng     = "2 · Persistence engine"
hurstLen = input.int(100, "Hurst window",        minval = 20, maxval = 200, group = gEng)
vrQ      = input.int(4,   "Variance-ratio lag q", minval = 2, maxval = 20,  group = gEng)
vrN      = input.int(60,  "Variance-ratio window", minval = 20, maxval = 300, group = gEng)
wHurst   = input.float(0.5, "Hurst weight (vs VR)", minval = 0.0, maxval = 1.0, step = 0.05, group = gEng)
normLen  = input.int(100, "Normalization window",  minval = 20, maxval = 500, group = gEng)

gDiv     = "3 · Divergence"
pivLen   = input.int(5,  "Pivot L/R", minval = 1, maxval = 50, group = gDiv)
divLook  = input.int(60, "Max bars between pivots", minval = 5, maxval = 300, group = gDiv)
showHid  = input.bool(true, "Hidden divergences", group = gDiv)
drawLines= input.bool(true, "Draw divergence lines", group = gDiv)

gCal     = "4 · Calibration (forward)"
calOn    = input.bool(true, "Run forward calibration", group = gCal)
calHor   = input.int(10, "Forward horizon (bars)", minval = 2, maxval = 200, group = gCal)
calMinN  = input.int(15, "Min sample for stars", minval = 5, maxval = 500, group = gCal)

gUI      = "5 · Dashboard & theme"
showTbl  = input.bool(true, "Show dashboard", group = gUI)
tblPos   = input.string("Top Right", "Position", options = ["Top Right","Top Left","Bottom Right","Bottom Left"], group = gUI)
dashTheme= input.string("Auto (match chart)", "Theme", options = ["Auto (match chart)","Dark","Light"], group = gUI)
colUp    = input.color(#2ebd85, "Bull / Up",   inline = "c", group = gUI)
colDn    = input.color(#f6465d, "Bear / Down", inline = "c", group = gUI)

f_pos(string s) => s=="Top Left"?position.top_left : s=="Bottom Right"?position.bottom_right : s=="Bottom Left"?position.bottom_left : position.top_right
f_zscore(float s, int len) =>
    sd = ta.stdev(s, len)
    mn = ta.sma(s, len)
    sd == 0 ? 0.0 : (s - mn) / sd
f_tanh(float x) =>
    float xc = math.max(-10.0, math.min(10.0, x))
    float e = math.exp(2 * xc)
    (e - 1) / (e + 1)
f_squash(float x, simple float k) => 100.0 * f_tanh(x / k)
f_star(float wl, float base, int n) =>
    n < calMinN or na(wl) or na(base) ? "n/a" : wl > base+5 ? "★★★" : wl > base ? "★★" : wl > base-5 ? "★" : "—"
f_hurst(float r, simple int n) =>
    float mean = 0.0
    for i = 0 to n - 1
        mean += nz(r[i])
    mean /= n
    float cum = 0.0
    float mx = -1e10
    float mn = 1e10
    for i = 0 to n - 1
        cum += nz(r[n - 1 - i]) - mean
        mx := math.max(mx, cum)
        mn := math.min(mn, cum)
    float rng = mx - mn
    float sd  = ta.stdev(r, n)
    (rng > 0 and sd > 0) ? math.log(rng / sd) / math.log(n) : 0.5
f_vr(float r, simple int q, simple int n) =>
    qsum = math.sum(r, q)
    vq = ta.variance(qsum, n)
    v1 = ta.variance(r, n)
    v1 > 0 ? vq / (q * v1) : 1.0

// ── ENGINE ──────────────────────────────────────────────────────────────────────────────────
ret   = srcPrice - srcPrice[1]
hurst = f_hurst(ret, hurstLen)
vr    = f_vr(ret, vrQ, vrN)
pRaw  = wHurst * (hurst - 0.5) * 200.0 + (1 - wHurst) * (vr - 1.0) * 100.0
osc   = f_squash(f_zscore(pRaw, normLen) * 33, 100)

// ── DIVERGENCE ENGINE ─────────────────────────────────────────────────────────────────────────
ph = ta.pivothigh(srcHigh, pivLen, pivLen)
pl = ta.pivotlow(srcLow, pivLen, pivLen)
phC = not na(ph)
plC = not na(pl)
curX = bar_index - pivLen
oH=osc[pivLen], pHh=srcHigh[pivLen]
poH=ta.valuewhen(phC, osc[pivLen],1), ppH=ta.valuewhen(phC, srcHigh[pivLen],1), pxH=ta.valuewhen(phC, bar_index-pivLen,1)
bearReg = phC and pHh>ppH and oH<poH and (curX-pxH<=divLook)
bearHid = showHid and phC and pHh<ppH and oH>poH and (curX-pxH<=divLook)
oL=osc[pivLen], pLl=srcLow[pivLen]
poL=ta.valuewhen(plC, osc[pivLen],1), ppL=ta.valuewhen(plC, srcLow[pivLen],1), pxL=ta.valuewhen(plC, bar_index-pivLen,1)
bullReg = plC and pLl<ppL and oL>poL and (curX-pxL<=divLook)
bullHid = showHid and plC and pLl>ppL and oL<poL and (curX-pxL<=divLook)
bullDiv = bullReg or bullHid
bearDiv = bearReg or bearHid

if drawLines and bearReg
    line.new(int(pxH), poH, curX, oH, color = color.new(colDn,30), width = 2)
if drawLines and bullReg
    line.new(int(pxL), poL, curX, oL, color = color.new(colUp,30), width = 2)

buySig  = bullReg
sellSig = bearReg
stTxt = osc >= 0 ? "Persistent" : "Mean-revert"
wCol  = osc >= 0 ? colUp : colDn

// ── CALIBRATION ───────────────────────────────────────────────────────────────────────────────
var int buyN = 0
var int buyW = 0
var int sellN = 0
var int sellW = 0
var int baseN = 0
var int baseW = 0
canEval = calOn and barstate.isconfirmed and not na(close[calHor])
if canEval
    if buySig[calHor]
        buyN += 1
        buyW += close > close[calHor] ? 1 : 0
    if sellSig[calHor]
        sellN += 1
        sellW += close < close[calHor] ? 1 : 0
    baseN += 1
    baseW += close > close[calHor] ? 1 : 0
buyHit  = buyN  > 0 ? buyW  / buyN  * 100.0 : na
sellHit = sellN > 0 ? sellW / sellN * 100.0 : na
baseUp  = baseN > 0 ? baseW / baseN * 100.0 : na
baseDn  = baseN > 0 ? 100.0 - baseUp : na
buyEdge  = (not na(buyHit)  and not na(baseUp)) ? buyHit  - baseUp : na
sellEdge = (not na(sellHit) and not na(baseDn)) ? sellHit - baseDn : na
buyStar  = f_star(calib.wilsonLo(buyW, buyN, 1.96),  baseUp, buyN)
sellStar = f_star(calib.wilsonLo(sellW, sellN, 1.96), baseDn, sellN)

// ── PLOTS ─────────────────────────────────────────────────────────────────────────────────────
pObIn  = plot(50.0,  "Persist edge", color.new(colUp, 35), 1)
pObOut = plot(100.0, "Persist cap",  color.new(colUp, 100), display = display.none)
fill(pObIn, pObOut, 100.0, 50.0, color.new(colUp, 18), color.new(colUp, 92), title = "Persistent")
pOsIn  = plot(-50.0,  "MR edge", color.new(colDn, 35), 1)
pOsOut = plot(-100.0, "MR cap",  color.new(colDn, 100), display = display.none)
fill(pOsIn, pOsOut, -50.0, -100.0, color.new(colDn, 92), color.new(colDn, 18), title = "Mean-revert")
hline(0, "Zero", color.new(color.gray, 60))

plot(osc, "Persistence glow", color.new(wCol, 70), 8)
plot(osc, "Persistence", color.new(wCol, 0), 2)

plotshape(bullDiv ? oL : na, "Bull div", shape.circle, location.absolute, color.new(colUp,0), offset = -pivLen, size = size.tiny)
plotshape(bearDiv ? oH : na, "Bear div", shape.circle, location.absolute, color.new(colDn,0), offset = -pivLen, size = size.tiny)
plotshape(bullReg, "Bull mark", shape.triangleup,   location.belowbar, color.new(colUp,0), size = size.tiny, force_overlay = true)
plotshape(bearReg, "Bear mark", shape.triangledown, location.abovebar, color.new(colDn,0), size = size.tiny, force_overlay = true)

// ── DASHBOARD ───────────────────────────────────────────────────────────────────────────────
var table st = table.new(f_pos(tblPos), 2, 7, frame_width = 1, border_width = 1)
if showTbl and barstate.islast
    color bgc    = chart.bg_color
    float lumaV  = na(bgc) ? 0.0 : color.r(bgc)*0.299 + color.g(bgc)*0.587 + color.b(bgc)*0.114
    bool  darkUI = dashTheme=="Dark" ? true : dashTheme=="Light" ? false : (na(bgc) or lumaV < 140)
    color panelBg= darkUI ? color.rgb(17,22,28)    : color.rgb(244,246,248)
    color rowAlt = darkUI ? color.rgb(25,31,39)    : color.rgb(232,236,240)
    color txtMain= darkUI ? color.white            : color.rgb(16,20,24)
    color txtSub = darkUI ? color.rgb(154,166,178) : color.rgb(74,82,91)
    color frameC = darkUI ? color.rgb(58,70,84)    : color.rgb(196,204,212)
    color upC    = darkUI ? colUp : color.rgb(22,151,106)
    color dnC    = darkUI ? colDn : color.rgb(210,45,68)
    color flatC  = darkUI ? color.gray : color.rgb(122,130,139)
    color hdr    = color.new(colUp, 0)
    string divTxt = bullDiv ? "Bull div" : bearDiv ? "Bear div" : "—"
    color  divC   = bullDiv ? upC : bearDiv ? dnC : flatC
    table.set_bgcolor(st, panelBg)
    table.set_frame_color(st, frameC)
    table.set_border_color(st, frameC)
    table.cell(st, 0, 0, "Persistence Div", text_color = color.white, bgcolor = hdr, text_size = size.tiny)
    table.cell(st, 1, 0, str.upper(stTxt), text_color = color.white, bgcolor = hdr, text_size = size.tiny)
    table.cell(st, 0, 1, "Persistence", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(st, 1, 1, str.tostring(osc,"#"), text_color = osc>=0?upC:dnC, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(st, 0, 2, "Hurst", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
    table.cell(st, 1, 2, str.tostring(hurst,"0.00"), text_color = hurst>0.5?upC:dnC, bgcolor = panelBg, text_size = size.tiny)
    table.cell(st, 0, 3, "Divergence", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(st, 1, 3, divTxt, text_color = divC, bgcolor = rowAlt, text_size = size.tiny)
    if calOn
        string baseTxt = (na(baseUp) or na(baseDn)) ? "warming" : "up " + str.tostring(baseUp,"0") + "  dn " + str.tostring(baseDn,"0")
        string buyTxt  = buyN  < calMinN ? "warm " + str.tostring(buyN)  : "H" + str.tostring(buyHit,"0")  + "  E" + (nz(buyEdge)>=0?"+":"")  + str.tostring(buyEdge,"0")  + "  (" + str.tostring(buyN) + ")"
        string sellTxt = sellN < calMinN ? "warm " + str.tostring(sellN) : "H" + str.tostring(sellHit,"0") + "  E" + (nz(sellEdge)>=0?"+":"") + str.tostring(sellEdge,"0") + "  (" + str.tostring(sellN) + ")"
        table.cell(st, 0, 4, "Base " + str.tostring(calHor) + "b", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
        table.cell(st, 1, 4, baseTxt, text_color = txtMain, bgcolor = panelBg, text_size = size.tiny)
        table.cell(st, 0, 5, "Bull " + buyStar, text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
        table.cell(st, 1, 5, buyTxt, text_color = buyN<calMinN?flatC:upC, bgcolor = rowAlt, text_size = size.tiny)
        table.cell(st, 0, 6, "Bear " + sellStar, text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
        table.cell(st, 1, 6, sellTxt, text_color = sellN<calMinN?flatC:dnC, bgcolor = panelBg, text_size = size.tiny)

// ── EXPORTS / ALERTS ──────────────────────────────────────────────────────────────────────────
plot(osc,   "Persistence", color.new(color.gray,100), display = display.data_window)
plot(hurst, "Hurst", color.new(color.gray,100), display = display.data_window)
plot(bullDiv?1:bearDiv?-1:0, "Divergence", color.new(color.gray,100), display = display.data_window)
alertcondition(bullReg, "Bull Divergence", "Persistence: bullish divergence")
alertcondition(bearReg, "Bear Divergence", "Persistence: bearish divergence")
````
