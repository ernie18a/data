# Lead-Lag Information Flow

- url: https://www.tradingview.com/script/gTkknhYQ-Lead-Lag-Information-Flow/
- type: indicator
- pine_id: PUB;154da8fe95c14c2b8a339ced7e26ce7e
- version: 2.0

## Description

Lead-Lag Information Flow


OVERVIEW

Correlation tells you two instruments move together. It cannot tell you who moves first. This indicator answers that question directly: it measures the net directional information flow between a reference symbol and the chart using transfer entropy — how much knowing the reference's last move reduces uncertainty about the chart's next move, beyond what the chart's own history already says, minus the same quantity in the other direction.

The result plots around zero. Positive = the reference leads the chart; negative = the chart leads the reference. A regime read (is the follower trending or chopping?) sits alongside it, because a lead is only worth acting on when the follower is in a state that lets the move pay off.

WHY THESE COMPONENTS BELONG IN ONE SCRIPT (mashup rationale)

Three parts, one question — is there exploitable lead-lag right now, and which way? Each closes a gap the others leave open:


Transfer entropy (net, in bits) answers the DIRECTION of information — who leads. It is model-free and captures nonlinear lead-lag that a correlation or linear regression misses, and netting the two directions cancels much of the small-sample bias that distorts raw entropy estimates.
The Hurst regime read answers whether a lead is tradeable: information flowing into a persistent (trending) follower is far more actionable than into a mean-reverting chop. The same lead means different things in different regimes.
The calibration harness answers whether it has actually worked here: it logs each lead-and-follow setup and, a fixed horizon later, checks whether the chart moved with the leader by at least k × ATR, reporting Hit %, Base %, and Edge.


Direction without a regime filter fires into noise; a regime read without direction is just a Hurst line; either without calibration is an untested assertion. Together they form one decision — lead exists (entropy) and the follower can run (regime) and it has paid before (Edge). Remove any one and the question is answered less completely.

HOW IT WORKS


Each series' bar-to-bar move is reduced to an up/down state.
Over a rolling window, state-transition frequencies estimate the transfer entropy in each direction (Schreiber's estimator); the plotted line is the net (reference→chart minus chart→reference), in bits. An optional Miller-Madow finite-sample correction subtracts the small-sample bias raw entropy estimates carry on short windows — a streaming-feasible step toward effective transfer entropy.
A Hurst exponent (a structure-function estimate around the 0.5 line) classifies the follower's regime as trending or reverting.
A follow setup arms when net flow says the reference leads and the reference has just moved; the calibration harness then measures whether the chart followed.


HOW TO USE

Read the line for direction — above the upper threshold, the reference leads; below the lower threshold, the chart leads — and read the dashboard for regime and the Edge row. A lead into a trending follower with a positive, matured Edge is the context this tool is built to surface. A lead into a reverting follower, or one where Edge sits near zero, is the engine telling you the lead-lag is not exploitable on this pair and timeframe. The background tints faintly green when the reference leads decisively and red when the chart leads. Treat all of this as context, never a standalone trigger.

Three visual styles are provided (Gradient area + glow / Histogram / Line); the gradient area's intensity scales with how strong the net flow is.

UNIVERSAL ACROSS MARKETS

The chart is the follower; the Reference symbol is the candidate leader — both are inputs, so the engine runs on any related pair in any market: cash index vs its futures, an index vs a lead constituent, an asset vs its dominant driver. Defaults pair NSE:NIFTY (cash) as the candidate leader against a NIFTY-futures chart; change the reference for any other pair. Use it on the timeframe at which you expect the lead-lag to operate.

ORIGINALITY

The techniques are public and credited below. The original work is the integration: a streaming two-state transfer-entropy estimator that nets the two directions and applies a Miller-Madow finite-sample correction to approximate effective transfer entropy (the documented fix for small-sample bias) without the shuffle step that a streaming script can't perform, gated by a Hurst regime classifier so a lead is only surfaced where the follower can act on it, and tied to a forward base-rate calibration so every follow setup reports its own realized Edge rather than an asserted one. No third-party Pine code is reused.

CONCEPT CREDIT

Transfer entropy — Thomas Schreiber (2000); effective transfer entropy and small-sample bias correction — Marschinski & Kantz (2002). Finite-sample entropy correction — Miller (1955) / Madow. Information entropy — Claude E. Shannon (1948). Hurst exponent — Harold E. Hurst (1951); long-memory framing — Benoit Mandelbrot. Not affiliated with, nor endorsed by, any third party.

HONESTY / LIMITATIONS

This is a coarse, two-state, windowed estimator. The finite-sample (Miller-Madow) correction and the netting of the two directions together approximate effective transfer entropy — they reduce the small-sample bias raw TE carries — but they are not a full surrogate-shuffle effective TE with significance testing (which requires reshuffling that isn't possible in a streaming script). The Edge figures are in-sample, close-to-close, with overlapping forward windows and no costs — descriptive context, not a verified backtest. An Edge near zero or negative is the harness honestly reporting that the lead-lag is not exploitable here; do not tune until it turns green — that is curve-fitting. The reference must be a genuinely related instrument for the read to mean anything. Nothing here predicts price.

DISCLAIMER

Research and educational tool only. NOT financial advice and NO guarantee of profitability or accuracy. Indicators describe past behaviour; they do not predict the future. Trading carries risk of loss. Test out-of-sample and make your own decisions. The author accepts no liability for any use of this script.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
// ══════════════════════════════════════════════════════════════════════════════════════════════
// © Market_Logic_India                                                       MPL-2.0
// LEAD-LAG INFORMATION FLOW                                                               v2.0
// ────────────────────────────────────────────────────────────────────────────────────────────
// OVERVIEW
//   A single line that answers one question correlation cannot: WHO MOVES FIRST. It measures the
//   net DIRECTIONAL information flow between a reference symbol and the chart using transfer
//   entropy - how much knowing the reference's last move reduces uncertainty about the chart's
//   NEXT move, beyond what the chart's own past already says, minus the same quantity in reverse.
//   Plotted around zero: positive = the reference leads the chart; negative = the chart leads the
//   reference. Alongside it sits a regime read (is the follower trending or chopping?) because a
//   lead is only worth acting on when the follower is in a state that lets it pay off. This is a
//   study of lead-lag STRUCTURE, not a buy/sell signal.
//
// WHAT MAKES IT DIFFERENT  (why these parts are ONE tool, not three overlays)
//   Three components, one question - "is there exploitable lead-lag right now, and which way?":
//     - TRANSFER ENTROPY (net, in bits) answers DIRECTION of information: who leads. It is model-
//       free and captures nonlinear lead-lag a correlation or regression misses, and netting the
//       two directions cancels much of the small-sample bias that plagues raw entropy estimates.
//     - The HURST REGIME read answers WHETHER a lead is tradeable: information flow into a
//       persistent (trending) follower is far more actionable than into a mean-reverting chop.
//     - The CALIBRATION HARNESS answers WHETHER IT ACTUALLY WORKED here: it logs each lead-and-
//       follow setup and, a fixed horizon later, checks whether the chart moved with the leader.
//   Direction without a regime filter fires into noise; a regime read without direction is just a
//   Hurst line; either without calibration is an untested claim. Together they form one decision:
//   lead exists (entropy) + follower can run (regime) + it has paid before (Edge). Remove any one
//   and the question is answered less completely - which is why they ship as a single engine.
//
// HOW IT WORKS
//   1. Each series' bar-to-bar move is reduced to an up/down state.
//   2. Over a window, state-transition frequencies estimate the transfer entropy in each
//      direction (Schreiber); the plotted value is the NET (reference->chart minus chart->ref).
//   3. A Hurst exponent (structure-function estimate around 0.5) classifies the follower's regime.
//   4. A FOLLOW setup arms when net flow says the reference leads AND the reference has just moved;
//      the calibration harness then measures whether the chart followed by at least k x ATR.
//
// HOW TO USE
//   Read the line for direction (above zero / the upper threshold = reference leads; below =
//   chart leads) and the dashboard for regime and the Edge row. A lead into a trending follower
//   with a positive, matured Edge is the context this tool is built to surface; a lead into a
//   reverting follower, or with Edge near zero, is the engine telling you the lead-lag is not
//   exploitable on this pair and timeframe. Context, never a standalone trigger.
//
// UNIVERSAL ACROSS MARKETS  (configurable data source)
//   The chart is the follower; the Reference symbol is the candidate leader - both are inputs, so
//   the engine runs on any related pair in any market (cash vs futures, index vs lead constituent,
//   asset vs its dominant driver). Default reference NSE:NIFTY pairs the cash index against a
//   NIFTY-futures chart; change it for any other pair.
//
// NON-REPAINT
//   The reference series is requested with lookahead off and read on confirmed bars; the entropy,
//   regime and calibration all use closed-bar data. No higher-timeframe lookahead is used.
//
// CONCEPT CREDIT
//   Transfer entropy - Thomas Schreiber (2000). Information entropy - Claude E. Shannon (1948).
//   Hurst exponent - Harold E. Hurst (1951); long-memory framing - Benoit Mandelbrot. The
//   transfer-entropy-with-regime framing follows recent information-flow / regime research.
//   Original implementation; not affiliated with, nor endorsed by, any third party.
//
// HONESTY / LIMITATIONS
//   This is a COARSE, two-state, windowed estimator. The optional finite-sample (Miller-Madow)
//   correction and the netting of the two directions together approximate "effective transfer
//   entropy" - they reduce the small-sample bias raw TE carries - but they are not a full
//   surrogate-shuffle effective TE with significance testing (which needs reshuffling not possible
//   in a streaming script). The Edge figures are in-sample, close-to-close, with overlapping
//   forward windows and no costs - descriptive context, not a verified backtest. Read the Edge row
//   before trusting any lead. Nothing here predicts price.
//
// DISCLAIMER
//   Research and educational tool only. NOT financial advice and NO guarantee of profitability or
//   accuracy. Indicators describe past behaviour; they do not predict the future. Trading carries
//   risk of loss. Test out-of-sample and make your own decisions. The author accepts no liability
//   for any use of this script.
// ══════════════════════════════════════════════════════════════════════════════════════════════
indicator("Lead-Lag Information Flow", "Info Flow", overlay = false, max_labels_count = 120, dynamic_requests = true)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                          INPUTS
// ═════════════════════════════════════════════════════════════════════════════════════════

// ── 01 · DATA & SOURCE ───────────────────────────────────────────────────────────────────
g0 = "01 · Data & source"
src    = input.source(close, "Chart (follower) source", group = g0, tooltip = "The series whose NEXT move we test. Works on any symbol / market.")
refSym = input.symbol("NSE:NIFTY", "Reference (candidate leader) symbol", group = g0, tooltip = "The series tested as the LEADER. Default NSE:NIFTY (cash) pairs with NIFTY futures; set it to any related instrument.")

// ── 02 · TRANSFER ENTROPY ────────────────────────────────────────────────────────────────
g1 = "02 · Transfer entropy"
teLen    = input.int(120, "Window (transitions)", minval = 40, maxval = 400, group = g1, tooltip = "How many state transitions are tallied for the probability estimate. Longer = steadier but slower.")
biasOn   = input.bool(true, "Finite-sample bias correction", group = g1, tooltip = "Miller-Madow correction: a streaming-feasible step toward 'effective transfer entropy' that subtracts the small-sample bias raw TE estimates carry on short windows. Recommended on.")
teSmooth = input.int(3, "Smoothing (EMA, 1 = off)", minval = 1, maxval = 20, group = g1)
teThr    = input.float(0.02, "Lead threshold (bits)", minval = 0.0, step = 0.01, group = g1, tooltip = "Net flow beyond +/- this marks a decisive lead and tints the background.")

// ── 03 · SIGNAL & REGIME ─────────────────────────────────────────────────────────────────
g2 = "03 · Signal & regime"
refMomLen = input.int(3, "Reference momentum length", minval = 1, group = g2, tooltip = "Sign of the reference's move over this many bars sets the follow direction.")
hLen      = input.int(100, "Hurst window (regime)", minval = 40, maxval = 400, group = g2)
reqTrend  = input.bool(false, "Require trending regime (H > 0.5) for signal", group = g2)
showSig   = input.bool(true, "Mark follow signals", group = g2)

// ── 04 · CALIBRATION HARNESS ─────────────────────────────────────────────────────────────
g4 = "04 · Calibration harness"
calibOn   = input.bool(true, "Run calibration", group = g4, tooltip = "Logs every follow setup and, a fixed horizon later, checks whether the chart followed >= k x ATR in the signal direction. Reports Hit %, unconditional Base %, and Edge = Hit - Base.")
calHor    = input.int(10, "Forward horizon (bars)", minval = 2, maxval = 100, group = g4)
calMove   = input.float(0.6, "Move threshold (x ATR)", minval = 0.1, step = 0.1, group = g4)
calAtrLen = input.int(14, "ATR length", minval = 1, group = g4)

// ── 05 · VISUAL STYLE ────────────────────────────────────────────────────────────────────
g5 = "05 · Visual style"
visStyle = input.string("Gradient area + glow", "Line style", options = ["Gradient area + glow","Histogram","Line"], group = g5)
showTint = input.bool(true, "Background regime tint", group = g5)
colBull  = input.color(#2ebd85, "Ref leads / up", inline = "cc", group = g5)
colBear  = input.color(#f6465d, "Chart leads / down", inline = "cc", group = g5)
colMid   = input.color(#f7c948, "Midline", group = g5)

// ── 06 · DASHBOARD & THEME ───────────────────────────────────────────────────────────────
g6 = "06 · Dashboard & theme"
showPanel = input.bool(true, "Show dashboard", group = g6)
panelPos  = input.string("Bottom Right", "Dashboard position", options = ["Bottom Left","Bottom Right","Top Left","Top Right","Middle Right"], group = g6)
themeOpt  = input.string("Auto (match chart)", "Theme", options = ["Auto (match chart)","Dark","Light"], group = g6, tooltip = "Auto reads the chart background luminance so the panel stays legible on any colour scheme.")

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                    STATES & REFERENCE
// ═════════════════════════════════════════════════════════════════════════════════════════
float xClose = request.security(refSym, timeframe.period, close, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
bool  refLive = not na(xClose)
float retY = src - src[1]
float retX = xClose - xClose[1]
int ySt = retY >= 0 ? 1 : 0
int xSt = (not na(retX) and retX >= 0) ? 1 : 0

// ═════════════════════════════════════════════════════════════════════════════════════════
//                         ENGINE · two-state transfer entropy (Schreiber)
// ═════════════════════════════════════════════════════════════════════════════════════════
f_te(simple int win, simple bool xToY, simple bool mm) =>
    array<float> c3  = array.new<float>(8, 0.0)
    array<float> c2s = array.new<float>(4, 0.0)
    array<float> c2t = array.new<float>(4, 0.0)
    array<float> c1t = array.new<float>(2, 0.0)
    for i = 0 to win - 1
        int tn1 = xToY ? ySt[i]   : xSt[i]
        int tn  = xToY ? ySt[i+1] : xSt[i+1]
        int sn  = xToY ? xSt[i+1] : ySt[i+1]
        array.set(c3,  tn1*4 + tn*2 + sn, array.get(c3,  tn1*4 + tn*2 + sn) + 1.0)
        array.set(c2s, tn*2 + sn,         array.get(c2s, tn*2 + sn)         + 1.0)
        array.set(c2t, tn1*2 + tn,        array.get(c2t, tn1*2 + tn)        + 1.0)
        array.set(c1t, tn,                array.get(c1t, tn)                + 1.0)
    float Tn = win
    float te = 0.0
    for a = 0 to 1
        for b = 0 to 1
            for c = 0 to 1
                float n3 = array.get(c3, a*4 + b*2 + c)
                if n3 > 0.0
                    float p3  = n3 / Tn
                    float pys = array.get(c2s, b*2 + c) / Tn
                    float pyy = array.get(c2t, a*2 + b) / Tn
                    float py  = array.get(c1t, b) / Tn
                    if pys > 0.0 and pyy > 0.0 and py > 0.0
                        float ratio = (p3 / pys) / (pyy / py)
                        if ratio > 0.0
                            te += p3 * (math.log(ratio) / math.log(2.0))
    // Miller-Madow finite-sample correction (a streaming-feasible effective-TE step):
    // TE = H(Yf,Yp) - H(Yp) - H(Yf,Yp,Xp) + H(Yp,Xp); each Ĥ underestimates by (K-1)/(2N),
    // which nets to (K_c2t + K_c2s - K_c1t - K_c3)/(2N) nats -> /ln2 for bits.
    if mm
        int k3 = 0
        for j = 0 to 7
            if array.get(c3, j) > 0.0
                k3 += 1
        int k2s = 0
        int k2t = 0
        for j = 0 to 3
            if array.get(c2s, j) > 0.0
                k2s += 1
            if array.get(c2t, j) > 0.0
                k2t += 1
        int k1 = 0
        for j = 0 to 1
            if array.get(c1t, j) > 0.0
                k1 += 1
        te += (k2t + k2s - k1 - k3) / (2.0 * Tn * math.log(2.0))
    te

float teXY_raw = bar_index >= teLen + 2 and refLive ? f_te(teLen, true,  biasOn) : na
float teYX_raw = bar_index >= teLen + 2 and refLive ? f_te(teLen, false, biasOn) : na
float netRaw = (not na(teXY_raw) and not na(teYX_raw)) ? teXY_raw - teYX_raw : na
float netEma = ta.ema(netRaw, teSmooth)
float netTE = teSmooth > 1 ? netEma : netRaw

// ===== Effective net TE (baseline-subtracted, standardized) + significance gate =====
teEffLen = input.int(120, "Effective-TE baseline window", minval = 30, group = "Z2 · Advanced calibration")
float teMu = ta.sma(netTE, teEffLen)
float teSd = ta.stdev(netTE, teEffLen)
float teEff = (not na(netTE) and not na(teMu)) ? netTE - teMu : na
float teZ   = (not na(teEff) and not na(teSd) and teSd > 0) ? teEff / teSd : na
float teSigVal = (not na(teZ) and math.abs(teZ) >= 2.0) ? netTE : 0.0

// ═════════════════════════════════════════════════════════════════════════════════════════
//                         HURST regime (structure-function estimate)
// ═════════════════════════════════════════════════════════════════════════════════════════
float lY = math.log(src)
float hm1 = ta.sma(math.abs(lY - lY[1]), hLen)
float hm2 = ta.sma(math.abs(lY - lY[2]), hLen)
float hm4 = ta.sma(math.abs(lY - lY[4]), hLen)
float hm8 = ta.sma(math.abs(lY - lY[8]), hLen)
array<float> hxs = array.from(math.log(1.0), math.log(2.0), math.log(4.0), math.log(8.0))
array<float> hys = array.from(math.log(math.max(hm1,1e-10)), math.log(math.max(hm2,1e-10)), math.log(math.max(hm4,1e-10)), math.log(math.max(hm8,1e-10)))
float hsx = 0.0
float hsy = 0.0
float hsxx = 0.0
float hsxy = 0.0
for i = 0 to 3
    float xi = array.get(hxs, i)
    float yi = array.get(hys, i)
    hsx += xi
    hsy += yi
    hsxx += xi*xi
    hsxy += xi*yi
float hDen = 4.0*hsxx - hsx*hsx
float hurst = hDen != 0 ? (4.0*hsxy - hsx*hsy)/hDen : 0.5
hurst := math.max(0.0, math.min(1.0, hurst))
bool trending = hurst >= 0.5

float xMom = xClose - xClose[refMomLen]
bool refLeads = not na(netTE) and netTE >= teThr
bool regimeOK = not reqTrend or trending
bool longSig  = refLeads and regimeOK and not na(xMom) and xMom > 0
bool shortSig = refLeads and regimeOK and not na(xMom) and xMom < 0

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                          PLOTS
// ═════════════════════════════════════════════════════════════════════════════════════════
bool isArea = visStyle == "Gradient area + glow"
bool isHist = visStyle == "Histogram"
bool isLine = visStyle == "Line"
bool showGlow = isArea or isLine

color lineCol = na(netTE) ? color.gray : netTE >= 0 ? colBull : colBear

// yellow midline (house signature) - hline costs no plot budget
plot(0.0, "Mid glow", color = color.new(colMid, 80), linewidth = 6, display = display.pane)
hline(0, "No net flow", color = color.new(colMid, 0), linestyle = hline.style_solid)
hline(teThr,  "Ref leads",   color = color.new(colBull, 55), linestyle = hline.style_dashed)
hline(-teThr, "Chart leads", color = color.new(colBear, 55), linestyle = hline.style_dashed)

// glow line (Line / Gradient styles) or histogram columns
plot(showGlow ? netTE : na, "glow outer", color = color.new(lineCol, 82), linewidth = 8, display = display.pane)
plot(showGlow ? netTE : na, "glow inner", color = color.new(lineCol, 55), linewidth = 4, display = display.pane)
pMain = plot(showGlow ? netTE : na, "Net information flow", color = lineCol, linewidth = 2, display = display.pane)
plot(isHist ? netTE : na, "Histogram", color = color.new(lineCol, 20), style = plot.style_columns, display = display.pane)

// gradient area under the line, intensity scaling with the reading
pBase = plot(isArea ? 0.0 : na, "base", color = na, display = display.none, editable = false)
float areaInt = math.min(1.0, math.abs(nz(netTE)) / math.max(teThr * 3.0, 0.01))
fill(pMain, pBase, color = isArea ? color.new(netTE >= 0 ? colBull : colBear, 92 - int(42 * areaInt)) : na)

// background regime tint - decisive lead at a glance
bgcolor(showTint and not na(netTE) and teThr > 0 and netTE >= teThr ? color.new(colBull, 92) : showTint and not na(netTE) and teThr > 0 and netTE <= -teThr ? color.new(colBear, 92) : na)

// follow signals
plotshape(showSig and longSig  ? netTE : na, "Follow long",  shape.triangleup,   location.absolute, color.new(colBull, 0), size = size.tiny)
plotshape(showSig and shortSig ? netTE : na, "Follow short", shape.triangledown, location.absolute, color.new(colBear, 0), size = size.tiny)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                       CALIBRATION
// ═════════════════════════════════════════════════════════════════════════════════════════
float atrC = ta.atr(calAtrLen)
var int sigN    = 0
var int hitN    = 0
var int baseTot = 0
var int baseUp  = 0
var int baseDn  = 0
float fwdMv  = close - close[calHor]
float fwdAtr = atrC[calHor]
if calibOn and barstate.isconfirmed and bar_index > calHor and not na(fwdAtr) and fwdAtr > 0
    if longSig[calHor]
        sigN += 1
        if fwdMv >= calMove * fwdAtr
            hitN += 1
    if shortSig[calHor]
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
    if cusumEvt and (longSig)
        rtDir.push(1), rtBar.push(bar_index), rtEnt.push(close), rtAtr0.push(atrC)
    if cusumEvt and (shortSig)
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
f_pos(string s) =>
    s == "Bottom Left" ? position.bottom_left : s == "Top Left" ? position.top_left : s == "Top Right" ? position.top_right : s == "Middle Right" ? position.middle_right : position.bottom_right

var table T = table.new(f_pos(panelPos), 2, 11, frame_width = 1, border_width = 1)
if showPanel and barstate.islast
    color bgc    = chart.bg_color
    float luma   = na(bgc) ? 0.0 : color.r(bgc) * 0.299 + color.g(bgc) * 0.587 + color.b(bgc) * 0.114
    bool  darkUI = themeOpt == "Dark" ? true : themeOpt == "Light" ? false : (na(bgc) or luma < 140)
    color panelBg = darkUI ? color.rgb(17, 22, 28)    : color.rgb(244, 246, 248)
    color rowAlt  = darkUI ? color.rgb(25, 31, 39)    : color.rgb(232, 236, 240)
    color txtMain = darkUI ? color.white              : color.rgb(16, 20, 24)
    color txtSub  = darkUI ? color.rgb(154, 166, 178) : color.rgb(74, 82, 91)
    color txtMut  = darkUI ? color.rgb(110, 120, 132) : color.rgb(140, 148, 156)
    color frameC  = darkUI ? color.rgb(58, 70, 84)    : color.rgb(196, 204, 212)
    color hdr     = color.new(colBull, 0)
    color cUp     = darkUI ? colBull : color.rgb(14, 124, 90)
    color cDn     = darkUI ? colBear : color.rgb(198, 40, 40)
    table.set_bgcolor(T, panelBg)
    table.set_frame_color(T, frameC)
    table.set_border_color(T, frameC)

    string netTxt = not refLive ? "no reference" : na(netTE) ? "warming" : str.tostring(netTE, "0.000") + " bits"
    string lead   = na(netTE) ? "-" : netTE >= teThr ? "reference leads" : netTE <= -teThr ? "chart leads" : "balanced"
    color  leadCol = na(netTE) ? txtMut : netTE >= teThr ? cUp : netTE <= -teThr ? cDn : txtMain

    table.cell(T, 0, 0, "Info Flow", text_color = color.white, bgcolor = hdr, text_size = size.tiny)
    table.cell(T, 1, 0, netTxt, text_color = color.white, bgcolor = hdr, text_size = size.tiny)
    table.cell(T, 0, 1, "Direction", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(T, 1, 1, lead, text_color = leadCol, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(T, 0, 2, "Regime", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
    table.cell(T, 1, 2, na(netTE) ? "-" : trending ? "trending" : "reverting", text_color = trending ? txtMain : txtMut, bgcolor = panelBg, text_size = size.tiny)
    table.cell(T, 0, 3, "Hurst", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(T, 1, 3, na(hurst) ? "-" : str.tostring(hurst, "0.00"), text_color = txtMain, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(T, 0, 4, "Reference move", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
    table.cell(T, 1, 4, na(xMom) ? "-" : xMom > 0 ? "up" : xMom < 0 ? "down" : "flat", text_color = xMom > 0 ? cUp : xMom < 0 ? cDn : txtMut, bgcolor = panelBg, text_size = size.tiny)
    table.cell(T, 0, 5, "Signals (n)", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(T, 1, 5, str.tostring(sigN), text_color = txtMain, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(T, 0, 6, "Hit %", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
    table.cell(T, 1, 6, sigN < 20 ? "warming" : str.tostring(hitP, "0") + "% +/-" + str.tostring(ciPct, "0"), text_color = sigN < 20 ? txtMut : txtMain, bgcolor = panelBg, text_size = size.tiny)
    table.cell(T, 0, 7, "Edge (Hit - Base)", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(T, 1, 7, sigN < 20 or na(edge) ? "warming" : str.tostring(edge, "+0.0;-0.0") + " pts" + (sigStar ? " *" : ""), text_color = (sigN < 20 or na(edge)) ? txtMut : edge > 3 ? cUp : edge < -3 ? cDn : txtMain, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(T, 0, 8, "Runs-Z (streak)", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
    table.cell(T, 1, 8, na(runsZ) ? "warming" : str.tostring(runsZ, "0.0"), text_color = math.abs(nz(runsZ)) > 2.0 ? cDn : txtMut, bgcolor = panelBg, text_size = size.tiny)
    table.cell(T, 0, 9, "Edge floor", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(T, 1, 9, na(edgeLB) ? "warming" : str.tostring(edgeLB, "+0.0;-0.0"), text_color = na(edgeLB) ? txtMut : edgeLB > 0 ? cUp : cDn, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(T, 0, 10, "Eff-TE / sig", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
    table.cell(T, 1, 10, na(teZ) ? "-" : str.tostring(teEff, "0.000") + (math.abs(teZ) >= 2.0 ? " *" : ""), text_color = na(teZ) ? txtMut : math.abs(teZ) >= 2.0 ? txtMain : txtMut, bgcolor = panelBg, text_size = size.tiny)

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
    table.cell(idT, 0, 0, "Lead-Lag Information Flow   -   " + syminfo.ticker + "   -   " + timeframe.period, text_color = dkI ? color.new(#c8d0da, 10) : color.new(#2a2f37, 10), text_size = size.small, text_halign = text.align_center, bgcolor = color.new(color.gray, 100))

// ===== EXP_* EXPORTS  (Data Window, generic names for input.source) =====
showEXP = input.bool(true, "Emit EXP_* exports", group = "Z · Identity & exports")
color exC_ = color.new(color.gray, 100)
plot(showEXP ? (netTE) : na, "EXP_NetTE", color = exC_, display = display.data_window)
plot(showEXP ? (netTE >= teThr ? 1 : netTE <= -teThr ? -1 : 0) : na, "EXP_Lead", color = exC_, display = display.data_window)
plot(showEXP ? (hurst) : na, "EXP_Hurst", color = exC_, display = display.data_window)
plot(showEXP ? (longSig ? 1 : shortSig ? -1 : 0) : na, "EXP_Signal", color = exC_, display = display.data_window)
plot(showEXP ? (edge) : na, "EXP_Edge", color = exC_, display = display.data_window)
plot(showEXP ? (refLive ? 1 : 0) : na, "EXP_DataLive", color = exC_, display = display.data_window)

plot(showEXP ? (teEff) : na, "EXP_TEeff", color = exC_, display = display.data_window)
plot(showEXP ? (teSigVal) : na, "EXP_TEsig", color = exC_, display = display.data_window)
plot(showEXP ? (runsZ) : na, "EXP_RunsZ", color = exC_, display = display.data_window)
plot(showEXP ? (edgeLB) : na, "EXP_EdgeLB", color = exC_, display = display.data_window)
plot(showEXP ? (cusumEvt ? 1 : 0) : na, "EXP_CUSUM", color = exC_, display = display.data_window)
alertcondition(longSig,  "Follow long",      "Lead-Lag Information Flow: reference leads up - chart expected to follow.")
alertcondition(shortSig, "Follow short",     "Lead-Lag Information Flow: reference leads down - chart expected to follow.")
alertcondition(refLeads, "Reference leads",  "Lead-Lag Information Flow: net information flow from reference to chart.")
````
