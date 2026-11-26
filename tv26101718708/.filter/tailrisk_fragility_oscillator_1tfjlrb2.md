# Tail-Risk & Fragility Oscillator

- url: https://www.tradingview.com/script/1TFJlrB2-Tail-Risk-Fragility-Oscillator/
- type: indicator
- pine_id: PUB;af5b8b6fe2ff47288e0b07e3c043b15b
- version: 4.0

## Description

Tail-Risk & Fragility Oscillator

A risk-shape meter — not a buy/sell oscillator. It measures the asymmetry (skewness) and tail-fatness (excess kurtosis) of recent returns to answer one question your momentum and trend tools cannot: is fragile, fat-tailed risk building right now, and on which side? It reads this in plain language, optionally from higher-resolution "realized" data, and forward-calibrates whether those fragile states have actually preceded moves on the symbol you're viewing.

Why these parts are combined (not a mashup for show). Skewness says which tail is heavier (where a violent move is more likely to come from). Excess kurtosis says how heavy the tails are (how likely an outsized move is at all). Neither alone is "fragility" — fragility is one tail heavy AND tails fattening together — so both are combined into one reading. Realized estimation (optional) measures these moments from intrabar returns rather than one value per bar, far less noisy. And a Cornish-Fisher value-at-risk turns skew + kurtosis into a single "expected bad-case move" you can size against. Together they form one coherent tail-risk tool.

How it works. Returns feed central moments over a window: skew = m3/σ³, excess kurtosis = m4/m2² − 3. With "Realized" on, the moments come from a lower-timeframe return stream (confirmed only). The signed wave is standardized skewness; a percentile of kurtosis flags fat tails; a Cornish-Fisher quantile combines both, scaled to the chart timeframe over the calibration horizon, into a value-at-risk. A "fragile-down" state (negative-skew extreme + fat tails) is then scored for a subsequent down move and "fragile-up" for an up move, using triple-barrier outcomes, split into in-sample and recent out-of-sample, with a confidence interval and a multiple-testing check.

How to use. Read the Verdict row — "Downside-fragile" / "Upside-fragile" means a heavy tail is building on that side; "Tails normal" means no fragility. The Conviction row says whether that state has actually preceded the expected move on this symbol. Use it to size down, widen stops, or expect violence on the fragile side — layered on your own directional tool, never as a standalone entry. The "Bad-case move" row is the modelled adverse move over the next N bars at your chosen confidence.

What's original. Realized higher-moment estimation, a horizon-scaled Cornish-Fisher VaR readout, the forward triple-barrier calibration with an out-of-sample split, and a conviction read that openly admits when there's no proven edge — on a risk axis (fragility) that most indicators ignore entirely.

Inputs. Price source (change it for any market), reading mode (Simple/Pro), moment and realized-estimation controls, risk thresholds and VaR confidence, full calibration settings, and an auto-adapting dashboard legible on dark or light charts. Defaults are tuned for NSE:NIFTY1! intraday.

Honesty & limitations. Moments from short windows are noisy and the VaR is a model estimate, not a guarantee. Edge figures are computed on this chart's own history with overlapping windows and no costs — context, not a backtest; past behaviour doesn't predict the future.

Disclaimer: for research and education only. Not financial advice. Trading carries risk of loss; manage your own size.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
// ══════════════════════════════════════════════════════════════════════════════════════════════
// © Market_Logic_India                                                                    MPL-2.0
// TAIL-RISK & FRAGILITY OSCILLATOR — Realized Skew / Kurtosis, Forward-Calibrated              v1.2
// ────────────────────────────────────────────────────────────────────────────────────────────
// v1.1 — House-standard pass (no engine change):
//        • Added the MPL-2.0 licence header, an EXP_ Data-Window export bus, and a round-trip COST
//          model (Net R). The fragile-down / fragile-up states are directional and forward-calibrated
//          on a symmetric 1:1 barrier, so conviction now also requires the edge to survive costs.
//        • No correctness fix needed — no conditional ta.* in this script.
// ────────────────────────────────────────────────────────────────────────────────────────────
// WHAT IT IS
//   A RISK-SHAPE meter, not a buy/sell oscillator. It measures the asymmetry (skewness) and the
//   tail-fatness (excess kurtosis) of recent returns to answer one question your momentum and trend
//   tools cannot: is fragile, fat-tailed risk building right now, and on which side? Negative skew
//   with fattening tails = downside-fragile (crash-prone); positive skew with fattening tails =
//   upside-fragile (squeeze-prone). It reads this in plain language and, where possible, from
//   higher-resolution "realized" data, and it forward-calibrates whether those fragile states have
//   actually preceded moves on the symbol you are viewing.
//
// WHY THESE PARTS ARE COMBINED (read this if you think it is a mashup)
//   Each piece supplies what the others cannot:
//     • Skewness says WHICH tail is heavier (where the violent move is more likely to come from).
//     • Excess kurtosis says HOW heavy the tails are (how likely an outsized move is at all).
//     • Neither alone is "fragility"; fragility is one tail heavy AND tails fattening together, so
//       both are needed and combined into one risk reading.
//     • Realized estimation (optional) measures these moments from intrabar returns instead of one
//       value per bar — far less noisy, the standard approach in modern risk research.
//     • A Cornish-Fisher value-at-risk turns skew+kurtosis into a single "expected bad-case move"
//       number you can size against.
//   An OPTIONAL variance-trend confirmation (off by default) fires a fragile state as a signal only
//   when realized variance is also rising — the more robust early-warning that a large move is
//   actually coming — with the calibration Edge as the arbiter of whether it helps.
//   Together they form one coherent tail-risk tool, not separate studies stacked for show.
//
// HOW IT WORKS
//   Returns (log or simple) feed central moments over a window: skew = m3/σ³, excess kurtosis =
//   m4/m2² − 3. With "Realized" on, the moments are computed from a lower-timeframe return stream
//   via request.security (confirmed only). The signed wave is standardized skewness; a percentile
//   of kurtosis drives a "fat-tails" flag. A Cornish-Fisher quantile combines both into a VaR.
//   Calibration: a "fragile-down" state (negative-skew extreme + fat tails) is scored for a
//   subsequent DOWN move and "fragile-up" for an UP move, using triple-barrier outcomes, split
//   into in-sample and recent out-of-sample, with a confidence interval and a multiple-testing check.
//
// HOW TO USE (plain language)
//   • Read the VERDICT row: "Downside-fragile" / "Upside-fragile" = a heavy tail is building on
//     that side; "Tails normal" = no fragility. This is a RISK warning, not an entry.
//   • The CONVICTION row says whether that fragile state has actually preceded the expected move on
//     THIS symbol. Low conviction = treat as context only.
//   • Use it to SIZE DOWN / widen stops / expect violence on the fragile side — layered on your own
//     directional tool, never as a standalone buy/sell.
//   • Wave near +100 = positive-skew extreme; near −100 = negative-skew extreme; gold tint = fat
//     tails active. The "Bad-case move" row is the modelled tail size.
//
// NON-REPAINT  Reads confirmed closes; the realized read uses confirmed lower-timeframe data only.
//   Calibration logs and resolves on barstate.isconfirmed only.
//
// CONCEPT CREDIT (technical attributions)
//   This script combines established, public-domain techniques: the statistical moments skewness
//   and excess kurtosis; realized higher-moment estimation from intraperiod returns as used in
//   modern quantitative risk research; the Cornish-Fisher quantile expansion for non-normal
//   value-at-risk; triple-barrier outcome labelling from standard supervised-labelling practice;
//   the Wilson score interval for the proportion bound; and the Bonferroni adjustment for multiple
//   testing. Credit is due to the originators of each technique. This is an original implementation
//   combining them into one forward-calibrated tail-risk tool.
//
// v1.2 — Two additive normalization options over v1.1 — the skew/kurtosis moment engine, the realized
//   (lower-timeframe) estimation, the Cornish-Fisher VaR, the fragile-down/up states and the entire
//   forward-calibration harness (triple-barrier, out-of-sample split, Wilson stars, Bonferroni,
//   Net-R cost model) are unchanged:
//     • Wave A — ROBUST normalization (default ON): the skew series can be standardized with a
//       MEDIAN / MAD z (median absolute deviation × 1.4826) instead of mean / stdev. Realized skew is
//       itself outlier-driven — one fat-tail bar dominates it — so a mean/stdev z double-counts those
//       extremes; MAD-z keeps the σ scale stable. Selectable via "Normalization" (group Engine). Set
//       "Classic (mean/stdev)" for the original v1.1 behaviour.
//     • Wave D · U8 — 3-window extreme consensus (opt-in, default OFF): the skew z can be taken as the
//       MEDIAN of the z at half, one and double the normalization window, so a reading is extreme only
//       when short, medium and long windows agree. "Extreme normalization" = "Single window" (default)
//       reproduces v1.1's single-window behaviour.
//   Also pins max_bars_back = 5000 (this script requests lower-timeframe data) for the deeper
//   median/MAD history. No divergence or calibration logic changed.
//
// DISCLAIMER  For research and education only. Moments from short windows are noisy and the VaR is
//   a model estimate, not a guarantee. Edge figures are computed on this chart's own history with
//   overlapping windows and no costs — context, not a backtest, and past behaviour does not predict
//   the future. Nothing here is financial advice. Trading carries risk of loss; manage your own size.
// ══════════════════════════════════════════════════════════════════════════════════════════════
indicator("Tail-Risk & Fragility Oscillator", "Tail Risk", overlay = false, max_lines_count = 100, max_labels_count = 200, max_bars_back = 5000)

// ──────────────────────────────────────────────────────────────────────────────────────────────
// INPUTS  (defaults tuned for NSE:NIFTY1! intraday; change the source to use any market)
// ──────────────────────────────────────────────────────────────────────────────────────────────
gMain    = "1 · General"
srcPrice = input.source(close, "Price source", group = gMain, tooltip = "Raw data the engine reads. Change for any symbol/market — this script is asset-agnostic.")
useLog   = input.bool(true, "Use log returns", group = gMain)
audience = input.string("Simple (plain language)", "Reading mode", options = ["Simple (plain language)", "Pro (full detail)"], group = gMain, tooltip = "Simple shows a verdict and conviction in words. Pro shows every number.")

gEng     = "2 · Moment engine"
mLen     = input.int(50,  "Moment window", minval = 10, maxval = 300, group = gEng)
kurtLook = input.int(150, "Tail-fatness percentile window", minval = 20, maxval = 500, group = gEng)
normLen  = input.int(100, "Skew normalization window", minval = 20, maxval = 500, group = gEng)
zMode    = input.string("Robust (MAD)", "Normalization", options = ["Robust (MAD)","Classic (mean/stdev)"], group = gEng, tooltip = "Robust (MAD) standardizes skew with median / median-absolute-deviation (×1.4826). Skew is already outlier-driven, so a mean/stdev z double-counts fat-tail bars; MAD keeps the σ scale stable. Classic reproduces the original.")
zWinMode = input.string("Single window", "Extreme normalization (Wave D · U8)", options = ["Single window","3-window consensus"], group = gEng, tooltip = "Single window = the one Normalization window above (original). 3-window consensus = z is the MEDIAN of the z at half, one and double that window, so a reading is extreme only when short, medium and long agree. Default Single so nothing changes unless you opt in.")

gReal    = "3 · Realized estimation"
useReal  = input.bool(true, "Use realized (intrabar) returns", group = gReal, tooltip = "Estimate the moments from a lower-timeframe return stream instead of one return per bar — far less noisy. On by default.")
realTf   = input.string("Auto (≈1/5×)", "Sub-timeframe", options = ["Auto (≈1/5×)","1","2","3","5","15"], group = gReal, tooltip = "Lower timeframe whose returns build the realized moments. Auto picks a sensible fraction of your chart timeframe.")

gVar     = "3b · Variance confirmation (optional)"
varGate  = input.bool(false, "Confirm fragility with rising variance", group = gVar, tooltip = "OFF = original behaviour (default). ON = a fragile state fires as a signal only when realized variance is ALSO rising — the more robust early-warning that a large move is actually coming (rising variance precedes crashes more reliably than any single tail read). Watch the calibration Edge to confirm it helps on your instrument.")
vTrendLen= input.int(20, "Variance trend window", minval = 5, maxval = 100, group = gVar)
vTrendThr= input.float(0.20, "Rising threshold", minval = 0.0, maxval = 0.9, step = 0.05, group = gVar, tooltip = "Variance-versus-time correlation above this counts as variance rising.")

gSig     = "4 · Risk thresholds"
skewZone = input.float(50, "Skew extreme zone", minval = 20, maxval = 90, group = gSig)
fatThr   = input.float(70, "Fat-tail percentile (>)", minval = 50, maxval = 99, group = gSig)
varConf  = input.float(95, "Value-at-risk confidence %", minval = 80, maxval = 99.5, step = 0.5, group = gSig)

gCal     = "5 · Forward calibration"
calOn    = input.bool(true, "Run forward calibration", group = gCal, tooltip = "Score fragile states forward on this chart. On by default — the core honesty feature.")
calHor   = input.int(10, "Time limit (bars)", minval = 2, maxval = 200, group = gCal)
barrierK = input.float(1.0, "Profit/stop size × ATR", minval = 0.1, maxval = 10.0, step = 0.1, group = gCal, tooltip = "A fragile state 'wins' if price reaches the expected-side target (this many ATRs) before the opposite barrier, within the time limit.")
atrLen   = input.int(14, "ATR length", minval = 2, maxval = 100, group = gCal)
oosBars  = input.int(1500, "Out-of-sample window (recent bars)", minval = 100, maxval = 20000, group = gCal, tooltip = "States inside the last N bars are scored separately as out-of-sample.")
uniqOn   = input.bool(true, "Non-overlapping sampling", group = gCal, tooltip = "Skip a state if the previous same-side one was within one time-limit — reduces double-counting.")
calMinN  = input.int(20, "Min sample for rating", minval = 5, maxval = 500, group = gCal)
costR    = input.float(0.30, "Round-trip cost (R) — subtracted for NET", minval = 0.0, maxval = 3.0, step = 0.05, group = gCal, tooltip = "Round-trip cost (brokerage + STT + slippage + optimistic fill) as a fraction of the barrier risk (Profit/stop × ATR). The barrier is symmetric 1:1, so gross expectancy in R = 2·hit% − 1; Net R subtracts this cost, and CONVICTION now requires the fragile-state edge to survive it. On 1m NIFTY futures costs eat a large share of R, so a gross edge that ignores them is not tradeable.")

gUI      = "6 · Dashboard & appearance"
showTbl  = input.bool(true, "Show dashboard", group = gUI)
tblPos   = input.string("Top Right", "Dashboard position", options = ["Top Right","Top Left","Bottom Right","Bottom Left"], group = gUI)
dashTheme= input.string("Auto (match chart)", "Color theme", options = ["Auto (match chart)","Dark","Light"], group = gUI, tooltip = "Auto reads the chart background brightness and adapts table, text and line colors for visibility on any theme.")
tintBg   = input.bool(true, "Tint pane when tails are fat", group = gUI)
colUp    = input.color(#2ebd85, "Positive skew", inline = "c", group = gUI)
colDn    = input.color(#f6465d, "Negative skew", inline = "c", group = gUI)
colFat   = input.color(#f0b90b, "Fat tails", group = gUI)

// ──────────────────────────────────────────────────────────────────────────────────────────────
// THEME  (single source of truth — every table, text and line color derives from here)
// ──────────────────────────────────────────────────────────────────────────────────────────────
bgc        = chart.bg_color
lumaV      = na(bgc) ? 0.0 : color.r(bgc)*0.299 + color.g(bgc)*0.587 + color.b(bgc)*0.114
darkUI     = dashTheme=="Dark" ? true : dashTheme=="Light" ? false : (na(bgc) or lumaV < 140)
panelBg    = darkUI ? color.rgb(17,22,28)    : color.rgb(244,246,248)
rowAlt     = darkUI ? color.rgb(25,31,39)    : color.rgb(232,236,240)
txtMain    = darkUI ? color.rgb(236,239,243) : color.rgb(16,20,24)
txtSub     = darkUI ? color.rgb(154,166,178) : color.rgb(74,82,91)
frameC     = darkUI ? color.rgb(58,70,84)    : color.rgb(196,204,212)
posC       = darkUI ? colUp : color.rgb(22,151,106)
negC       = darkUI ? colDn : color.rgb(200,42,64)
fatC       = colFat
flatC      = darkUI ? color.rgb(120,130,140) : color.rgb(122,130,139)
gridC      = darkUI ? color.new(color.gray, 55) : color.new(color.gray, 45)

// ── HELPERS ───────────────────────────────────────────────────────────────────────────────────
f_pos(string s) => s=="Top Left"?position.top_left : s=="Bottom Right"?position.bottom_right : s=="Bottom Left"?position.bottom_left : position.top_right
f_zscore(float s, int len) =>
    sd = ta.stdev(s, len)
    mn = ta.sma(s, len)
    sd == 0 ? 0.0 : (s - mn) / sd
// robust z: median / MAD (×1.4826). ta.median calls unconditional → compiles clean.
f_robZ(float s, int len) =>
    float med = ta.median(s, len)
    float mad = ta.median(math.abs(s - med), len)
    mad > 1e-10 ? (s - med) / (1.4826 * mad) : 0.0
f_tanh(float x) =>
    float xc = math.max(-10.0, math.min(10.0, x))
    float e = math.exp(2 * xc)
    (e - 1) / (e + 1)
f_squash(float x, float k) => 100.0 * f_tanh(x / math.max(k, 0.0001))
f_wilson(int w, int n, float z) =>
    if n <= 0
        na
    else
        p = w / n
        (p + z*z/(2*n) - z*math.sqrt(p*(1-p)/n + z*z/(4*n*n))) / (1 + z*z/n) * 100.0
f_stars(float wl, float base, int n) =>
    n < calMinN or na(wl) or na(base) ? "n/a" : wl > base+5 ? "★★★" : wl > base ? "★★" : wl > base-5 ? "★" : "—"
f_firstHit(float up, float lo, int hor) =>
    int fh = 0
    bool done = false
    for i = 0 to hor - 1
        off = hor - 1 - i
        if not done
            hi = high[off]
            ll = low[off]
            bu = hi >= up
            bd = ll <= lo
            if bu and bd
                fh := 2
                done := true
            else if bu
                fh := 1
                done := true
            else if bd
                fh := -1
                done := true
    fh
// Inverse standard normal (Acklam approximation) for the VaR quantile
f_invnorm(float p) =>
    float a1 = -39.6968302866538
    float a2 = 220.946098424521
    float a3 = -275.928510446969
    float a4 = 138.357751867269
    float a5 = -30.6647980661472
    float a6 = 2.50662827745924
    float b1 = -54.4760987982241
    float b2 = 161.585836858041
    float b3 = -155.698979859887
    float b4 = 66.8013118877197
    float b5 = -13.2806815528857
    float c1 = -0.00778489400243029
    float c2 = -0.322396458041136
    float c3 = -2.40075827716184
    float c4 = -2.54973253934373
    float c5 = 4.37466414146497
    float c6 = 2.93816398269878
    float d1 = 0.00778469570904146
    float d2 = 0.32246712907004
    float d3 = 2.445134137143
    float d4 = 3.75440866190742
    float pl = 0.02425
    float q = 0.0
    float r = 0.0
    float x = 0.0
    if p < pl
        q := math.sqrt(-2*math.log(p))
        x := (((((c1*q+c2)*q+c3)*q+c4)*q+c5)*q+c6) / ((((d1*q+d2)*q+d3)*q+d4)*q+1)
    else if p <= 1 - pl
        q := p - 0.5
        r := q*q
        x := (((((a1*r+a2)*r+a3)*r+a4)*r+a5)*r+a6)*q / (((((b1*r+b2)*r+b3)*r+b4)*r+b5)*r+1)
    else
        q := math.sqrt(-2*math.log(1-p))
        x := -(((((c1*q+c2)*q+c3)*q+c4)*q+c5)*q+c6) / ((((d1*q+d2)*q+d3)*q+d4)*q+1)
    x
f_htf_sub() =>
    float tfm = timeframe.in_seconds(timeframe.period) / 60.0
    realTf != "Auto (≈1/5×)" ? realTf : tfm<=2 ? "1" : tfm<=5 ? "1" : tfm<=15 ? "3" : tfm<=60 ? "5" : "15"

// ── MOMENTS (realized or bar-return) ─────────────────────────────────────────────────────────
f_moments(float src, simple int win, simple bool logr) =>
    r = logr ? math.log(src / src[1]) : (src - src[1])
    mean = ta.sma(r, win)
    dev  = r - mean
    m2   = ta.sma(dev*dev, win)
    m3   = ta.sma(dev*dev*dev, win)
    m4   = ta.sma(dev*dev*dev*dev, win)
    sd   = math.sqrt(math.max(m2, 0.0))
    sk   = sd > 0 ? m3 / (sd*sd*sd) : 0.0
    ku   = m2 > 0 ? m4 / (m2*m2) - 3.0 : 0.0
    [sk, ku, sd]

subTf = f_htf_sub()
[skR, kuR, sdR] = request.security(syminfo.tickerid, subTf, f_moments(close, mLen, useLog), lookahead = barmerge.lookahead_off)
[skB, kuB, sdB] = f_moments(srcPrice, mLen, useLog)
skew = useReal ? skR : skB
kurt = useReal ? kuR : kuB
sdv  = useReal ? sdR : sdB

kurtPct = ta.percentrank(kurt, kurtLook)
fatTails = kurtPct > fatThr
// Wave A: compute both z-scores unconditionally, then select
// U8 (Wave D): z at three windows (unconditional), select by mode, optional median consensus.
int   _wS = math.max(5, int(normLen / 2))
int   _wL = int(normLen * 2)
float _zcS = f_zscore(skew, _wS), _zcM = f_zscore(skew, normLen), _zcL = f_zscore(skew, _wL)
float _zrS = f_robZ(skew, _wS),  _zrM = f_robZ(skew, normLen),  _zrL = f_robZ(skew, _wL)
bool  _uCl = zMode == "Classic (mean/stdev)"
float _zS = _uCl ? _zcS : _zrS
float _zM = _uCl ? _zcM : _zrM
float _zL = _uCl ? _zcL : _zrL
float _zMed = _zS + _zM + _zL - math.min(_zS, math.min(_zM, _zL)) - math.max(_zS, math.max(_zM, _zL))
skewZ = zWinMode == "Single window" ? _zM : _zMed
wave  = f_squash(skewZ * 33, 100)

// Cornish-Fisher value-at-risk (lower-tail, as a positive "bad-case move" magnitude in %)
zc = f_invnorm(1 - varConf/100.0)
cf = zc + (zc*zc - 1)*skew/6.0 + (zc*zc*zc - 3*zc)*kurt/24.0 - (2*zc*zc*zc - 5*zc)*skew*skew/36.0
varMove = math.abs(cf) * sdB * math.sqrt(calHor) * 100.0   // chart-bar sd, scaled to the horizon, % adverse move

// fragile states
fragileDown = wave < -skewZone and fatTails    // negative-skew extreme + fat tails
fragileUp   = wave >  skewZone and fatTails    // positive-skew extreme + fat tails
// optional variance-trend confirmation (rising variance = the robust early-warning)
float vRet = useLog ? math.log(srcPrice / srcPrice[1]) : (srcPrice - srcPrice[1])
float vVar = ta.variance(vRet, mLen)
bool  varRising = ta.correlation(vVar, bar_index, vTrendLen) > vTrendThr
newDown = fragileDown and not fragileDown[1] and (not varGate or varRising)
newUp   = fragileUp and not fragileUp[1] and (not varGate or varRising)
wCol    = wave >= 0 ? posC : negC
phaseTxt = fatTails ? (wave>=0 ? "Upside-fragile" : "Downside-fragile") : "Tails normal"

// ── CALIBRATION (triple-barrier + OOS + uniqueness + Bonferroni) ─────────────────────────────
atrSeries = ta.atr(atrLen)
var int dnN = 0
var int dnW = 0
var int dnNo = 0
var int dnWo = 0
var int upN = 0
var int upW = 0
var int upNo = 0
var int upWo = 0
var int baseN = 0
var int baseW = 0
var int lastDnBar = -1000000
var int lastUpBar = -1000000

canEval = calOn and barstate.isconfirmed and not na(close[calHor]) and not na(atrSeries[calHor])
if canEval
    entryB = close[calHor]
    aB = atrSeries[calHor]
    fhB = f_firstHit(entryB + barrierK*aB, entryB - barrierK*aB, calHor)
    baseN += 1
    baseW += (fhB == -1 or (fhB == 0 and close < entryB)) ? 1 : 0     // base = chance of a DOWN resolution
    // fragile-down -> expect a down move (lower barrier first)
    if newDown[calHor]
        sigBar = bar_index[calHor]
        okD = (not uniqOn) or (sigBar - lastDnBar >= calHor)
        if okD
            win = fhB == -1 or (fhB == 0 and close < entryB)
            dnN += 1
            dnW += win ? 1 : 0
            if sigBar >= last_bar_index - oosBars
                dnNo += 1
                dnWo += win ? 1 : 0
            lastDnBar := sigBar
    // fragile-up -> expect an up move (upper barrier first)
    if newUp[calHor]
        sigBarU = bar_index[calHor]
        okU = (not uniqOn) or (sigBarU - lastUpBar >= calHor)
        if okU
            winU = fhB == 1 or (fhB == 0 and close > entryB)
            upN += 1
            upW += winU ? 1 : 0
            if sigBarU >= last_bar_index - oosBars
                upNo += 1
                upWo += winU ? 1 : 0
            lastUpBar := sigBarU

baseDn  = baseN > 0 ? baseW / baseN * 100.0 : na      // base chance of a down resolution
baseUp  = baseN > 0 ? 100.0 - baseDn : na
dnHit  = dnN  > 0 ? dnW  / dnN  * 100.0 : na
upHit  = upN  > 0 ? upW  / upN  * 100.0 : na
dnHitO = dnNo  > 0 ? dnWo  / dnNo  * 100.0 : na
upHitO = upNo  > 0 ? upWo  / upNo  * 100.0 : na
dnEdge  = (not na(dnHit) and not na(baseDn)) ? dnHit - baseDn : na
upEdge  = (not na(upHit) and not na(baseUp)) ? upHit - baseUp : na
dnStars = f_stars(f_wilson(dnW, dnN, 1.96), baseDn, dnN)
upStars = f_stars(f_wilson(upW, upN, 1.96), baseUp, upN)
dnSurv  = (dnN >= calMinN and not na(baseDn)) and (f_wilson(dnW, dnN, 2.24) > baseDn)
upSurv  = (upN >= calMinN and not na(baseUp)) and (f_wilson(upW, upN, 2.24) > baseUp)

// ── COST MODEL (Net R on the symmetric 1:1 barrier) ───────────────────────────────────────────
float dnNetR = na(dnHit) ? na : (2.0 * dnHit / 100.0 - 1.0) - costR
float upNetR = na(upHit) ? na : (2.0 * upHit / 100.0 - 1.0) - costR

// ── PLAIN-LANGUAGE VERDICT + CONVICTION ──────────────────────────────────────────────────────
dnConv = dnN >= calMinN and not na(dnEdge) and dnEdge > 0 and dnSurv and not na(dnNetR) and dnNetR > 0
upConv = upN >= calMinN and not na(upEdge) and upEdge > 0 and upSurv and not na(upNetR) and upNetR > 0
verdict = fragileDown ? "DOWNSIDE-FRAGILE" : fragileUp ? "UPSIDE-FRAGILE" : fatTails ? "Fat tails — no skew" : "Tails normal"
vCol    = fragileDown ? negC : fragileUp ? posC : fatTails ? fatC : flatC
convTxt = (fragileDown and dnConv) or (fragileUp and upConv) ? "High — risk has paid here" : (fragileDown or fragileUp) ? "Low — context only" : dnConv or upConv ? "Fragile states have edge here" : "No proven edge here"
convCol = ((fragileDown and dnConv) or (fragileUp and upConv)) ? fatC : flatC

// ── PLOTS (theme-aware) ──────────────────────────────────────────────────────────────────────
pObIn  = plot(skewZone,  "Pos edge", color.new(posC, 45), 1)
pObOut = plot(100.0,     "Pos cap",  color.new(posC, 100), display = display.none)
fill(pObIn, pObOut, 100.0, 50.0, color.new(posC, 30), color.new(posC, 95), title = "Positive-skew zone")
pOsIn  = plot(-skewZone, "Neg edge", color.new(negC, 45), 1)
pOsOut = plot(-100.0,    "Neg cap",  color.new(negC, 100), display = display.none)
fill(pOsIn, pOsOut, -50.0, -100.0, color.new(negC, 95), color.new(negC, 30), title = "Negative-skew zone")
plot(0, "Zero", gridC, 1)
bgcolor(tintBg and fatTails ? color.new(fatC, 90) : na, title = "Fat-tails tint")

plot(wave, "Skew glow", color.new(wCol, 70), 8)
plot(wave, "Skew", color.new(wCol, 0), 2)

plotshape(newDown ? wave : na, "Down-fragile", shape.diamond, location.absolute, color.new(negC,0), size = size.tiny)
plotshape(newUp   ? wave : na, "Up-fragile",   shape.diamond, location.absolute, color.new(posC,0), size = size.tiny)
plotshape(newDown, "Down mark", shape.diamond, location.abovebar, color.new(negC,0), size = size.tiny, force_overlay = true)
plotshape(newUp,   "Up mark",   shape.diamond, location.belowbar, color.new(posC,0), size = size.tiny, force_overlay = true)

// ── DASHBOARD ───────────────────────────────────────────────────────────────────────────────
simple = audience == "Simple (plain language)"
var table st = table.new(f_pos(tblPos), 2, 14, frame_width = 1, border_width = 1)
if showTbl and barstate.islast
    color hdr   = color.new(negC, 0)
    color skCol = wave>=0?posC:negC
    table.set_bgcolor(st, panelBg)
    table.set_frame_color(st, frameC)
    table.set_border_color(st, frameC)
    int r = 0
    table.cell(st, 0, r, "Tail Risk & Fragility", text_color = color.white, bgcolor = hdr, text_size = size.tiny)
    table.cell(st, 1, r, str.upper(phaseTxt), text_color = color.white, bgcolor = hdr, text_size = size.tiny)
    r += 1
    table.cell(st, 0, r, "Verdict", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(st, 1, r, verdict, text_color = vCol, bgcolor = rowAlt, text_size = size.tiny)
    r += 1
    table.cell(st, 0, r, "Conviction", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
    table.cell(st, 1, r, calOn ? convTxt : "calibration off", text_color = convCol, bgcolor = panelBg, text_size = size.tiny)
    r += 1
    table.cell(st, 0, r, "Bad-case move", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(st, 1, r, str.tostring(varMove,"0.00") + "% /" + str.tostring(calHor) + "b @ " + str.tostring(varConf,"0") + "%", text_color = txtMain, bgcolor = rowAlt, text_size = size.tiny)
    r += 1
    if not simple
        table.cell(st, 0, r, "Skew / Kurt", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
        table.cell(st, 1, r, str.tostring(skew,"0.00") + " / " + str.tostring(kurt,"0.0"), text_color = skCol, bgcolor = panelBg, text_size = size.tiny)
        r += 1
        table.cell(st, 0, r, "Tail %ile", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
        table.cell(st, 1, r, str.tostring(kurtPct,"#") + (fatTails?" · FAT":"") + (useReal?" · realized":""), text_color = fatTails?fatC:txtMain, bgcolor = rowAlt, text_size = size.tiny)
        r += 1
    if calOn
        string baseTxt = (na(baseUp) or na(baseDn)) ? "warming up" : "dn " + str.tostring(baseDn,"0") + "%  up " + str.tostring(baseUp,"0") + "%"
        string dnTxt = dnN < calMinN ? "warming " + str.tostring(dnN) : "hit " + str.tostring(dnHit,"0") + "%  edge " + (nz(dnEdge)>=0?"+":"") + str.tostring(dnEdge,"0") + "  (" + str.tostring(dnN) + ")"
        string upTxt = upN < calMinN ? "warming " + str.tostring(upN) : "hit " + str.tostring(upHit,"0") + "%  edge " + (nz(upEdge)>=0?"+":"") + str.tostring(upEdge,"0") + "  (" + str.tostring(upN) + ")"
        table.cell(st, 0, r, "Base " + str.tostring(calHor) + "b", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
        table.cell(st, 1, r, baseTxt, text_color = txtMain, bgcolor = panelBg, text_size = size.tiny)
        r += 1
        table.cell(st, 0, r, "Dn-fragile " + dnStars, text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
        table.cell(st, 1, r, dnTxt, text_color = dnN<calMinN?flatC:negC, bgcolor = rowAlt, text_size = size.tiny)
        r += 1
        table.cell(st, 0, r, "Up-fragile " + upStars, text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
        table.cell(st, 1, r, upTxt, text_color = upN<calMinN?flatC:posC, bgcolor = panelBg, text_size = size.tiny)
        r += 1
        string netTxt = (na(dnNetR) or na(upNetR)) ? "warming" : "Dn " + (dnNetR>=0?"+":"") + str.tostring(dnNetR,"0.00") + " · Up " + (upNetR>=0?"+":"") + str.tostring(upNetR,"0.00") + " R  (cost " + str.tostring(costR,"0.00") + ")"
        color netCol = (na(dnNetR) or na(upNetR)) ? flatC : (dnNetR > 0 or upNetR > 0) ? fatC : flatC
        table.cell(st, 0, r, "Net R", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
        table.cell(st, 1, r, netTxt, text_color = netCol, bgcolor = rowAlt, text_size = size.tiny)
        r += 1
        if not simple
            string dnOTxt = dnNo < calMinN ? "warming " + str.tostring(dnNo) : "hit " + str.tostring(dnHitO,"0") + "%  (" + str.tostring(dnNo) + ")"
            string upOTxt = upNo < calMinN ? "warming " + str.tostring(upNo) : "hit " + str.tostring(upHitO,"0") + "%  (" + str.tostring(upNo) + ")"
            table.cell(st, 0, r, "Out-of-sample", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
            table.cell(st, 1, r, "Dn " + dnOTxt + " · Up " + upOTxt, text_color = txtMain, bgcolor = rowAlt, text_size = size.tiny)
            r += 1
            table.cell(st, 0, r, "Multi-test", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
            table.cell(st, 1, r, "dn " + (dnSurv?"survives":"no") + " · up " + (upSurv?"survives":"no"), text_color = txtMain, bgcolor = panelBg, text_size = size.tiny)
            r += 1
    if varGate
        table.cell(st, 0, r, "Variance", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
        table.cell(st, 1, r, varRising ? "RISING · confirms" : "flat/falling · gates out", text_color = varRising ? negC : txtSub, bgcolor = panelBg, text_size = size.tiny)
        r += 1
    table.cell(st, 0, r, "Note", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(st, 1, r, "risk shape, not a buy/sell", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)

// ── GENERIC EXPORTS (for use from other scripts) ─────────────────────────────────────────────
plot(skew,    "EXP_Skew",       color.new(color.gray,100), display = display.data_window)
plot(kurt,    "EXP_Kurtosis",   color.new(color.gray,100), display = display.data_window)
plot(wave,    "EXP_SkewWave",   color.new(color.gray,100), display = display.data_window)
plot(kurtPct, "EXP_TailPct",    color.new(color.gray,100), display = display.data_window)
plot(varMove, "EXP_VaRpct",     color.new(color.gray,100), display = display.data_window)
plot(sdv,     "EXP_ReturnSD",   color.new(color.gray,100), display = display.data_window)
plot(fragileDown?1:fragileUp?-1:0, "EXP_Fragile", color.new(color.gray,100), display = display.data_window)
plot(fatTails?1:0, "EXP_FatTails", color.new(color.gray,100), display = display.data_window)
plot(na(dnNetR) ? na : dnNetR, "EXP_DownNetR", color.new(color.gray,100), display = display.data_window)
plot(na(upNetR) ? na : upNetR, "EXP_UpNetR",   color.new(color.gray,100), display = display.data_window)

alertcondition(newDown, "Downside fragility", "Tail Risk: downside-fragile (negative skew + fat tails)")
alertcondition(newUp,   "Upside fragility",   "Tail Risk: upside-fragile (positive skew + fat tails)")
alertcondition(fatTails and not fatTails[1], "Fat tails on", "Tail Risk: tails entered fat regime")
````
