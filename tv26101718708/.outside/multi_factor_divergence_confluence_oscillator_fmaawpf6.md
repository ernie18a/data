# Multi Factor Divergence Confluence Oscillator

- url: https://www.tradingview.com/script/FmaawPF6-Multi-Factor-Divergence-Confluence-Oscillator/
- type: indicator
- pine_id: PUB;557222f8c53946b983832813e4d93b21
- version: 3.0

## Description

Multi-Factor Divergence Confluence Oscillator 

What it is

This indicator detects price/oscillator divergence on four independent indicator families at the same price pivots and reports how many of them agree. The lower-pane histogram shows the signed agreement count — positive (bullish) above the zero line, negative (bearish) below — and a signal is flagged only when at least N independent families diverge at the same swing. It is a context tool that measures agreement, not a buy/sell system, and it places no orders.

Why these components are combined (and why it is not just stacked indicators)

Divergence on a single oscillator is a weak, noisy signal. The instinctive "fix" is to stack several oscillators and look for agreement — but stacking RSI, Stochastic, MACD and similar tools does not create real confluence, because they are all rate-of-change of price. They are highly correlated, so a divergence on one almost always coincides with the others. That is one witness counted several times, which feels like confirmation while adding almost no new information.

Meaningful confluence requires independent witnesses. This script therefore measures divergence on four families chosen specifically because each looks at a different dimension of the same bar, and each covers a blind spot of the others:


Momentum — Relative Strength Index. The classic rate-of-change read. It says nothing about who is transacting or how far price has travelled.
Volume — Normalized Cumulative Volume Delta. Detrended, standardized signed volume — an order-flow read that is independent of price geometry. (Signed volume is estimated; see Limitations.)
Volatility — Parabolic-SAR-to-price extension, in ATR units. How stretched the current trend leg is relative to its trailing stop, normalized by volatility — a read that ignores both momentum and volume.
Forecast — price minus its linear-regression forecast. A z-scored "how far has price departed from its own fitted path" term, independent of the three above.


All four are rescaled to share polarity (up = bullish), so a single divergence rule applies to every engine and the counts are directly comparable. Counting agreement across these families is information; counting it within one family is not — that independence is the entire reason these four are combined, rather than four momentum clones.

How the parts work together


Each enabled family is reduced to one bounded, bullish-up oscillator.
At every confirmed price swing (the families share the same price pivots), each family is asked whether it diverges there. Bearish = price makes a higher high while the oscillator makes a lower high; bullish = price makes a lower low while the oscillator makes a higher low.
The number of agreeing families becomes the signed confluence histogram, with glowing tip dots on flagged signals and a connecting line/label on the pane.
A signal flag is raised only at or above the chosen agreement threshold. That threshold can adapt to the chart timeframe — lower timeframes are noisier, so by default 1–5m require four families, 15–60m require three, and above 60m require two.


How to use it


Read the height and sign of the histogram: how many independent families diverge, and in which direction. The flag lines and the optional shaded zones mark where agreement is strong (three or more).
Treat it as context that qualifies your own analysis, not a standalone trigger. A divergence marks where price and a flow/momentum read disagree; it can resolve either way. More agreement is rarer, not guaranteed-better.
The dashboard summarizes the last signal, which families diverged, the active engines, the current threshold, and whether the signed-volume estimate is using lower-timeframe data or the proxy.
Enable/disable any family, switch between regular (reversal) and hidden (continuation) divergence, and tune the pivot, gap and threshold settings to your instrument and style.


What is original

The originality is the integration discipline, not the individual techniques: divergence is measured only across deliberately independent families on one shared set of price pivots and one comparable axis, with an explicit rule that within-family agreement is excluded. The result is a single confluence read that resists the double-counting that ordinary multi-oscillator "confluence" tools fall into, plus a timeframe-adaptive agreement threshold and an honest, configurable, multi-market implementation.

Universal across markets (configurable data source)

The Price / High / Low sources are user-selectable in Settings, so the engine runs on any symbol, asset class or timeframe — equities, futures, forex, crypto or indices. The Volume family needs a symbol that reports real volume; otherwise it falls back to a high/low/close proxy, and the dashboard shows which is active. Defaults are tuned for NSE NIFTY index futures on intraday charts; change the sources, lengths and lower timeframe for any other instrument.

Concept credits

Relative Strength Index and Parabolic SAR — J. Welles Wilder Jr. Cumulative Volume Delta, linear-regression forecasting and price/oscillator divergence are standard, publicly documented techniques. This is an original integration built around those public concepts and is not affiliated with, nor endorsed by, any originator.

Limitations (honest)

Divergence is context, not a trigger. Signed volume is estimated from lower-timeframe sub-bars (or an intrabar proxy), not exchange aggressor data, so the Volume family is an approximation and is unreliable on instruments without real volume. Divergence confirms a few bars after its pivot — inherent to honest, non-repainting pivot detection. Past behaviour does not predict future results.

Disclaimer

For research and educational purposes only. This is not financial advice and carries no guarantee of profitability or accuracy. Indicators describe past behaviour; they do not predict the future. Trading involves risk of loss. Test out-of-sample and make your own decisions.

## Source Code

````pine
//@version=6
// ══════════════════════════════════════════════════════════════════════════════════════════════
// MULTI-FACTOR DIVERGENCE CONFLUENCE OSCILLATOR                                        v1.4
// ────────────────────────────────────────────────────────────────────────────────────────────
// WHAT IT IS
//   One pane that collapses NINE independent-style factors onto a single shared standard-
//   deviation (sigma) scale, draws ONE pair of extreme bands valid for all of them, and
//   measures how many reach the extreme at the SAME time (their CONFLUENCE). A consensus dot
//   prints on the band and an "Ext N" tag on price (N = how many lenses agree). The mean of
//   the nine (the COMPOSITE) is read for DIVERGENCE against price and for in-band REVERSALS.
//   A CALIBRATION harness then forward-scores all three signal types against an unconditional
//   base rate, so the tool reports whether its OWN signals carry any edge - not just asserts it.
//
//   The nine lenses (each standardized to sigma, up = bullish):
//     1 Fair value  - VWAP deviation          2 Volatility  - directional range expansion
//     3 Efficiency  - signed Kaufman ER        4 Positioning - basis (futures - spot)
//     5 Trend ext.  - SAR distance / ATR       6 Momentum    - RSI
//     7 Equilibrium - linreg deviation / ATR   8 Cycle       - Know Sure Thing
//     9 Order flow  - normalized cumulative volume delta
//
// WHY THESE ARE COMBINED  (mashup rationale)
//   Each lens answers "is price stretched?" through a DIFFERENT physical quantity - location
//   vs a mean, volatility, path quality, cross-instrument carry, trend extension, momentum,
//   equilibrium distance, cycle, order flow. Standardizing every one to the SAME sigma axis
//   makes them directly comparable, so one pair of bands is valid for all nine and the COUNT
//   at the extreme becomes the signal: broad agreement that price is stretched is a stronger
//   exhaustion read than any single oscillator. The composite (their mean) is the natural
//   object on which to read divergence and reversals, and the calibration harness ties the
//   whole construction back to realised forward outcomes.
//
// HOW IT WORKS
//   - LENSES: each is z-scored over a rolling window (normLen) and "counts" toward consensus
//     when it sits beyond +/- extSigma. The consensus threshold auto-scales by timeframe
//     (4 lenses on 1m, 3 on 2/3/5m, 2 on 15m+), clamped to the active lens count. Lenses with
//     missing data (no volume -> VWAP / order flow; no reference -> basis) are skipped and the
//     threshold scales to what is active.
//   - COMPOSITE GATES: the composite is a MEAN of nine z-scores, so its standard deviation is
//     well below 1. Its divergence extreme-gate, reversal band and line colour therefore
//     self-scale to the composite's OWN rolling stdev (compWin), so the Phase-2 reads fire on
//     every timeframe instead of only the lowest. The per-lens consensus bands are unchanged.
//   - DIVERGENCE: regular + hidden, from CONFIRMED price pivots, gated by magnitude, pivot
//     distance and (optionally) a composite extreme at the pivot; detection anchors to the
//     composite's own swing while the line draws from the raw pivot value.
//   - REVERSAL: a composite pivot that prints inside the extreme band.
//   - CALIBRATION: each consensus / divergence / reversal event is a directional hypothesis,
//     queued and resolved calHor bars later vs calMove x ATR, then compared to the
//     unconditional same-horizon base rate. The dashboard shows, per class: n, Hit %, and
//     Edge = Hit - Base. Consensus direction follows the Exhaustion(fade)/Continuation(follow)
//     toggle; divergence follows its own direction; reversal fades the extreme.
//
// UNIVERSAL ACROSS MARKETS  (configurable data source)
//   Price / high / low, the VWAP source and the reference (spot) symbol are all inputs, so the
//   engine runs on any symbol or timeframe. Order flow and VWAP need real volume - use the
//   futures contract, not a cash index. Defaults target NSE NIFTY index futures intraday with
//   an NSE:NIFTY spot reference; change the sources for any other instrument.
//
// NON-REPAINT
//   Lenses read confirmed closes. Divergence and reversals come from ta.pivot* and therefore
//   confirm a few bars after the pivot (pivLen / revPiv); once printed they do not move. The
//   reference symbol is requested with lookahead_off. The calibration harness logs AND resolves
//   only on barstate.isconfirmed, so its statistics never repaint. The live consensus dot
//   reflects the current (still-forming) bar and settles on close.
//
// CONCEPT CREDIT
//   RSI, Parabolic SAR, ATR - J. Welles Wilder. Know Sure Thing - Martin J. Pring. Efficiency
//   Ratio - Perry J. Kaufman. VWAP and cumulative volume delta - standard public market-
//   microstructure concepts. The basis is explained by the cost-of-carry / theory-of-storage
//   framework (N. Kaldor 1939; H. Working 1948-49). Linear regression and price / oscillator
//   divergence are long-established public techniques. The forward base-rate Edge harness is
//   the author's own assembly. Original implementation; not affiliated with, nor endorsed by,
//   any third party.
//
// HONESTY / LIMITATIONS
//   Consensus is context, not a trigger. Several lenses share inputs (two momentum reads, two
//   deviation reads, two trend reads), so co-extremity is PARTLY mechanical redundancy - a high
//   count overstates independence. The Edge figures are IN-SAMPLE, close-to-close, with
//   OVERLAPPING forward windows (so the events are not independent) and NO costs - descriptive
//   context, not a verified backtest. An Edge near zero, negative, or unstable across
//   timeframes is the harness honestly telling you the signal has no reliable edge on that
//   instrument; do NOT tune parameters until it turns green - that is curve-fitting. Nothing
//   here predicts price.
//
// DISCLAIMER
//   Research and educational tool only. NOT financial advice and NO guarantee of profitability
//   or accuracy. Indicators describe past behaviour; they do not predict the future. Trading
//   carries risk of loss. Test out-of-sample and make your own decisions. The author accepts
//   no liability for any use of this script.
// ══════════════════════════════════════════════════════════════════════════════════════════════
indicator("Multi-Factor Divergence Confluence Oscillator", "Divergence Confluence", overlay = false,
     max_lines_count = 100, max_labels_count = 200, dynamic_requests = true)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                          INPUTS
// ═════════════════════════════════════════════════════════════════════════════════════════

// ── 1 · DATA SOURCE ───────────────────────────────────────────────────────────────────────
gData = "1 · Data source"
srcPrice = input.source(close, "Price source", group = gData)
srcHigh  = input.source(high,  "High source (bearish-pivot reference)", group = gData)
srcLow   = input.source(low,   "Low source (bullish-pivot reference)",  group = gData)
refSym   = input.symbol("NSE:NIFTY", "Reference (cash / spot) symbol  - Positioning lens", group = gData,
     tooltip = "Cash/spot series for the basis lens (chart - reference). Default NSE:NIFTY pairs with NIFTY futures.")
vwapSrc  = input.source(hlc3, "VWAP source  - Fair-value lens", group = gData,
     tooltip = "Series fed to the session VWAP. Needs real volume - use a futures contract.")

// ── 2 · OSCILLATOR LENSES (toggle each) ───────────────────────────────────────────────────
gOsc = "2 · Oscillator lenses"
onVWAP  = input.bool(true, "Fair value (VWAP deviation)", group = gOsc)
onRange = input.bool(true, "Volatility (range)", group = gOsc, inline = "rg")
rngLen  = input.int(14, "len", minval = 2, inline = "rg", group = gOsc)
onEff   = input.bool(true, "Efficiency (Kaufman)", group = gOsc, inline = "ef")
erLen   = input.int(20, "len", minval = 2, inline = "ef", group = gOsc)
onBasis = input.bool(true, "Positioning (basis)", group = gOsc)
onSAR   = input.bool(true, "Trend extension (SAR / ATR)", group = gOsc)
onRSI   = input.bool(true, "Momentum (RSI)", group = gOsc, inline = "rs")
rsiLen  = input.int(14, "len", minval = 2, inline = "rs", group = gOsc)
onEquil  = input.bool(true, "Equilibrium (linreg deviation)", group = gOsc, inline = "eq")
eqLen   = input.int(50, "len", minval = 5, inline = "eq", group = gOsc)
onKST   = input.bool(true, "Cycle (KST)", group = gOsc)
onFlow  = input.bool(true, "Order flow (volume delta)", group = gOsc)
atrLen  = input.int(14, "ATR length (SAR / equilibrium)", minval = 1, group = gOsc)
normLen = input.int(50, "Normalization window (z-score)", minval = 5, group = gOsc,
     tooltip = "Rolling window each lens is standardized over, so one pair of sigma bands is valid for all of them.")

// ── 3 · BANDS & CONSENSUS ─────────────────────────────────────────────────────────────────
gCon = "3 · Bands & consensus"
obSigma   = input.float(1.5, "Overbought / oversold (sigma)", minval = 0.5, step = 0.1, group = gCon)
extSigma  = input.float(2.5, "Extreme (sigma)", minval = 1.0, step = 0.1, group = gCon,
     tooltip = "A lens counts toward consensus when it sits beyond this many sigma.")
autoCons  = input.bool(true, "Auto consensus threshold (by timeframe)", group = gCon,
     tooltip = "On: require 4 lenses at the extreme on 1-min, 3 on 2/3/5-min, 2 on 15-min and above. Off: use the manual count. Always clamped to the active lens count.")
manualN   = input.int(5, "Manual min lenses at extreme", minval = 1, maxval = 9, group = gCon)
showRibbon    = input.bool(false, "Show all lenses (faint ribbon)", group = gCon,
     tooltip = "Off by default to keep the pane clean - only the composite line, extreme bands, signals and divergence show. Turn on to overlay every individual lens.")
showComposite = input.bool(true, "Show composite (mean) line", group = gCon)

// ── 4 · DIVERGENCE (on the composite) ─────────────────────────────────────────────────────
gDiv = "4 · Divergence (composite)"
showDiv     = input.bool(true, "Detect divergence on the composite", group = gDiv)
showHidden  = input.bool(true, "Detect hidden (continuation) divergence", group = gDiv)
reqExtreme  = input.bool(true, "Require overbought / oversold at the pivot", group = gDiv,
     tooltip = "Phase 2: a regular divergence only counts when the composite is at/beyond the OB-OS band at the pivot, where it carries the most meaning. This removes mid-range noise. Turn off for the v1.1 behaviour. NOTE: the composite is a mean, so its range is compressed - lower obSigma if this gates too hard.")
useOscPivot = input.bool(true, "Anchor to the composite's own swing", group = gDiv,
     tooltip = "Phase 2: detect on the composite's highest/lowest across the pivot window (the real swing) while still drawing the line from the raw value at the pivot. Catches divergences the plain offset value misses.")
pivLen      = input.int(5,  "Pivot length", minval = 1, inline = "p", group = gDiv)
maxGap      = input.int(60, "Max bars between pivots", minval = 2, inline = "p", group = gDiv)
magThr      = input.float(0.3, "Min composite gap (x its stdev)", minval = 0.0, step = 0.05, group = gDiv)
compAdapt   = input.bool(true, "Scale composite gates to its own range", group = gDiv,
     tooltip = "v1.3: the composite is a MEAN of nine z-scores, so its standard deviation is well below 1 and it rarely reaches the per-lens +/-1.5 / 2.5 bands. ON: the divergence extreme-gate, the reversal band and the composite line colour are all set from the composite's OWN rolling stdev, so they fire appropriately on every timeframe. OFF: use the fixed per-lens sigma levels (v1.2 behaviour).")
compWin     = input.int(200, "Composite range window", minval = 20, group = gDiv,
     tooltip = "Rolling window for the composite's own standard deviation.")
compObK     = input.float(1.0,  "Composite OB / OS (x its stdev)", minval = 0.3, step = 0.05, group = gDiv)
compExtK    = input.float(1.75, "Composite extreme (x its stdev)", minval = 0.5, step = 0.05, group = gDiv)
showExtRev  = input.bool(true, "Mark in-band reversals (dots)", group = gDiv,
     tooltip = "Phase 2: a dot when the composite turns back from inside the extreme band - a composite pivot beyond +/- extSigma.")
revPiv      = input.int(1, "Reversal pivot length", minval = 1, group = gDiv)

// ── 5 · CALIBRATION (forward test) ─────────────────────────────────────────────────────────
gCal = "5 · Calibration (forward test)"
calibOn   = input.bool(true, "Run forward calibration", group = gCal,
     tooltip = "Logs each consensus extreme and, calHor bars later, checks whether price moved at least calMove x ATR in the hypothesised direction. Reports Hit %, unconditional Base %, and Edge = Hit - Base. In-sample, close-to-close, overlapping windows, no costs - a study aid, not a backtest.")
calMode   = input.string("Exhaustion (fade)", "Consensus hypothesis", options = ["Exhaustion (fade)","Continuation (follow)"], group = gCal,
     tooltip = "Exhaustion: overbought consensus is scored as a DOWN move and oversold as an UP move (the script's stated exhaustion read). Continuation: the reverse. Flip this to test which actually holds on your symbol.")
calHor    = input.int(10, "Forward horizon (bars)", minval = 2, maxval = 200, group = gCal)
calMove   = input.float(0.6, "Win threshold (x ATR)", minval = 0.1, step = 0.1, group = gCal)
calAtrLen = input.int(14, "Calibration ATR length", minval = 1, group = gCal)
calGap    = input.int(10, "Min bars between logged events", minval = 1, group = gCal,
     tooltip = "Cooldown so a consensus that persists for many bars is logged ONCE, not every bar - otherwise overlapping copies of one event dominate the statistics.")

// ── 6 · MARKS ──────────────────────────────────────────────────────────────────────────────
gMrk = "6 · Marks"
showDots  = input.bool(true, "Consensus dots on the bands", group = gMrk)
showMarks = input.bool(true, "Mark consensus extremes on price (Ext N)", group = gMrk,
     tooltip = "Prints an 'Ext N' tag on the price pane when a consensus extreme forms; N = how many lenses are stretched. All marks come from this indicator only.")

// ── 7 · DASHBOARD & THEME ─────────────────────────────────────────────────────────────────
gUI = "7 · Dashboard & theme"
showTable = input.bool(true, "Show status dashboard", group = gUI)
tblPos    = input.string("Top Right", "Dashboard position", options = ["Top Right","Top Left","Bottom Right","Bottom Left"], group = gUI)
dashTheme = input.string("Auto (match chart)", "Dashboard theme", options = ["Auto (match chart)","Dark","Light"], group = gUI,
     tooltip = "Auto reads chart-background brightness and keeps the panel legible on any theme.")
colBull   = input.color(#2ebd85, "Bull color", inline = "col", group = gUI)
colBear   = input.color(#f6465d, "Bear color", inline = "col", group = gUI)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                              HELPERS  (arguments + built-ins only)
// ═════════════════════════════════════════════════════════════════════════════════════════
f_pos(string s) =>
    s == "Top Left" ? position.top_left : s == "Bottom Right" ? position.bottom_right : s == "Bottom Left" ? position.bottom_left : position.top_right

f_zscore(float x, int len) =>
    float m  = ta.sma(x, len)
    float sd = ta.stdev(x, len)
    sd == 0 ? 0.0 : (x - m) / sd

f_drawDiv(array<line> ls, array<label> lbs, int b0, float o0, int b1, float o1, color col, bool hidden, bool bear) =>
    array.push(ls, line.new(b0, o0, b1, o1, color = color.new(col, hidden ? 45 : 0), width = 2, style = hidden ? line.style_dashed : line.style_solid))
    array.push(lbs, label.new(b1, o1, (hidden ? "H " : "") + (bear ? "Bear" : "Bull"), style = bear ? label.style_label_down : label.style_label_up, color = color.new(col, 20), textcolor = color.white, size = size.tiny))
    if array.size(ls) > 40
        line.delete(array.shift(ls))
    if array.size(lbs) > 40
        label.delete(array.shift(lbs))

// ═════════════════════════════════════════════════════════════════════════════════════════
//                  NINE LENSES  - each standardized to sigma, up = bullish
// ═════════════════════════════════════════════════════════════════════════════════════════
float refClose = request.security(refSym, timeframe.period, close, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
bool  basisLive = not na(refClose) and refClose != 0
bool  volLive   = ta.cum(nz(volume)) > 0
float atrV      = ta.atr(atrLen)

// 1 Fair value (VWAP deviation)
float vw    = ta.vwap(vwapSrc)
float zVWAP = f_zscore(srcPrice - vw, normLen)
// 2 Volatility (directional range expansion)
float zRangeMag = f_zscore(high - low, normLen)
float rngDir    = math.sign(srcPrice - srcPrice[rngLen])
float zRange    = zRangeMag * (rngDir == 0 ? 1.0 : rngDir)
// 3 Efficiency (signed Kaufman ER)
float erChg = srcPrice - srcPrice[erLen]
float erVol = math.sum(math.abs(srcPrice - srcPrice[1]), erLen)
float erSer = erVol == 0 ? 0.0 : erChg / erVol
float zEff  = f_zscore(erSer, normLen)
// 4 Positioning (basis)
float zBasis = f_zscore(srcPrice - refClose, normLen)
// 5 Trend extension (SAR distance in ATR units)
float sarV   = ta.sar(0.02, 0.02, 0.2)
int   sarDir = srcPrice > sarV ? 1 : srcPrice < sarV ? -1 : 0
float sarExt = sarDir == 1 ? (srcHigh - sarV) : sarDir == -1 ? (sarV - srcLow) : 0.0
float sarMag = (not na(atrV) and atrV > 0) ? math.max(0.0, math.min(sarExt / atrV, 10.0)) : 0.0
float zSAR   = f_zscore(sarMag, normLen) * sarDir
// 6 Momentum (RSI)
float rsiV = ta.rsi(srcPrice, rsiLen)
float zRSI = f_zscore(rsiV, normLen)
// 7 Equilibrium (linreg deviation in ATR units)
float fairV   = ta.linreg(srcPrice, eqLen, 0)
float equilDev = (not na(atrV) and atrV > 0) ? (srcPrice - fairV) / atrV : 0.0
float zEquil   = f_zscore(equilDev, normLen)
// 8 Cycle (Know Sure Thing - standard Pring lengths)
float roc10 = ta.roc(srcPrice, 10)
float roc15 = ta.roc(srcPrice, 15)
float roc20 = ta.roc(srcPrice, 20)
float roc30 = ta.roc(srcPrice, 30)
float kstV  = ta.sma(roc10, 10) * 1.0 + ta.sma(roc15, 10) * 2.0 + ta.sma(roc20, 10) * 3.0 + ta.sma(roc30, 15) * 4.0
float zKST  = f_zscore(kstV, normLen)
// 9 Order flow (normalized cumulative volume delta, OHLC proxy)
float rng   = high - low
float bf    = rng == 0 ? 0.5 : math.max(0.0, math.min(1.0, (close - low) / rng))
float sv    = volume * (2 * bf - 1)
float cvd   = ta.cum(sv)
float resid = cvd - ta.ema(cvd, normLen)
float zFlow = f_zscore(resid, normLen)

// active flags (toggle AND data available)
bool aVWAP  = onVWAP  and volLive and not na(vw)
bool aRange = onRange
bool aEff   = onEff
bool aBasis = onBasis and basisLive
bool aSAR   = onSAR
bool aRSI   = onRSI
bool aEquil  = onEquil
bool aKST   = onKST
bool aFlow  = onFlow  and volLive

// ═════════════════════════════════════════════════════════════════════════════════════════
//                          COMPOSITE  +  EXTREME CONSENSUS COUNT
// ═════════════════════════════════════════════════════════════════════════════════════════
array<float> zA = array.from(zVWAP, zRange, zEff, zBasis, zSAR, zRSI, zEquil, zKST, zFlow)
array<bool>  aA = array.from(aVWAP, aRange, aEff, aBasis, aSAR, aRSI, aEquil, aKST, aFlow)

float zSum = 0.0
int actN = 0
int extHiN = 0
int extLoN = 0
int obHiN  = 0
int obLoN  = 0
for i = 0 to 8
    if array.get(aA, i)
        float z = array.get(zA, i)
        if not na(z)
            actN += 1
            zSum += z
            extHiN += (z >= extSigma ? 1 : 0)
            extLoN += (z <= -extSigma ? 1 : 0)
            obHiN  += (z >= obSigma ? 1 : 0)
            obLoN  += (z <= -obSigma ? 1 : 0)
float meanZ = actN > 0 ? zSum / actN : 0.0

int tfNeed = timeframe.in_seconds() <= 60 ? 4 : timeframe.in_seconds() <= 300 ? 3 : 2
int needN  = autoCons ? math.min(tfNeed, math.max(1, actN)) : math.min(manualN, math.max(1, actN))
bool consUp = actN > 0 and extHiN >= needN
bool consDn = actN > 0 and extLoN >= needN

// sigma levels
float capHi = extSigma + 1.5
float capLo = -extSigma - 1.5

// composite-adaptive gate levels — the composite is a MEAN, so its sd is well below 1.
// These drive the divergence extreme-gate, the reversal band and the composite colour, so
// Phase 2 fires on every timeframe instead of only the lowest. Consensus counting is on the
// individual lenses (extSigma) and is untouched.
float compSd = ta.stdev(meanZ, compWin)
bool  compOK = compAdapt and not na(compSd) and compSd > 0
float cmpOb  = compOK ? compObK  * compSd : obSigma
float cmpExt = compOK ? compExtK * compSd : extSigma

// (calibration harness moved below the engines - it now scores all three signal classes)

// ═════════════════════════════════════════════════════════════════════════════════════════
//        PHASE 2 · DIVERGENCE ENGINE  (composite mean-z, extreme-gated + swing-anchored)
// ═════════════════════════════════════════════════════════════════════════════════════════
float gapMin = magThr * ta.stdev(meanZ, 100)
int   oscWin = 2 * pivLen + 1
float ph = ta.pivothigh(srcHigh, pivLen, pivLen)
float pl = ta.pivotlow(srcLow,  pivLen, pivLen)

var float pHp  = na     // prev high pivot: price
var float pHo  = na     //               : detection osc value (swing extreme)
var float pHoD = na     //               : drawing osc value (raw at pivot)
var int   pHb  = na
var float pLp  = na
var float pLo  = na
var float pLoD = na
var int   pLb  = na

bool regBear = false
bool regBull = false
bool hidBear = false
bool hidBull = false

var array<line>  dLines = array.new<line>()
var array<label> dLabs  = array.new<label>()

if not na(ph) and showDiv
    float cP   = srcHigh[pivLen]
    float cDet = useOscPivot ? ta.highest(meanZ, oscWin) : meanZ[pivLen]
    float cDr  = meanZ[pivLen]
    int   cB   = bar_index - pivLen
    if not na(pHp) and (cB - pHb) <= maxGap
        bool obOK = cDet >= cmpOb
        regBear := cP > pHp and cDet < pHo and (pHo - cDet) >= gapMin and (not reqExtreme or obOK)
        hidBear := showHidden and cP < pHp and cDet > pHo and (cDet - pHo) >= gapMin
        if regBear or hidBear
            f_drawDiv(dLines, dLabs, pHb, pHoD, cB, cDr, colBear, hidBear and not regBear, true)
    pHp  := cP
    pHo  := cDet
    pHoD := cDr
    pHb  := cB

if not na(pl) and showDiv
    float cP   = srcLow[pivLen]
    float cDet = useOscPivot ? ta.lowest(meanZ, oscWin) : meanZ[pivLen]
    float cDr  = meanZ[pivLen]
    int   cB   = bar_index - pivLen
    if not na(pLp) and (cB - pLb) <= maxGap
        bool osOK = cDet <= -cmpOb
        regBull := cP < pLp and cDet > pLo and (cDet - pLo) >= gapMin and (not reqExtreme or osOK)
        hidBull := showHidden and cP > pLp and cDet < pLo and (pLo - cDet) >= gapMin
        if regBull or hidBull
            f_drawDiv(dLines, dLabs, pLb, pLoD, cB, cDr, colBull, hidBull and not regBull, false)
    pLp  := cP
    pLo  := cDet
    pLoD := cDr
    pLb  := cB

// ═════════════════════════════════════════════════════════════════════════════════════════
//        PHASE 2 · REVERSAL ENGINE  (composite turn whose peak / trough is in the band)
// ═════════════════════════════════════════════════════════════════════════════════════════
float oscPH = ta.pivothigh(meanZ, revPiv, revPiv)
float oscPL = ta.pivotlow(meanZ, revPiv, revPiv)
bool  revTop = showExtRev and not na(oscPH) and oscPH >= cmpExt
bool  revBot = showExtRev and not na(oscPL) and oscPL <= -cmpExt

// ═════════════════════════════════════════════════════════════════════════════════════════
//   CALIBRATION HARNESS  -  forward-scores all THREE signal classes vs an unconditional base
// ─────────────────────────────────────────────────────────────────────────────────────────
// Classes: 1 CONSENSUS · 2 DIVERGENCE · 3 REVERSAL. Each event is a directional hypothesis,
// queued and resolved calHor bars later vs calMove x ATR, then compared with the unconditional
// same-horizon base rate (split up / down). Logged on CONFIRMED bars only -> never repaints.
// In-sample, overlapping windows, no costs: read Edge as context, not a verified backtest.
// ═════════════════════════════════════════════════════════════════════════════════════════
type CalEvt
    int   cls
    int   dir
    float entry
    float atr0
    int   bidx

int   NCLS    = 3
int   calMinN = 8                        // events a class needs before its Hit / Edge is shown
float atrC    = ta.atr(calAtrLen)

var array<CalEvt> calPend = array.new<CalEvt>()
var array<int> cUpN    = array.new<int>(NCLS + 1, 0)
var array<int> cUpW    = array.new<int>(NCLS + 1, 0)
var array<int> cDnN    = array.new<int>(NCLS + 1, 0)
var array<int> cDnW    = array.new<int>(NCLS + 1, 0)
var array<int> cLastUp = array.new<int>(NCLS + 1, -100000)
var array<int> cLastDn = array.new<int>(NCLS + 1, -100000)

// unconditional base rate (every confirmed bar, same horizon, split up / down)
var array<float> baseE = array.new<float>()
var array<float> baseA = array.new<float>()
var array<int>   baseB = array.new<int>()
var int baseN   = 0
var int baseUpW = 0
var int baseDnW = 0

f_logEvt(array<CalEvt> q, array<int> lu, array<int> ld, int cls, int dir, float price, float a0, int gap) =>
    bool done = false
    if dir > 0 and (bar_index - array.get(lu, cls)) >= gap
        array.set(lu, cls, bar_index)
        array.push(q, CalEvt.new(cls, dir, price, a0, bar_index))
        done := true
    else if dir < 0 and (bar_index - array.get(ld, cls)) >= gap
        array.set(ld, cls, bar_index)
        array.push(q, CalEvt.new(cls, dir, price, a0, bar_index))
        done := true
    done

// resolve matured events into their class / direction bucket
if calibOn and barstate.isconfirmed and calPend.size() > 0
    for i = calPend.size() - 1 to 0
        CalEvt e = calPend.get(i)
        if bar_index - e.bidx >= calHor
            float fwd = (srcPrice - e.entry) * e.dir
            bool  win = fwd >= calMove * e.atr0
            if e.dir > 0
                array.set(cUpN, e.cls, array.get(cUpN, e.cls) + 1)
                array.set(cUpW, e.cls, array.get(cUpW, e.cls) + (win ? 1 : 0))
            else
                array.set(cDnN, e.cls, array.get(cDnN, e.cls) + 1)
                array.set(cDnW, e.cls, array.get(cDnW, e.cls) + (win ? 1 : 0))
            calPend.remove(i)

// unconditional base-rate sampler
if calibOn and barstate.isconfirmed and not na(atrC) and atrC > 0
    baseE.push(srcPrice)
    baseA.push(atrC)
    baseB.push(bar_index)
    for i = baseB.size() - 1 to 0
        if bar_index - baseB.get(i) >= calHor
            float e0 = baseE.get(i)
            float a0 = baseA.get(i)
            if (srcPrice - e0) >= calMove * a0
                baseUpW += 1
            if (e0 - srcPrice) >= calMove * a0
                baseDnW += 1
            baseN += 1
            baseE.remove(i)
            baseA.remove(i)
            baseB.remove(i)

// log THIS bar's events (after all three engines are evaluated); cooldown per class + side
if calibOn and barstate.isconfirmed and not na(atrC) and atrC > 0
    int cDirU = calMode == "Exhaustion (fade)" ? -1 : 1
    int cDirD = calMode == "Exhaustion (fade)" ? 1 : -1
    if consUp
        f_logEvt(calPend, cLastUp, cLastDn, 1, cDirU, srcPrice, atrC, calGap)
    if consDn
        f_logEvt(calPend, cLastUp, cLastDn, 1, cDirD, srcPrice, atrC, calGap)
    if regBull
        f_logEvt(calPend, cLastUp, cLastDn, 2,  1, srcPrice, atrC, calGap)
    if regBear
        f_logEvt(calPend, cLastUp, cLastDn, 2, -1, srcPrice, atrC, calGap)
    if revBot
        f_logEvt(calPend, cLastUp, cLastDn, 3,  1, srcPrice, atrC, calGap)
    if revTop
        f_logEvt(calPend, cLastUp, cLastDn, 3, -1, srcPrice, atrC, calGap)

// per-class metrics (event-weighted base, since a class can fire both directions)
float upBaseP = baseN > 0 ? baseUpW * 100.0 / baseN : na
float dnBaseP = baseN > 0 ? baseDnW * 100.0 / baseN : na
f_clsN(int c)    => array.get(cUpN, c) + array.get(cDnN, c)
f_clsW(int c)    => array.get(cUpW, c) + array.get(cDnW, c)
f_clsHit(int c)  => f_clsN(c) > 0 ? f_clsW(c) * 100.0 / f_clsN(c) : na
f_clsBase(int c) =>
    int n = f_clsN(c)
    (n > 0 and not na(upBaseP) and not na(dnBaseP)) ? (array.get(cUpN, c) * upBaseP + array.get(cDnN, c) * dnBaseP) / n : na
f_clsEdge(int c) => (not na(f_clsHit(c)) and not na(f_clsBase(c))) ? f_clsHit(c) - f_clsBase(c) : na

// ── latest-event trackers (dashboard) ──
var int    consBar = na
var string consTxt = "-"
var int    consDir = 0
if consUp
    consBar := bar_index
    consTxt := "OB " + str.tostring(extHiN)
    consDir := 1
if consDn
    consBar := bar_index
    consTxt := "OS " + str.tostring(extLoN)
    consDir := -1

var int    revBar = na
var string revTxt = "-"
if revTop
    revBar := bar_index - revPiv
    revTxt := "Top"
if revBot
    revBar := bar_index - revPiv
    revTxt := "Bottom"

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                          PLOTS
// ═════════════════════════════════════════════════════════════════════════════════════════
// faint ribbon - every active lens on the shared sigma scale
plot(showRibbon and aVWAP  ? zVWAP  : na, "Fair value",  color = color.new(zVWAP  >= 0 ? colBull : colBear, 78), linewidth = 1)
plot(showRibbon and aRange ? zRange : na, "Volatility",  color = color.new(zRange >= 0 ? colBull : colBear, 78), linewidth = 1)
plot(showRibbon and aEff   ? zEff   : na, "Efficiency",  color = color.new(zEff   >= 0 ? colBull : colBear, 78), linewidth = 1)
plot(showRibbon and aBasis ? zBasis : na, "Positioning", color = color.new(zBasis >= 0 ? colBull : colBear, 78), linewidth = 1)
plot(showRibbon and aSAR   ? zSAR   : na, "Trend",       color = color.new(zSAR   >= 0 ? colBull : colBear, 78), linewidth = 1)
plot(showRibbon and aRSI   ? zRSI   : na, "Momentum",    color = color.new(zRSI   >= 0 ? colBull : colBear, 78), linewidth = 1)
plot(showRibbon and aEquil  ? zEquil  : na, "Equilibrium", color = color.new(zEquil  >= 0 ? colBull : colBear, 78), linewidth = 1)
plot(showRibbon and aKST   ? zKST   : na, "Cycle",       color = color.new(zKST   >= 0 ? colBull : colBear, 78), linewidth = 1)
plot(showRibbon and aFlow  ? zFlow  : na, "Order flow",  color = color.new(zFlow  >= 0 ? colBull : colBear, 78), linewidth = 1)

// composite (mean) - glow line, colored by its (adaptive) gate
color cmpCol = meanZ >= cmpOb ? colBear : meanZ <= -cmpOb ? colBull : color.new(color.gray, 0)
plot(showComposite ? meanZ : na, "Composite glow", color = color.new(cmpCol, 70), linewidth = 8)
plot(showComposite ? meanZ : na, "Composite",      color = cmpCol, linewidth = 2)

// shared bands
hline(0, "Zero", color = color.new(color.gray, 45))

pExtHi = plot(extSigma, "Extreme +", color = color.new(colBear, 25), linewidth = 1)
pCapHi = plot(capHi,    "cap+",      color = color.new(colBear, 100), display = display.none)
fill(pExtHi, pCapHi, capHi, extSigma, color.new(colBear, 12), color.new(colBear, 88), title = "Upper extreme")
pExtLo = plot(-extSigma, "Extreme -", color = color.new(colBull, 25), linewidth = 1)
pCapLo = plot(capLo,     "cap-",      color = color.new(colBull, 100), display = display.none)
fill(pExtLo, pCapLo, -extSigma, capLo, color.new(colBull, 88), color.new(colBull, 12), title = "Lower extreme")

// composite gate guide lines — the levels the divergence gate / reversals actually use
// (adaptive to the composite's own range when compAdapt is on; the extSigma fills above
// remain as a fixed per-lens frame)
plot(compOK ? cmpExt  : na, "Comp ext +", color = color.new(colBear, 75))
plot(compOK ? -cmpExt : na, "Comp ext -", color = color.new(colBull, 75))

// consensus dots on the band
plot(showDots and consUp ? extSigma  : na, "Consensus OB", style = plot.style_circles, color = colBear, linewidth = 4)
plot(showDots and consDn ? -extSigma : na, "Consensus OS", style = plot.style_circles, color = colBull, linewidth = 4)

// in-band composite reversal dots (Phase 2)
plot(revTop ? oscPH : na, "Top reversal",    style = plot.style_circles, color = colBear, linewidth = 4, offset = -revPiv)
plot(revBot ? oscPL : na, "Bottom reversal", style = plot.style_circles, color = colBull, linewidth = 4, offset = -revPiv)

// price-pane consensus marks
if showMarks and consUp
    label.new(bar_index, high, "Ext " + str.tostring(extHiN), yloc = yloc.abovebar, style = label.style_label_down, color = colBear, textcolor = color.white, size = size.tiny, force_overlay = true)
if showMarks and consDn
    label.new(bar_index, low, "Ext " + str.tostring(extLoN), yloc = yloc.belowbar, style = label.style_label_up, color = colBull, textcolor = color.white, size = size.tiny, force_overlay = true)

// price-pane composite divergence marks
plotshape(showDiv and regBull, "Reg Bull", shape.triangleup,   location.belowbar, colBull, size = size.tiny, force_overlay = true)
plotshape(showDiv and regBear, "Reg Bear", shape.triangledown, location.abovebar, colBear, size = size.tiny, force_overlay = true)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                       STATUS DASHBOARD  (lower pane, background-adaptive)
// ═════════════════════════════════════════════════════════════════════════════════════════
var table st = table.new(f_pos(tblPos), 2, 10, frame_width = 1, border_width = 1)
if showTable and barstate.islast
    color bgc    = chart.bg_color
    float luma   = na(bgc) ? 0.0 : color.r(bgc) * 0.299 + color.g(bgc) * 0.587 + color.b(bgc) * 0.114
    bool  darkUI = dashTheme == "Dark" ? true : dashTheme == "Light" ? false : (na(bgc) or luma < 140)
    color panelBg = darkUI ? color.rgb(17, 22, 28)    : color.rgb(244, 246, 248)
    color rowAlt  = darkUI ? color.rgb(25, 31, 39)    : color.rgb(232, 236, 240)
    color txtMain = darkUI ? color.white              : color.rgb(16, 20, 24)
    color txtSub  = darkUI ? color.rgb(154, 166, 178) : color.rgb(74, 82, 91)
    color frameC  = darkUI ? color.rgb(58, 70, 84)    : color.rgb(196, 204, 212)
    color bullC   = darkUI ? colBull : color.rgb(22, 151, 106)
    color bearC   = darkUI ? colBear : color.rgb(210, 45, 68)
    color flatC   = darkUI ? color.gray : color.rgb(122, 130, 139)
    color hdr     = color.new(colBull, 0)
    table.set_bgcolor(st, panelBg)
    table.set_frame_color(st, frameC)
    table.set_border_color(st, frameC)

    string state = consUp ? "OVERBOUGHT" : consDn ? "OVERSOLD" : "Neutral"
    color  czcol = meanZ >= cmpOb ? bearC : meanZ <= -cmpOb ? bullC : flatC
    string czone = meanZ >= cmpOb ? "OB" : meanZ <= -cmpOb ? "OS" : "neutral"
    string cgate = compOK ? "  ext " + str.tostring(cmpExt, "0.0") : ""
    color  scol  = consUp ? bearC : consDn ? bullC : flatC
    string cage  = na(consBar) ? "" : "  " + str.tostring(bar_index - consBar) + "b"
    color  lcol  = consDir == 1 ? bearC : consDir == -1 ? bullC : flatC
    string rage  = na(revBar) ? "" : "  " + str.tostring(bar_index - revBar) + "b"
    color  rcol  = revTxt == "Top" ? bearC : revTxt == "Bottom" ? bullC : flatC

    table.cell(st, 0, 0, "Divergence Confluence", text_color = color.white, bgcolor = hdr, text_size = size.tiny)
    table.cell(st, 1, 0, state, text_color = color.white, bgcolor = hdr, text_size = size.tiny)
    table.cell(st, 0, 1, "Composite", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(st, 1, 1, str.tostring(meanZ, "0.0") + " sigma  " + czone + cgate, text_color = czcol, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(st, 0, 2, "At extreme", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
    table.cell(st, 1, 2, "OB " + str.tostring(extHiN) + " / OS " + str.tostring(extLoN), text_color = scol, bgcolor = panelBg, text_size = size.tiny)
    table.cell(st, 0, 3, "Need / active", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(st, 1, 3, str.tostring(needN) + " of " + str.tostring(actN), text_color = txtMain, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(st, 0, 4, "Last consensus", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
    table.cell(st, 1, 4, consTxt + cage, text_color = lcol, bgcolor = panelBg, text_size = size.tiny)
    table.cell(st, 0, 5, "Last reversal", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(st, 1, 5, revTxt + rage, text_color = rcol, bgcolor = rowAlt, text_size = size.tiny)

    // ── calibration: each signal class forward-scored vs the unconditional base ──
    if calibOn
        string baseTxt = (na(upBaseP) or na(dnBaseP)) ? "warming" : "up " + str.tostring(upBaseP, "0") + "  dn " + str.tostring(dnBaseP, "0")
        table.cell(st, 0, 6, "Base " + str.tostring(calHor) + "b %", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
        table.cell(st, 1, 6, baseTxt, text_color = txtMain, bgcolor = panelBg, text_size = size.tiny)
        for cls = 1 to NCLS
            int    cn   = f_clsN(cls)
            float  chit = f_clsHit(cls)
            float  cedg = f_clsEdge(cls)
            string cnm  = cls == 1 ? "Consensus" : cls == 2 ? "Divergence" : "Reversal"
            color  cbg  = cls % 2 == 1 ? rowAlt : panelBg
            color  cec  = (na(cedg) or cn < calMinN) ? flatC : cedg > 0 ? bullC : bearC
            string ctx  = cn < calMinN ? "warm " + str.tostring(cn) : "H" + str.tostring(chit, "0") + "  E" + (cedg >= 0 ? "+" : "") + str.tostring(cedg, "0") + "  (" + str.tostring(cn) + ")"
            table.cell(st, 0, 6 + cls, cnm, text_color = txtSub, bgcolor = cbg, text_size = size.tiny)
            table.cell(st, 1, 6 + cls, ctx, text_color = cec, bgcolor = cbg, text_size = size.tiny)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                          ALERTS
// ═════════════════════════════════════════════════════════════════════════════════════════
alertcondition(consUp, "Consensus overbought", "Divergence Confluence: factor consensus overbought")
alertcondition(consDn, "Consensus oversold",   "Divergence Confluence: factor consensus oversold")
alertcondition(regBull, "Composite bullish divergence", "Divergence Confluence: composite bullish divergence")
alertcondition(regBear, "Composite bearish divergence", "Divergence Confluence: composite bearish divergence")
alertcondition(revTop,  "Composite upper reversal", "Divergence Confluence: composite reversal at the upper extreme")
alertcondition(revBot,  "Composite lower reversal", "Divergence Confluence: composite reversal at the lower extreme")
````
