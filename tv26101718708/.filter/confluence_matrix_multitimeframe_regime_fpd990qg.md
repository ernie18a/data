# Confluence Matrix  Multi-Timeframe Regime

- url: https://www.tradingview.com/script/fPd990QG-Confluence-Matrix-Multi-Timeframe-Regime/
- type: indicator
- pine_id: PUB;13db4be6f1fd4476abcbf2ad414e3425
- version: 2.0

## Description

CONFLUENCE MATRIX — Multi-Timeframe Regime & Accuracy-Weighted Bias
================================================================================

WHAT THIS SCRIPT IS

A multi-timeframe decision panel. Across a fixed ladder of nine timeframes
(1m, 3m, 5m, 15m, 30m, 60m, 120m, 240m, Daily) it measures the same five
technical factors — trend, momentum, structure, volume flow and mean-reversion —
normalises each to a comparable scale, and fuses them into one directional bias
per timeframe. It then compares the timeframes to each other: how strongly they
agree (a confluence meter), how many of the nine are aligned, and whether the
fast timeframes are turning against the slow ones (a transition). It flags moves
that are exhausted, shows where volatility is compressing, and reports past-only
how often the overall bias has actually been followed through on the current
symbol, with a confidence interval.

WHY THE COMPONENTS ARE COMBINED (how the parts work together)

These are not separate indicators stacked in one pane. They are five reads of
the same question — "what is price doing and should I trust it?" — chosen
because they fail in different conditions, so combining them removes each
other's blind spots, and reading them across a full timeframe ladder removes the
blind spot of any single chart:

- TREND: an ATR SuperTrend blended with a moving-average stack. The SuperTrend
  flips with less lag than a moving average alone; the stack confirms direction.
- MOMENTUM: MACD histogram + RSI + Stochastic. A three-oscillator read is harder
  to whipsaw than any one of them.
- STRUCTURE: location of price within the recent range — acceptance in the
  middle versus pressure at the edges.
- VOLUME FLOW: money-flow combined with position relative to the anchored VWAP,
  i.e. whether price is above or below the session's volume-weighted fair value.
- MEAN-REVERSION: deviation from an adaptive equilibrium whose responsiveness
  scales with the efficiency ratio. This is the counterweight that fades
  extension — correct in a range, wrong in a trend.

Because a factor that helps in one regime hurts in another, the fusion is
governed by two layers that decide how much to trust each factor:

1. REGIME WEIGHTING. Each timeframe classifies its own regime from the
   efficiency ratio, ADX and relative volatility, and reweights the factors
   accordingly — trend and momentum lead in a trend, mean-reversion leads in a
   range, and confidence is damped when volatility is elevated. A daily that is
   trending and a 5-minute that is ranging are therefore scored by different
   logic, which is the whole point of a multi-timeframe read.

2. PROVEN-ACCURACY WEIGHTING. The script tracks, on past bars only, how often
   each individual factor's signal has been followed through on THIS symbol, and
   scales that factor's weight by its measured hit-rate. So the fusion becomes
   regime x proven-accuracy: on a symbol where, historically, mean-reversion has
   paid and trend has not, the panel learns that and weights accordingly. This
   is what turns a generic vote into a calibrated, symbol-aware read.

Two further layers handle the traps and the timing:

- EXHAUSTION. A fully-aligned stack that is also over-extended is the classic
  "everything agrees right at the turn" trap. Exhausted timeframes are marked,
  and the confluence meter is damped so that alignment-with-exhaustion is not
  mistaken for high conviction.
- SQUEEZE. A read of where Bollinger bands sit inside Keltner channels —
  volatility compression that tends to precede expansion. This adds timing
  (when a move may start) to the directional read (which way).

The cross-timeframe layer then turns the nine composites into one verdict:
overall direction, a confluence meter, an alignment count, and a fast-versus-slow
transition flag. Calibration of the overall bias keeps the headline honest by
measuring its real follow-through on the current symbol.

HOW IT WORKS (mechanics, briefly)

Each timeframe's factors are computed with standard confirmation and requested
non-repainting; history does not change after the fact. The per-symbol accuracy
weights and the headline follow-through are built by recording a signal's
direction when it forms and checking, a fixed number of bars later, whether
price travelled a chosen ATR multiple in that direction, then aggregating into a
rate with a Wilson confidence interval. All thresholds are ATR-relative, so
nothing is tied to a particular price scale.

HOW TO USE

1. Read the headline bar (overall bias) and the CONFLUENCE meter, then scan the
   Bias column down the ladder for a long aligned run.
2. A "!" on a Bias cell means that timeframe is exhausted; high alignment with
   exhaustion is lower conviction, and the meter already reflects that.
3. Watch STATE (FULL STACK / TRANSITION) and the SQUEEZE row for timing.
4. Weight the read by FOLLOW-THROUGH — the overall bias's measured hit-rate here.
5. Everything is descriptive context, not a signal to act on.

USE ON ANY MARKET

The Price source input drives the trend, momentum, mean-reversion and structure
reads, so you can run the panel on standard candles, Heikin-Ashi, or another
price series across stocks, indices, futures, forex and crypto. High, low and
volume stay native for the range and flow factors, and a volume-borrow input
supplies volume for symbols that report none.

WHAT MAKES IT ORIGINAL

The contribution is the fusion, not the individual factors, which are standard.
Here the same regime-adaptive, volatility-normalised composite is computed
identically across a timeframe ladder, then weighted further by each factor's
past-only, per-symbol accuracy, with exhaustion damping and explicit alignment,
transition and squeeze context. A multi-timeframe panel that learns which
factors to trust on each symbol, and that damps alignment when a move is
exhausted, is the part that is not available elsewhere.

SETTINGS WORTH KNOWING

- Timeframe Ladder: the nine timeframes are editable.
- Fusion: toggle proven-accuracy weighting, exhaustion damping and the squeeze
  read; the higher-timeframe emphasis slider controls how much slow timeframes
  count in the overall (0 = equal weighting).
- Calibration: horizon and minimum follow-through define what counts as a
  "followed-through" signal for both the accuracy weights and the headline rate.
- External signals (optional): three source inputs accept directional exports
  from other indicators and blend them into the overall composite at the chart
  timeframe; price sources are auto-ignored.
- Visuals: theme is auto/dark/light; size is Tiny/Small/Normal; the identity
  strip shows the script name, symbol and timeframe.

NOTE ON TIMEFRAMES BELOW THE CHART

A timeframe lower than the chart returns its most recent value rather than a full
aggregated history. For a fully historical view of the fast rows, load the
indicator on a low chart timeframe; for a live current-state read, every row is
valid at any chart timeframe.

LIMITATIONS

Higher-timeframe values reflect the developing bar in real time; history is
non-repainting. Volume flow and anchored VWAP need real (or borrowed) volume. The
accuracy weighting and follow-through describe PAST behaviour only — they are not
a backtest and not a probability of future results. Every read is probabilistic
context, never a certainty.

DISCLAIMER

This is a study / indicator for chart analysis and education only. It is not a
strategy, not a recommendation, and not financial advice. It places no orders and
guarantees no outcome. Markets carry risk, and the past behaviour of a signal
does not assure its future behaviour. Do your own research and manage your own
risk.

## Source Code

````pine
// =============================================================================
//  CONFLUENCE MATRIX — Multi-Timeframe Market-State Cockpit
//  shorttitle: Confluence MTF                                       Pine Script v6
// -----------------------------------------------------------------------------
//  WHAT IT DOES
//    Summarizes the state of a market across seven timeframes in one panel and
//    turns it into three plain verdicts — Scalp, Intraday, Positional — each with
//    a confidence-weighted score. It is a market-state gauge, not a buy/sell
//    signal, and nothing here is financial advice.
//
//  READ IT IN ONE LOOK  (non-technical)
//    • Grid colour:  green = up bias, red = down bias, brighter = stronger.
//                    ▲ up · ▼ down · · neutral. Scan the BIAS row first.
//    • Gold anywhere = caution (high volatility, toxic flow, or a regime shift).
//    • DECISION rows:  the coloured bar is the read for that horizon; the number
//                    is a score from −100 to +100. |score| above the strong level
//                    means a firm, aligned, confident read. Mixed = no edge.
//    • Turn on the Info panel (settings) for a built-in how-to key.
//
//  HOW THE PARTS WORK TOGETHER  (why this is one tool, not several)
//    The panel fuses two orthogonal groups so they cross-check each other:
//    (1) A DIRECTIONAL CORE measured independently on every timeframe — trend,
//        trend-quality, momentum, structure, volume-flow and mean-reversion —
//        each factor adaptively weighted by how well it has actually followed
//        through on THIS instrument (measured forward, past-only).
//    (2) A CONTEXT LAYER measured on the chart timeframe — value/auction location,
//        order-flow toxicity + price-impact, options/positioning bias, an
//        intermarket leader, order-flow self-excitation, the implied-vs-realized
//        volatility premium, and a statistical regime-shift detector.
//    The core says WHICH WAY; the context says HOW RELIABLE. Context that is
//    toxic, fragile, stressed or shifting mechanically LOWERS the confidence that
//    scales every verdict — so "aligned but fragile" prints a smaller number
//    rather than a false green. That interaction is the whole point of combining
//    them: neither group alone tells you both direction and trustworthiness.
//
//  CONCEPT CREDITS  (this is a mashup of established public methods; credit due)
//    Efficiency Ratio — P. Kaufman.  RSI / ATR / DMI — J.W. Wilder.
//    Money Flow Index — Quong & Soudack.  Linear-regression channel — classical.
//    Order-flow toxicity (VPIN) — Easley, López de Prado & O'Hara (2012).
//    Price impact (lambda) — A. Kyle (1985).
//    Self-excitation / branching ratio — Hawkes (1971); Hardiman, Bercot &
//      Bouchaud (2013).  Variance-risk premium — Bollerslev, Tauchen & Zhou (2009).
//    Auction / value-area location — J.P. Steidlmayer (Market Profile).
//    Change-point (CUSUM) — E.S. Page (1954).
//    Adaptive forward-weighting of signals — after meta-labeling / triple-barrier
//      concepts, López de Prado (2018).
//    Original contribution: the specific 7-TF fusion, the per-factor forward-Edge
//    weighting driving the composite, and the context-driven confidence that
//    damps three horizon verdicts — combined and presented as one cockpit.
//
//  USE IT ON ANY MARKET
//    Defaults target NSE NIFTY (index / futures / leader / India VIX). To use
//    another instrument, open "① Data Sources" and set the futures, spot, leader
//    and implied-vol symbols to your market — or switch those context cells off.
//    Every context cell also accepts an external input if you prefer your own feed.
//
//  LIMITATIONS
//    Higher-timeframe cells reflect the developing HTF bar. Volume/flow is
//    ESTIMATED from price and bar volume, not exchange-tagged trades. Context and
//    Edge are chart-timeframe only. A sub-bar timeframe below the chart is used
//    for flow; if your data lacks it, the panel falls back to a bar proxy.
//    The Edge weighting is descriptive of past behaviour, not a backtest or a
//    forward guarantee.
//
//  DISCLAIMER
//    For study and education only. This is NOT financial, investment or trading
//    advice, NOT a recommendation, and NOT a signal to buy or sell. It places no
//    orders and makes no guarantees. Markets involve risk of loss; past behaviour
//    does not assure future results. Always do your own research and manage risk.
// =============================================================================

//@version=6
indicator("Confluence Matrix — MTF Market-State Cockpit", "Confluence MTF", overlay = true, max_bars_back = 1000, dynamic_requests = true)

// ═════════════════════════════ SETTINGS ════════════════════════════════════
g0 = "① Data Sources — set to match your instrument"
futSym       = input.symbol("NSE:NIFTY1!",   "Futures / primary symbol", group = g0, tooltip = "Used for options-basis and intermarket basis. Set to your instrument's futures, or the same as chart if none.")
spotSym      = input.symbol("NSE:NIFTY",     "Spot / underlying symbol", group = g0)
leaderSym    = input.symbol("NSE:BANKNIFTY", "Intermarket leader symbol", group = g0, tooltip = "A related instrument that tends to lead. E.g. a sector, a heavyweight, or a macro driver.")
leadInv      = input.bool(false,             "Leader is inverse (e.g. USD pair)", group = g0)
vixSym       = input.symbol("NSE:INDIAVIX",  "Implied-volatility index symbol", group = g0, tooltip = "Your market's implied-vol index (VIX-type). Powers options, VRP and stress reads.")
volBorrowSym = input.symbol("",              "Borrow volume from symbol (if chart has none)", group = g0)
cvdLTF       = input.timeframe("1S",         "Flow sub-timeframe (finest available)", group = g0, tooltip = "Sub-bar resolution for signed volume (toxicity / impact). Use the finest your data allows: 1S = 1 second; set 1 for 1 minute if seconds are unavailable. Falls back automatically.")

g1 = "② Timeframes"
tf1i = input.timeframe("1",   "TF 1", group = g1)
tf2i = input.timeframe("3",   "TF 2", group = g1)
tf3i = input.timeframe("5",   "TF 3", group = g1)
tf4i = input.timeframe("15",  "TF 4", group = g1)
tf5i = input.timeframe("60",  "TF 5", group = g1)
tf6i = input.timeframe("240", "TF 6", group = g1)
tf7i = input.timeframe("D",   "TF 7", group = g1)

g2 = "③ Factor Engine"
emaFast   = input.int(20, "Trend fast EMA", minval = 2, group = g2)
emaSlow   = input.int(50, "Trend slow EMA", minval = 3, group = g2)
lrLen     = input.int(20, "Trend regression length", minval = 5, group = g2)
lrGain    = input.float(4.0, "Trend slope sensitivity", minval = 1.0, maxval = 12.0, step = 0.5, group = g2)
rsiLen    = input.int(14, "Momentum (RSI) length", minval = 2, group = g2)
structLen = input.int(20, "Structure / range length", minval = 5, group = g2)
structPiv = input.int(5, "Structure swing pivots (L/R)", minval = 2, group = g2)
mfiLen    = input.int(14, "Volume-flow length", minval = 2, group = g2)
mrLen     = input.int(20, "Mean-reversion length", minval = 5, group = g2)

g3 = "④ Regime Detection"
erLen    = input.int(20, "Efficiency-ratio length", minval = 2, group = g3)
erTrend  = input.float(0.30, "Trend threshold (efficiency)", minval = 0.05, maxval = 0.95, step = 0.01, group = g3)
adxLen   = input.int(14, "Directional (ADX) length", minval = 2, group = g3)
adxTrend = input.float(20.0, "Trend threshold (ADX)", minval = 5, maxval = 50, group = g3)
volMult  = input.float(1.5, "Volatile: range vs its average (x)", minval = 1.1, maxval = 3.0, step = 0.1, group = g3)

g4 = "⑤ Adaptive Edge Weighting"
edgeOn    = input.bool(true, "Weight factors by measured follow-through", group = g4, tooltip = "Each factor is logged forward on the chart timeframe and scored against a base rate; factors that pay on this instrument are weighted up, others down. Warms up over history. Past-only, not a backtest.")
edgeHoriz = input.int(12, "Follow-through horizon (bars)", minval = 3, maxval = 100, group = g4)
edgeMoveA = input.float(0.6, "Follow-through size (× ATR)", minval = 0.1, maxval = 3.0, step = 0.1, group = g4)
edgeMinN  = input.int(20, "Min samples before weighting", minval = 5, group = g4)
edgeGain  = input.float(2.0, "Weighting sensitivity", minval = 0.5, maxval = 5.0, step = 0.5, group = g4)
edgeMinW  = input.float(0.4, "Min factor weight", minval = 0.1, maxval = 1.0, step = 0.05, group = g4)
edgeMaxW  = input.float(1.6, "Max factor weight", minval = 1.0, maxval = 3.0, step = 0.1, group = g4)
edgeThr   = input.float(0.15, "Log a factor when |value| ≥", minval = 0.05, maxval = 0.5, step = 0.05, group = g4)

g5 = "⑥ Context Layer (chart timeframe)"
bValue   = input.bool(true, "Value / auction location", group = g5)
valLen   = input.int(50, "Value window", minval = 10, group = g5)
valExt   = input.source(close, "↳ External value/auction position (−1..+1)", group = g5, tooltip = "Optional: feed your own value/auction position export. Internal volume-weighted proxy otherwise.")
bVpin    = input.bool(true, "Flow-quality: toxicity + impact", group = g5)
vpinAvg  = input.int(50, "Toxicity bucket avg length", minval = 10, group = g5)
vpinBars = input.float(3.0, "Toxicity bucket size (× avg vol)", minval = 0.5, maxval = 20.0, step = 0.5, group = g5)
vpinN    = input.int(50, "Toxicity window (buckets)", minval = 5, group = g5)
lamLook  = input.int(30, "Impact (price-impact) length", minval = 10, maxval = 100, group = g5)
lamRank  = input.int(200, "Impact rank lookback", minval = 50, maxval = 600, group = g5)
vpinExt  = input.source(close, "↳ External order-flow toxicity (0..100)", group = g5)
bOptions = input.bool(true, "Options / positioning bias", group = g5)
ivLen    = input.int(252, "Implied-vol rank lookback", minval = 20, group = g5)
termLen  = input.int(50, "Vol term length", minval = 5, group = g5)
oNormLen = input.int(100, "Positioning normalization", minval = 20, group = g5)
optExt   = input.source(close, "↳ External positioning bias (σ, −2.5..+2.5)", group = g5)
bBasis   = input.bool(true, "Intermarket leader / basis", group = g5)
basisLen = input.int(50, "Basis / leader window", minval = 10, group = g5)
corrLen  = input.int(50, "Correlation window", minval = 5, group = g5)
corrMin  = input.float(0.30, "Min |correlation| for leader vote", minval = 0.0, maxval = 1.0, step = 0.05, group = g5)
basisExt = input.source(close, "↳ External intermarket signal (−2.5..+2.5)", group = g5)
bHawkes  = input.bool(true, "Self-excitation (order-flow cascades)", group = g5)
hawkEvThr= input.float(2.0, "Burst threshold (× typical flow)", minval = 1.1, maxval = 6.0, step = 0.1, group = g5)
hawkBin  = input.int(5, "Counting-bin length (bars)", minval = 1, group = g5)
hawkNBins= input.int(60, "Bins in estimate", minval = 10, group = g5)
hawkExt  = input.source(close, "↳ External self-excitation ratio (0..1)", group = g5)
bVRP     = input.bool(true, "Volatility risk premium / stress", group = g5)
vrpLen   = input.int(20, "Realized-vol window", minval = 5, group = g5)
bCP      = input.bool(true, "Regime-shift (change-point)", group = g5)
cpLen    = input.int(50, "Change-point baseline window", minval = 10, group = g5)
cpK      = input.float(0.5, "Sensitivity slack (× σ)", minval = 0.1, maxval = 2.0, step = 0.1, group = g5)
cpH      = input.float(5.0, "Detection threshold", minval = 2.0, maxval = 15.0, step = 0.5, group = g5)
cpHold   = input.int(10, "Shift 'active' hold (bars)", minval = 1, maxval = 100, group = g5)

g6 = "⑦ Confidence & Decision"
sigThr    = input.float(0.08, "Neutral deadband (|bias|)", minval = 0.0, maxval = 0.4, step = 0.01, group = g6)
bWeight   = input.float(0.25, "Context directional tilt", minval = 0, maxval = 0.6, step = 0.05, group = g6)
confAlert = input.int(60, "Strong-verdict score level", minval = 30, maxval = 95, group = g6)

g7 = "⑧ Dashboard & Theme"
showMain  = input.bool(true,  "Main panel", group = g7)
showKey   = input.bool(false, "Info panel (how-to key)", group = g7)
showLegend= input.bool(false, "Colour legend", group = g7)
showId    = input.bool(false, "Identity strip", group = g7)
tblPosStr = input.string("Top Right", "Main panel position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = g7)
tblSize   = input.string("Small", "Panel size", options = ["Tiny", "Small", "Normal"], group = g7)
legPosStr = input.string("Bottom Left", "Info / legend position", options = ["Bottom Left", "Bottom Right", "Top Left", "Top Right"], group = g7)
themeMode = input.string("Auto (match chart)", "Theme", options = ["Auto (match chart)", "Dark", "Light"], group = g7)
bullCol   = input.color(#089981, "Bullish colour", group = g7)
bearCol   = input.color(#f23645, "Bearish colour", group = g7)
// ───────────────────────────── PURE HELPERS ────────────────────────────────
f_luma(color c) => na(c) ? 0.0 : color.r(c) * 0.299 + color.g(c) * 0.587 + color.b(c) * 0.114
f_clamp(float x, float lo, float hi) => math.max(lo, math.min(hi, x))
f_wired(float v) => not na(v) and v != close
f_isExt(float v) => not na(v) and math.abs(v) <= 3.0 and v != close
f_z(float v, float m, float s) => s > 0 ? (v - m) / s : 0.0
f_arrVar(array<float> arr) =>
    int n = array.size(arr)
    float out = na
    if n >= 2
        float mu = array.avg(arr)
        float ss = 0.0
        for i = 0 to n - 1
            float d = array.get(arr, i) - mu
            ss += d * d
        out := ss / (n - 1)
    out
legCalc(simple int ivL, simple int tL, simple int nL) =>
    float ivR  = ta.percentrank(close, ivL)
    float trm  = close - ta.ema(close, tL)
    float sdT  = ta.stdev(trm, nL)
    float mnT  = ta.sma(trm, nL)
    float trmZ = sdT > 0 ? (trm - mnT) / sdT : 0.0
    [ivR, trmZ]
f_posT(string s) =>
    switch s
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        "Middle Right" => position.middle_right
        => position.top_right
f_posL(string s) =>
    switch s
        "Bottom Right" => position.bottom_right
        "Top Left"     => position.top_left
        "Top Right"    => position.top_right
        => position.bottom_left
f_sz(string s) => s == "Tiny" ? size.tiny : s == "Normal" ? size.normal : size.small

// ── BLOCK A: pure factor engine — returns raw factors, composed outside ──
// [trendF, momoF, structF, flowF, mrF, qualF, regCode, volScore]
// regCode: 2 = trend-up, -2 = trend-down, 1 = volatile, 0 = range
f_factors() =>
    float atrv = ta.atr(14)
    float a = atrv > 0 ? atrv : close * 0.001
    // regime
    float erN = math.abs(close - close[erLen])
    float erD = math.sum(math.abs(close - close[1]), erLen)
    float er = erD > 0 ? erN / erD : 0.0
    [dip, dim, adx] = ta.dmi(adxLen, adxLen)
    float atrAvg = ta.sma(atrv, 50)
    bool isVol = atrAvg > 0 and atrv > atrAvg * volMult
    bool isTrend = adx > adxTrend and er > erTrend
    float emaS = ta.ema(close, emaSlow)
    int regCode = isTrend ? (close >= emaS ? 2 : -2) : (isVol ? 1 : 0)
    // trend factor: EMA stack + distance + regression slope×R²
    float eF = ta.ema(close, emaFast)
    float eS = emaS
    float stack = eF > eS ? 1.0 : eF < eS ? -1.0 : 0.0
    float dist = a > 0 ? f_clamp((close - eS) / (a * 3.0), -1.0, 1.0) : 0.0
    float lr = ta.linreg(close, lrLen, 0)
    float lrPrev = ta.linreg(close, lrLen, 1)
    float slope = (lr - lrPrev)
    float slopeN = a > 0 ? f_clamp(slope / a * lrGain, -1.0, 1.0) : 0.0
    float corr = ta.correlation(close, bar_index, lrLen)
    float r2 = na(corr) ? 0.0 : corr * corr
    float statTrend = slopeN * r2
    float trendF = f_clamp(0.34 * stack + 0.33 * dist + 0.33 * statTrend, -1.0, 1.0)
    // trend-quality: efficiency ratio, signed
    float qualF = f_clamp((er - erTrend) / (1.0 - erTrend), -1.0, 1.0) * (close >= eS ? 1.0 : -1.0)
    // momentum: RSI centered + slope
    float rsi = ta.rsi(close, rsiLen)
    float rsiC = (rsi - 50.0) / 50.0
    float rsiSlope = f_clamp((rsi - rsi[3]) / 20.0, -1.0, 1.0)
    float momoF = f_clamp(0.6 * rsiC + 0.4 * rsiSlope, -1.0, 1.0)
    // structure: range location + swing-break (BOS-lite)
    float hh = ta.highest(high, structLen)
    float ll = ta.lowest(low, structLen)
    float loc = hh > ll ? (close - ll) / (hh - ll) * 2.0 - 1.0 : 0.0
    float ph = ta.pivothigh(high, structPiv, structPiv)
    float pl = ta.pivotlow(low, structPiv, structPiv)
    var float lastPH = na
    var float lastPL = na
    lastPH := na(ph) ? lastPH : ph
    lastPL := na(pl) ? lastPL : pl
    float bos = 0.0
    bos := not na(lastPH) and close > lastPH ? 1.0 : not na(lastPL) and close < lastPL ? -1.0 : 0.0
    float structF = f_clamp(0.6 * loc + 0.4 * bos, -1.0, 1.0)
    // flow: MFI centered + OHLC delta proxy
    float mfi = ta.mfi(hlc3, mfiLen)
    float mfiC = (mfi - 50.0) / 50.0
    float rng = high - low
    float delta = rng > 0 ? ((close - low) - (high - close)) / rng : 0.0
    float deltaAvg = ta.ema(delta, mfiLen)
    float flowF = f_clamp(0.6 * mfiC + 0.4 * deltaAvg, -1.0, 1.0)
    // mean-reversion: z-score of price vs mean (contrarian sign)
    float basis = ta.sma(close, mrLen)
    float sd = ta.stdev(close, mrLen)
    float zc = sd > 0 ? (close - basis) / sd : 0.0
    float mrF = f_clamp(-zc / 2.5, -1.0, 1.0)
    // volatility context score 0..1 (ATR percentile)
    float volScore = ta.percentrank(atrv, 100) / 100.0
    [trendF, momoF, structF, flowF, mrF, qualF, regCode, volScore]

// ── COMPOSER: regime-adaptive base weights × per-factor Edge multipliers ──
// em index: 0 trend · 1 qual · 2 momo · 3 struct · 4 flow · 5 mr
f_compose(float t, float m, float s, float fl, float mv, float q, int reg, float vs, float[] em) =>
    float wT = 0.18, wQ = 0.15, wM = 0.18, wS = 0.16, wV = 0.14, wR = 0.19
    if reg == 2 or reg == -2
        wT := 0.22
        wQ := 0.20
        wM := 0.22
        wS := 0.12
        wV := 0.12
        wR := 0.12
    else if reg == 0
        wT := 0.12
        wQ := 0.10
        wM := 0.12
        wS := 0.16
        wV := 0.12
        wR := 0.38
    wT := wT * array.get(em, 0)
    wQ := wQ * array.get(em, 1)
    wM := wM * array.get(em, 2)
    wS := wS * array.get(em, 3)
    wV := wV * array.get(em, 4)
    wR := wR * array.get(em, 5)
    float wsum = wT + wQ + wM + wS + wV + wR
    float comp = wsum > 0 ? (wT * t + wQ * q + wM * m + wS * s + wV * fl + wR * mv) / wsum : 0.0
    comp := comp * (1.0 - 0.30 * math.max(0.0, vs))
    f_clamp(comp, -1.0, 1.0)

// ───────────────────────────── THEME ───────────────────────────────────────
bool isDark = themeMode == "Dark" ? true : themeMode == "Light" ? false : f_luma(chart.bg_color) < 0.5
color uiBull = bullCol
color uiBear = bearCol
color uiGold = #e0a020
color uiText = isDark ? color.new(#e8e8e8, 0) : color.new(#1a1a1a, 0)
color uiDim  = isDark ? color.new(#8a8f99, 0) : color.new(#6a6f78, 0)
color hdrBg  = isDark ? color.new(#1c2230, 0) : color.new(#e6e9ef, 0)
color rowBg  = isDark ? color.new(#0e1420, 40) : color.new(#f6f7fa, 20)
color sepBg  = isDark ? color.new(#2a3242, 0) : color.new(#d2d6de, 0)
color neutBg = isDark ? color.new(#3a4150, 30) : color.new(#c8ccd4, 20)

// cell background by directional strength
f_cellCol(float sig) =>
    float m = math.min(math.abs(sig), 1.0)
    sig > 0.03 ? color.new(uiBull, 100 - int(28 + m * 60)) : sig < -0.03 ? color.new(uiBear, 100 - int(28 + m * 60)) : neutBg
f_arrow(float sig) => sig > 0.10 ? "▲" : sig < -0.10 ? "▼" : "·"
f_arrCol(float sig) => sig > 0.10 ? color.new(#ffffff, 0) : sig < -0.10 ? color.new(#ffffff, 0) : uiDim

// ───────────────────────────── VOLUME FIX ──────────────────────────────────
float volRaw = na(volume) ? na : volume
float volBorrow = str.length(volBorrowSym) > 0 ? request.security(volBorrowSym, timeframe.period, volume, ignore_invalid_symbol = true) : na
float vol = not na(volRaw) and volRaw > 0 ? volRaw : (not na(volBorrow) ? volBorrow : na)
bool hasVol = not na(vol) and vol > 0

// ───────────────────────────── FETCH 7 TFs ─────────────────────────────────
[tr1, mo1, st1, fl1, mv1, qu1, rg1, vz1] = request.security(syminfo.tickerid, tf1i, f_factors(), lookahead = barmerge.lookahead_off)
[tr2, mo2, st2, fl2, mv2, qu2, rg2, vz2] = request.security(syminfo.tickerid, tf2i, f_factors(), lookahead = barmerge.lookahead_off)
[tr3, mo3, st3, fl3, mv3, qu3, rg3, vz3] = request.security(syminfo.tickerid, tf3i, f_factors(), lookahead = barmerge.lookahead_off)
[tr4, mo4, st4, fl4, mv4, qu4, rg4, vz4] = request.security(syminfo.tickerid, tf4i, f_factors(), lookahead = barmerge.lookahead_off)
[tr5, mo5, st5, fl5, mv5, qu5, rg5, vz5] = request.security(syminfo.tickerid, tf5i, f_factors(), lookahead = barmerge.lookahead_off)
[tr6, mo6, st6, fl6, mv6, qu6, rg6, vz6] = request.security(syminfo.tickerid, tf6i, f_factors(), lookahead = barmerge.lookahead_off)
[tr7, mo7, st7, fl7, mv7, qu7, rg7, vz7] = request.security(syminfo.tickerid, tf7i, f_factors(), lookahead = barmerge.lookahead_off)
// chart-TF factors (direct) for per-factor calibration
[cT, cM, cS, cF, cR, cQ, cRg, cVz] = f_factors()  // cRg,cVz unused on chart TF; kept to reuse one request path
float cAtr = nz(ta.atr(14), close * 0.001)

// ───────────────────────────── BLOCK B — CONTEXT (chart TF) ────────────────
// shared signed-volume sub-bars for VPIN / Kyle's lambda
[ltfClose, ltfOpen, ltfVol] = request.security_lower_tf(syminfo.tickerid, cvdLTF, [close, open, volume])
float ltfNet = 0.0
float ltfTot = 0.0
int nSub = array.size(ltfClose)
if nSub > 0
    for i = 0 to nSub - 1
        float cc = array.get(ltfClose, i)
        float oo = array.get(ltfOpen, i)
        float vv = array.get(ltfVol, i)
        if not na(vv) and vv > 0
            float sgn = cc > oo ? 1.0 : cc < oo ? -1.0 : 0.0
            ltfNet += sgn * vv
            ltfTot += vv

// VALUE — VWAP-band proxy (external TPO position preferred)
float valF = na
if bValue
    if f_isExt(valExt)
        valF := f_clamp(valExt, -1.0, 1.0)
    else
        float vsma = ta.vwap(hlc3)
        float vsd = ta.stdev(close, valLen)
        valF := vsd > 0 ? f_clamp((close - vsma) / (vsd * 2.0), -1.0, 1.0) : 0.0

// FLOW-QUALITY — bucketed VPIN toxicity + Kyle's lambda impact
float vpin = na
if bVpin
    if f_wired(vpinExt) and vpinExt >= 0 and vpinExt <= 100
        vpin := vpinExt / 100.0
    else if hasVol
        float avgV = ta.sma(vol, vpinAvg)
        float bucket = avgV * vpinBars
        var float accVol = 0.0
        var float accBuy = 0.0
        var float accSell = 0.0
        var array<float> imb = array.new_float(0)
        float useNet = nSub > 0 ? ltfNet : ((close > open ? 1.0 : close < open ? -1.0 : 0.0) * vol)
        float useTot = nSub > 0 ? ltfTot : vol
        float buyV = (useTot + useNet) / 2.0
        float sellV = (useTot - useNet) / 2.0
        accVol += vol
        accBuy += math.max(buyV, 0.0)
        accSell += math.max(sellV, 0.0)
        if bucket > 0 and accVol >= bucket
            float tot = accBuy + accSell
            if tot > 0
                array.push(imb, math.abs(accBuy - accSell) / tot)
                if array.size(imb) > vpinN
                    array.shift(imb)
            accVol := 0.0
            accBuy := 0.0
            accSell := 0.0
        vpin := array.size(imb) > 0 ? array.avg(imb) : na
// Kyle's lambda — price impact per unit signed volume
float dP = close - close[1]
float sVol = nSub > 0 ? ltfNet : ((close > open ? 1.0 : close < open ? -1.0 : 0.0) * (hasVol ? vol : 1.0))
float lamCorr = ta.correlation(dP, sVol, lamLook)
float sdP = ta.stdev(dP, lamLook)
float sdV = ta.stdev(sVol, lamLook)
float lambda = (not na(lamCorr) and sdV > 0) ? math.abs(lamCorr) * sdP / sdV : na
float lamPct = not na(lambda) ? ta.percentrank(lambda, lamRank) / 100.0 : na

// OPTIONS / POSITIONING — implied-vol rank + vol term + basis (single vol leg)
float ivRankD = na
float zTermD = na
if bOptions and not f_isExt(optExt)
    [ivR_, zt_] = request.security(vixSym, "D", legCalc(ivLen, termLen, oNormLen), ignore_invalid_symbol = true)
    ivRankD := ivR_
    zTermD := zt_
float ivRankShow = ivRankD
float optF = na
if bOptions
    if f_isExt(optExt)
        optF := f_clamp(optExt / 2.5, -1.0, 1.0)
    else
        float fut = request.security(futSym, timeframe.period, close, ignore_invalid_symbol = true)
        float spot = request.security(spotSym, timeframe.period, close, ignore_invalid_symbol = true)
        float basisRaw = (not na(fut) and not na(spot) and spot != 0) ? (fut - spot) / spot * 100.0 : na
        float basisZ = not na(basisRaw) ? f_z(basisRaw, ta.sma(basisRaw, oNormLen), ta.stdev(basisRaw, oNormLen)) : 0.0
        float ivComp = not na(ivRankD) ? (ivRankD - 50.0) / 50.0 : 0.0
        float termComp = not na(zTermD) ? f_clamp(zTermD / 2.0, -1.0, 1.0) : 0.0
        float optComp = 0.45 * ivComp + 0.30 * termComp + 0.25 * f_clamp(basisZ / 2.0, -1.0, 1.0)
        optF := f_clamp(optComp, -1.0, 1.0)

// INTERMARKET — basis + correlation-gated leader
float imF = na
float corrShow = na
if bBasis
    if f_isExt(basisExt)
        imF := f_clamp(basisExt / 2.5, -1.0, 1.0)
    else
        float led = request.security(leaderSym, timeframe.period, close, ignore_invalid_symbol = true)
        float ledRet = not na(led) ? (led - led[basisLen]) / (led[basisLen] != 0 ? led[basisLen] : 1.0) : na
        float ownRet = (close - close[basisLen]) / (close[basisLen] != 0 ? close[basisLen] : 1.0)
        float cc = not na(led) ? ta.correlation(close, led, corrLen) : na
        corrShow := cc
        float ledDir = not na(ledRet) ? f_clamp(ledRet * 20.0, -1.0, 1.0) * (leadInv ? -1.0 : 1.0) : 0.0
        float gate = (not na(cc) and math.abs(cc) >= corrMin) ? 1.0 : 0.0
        imF := f_clamp(ledDir * gate, -1.0, 1.0)

// SELF-EXCITATION — Hardiman-Bouchaud branching-ratio moment estimator
float hawkes = na
if bHawkes
    if f_wired(hawkExt) and hawkExt >= 0 and hawkExt <= 1
        hawkes := hawkExt
    else
        float flowMag = hasVol ? vol : math.abs(close - close[1])
        float typ = ta.sma(flowMag, 50)
        bool ev = typ > 0 and flowMag > typ * hawkEvThr
        var int binCount = 0
        var int barsInBin = 0
        var array<float> binCounts = array.new_float(0)
        barsInBin += 1
        if ev
            binCount += 1
        if barsInBin >= hawkBin
            array.push(binCounts, binCount)
            if array.size(binCounts) > hawkNBins
                array.shift(binCounts)
            binCount := 0
            barsInBin := 0
        if array.size(binCounts) >= 10
            float mean = array.avg(binCounts)
            float varc = f_arrVar(binCounts)
            float ratio = varc > 0 ? mean / varc : na
            hawkes := not na(ratio) ? f_clamp(1.0 - math.sqrt(math.min(ratio, 1.0)), 0.0, 1.0) : na

// VRP / VIX — implied vs realized
float vixStress = na
float vrpSign = na
if bVRP
    float iv = request.security(vixSym, timeframe.period, close, ignore_invalid_symbol = true)
    float rv = ta.stdev(math.log(close / close[1]), vrpLen) * math.sqrt(252.0) * 100.0
    if not na(iv) and not na(rv)
        vixStress := f_clamp(ta.percentrank(iv, 100) / 100.0, 0.0, 1.0)
        vrpSign := f_clamp((iv - rv) / (rv != 0 ? rv : 1.0), -1.0, 1.0)

// CHANGE-POINT — two-sided CUSUM on standardized returns
float ret = math.log(close / close[1])
float muR = ta.sma(ret, cpLen)
float sdR = ta.stdev(ret, cpLen)
float zR = sdR > 0 ? (ret - muR) / sdR : 0.0
var float cSumHi = 0.0
var float cSumLo = 0.0
cSumHi := math.max(0.0, cSumHi + zR - cpK)
cSumLo := math.min(0.0, cSumLo + zR + cpK)
bool cpFired = bCP and (cSumHi > cpH or cSumLo < -cpH)
if cpFired
    cSumHi := 0.0
    cSumLo := 0.0
var int cpLastBar = -100000
if cpFired
    cpLastBar := bar_index
bool cpActive = bCP and (bar_index - cpLastBar) < cpHold
int cpDir = cSumHi >= math.abs(cSumLo) ? 1 : -1

// ───────────────────────────── PER-FACTOR EDGE ─────────────────────────────
var array<int>   pBar = array.new_int(0)
var array<float> pRef = array.new_float(0)
var array<int>   pDir = array.new_int(0)
var array<int>   pFac = array.new_int(0)
var array<float> fHit = array.new_float(6, 0.0)
var array<float> fTot = array.new_float(6, 0.0)
var array<int>   fUp  = array.new_int(6, 0)
var array<int>   fDn  = array.new_int(6, 0)
var float baseUp = 0.0
var float baseDn = 0.0
var float baseN  = 0.0
var array<int>   bBar = array.new_int(0)
var array<float> bRef = array.new_float(0)
var array<float> edgeMul = array.new_float(6, 1.0)

if barstate.isconfirmed and edgeOn
    // log each factor when it fires
    array<float> fv = array.from(cT, cQ, cM, cS, cF, cR)
    for id = 0 to 5
        float v = array.get(fv, id)
        if math.abs(v) >= edgeThr
            array.push(pBar, bar_index)
            array.push(pRef, close)
            array.push(pDir, v > 0 ? 1 : -1)
            array.push(pFac, id)
    // base sampler
    array.push(bBar, bar_index)
    array.push(bRef, close)
    // resolve factor events
    if array.size(pBar) > 0
        int i = 0
        while i < array.size(pBar)
            if bar_index - array.get(pBar, i) >= edgeHoriz
                int id = array.get(pFac, i)
                int dir = array.get(pDir, i)
                float mv = close - array.get(pRef, i)
                bool hit = dir > 0 ? mv >= edgeMoveA * cAtr : mv <= -edgeMoveA * cAtr
                array.set(fTot, id, array.get(fTot, id) + 1.0)
                if hit
                    array.set(fHit, id, array.get(fHit, id) + 1.0)
                if dir > 0
                    array.set(fUp, id, array.get(fUp, id) + 1)
                else
                    array.set(fDn, id, array.get(fDn, id) + 1)
                array.remove(pBar, i)
                array.remove(pRef, i)
                array.remove(pDir, i)
                array.remove(pFac, i)
            else
                i += 1
    // resolve base events (both directions)
    if array.size(bBar) > 0
        int j = 0
        while j < array.size(bBar)
            if bar_index - array.get(bBar, j) >= edgeHoriz
                float mv = close - array.get(bRef, j)
                baseN += 1.0
                if mv >= edgeMoveA * cAtr
                    baseUp += 1.0
                if mv <= -edgeMoveA * cAtr
                    baseDn += 1.0
                array.remove(bBar, j)
                array.remove(bRef, j)
            else
                j += 1
    // recompute multipliers
    for id = 0 to 5
        float tot = array.get(fTot, id)
        float mul = 1.0
        if tot >= edgeMinN and baseN > 0
            float hitPct = array.get(fHit, id) / tot * 100.0
            float bUp = baseUp / baseN * 100.0
            float bDn = baseDn / baseN * 100.0
            int un = array.get(fUp, id)
            int dn = array.get(fDn, id)
            float bp = (un + dn) > 0 ? (un * bUp + dn * bDn) / (un + dn) : 50.0
            float edge = hitPct - bp
            mul := f_clamp(1.0 + edgeGain * edge / 100.0, edgeMinW, edgeMaxW)
        array.set(edgeMul, id, mul)

// ───────────────────────────── COMPOSE 7 TFs ───────────────────────────────
float c1 = f_compose(tr1, mo1, st1, fl1, mv1, qu1, rg1, vz1, edgeMul)
float c2 = f_compose(tr2, mo2, st2, fl2, mv2, qu2, rg2, vz2, edgeMul)
float c3 = f_compose(tr3, mo3, st3, fl3, mv3, qu3, rg3, vz3, edgeMul)
float c4 = f_compose(tr4, mo4, st4, fl4, mv4, qu4, rg4, vz4, edgeMul)
float c5 = f_compose(tr5, mo5, st5, fl5, mv5, qu5, rg5, vz5, edgeMul)
float c6 = f_compose(tr6, mo6, st6, fl6, mv6, qu6, rg6, vz6, edgeMul)
float c7 = f_compose(tr7, mo7, st7, fl7, mv7, qu7, rg7, vz7, edgeMul)

// ───────────────────────────── CONTEXT DIRECTIONAL TILT ────────────────────
float dirNum = 0.0
float dirW = 0.0
if not na(valF)
    dirNum += valF * 0.5
    dirW += 0.5
if not na(optF)
    dirNum += optF * 1.0
    dirW += 1.0
if not na(imF)
    dirNum += imF * 0.8
    dirW += 0.8
if not na(vrpSign)
    dirNum += vrpSign * 0.4
    dirW += 0.4
float dirScore = dirW > 0 ? f_clamp(dirNum / dirW, -1.0, 1.0) : 0.0

// ───────────────────────────── HORIZON COMPOSITES ──────────────────────────
// scalp 1-5m · intraday 5-60m · positional 60m-1D
float scalpRaw = 0.45 * c1 + 0.30 * c2 + 0.20 * c3 + 0.05 * c4
float intraRaw = 0.10 * c2 + 0.30 * c3 + 0.35 * c4 + 0.20 * c5 + 0.05 * c6
float posRaw   = 0.10 * c4 + 0.30 * c5 + 0.30 * c6 + 0.30 * c7
float scalpComp = dirW > 0 ? f_clamp((1.0 - bWeight) * scalpRaw + bWeight * dirScore, -1.0, 1.0) : scalpRaw
float intraComp = dirW > 0 ? f_clamp((1.0 - bWeight) * intraRaw + bWeight * dirScore, -1.0, 1.0) : intraRaw
float posComp   = dirW > 0 ? f_clamp((1.0 - bWeight * 0.5) * posRaw + bWeight * 0.5 * dirScore, -1.0, 1.0) : posRaw

// ───────────────────────────── CONFIDENCE ──────────────────────────────────
float conf = 1.0
if bVpin and not na(vpin) and vpin > 0.66
    conf -= 0.12
if bHawkes and not na(hawkes) and hawkes > 0.66
    conf -= 0.15
if bVRP and not na(vixStress) and vixStress > 0.66
    conf -= 0.18
if cpActive
    conf -= 0.20
if bVpin and not na(vpin) and not na(lamPct) and vpin > 0.6 and lamPct < 0.33
    conf -= 0.08
conf := f_clamp(conf, 0.4, 1.0)

// ───────────────────────────── SCORES + VERDICTS ───────────────────────────
f_verdict(float comp) => comp > sigThr ? "BULLISH" : comp < -sigThr ? "BEARISH" : "MIXED"
f_vcol(float comp) => comp > sigThr ? uiBull : comp < -sigThr ? uiBear : uiGold
int scalpScore = int(math.round(scalpComp * conf * 100.0))
int intraScore = int(math.round(intraComp * conf * 100.0))
int posScore   = int(math.round(posComp   * conf * 100.0))
string scalpV = f_verdict(scalpComp)
string intraV = f_verdict(intraComp)
string posV   = f_verdict(posComp)
color scalpC = f_vcol(scalpComp)
color intraC = f_vcol(intraComp)
color posC   = f_vcol(posComp)

// alignment across the 7 TFs
int upN = (c1 > sigThr ? 1 : 0) + (c2 > sigThr ? 1 : 0) + (c3 > sigThr ? 1 : 0) + (c4 > sigThr ? 1 : 0) + (c5 > sigThr ? 1 : 0) + (c6 > sigThr ? 1 : 0) + (c7 > sigThr ? 1 : 0)
int dnN = (c1 < -sigThr ? 1 : 0) + (c2 < -sigThr ? 1 : 0) + (c3 < -sigThr ? 1 : 0) + (c4 < -sigThr ? 1 : 0) + (c5 < -sigThr ? 1 : 0) + (c6 < -sigThr ? 1 : 0) + (c7 < -sigThr ? 1 : 0)
int alignN = math.max(upN, dnN)

// edge health: how many factors carry positive edge
int edgePos = 0
for id = 0 to 5
    if array.get(edgeMul, id) > 1.02
        edgePos += 1

// ───────────────────────────── DATA HEALTH ─────────────────────────────────
bool volOK = hasVol
bool ltfOK = nSub > 0
bool ctxOK = (not bOptions or not na(optF)) and (not bBasis or not na(imF))
string dataMsg = volOK and ltfOK and ctxOK ? "OK" : not volOK ? "No volume — set borrow symbol" : not ltfOK ? "No sub-bars (raise delta TF)" : "Context symbols resolving…"
color dataCol = volOK and ltfOK and ctxOK ? uiBull : uiGold

// ───────────────────────────── ALERTS ──────────────────────────────────────
alertcondition(scalpScore >= confAlert,  "Scalp strong bull",     "Confluence: Scalp bullish, high confidence")
alertcondition(scalpScore <= -confAlert, "Scalp strong bear",     "Confluence: Scalp bearish, high confidence")
alertcondition(intraScore >= confAlert,  "Intraday strong bull",  "Confluence: Intraday bullish, high confidence")
alertcondition(intraScore <= -confAlert, "Intraday strong bear",  "Confluence: Intraday bearish, high confidence")
alertcondition(posScore >= confAlert,    "Positional strong bull","Confluence: Positional bullish, high confidence")
alertcondition(posScore <= -confAlert,   "Positional strong bear","Confluence: Positional bearish, high confidence")
alertcondition(cpFired, "Regime shift", "Confluence: change-point / regime shift detected")

// ───────────────────────────── EXPORTS ─────────────────────────────────────
plot(scalpComp, "Scalp bias (-1..1)",       display = display.none)
plot(intraComp, "Intraday bias (-1..1)",    display = display.none)
plot(posComp,   "Positional bias (-1..1)",  display = display.none)
plot(scalpScore,"Scalp score",      display = display.none)
plot(intraScore,"Intraday score",   display = display.none)
plot(posScore,  "Positional score", display = display.none)
plot(conf,      "Confidence",      display = display.none)
plot(na(vpin) ? na : vpin * 100.0, "Flow toxicity (0-100)", display = display.none)
plot(na(hawkes) ? na : hawkes, "Self-excitation (0-1)",   display = display.none)
plot(cpActive ? 1 : 0, "Regime shift (0/1)",      display = display.none)
plot(alignN, "TF alignment (0-7)", display = display.none)

// ───────────────────────────── DISPLAY HELPERS ─────────────────────────────
f_regTxt(int r) => r == 2 ? "T▲" : r == -2 ? "T▼" : r == 1 ? "Vol" : "Rng"
f_regCol(int r) => r == 2 ? color.new(uiBull, 55) : r == -2 ? color.new(uiBear, 55) : r == 1 ? color.new(uiGold, 55) : neutBg
f_volTxt(float v) => v > 0.66 ? "Hi" : v < 0.33 ? "Lo" : "Md"
f_volCol(float v) => v > 0.66 ? color.new(uiGold, 55) : v < 0.33 ? color.new(uiDim, 70) : neutBg
f_ctxTxt(float s, string p, string n, string z) => s > 0.15 ? p : s < -0.15 ? n : z
f_ctxCol(float s) => s > 0.15 ? color.new(uiBull, 65) : s < -0.15 ? color.new(uiBear, 65) : neutBg

var table tbl = na
sz = f_sz(tblSize)
f_facRow(int row, string lbl, array<float> vals) =>
    table.cell(tbl, 0, row, lbl, text_color = uiText, text_size = sz, bgcolor = rowBg, text_halign = text.align_left)
    for c = 0 to 6
        float v = array.get(vals, c)
        table.cell(tbl, c + 1, row, f_arrow(v), text_color = f_arrCol(v), text_size = sz, bgcolor = f_cellCol(v))
f_mergeRow(int row, string lbl, color lblBg, color lblTx, string val, color valTx, color valBg) =>
    table.cell(tbl, 0, row, lbl, text_color = lblTx, text_size = sz, bgcolor = lblBg, text_halign = text.align_left)
    table.cell(tbl, 1, row, val, text_color = valTx, text_size = sz, bgcolor = valBg, text_halign = text.align_center)
    for c = 2 to 7
        table.cell(tbl, c, row, "", bgcolor = valBg)
    table.merge_cells(tbl, 1, row, 7, row)
if showMain and barstate.islast
    tbl := table.new(f_posT(tblPosStr), 8, 24, border_width = 1, border_color = sepBg, frame_width = 1, frame_color = sepBg)

    // arrays for the 7-TF grid rows
    array<float> compArr = array.from(c1, c2, c3, c4, c5, c6, c7)
    array<float> trArr   = array.from(tr1, tr2, tr3, tr4, tr5, tr6, tr7)
    array<float> qArr    = array.from(qu1, qu2, qu3, qu4, qu5, qu6, qu7)
    array<float> mArr    = array.from(mo1, mo2, mo3, mo4, mo5, mo6, mo7)
    array<float> sArr    = array.from(st1, st2, st3, st4, st5, st6, st7)
    array<float> flArr   = array.from(fl1, fl2, fl3, fl4, fl5, fl6, fl7)
    array<float> mvArr   = array.from(mv1, mv2, mv3, mv4, mv5, mv6, mv7)
    array<int>   rgArr   = array.from(rg1, rg2, rg3, rg4, rg5, rg6, rg7)
    array<float> vzArr   = array.from(vz1, vz2, vz3, vz4, vz5, vz6, vz7)
    array<string> tfHdr  = array.from("1m", "3m", "5m", "15m", "1H", "4H", "1D")

    // header
    table.cell(tbl, 0, 0, "MATRIX", text_color = uiText, text_size = sz, bgcolor = hdrBg, text_halign = text.align_left)
    for c = 0 to 6
        table.cell(tbl, c + 1, 0, array.get(tfHdr, c), text_color = uiText, text_size = sz, bgcolor = hdrBg)

    // BIAS row (per-TF composite)
    table.cell(tbl, 0, 1, "BIAS", text_color = uiText, text_size = sz, bgcolor = hdrBg, text_halign = text.align_left)
    for c = 0 to 6
        float v = array.get(compArr, c)
        table.cell(tbl, c + 1, 1, f_arrow(v), text_color = f_arrCol(v), text_size = sz, bgcolor = f_cellCol(v))

    // factor rows (arrow + colour only)
    f_facRow(2, "Trend", trArr)
    f_facRow(3, "T-Qual", qArr)
    f_facRow(4, "Momentum", mArr)
    f_facRow(5, "Structure", sArr)
    f_facRow(6, "Flow", flArr)
    f_facRow(7, "Mean-Rev", mvArr)

    // Vol row
    table.cell(tbl, 0, 8, "Vol", text_color = uiText, text_size = sz, bgcolor = rowBg, text_halign = text.align_left)
    for c = 0 to 6
        float v = array.get(vzArr, c)
        table.cell(tbl, c + 1, 8, f_volTxt(v), text_color = uiText, text_size = sz, bgcolor = f_volCol(v))

    // Regime row
    table.cell(tbl, 0, 9, "Regime", text_color = uiText, text_size = sz, bgcolor = rowBg, text_halign = text.align_left)
    for c = 0 to 6
        int r = array.get(rgArr, c)
        table.cell(tbl, c + 1, 9, f_regTxt(r), text_color = uiText, text_size = sz, bgcolor = f_regCol(r))

    // CONTEXT header
    f_mergeRow(10, "CONTEXT", hdrBg, uiText, "chart-timeframe read", uiDim, hdrBg)

    // Value / auction location
    string valTxt = not bValue or na(valF) ? "—" : f_ctxTxt(valF, "Premium", "Discount", "Fair value")
    color valBgC  = not bValue or na(valF) ? rowBg : f_ctxCol(valF)
    f_mergeRow(11, "Value", rowBg, uiText, valTxt, uiText, valBgC)

    // Flow-quality: toxicity + impact
    string toxTxt = na(vpin) ? "—" : vpin > 0.66 ? "Toxic" : vpin < 0.33 ? "Clean" : "Mid"
    string impTxt = na(lamPct) ? "" : lamPct > 0.66 ? " · Impact" : lamPct < 0.33 ? " · Absorbed" : " · Neutral"
    color fqBg    = na(vpin) ? rowBg : vpin > 0.66 ? color.new(uiGold, 45) : vpin < 0.33 ? color.new(uiDim, 65) : neutBg
    f_mergeRow(12, "Flow-Q", rowBg, uiText, toxTxt + (na(vpin) ? "" : impTxt), uiText, fqBg)

    // Options / positioning
    string optTxt = not bOptions or na(optF) ? "—" : f_arrow(optF) + " " + f_ctxTxt(optF, "Bullish", "Bearish", "Neutral") + (na(ivRankShow) ? "" : "  ·  IV " + str.tostring(math.round(ivRankShow)) + "%")
    color optBg   = not bOptions or na(optF) ? rowBg : f_ctxCol(optF)
    f_mergeRow(13, "Options", rowBg, uiText, optTxt, uiText, optBg)

    // Intermarket leader
    string imTxt = not bBasis or na(imF) ? "—" : f_arrow(imF) + " " + f_ctxTxt(imF, "Leader up", "Leader dn", "Flat") + (na(corrShow) ? "" : "  ·  ρ " + str.tostring(corrShow, "#.00"))
    color imBg   = not bBasis or na(imF) ? rowBg : f_ctxCol(imF)
    f_mergeRow(14, "Intermkt", rowBg, uiText, imTxt, uiText, imBg)

    // Self-excitation
    string hkTxt = na(hawkes) ? "—" : (hawkes > 0.66 ? "Critical" : hawkes < 0.33 ? "Quiet" : "Building") + "  ·  " + str.tostring(hawkes, "#.00")
    color hkBg   = na(hawkes) ? rowBg : hawkes > 0.66 ? color.new(uiGold, 40) : hawkes < 0.33 ? color.new(uiDim, 65) : neutBg
    f_mergeRow(15, "Self-Exc", rowBg, uiText, hkTxt, uiText, hkBg)

    // VRP / VIX
    string vsTxt = na(vixStress) ? "—" : (vixStress > 0.66 ? "Stress" : vixStress < 0.33 ? "Calm" : "Mid") + (na(vrpSign) ? "" : "  ·  " + (vrpSign > 0 ? "IV rich" : "IV cheap"))
    color vsBg   = na(vixStress) ? rowBg : vixStress > 0.66 ? color.new(uiGold, 40) : vixStress < 0.33 ? color.new(uiDim, 65) : neutBg
    f_mergeRow(16, "VRP/VIX", rowBg, uiText, vsTxt, uiText, vsBg)

    // Regime-shift (change-point)
    string cpTxt = not bCP ? "off" : cpActive ? ("REGIME SHIFT " + (cpDir > 0 ? "▲" : "▼")) : "Stable"
    color cpBg   = not bCP ? rowBg : cpActive ? color.new(uiGold, 20) : color.new(uiDim, 65)
    color cpTx   = cpActive ? color.new(#ffffff, 0) : uiText
    f_mergeRow(17, "Shift", rowBg, uiText, cpTxt, cpTx, cpBg)

    // DECISION header
    f_mergeRow(18, "DECISION", hdrBg, uiText, "verdict · score", uiDim, hdrBg)

    // decision bars (full-width, confidence-weighted)
    f_mergeRow(19, "SCALP",      color.new(scalpC, 22), color.new(#ffffff, 0), scalpV + "   " + (scalpScore >= 0 ? "+" : "") + str.tostring(scalpScore), color.new(#ffffff, 0), color.new(scalpC, 12))
    f_mergeRow(20, "INTRADAY",   color.new(intraC, 22), color.new(#ffffff, 0), intraV + "   " + (intraScore >= 0 ? "+" : "") + str.tostring(intraScore), color.new(#ffffff, 0), color.new(intraC, 12))
    f_mergeRow(21, "POSITIONAL", color.new(posC, 22),   color.new(#ffffff, 0), posV   + "   " + (posScore   >= 0 ? "+" : "") + str.tostring(posScore),   color.new(#ffffff, 0), color.new(posC, 12))

    // confidence / edge / alignment
    color confBg = conf >= 0.85 ? color.new(uiBull, 55) : conf >= 0.6 ? neutBg : color.new(uiGold, 45)
    f_mergeRow(22, "Conf", rowBg, uiText, str.tostring(math.round(conf * 100)) + "%   ·   Edge " + str.tostring(edgePos) + "/6   ·   Align " + str.tostring(alignN) + "/7", uiText, confBg)

    // data health
    f_mergeRow(23, "Data", rowBg, uiText, dataMsg, dataCol, rowBg)

// ───────────────────────────── IDENTITY STRIP ──────────────────────────────
var table idt = na
if showId and barstate.islast
    idt := table.new(position.bottom_center, 1, 1)
    table.cell(idt, 0, 0, "Confluence Matrix  ·  " + syminfo.ticker + "  ·  " + timeframe.period, text_color = uiDim, text_size = size.tiny, bgcolor = color.new(hdrBg, 20))

// ───────────────────────────── LEGEND ──────────────────────────────────────
var table leg = na
if showLegend and barstate.islast
    leg := table.new(f_posL(legPosStr), 2, 9, border_width = 1, border_color = sepBg, frame_width = 1, frame_color = sepBg)
    szl = size.tiny
    table.cell(leg, 0, 0, "LEGEND", text_color = uiText, text_size = szl, bgcolor = hdrBg, text_halign = text.align_left)
    table.cell(leg, 1, 0, "", bgcolor = hdrBg)
    table.cell(leg, 0, 1, "▲ / ▼ / ·", text_color = uiText, text_size = szl, bgcolor = rowBg, text_halign = text.align_left)
    table.cell(leg, 1, 1, "up / down / neutral", text_color = uiDim, text_size = szl, bgcolor = rowBg, text_halign = text.align_left)
    table.cell(leg, 0, 2, "green / red", text_color = uiText, text_size = szl, bgcolor = color.new(uiBull, 60), text_halign = text.align_left)
    table.cell(leg, 1, 2, "bull / bear (brighter = stronger)", text_color = uiDim, text_size = szl, bgcolor = rowBg, text_halign = text.align_left)
    table.cell(leg, 0, 3, "gold", text_color = uiText, text_size = szl, bgcolor = color.new(uiGold, 45), text_halign = text.align_left)
    table.cell(leg, 1, 3, "caution: high / stretched / shift", text_color = uiDim, text_size = szl, bgcolor = rowBg, text_halign = text.align_left)
    table.cell(leg, 0, 4, "dim", text_color = uiText, text_size = szl, bgcolor = color.new(uiDim, 70), text_halign = text.align_left)
    table.cell(leg, 1, 4, "quiet / low / calm", text_color = uiDim, text_size = szl, bgcolor = rowBg, text_halign = text.align_left)
    table.cell(leg, 0, 5, "Regime", text_color = uiText, text_size = szl, bgcolor = rowBg, text_halign = text.align_left)
    table.cell(leg, 1, 5, "T▲/T▼ trend · Rng range · Vol volatile", text_color = uiDim, text_size = szl, bgcolor = rowBg, text_halign = text.align_left)
    table.cell(leg, 0, 6, "Flow-Q", text_color = uiText, text_size = szl, bgcolor = rowBg, text_halign = text.align_left)
    table.cell(leg, 1, 6, "Toxic+Impact = moving · Toxic+Absorb = reversal risk", text_color = uiDim, text_size = szl, bgcolor = rowBg, text_halign = text.align_left)
    table.cell(leg, 0, 7, "Score", text_color = uiText, text_size = szl, bgcolor = rowBg, text_halign = text.align_left)
    table.cell(leg, 1, 7, "−100..+100, confidence-weighted", text_color = uiDim, text_size = szl, bgcolor = rowBg, text_halign = text.align_left)
    table.cell(leg, 0, 8, "Conf", text_color = uiText, text_size = szl, bgcolor = rowBg, text_halign = text.align_left)
    table.cell(leg, 1, 8, "cut by toxicity / Hawkes / VIX / shift", text_color = uiDim, text_size = szl, bgcolor = rowBg, text_halign = text.align_left)

// ───────────────────────────── INFO PANEL (how-to) ─────────────────────────
var table inf = na
if showKey and barstate.islast
    inf := table.new(f_posL(legPosStr), 2, 8, border_width = 1, border_color = sepBg, frame_width = 1, frame_color = sepBg)
    szi = size.tiny
    table.cell(inf, 0, 0, "HOW TO READ", text_color = uiText, text_size = szi, bgcolor = hdrBg, text_halign = text.align_left)
    table.cell(inf, 1, 0, "", bgcolor = hdrBg)
    table.cell(inf, 0, 1, "1 · Grid colour", text_color = uiText, text_size = szi, bgcolor = rowBg, text_halign = text.align_left)
    table.cell(inf, 1, 1, "green = up bias · red = down · brighter = stronger", text_color = uiDim, text_size = szi, bgcolor = rowBg, text_halign = text.align_left)
    table.cell(inf, 0, 2, "2 · Decision rows", text_color = uiText, text_size = szi, bgcolor = rowBg, text_halign = text.align_left)
    table.cell(inf, 1, 2, "the coloured bar is the read for that horizon", text_color = uiDim, text_size = szi, bgcolor = rowBg, text_halign = text.align_left)
    table.cell(inf, 0, 3, "3 · Score", text_color = uiText, text_size = szi, bgcolor = rowBg, text_halign = text.align_left)
    table.cell(inf, 1, 3, "−100..+100 · big number = firm, confident read", text_color = uiDim, text_size = szi, bgcolor = rowBg, text_halign = text.align_left)
    table.cell(inf, 0, 4, "4 · Gold = caution", text_color = uiText, text_size = szi, bgcolor = color.new(uiGold, 55), text_halign = text.align_left)
    table.cell(inf, 1, 4, "high volatility / toxic flow / regime shift", text_color = uiDim, text_size = szi, bgcolor = rowBg, text_halign = text.align_left)
    table.cell(inf, 0, 5, "Mixed", text_color = uiText, text_size = szi, bgcolor = rowBg, text_halign = text.align_left)
    table.cell(inf, 1, 5, "no clear edge — nothing to do", text_color = uiDim, text_size = szi, bgcolor = rowBg, text_halign = text.align_left)
    table.cell(inf, 0, 6, "Horizons", text_color = uiText, text_size = szi, bgcolor = rowBg, text_halign = text.align_left)
    table.cell(inf, 1, 6, "Scalp = fast · Intraday = mid · Positional = slow", text_color = uiDim, text_size = szi, bgcolor = rowBg, text_halign = text.align_left)
    table.cell(inf, 0, 7, "Note", text_color = uiGold, text_size = szi, bgcolor = rowBg, text_halign = text.align_left)
    table.cell(inf, 1, 7, "market-state gauge, not financial advice", text_color = uiDim, text_size = szi, bgcolor = rowBg, text_halign = text.align_left)
````
