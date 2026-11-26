# Adaptive Volume Confluence Oscillator

- url: https://www.tradingview.com/script/KR8etS2U-Adaptive-Volume-Confluence-Oscillator/
- type: indicator
- pine_id: PUB;202fce4e48644ac186188500a0c25b70
- version: 4.0

## Description

What it is

One pane that fuses seven different reads of the bar into a single 0–100 confluence score, gates that score by a trend-vs-chop regime filter, confirms it against an auto-mapped higher timeframe, and — most importantly — forward-calibrates its own Buy/Sell signals against an unconditional base rate, so you can see whether the construction actually carries an edge on your instrument.

The seven votes: momentum sign · momentum vs its signal · money flow · trend structure (MA fan) · price location vs VWAP · trend slope · higher-timeframe bias.

The displayed wave is a volume-flow ribbon; the votes drive the score, the signals and the verdict. A plain-language verdict and a subtle pane tint make it readable at a glance (Simple view); a full analytic layer is available for advanced users (Pro view).

Why these are combined (mashup rationale)

A single oscillator whipsaws and a single signal over-fires. Combining helps only when the inputs key on different quantities and their agreement is checked. Each vote reads a different thing — momentum, momentum-vs-signal, volume flow, multi-MA structure, location vs a session mean, slope, and a higher-timeframe read — so the count that agrees carries more information than any one of them alone. A Kaufman Efficiency-Ratio regime gate suppresses conviction in chop, and a forward-calibration harness ties the whole construction back to realised forward outcomes.

An honest caveat, stated up front: the votes are not statistically independent. The oscillator itself embeds money flow, and vote 2 is derived from vote 1's series. Treat the score as a weight-of-evidence read, not as seven independent confirmations. The harness exists precisely so you can check whether the construction earns its keep on your instrument rather than taking the claim on faith.

How it works


Score — how many of the seven votes are bullish, scaled 0–100.
Regime — Kaufman Efficiency Ratio. Below the chop threshold, conviction dims, signals are withheld, and the verdict reads "WAIT – choppy".
HTF — the chart timeframe auto-maps to a confirming higher timeframe (~4–6×), requested with lookahead_off and offset by one bar while the live bar forms.
Signals — Buy/Sell fire only when the oscillator crosses its signal at a statistical OB/OS extreme and the score agrees and the regime isn't choppy and the visible wave isn't already at the opposite extreme.
Climax — a volume spike at an OB/OS extreme prints a Possible Bottom/Top exhaustion mark.
Divergence (Pro) — regular + hidden, from confirmed pivots on the momentum oscillator.
Calibration — each Buy/Sell is queued and resolved a fixed horizon later, then compared with the unconditional same-horizon base rate. The dashboard shows, per side: Hit %, Edge = Hit − Base, sample size, and a Wilson-gated star.


How to use it


Read the verdict and the score. Above the gate = bullish weight of evidence; below = bearish; in between, or in chop, the tool says WAIT — and it means it.
Treat Buy/Sell marks as context, not triggers. They already require the score, the regime and the wave to agree, but they remain a description of conditions — not a recommendation.
Read the Edge row before you weight any signal. If Buy/Sell Edge isn't clearly positive with an adequate sample and a star, this construction is not carrying an edge on this instrument — weight it down or ignore it. Do not tune the parameters until the Edge turns green: that is curve-fitting, and the harness is there to catch it, not to be defeated.
Combine with your own levels, structure and risk rules.


Universal across markets

Price / high / low are inputs, so the engine runs on any symbol or timeframe. The volume votes (money flow, climax, VWAP location) need real volume — prefer a futures contract or a stock. On a symbol with no volume the tool degrades gracefully: money flow is neutralised, the score falls back to the price-only votes, and the dashboard says "NO VOLUME", so you're never misled by a blank or a phantom reading.

Non-repainting

Votes read confirmed closes. The HTF series uses lookahead_off and is offset by one bar while the live bar forms. Divergences come from ta.pivot* and confirm a few bars after the pivot; once printed they don't move. The calibration harness logs and resolves only on confirmed bars, so its statistics never inflate intrabar. The live oscillator updates each bar, like any oscillator.

Concept credits

Super Smoother and Ultimate Smoother low-lag filters — John Ehlers. Chebyshev Type-I filter — classical DSP. Recursive (Kalman) smoothing — R. E. Kalman. Volume Zone Oscillator — Walid Khalil & David Steckler. Accumulation/Distribution money-flow multiplier — Marc Chaikin. Efficiency Ratio — Perry J. Kaufman. ATR — J. Welles Wilder. Wilson score interval — Edwin B. Wilson. VWAP, Hull MA and percentile rank — standard public methods.

Original implementation; not affiliated with, nor endorsed by, any third party. No third-party code is reused.

Honest limits

The score is context, not a guarantee, and the votes are correlated (see the caveat above). The Edge figures are in-sample, close-to-close, with overlapping forward windows and no costs — descriptive context, not a verified backtest. An Edge near zero, negative, or unstable across timeframes is the harness honestly telling you the signal has no reliable edge on that instrument. Nothing here predicts price.

Disclaimer

Research and educational tool only. Not financial advice and no guarantee of profitability or accuracy. Indicators describe past behaviour; they do not predict the future. Trading carries risk of loss. Test out-of-sample and make your own decisions. The author accepts no liability for any use of this script.

## Source Code

````pine
//@version=6
// ══════════════════════════════════════════════════════════════════════════════════════════════
// ADAPTIVE VOLUME CONFLUENCE OSCILLATOR                                                  v1.1
// ────────────────────────────────────────────────────────────────────────────────────────────
// THIS UPDATE (from a full audit)
//   [FIX] Integer division was truncating three calculations to 0/1: the trend-structure
//         vote (MA-fan rank), and — more importantly — every forward-calibration figure
//         (Hit %, base %, Edge) and the Wilson star. All three now compute true fractional
//         rates, so vote 4 and the whole calibration harness finally work as designed.
//         (Expect the confluence score and signals to reflect the corrected vote.)
//   [SPEED] A dead Chaikin money-flow chain (two windowed ta.* calls per bar) was removed;
//         a per-bar array fetch and pair count in the rank loop were hoisted; the dashboard
//         strings are built only on the last bar. The trend-structure "fan" (vote 4) now
//         uses incremental EMAs — O(1) per average instead of recomputing SMAs in a loop —
//         which is faster AND removes Pine's CW10003 "call ta.* on every bar" warning. (The
//         fan is now an EMA fan rather than an SMA fan; a more responsive, standard trend-
//         structure read, and since the old vote was truncated to ~0 by the bug above it
//         barely contributed before — this is net a correctness + robustness fix.)
//   [VISUALS] The pane tint now darkens with conviction and the flow-glow brightens with
//         flow strength, so the strength of the move reads at a glance, not just its side.
//   [ON-PRICE] The Buy / Sell setups now print as BRIGHT triangles directly on the price
//         chart (force-overlay, default ON, colours tunable, optional text labels), so a
//         single indicator gives you both the on-chart signals and the full pane analysis.
//   [TIDY] The verdict reads "Long/Short setup" (was "BUY/SELL setup") and the one
//         home-market wording was genericized. No symbol is hardcoded.
// ────────────────────────────────────────────────────────────────────────────────────────────
// WHAT IT IS
//   One pane that fuses SEVEN independent reads of the bar into a single 0-100 confluence score,
//   gates that score by a trend-vs-chop regime filter, confirms it against an auto-mapped higher
//   timeframe, and FORWARD-CALIBRATES its own Buy/Sell signals against an unconditional base rate.
//   A plain-language verdict and a subtle pane tint make it readable at a glance (Simple mode); a
//   full analytic layer is available for advanced users (Pro mode). The displayed wave is a
//   volume-flow ribbon; the seven votes drive the score, the signals and the verdict.
//
//   The seven votes (each up = bullish, independent physical quantity):
//     1 Momentum direction        2 Momentum acceleration     3 Money flow (volume)
//     4 Trend structure (MA fan)  5 Price location (vs VWAP)   6 Trend slope (angle)
//     7 Higher-timeframe bias
//
// WHY THESE ARE COMBINED  (mashup rationale)
//   A single oscillator whipsaws and a single signal over-fires; combining only helps when the
//   inputs are INDEPENDENT and their agreement is CHECKED. Each vote keys on a different quantity
//   - momentum, acceleration, volume flow, multi-MA structure, location vs a session mean, slope,
//   and a higher-timeframe read - so the COUNT that agrees is informative rather than redundant.
//   A Kaufman Efficiency-Ratio regime gate suppresses conviction in chop, and a forward
//   calibration harness ties the whole construction back to realised forward outcomes.
//
// HOW IT WORKS
//   - SCORE: how many of the seven votes are bullish, scaled 0-100.
//   - REGIME: Kaufman Efficiency Ratio. Below the chop threshold, conviction dims, signals are
//     withheld and the verdict reads "WAIT - choppy".
//   - HTF: chart timeframe is auto-mapped to a confirming higher timeframe (~4-6x), requested with
//     lookahead_off. Scalper-aware: 1m->5m, 2m->10m, 3m->15m, 5m->15m, 15m->60m, 30m->120m, 1h->240m.
//   - SIGNALS: Buy/Sell fire only when the oscillator crosses its signal at an OB/OS extreme AND
//     the confluence score agrees AND the regime is not choppy.
//   - CLIMAX: a volume spike at an OB/OS extreme prints a Possible Bottom/Top exhaustion mark.
//   - DIVERGENCE (Pro): regular + hidden, from CONFIRMED pivots on the momentum oscillator.
//   - CALIBRATION: each Buy/Sell is queued and resolved calHor bars later, then compared with the
//     unconditional same-horizon base rate. The dashboard shows, per side: Hit %, Edge = Hit-Base,
//     n, and a Wilson-gated star. Logged on CONFIRMED bars only, so the statistics never repaint.
//
// UNIVERSAL ACROSS MARKETS  (configurable data source)
//   Price / high / low are inputs, so the engine runs on any symbol or timeframe. Volume features
//   (money flow, climax, VWAP) need real volume - use the futures contract, not a cash index;
//   price-vs-VWAP falls back to momentum where volume is absent. Defaults suit a liquid
//   index-futures contract on an intraday timeframe; change the Data-Source inputs for any
//   other instrument. No symbol is hardcoded - every fetch uses the chart's own ticker.
//
// NON-REPAINT
//   Votes read confirmed closes. The HTF series is requested with lookahead_off and offset on the
//   live bar. Divergence comes from ta.pivot* and confirms a few bars after the pivot; once printed
//   it does not move. The calibration harness logs AND resolves only on barstate.isconfirmed.
//
// CONCEPT CREDIT
//   Super Smoother low-lag filter - John Ehlers. Chebyshev Type-I filter - classical DSP.
//   Recursive (Kalman) smoothing - R. E. Kalman. Volume Zone Oscillator - Walid Khalil & David
//   Steckler. Accumulation/Distribution money-flow multiplier - Marc Chaikin. Efficiency Ratio -
//   Perry J. Kaufman. ATR - J. Welles Wilder. VWAP, percentile rank and the Wilson score interval
//   - standard public methods. Original implementation; not affiliated with, nor endorsed by, any
//   third party.
//
// HONESTY / LIMITATIONS
//   The score is context, not a guarantee. The Edge figures are IN-SAMPLE, close-to-close, with
//   OVERLAPPING forward windows and NO costs - descriptive context, not a verified backtest. An
//   Edge near zero, negative, or unstable across timeframes is the harness honestly telling you
//   the signal has no reliable edge on that instrument; do NOT tune parameters until it turns
//   green - that is curve-fitting. Nothing here predicts price.
//
// DISCLAIMER
//   Research and educational tool only. NOT financial advice and NO guarantee of profitability or
//   accuracy. Indicators describe past behaviour; they do not predict the future. Trading carries
//   risk of loss. Test out-of-sample and make your own decisions. The author accepts no liability
//   for any use of this script.
// ══════════════════════════════════════════════════════════════════════════════════════════════
indicator("Adaptive Volume Confluence Oscillator", "Vol Conf", overlay = false,
     max_lines_count = 100, max_labels_count = 200)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                          INPUTS
// ═════════════════════════════════════════════════════════════════════════════════════════

// ── 1 · DISPLAY ─────────────────────────────────────────────────────────────────────────────
gDisp    = "1 · Display"
view     = input.string("Simple", "Audience", options = ["Simple","Pro"], group = gDisp,
     tooltip = "Simple: clean, plain-language read for any user. Pro: full analytic layer + exports.")
showTint = input.bool(true, "Tint pane by context", group = gDisp,
     tooltip = "Subtle green / red / grey background = bullish / bearish / chop at a glance.")
showPriceSig = input.bool(true, "Buy / Sell triangles on price", group = gDisp,
     tooltip = "Draws the Buy / Sell setups as bright triangles directly on the PRICE chart (force-overlay), so you get the on-chart signals and the pane analysis from one indicator.")
showPriceLbl = input.bool(false, "Text labels on price signals", group = gDisp,
     tooltip = "Adds a 'BUY' / 'SELL' text label at each on-price setup in addition to the triangle. Off by default for a cleaner chart.")
sigBuyCol  = input.color(#00ff00, "Buy signal colour",  inline = "sig", group = gDisp)
sigSellCol = input.color(#ff0000, "Sell signal colour", inline = "sig", group = gDisp)

// ── 2 · DATA SOURCE  (change these for any asset / market) ──────────────────────────────────
gData    = "2 · Data source"
srcPrice = input.source(close, "Price source", group = gData)
srcHigh  = input.source(high,  "High source (bearish-pivot reference)", group = gData)
srcLow   = input.source(low,   "Low source (bullish-pivot reference)",  group = gData)

// ── 3 · MOMENTUM CORE ───────────────────────────────────────────────────────────────────────
gMom     = "3 · Momentum core"
momLen   = input.int(20,  "Momentum length",      minval = 2,  maxval = 200, group = gMom)
normLen  = input.int(100, "Normalization window", minval = 20, maxval = 500, group = gMom)
filterT  = input.string("Super Smoother", "Low-lag filter", options = ["Super Smoother","Ultimate Smoother","Chebyshev"], group = gMom)
smoothLen= input.int(8,   "Smoothing",            minval = 1,  maxval = 50,  group = gMom)
ripple   = input.float(0.05, "Chebyshev ripple",  minval = 0.01, maxval = 0.50, step = 0.01, group = gMom)
sigLen   = input.int(9,   "Signal length",        minval = 1,  maxval = 50,  group = gMom)

// ── 4 · VOLUME / MONEY FLOW ─────────────────────────────────────────────────────────────────
gVol     = "4 · Volume / money flow"
volLen   = input.int(70,  "Volume length",        minval = 2,  maxval = 300, group = gVol)
kCoef    = input.float(0.10, "Kalman coefficient", minval = 0.01, maxval = 0.30, step = 0.01, group = gVol)
volWeight= input.float(0.40, "Volume weight",      minval = 0.0, maxval = 1.0, step = 0.05, group = gVol,
     tooltip = "0 = pure momentum, 1 = pure volume flow.")
mvpFastL = input.int(8,   "Ribbon fast",          minval = 1,  maxval = 100, group = gVol)
mvpSlowL = input.int(21,  "Ribbon slow",          minval = 2,  maxval = 200, group = gVol)

// ── 5 · CONFLUENCE & REGIME ─────────────────────────────────────────────────────────────────
gConf    = "5 · Confluence & regime"
clN      = input.int(8,  "Trend-cluster size",    minval = 3,  maxval = 20,  group = gConf)
clBase   = input.int(5,  "Cluster base length",   minval = 2,  maxval = 100, group = gConf)
clSpace  = input.int(4,  "Cluster spacing",       minval = 1,  maxval = 20,  group = gConf)
erLen    = input.int(20, "Efficiency length",     minval = 2,  maxval = 200, group = gConf)
erThresh = input.float(0.30, "Chop threshold",    minval = 0.05, maxval = 0.80, step = 0.05, group = gConf,
     tooltip = "Below this efficiency = chop; conviction dims and Simple mode says 'wait'.")
sigScore = input.int(57, "Signal confluence gate (%)", minval = 50, maxval = 100, group = gConf,
     tooltip = "Buy/Sell fire only when the confluence score agrees by at least this %.")

// ── 6 · HIGHER-TIMEFRAME BIAS  (adaptive) ───────────────────────────────────────────────────
gHTF     = "6 · Higher-timeframe bias"
useHTF   = input.bool(true, "Use HTF confirmation", group = gHTF)
autoMTF  = input.bool(true, "Auto-map HTF to chart TF", group = gHTF,
     tooltip = "Scalper-aware approx 4-6x: 1m->5m, 2m->10m, 3m->15m, 5m->15m, 15m->60m, 30m->120m, 1h->240m, 4h->D, D->W.")
manHTF   = input.timeframe("60", "Manual HTF (if auto off)", group = gHTF)

// ── 7 · OB/OS & REVERSALS ───────────────────────────────────────────────────────────────────
gObos    = "7 · OB/OS & reversals"
obosLen  = input.int(150, "OB/OS window",         minval = 20, maxval = 600, group = gObos)
obosMult = input.float(1.6, "OB/OS sensitivity",  minval = 0.5, maxval = 3.0, step = 0.1, group = gObos)
exhLen   = input.int(20,  "Climax volume avg",    minval = 2,  maxval = 100, group = gObos)
exhMult  = input.float(1.8, "Climax multiplier",  minval = 1.0, maxval = 5.0, step = 0.1, group = gObos)

// ── 8 · DIVERGENCE  (Pro view) ──────────────────────────────────────────────────────────────
gDiv     = "8 · Divergence (Pro)"
showDiv  = input.bool(true,  "Show divergences",      group = gDiv)
autoPeak = input.bool(true,  "Auto lookback by TF",   group = gDiv)
pivMan   = input.int(5,      "Manual pivot L/R",  minval = 1, maxval = 50, group = gDiv)
divLook  = input.int(60,     "Max bars between pivots", minval = 5, maxval = 300, group = gDiv)
showHid  = input.bool(true,  "Hidden divergences",    group = gDiv)

// ── 9 · CALIBRATION  (forward test) ─────────────────────────────────────────────────────────
gCal     = "9 · Calibration (forward test)"
calOn    = input.bool(true, "Run forward calibration", group = gCal,
     tooltip = "Logs each Buy/Sell and, calHor bars later, checks the forward move. Reports Hit %, base %, Edge = Hit-Base and a Wilson-gated star. In-sample, overlapping windows, no costs.")
calHor   = input.int(10, "Forward horizon (bars)", minval = 2, maxval = 200, group = gCal)
calMinN  = input.int(20, "Min sample for stars",   minval = 5, maxval = 500, group = gCal)
showExp  = input.bool(true, "Export values (data window)", group = gCal)

// ── 10 · DASHBOARD & THEME ──────────────────────────────────────────────────────────────────
gUI      = "10 · Dashboard & theme"
showTable= input.bool(true, "Show status dashboard", group = gUI)
tblPos   = input.string("Top Right", "Dashboard position", options = ["Top Right","Top Left","Bottom Right","Bottom Left"], group = gUI)
dashTheme= input.string("Auto (match chart)", "Dashboard theme", options = ["Auto (match chart)","Dark","Light"], group = gUI,
     tooltip = "Auto reads chart-background brightness and keeps the panel legible on any theme.")
colBull  = input.color(#2ebd85, "Bull color", inline = "col", group = gUI)
colBear  = input.color(#f6465d, "Bear color", inline = "col", group = gUI)

pro = view == "Pro"

// ═════════════════════════════════════════════════════════════════════════════════════════
//                              HELPERS  (arguments + built-ins only)
// ═════════════════════════════════════════════════════════════════════════════════════════
f_pos(string s) =>
    s == "Top Left" ? position.top_left : s == "Bottom Right" ? position.bottom_right : s == "Bottom Left" ? position.bottom_left : position.top_right

f_cosh(float x)  => (math.exp(x) + math.exp(-x)) / 2
f_sinh(float x)  => (math.exp(x) - math.exp(-x)) / 2
f_acosh(float x) => x < 1 ? na : math.log(x + math.sqrt(x * x - 1))
f_asinh(float x) => math.log(x + math.sqrt(x * x + 1))

f_tanh(float x) =>
    float xc = math.max(-10.0, math.min(10.0, x))
    float e  = math.exp(2 * xc)
    (e - 1) / (e + 1)

// soft-bound any series to +/-100 so spikes saturate instead of blowing out the scale
f_squash(float x, simple float k) => 100.0 * f_tanh(x / k)

f_atan2(float y, float x) =>
    float a = 0.0
    if x > 0
        a := math.atan(y / x)
    else if x < 0 and y >= 0
        a := math.atan(y / x) + math.pi
    else if x < 0 and y < 0
        a := math.atan(y / x) - math.pi
    else if x == 0 and y > 0
        a := math.pi / 2
    else if x == 0 and y < 0
        a := -math.pi / 2
    a

f_ss(float s, simple int len) =>
    f  = 1.414 * math.pi / math.max(len, 1)
    a1 = math.exp(-f)
    c2 = 2 * a1 * math.cos(f)
    c3 = -a1 * a1
    c1 = 1 - c2 - c3
    var float v = na
    v := na(v[1]) or na(v[2]) ? s : c1 * (s + nz(s[1])) / 2 + c2 * nz(v[1]) + c3 * nz(v[2])
    v

f_cheby(float s, simple int len, simple float rip) =>
    a = f_cosh(1.0 / len * f_acosh(1.0 / (1.0 - rip)))
    b = f_sinh(1.0 / len * f_asinh(1.0 / rip))
    g = (a - b) / (a + b)
    var float v = na
    v := na(v[1]) ? s : (1 - g) * s + g * nz(v[1])
    v

f_us(float s, simple int len) =>
    a1 = math.exp(-1.414 * math.pi / math.max(len, 1))
    c2 = 2 * a1 * math.cos(1.414 * math.pi / math.max(len, 1))
    c3 = -a1 * a1
    c1 = (1 + c2 - c3) / 4
    var float v = na
    v := na(v[1]) or na(v[2]) ? s : (1 - c1) * s + (2 * c1 - c2) * nz(s[1]) - (c1 + c3) * nz(s[2]) + c2 * nz(v[1]) + c3 * nz(v[2])
    v

f_lp(float s, simple int len) => filterT == "Ultimate Smoother" ? f_us(s, len) : filterT == "Chebyshev" ? f_cheby(s, len, ripple) : f_ss(s, len)

f_zscore(float s, int len) =>
    sd = ta.stdev(s, len)
    mn = ta.sma(s, len)
    sd == 0 ? 0.0 : (s - mn) / sd

f_wilson(int w, int n) =>
    if n <= 0
        na
    else
        p = w / float(n)   // float() so the proportion isn't truncated by int/int division
        z = 1.96
        (p + z*z/(2*n) - z * math.sqrt(p*(1-p)/n + z*z/(4*n*n))) / (1 + z*z/n) * 100.0

f_rank(float s, simple int n, simple int baseLen, simple int sp) =>
    // Trend-structure "fan": n moving averages of increasing length, then the net
    // pairwise ordering (shorter-above-longer = bullish). The fan is built from
    // INCREMENTAL EMAs maintained O(1) each — no ta.* inside a loop (which triggers
    // the CW10003 "call on every bar" warning) and no per-bar full-window recompute.
    var float[] fan = array.new<float>(n, na)
    for i = 0 to n - 1
        float al   = 2.0 / (baseLen + i * sp + 1)
        float prev = array.get(fan, i)
        array.set(fan, i, na(prev) ? s : al * s + (1.0 - al) * prev)
    int sc = 0
    int pairs = n * (n - 1) / 2             // deterministic pair count
    for i = 0 to n - 2
        float mi = array.get(fan, i)        // fetched once per i
        for j = i + 1 to n - 1
            sc += mi > array.get(fan, j) ? 1 : -1
    pairs == 0 ? 0.0 : 100.0 * sc / pairs   // 100.0 first: int/int would truncate the rank to ~0

f_autoHTF() =>
    s = timeframe.in_seconds()
    s <= 60    ? "5"   :
       s <= 120   ? "10"  :
       s <= 180   ? "15"  :
       s <= 300   ? "15"  :
       s <= 600   ? "30"  :
       s <= 900   ? "60"  :
       s <= 1800  ? "120" :
       s <= 3600  ? "240" :
       s <= 14400 ? "D"   :
       s <= 86400 ? "W"   : "M"

f_star(float wl, float base, int n) =>
    n < calMinN or na(wl) or na(base) ? "n/a" : wl > base + 5 ? "★★★" : wl > base ? "★★" : wl > base - 5 ? "★" : "—"

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                          ENGINE
// ═════════════════════════════════════════════════════════════════════════════════════════
basis = ta.linreg(srcPrice, momLen, 0)
momZ  = f_zscore(srcPrice - basis, normLen)
momS  = f_lp(momZ, smoothLen)

// Volume Zone Oscillator -> Kalman (money flow)
volDir = srcPrice > srcPrice[2] ? volume : -volume
vzoRaw = ta.hma(volDir, volLen) / math.max(ta.hma(volume, volLen), 1e-10)
vzoZ   = f_zscore(vzoRaw, 200)
var float kf = na
kf := na(kf[1]) ? vzoZ : kCoef * vzoZ + (1 - kCoef) * nz(kf[1])
moneyFlow = f_lp(kf, smoothLen) * 50

composite = (1 - volWeight) * momS + volWeight * (moneyFlow / 50)
osc    = f_lp(composite, smoothLen) * 50
signal = f_lp(osc, sigLen)

rank = f_rank(srcPrice, clN, clBase, clSpace)

atrA     = ta.atr(momLen)
slope    = (srcPrice - srcPrice[momLen]) / (math.max(atrA, 1e-10) * momLen)
angleDeg = f_atan2(slope, 1) * 180 / math.pi

vwapVal = ta.vwap(hlc3)
cLoc    = not na(vwapVal) ? close > vwapVal : momZ > 0

htfTf   = autoMTF ? f_autoHTF() : manHTF
htfExpr = close - ta.ema(close, momLen)
htfRaw  = request.security(syminfo.tickerid, useHTF ? htfTf : timeframe.period, htfExpr[barstate.isrealtime ? 1 : 0], lookahead = barmerge.lookahead_off)
htfBull = useHTF ? htfRaw > 0 : osc > 0

erChange = math.abs(srcPrice - srcPrice[erLen])
erVol    = math.sum(math.abs(srcPrice - srcPrice[1]), erLen)
er       = erVol == 0 ? 0.0 : erChange / erVol
choppy   = er < erThresh

oscMean = ta.sma(osc, obosLen)
oscSd   = ta.stdev(osc, obosLen)
obLevel = oscMean + obosMult * oscSd
osLevel = oscMean - obosMult * oscSd

// ── seven independent votes ──
c1 = osc > 0, c2 = osc > signal, c3 = kf > 0, c4 = rank > 0, c5 = cLoc, c6 = angleDeg > 0, c7 = htfBull
bull7 = (c1?1:0)+(c2?1:0)+(c3?1:0)+(c4?1:0)+(c5?1:0)+(c6?1:0)+(c7?1:0)
score = bull7 / 7.0 * 100.0
regimeCode = score > 57 ? 1 : score < 43 ? -1 : 0

// ── displayed wave (standardized to own volatility, soft-bounded to +/-100) ──
// computed here so signals can veto on the wave's own OB/OS position.
float OBZ = 60.0          // overbought / oversold zone edge on the bounded scale
float CAP = 100.0
volPress = kf * 50
ribFast  = f_lp(volPress, mvpFastL)
ribSlow  = f_lp(volPress, mvpSlowL)
ribStd   = ta.stdev(ribFast, 200)
ribFastN = ribStd > 0 ? ribFast / ribStd : 0.0
ribSlowN = ribStd > 0 ? ribSlow / ribStd : 0.0
dispFast = f_squash(ribFastN * 33, 100)
dispSlow = f_squash(ribSlowN * 33, 100)
dispUp   = dispFast >= dispSlow
dCol     = dispUp ? colBull : colBear
dLo      = math.min(dispFast, dispSlow)
dHi      = math.max(dispFast, dispSlow)
waveOB   = dispFast >= OBZ    // wave is in the overbought zone
waveOS   = dispFast <= -OBZ   // wave is in the oversold zone

// ── signals / climax ──
// a Buy never prints while the wave is overbought, a Sell never while it is oversold.
xUp = ta.crossover(osc, signal)
xDn = ta.crossunder(osc, signal)
buySig  = xUp and osc < osLevel and score >= sigScore and not choppy and not waveOB
sellSig = xDn and osc > obLevel and score <= 100 - sigScore and not choppy and not waveOS

climax = volume > ta.sma(volume, exhLen) * exhMult
botExh = climax and osc < osLevel
topExh = climax and osc > obLevel

// ── divergence (Pro) ──
tfMin  = timeframe.in_seconds() / 60.0
autoP  = tfMin <= 5 ? 4 : tfMin <= 60 ? 5 : tfMin <= 240 ? 6 : 8
pivLen = autoPeak ? autoP : pivMan

ph = ta.pivothigh(osc, pivLen, pivLen)
pl = ta.pivotlow(osc, pivLen, pivLen)
phConf = not na(ph)
plConf = not na(pl)
curX = bar_index - pivLen

oscH=osc[pivLen], hH=srcHigh[pivLen]
pOscH=ta.valuewhen(phConf, osc[pivLen],1), pHH=ta.valuewhen(phConf, srcHigh[pivLen],1), pXH=ta.valuewhen(phConf, bar_index-pivLen,1)
bearReg = showDiv and phConf and hH>pHH and oscH<pOscH and (curX-pXH<=divLook)
bearHid = showDiv and showHid and phConf and hH<pHH and oscH>pOscH and (curX-pXH<=divLook)

oscL=osc[pivLen], lL=srcLow[pivLen]
pOscL=ta.valuewhen(plConf, osc[pivLen],1), pLL=ta.valuewhen(plConf, srcLow[pivLen],1), pXL=ta.valuewhen(plConf, bar_index-pivLen,1)
bullReg = showDiv and plConf and lL<pLL and oscL>pOscL and (curX-pXL<=divLook)
bullHid = showDiv and showHid and plConf and lL>pLL and oscL<pOscL and (curX-pXL<=divLook)
bullDiv = bullReg or bullHid
bearDiv = bearReg or bearHid

// ── calibration (forward, past-only) ──
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
// 100.0 first forces float division — buyW/buyN etc. are int counters and int/int
// would collapse every hit-rate to 0 or 100, corrupting the whole calibration.
buyHit  = buyN  > 0 ? 100.0 * buyW  / buyN  : na
sellHit = sellN > 0 ? 100.0 * sellW / sellN : na
baseUp  = baseN > 0 ? 100.0 * baseW / baseN : na
baseDn  = baseN > 0 ? 100.0 - baseUp : na
buyEdge  = (not na(buyHit)  and not na(baseUp)) ? buyHit  - baseUp : na
sellEdge = (not na(sellHit) and not na(baseDn)) ? sellHit - baseDn : na
buyStar  = f_star(f_wilson(buyW, buyN),  baseUp, buyN)
sellStar = f_star(f_wilson(sellW, sellN), baseDn, sellN)

// verdict/state/band strings are built inside the last-bar dashboard block (they
// are only ever shown there), so they aren't recomputed on every historical bar.

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                          PLOTS
// ═════════════════════════════════════════════════════════════════════════════════════════
// the wave, its bounded scale and the OB/OS zone flags are computed above (before signals).

// at-a-glance pane tint (kept subtle) — its intensity now tracks CONVICTION: the
// further the score is from neutral (50), the more solid the tint, so a decisive
// bias reads darker than a marginal one. Chop stays a flat, faint grey.
int tintT = int(math.max(78.0, 94.0 - math.abs(score - 50.0) / 50.0 * 16.0))
bgcolor(showTint ? (choppy ? color.new(color.gray,96) : score>=sigScore ? color.new(colBull,tintT) : score<=100-sigScore ? color.new(colBear,tintT) : na) : na)

// fixed OB/OS gradient zones (house extreme-fill look) — always aligned to the wave
pObIn  = plot(OBZ,  "OB edge", color.new(colBear, 35), 1)
pObOut = plot(CAP,  "OB cap",  color.new(colBear, 100), display = display.none)
fill(pObIn, pObOut, 100.0, 60.0, color.new(colBear, 18), color.new(colBear, 92), title = "Overbought zone")
pOsIn  = plot(-OBZ, "OS edge", color.new(colBull, 35), 1)
pOsOut = plot(-CAP, "OS cap",  color.new(colBull, 100), display = display.none)
fill(pOsIn, pOsOut, -60.0, -100.0, color.new(colBull, 92), color.new(colBull, 18), title = "Oversold zone")
hline(0, "Zero", color = color.new(color.gray, 60))

// volume-flow ribbon (hero) — glow line in house style
pRF = plot(dispFast, "Flow Fast", na)
pRS = plot(dispSlow, "Flow Slow", na)
fill(pRF, pRS, color.new(dCol, 42))
// glow brightens with flow STRENGTH: a strong money-flow push radiates, a weak
// one stays faint (dispFast is already soft-bounded to +/-100).
int glowT = int(math.max(48.0, 78.0 - math.abs(dispFast) / 100.0 * 30.0))
plot(dispFast, "Flow glow", color.new(dCol, glowT), 8)
plot(dispFast, "Flow Edge", color.new(dCol, 0),  2)

// Pro: one faint momentum reference line (same normalized scale) + divergence dots
oscStd  = ta.stdev(osc, 200)
oscN    = oscStd > 0 ? osc / oscStd : 0.0
plot(pro ? f_squash(oscN * 33, 100) : na, "Momentum", color.new(osc>=0?colBull:colBear, 55), 1)
plotshape(pro and bullDiv ? dLo : na, "Divergence Bull", shape.circle, location.absolute, color.new(colBull,0), size = size.tiny)
plotshape(pro and bearDiv ? dHi : na, "Divergence Bear", shape.circle, location.absolute, color.new(colBear,0), size = size.tiny)

// exhaustion turns (sparse — only the turn, not every climax bar)
plotshape(botExh and not botExh[1] ? -OBZ : na, "Possible Bottom", shape.triangleup,   location.absolute, color.new(colBull,0), size = size.tiny)
plotshape(topExh and not topExh[1] ?  OBZ : na, "Possible Top",    shape.triangledown, location.absolute, color.new(colBear,0), size = size.tiny)

// signals on the wave
plotshape(buySig  ? dLo : na, "Buy",  shape.triangleup,   location.absolute, color.new(colBull,0), size = size.small)
plotshape(sellSig ? dHi : na, "Sell", shape.triangledown, location.absolute, color.new(colBear,0), size = size.small)

// ── on-price signals (force-overlay): the SAME markers shown in the pane, printed on price ──
plotshape(showPriceSig and buySig,  "Buy mark",  shape.triangleup,   location.belowbar, color.new(sigBuyCol, 0),  size = size.normal, force_overlay = true)
plotshape(showPriceSig and sellSig, "Sell mark", shape.triangledown, location.abovebar, color.new(sigSellCol, 0), size = size.normal, force_overlay = true)
// exhaustion turns mirrored to price (smaller = secondary context, not a Buy/Sell)
plotshape(showPriceSig and botExh and not botExh[1], "Bottom mark", shape.triangleup,   location.belowbar, color.new(sigBuyCol, 20),  size = size.tiny, force_overlay = true)
plotshape(showPriceSig and topExh and not topExh[1], "Top mark",    shape.triangledown, location.abovebar, color.new(sigSellCol, 20), size = size.tiny, force_overlay = true)
if showPriceSig and showPriceLbl and buySig
    label.new(bar_index, low,  "BUY",  yloc = yloc.belowbar, style = label.style_label_up,   color = color.new(sigBuyCol, 0),  textcolor = color.white, size = size.small, force_overlay = true)
if showPriceSig and showPriceLbl and sellSig
    label.new(bar_index, high, "SELL", yloc = yloc.abovebar, style = label.style_label_down, color = color.new(sigSellCol, 0), textcolor = color.white, size = size.small, force_overlay = true)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                       STATUS DASHBOARD  (background-adaptive, house theme)
// ═════════════════════════════════════════════════════════════════════════════════════════
var table stP = table.new(f_pos(tblPos), 2, 10, frame_width = 1, border_width = 1)
var table stS = table.new(f_pos(tblPos), 2, 4,  frame_width = 1, border_width = 1)

if showTable and barstate.islast
    string trendTxt = score>57 ? "Bullish" : score<43 ? "Bearish" : "Neutral"
    string verdict  = choppy ? "WAIT - choppy" : buySig ? "Long setup" : sellSig ? "Short setup" : score>=sigScore ? "Bullish bias" : score<=100-sigScore ? "Bearish bias" : "Neutral - wait"
    string stateHdr = choppy ? "WAIT" : score>=sigScore ? "BULLISH" : score<=100-sigScore ? "BEARISH" : "NEUTRAL"
    string stTxt    = osc>obLevel ? "Overbought" : osc<osLevel ? "Oversold" : "Neutral"
    color bgc    = chart.bg_color
    float lumaV  = na(bgc) ? 0.0 : color.r(bgc) * 0.299 + color.g(bgc) * 0.587 + color.b(bgc) * 0.114
    bool  darkUI = dashTheme == "Dark" ? true : dashTheme == "Light" ? false : (na(bgc) or lumaV < 140)
    color panelBg= darkUI ? color.rgb(17, 22, 28)    : color.rgb(244, 246, 248)
    color rowAlt = darkUI ? color.rgb(25, 31, 39)    : color.rgb(232, 236, 240)
    color txtMain= darkUI ? color.white              : color.rgb(16, 20, 24)
    color txtSub = darkUI ? color.rgb(154, 166, 178) : color.rgb(74, 82, 91)
    color frameC = darkUI ? color.rgb(58, 70, 84)    : color.rgb(196, 204, 212)
    color bullC  = darkUI ? colBull : color.rgb(22, 151, 106)
    color bearC  = darkUI ? colBear : color.rgb(210, 45, 68)
    color flatC  = darkUI ? color.gray : color.rgb(122, 130, 139)
    color hdr    = color.new(colBull, 0)
    color vCol   = choppy ? flatC : (score>=sigScore ? bullC : score<=100-sigScore ? bearC : flatC)
    color flowC  = kf>0 ? bullC : bearC
    color stCol  = osc>obLevel ? bearC : osc<osLevel ? bullC : flatC

    if pro
        table.set_bgcolor(stP, panelBg)
        table.set_frame_color(stP, frameC)
        table.set_border_color(stP, frameC)
        table.cell(stP, 0, 0, "Volume Confluence", text_color = color.white, bgcolor = hdr, text_size = size.tiny)
        table.cell(stP, 1, 0, stateHdr, text_color = color.white, bgcolor = hdr, text_size = size.tiny)
        table.cell(stP, 0, 1, "Score", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
        table.cell(stP, 1, 1, str.tostring(score,"#") + "/100  " + trendTxt, text_color = vCol, bgcolor = rowAlt, text_size = size.tiny)
        table.cell(stP, 0, 2, "Regime", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
        table.cell(stP, 1, 2, choppy ? "Chop" : "Trend", text_color = choppy ? color.orange : bullC, bgcolor = panelBg, text_size = size.tiny)
        table.cell(stP, 0, 3, "Flow", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
        table.cell(stP, 1, 3, kf>0 ? "Inflow" : "Outflow", text_color = flowC, bgcolor = rowAlt, text_size = size.tiny)
        table.cell(stP, 0, 4, "HTF", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
        table.cell(stP, 1, 4, htfTf + " " + (htfBull ? "↑" : "↓"), text_color = htfBull ? bullC : bearC, bgcolor = panelBg, text_size = size.tiny)
        table.cell(stP, 0, 5, "Band", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
        table.cell(stP, 1, 5, stTxt, text_color = stCol, bgcolor = rowAlt, text_size = size.tiny)
        if calOn
            string baseTxt = (na(baseUp) or na(baseDn)) ? "warming" : "up " + str.tostring(baseUp,"0") + "  dn " + str.tostring(baseDn,"0")
            string buyTxt  = buyN  < calMinN ? "warm " + str.tostring(buyN)  : "H" + str.tostring(buyHit,"0")  + "  E" + (buyEdge>=0?"+":"")  + str.tostring(buyEdge,"0")  + "  (" + str.tostring(buyN) + ")"
            string sellTxt = sellN < calMinN ? "warm " + str.tostring(sellN) : "H" + str.tostring(sellHit,"0") + "  E" + (sellEdge>=0?"+":"") + str.tostring(sellEdge,"0") + "  (" + str.tostring(sellN) + ")"
            color  buyEc   = buyN  < calMinN ? flatC : nz(buyEdge)  > 0 ? bullC : bearC
            color  sellEc  = sellN < calMinN ? flatC : nz(sellEdge) > 0 ? bullC : bearC
            table.cell(stP, 0, 6, "Base " + str.tostring(calHor) + "b %", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
            table.cell(stP, 1, 6, baseTxt, text_color = txtMain, bgcolor = panelBg, text_size = size.tiny)
            table.cell(stP, 0, 7, "Buy " + buyStar, text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
            table.cell(stP, 1, 7, buyTxt, text_color = buyEc, bgcolor = rowAlt, text_size = size.tiny)
            table.cell(stP, 0, 8, "Sell " + sellStar, text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
            table.cell(stP, 1, 8, sellTxt, text_color = sellEc, bgcolor = panelBg, text_size = size.tiny)
            table.cell(stP, 0, 9, "Note", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
            table.cell(stP, 1, 9, "past-only context", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    else
        table.set_bgcolor(stS, panelBg)
        table.set_frame_color(stS, frameC)
        table.set_border_color(stS, frameC)
        table.cell(stS, 0, 0, "Volume Confluence", text_color = color.white, bgcolor = hdr, text_size = size.tiny)
        table.cell(stS, 1, 0, stateHdr, text_color = color.white, bgcolor = hdr, text_size = size.tiny)
        table.cell(stS, 0, 1, "Action", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
        table.cell(stS, 1, 1, verdict, text_color = vCol, bgcolor = rowAlt, text_size = size.tiny)
        table.cell(stS, 0, 2, "Trend", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
        table.cell(stS, 1, 2, trendTxt, text_color = vCol, bgcolor = panelBg, text_size = size.tiny)
        table.cell(stS, 0, 3, "Strength", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
        table.cell(stS, 1, 3, str.tostring(score,"#") + "/100", text_color = vCol, bgcolor = rowAlt, text_size = size.tiny)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                              EXPORTS  (generic, cross-script)
// ═════════════════════════════════════════════════════════════════════════════════════════
plot(showExp ? score      : na, "Score",     color.new(color.gray,100), display = display.data_window)
plot(showExp ? osc        : na, "Osc",       color.new(color.gray,100), display = display.data_window)
plot(showExp ? regimeCode : na, "Regime",    color.new(color.gray,100), display = display.data_window)
plot(showExp ? (choppy?0:1): na, "Trending", color.new(color.gray,100), display = display.data_window)
plot(showExp ? (kf>0?1:-1): na, "Flow",      color.new(color.gray,100), display = display.data_window)
plot(showExp ? (buySig?1:sellSig?-1:0) : na, "Signal", color.new(color.gray,100), display = display.data_window)
plot(showExp ? nz(buyHit,-1)  : na, "BuyHit",  color.new(color.gray,100), display = display.data_window)
plot(showExp ? nz(sellHit,-1) : na, "SellHit", color.new(color.gray,100), display = display.data_window)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                          ALERTS
// ═════════════════════════════════════════════════════════════════════════════════════════
alertcondition(buySig,  "Buy Signal",  "Volume Confluence: buy setup")
alertcondition(sellSig, "Sell Signal", "Volume Confluence: sell setup")
alertcondition(bullDiv, "Bullish Divergence", "Volume Confluence: bullish divergence")
alertcondition(bearDiv, "Bearish Divergence", "Volume Confluence: bearish divergence")
alertcondition(botExh,  "Possible Bottom", "Volume Confluence: possible bottom")
alertcondition(topExh,  "Possible Top",    "Volume Confluence: possible top")
alertcondition(score>=85, "Strong Bullish", "Volume Confluence: strong bullish confluence")
alertcondition(score<=15, "Strong Bearish", "Volume Confluence: strong bearish confluence")
````
