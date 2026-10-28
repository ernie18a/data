# Multi-Factor Divergence Matrix

- url: https://www.tradingview.com/script/pOMiVQ8K-Multi-Factor-Divergence-Matrix/
- type: indicator
- pine_id: PUB;e55627836994420f8f0af0cc6773dcdb
- version: 3.0

## Description

Multi-Factor Divergence Matrix 

OVERVIEW

Most divergence tools read one oscillator against price. The Multi-Factor Divergence Matrix reads fifteen independent lenses at once, standardizes them onto a single shared standard-deviation (sigma) scale, and then organizes them into a structure: lenses roll up into 14 aspects (distinct questions), aspects roll up into 6 families (factor classes), and families roll up into one composite. Divergence is detected five different ways on that construction, and a built-in calibration harness scores whether each method has actually carried any edge on your instrument.

The core idea: a price move is more trustworthy when many independent reads confirm it, and a divergence is more meaningful when it shows up across different kinds of information — not just three flavours of momentum that all say the same thing.

WHY THE COMPONENTS BELONG IN ONE SCRIPT (mashup rationale)

This is a deliberate multi-factor engine, not indicators stacked side by side. Every part answers the same question — is this price move confirmed, and by how broad a set of independent reads? — and each fixes a blind spot of the others:


A single oscillator can only diverge one way. Fifteen lenses across six families let price be unconfirmed by momentum, by trend efficiency, by location, by volatility, by order flow, or by cross-asset carry — independently.
Raw factor-stacking double-counts. Standardizing every lens to one sigma scale makes them directly comparable, and grouping correlated lenses into aspects (then families) means consensus is counted where it carries independent information, not where it merely repeats.
One detection method misses what another catches. Pivot divergence is precise but lags; slope fires earlier; correlation is continuous; sequential catches structured exhaustion; the intra-family split is often the very first crack. Run together, they cover the ways divergence actually appears.
Assertions are cheap. The calibration harness ties the whole construction back to realized forward outcomes, per method, so the tool reports whether its own signals carry edge rather than claiming they do.


Remove any one layer and the central question is answered less completely — which is what makes them one tool.

HOW IT WORKS

The 15 lenses → 14 aspects → 6 families


Momentum — oscillatory (RSI + Know Sure Thing), velocity (low-lag two-pole strength), stationary (fractional-difference of log price)
Trend / Efficiency — path quality (Kaufman efficiency ratio), extension (SAR distance in ATR units), rollover (dual-horizon efficiency gap)
Location / Mean — volume-anchored (VWAP deviation), geometric (linear-regression deviation)
Volatility — realized expansion (directional range), implied-vs-realized (variance-risk-premium spread)
Flow / Volume — net pressure (cumulative signed-volume delta, lower-timeframe estimated), volume-weighted (Money Flow Index)
Cross-Asset — carry (futures-vs-spot basis), fear (volatility-index vs price)


Each lens is z-scored over a rolling window (up = bullish). Correlated lenses that answer the same question (e.g. RSI and KST) are averaged into one aspect — the anti-redundancy step. A family agrees only when a majority of its filled aspects align; when its aspects disagree it is flagged SPLIT.

Two consensus axes, both at family resolution, auto-scaled by timeframe


Extreme-count — how many families are stretched to their extreme.
Divergence-count — how many families are diverging from price right now.


Five detection methods


Pivot — regular, hidden, exaggerated (equal-extreme) and triple divergence on the composite.
Slope — price-vs-composite regression-slope sign disagreement (fires earlier than pivots).
Correlation — rolling price-composite correlation flipping negative (continuous, always-on).
Sequential — a structured RSI exhaustion pattern (three deeper pushes, then a turn).
Leading — the intra-family SPLIT, often the first warning before a family flips.


Calibration. Each event is a directional hypothesis, queued and resolved a fixed horizon later versus an ATR threshold, then compared with the unconditional same-horizon base rate. The dashboard reports, per method: number of events, Hit %, and Edge = Hit − Base. Events are logged and resolved on confirmed bars only.

HOW TO USE

The dashboard has two modes. Compact (default) shows the decision essentials: the composite zone, the two consensus counts (Stretched X/6 · Diverging Y/6), a one-line family summary (bull / bear / split), and the single best-calibrated method with its Edge. Pro expands this to every family row (vote arrow, aspect agreement, SPLIT flag) and every per-method calibration class. In both, a high divergence-count backed by clean family agreement is strong context; the Edge figure tells you whether that read has actually preceded a move on this symbol and timeframe. Treat consensus as context, never a standalone trigger.

UNIVERSAL ACROSS MARKETS

Price, high, low, the VWAP source, the spot reference symbol and the volatility symbol are all inputs, so the engine runs on any instrument and timeframe. Volume-based lenses (VWAP, flow, MFI) need real traded volume — use the futures contract, not a cash index. Defaults target NSE NIFTY index futures intraday with an NSE:NIFTY spot reference and NSE:INDIAVIX; lenses without data quietly drop out and the consensus scales to whatever stays active.

ORIGINALITY

The individual techniques are public and credited below. The original work is the integration: standardizing fifteen heterogeneous reads onto one sigma axis, the aspect → family → composite roll-up that counts agreement only where it is independent, the dual extreme-and-divergence consensus, the surfacing of intra-family disagreement as a leading signal, and the forward base-rate calibration over every detection method. No third-party Pine code is reused.

CONCEPT CREDIT

RSI, Parabolic SAR, ATR, DMI — J. Welles Wilder. Know Sure Thing — Martin J. Pring. Efficiency Ratio — Perry J. Kaufman. Money Flow Index — Quong & Soudack. VWAP and cumulative volume delta — standard public market-microstructure concepts. Fractional differentiation — the long-memory / stationarity literature (Hosking 1981; adapted for finance by M. López de Prado). Two-pole low-pass smoothing — John F. Ehlers. The basis is explained by the cost-of-carry framework (N. Kaldor 1939; H. Working 1948–49). Variance risk premium — the implied-minus-realized literature. Linear regression and price/oscillator divergence are long-established public techniques. Not affiliated with, nor endorsed by, any third party.

HONESTY / LIMITATIONS

Consensus is context, not a trigger. Independence is managed, not perfect — lenses inside a family still share inputs, which is exactly why consensus counts families and aspects rather than raw lenses, and why a high count is never proof. The Edge figures are in-sample, close-to-close, with overlapping forward windows and no costs — descriptive context, not a verified backtest. An Edge near zero, negative, or unstable across timeframes is the harness honestly telling you the method has no reliable edge on that instrument; do not tune parameters until it turns green — that is curve-fitting. Divergence and reversals confirm a few bars after their pivot (inherent to honest pivot detection). Nothing here predicts price.

DISCLAIMER

Research and educational tool only. NOT financial advice and NO guarantee of profitability or accuracy. Indicators describe past behaviour; they do not predict the future. Trading carries risk of loss. Test out-of-sample and make your own decisions. The author accepts no liability for any use of this script.

## Source Code

````pine
//@version=6
// ══════════════════════════════════════════════════════════════════════════════════════════════
// © Market_Logic_India                                                       MPL-2.0
// MULTI-FACTOR DIVERGENCE MATRIX                                                          v2.1
// ────────────────────────────────────────────────────────────────────────────────────────────
// WHAT CHANGED IN v2.1
//   - FIX (important): pivot-divergence detection is now gated to CONFIRMED bars. ta.pivothigh uses
//     the current bar as its right-hand confirmation bar, so on a live bar it flickers; the drawing
//     helper was pushing a fresh line+label on every tick. Because the line/label arrays cap at 40
//     and shift the oldest out - and because Pine does NOT roll back array contents between intrabar
//     ticks - live-bar churn could silently EVICT genuine historical divergence lines from the chart.
//     Detection and drawing now happen only on confirmed bars, so historical divergences persist.
//   - FIX: the fractional-difference weight array is now guarded against a duplicate first-bar push.
//   - Every lookback input is now bounded (maxval), and max_bars_back is declared, so an extreme
//     setting cannot silently truncate a lens or fail at runtime.
//   - Added a LEGEND / KEY panel: fifteen lenses across six families is a lot to read cold.
//   No engine, lens, family or calibration logic was changed - readings are identical to v2.0.
//
// OVERVIEW
//   A single pane that reads divergence as a STRUCTURED, THREE-TIER consensus instead of a flat
//   factor count. FIFTEEN independent lenses are each standardized to one shared standard-
//   deviation (sigma) scale, grouped into FOURTEEN ASPECTS (distinct questions), then into SIX
//   FAMILIES (factor classes), then into the COMPOSITE. Agreement is counted where it carries
//   independent information - at the family level - and DISAGREEMENT is surfaced, not averaged
//   away, at every tier. FIVE detection methods (pivot / slope / correlation / sequential /
//   intra-family split) read the same construction so the engine sees divergence the way it
//   actually occurs - early, structurally, and across factor classes, not just as one RSI line.
//
// WHAT MAKES IT DIFFERENT  (why these components are ONE tool, not a stack)
//   A plain divergence indicator reads ONE oscillator against price. This separates each factor
//   into its ASPECTS: momentum, for instance, is read as oscillatory (RSI / KST), velocity (low-
//   lag) AND stationary (fractional-difference) - three different questions one RSI cannot answer.
//   Aspects roll up into families; a family "agrees" only when a majority of its filled aspects
//   align, and when they SPLIT, that split is itself an early signal (a LEADING divergence, often
//   the first crack before a family flips). Consensus then counts FAMILIES, not raw lenses, so six
//   independent families disagreeing with price means far more than many correlated lenses doing
//   so. Every part - the shared scale, the aspect roll-up, the dual counts, the five methods and
//   the calibration scorekeeper - serves the SAME question: is this price move confirmed, and by
//   how broad a set of independent reads? Remove any one and that question is answered less fully.
//
// HOW IT WORKS
//   - LENSES: each standardized to sigma over a rolling window (up = bullish).
//   - ASPECTS: lenses answering the same question are averaged into one aspect (correlated twins
//     share one slot - the anti-redundancy mechanism).
//   - FAMILIES: Momentum, Trend/Efficiency, Location, Volatility, Flow, Cross-Asset. Net read =
//     mean of active aspects; vote = aspect agreement; SPLIT when aspects disagree.
//   - COMPOSITE: mean of active lenses, drawn as the oscillator. Two consensus axes, both at
//     family resolution and auto-scaled by timeframe: EXTREME-count (families stretched) and
//     DIVERGENCE-count (families diverging from price now).
//   - DETECTION: composite pivot divergence (regular / hidden / exaggerated / triple), regression-
//     SLOPE sign disagreement, rolling price-composite CORRELATION flipping negative, RSI
//     SEQUENTIAL exhaustion, and the intra-family LEADING split.
//   - CALIBRATION: every event class is a directional hypothesis, queued and resolved calHor bars
//     later vs calMove x ATR, scored against an unconditional same-horizon base rate. Reports, per
//     class: n, Hit %, Edge = Hit - Base. Logged AND resolved on confirmed bars - never repaints.
//
// HOW TO USE
//   Read the dashboard top-down: composite zone, then the two consensus counts, then the six
//   family rows (vote, aspect agreement, SPLIT flag), then the calibration Edge per class. A high
//   divergence-count with a clean family agreement is the context; the per-class Edge tells you
//   whether that class has carried any edge on THIS instrument. Consensus is context, not a trigger.
//
// UNIVERSAL ACROSS MARKETS  (configurable data source)
//   Price / high / low, the VWAP source, the reference (spot) symbol and the volatility symbol are
//   all inputs. Volume-based lenses (VWAP, flow, MFI) need real volume - use the futures contract.
//   Defaults target NSE NIFTY index futures intraday with NSE:NIFTY spot and NSE:INDIAVIX.
//
// NON-REPAINT
//   Lenses read confirmed closes. Divergence / reversal come from ta.pivot* and confirm a few bars
//   after the pivot; once printed they do not move. External symbols are requested lookahead_off.
//   The harness logs and resolves only on barstate.isconfirmed, so its statistics never repaint.
//
// CONCEPT CREDIT
//   RSI, Parabolic SAR, ATR, DMI - J. Welles Wilder. Know Sure Thing - Martin J. Pring. Efficiency
//   Ratio - Perry J. Kaufman. Money Flow Index - Quong & Soudack. VWAP and cumulative volume delta
//   - standard public market-microstructure concepts. Fractional differentiation - the long-memory
//   / stationarity literature (Hosking 1981; popularized for finance by M. López de Prado). Two-pole
//   low-pass smoothing and dominant-cycle work - John F. Ehlers. The basis is explained by the
//   cost-of-carry framework (N. Kaldor 1939; H. Working 1948-49). Variance risk premium - the
//   implied-minus-realized literature. Linear regression and price / oscillator divergence are
//   long-established public techniques. The aspect / family / composite assembly and the forward
//   base-rate Edge harness are the author's own. Original implementation; not affiliated with, nor
//   endorsed by, any third party.
//
// HONESTY / LIMITATIONS
//   Consensus is context, not a trigger. Independence is MANAGED, not perfect - lenses inside a
//   family still share inputs, which is exactly why consensus counts families and aspects, not raw
//   lenses, and why a high count never means proof. Edge figures are IN-SAMPLE, close-to-close, with
//   OVERLAPPING forward windows and NO costs - descriptive context, not a verified backtest. An Edge
//   near zero, negative, or unstable across timeframes is the harness honestly telling you the class
//   has no reliable edge here; do NOT tune until it turns green - that is curve-fitting. Several
//   lenses are session- or volume-dependent (VWAP, flow, MFI need real volume; basis needs a clean
//   spot reference; VRP / fear need a volatility index) and quietly drop out where data is absent,
//   with the consensus scaling to whatever stays active. Nothing here predicts price.
//
// DISCLAIMER
//   Research and educational tool only. NOT financial advice and NO guarantee of profitability or
//   accuracy. Indicators describe past behaviour; they do not predict the future. Trading carries
//   risk of loss. Test out-of-sample and make your own decisions. The author accepts no liability
//   for any use of this script.
// ══════════════════════════════════════════════════════════════════════════════════════════════
indicator("Multi-Factor Divergence Matrix", "Divergence Matrix", overlay = false,
     max_lines_count = 200, max_labels_count = 300, max_bars_back = 2000, dynamic_requests = true)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                          INPUTS
// ═════════════════════════════════════════════════════════════════════════════════════════

// ── 01 · DATA SOURCE ───────────────────────────────────────────────────────────────────────
g01 = "01 · Data source"
srcPrice = input.source(close, "Price source", group = g01)
srcHigh  = input.source(high,  "High source (bearish-pivot reference)", group = g01)
srcLow   = input.source(low,   "Low source (bullish-pivot reference)",  group = g01)
vwapSrc  = input.source(hlc3,  "VWAP source  - Location lens", group = g01,
     tooltip = "Series fed to the session VWAP. Needs real volume - use a futures contract.")
refSym   = input.symbol("NSE:NIFTY",   "Reference (cash / spot) symbol  - Cross-asset basis", group = g01)
vixSym   = input.symbol("NSE:INDIAVIX","Volatility symbol  - VRP & fear lenses", group = g01)
lowerTF  = input.timeframe("1", "Lower timeframe (signed flow delta)", group = g01,
     tooltip = "Sub-bar timeframe used to estimate signed volume for the flow lens. Set BELOW the chart timeframe; proxy used when unavailable.")

// ── 02 · LENS TOGGLES (by aspect) ──────────────────────────────────────────────────────────
g02 = "02 · Lens toggles"
onRSI   = input.bool(true, "Momentum · oscillatory (RSI)", group = g02, inline = "m1")
onKST   = input.bool(true, "+ KST", group = g02, inline = "m1")
onLLSO  = input.bool(true, "Momentum · velocity (low-lag)", group = g02)
onFrac  = input.bool(true, "Momentum · stationary (frac-diff)", group = g02)
onER    = input.bool(true, "Trend · path quality (efficiency)", group = g02)
onSAR   = input.bool(true, "Trend · extension (SAR / ATR)", group = g02)
onERgap = input.bool(true, "Trend · rollover (efficiency gap)", group = g02)
onVWAP  = input.bool(true, "Location · volume-anchored (VWAP)", group = g02)
onLin   = input.bool(true, "Location · geometric (linreg)", group = g02)
onRange = input.bool(true, "Volatility · realized expansion (range)", group = g02)
onVRP   = input.bool(true, "Volatility · implied-vs-realized (VRP)", group = g02)
onCVD   = input.bool(true, "Flow · net pressure (CVD)", group = g02)
onMFI   = input.bool(true, "Flow · volume-weighted (MFI)", group = g02)
onBasis = input.bool(true, "Cross-asset · carry (basis)", group = g02)
onVIX   = input.bool(true, "Cross-asset · fear (VIX-vs-price)", group = g02)

// ── 03 · LENS PARAMETERS ───────────────────────────────────────────────────────────────────
g03 = "03 · Lens parameters"
normLen = input.int(50, "Normalization window (z-score)", minval = 5, maxval = 500, group = g03,
     tooltip = "Rolling window each lens is standardized over, so one pair of sigma bands is valid for all of them.")
rsiLen  = input.int(14, "RSI length", minval = 2, maxval = 200, group = g03, inline = "p1")
mfiLen  = input.int(14, "MFI length", minval = 2, maxval = 200, group = g03, inline = "p1")
llsoLen = input.int(20, "Low-lag period", minval = 3, maxval = 200, group = g03, inline = "p2")
erLen   = input.int(20, "Efficiency length", minval = 2, maxval = 200, group = g03, inline = "p2")
erGapFast = input.int(10, "Eff-gap fast", minval = 3, maxval = 200, group = g03, inline = "p3")
erGapSlow = input.int(30, "Eff-gap slow", minval = 5, maxval = 400, group = g03, inline = "p3")
eqLen   = input.int(50, "Linreg / equilibrium length", minval = 5, maxval = 500, group = g03, inline = "p4")
rngLen  = input.int(14, "Range direction length", minval = 2, maxval = 200, group = g03, inline = "p4")
atrLen  = input.int(14, "ATR length (SAR / equilibrium)", minval = 1, maxval = 200, group = g03)
fracD   = input.float(0.4, "Frac-diff order d", minval = 0.05, maxval = 0.95, step = 0.05, group = g03, inline = "p5")
fracW   = input.int(20, "Frac-diff width", minval = 4, maxval = 80, group = g03, inline = "p5")
vrpLen  = input.int(20, "Realized-vol window (VRP)", minval = 5, maxval = 300, group = g03)

// ── 04 · NORMALIZATION & BANDS ─────────────────────────────────────────────────────────────
g04 = "04 · Bands"
obSigma  = input.float(1.5, "Overbought / oversold (sigma)", minval = 0.5, step = 0.1, group = g04)
extSigma = input.float(2.5, "Extreme (sigma)", minval = 1.0, step = 0.1, group = g04,
     tooltip = "An aspect is at the extreme when it sits beyond this many sigma; a family is stretched when any of its aspects is.")
compWin  = input.int(200, "Composite range window", minval = 20, maxval = 1000, group = g04,
     tooltip = "Rolling window for the composite's OWN standard deviation. The composite is a mean, so its sd is well below 1; its gates self-scale to this.")
compObK  = input.float(1.0,  "Composite OB / OS (x its stdev)", minval = 0.3, step = 0.05, group = g04)
compExtK = input.float(1.75, "Composite extreme (x its stdev)", minval = 0.5, step = 0.05, group = g04)

// ── 05 · CONSENSUS ─────────────────────────────────────────────────────────────────────────
g05 = "05 · Consensus"
autoCons = input.bool(true, "Auto family threshold (by timeframe)", group = g05,
     tooltip = "On: require 4 families on 1-min, 3 on 2/3/5-min, 2 on 15-min+, clamped to active families. Off: manual.")
manualFam = input.int(3, "Manual min families", minval = 1, maxval = 6, group = g05)
leadSig  = input.float(0.5, "Aspect lean threshold (sigma)", minval = 0.1, step = 0.1, group = g05,
     tooltip = "An aspect counts as leaning up/down only beyond this many sigma; below it the aspect is treated as neutral. Drives the family vote and the SPLIT (leading) flag.")

// ── 06 · DETECTION METHODS ─────────────────────────────────────────────────────────────────
g06 = "06 · Detection"
showDiv     = input.bool(true, "Composite pivot divergence", group = g06)
showHidden  = input.bool(true, "+ hidden (continuation)", group = g06)
useExag     = input.bool(true, "+ exaggerated (equal-extreme)", group = g06)
reqExtreme  = input.bool(true, "Require OB/OS at the pivot (regular)", group = g06)
useOscPivot = input.bool(true, "Anchor to composite's own swing", group = g06)
pivLen   = input.int(5,  "Pivot length", minval = 1, maxval = 50, inline = "pv", group = g06)
maxGap   = input.int(60, "Max bars between pivots", maxval = 500, minval = 2, inline = "pv", group = g06)
magThr   = input.float(0.3, "Min composite gap (x its stdev)", minval = 0.0, step = 0.05, group = g06)
eqTol    = input.float(0.25, "Equal-extreme tolerance (x ATR)", minval = 0.0, step = 0.05, group = g06)
useSlope = input.bool(true, "Slope divergence (regression sign)", group = g06, inline = "sl")
slopeLen = input.int(20, "len", maxval = 500, minval = 3, inline = "sl", group = g06)
useCorr  = input.bool(true, "Correlation divergence (rolling)", group = g06, inline = "cr")
corrLen  = input.int(20, "len", maxval = 500, minval = 3, inline = "cr", group = g06)
corrThr  = input.float(0.0, "Correlation flip level", minval = -1.0, maxval = 1.0, step = 0.05, group = g06)
useSeq   = input.bool(true, "Sequential RSI exhaustion", group = g06, inline = "sq")
seqOs    = input.float(25, "OS", minval = 1, maxval = 49, inline = "sq", group = g06)
seqOb    = input.float(75, "OB", minval = 51, maxval = 99, inline = "sq", group = g06)
useLead  = input.bool(true, "Leading (intra-family split)", group = g06)
showExtRev = input.bool(true, "Mark in-band composite reversals", group = g06)
revPiv   = input.int(1, "Reversal pivot length", maxval = 500, minval = 1, group = g06)

// ── 10 · CALIBRATION (forward test) ─────────────────────────────────────────────────────────
g10 = "10 · Calibration (forward test)"
calibOn   = input.bool(true, "Run forward calibration", group = g10)
calMode   = input.string("Exhaustion (fade)", "Consensus hypothesis", options = ["Exhaustion (fade)","Continuation (follow)"], group = g10,
     tooltip = "Direction scored for the EXTREME consensus class. Divergence / slope / correlation / sequential / leading classes follow their own natural direction.")
calHor    = input.int(10, "Forward horizon (bars)", minval = 2, maxval = 200, group = g10)
calMove   = input.float(0.6, "Win threshold (x ATR)", minval = 0.1, step = 0.1, group = g10)
calAtrLen = input.int(14, "Calibration ATR length", maxval = 500, minval = 1, group = g10)
calGap    = input.int(10, "Min bars between logged events", maxval = 500, minval = 1, group = g10)

// ── 12 · DASHBOARD & THEME ─────────────────────────────────────────────────────────────────
g12 = "12 · Dashboard & theme"
showTable = input.bool(true, "Show dashboard", group = g12)
dashMode  = input.string("Compact", "Dashboard detail", options = ["Compact","Pro"], group = g12,
     tooltip = "Compact (default): the decision essentials - composite, the two consensus counts, a one-line family summary and the single best-calibrated method. Pro: every family row and every per-method calibration class.")
tblPos    = input.string("Top Right", "Dashboard position", options = ["Top Right","Top Left","Bottom Right","Bottom Left"], group = g12)
dashTheme = input.string("Auto (match chart)", "Dashboard theme", options = ["Auto (match chart)","Dark","Light"], group = g12)
colBull   = input.color(#2ebd85, "Bull color", inline = "col", group = g12)
colBear   = input.color(#f6465d, "Bear color", inline = "col", group = g12)
colMid    = input.color(#f7c948, "Midline glow", inline = "col", group = g12)

// ── 13 · MARKS ───────────────────────────────────────────────────────────────────────────
g13 = "13 · Marks"
showDots  = input.bool(true, "Consensus dots on the bands", group = g13)
showMarks = input.bool(true, "Mark consensus / divergence on price", group = g13)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                              HELPERS  (arguments + built-ins only)
// ═════════════════════════════════════════════════════════════════════════════════════════
f_pos(string s) =>
    s == "Top Left" ? position.top_left : s == "Bottom Right" ? position.bottom_right : s == "Bottom Left" ? position.bottom_left : position.top_right

f_zscore(float x, int len) =>
    float m  = ta.sma(x, len)
    float sd = ta.stdev(x, len)
    sd == 0 ? 0.0 : (x - m) / sd

// two-pole low-pass (Ehlers) smoother for the low-lag momentum lens
f_smooth(float s, simple int per) =>
    float a1 = math.exp(-1.414 * math.pi / per)
    float b1 = 2.0 * a1 * math.cos(1.414 * math.pi / per)
    float c2 = b1
    float c3 = -a1 * a1
    float c1 = (1.0 + c2 - c3) / 4.0
    var float u = na
    u := (na(u[1]) or na(u[2])) ? s : (1.0 - c1) * s + (2.0 * c1 - c2) * nz(s[1]) - (c1 + c3) * nz(s[2]) + c2 * u[1] + c3 * u[2]
    u

f_kst(float s, simple int r1, simple int r2, simple int r3, simple int r4, simple int m1, simple int m2, simple int m3, simple int m4) =>
    ta.sma(ta.roc(s, r1), m1) * 1.0 + ta.sma(ta.roc(s, r2), m2) * 2.0 + ta.sma(ta.roc(s, r3), m3) * 3.0 + ta.sma(ta.roc(s, r4), m4) * 4.0

// combine up to two lenses into one aspect: mean of the available, active ones
f_asp2(float a, bool aok, float b, bool bok) =>
    float s = 0.0
    int n = 0
    if aok and not na(a)
        s := s + a
        n := n + 1
    if bok and not na(b)
        s := s + b
        n := n + 1
    [n > 0 ? s / n : na, n > 0]

f_drawDiv(array<line> ls, array<label> lbs, int b0, float o0, int b1, float o1, color col, bool hidden, bool bear, string tag) =>
    array.push(ls, line.new(b0, o0, b1, o1, color = color.new(col, hidden ? 45 : 0), width = 2, style = hidden ? line.style_dashed : line.style_solid))
    array.push(lbs, label.new(b1, o1, tag, style = bear ? label.style_label_down : label.style_label_up, color = color.new(col, 20), textcolor = color.white, size = size.tiny))
    if array.size(ls) > 40
        line.delete(array.shift(ls))
    if array.size(lbs) > 40
        label.delete(array.shift(lbs))

// ═════════════════════════════════════════════════════════════════════════════════════════
//                       EXTERNAL DATA  (one ref + one vol request)
// ═════════════════════════════════════════════════════════════════════════════════════════
float refClose = request.security(refSym, timeframe.period, close, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
float vixClose = request.security(vixSym, timeframe.period, close, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
bool  basisLive = not na(refClose) and refClose != 0
bool  vixLive   = not na(vixClose) and vixClose != 0
bool  volLive   = ta.cum(nz(volume)) > 0
float atrV      = ta.atr(atrLen)

// signed lower-timeframe flow delta (proxy fallback)
f_proxyDelta() =>
    float r  = high - low
    float bf = r == 0 ? 0.5 : math.max(0.0, math.min(1.0, (close - low) / r))
    volume * (2 * bf - 1)
[ltfO, ltfC, ltfV] = request.security_lower_tf(syminfo.tickerid, lowerTF, [open, close, volume])
float svLTF = na
bool  ltfOK = false
if array.size(ltfV) > 0
    float sAcc = 0.0
    for i = 0 to array.size(ltfV) - 1
        sAcc := sAcc + (array.get(ltfC, i) > array.get(ltfO, i) ? array.get(ltfV, i) : array.get(ltfC, i) < array.get(ltfO, i) ? -array.get(ltfV, i) : 0.0)
    svLTF := sAcc
    ltfOK := true
float sv = (ltfOK) ? svLTF : f_proxyDelta()

// ═════════════════════════════════════════════════════════════════════════════════════════
//                       LENSES  - each standardized to sigma, up = bullish
// ═════════════════════════════════════════════════════════════════════════════════════════
// Momentum · oscillatory
float rsiV = ta.rsi(srcPrice, rsiLen)
float zRSI = f_zscore(rsiV, normLen)
float kstV = f_kst(srcPrice, 10, 15, 20, 30, 10, 10, 10, 15)
float zKST = f_zscore(kstV, normLen)
// Momentum · velocity (low-lag strength)
float upMove = math.max(srcPrice - srcPrice[1], 0.0)
float dnMove = math.max(srcPrice[1] - srcPrice, 0.0)
float su = f_smooth(upMove, llsoLen)
float sd = f_smooth(dnMove, llsoLen)
float den = su + sd
float llStr = math.abs(den) > 1e-10 ? (su - sd) / den : 0.0
llStr := math.max(-1.0, math.min(1.0, llStr))
float zLLSO = f_zscore(llStr, normLen)
// Momentum · stationary (fixed-width fractional differencing of log price)
var array<float> fdW = array.new<float>(0)
// size check as well as isfirst: array contents are NOT rolled back between intrabar ticks, so if the
// first bar were ever a live bar this would push duplicate weights on every tick.
if barstate.isfirst and array.size(fdW) == 0
    float wv = 1.0
    array.push(fdW, 1.0)
    for k = 1 to fracW - 1
        wv := -wv * (fracD - k + 1) / k
        array.push(fdW, wv)
float lp = math.log(srcPrice)
float fdRaw = na
if bar_index >= fracW
    float acc = 0.0
    for k = 0 to fracW - 1
        acc := acc + array.get(fdW, k) * lp[k]
    fdRaw := acc
float zFrac = f_zscore(fdRaw, normLen)

// Trend · path quality (signed Kaufman efficiency ratio)
float erChg = srcPrice - srcPrice[erLen]
float erVol = math.sum(math.abs(srcPrice - srcPrice[1]), erLen)
float erSer = erVol == 0 ? 0.0 : erChg / erVol
float zER   = f_zscore(erSer, normLen)
// Trend · extension (SAR distance in ATR units)
float sarV   = ta.sar(0.02, 0.02, 0.2)
int   sarDir = srcPrice > sarV ? 1 : srcPrice < sarV ? -1 : 0
float sarExt = sarDir == 1 ? (srcHigh - sarV) : sarDir == -1 ? (sarV - srcLow) : 0.0
float sarMag = (not na(atrV) and atrV > 0) ? math.max(0.0, math.min(sarExt / atrV, 10.0)) : 0.0
float zSAR   = f_zscore(sarMag, normLen) * sarDir
// Trend · rollover (dual-horizon efficiency gap)
float erFast = na
float erSlow = na
float pf = math.sum(math.abs(srcPrice - srcPrice[1]), erGapFast)
float ps = math.sum(math.abs(srcPrice - srcPrice[1]), erGapSlow)
erFast := pf == 0 ? 0.0 : math.abs(srcPrice - srcPrice[erGapFast]) / pf
erSlow := ps == 0 ? 0.0 : math.abs(srcPrice - srcPrice[erGapSlow]) / ps
float erGap = erFast - erSlow
float dirG  = math.sign(srcPrice - srcPrice[erGapFast])
float zERgap = f_zscore(erGap, normLen) * (dirG == 0 ? 1.0 : dirG)

// Location · volume-anchored (VWAP deviation)
float vw    = ta.vwap(vwapSrc)
float zVWAP = f_zscore(srcPrice - vw, normLen)
// Location · geometric (linreg deviation in ATR units)
float fairV    = ta.linreg(srcPrice, eqLen, 0)
float equilDev = (not na(atrV) and atrV > 0) ? (srcPrice - fairV) / atrV : 0.0
float zLin     = f_zscore(equilDev, normLen)

// Volatility · realized expansion (directional range)
float zRangeMag = f_zscore(high - low, normLen)
float rngDir    = math.sign(srcPrice - srcPrice[rngLen])
float zRange    = zRangeMag * (rngDir == 0 ? 1.0 : rngDir)
// Volatility · implied-vs-realized (variance risk premium, scale-free)
float logret = math.log(srcPrice / srcPrice[1])
float rvol   = ta.stdev(logret, vrpLen)
float ivZ    = f_zscore(vixClose, normLen)
float rvZ    = f_zscore(rvol, normLen)
float vrpSpread = ivZ - rvZ
float zVRP   = vixLive ? f_zscore(vrpSpread, normLen) : na

// Flow · net pressure (normalized cumulative signed-volume delta)
float cvd   = ta.cum(sv)
float resid = cvd - ta.ema(cvd, normLen)
float zCVD  = f_zscore(resid, normLen)
// Flow · volume-weighted momentum (MFI, delta-independent)
float mfiV  = ta.mfi(hlc3, mfiLen)
float zMFI  = f_zscore(mfiV, normLen)

// Cross-asset · carry (basis)
float zBasis = basisLive ? f_zscore(srcPrice - refClose, normLen) : na
// Cross-asset · fear (VIX-vs-price): low vol = bullish, so invert
float zVIX   = vixLive ? -f_zscore(vixClose, normLen) : na

// active flags (toggle AND data available)
bool aRSI   = onRSI
bool aKST   = onKST
bool aLLSO  = onLLSO
bool aFrac  = onFrac and not na(zFrac)
bool aER    = onER
bool aSAR   = onSAR
bool aERgap = onERgap
bool aVWAP  = onVWAP and volLive and not na(vw)
bool aLin   = onLin
bool aRange = onRange
bool aVRP   = onVRP and vixLive
bool aCVD   = onCVD and volLive
bool aMFI   = onMFI and volLive
bool aBasis = onBasis and basisLive
bool aVIX   = onVIX and vixLive

// ═════════════════════════════════════════════════════════════════════════════════════════
//                       ASPECTS  (14)  ->  FAMILIES  (6)
// ═════════════════════════════════════════════════════════════════════════════════════════
[a01, k01] = f_asp2(zRSI, aRSI, zKST, aKST)        // Momentum · oscillatory
[a02, k02] = f_asp2(zLLSO, aLLSO, na, false)       // Momentum · velocity
[a03, k03] = f_asp2(zFrac, aFrac, na, false)       // Momentum · stationary
[a04, k04] = f_asp2(zER, aER, na, false)           // Trend · path quality
[a05, k05] = f_asp2(zSAR, aSAR, na, false)         // Trend · extension
[a06, k06] = f_asp2(zERgap, aERgap, na, false)     // Trend · rollover
[a07, k07] = f_asp2(zVWAP, aVWAP, na, false)       // Location · volume-anchored
[a08, k08] = f_asp2(zLin, aLin, na, false)         // Location · geometric
[a09, k09] = f_asp2(zRange, aRange, na, false)     // Volatility · realized
[a10, k10] = f_asp2(zVRP, aVRP, na, false)         // Volatility · implied-vs-realized
[a13, k13] = f_asp2(zCVD, aCVD, na, false)         // Flow · net pressure
[a14, k14] = f_asp2(zMFI, aMFI, na, false)         // Flow · volume-weighted
[a15, k15] = f_asp2(zBasis, aBasis, na, false)     // Cross-asset · carry (basis)
[a16, k16] = f_asp2(zVIX, aVIX, na, false)         // Cross-asset · fear

array<float> aspZ  = array.from(a01,a02,a03,a04,a05,a06,a07,a08,a09,a10,a13,a14,a15,a16)
array<bool>  aspA  = array.from(k01,k02,k03,k04,k05,k06,k07,k08,k09,k10,k13,k14,k15,k16)
array<int>   aspF  = array.from(1,1,1, 2,2,2, 3,3, 4,4, 5,5, 6,6)

array<float> famSum = array.new<float>(6, 0.0)
array<int>   famAct = array.new<int>(6, 0)
array<int>   famUp  = array.new<int>(6, 0)
array<int>   famDn  = array.new<int>(6, 0)
array<bool>  famEU  = array.new<bool>(6, false)
array<bool>  famED  = array.new<bool>(6, false)
for i = 0 to 13
    if array.get(aspA, i)
        int f = array.get(aspF, i) - 1
        float v = array.get(aspZ, i)
        if not na(v)
            array.set(famAct, f, array.get(famAct, f) + 1)
            array.set(famSum, f, array.get(famSum, f) + v)
            if v >= leadSig
                array.set(famUp, f, array.get(famUp, f) + 1)
            if v <= -leadSig
                array.set(famDn, f, array.get(famDn, f) + 1)
            if v >= extSigma
                array.set(famEU, f, true)
            if v <= -extSigma
                array.set(famED, f, true)

array<float> famNet = array.new<float>(6, na)
array<bool>  famSplit = array.new<bool>(6, false)
for f = 0 to 5
    int n = array.get(famAct, f)
    array.set(famNet, f, n > 0 ? array.get(famSum, f) / n : na)
    array.set(famSplit, f, array.get(famUp, f) > 0 and array.get(famDn, f) > 0)

float fzMom = array.get(famNet, 0)
float fzTrd = array.get(famNet, 1)
float fzLoc = array.get(famNet, 2)
float fzVol = array.get(famNet, 3)
float fzFlo = array.get(famNet, 4)
float fzCrs = array.get(famNet, 5)

// consensus counts (family resolution)
int actFamN = 0
int extUpFamN = 0
int extDnFamN = 0
int splitN = 0
for f = 0 to 5
    if array.get(famAct, f) > 0
        actFamN := actFamN + 1
    if array.get(famEU, f)
        extUpFamN := extUpFamN + 1
    if array.get(famED, f)
        extDnFamN := extDnFamN + 1
    if array.get(famSplit, f)
        splitN := splitN + 1

int tfNeed = timeframe.in_seconds() <= 60 ? 4 : timeframe.in_seconds() <= 300 ? 3 : 2
int needFam = autoCons ? math.min(tfNeed, math.max(1, actFamN)) : math.min(manualFam, math.max(1, actFamN))
bool consUp = actFamN > 0 and extUpFamN >= needFam
bool consDn = actFamN > 0 and extDnFamN >= needFam

// ═════════════════════════════════════════════════════════════════════════════════════════
//                       COMPOSITE  (mean of active lenses)  +  GATES
// ═════════════════════════════════════════════════════════════════════════════════════════
array<float> lensZ = array.from(zRSI,zKST,zLLSO,zFrac,zER,zSAR,zERgap,zVWAP,zLin,zRange,zVRP,zCVD,zMFI,zBasis,zVIX)
array<bool>  lensA = array.from(aRSI,aKST,aLLSO,aFrac,aER,aSAR,aERgap,aVWAP,aLin,aRange,aVRP,aCVD,aMFI,aBasis,aVIX)
float zSum = 0.0
int   zN = 0
for i = 0 to 14
    if array.get(lensA, i) and not na(array.get(lensZ, i))
        zSum := zSum + array.get(lensZ, i)
        zN := zN + 1
float meanZ = zN > 0 ? zSum / zN : 0.0

float capHi = extSigma + 1.5
float capLo = -extSigma - 1.5
float compSd = ta.stdev(meanZ, compWin)
bool  compOK = not na(compSd) and compSd > 0
float cmpOb  = compOK ? compObK  * compSd : obSigma
float cmpExt = compOK ? compExtK * compSd : extSigma

// composite-derived ta (hoisted to global scope - never conditional)
int   oscWin  = 2 * pivLen + 1
float meanZHi = ta.highest(meanZ, oscWin)
float meanZLo = ta.lowest(meanZ, oscWin)
float gapMin  = magThr * ta.stdev(meanZ, 100)
float phRaw   = ta.pivothigh(srcHigh, pivLen, pivLen)
float plRaw   = ta.pivotlow(srcLow,  pivLen, pivLen)
float oscPH   = ta.pivothigh(meanZ, revPiv, revPiv)
float oscPL   = ta.pivotlow(meanZ, revPiv, revPiv)
// slope (regression sign disagreement)
float pLR0 = ta.linreg(srcPrice, slopeLen, 0)
float pLR1 = ta.linreg(srcPrice, slopeLen, 1)
float zLR0 = ta.linreg(meanZ, slopeLen, 0)
float zLR1 = ta.linreg(meanZ, slopeLen, 1)
float pSlope = pLR0 - pLR1
float zSlope = zLR0 - zLR1
// correlation (rolling price vs composite)
float corr = ta.correlation(srcPrice, meanZ, corrLen)
bool  corrFlip = ta.crossunder(corr, corrThr)

// ═════════════════════════════════════════════════════════════════════════════════════════
//        DETECTION 1 · COMPOSITE PIVOT DIVERGENCE  (regular / hidden / exaggerated / triple)
//                      + DIVERGENCE-COUNT  (families diverging at the pivot)
// ═════════════════════════════════════════════════════════════════════════════════════════
var float pHp  = na
var float pHo  = na
var float pHoD = na
var int   pHb  = na
var array<float> pHfz = array.new<float>(6, na)
var float pLp  = na
var float pLo  = na
var float pLoD = na
var int   pLb  = na
var array<float> pLfz = array.new<float>(6, na)

var int triBearN = 0
var int triBullN = 0
var int divBearFamN = 0
var int divBullFamN = 0

bool regBear = false
bool regBull = false
bool hidBear = false
bool hidBull = false
bool exaBear = false
bool exaBull = false
bool triBear = false
bool triBull = false
bool divConsBear = false
bool divConsBull = false

var array<line>  dLines = array.new<line>()
var array<label> dLabs  = array.new<label>()

// CONFIRMED-BAR GATE (important): ta.pivothigh uses the CURRENT bar as its right-hand confirmation
// bar, so on a live bar it flickers as that bar's high moves. Ungated, f_drawDiv would push a fresh
// line+label on EVERY tick; dLines/dLabs cap at 40 and shift the oldest out, so live-bar churn would
// silently evict genuine historical divergence lines. Arrays are not rolled back between ticks, so
// the gate must be here rather than relying on var rollback.
if not na(phRaw) and showDiv and barstate.isconfirmed
    float cP   = srcHigh[pivLen]
    float cDet = useOscPivot ? meanZHi : meanZ[pivLen]
    float cDr  = meanZ[pivLen]
    int   cB   = bar_index - pivLen
    array<float> curFz = array.from(fzMom[pivLen], fzTrd[pivLen], fzLoc[pivLen], fzVol[pivLen], fzFlo[pivLen], fzCrs[pivLen])
    if not na(pHp) and (cB - pHb) <= maxGap
        bool obOK = cDet >= cmpOb
        bool hh   = cP > pHp
        bool eqh  = (not na(atrV)) and math.abs(cP - pHp) <= eqTol * atrV
        regBear := hh and cDet < pHo and (pHo - cDet) >= gapMin and (not reqExtreme or obOK)
        exaBear := useExag and eqh and cDet < pHo and (pHo - cDet) >= gapMin and (not reqExtreme or obOK)
        hidBear := showHidden and cP < pHp and cDet > pHo and (cDet - pHo) >= gapMin
        if regBear or exaBear
            triBearN := triBearN + 1
        else
            triBearN := 0
        triBear := triBearN >= 3
        // divergence-count: families whose net read failed to confirm the new/equal high
        int dc = 0
        if hh or eqh
            for f = 0 to 5
                float now = array.get(curFz, f)
                float prv = array.get(pHfz, f)
                if not na(now) and not na(prv) and now < prv
                    dc := dc + 1
        divBearFamN := dc
        divConsBear := dc >= needFam
        if regBear or exaBear or hidBear
            f_drawDiv(dLines, dLabs, pHb, pHoD, cB, cDr, colBear, hidBear and not (regBear or exaBear), true, triBear ? "3x" : exaBear and not regBear ? "Exa" : hidBear and not regBear ? "H" : "Bear")
    pHp  := cP
    pHo  := cDet
    pHoD := cDr
    pHb  := cB
    pHfz := curFz

if not na(plRaw) and showDiv and barstate.isconfirmed
    float cP   = srcLow[pivLen]
    float cDet = useOscPivot ? meanZLo : meanZ[pivLen]
    float cDr  = meanZ[pivLen]
    int   cB   = bar_index - pivLen
    array<float> curFz = array.from(fzMom[pivLen], fzTrd[pivLen], fzLoc[pivLen], fzVol[pivLen], fzFlo[pivLen], fzCrs[pivLen])
    if not na(pLp) and (cB - pLb) <= maxGap
        bool osOK = cDet <= -cmpOb
        bool ll   = cP < pLp
        bool eql  = (not na(atrV)) and math.abs(cP - pLp) <= eqTol * atrV
        regBull := ll and cDet > pLo and (cDet - pLo) >= gapMin and (not reqExtreme or osOK)
        exaBull := useExag and eql and cDet > pLo and (cDet - pLo) >= gapMin and (not reqExtreme or osOK)
        hidBull := showHidden and cP > pLp and cDet < pLo and (pLo - cDet) >= gapMin
        if regBull or exaBull
            triBullN := triBullN + 1
        else
            triBullN := 0
        triBull := triBullN >= 3
        int dc = 0
        if ll or eql
            for f = 0 to 5
                float now = array.get(curFz, f)
                float prv = array.get(pLfz, f)
                if not na(now) and not na(prv) and now > prv
                    dc := dc + 1
        divBullFamN := dc
        divConsBull := dc >= needFam
        if regBull or exaBull or hidBull
            f_drawDiv(dLines, dLabs, pLb, pLoD, cB, cDr, colBull, hidBull and not (regBull or exaBull), false, triBull ? "3x" : exaBull and not regBull ? "Exa" : hidBull and not regBull ? "H" : "Bull")
    pLp  := cP
    pLo  := cDet
    pLoD := cDr
    pLb  := cB
    pLfz := curFz

// ═════════════════════════════════════════════════════════════════════════════════════════
//        DETECTION 2 · SLOPE   3 · CORRELATION   4 · SEQUENTIAL   5 · LEADING (split)
// ═════════════════════════════════════════════════════════════════════════════════════════
bool slopeBear = useSlope and pSlope > 0 and zSlope < 0
bool slopeBull = useSlope and pSlope < 0 and zSlope > 0
bool slopeBearEvt = slopeBear and not slopeBear[1]
bool slopeBullEvt = slopeBull and not slopeBull[1]

bool corrBearEvt = useCorr and corrFlip and pSlope > 0
bool corrBullEvt = useCorr and corrFlip and pSlope < 0

bool descending = rsiV < rsiV[1] and rsiV[1] < rsiV[2] and rsiV[2] < rsiV[3]
bool ascending  = rsiV > rsiV[1] and rsiV[1] > rsiV[2] and rsiV[2] > rsiV[3]
bool seqBull = useSeq and descending and rsiV[3] < seqOs and rsiV[4] > seqOs
bool seqBear = useSeq and ascending  and rsiV[3] > seqOb and rsiV[4] < seqOb

bool leadBull = useLead and splitN > 0 and meanZ <= -cmpOb
bool leadBear = useLead and splitN > 0 and meanZ >=  cmpOb
bool leadBullEvt = leadBull and not leadBull[1]
bool leadBearEvt = leadBear and not leadBear[1]

// in-band composite reversals
bool revTop = showExtRev and not na(oscPH) and oscPH >= cmpExt
bool revBot = showExtRev and not na(oscPL) and oscPL <= -cmpExt

// ═════════════════════════════════════════════════════════════════════════════════════════
//   CALIBRATION HARNESS  -  forward-scores every event class vs an unconditional base rate
//   Classes: 1 EXTREME · 2 DIVERGENCE(pivot) · 3 SLOPE · 4 CORRELATION · 5 SEQUENTIAL ·
//            6 LEADING(split) · 7 DIVERGENCE-COUNT.  Logged AND resolved on confirmed bars.
//   na-safe base sampler: the running base only advances on a valid (non-na) sample.
// ═════════════════════════════════════════════════════════════════════════════════════════
type CalEvt
    int   cls
    int   dir
    float entry
    float atr0
    int   bidx

int   NCLS    = 7
int   calMinN = 8
float atrC    = ta.atr(calAtrLen)

var array<CalEvt> calPend = array.new<CalEvt>()
var array<int> cUpN    = array.new<int>(NCLS + 1, 0)
var array<int> cUpW    = array.new<int>(NCLS + 1, 0)
var array<int> cDnN    = array.new<int>(NCLS + 1, 0)
var array<int> cDnW    = array.new<int>(NCLS + 1, 0)
var array<int> cLastUp = array.new<int>(NCLS + 1, -100000)
var array<int> cLastDn = array.new<int>(NCLS + 1, -100000)

var array<float> baseE = array.new<float>()
var array<float> baseA = array.new<float>()
var array<int>   baseB = array.new<int>()
var int baseN   = 0
var int baseUpW = 0
var int baseDnW = 0

f_logEvt(array<CalEvt> q, array<int> lu, array<int> ld, int cls, int dir, float price, float a0, int gap) =>
    if dir > 0 and (bar_index - array.get(lu, cls)) >= gap
        array.set(lu, cls, bar_index)
        array.push(q, CalEvt.new(cls, dir, price, a0, bar_index))
    else if dir < 0 and (bar_index - array.get(ld, cls)) >= gap
        array.set(ld, cls, bar_index)
        array.push(q, CalEvt.new(cls, dir, price, a0, bar_index))

// resolve matured events
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

// unconditional base-rate sampler (na-gated)
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

// log this bar's events
if calibOn and barstate.isconfirmed and not na(atrC) and atrC > 0
    int cDirU = calMode == "Exhaustion (fade)" ? -1 : 1
    int cDirD = calMode == "Exhaustion (fade)" ?  1 : -1
    if consUp
        f_logEvt(calPend, cLastUp, cLastDn, 1, cDirU, srcPrice, atrC, calGap)
    if consDn
        f_logEvt(calPend, cLastUp, cLastDn, 1, cDirD, srcPrice, atrC, calGap)
    if regBull or exaBull
        f_logEvt(calPend, cLastUp, cLastDn, 2,  1, srcPrice, atrC, calGap)
    if regBear or exaBear
        f_logEvt(calPend, cLastUp, cLastDn, 2, -1, srcPrice, atrC, calGap)
    if slopeBullEvt
        f_logEvt(calPend, cLastUp, cLastDn, 3,  1, srcPrice, atrC, calGap)
    if slopeBearEvt
        f_logEvt(calPend, cLastUp, cLastDn, 3, -1, srcPrice, atrC, calGap)
    if corrBullEvt
        f_logEvt(calPend, cLastUp, cLastDn, 4,  1, srcPrice, atrC, calGap)
    if corrBearEvt
        f_logEvt(calPend, cLastUp, cLastDn, 4, -1, srcPrice, atrC, calGap)
    if seqBull
        f_logEvt(calPend, cLastUp, cLastDn, 5,  1, srcPrice, atrC, calGap)
    if seqBear
        f_logEvt(calPend, cLastUp, cLastDn, 5, -1, srcPrice, atrC, calGap)
    if leadBullEvt
        f_logEvt(calPend, cLastUp, cLastDn, 6,  1, srcPrice, atrC, calGap)
    if leadBearEvt
        f_logEvt(calPend, cLastUp, cLastDn, 6, -1, srcPrice, atrC, calGap)
    if divConsBull
        f_logEvt(calPend, cLastUp, cLastDn, 7,  1, srcPrice, atrC, calGap)
    if divConsBear
        f_logEvt(calPend, cLastUp, cLastDn, 7, -1, srcPrice, atrC, calGap)

float upBaseP = baseN > 0 ? baseUpW * 100.0 / baseN : na
float dnBaseP = baseN > 0 ? baseDnW * 100.0 / baseN : na
f_clsN(int c)    => array.get(cUpN, c) + array.get(cDnN, c)
f_clsW(int c)    => array.get(cUpW, c) + array.get(cDnW, c)
f_clsHit(int c)  => f_clsN(c) > 0 ? f_clsW(c) * 100.0 / f_clsN(c) : na
f_clsBase(int c) =>
    int n = f_clsN(c)
    (n > 0 and not na(upBaseP) and not na(dnBaseP)) ? (array.get(cUpN, c) * upBaseP + array.get(cDnN, c) * dnBaseP) / n : na
f_clsEdge(int c) => (not na(f_clsHit(c)) and not na(f_clsBase(c))) ? f_clsHit(c) - f_clsBase(c) : na

// ===== FORWARD-STATISTICS UPGRADE  (Wilson interval + significance) =====
f_wilson(float w, float n, float zc) =>
    float r = na
    if n > 0.0
        float pp = w / n
        float den = 1.0 + zc * zc / n
        r := zc * math.sqrt(pp * (1.0 - pp) / n + zc * zc / (4.0 * n * n)) / den
    r

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                          PLOTS

// ===== meta-labelling weight (Edge-significant class fraction) + PBO flag =====
float metaW = 0.0
int   metaTot = 0
for c = 1 to NCLS
    if f_clsN(c) >= calMinN and not na(f_clsEdge(c))
        metaTot += 1
        if (f_clsHit(c) - f_wilson(f_clsW(c), f_clsN(c), 2.69) * 100.0) > f_clsBase(c)
            metaW += 1.0
float metaScale = metaTot > 0 ? metaW / metaTot : 0.0
float exMetaBias = math.max(-100.0, math.min(100.0, meanZ * 33.0 * metaScale))
bool  pboFlag = metaTot >= 3 and metaScale < 0.2
// ═════════════════════════════════════════════════════════════════════════════════════════
// (lens ribbon removed for plot-budget headroom; the composite carries the read)

// composite glow line, colored by its adaptive gate
color cmpCol = meanZ >= cmpOb ? colBear : meanZ <= -cmpOb ? colBull : color.new(color.gray, 0)
plot(meanZ, "Composite glow", color = color.new(cmpCol, 68), linewidth = 7)
plot(meanZ, "Composite",      color = cmpCol, linewidth = 2)

// yellow midline - hline costs no plot budget; one faint glow plot for the house look
plot(0.0, "Mid glow", color = color.new(colMid, 80), linewidth = 6)
hline(0.0, "Zero", color = color.new(colMid, 0), linestyle = hline.style_solid)

// shared extreme bands - red top (overbought), green bottom (oversold)
pExtHi = plot(extSigma, "Extreme +", color = color.new(colBear, 25), linewidth = 1)
pCapHi = plot(capHi,    "cap+",      color = color.new(colBear, 100), display = display.none)
fill(pExtHi, pCapHi, capHi, extSigma, color.new(colBear, 12), color.new(colBear, 88), title = "Upper extreme")
pExtLo = plot(-extSigma, "Extreme -", color = color.new(colBull, 25), linewidth = 1)
pCapLo = plot(capLo,     "cap-",      color = color.new(colBull, 100), display = display.none)
fill(pExtLo, pCapLo, -extSigma, capLo, color.new(colBull, 88), color.new(colBull, 12), title = "Lower extreme")

// composite adaptive gate guides
plot(compOK ? cmpExt  : na, "Comp ext +", color = color.new(colBear, 75))
plot(compOK ? -cmpExt : na, "Comp ext -", color = color.new(colBull, 75))

// consensus dots
plot(showDots and consUp ? extSigma  : na, "Consensus OB", style = plot.style_circles, color = colBear, linewidth = 4)
plot(showDots and consDn ? -extSigma : na, "Consensus OS", style = plot.style_circles, color = colBull, linewidth = 4)

// in-band composite reversal dots
plot(revTop ? oscPH : na, "Top reversal",    style = plot.style_circles, color = colBear, linewidth = 4, offset = -revPiv)
plot(revBot ? oscPL : na, "Bottom reversal", style = plot.style_circles, color = colBull, linewidth = 4, offset = -revPiv)

// price-pane marks
if showMarks and consUp
    label.new(bar_index, high, "Ext " + str.tostring(extUpFamN), yloc = yloc.abovebar, style = label.style_label_down, color = colBear, textcolor = color.white, size = size.tiny, force_overlay = true)
if showMarks and consDn
    label.new(bar_index, low, "Ext " + str.tostring(extDnFamN), yloc = yloc.belowbar, style = label.style_label_up, color = colBull, textcolor = color.white, size = size.tiny, force_overlay = true)
plotshape(showMarks and (regBull or exaBull), "Div Bull", shape.triangleup,   location.belowbar, colBull, size = size.tiny, force_overlay = true)
plotshape(showMarks and (regBear or exaBear), "Div Bear", shape.triangledown, location.abovebar, colBear, size = size.tiny, force_overlay = true)
plotshape(showMarks and divConsBull, "DivCount Bull", shape.diamond, location.belowbar, color.new(colBull, 25), size = size.tiny, force_overlay = true)
plotshape(showMarks and divConsBear, "DivCount Bear", shape.diamond, location.abovebar, color.new(colBear, 25), size = size.tiny, force_overlay = true)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                       DASHBOARD  (three-tier, theme-adaptive zebra)
// ═════════════════════════════════════════════════════════════════════════════════════════
var table st = table.new(f_pos(tblPos), 2, 20, frame_width = 1, border_width = 1)
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
    int    divNow = math.max(divBullFamN, divBearFamN)
    int    extNow = math.max(extUpFamN, extDnFamN)
    array<string> cnm = array.from("Extreme","Divergence","Slope","Correlation","Sequential","Leading","Div-count")

    // shared family tallies
    int bullFamN = 0
    int bearFamN = 0
    for f = 0 to 5
        float fv = array.get(famNet, f)
        if not na(fv) and not array.get(famSplit, f)
            if fv > 0
                bullFamN += 1
            if fv < 0
                bearFamN += 1

    // best-calibrated method (highest Edge among matured classes)
    int   bestC = 0
    float bestE = -1e9
    for c = 1 to NCLS
        float e = f_clsEdge(c)
        if f_clsN(c) >= calMinN and not na(e) and e > bestE
            bestE := e
            bestC := c

    table.cell(st, 0, 0, "Divergence Matrix", text_color = color.white, bgcolor = hdr, text_size = size.tiny)
    table.cell(st, 1, 0, state, text_color = color.white, bgcolor = hdr, text_size = size.tiny)
    table.cell(st, 0, 1, "Composite", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(st, 1, 1, str.tostring(meanZ, "0.00") + " sigma  " + czone + cgate + "  mW" + str.tostring(metaScale * 100.0, "0") + (pboFlag ? "!" : ""), text_color = czcol, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(st, 0, 2, "Stretched / Diverging", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
    table.cell(st, 1, 2, str.tostring(extNow) + "/" + str.tostring(actFamN) + "  ·  " + str.tostring(divNow) + "/" + str.tostring(actFamN), text_color = txtMain, bgcolor = panelBg, text_size = size.tiny)

    if dashMode == "Compact"
        // ── COMPACT · decision essentials ──
        string famTxt = str.tostring(bullFamN) + " bull · " + str.tostring(bearFamN) + " bear · " + str.tostring(splitN) + " split"
        color  famCol = bullFamN > bearFamN ? bullC : bearFamN > bullFamN ? bearC : flatC
        table.cell(st, 0, 3, "Families", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
        table.cell(st, 1, 3, famTxt, text_color = famCol, bgcolor = rowAlt, text_size = size.tiny)
        if calibOn
            string bestTxt = bestC == 0 ? "warming" : array.get(cnm, bestC - 1) + "  E" + (bestE >= 0 ? "+" : "") + str.tostring(bestE, "0") + " H" + str.tostring(f_clsHit(bestC), "0") + " (" + str.tostring(f_clsN(bestC)) + ")" + ((bestC > 0 and not na(bestE) and (f_clsHit(bestC) - f_wilson(f_clsW(bestC), f_clsN(bestC), 2.69) * 100.0) > f_clsBase(bestC)) ? " *" : "")
            color  bestCol = bestC == 0 ? flatC : bestE > 0 ? bullC : bearC
            table.cell(st, 0, 4, "Best method", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
            table.cell(st, 1, 4, bestTxt, text_color = bestCol, bgcolor = panelBg, text_size = size.tiny)
            string baseTxt = (na(upBaseP) or na(dnBaseP)) ? "warming" : "up " + str.tostring(upBaseP, "0") + "  dn " + str.tostring(dnBaseP, "0")
            table.cell(st, 0, 5, "Base " + str.tostring(calHor) + "b %", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
            table.cell(st, 1, 5, baseTxt, text_color = txtMain, bgcolor = rowAlt, text_size = size.tiny)
    else
        // ── PRO · every family row + every calibration class ──
        array<string> fnm = array.from("Momentum","Trend/Eff","Location","Volatility","Flow/Volume","Cross-Asset")
        for f = 0 to 5
            float fv = array.get(famNet, f)
            int   up = array.get(famUp, f)
            int   dn = array.get(famDn, f)
            int   an = array.get(famAct, f)
            bool  sp = array.get(famSplit, f)
            bool  eu = array.get(famEU, f)
            bool  ed = array.get(famED, f)
            string arrow = na(fv) ? "·" : fv > 0 ? "▲" : fv < 0 ? "▼" : "·"
            int    maj   = math.max(up, dn)
            string agree = an > 0 ? str.tostring(maj) + "/" + str.tostring(an) : "—"
            string flag  = sp ? "  SPLIT" : (eu or ed) ? "  ●" : ""
            color  fc    = na(fv) ? flatC : sp ? flatC : fv > 0 ? bullC : bearC
            color  rbg   = f % 2 == 0 ? rowAlt : panelBg
            table.cell(st, 0, 3 + f, array.get(fnm, f), text_color = txtSub, bgcolor = rbg, text_size = size.tiny)
            table.cell(st, 1, 3 + f, arrow + " " + agree + flag, text_color = fc, bgcolor = rbg, text_size = size.tiny)
        if calibOn
            string baseTxt = (na(upBaseP) or na(dnBaseP)) ? "warming" : "up " + str.tostring(upBaseP, "0") + "  dn " + str.tostring(dnBaseP, "0")
            table.cell(st, 0, 9, "Base " + str.tostring(calHor) + "b %", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
            table.cell(st, 1, 9, baseTxt, text_color = txtMain, bgcolor = rowAlt, text_size = size.tiny)
            for c = 1 to NCLS
                int    cn   = f_clsN(c)
                float  chit = f_clsHit(c)
                float  cedg = f_clsEdge(c)
                color  cbg  = c % 2 == 1 ? panelBg : rowAlt
                color  cec  = (na(cedg) or cn < calMinN) ? flatC : cedg > 0 ? bullC : bearC
                string ctx  = cn < calMinN ? "warm " + str.tostring(cn) : "H" + str.tostring(chit, "0") + "  E" + (cedg >= 0 ? "+" : "") + str.tostring(cedg, "0") + "  (" + str.tostring(cn) + ")" + ((cn >= calMinN and not na(cedg) and (chit - f_wilson(f_clsW(c), f_clsN(c), 2.69) * 100.0) > f_clsBase(c)) ? " *" : "")
                table.cell(st, 0, 9 + c, array.get(cnm, c - 1), text_color = txtSub, bgcolor = cbg, text_size = size.tiny)
                table.cell(st, 1, 9 + c, ctx, text_color = cec, bgcolor = cbg, text_size = size.tiny)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                          ALERTS
// ═════════════════════════════════════════════════════════════════════════════════════════

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                       LEGEND / KEY
// ═════════════════════════════════════════════════════════════════════════════════════════
showLegend = input.bool(true, "Show legend / key", group = g12,
     tooltip = "A key explaining every line, zone and marker the script draws. Fifteen lenses is a lot to read cold.")
var table lgT = table.new(position.bottom_left, 2, 8, frame_width = 1, border_width = 1)
f_lgRow(int rw, string sw, color swc, string txt, color bg, color tc) =>
    table.cell(lgT, 0, rw, sw, text_color = swc, bgcolor = bg, text_size = size.tiny, text_halign = text.align_center)
    table.cell(lgT, 1, rw, txt, text_color = tc, bgcolor = bg, text_size = size.tiny, text_halign = text.align_left)
if showLegend and barstate.islast
    color bgL  = chart.bg_color
    float lumL = na(bgL) ? 0.0 : color.r(bgL) * 0.299 + color.g(bgL) * 0.587 + color.b(bgL) * 0.114
    bool  dkL  = dashTheme == "Dark" ? true : dashTheme == "Light" ? false : (na(bgL) or lumL < 140)
    color pnL  = dkL ? color.rgb(17, 22, 28)    : color.rgb(244, 246, 248)
    color alL  = dkL ? color.rgb(25, 31, 39)    : color.rgb(232, 236, 240)
    color tmL  = dkL ? color.white              : color.rgb(16, 20, 24)
    color tsL  = dkL ? color.rgb(154, 166, 178) : color.rgb(74, 82, 91)
    color frL  = dkL ? color.rgb(58, 70, 84)    : color.rgb(196, 204, 212)
    table.set_bgcolor(lgT, pnL)
    table.set_frame_color(lgT, frL)
    table.set_border_color(lgT, frL)
    table.cell(lgT, 0, 0, "KEY", text_color = tmL, bgcolor = frL, text_size = size.tiny)
    table.cell(lgT, 1, 0, "what you're looking at", text_color = tmL, bgcolor = frL, text_size = size.tiny, text_halign = text.align_left)
    f_lgRow(1, "━━", colBull, "Composite — mean of the active lenses (sigma units)", alL, tsL)
    f_lgRow(2, "▒",  colBear, "Shaded = overbought / oversold and extreme bands", pnL, tsL)
    f_lgRow(3, "╱",  colBull, "Solid line = regular divergence · dashed = hidden", alL, tsL)
    f_lgRow(4, "3x", colBear, "Label: 3x = triple · Exa = exaggerated · H = hidden", pnL, tsL)
    f_lgRow(5, "▲▼", colBull, "Price-chart mark = divergence confirmed at a pivot", alL, tsL)
    f_lgRow(6, "Ext", colBear, "Ext n = n families stretched to the extreme together", pnL, tsL)
    f_lgRow(7, "SPLIT", color.new(#ffa726, 0), "A family's aspects disagree — often the first crack", alL, tsL)

// ===== IDENTITY STRIP  (name, symbol, timeframe) =====
showId = input.bool(true, "Show identity strip (name, symbol, timeframe)", group = "Z · Identity & exports")
var table idT = table.new(position.bottom_center, 1, 1, force_overlay = true)
if showId and barstate.islast
    color bgI  = chart.bg_color
    float lumI = na(bgI) ? 0.0 : color.r(bgI) * 0.299 + color.g(bgI) * 0.587 + color.b(bgI) * 0.114
    bool  dkI  = dashTheme == "Dark" ? true : dashTheme == "Light" ? false : (na(bgI) or lumI < 140)
    table.cell(idT, 0, 0, "Multi-Factor Divergence Matrix   -   " + syminfo.ticker + "   -   " + timeframe.period, text_color = dkI ? color.new(#c8d0da, 10) : color.new(#2a2f37, 10), text_size = size.small, text_halign = text.align_center, bgcolor = color.new(color.gray, 100))

// ===== EXP_* EXPORTS  (Data Window, generic names for input.source) =====
showEXP = input.bool(true, "Emit EXP_* exports", group = "Z · Identity & exports")
color exC_ = color.new(color.gray, 100)
plot(showEXP ? (meanZ) : na, "EXP_Composite", color = exC_, display = display.data_window)
plot(showEXP ? (math.max(-100.0, math.min(100.0, meanZ * 33.0))) : na, "EXP_Bias", color = exC_, display = display.data_window)
plot(showEXP ? (meanZ >= cmpOb ? 1 : meanZ <= -cmpOb ? -1 : 0) : na, "EXP_Zone", color = exC_, display = display.data_window)
plot(showEXP ? (consUp ? 1 : consDn ? -1 : 0) : na, "EXP_Consensus", color = exC_, display = display.data_window)
plot(showEXP ? (extUpFamN) : na, "EXP_ExtUp", color = exC_, display = display.data_window)
plot(showEXP ? (extDnFamN) : na, "EXP_ExtDn", color = exC_, display = display.data_window)
plot(showEXP ? (math.max(divBullFamN, divBearFamN)) : na, "EXP_DivCount", color = exC_, display = display.data_window)
plot(showEXP ? ((regBull or exaBull) ? 1 : (regBear or exaBear) ? -1 : 0) : na, "EXP_RegDiv", color = exC_, display = display.data_window)
plot(showEXP ? (1) : na, "EXP_DataLive", color = exC_, display = display.data_window)

plot(showEXP ? (exMetaBias) : na, "EXP_MetaBias", color = exC_, display = display.data_window)
plot(showEXP ? (pboFlag ? 1 : 0) : na, "EXP_PBO", color = exC_, display = display.data_window)
alertcondition(consUp, "Consensus overbought", "Divergence Matrix: family consensus overbought")
alertcondition(consDn, "Consensus oversold",   "Divergence Matrix: family consensus oversold")
alertcondition(regBull or exaBull, "Composite bullish divergence", "Divergence Matrix: composite bullish divergence")
alertcondition(regBear or exaBear, "Composite bearish divergence", "Divergence Matrix: composite bearish divergence")
alertcondition(divConsBull, "Divergence-count bullish", "Divergence Matrix: family divergence-count bullish")
alertcondition(divConsBear, "Divergence-count bearish", "Divergence Matrix: family divergence-count bearish")
alertcondition(leadBullEvt, "Leading split bullish", "Divergence Matrix: intra-family split (bullish context)")
alertcondition(leadBearEvt, "Leading split bearish", "Divergence Matrix: intra-family split (bearish context)")

int divPulse = (regBull or exaBull) ? 1 : (regBear or exaBear) ? -1 : 0
var int divDirHeld = 0
var int divDirAge  = 0
if divPulse != 0
    divDirHeld := divPulse
    divDirAge  := 0
else
    divDirAge += 1
    if divDirAge >= 8           // hold window in bars — raise for a longer-lived veto
        divDirHeld := 0
plot(divDirHeld, "→Conf: Div dir", display=display.data_window)
````
