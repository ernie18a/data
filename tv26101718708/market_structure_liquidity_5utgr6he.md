# Market Structure & Liquidity

- url: https://www.tradingview.com/script/5UtGr6hE-Market-Structure-Liquidity/
- type: indicator
- pine_id: PUB;40ffe7a081ec458bb005b037bee98cd2
- version: 2.0

## Description

MARKET STRUCTURE & LIQUIDITY — Calibrated Zones, Premium/Discount & Setup Grade
================================================================================

WHAT THIS SCRIPT IS

A single price-action framework that maps the structural read of a chart and
then measures it. It plots market structure (break of structure and change of
character), supply/demand order blocks, fair value gaps, resting liquidity
(equal highs and lows) and the sweeps that take it, premium/discount with an
optimal-entry band, a higher-timeframe bias, and a rolling volume profile. On
top of those objects it does three things most structure tools do not: it
validates every structure break, it scores each zone by confluence and quality,
and it reports — using past data on the current symbol only — how often each
zone type has actually been respected, with statistical confidence intervals.
The levels are the raw material; the framework adds a measured read of which
ones to trust.

WHY THE COMPONENTS ARE COMBINED (how the parts work together)

These are not independent indicators bolted together. They describe one process
— how large participants build positions: rest liquidity, take it, displace
price, and leave an inefficiency behind — and each layer covers a blind spot of
the others, feeding one combined decision:

- Market structure (swing and internal) gives trend context and the moment it
  shifts. Because raw break detection is noisy, a break is only counted when it
  shows real displacement (range expansion with body, or a volatility
  compression followed by a release), closes beyond the level with body rather
  than leaving a rejection wick, and breaks a tight, recent (quality) pivot.
  This removes most false breaks before anything else is drawn.

- Regime context (efficiency ratio + ADX + volatility clustering + a whipsaw
  score) conditions how far to trust a read: continuation breaks are reliable in
  a trending regime, reversals are more reliable in a range, and a choppy regime
  weights everything down. Structure on its own cannot tell you this.

- Liquidity (equal highs/lows, sweeps, and inducement) marks where stops rest
  and the moment they are taken — the trigger that typically precedes a real
  move, and the event that validates a nearby zone.

- Order blocks and fair value gaps mark the origin of the displacement and the
  inefficiency price tends to revisit. A zone that forms on a sweep, on a
  high-volume node, in the correct half of the range scores highest — which is
  exactly why liquidity, the volume profile and premium/discount all feed the
  zone score rather than living in separate panes.

- Volume profile (point of control, high- and low-volume nodes, and untested
  "naked" points of control) tells you whether a zone sits on acceptance (tends
  to hold) or on a thin gap (tends to slice), and marks magnet levels price is
  drawn back toward.

- Premium/discount and the OTE band frame every zone as expensive or cheap
  relative to the current dealing range, so a long in discount and a short in
  premium are favoured.

- The confluence engine and setup grade fuse structure direction, a recent
  sweep, zone quality, node type, premium/discount alignment, higher-timeframe
  bias and a momentum-divergence confirmation into one A/B/C read per zone, so
  the chart self-prioritises instead of leaving you to weigh eight things by eye.

- Calibration measures, on past bars only, how often each zone type produced a
  meaningful reaction on the current symbol, and reports it with Wilson
  confidence intervals — so reliability is earned per instrument, not assumed.

In one sentence: structure says direction, regime says whether to believe it,
liquidity says when, the zones say where, premium/discount says whether it is
worth it, the grade fuses them, and the calibration keeps the whole thing honest.

HOW IT WORKS (mechanics, briefly)

Pivots use the standard left/right confirmation, so structure is non-repainting:
a break is only labelled after the pivot is confirmed and the close validates it.
Order blocks anchor to the last opposing candle before a validated break, are
scored on formation, and are re-scored for confluence on the most recent bar.
Calibration records, the first time a zone is tagged, whether price then travels
a chosen ATR multiple in the zone's direction within a fixed horizon, and
aggregates that into the respect rate shown on the dashboard. All thresholds are
ATR-relative, so nothing is tied to a particular price scale.

HOW TO USE IT

1. Read the dashboard headline: the SETUP grade and the structure bias.
2. Favour higher-grade setups — a validated structure direction, a recent sweep,
   a fresh high-quality zone sitting on a volume node, in discount for longs or
   premium for shorts, with higher-timeframe agreement.
3. Use the OTE band for entry context and an opposing fair value gap as a
   logical target.
4. Check the respect rows. If order blocks or fair value gaps rarely hold on this
   symbol, weight the read down accordingly.
5. Treat everything as descriptive context, not a signal to act on.

USE ON ANY MARKET

The High / Low / Close source inputs let you drive structure, liquidity and
premium/discount from any series (standard candles, Heikin-Ashi, or another
source), so the framework applies to stocks, indices, futures, forex and crypto.
A volume-borrow input supplies volume for symbols that report none.

WHAT MAKES IT ORIGINAL

The contribution is the closed loop, not the individual objects, which are
common to price-action analysis. Here, validated structure and liquidity feed a
per-zone confluence and quality score and a single setup grade, and a past-only
calibration tracker reports each zone type's actual respect rate on the current
symbol with confidence intervals. That turns a set of drawing tools into a
measured, self-prioritising read.

SETTINGS WORTH KNOWING

- Break Validation: turn displacement, anti-wick and pivot-quality gates on/off
  and tune their strictness to make structure more or less selective.
- Volume Profile / Nodes: bins, window and HVN/LVN percentiles control node
  tagging; naked POC tracking is session-based and turns itself off when the
  chart is not intraday.
- Confluence & Setup Grade: cluster tolerance controls how close levels must be
  to count as confluent.
- Calibration: horizon and minimum reaction define what counts as a "respected"
  zone.
- Visuals: theme is auto/dark/light; grade-weighted opacity makes strong zones
  bold and weak ones faint; the identity strip shows the script name, symbol and
  timeframe.

LIMITATIONS

Pivots confirm after the right-bars lag, so forming structure is not drawn until
confirmed. Volume layers require real or borrowed volume. Calibration describes
past behaviour only — it is not a backtest and not a probability of future
results. Every read is probabilistic context, never a certainty.

DISCLAIMER

This is a study/indicator for chart analysis and education only. It is not a
strategy, not a recommendation, and not financial advice. It places no orders
and guarantees no outcome. Markets carry risk, and the past behaviour of a level
does not assure its future behaviour. Do your own research and manage your own
risk.

## Source Code

````pine
// =============================================================================
//  MARKET STRUCTURE & LIQUIDITY — Calibrated Zones, Premium/Discount & Setup Grade
//  shorttitle: MS Liquidity                                         Pine Script v6
// -----------------------------------------------------------------------------
//  OVERVIEW
//    A price-action framework that maps market structure (break of structure and
//    change of character), supply/demand order blocks, fair value gaps, resting
//    liquidity (equal highs/lows) and their sweeps, premium/discount with an
//    optimal-entry band, and higher-timeframe bias — then VALIDATES each
//    structure break, SCORES each zone by confluence and quality, GRADES the
//    overall setup, and reports past-only how often each zone type has actually
//    been respected on the current symbol. Levels are the raw material; the
//    framework adds a measured read of which ones to trust.
//
//  WHY THESE COMPONENTS ARE COMBINED  (mashup rationale)
//    These are not independent indicators stacked together; they describe one
//    process — how large participants build positions: rest liquidity, take it,
//    displace price, and leave an inefficiency behind. Each layer covers a blind
//    spot of the others and feeds a single decision:
//      * MARKET STRUCTURE (swing + internal) gives trend context and the moment
//        it shifts. Raw break detection is noisy, so a break only counts when it
//        shows real DISPLACEMENT (range expansion with body, or a compression
//        followed by release), closes beyond the level with body (ANTI-WICK),
//        and breaks a tight, recent (QUALITY) pivot. This removes most fakeouts.
//      * REGIME (efficiency ratio + ADX + volatility clustering + a whipsaw
//        score) conditions how much to trust a read: continuation breaks are
//        reliable in trend, reversals in range, and a choppy regime weights
//        everything down. Structure alone cannot tell you this.
//      * LIQUIDITY (equal highs/lows, sweeps, inducement) marks where stops rest
//        and the moment they are taken — the trigger that precedes a real move.
//      * ORDER BLOCKS and FAIR VALUE GAPS mark the displacement origin and the
//        inefficiency price tends to revisit. A zone that forms on a sweep, on a
//        high-volume node, in the correct half of the range scores highest —
//        which is why liquidity, volume profile and premium/discount feed it.
//      * VOLUME PROFILE (point of control, high/low-volume nodes, untested
//        point-of-control magnets) tells whether a zone sits on acceptance
//        (tends to hold) or a gap (tends to slice), and marks magnet levels.
//      * PREMIUM / DISCOUNT and the OTE band frame every zone as expensive or
//        cheap relative to the current dealing range.
//      * CONFLUENCE + SETUP GRADE fuse structure, sweep, zone quality, node
//        type, premium/discount, higher-timeframe bias and a momentum-divergence
//        confirmation into one A/B/C read, so the chart self-prioritises.
//      * CALIBRATION measures, past-only, the respect rate of each zone type on
//        the current symbol with confidence intervals, so reliability is
//        earned per instrument rather than assumed.
//    In short: structure says direction, regime says whether to believe it,
//    liquidity says when, zones say where, premium/discount says whether it is
//    worth it, the grade fuses them, and calibration keeps the whole thing honest.
//
//  HOW IT WORKS (mechanics)
//    Pivots are detected with the standard left/right confirmation, so structure
//    is non-repainting (a break is only labelled after the pivot is confirmed and
//    the close validates it). Order blocks anchor to the last opposing candle
//    before a validated break, are scored on formation, and are scored again for
//    confluence on the most recent bar. Calibration records, when a zone is first
//    tagged, whether price then travels a chosen ATR multiple in the zone's
//    direction within a fixed horizon, and aggregates that into a respect rate.
//
//  HOW TO USE
//    1. Read the dashboard headline: the SETUP grade and the structure bias.
//    2. Favour higher-grade setups: a validated structure direction + a recent
//       sweep + a fresh, high-quality zone on a volume node, in discount (for
//       longs) or premium (for shorts), with higher-timeframe agreement.
//    3. Use the OTE band for entry context and an opposing FVG as a logical target.
//    4. Check the respect rows — if zones rarely hold on this symbol, weight less.
//    5. Everything here is descriptive context, not a trade instruction.
//
//  USE ON ANY MARKET
//    The High / Low / Close source inputs let you drive structure, liquidity and
//    premium/discount from any series (standard candles, Heikin-Ashi, etc.). A
//    volume-borrow input supplies volume for symbols that report none. All
//    thresholds are ATR-relative, so nothing is hard-coded to a price scale.
//
//  ORIGINALITY
//    The contribution is the closed loop, not the individual objects: validated
//    structure and liquidity feed a per-zone confluence/quality score and a
//    unified setup grade, and a past-only calibration tracker reports each zone
//    type's actual respect rate on the current symbol with confidence intervals.
//    This turns a set of drawing tools into a measured, self-prioritising read.
//
//  LIMITATIONS (honest)
//    Pivots confirm after the right-bars lag; forming structure is not drawn
//    until confirmed. Volume layers require real (or borrowed) volume. Calibration
//    describes PAST behaviour only — it is not a backtest and not a probability of
//    future results. Every read is probabilistic context, never a certainty.
//
//  DISCLAIMER
//    Study / indicator for chart analysis and education only. NOT a strategy, NOT
//    a recommendation, NOT financial advice. It places no orders and guarantees
//    no outcome. Markets carry risk; the past behaviour of a level does not assure
//    its future behaviour. Do your own research and manage your own risk.
// =============================================================================

//@version=6
indicator("Market Structure & Liquidity — Calibrated Zones, Premium/Discount & Setup Grade", "MS Liquidity", overlay = true,
     max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500, max_bars_back = 1500)

// ───────────────────────────── INPUTS ──────────────────────────────────────
gS = "1 · Data Source (any market)"
srcHigh  = input.source(high,  "High source",  group = gS, tooltip = "Drives pivots, structure and liquidity. Defaults are tuned for NIFTY index futures; for other instruments adjust the swing length and ATR-relative thresholds, or swap in an alternative series (e.g. Heikin-Ashi). Works on any market.")
srcLow   = input.source(low,   "Low source",   group = gS)
srcClose = input.source(close, "Close source", group = gS, tooltip = "Used to confirm structure breaks and to place price within the range.")
volBorrowSym = input.symbol("", "Borrow volume from symbol (no-volume fix)", group = gS, tooltip = "For symbols with no native volume, enter a volume-bearing proxy. Used only when the chart has no native volume.")

gStr = "2 · Market Structure"
swingLen = input.int(10, "Swing pivot length", minval = 2, group = gStr)
showIntl = input.bool(true, "Show internal structure", group = gStr)
intlLen  = input.int(5, "Internal pivot length", minval = 2, group = gStr)
showBOS  = input.bool(true, "Label BOS / CHoCH", group = gStr)

gGate = "3 · Break Validation"
useDisplacement = input.bool(true, "Require displacement on break", group = gGate, tooltip = "A break only counts on real displacement (range expansion with body, or a compression then release), not a one-tick poke.")
dispAtrMin = input.float(1.0, "Displacement size (x ATR)", minval = 0.3, maxval = 3.0, step = 0.1, group = gGate)
useAntiWick = input.bool(true, "Require clean close (anti-wick)", group = gGate, tooltip = "The break bar must close beyond the level with body, not leave a rejection wick.")
antiWickPos = input.float(0.60, "Min close position (0-1)", minval = 0.5, maxval = 0.9, step = 0.05, group = gGate)
usePivotQuality = input.bool(true, "Require quality pivot to break", group = gGate, tooltip = "Filters sloppy consolidations: the broken swing must be a tight, recent (defended) level.")
minPivQ = input.float(0.30, "Min pivot quality (0-1)", minval = 0.0, maxval = 0.9, step = 0.05, group = gGate)

gReg = "4 · Regime Filter"
useRegime = input.bool(true, "Condition trust on regime", group = gReg)
erLen    = input.int(20, "Efficiency-ratio length", minval = 2, group = gReg)
erTrend  = input.float(0.30, "ER trend threshold", minval = 0.05, maxval = 0.95, step = 0.01, group = gReg)
adxLen   = input.int(14, "ADX length", minval = 2, group = gReg)
adxTrend = input.float(20.0, "ADX trend threshold", minval = 5, maxval = 50, group = gReg)
clustThr = input.float(1.5, "Vol-cluster z threshold", minval = 0.5, maxval = 4.0, step = 0.1, group = gReg)

gOB = "5 · Order Blocks"
showOB    = input.bool(true,  "Show order blocks", group = gOB)
obScan    = input.int(12, "Origin scan (bars before break)", minval = 3, maxval = 50, group = gOB)
maxOB     = input.int(8, "Max order blocks shown", minval = 1, maxval = 20, group = gOB)
obMinQual = input.float(40, "Min quality to draw (0-100)", minval = 0, maxval = 100, group = gOB)
obUseBody = input.bool(false, "Use candle body (not wick) for OB zone", group = gOB)

gFVG = "6 · Fair Value Gaps"
showFVG   = input.bool(true,  "Show fair value gaps", group = gFVG)
maxFVG    = input.int(8, "Max FVGs shown", minval = 1, maxval = 20, group = gFVG)
fvgMinAtr = input.float(0.15, "Min gap size (x ATR)", minval = 0.0, maxval = 2.0, step = 0.05, group = gFVG)
fvgFillRule = input.string("Midpoint", "FVG fill rule", options = ["Touch", "Midpoint", "Full"], group = gFVG)

gLiq = "7 · Liquidity"
showLiq   = input.bool(true, "Show EQH/EQL liquidity pools", group = gLiq)
eqTol     = input.float(0.10, "Equal-level tolerance (x ATR)", minval = 0.02, maxval = 1.0, step = 0.02, group = gLiq)
showSweep = input.bool(true, "Mark liquidity sweeps", group = gLiq)
useInducement = input.bool(true, "Detect inducement (minor grab before move)", group = gLiq, tooltip = "Flags a minor liquidity grab that lures entries just before the real sweep/shift.")

gPD = "8 · Premium / Discount / OTE"
showPD   = input.bool(true, "Show premium / discount", group = gPD)
showOTE  = input.bool(true, "Show OTE band (0.62 / 0.705 / 0.79)", group = gPD)
pdOpacity = input.int(82, "Zone fill opacity (higher = lighter)", minval = 60, maxval = 96, group = gPD)

gVP = "9 · Volume Profile & Nodes"
useVP    = input.bool(true, "Tag zones as HVN / LVN + show POC", group = gVP)
vpBins   = input.int(24, "Profile bins", minval = 10, maxval = 50, group = gVP)
vpWindow = input.int(250, "Profile window (bars)", minval = 50, maxval = 1000, group = gVP)
hvnPct   = input.float(75, "HVN percentile", minval = 55, maxval = 95, step = 1, group = gVP)
lvnPct   = input.float(30, "LVN percentile", minval = 5, maxval = 45, step = 1, group = gVP)
useNakedPOC = input.bool(true, "Track naked POC magnets", group = gVP)
nakedMax = input.int(8, "Max naked POCs", minval = 2, maxval = 20, group = gVP)

gHTF = "10 · Higher-Timeframe Bias"
useHTF  = input.bool(true, "Use HTF structure bias (non-repaint)", group = gHTF)
htfMult = input.int(4, "HTF multiple of chart", minval = 2, maxval = 60, group = gHTF)

gConf = "11 · Confluence & Setup Grade"
useGrade = input.bool(true, "Compute confluence + A/B/C setup grade", group = gConf)
clusterTol = input.float(0.40, "Confluence cluster tolerance (x ATR)", minval = 0.1, maxval = 1.5, step = 0.05, group = gConf)
useDiv   = input.bool(true, "Use momentum divergence/exhaustion as confirmation", group = gConf)
showGradeLabel = input.bool(true, "Show setup-grade label on chart", group = gConf)

gRev = "12 · Reversion Context"
useHalfLife = input.bool(true, "Show OU half-life to equilibrium", group = gRev)
hlLen   = input.int(100, "Half-life window", minval = 20, maxval = 300, group = gRev)

gCal = "13 · Calibration (past-only)"
calEnable  = input.bool(true, "Track zone respect rate", group = gCal)
calHorizon = input.int(12, "Evaluation horizon (bars)", minval = 3, maxval = 100, group = gCal)
calMoveATR = input.float(0.6, "Min reaction (x ATR)", minval = 0.1, maxval = 3.0, step = 0.1, group = gCal)

gUP = "14 · Predictive & Lifecycle"
useProtSwing = input.bool(true, "Protected-swing CHoCH (anti-flip)", group = gUP, tooltip = "A change of character only counts when the swing that launched the prior leg breaks — cuts flip-flop on shallow pullbacks.")
useAdaptDisp = input.bool(true, "Self-calibrating displacement percentile", group = gUP, tooltip = "Replace the fixed ATR multiple with this instrument's own recent displacement distribution — no magic number.")
dispPctMin   = input.float(55, "Displacement percentile floor", minval = 30, maxval = 90, step = 1, group = gUP)
useAdaptOTE  = input.bool(true, "Self-calibrating OTE (instrument retracements)", group = gUP, tooltip = "Centre the optimal-entry band on the median retracement depth actually seen on this symbol.")
useMerge     = input.bool(true, "Merge overlapping same-side zones", group = gUP)
useDecay     = input.bool(true, "Decay zone score with age + mitigation", group = gUP)
decayBars    = input.int(150, "Score decay window (bars)", minval = 20, maxval = 600, group = gUP)
useReaction  = input.bool(true, "Track reaction strength (ATR)", group = gUP, tooltip = "How far price travels in the zone's favour after it is tagged, in ATR — a measured 'how hard it reacted' that complements the hold-rate.")
useKNN       = input.bool(true, "Per-zone forward probability (analog)", group = gUP, tooltip = "Distance-weighted vote over past zones with a similar context (quality, structure, regime, efficiency, volume) — a forward estimate of whether THIS zone holds. Descriptive of past analogs only.")
knnMin       = input.int(20, "Min analogs to show probability", minval = 5, maxval = 100, group = gUP)
knnBank      = input.int(250, "Analog memory size", minval = 40, maxval = 500, group = gUP)
useWalkFwd   = input.bool(true, "Respect trend + streak check", group = gUP)
useTradeMap  = input.bool(true, "Trade map (reference entry / stop / targets)", group = gUP, tooltip = "Draws invalidation and a target ladder for the highest-grade setup, from structure and liquidity. Reference context only — not a signal, order, or advice.")
tmMinScore   = input.float(55, "Trade map min grade", minval = 0, maxval = 100, group = gUP)
tmStopPad    = input.float(0.25, "Stop pad (x ATR beyond zone)", minval = 0.0, maxval = 1.5, step = 0.05, group = gUP)

gV = "15 · Dashboard & Visuals"
themeMode = input.string("Auto (match chart)", "Theme", options = ["Auto (match chart)", "Dark", "Light"], group = gV)
bullCol   = input.color(#089981, "Bullish / discount", group = gV)
bearCol   = input.color(#f23645, "Bearish / premium", group = gV)
tmEntryCol = input.color(#00BCD4, "Trade map · entry", group = gV, tooltip = "Distinct colours so the trade map reads as its own layer, separate from zones, EQ/OTE and POC.")
tmStopCol  = input.color(#FF6D00, "Trade map · stop", group = gV)
tmTgtCol   = input.color(#2962FF, "Trade map · target", group = gV)
gradedOpacity = input.bool(true, "Grade-weighted zone opacity (A bold, C faint)", group = gV)
fadeMitigated = input.bool(true, "Fade mitigated/tested zones", group = gV)
extendBars = input.int(12, "Zone right-extension (bars)", minval = 0, maxval = 60, group = gV)
showTable = input.bool(true, "Dashboard", group = gV)
tblPosStr = input.string("Top Right", "Dashboard position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = gV)
showId    = input.bool(true, "Identity strip (name / symbol / timeframe)", group = gV)

tblMode = input.string("Compact", "Dashboard mode", options = ["Compact", "Pro"], group = gV, tooltip = "Compact = the decision plus all-timeframe structure at a glance. Pro = the same, with full calibration detail expanded underneath. Both carry every timeframe.")

// ───────────────────────────── PURE HELPERS ────────────────────────────────
f_luma(color c) => na(c) ? 0.0 : color.r(c) * 0.299 + color.g(c) * 0.587 + color.b(c) * 0.114

f_pos(string s) =>
    switch s
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        "Middle Right" => position.middle_right
        => position.top_right

f_wilson(int hits, int total) =>
    float lo = na
    float hi = na
    if total >= 5
        float p = hits / float(total)
        float z = 1.96
        float den = 1.0 + z * z / total
        float c = (p + z * z / (2.0 * total)) / den
        float h = z * math.sqrt(p * (1.0 - p) / total + z * z / (4.0 * total * total)) / den
        lo := math.max(0.0, c - h)
        hi := math.min(1.0, c + h)
    [lo, hi]

f_tfstr(int mult) =>
    int s = timeframe.in_seconds() * mult
    s < 60 ? str.tostring(s) + "S" : s < 86400 ? str.tostring(int(s / 60)) : s < 604800 ? str.tostring(int(s / 86400)) + "D" : str.tostring(int(s / 604800)) + "W"

// next standard TradingView resolution strictly above a given second-count (1/2/3/5/15/30/60/120/240/D/W/M)
f_nextStdSec(int s) =>
    s < 60 ? 60 : s < 120 ? 120 : s < 180 ? 180 : s < 300 ? 300 : s < 900 ? 900 : s < 1800 ? 1800 : s < 3600 ? 3600 : s < 7200 ? 7200 : s < 14400 ? 14400 : s < 86400 ? 86400 : s < 604800 ? 604800 : 2592000

f_secStr(int s) =>
    s < 86400 ? str.tostring(s / 60) : s < 604800 ? str.tostring(s / 86400) + "D" : s < 2592000 ? str.tostring(s / 604800) + "W" : str.tostring(s / 2592000) + "M"

// per-timeframe structure bias + regime code (for the MTF panel; called inside request.security)
f_mtf() =>
    float ph = ta.pivothigh(high, swingLen, swingLen)
    float pl = ta.pivotlow(low, swingLen, swingLen)
    var float sh = na
    var float sl = na
    var int bb = 0
    if not na(ph)
        sh := ph
    if not na(pl)
        sl := pl
    if not na(sh) and close > sh
        bb := 1
    if not na(sl) and close < sl
        bb := -1
    float eN = math.abs(close - close[erLen])
    float eD = math.sum(math.abs(close - close[1]), erLen)
    float e = eD > 0 ? eN / eD : 0.0
    [dp, dm, av] = ta.dmi(adxLen, adxLen)
    float ma = ta.ema(close, 50)
    bool trnd = av > adxTrend and e > erTrend
    float lr = math.abs(nz(ta.change(math.log(close))))
    var float ci = 0.0
    ci := ci * math.exp(-0.20) + lr
    float cm = ta.sma(ci, 100)
    float cs = ta.stdev(ci, 100)
    float cz = cs != 0 ? (ci - cm) / cs : 0.0
    bool vc = cz > clustThr
    int rc = vc and not trnd ? 1 : trnd ? (close > ma ? 2 : -2) : 0
    [bb, rc]

f_gradeLetter(float s) => s >= 80 ? "A+" : s >= 68 ? "A" : s >= 55 ? "B" : s >= 45 ? "C" : "-"

f_pivQ(float pivPx, float prevPx, int pivBar, float refPx) =>
    float q = 0.5
    if not na(pivPx) and not na(prevPx) and not na(pivBar)
        float refScale = refPx * 0.01
        float rng = math.abs(pivPx - prevPx)
        float tight = refScale > 0 ? math.max(0.0, math.min(1.0, 1.0 - rng / refScale)) : 0.5
        float rec = math.max(0.0, math.min(1.0, 1.0 - (bar_index - pivBar) / 200.0))
        q := 0.5 * tight + 0.5 * rec
    q

f_nodeTag(float px, float wHi, float wLo, float step, float[] bins, float hvnT, float lvnT) =>
    string tag = "mid"
    int n = array.size(bins)
    if n > 0 and not na(px) and step > 0 and px >= wLo and px <= wHi
        int bi = math.max(0, math.min(n - 1, int((px - wLo) / step)))
        float bv = array.get(bins, bi)
        tag := bv >= hvnT ? "HVN" : bv <= lvnT ? "LVN" : "mid"
    tag

f_quality(float dispAtr, float body, float vz, bool sweptValid) =>
    float dS = math.min(1.0, dispAtr / 2.0)
    float bS = math.min(1.0, body / 0.8)
    float vS = math.min(1.0, math.max(0.0, (vz + 0.5) / 2.5))
    float swS = sweptValid ? 1.0 : 0.0
    float q = 0.34 * dS + 0.20 * bS + 0.20 * vS + 0.26 * swS
    math.round(q * 100.0)

// analog (KNN) memory bank: resolved zones with their at-tag context + outcome
var float[] bf1 = array.new_float(0)
var float[] bf2 = array.new_float(0)
var float[] bf3 = array.new_float(0)
var float[] bf4 = array.new_float(0)
var float[] bf5 = array.new_float(0)
var float[] bf6 = array.new_float(0)
var int[]   bOut = array.new_int(0)
var int[]   bDir = array.new_int(0)

// distance-weighted analog vote (robust log-distance metric) over same-direction memories
f_analog(float q1, float q2, float q3, float q4, float q5, float q6, int qDir) =>
    float wsum = 0.0
    float vsum = 0.0
    int n = 0
    int rows = array.size(bOut)
    if rows > 0
        for r = 0 to rows - 1
            if array.get(bDir, r) == qDir
                float d = math.log(1.0 + math.abs(q1 - array.get(bf1, r))) + math.log(1.0 + math.abs(q2 - array.get(bf2, r))) + math.log(1.0 + math.abs(q3 - array.get(bf3, r))) + math.log(1.0 + math.abs(q4 - array.get(bf4, r))) + math.log(1.0 + math.abs(q5 - array.get(bf5, r))) + math.log(1.0 + math.abs(q6 - array.get(bf6, r)))
                float w = 1.0 / (1.0 + d * d)
                wsum += w
                vsum += w * array.get(bOut, r)
                n += 1
    float p = (n >= 1 and wsum > 0) ? vsum / wsum : na
    [p, n]

// runs-test Z for win/loss serial dependence (streak check)
f_runsZ(int[] seq) =>
    float z = na
    int n = array.size(seq)
    if n >= 10
        int n1 = 0
        for k = 0 to n - 1
            n1 += array.get(seq, k)
        int n0 = n - n1
        if n1 > 0 and n0 > 0
            int runs = 1
            for k = 1 to n - 1
                if array.get(seq, k) != array.get(seq, k - 1)
                    runs += 1
            float expR = 1.0 + 2.0 * n1 * n0 / n
            float varR = 2.0 * n1 * n0 * (2.0 * n1 * n0 - n) / (float(n) * n * (n - 1))
            if varR > 0
                z := (runs - expR) / math.sqrt(varR)
    z

f_recentRate(int[] h, int wnd) =>
    float r = na
    int n = array.size(h)
    if n >= 5
        int take = math.min(wnd, n)
        int s = 0
        for k = n - take to n - 1
            s += array.get(h, k)
        r := s / float(take)
    r

// ───────────────────────────── THEME ───────────────────────────────────────
_luma = f_luma(chart.bg_color)
uiDark = themeMode == "Dark" ? true : themeMode == "Light" ? false : (na(chart.bg_color) or _luma < 140)
uiBull = bullCol
uiBear = bearCol
cPanel = uiDark ? color.rgb(10, 14, 26)   : color.rgb(244, 246, 248)
cSub   = uiDark ? color.rgb(22, 27, 34)   : color.rgb(233, 237, 242)
cTxt   = uiDark ? color.rgb(226, 232, 240): color.rgb(20, 26, 38)
cDim   = uiDark ? color.rgb(168, 178, 190): color.rgb(74, 82, 94)
cFrame = uiDark ? color.rgb(42, 52, 88)   : color.rgb(196, 204, 212)
cBord  = uiDark ? color.rgb(26, 34, 56)   : color.rgb(210, 216, 224)
uiAcc  = uiDark ? color.rgb(179, 157, 219): color.rgb(94, 53, 177)
uiGold = uiDark ? color.rgb(255, 196, 0)  : color.rgb(176, 120, 0)

// ───────────────────────────── VOLUME (with borrow) ────────────────────────
var bool nativeVolSeen = false
if volume > 0
    nativeVolSeen := true
useBorrow = str.length(volBorrowSym) > 0 and not nativeVolSeen
volBorrowRaw = request.security(volBorrowSym, timeframe.period, volume, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
volEff = useBorrow and not na(volBorrowRaw) ? volBorrowRaw : volume
bool volOk = not na(volEff) and volEff > 0

// ───────────────────────────── CORE SERIES ─────────────────────────────────
atr = ta.atr(14)
atrSafe = atr > 0 ? atr : close * 0.001
volSd = ta.stdev(volEff, 20)
volZ = volOk ? (volEff - ta.sma(volEff, 20)) / (volSd == 0 ? 1 : volSd) : 0.0
bodyRatio = (high - low) > 0 ? math.abs(close - open) / (high - low) : 0.0
cpUp = (high - low) > 0 ? (close - low) / (high - low) : 0.5
cpDn = (high - low) > 0 ? (high - close) / (high - low) : 0.5
trVal = ta.tr(true)
bool warmedUp = bar_index >= swingLen * 2 + 30

erNum = math.abs(close - close[erLen])
erDen = math.sum(math.abs(close - close[1]), erLen)
er = erDen > 0 ? erNum / erDen : 0.0
[diP, diM, adx] = ta.dmi(adxLen, adxLen)
logRet = math.abs(nz(ta.change(math.log(close))))
var float clustI = 0.0
clustI := clustI * math.exp(-0.20) + logRet
hMean = ta.sma(clustI, 100)
hStd  = ta.stdev(clustI, 100)
clustZ = hStd != 0 ? (clustI - hMean) / hStd : 0.0
volCluster = clustZ > clustThr
trendMa = ta.ema(close, 50)
trending = adx > adxTrend and er > erTrend
string regime = volCluster and not trending ? "Volatile" : trending ? (close > trendMa ? "Trend Up" : "Trend Dn") : "Range"
bool regTrend = trending and not volCluster

var int regCode = 0
regCode := regime == "Trend Up" ? 2 : regime == "Trend Dn" ? -2 : regime == "Volatile" ? 1 : 0
float thrash = 0.0
for k = 0 to 9
    thrash += nz(regCode[k], 0) != nz(regCode[k + 1], 0) ? math.pow(0.85, k) : 0.0
float thrashScore = math.min(1.0, thrash / 4.0)

erShortNet = math.abs(close - close[10])
erShortPath = math.sum(math.abs(close - close[1]), 10)
erShortV = erShortPath > 0 ? erShortNet / erShortPath : 0.0
erLongNet = math.abs(close - close[30])
erLongPath = math.sum(math.abs(close - close[1]), 30)
erLongV = erLongPath > 0 ? erLongNet / erLongPath : 0.0
coilWasLow = nz(erLongV[5], 1.0) <= 0.30
coilRising = erShortV > nz(erShortV[3], 0.0)
coilRelease = coilWasLow and coilRising
float dispRank = ta.percentrank(trVal / atrSafe, 150)
bool dispThresh = useAdaptDisp ? (not na(dispRank) and dispRank >= dispPctMin) : (trVal >= dispAtrMin * atrSafe)
bool dispOK = (dispThresh and bodyRatio >= 0.5) or coilRelease

// ───────────────────────────── PIVOTS ──────────────────────────────────────
phS = ta.pivothigh(srcHigh, swingLen, swingLen)
plS = ta.pivotlow(srcLow,  swingLen, swingLen)
phI = ta.pivothigh(srcHigh, intlLen, intlLen)
plI = ta.pivotlow(srcLow,  intlLen, intlLen)

var float lastPH = na
var float prevPH = na
var int   lastPHbar = na
var float lastPL = na
var float prevPL = na
var int   lastPLbar = na
if not na(phS)
    prevPH := lastPH
    lastPH := phS
    lastPHbar := bar_index - swingLen
if not na(plS)
    prevPL := lastPL
    lastPL := plS
    lastPLbar := bar_index - swingLen

float pqH = f_pivQ(lastPH, prevPH, lastPHbar, close)
float pqL = f_pivQ(lastPL, prevPL, lastPLbar, close)

// protected swings (anti-flip): the high to break for a bullish CHoCH is the
// swing high that launched the last lower-low; symmetric for the downside.
var float protHi = na
var float protLo = na
if not na(plS) and not na(prevPL) and plS < prevPL
    protHi := lastPH
if not na(phS) and not na(prevPH) and phS > prevPH
    protLo := lastPL

// self-calibrating retracement-depth distribution (for adaptive OTE)
var float[] retArr = array.new_float(0)
if not na(plS) and not na(prevPL) and not na(lastPH) and plS > prevPL and (lastPH - plS) > 0 and (lastPH - prevPL) > 0
    array.push(retArr, math.max(0.2, math.min(0.9, (lastPH - plS) / (lastPH - prevPL))))
    if array.size(retArr) > 60
        array.shift(retArr)
if not na(phS) and not na(prevPH) and not na(lastPL) and phS < prevPH and (phS - lastPL) > 0 and (prevPH - lastPL) > 0
    array.push(retArr, math.max(0.2, math.min(0.9, (phS - lastPL) / (prevPH - lastPL))))
    if array.size(retArr) > 60
        array.shift(retArr)
float oteCenter = (useAdaptOTE and array.size(retArr) >= 8) ? array.median(retArr) : 0.705

// ───────────────────────────── LIQUIDITY (EQH / EQL + sweeps + inducement) ──
float eqDist = eqTol * atrSafe
bool eqhFormed = not na(phS) and not na(prevPH) and math.abs(lastPH - prevPH) <= eqDist
bool eqlFormed = not na(plS) and not na(prevPL) and math.abs(lastPL - prevPL) <= eqDist
var float eqhLevel = na
var int   eqhBar = na
var float eqlLevel = na
var int   eqlBar = na
if eqhFormed
    eqhLevel := math.max(lastPH, prevPH)
    eqhBar := bar_index
if eqlFormed
    eqlLevel := math.min(lastPL, prevPL)
    eqlBar := bar_index

bool sweepHigh = showSweep and ((not na(eqhLevel) and high > eqhLevel and srcClose < eqhLevel) or (not na(lastPH) and high > lastPH and srcClose < lastPH and close < open))
bool sweepLow  = showSweep and ((not na(eqlLevel) and low  < eqlLevel and srcClose > eqlLevel) or (not na(lastPL) and low  < lastPL and srcClose > lastPL and close > open))
var int lastSweepUpBar = na
var int lastSweepDnBar = na
if sweepLow
    lastSweepUpBar := bar_index
if sweepHigh
    lastSweepDnBar := bar_index

bool inducementUp = useInducement and sweepLow and not na(lastSweepDnBar) and (bar_index - lastSweepDnBar) <= 8
bool inducementDn = useInducement and sweepHigh and not na(lastSweepUpBar) and (bar_index - lastSweepUpBar) <= 8

// ───────────────────────────── MARKET STRUCTURE ────────────────────────────
var float structHi = na
var int   structHiBar = na
var float structLo = na
var int   structLoBar = na
var int   bias = 0
if not na(phS)
    structHi := phS
    structHiBar := bar_index - swingLen
if not na(plS)
    structLo := plS
    structLoBar := bar_index - swingLen

bool wickUpOK = (not useAntiWick) or cpUp >= antiWickPos
bool wickDnOK = (not useAntiWick) or cpDn >= antiWickPos
bool dispGate = (not useDisplacement) or dispOK
bool pqUpGate = (not usePivotQuality) or pqH >= minPivQ
bool pqDnGate = (not usePivotQuality) or pqL >= minPivQ

bool rawBrokeUp = not na(structHi) and srcClose > structHi and nz(srcClose[1], srcClose) <= structHi
bool rawBrokeDn = not na(structLo) and srcClose < structLo and nz(srcClose[1], srcClose) >= structLo
bool brokeUp = rawBrokeUp and dispGate and wickUpOK and pqUpGate
bool brokeDn = rawBrokeDn and dispGate and wickDnOK and pqDnGate

int  structEvent = 0
bool bosUp = false
bool chochUp = false
bool bosDn = false
bool chochDn = false
if brokeUp
    bool isChoch = bias == -1
    bool chochOK = (not useProtSwing) or na(protHi) or srcClose > protHi
    if (not isChoch) or chochOK
        chochUp := isChoch
        bosUp   := bias >= 0
        structEvent := chochUp ? 1 : 2
        bias := 1
if brokeDn
    bool isChoch = bias == 1
    bool chochOK = (not useProtSwing) or na(protLo) or srcClose < protLo
    if (not isChoch) or chochOK
        chochDn := isChoch
        bosDn   := bias <= 0
        structEvent := chochDn ? -1 : -2
        bias := -1

var float iHi = na
var float iLo = na
var int   iBias = 0
if not na(phI)
    iHi := phI
if not na(plI)
    iLo := plI
bool iBrokeUp = showIntl and not na(iHi) and srcClose > iHi and nz(srcClose[1], srcClose) <= iHi
bool iBrokeDn = showIntl and not na(iLo) and srcClose < iLo and nz(srcClose[1], srcClose) >= iLo
bool iChochUp = false
bool iChochDn = false
if iBrokeUp
    iChochUp := nz(iBias[1], 0) == -1
    iBias := 1
if iBrokeDn
    iChochDn := nz(iBias[1], 0) == 1
    iBias := -1

// ───────────────────────────── VOLUME PROFILE (computed once) ───────────────
var float vpPOC = na
var float vpHVNthr = na
var float vpLVNthr = na
var float vpHi = na
var float vpLo = na
var float vpStep = na
var float[] vpBinsArr = array.new_float(0)
if useVP and barstate.islast and volOk
    int win = math.min(vpWindow, bar_index)
    float wHi = high
    float wLo = low
    for b = 0 to win
        wHi := math.max(wHi, high[b])
        wLo := math.min(wLo, low[b])
    float step = (wHi - wLo) / vpBins
    if step > 0
        array.clear(vpBinsArr)
        for i = 0 to vpBins - 1
            array.push(vpBinsArr, 0.0)
        for b = 0 to win
            int bi = math.max(0, math.min(vpBins - 1, int(((high[b] + low[b] + close[b]) / 3.0 - wLo) / step)))
            array.set(vpBinsArr, bi, array.get(vpBinsArr, bi) + nz(volEff[b], 0.0))
        int pocBin = array.indexof(vpBinsArr, array.max(vpBinsArr))
        vpHi := wHi
        vpLo := wLo
        vpStep := step
        vpPOC := wLo + (pocBin + 0.5) * step
        float[] nzB = array.new_float(0)
        for i = 0 to vpBins - 1
            if array.get(vpBinsArr, i) > 0
                array.push(nzB, array.get(vpBinsArr, i))
        vpHVNthr := array.size(nzB) >= 5 ? array.percentile_linear_interpolation(nzB, hvnPct) : array.avg(vpBinsArr) * 1.4
        vpLVNthr := array.size(nzB) >= 5 ? array.percentile_linear_interpolation(nzB, lvnPct) : array.avg(vpBinsArr) * 0.5

// naked POC magnets (session-based; degrades off when not intraday)
bool sessionOpen = ta.change(time("D")) != 0
var float[] nakedPx  = array.new_float(0)
var int[]   nakedBar = array.new_int(0)
var float sessPOC = na
var float sBinLo = na
var float sBinStep = na
var float[] sBins = array.new_float(0)
if sessionOpen and useNakedPOC and volOk
    if not na(sessPOC)
        bool straddled = false
        int lk = math.min(120, bar_index)
        for k = 1 to lk
            if low[k] <= sessPOC and high[k] >= sessPOC
                straddled := true
                break
        if not straddled and sessPOC > 0
            array.push(nakedPx, sessPOC)
            array.push(nakedBar, bar_index)
            while array.size(nakedPx) > nakedMax
                array.shift(nakedPx)
                array.shift(nakedBar)
    array.clear(sBins)
    for i = 0 to 39
        array.push(sBins, 0.0)
    sBinLo := close - 10 * atrSafe
    sBinStep := (20 * atrSafe) / 40
    sessPOC := na
if useNakedPOC and volOk and not na(sBinStep) and sBinStep > 0 and array.size(sBins) == 40
    int bi = math.max(0, math.min(39, int(((high + low + close) / 3.0 - sBinLo) / sBinStep)))
    array.set(sBins, bi, array.get(sBins, bi) + nz(volEff, 0.0))
    int pb = array.indexof(sBins, array.max(sBins))
    sessPOC := sBinLo + (pb + 0.5) * sBinStep
if useNakedPOC and array.size(nakedPx) > 0
    int idx = array.size(nakedPx) - 1
    while idx >= 0
        float npv = array.get(nakedPx, idx)
        bool crossed = not na(npv) and low <= npv and high >= npv
        bool aged = bar_index - array.get(nakedBar, idx) > 3000
        if crossed or aged
            array.remove(nakedPx, idx)
            array.remove(nakedBar, idx)
        idx -= 1
float nakedAbove = na
float nakedBelow = na
if useNakedPOC and array.size(nakedPx) > 0
    float bestA = 1e20
    float bestB = 1e20
    for k = 0 to array.size(nakedPx) - 1
        float v = array.get(nakedPx, k)
        if v > close and (v - close) < bestA
            bestA := v - close
            nakedAbove := v
        if v < close and (close - v) < bestB
            bestB := close - v
            nakedBelow := v

// ───────────────────────────── ORDER BLOCK STORES ──────────────────────────
var box[]   obBox  = array.new<box>()
var float[] obTop  = array.new<float>()
var float[] obBot  = array.new<float>()
var bool[]  obBull = array.new<bool>()
var float[] obQual = array.new<float>()
var bool[]  obTagged = array.new<bool>()
var label[] obLab  = array.new<label>()
var int[]   obBar  = array.new<int>()

float impulseUp = not na(structHi) ? (srcClose - structHi) / atrSafe : 0.0
float impulseDn = not na(structLo) ? (structLo - srcClose) / atrSafe : 0.0
if showOB and (bosUp or chochUp or bosDn or chochDn)
    bool obIsBull = bosUp or chochUp
    float impAtr = obIsBull ? math.max(impulseUp, 0.0) : math.max(impulseDn, 0.0)
    int found = -1
    for k = 1 to obScan
        bool opp = obIsBull ? (close[k] < open[k]) : (close[k] > open[k])
        if opp
            found := k
            break
    if found >= 0
        float ctop = obUseBody ? math.max(open[found], close[found]) : high[found]
        float cbot = obUseBody ? math.min(open[found], close[found]) : low[found]
        bool swept = obIsBull ? (not na(lastSweepUpBar) and bar_index - lastSweepUpBar <= 6) : (not na(lastSweepDnBar) and bar_index - lastSweepDnBar <= 6)
        float q = f_quality(impAtr, bodyRatio[found], nz(volZ[found], 0.0), swept)
        if q >= obMinQual
            color bc = obIsBull ? uiBull : uiBear
            bool merged = false
            if useMerge and array.size(obBox) > 0
                for mi = 0 to array.size(obBox) - 1
                    if array.get(obBull, mi) == obIsBull and ctop >= array.get(obBot, mi) and cbot <= array.get(obTop, mi)
                        float nt = math.max(array.get(obTop, mi), ctop)
                        float nb = math.min(array.get(obBot, mi), cbot)
                        array.set(obTop, mi, nt)
                        array.set(obBot, mi, nb)
                        array.set(obQual, mi, math.max(array.get(obQual, mi), q))
                        array.set(obBar, mi, bar_index)
                        box.set_top(array.get(obBox, mi), nt)
                        box.set_bottom(array.get(obBox, mi), nb)
                        merged := true
                        break
            if not merged
                box bx = box.new(bar_index - found, ctop, bar_index + extendBars, cbot, border_color = color.new(bc, 20), bgcolor = color.new(bc, 66), border_width = 1)
                label lb = label.new(bar_index + extendBars, (ctop + cbot) / 2.0, "", xloc = xloc.bar_index, style = label.style_label_left, size = size.tiny, textcolor = color.white, color = color.new(bc, 20))
                array.push(obBox, bx)
                array.push(obTop, ctop)
                array.push(obBot, cbot)
                array.push(obBull, obIsBull)
                array.push(obQual, q)
                array.push(obTagged, false)
                array.push(obLab, lb)
                array.push(obBar, bar_index)
                while array.size(obBox) > maxOB
                    int worst = 0
                    float worstQ = 1e9
                    for pi = 0 to array.size(obBox) - 1
                        if array.get(obQual, pi) < worstQ
                            worstQ := array.get(obQual, pi)
                            worst := pi
                    box.delete(array.get(obBox, worst))
                    label.delete(array.get(obLab, worst))
                    array.remove(obBox, worst)
                    array.remove(obLab, worst)
                    array.remove(obTop, worst)
                    array.remove(obBot, worst)
                    array.remove(obBull, worst)
                    array.remove(obQual, worst)
                    array.remove(obTagged, worst)
                    array.remove(obBar, worst)

// ───────────────────────────── FVG STORES ──────────────────────────────────
var box[]   fvBox  = array.new<box>()
var float[] fvTop  = array.new<float>()
var float[] fvBot  = array.new<float>()
var bool[]  fvBull = array.new<bool>()
var float[] fvQual = array.new<float>()
var bool[]  fvTagged = array.new<bool>()

bool bullFVG = showFVG and barstate.isconfirmed and low > high[2] and (low - high[2]) >= fvgMinAtr * atrSafe
bool bearFVG = showFVG and barstate.isconfirmed and high < low[2] and (low[2] - high) >= fvgMinAtr * atrSafe
if bullFVG or bearFVG
    bool fvIsBull = bullFVG
    float ftop = fvIsBull ? low : low[2]
    float fbot = fvIsBull ? high[2] : high
    bool fswept = fvIsBull ? (not na(lastSweepUpBar) and bar_index - lastSweepUpBar <= 6) : (not na(lastSweepDnBar) and bar_index - lastSweepDnBar <= 6)
    float fq = f_quality((ftop - fbot) / atrSafe, bodyRatio[1], nz(volZ[1], 0.0), fswept)
    color fbc = fvIsBull ? uiBull : uiBear
    box fbx = box.new(bar_index - 2, ftop, bar_index + extendBars, fbot, border_color = color.new(fbc, 40), bgcolor = color.new(fbc, 72), border_width = 1)
    array.push(fvBox, fbx)
    array.push(fvTop, ftop)
    array.push(fvBot, fbot)
    array.push(fvBull, fvIsBull)
    array.push(fvQual, fq)
    array.push(fvTagged, false)
    while array.size(fvBox) > maxFVG
        box.delete(array.shift(fvBox))
        array.shift(fvTop)
        array.shift(fvBot)
        array.shift(fvBull)
        array.shift(fvQual)
        array.shift(fvTagged)

// ───────────────────────────── CALIBRATION ─────────────────────────────────
var int[]   calTot = array.new_int(2, 0)
var int[]   calHit = array.new_int(2, 0)
var int[]   pBar = array.new_int(0)
var float[] pRef = array.new_float(0)
var int[]   pDir = array.new_int(0)
var int[]   pTyp = array.new_int(0)
var float[] pAtr0 = array.new_float(0)
var float[] pMaxFav = array.new_float(0)
var float[] pf1 = array.new_float(0)
var float[] pf2 = array.new_float(0)
var float[] pf3 = array.new_float(0)
var float[] pf4 = array.new_float(0)
var float[] pf5 = array.new_float(0)
var float[] pf6 = array.new_float(0)
var float[] calReactSum = array.new_float(2, 0.0)
var int[]   calReactN = array.new_int(2, 0)
var int[]   outHistOB = array.new_int(0)
var int[]   outHistFV = array.new_int(0)

if array.size(obBox) > 0
    int i = 0
    while i < array.size(obBox)
        bool isBull = array.get(obBull, i)
        float t = array.get(obTop, i)
        float b = array.get(obBot, i)
        bool inside = low <= t and high >= b
        if inside and not array.get(obTagged, i)
            array.set(obTagged, i, true)
            if calEnable
                int dd = isBull ? 1 : -1
                array.push(pBar, bar_index)
                array.push(pRef, (t + b) / 2.0)
                array.push(pDir, dd)
                array.push(pTyp, 0)
                array.push(pAtr0, atrSafe)
                array.push(pMaxFav, 0.0)
                array.push(pf1, array.get(obQual, i) / 100.0)
                array.push(pf2, dd > 0 ? (bias >= 0 ? 1.0 : 0.0) : (bias <= 0 ? 1.0 : 0.0))
                array.push(pf3, (nz(regCode, 0) + 2.0) / 4.0)
                array.push(pf4, math.max(0.0, math.min(1.0, er)))
                array.push(pf5, thrashScore)
                array.push(pf6, math.max(0.0, math.min(1.0, (nz(volZ, 0.0) + 3.0) / 6.0)))
        bool broken = isBull ? close < b : close > t
        if broken
            box.delete(array.get(obBox, i))
            label.delete(array.get(obLab, i))
            array.remove(obBox, i)
            array.remove(obLab, i)
            array.remove(obTop, i)
            array.remove(obBot, i)
            array.remove(obBull, i)
            array.remove(obQual, i)
            array.remove(obTagged, i)
            array.remove(obBar, i)
        else
            i += 1

if array.size(fvBox) > 0
    int i = 0
    while i < array.size(fvBox)
        bool isBull = array.get(fvBull, i)
        float t = array.get(fvTop, i)
        float b = array.get(fvBot, i)
        bool inside = low <= t and high >= b
        float mid = (t + b) / 2.0
        if inside and not array.get(fvTagged, i)
            array.set(fvTagged, i, true)
            if calEnable
                int dd = isBull ? 1 : -1
                array.push(pBar, bar_index)
                array.push(pRef, mid)
                array.push(pDir, dd)
                array.push(pTyp, 1)
                array.push(pAtr0, atrSafe)
                array.push(pMaxFav, 0.0)
                array.push(pf1, array.get(fvQual, i) / 100.0)
                array.push(pf2, dd > 0 ? (bias >= 0 ? 1.0 : 0.0) : (bias <= 0 ? 1.0 : 0.0))
                array.push(pf3, (nz(regCode, 0) + 2.0) / 4.0)
                array.push(pf4, math.max(0.0, math.min(1.0, er)))
                array.push(pf5, thrashScore)
                array.push(pf6, math.max(0.0, math.min(1.0, (nz(volZ, 0.0) + 3.0) / 6.0)))
        bool filled = fvgFillRule == "Touch" ? inside : fvgFillRule == "Midpoint" ? (isBull ? low <= mid : high >= mid) : (isBull ? low <= b : high >= t)
        if filled
            box.delete(array.get(fvBox, i))
            array.remove(fvBox, i)
            array.remove(fvTop, i)
            array.remove(fvBot, i)
            array.remove(fvBull, i)
            array.remove(fvQual, i)
            array.remove(fvTagged, i)
        else
            i += 1

if calEnable and useReaction and array.size(pBar) > 0
    for j = 0 to array.size(pBar) - 1
        float rf = array.get(pRef, j)
        int dj = array.get(pDir, j)
        float fav = dj > 0 ? (high - rf) : (rf - low)
        if fav > array.get(pMaxFav, j)
            array.set(pMaxFav, j, fav)

if calEnable and array.size(pBar) > 0
    int idx = 0
    while idx < array.size(pBar)
        if bar_index - array.get(pBar, idx) >= calHorizon
            float p0 = array.get(pRef, idx)
            int   dr = array.get(pDir, idx)
            int   ty = array.get(pTyp, idx)
            float mv = close - p0
            bool hit = dr == 1 ? mv >= calMoveATR * atrSafe : mv <= -calMoveATR * atrSafe
            array.set(calTot, ty, array.get(calTot, ty) + 1)
            if hit
                array.set(calHit, ty, array.get(calHit, ty) + 1)
            float a0 = array.get(pAtr0, idx)
            float react = a0 > 0 ? array.get(pMaxFav, idx) / a0 : na
            if not na(react)
                array.set(calReactSum, ty, array.get(calReactSum, ty) + react)
                array.set(calReactN, ty, array.get(calReactN, ty) + 1)
            array.push(bf1, array.get(pf1, idx))
            array.push(bf2, array.get(pf2, idx))
            array.push(bf3, array.get(pf3, idx))
            array.push(bf4, array.get(pf4, idx))
            array.push(bf5, array.get(pf5, idx))
            array.push(bf6, array.get(pf6, idx))
            array.push(bOut, hit ? 1 : 0)
            array.push(bDir, dr)
            while array.size(bOut) > knnBank
                array.shift(bf1)
                array.shift(bf2)
                array.shift(bf3)
                array.shift(bf4)
                array.shift(bf5)
                array.shift(bf6)
                array.shift(bOut)
                array.shift(bDir)
            if ty == 0
                array.push(outHistOB, hit ? 1 : 0)
                if array.size(outHistOB) > 80
                    array.shift(outHistOB)
            else
                array.push(outHistFV, hit ? 1 : 0)
                if array.size(outHistFV) > 80
                    array.shift(outHistFV)
            array.remove(pBar, idx)
            array.remove(pRef, idx)
            array.remove(pDir, idx)
            array.remove(pTyp, idx)
            array.remove(pAtr0, idx)
            array.remove(pMaxFav, idx)
            array.remove(pf1, idx)
            array.remove(pf2, idx)
            array.remove(pf3, idx)
            array.remove(pf4, idx)
            array.remove(pf5, idx)
            array.remove(pf6, idx)
        else
            idx += 1
    while array.size(pBar) > 400
        array.shift(pBar)
        array.shift(pRef)
        array.shift(pDir)
        array.shift(pTyp)
        array.shift(pAtr0)
        array.shift(pMaxFav)
        array.shift(pf1)
        array.shift(pf2)
        array.shift(pf3)
        array.shift(pf4)
        array.shift(pf5)
        array.shift(pf6)

// ───────────────────────────── PREMIUM / DISCOUNT / OTE ────────────────────
float rangeHi = structHi
float rangeLo = structLo
float eqm = (not na(rangeHi) and not na(rangeLo)) ? (rangeHi + rangeLo) / 2.0 : na
float pdPos = (not na(eqm) and (rangeHi - rangeLo) != 0) ? (srcClose - rangeLo) / (rangeHi - rangeLo) : na
string pdZone = na(pdPos) ? "-" : pdPos > 0.62 ? "Premium" : pdPos < 0.38 ? "Discount" : "Equilibrium"
float oteShallow = oteCenter - 0.085
float oteDeep    = oteCenter + 0.085
float ote62 = (not na(rangeHi) and not na(rangeLo)) ? rangeLo + (1.0 - oteShallow) * (rangeHi - rangeLo) : na
float ote70 = (not na(rangeHi) and not na(rangeLo)) ? rangeLo + (1.0 - oteCenter)  * (rangeHi - rangeLo) : na
float ote79 = (not na(rangeHi) and not na(rangeLo)) ? rangeLo + (1.0 - oteDeep)    * (rangeHi - rangeLo) : na

// ───────────────────────────── HTF BIAS ────────────────────────────────────
htfStr = f_tfstr(htfMult)
f_htfStruct() =>
    [ta.pivothigh(srcHigh, 5, 5), ta.pivotlow(srcLow, 5, 5)]
[htfPH, htfPL] = request.security(syminfo.tickerid, htfStr, f_htfStruct(), lookahead = barmerge.lookahead_off)
var float htfHi = na
var float htfLo = na
var int   htfBias = 0
if not na(htfPH)
    htfHi := htfPH
if not na(htfPL)
    htfLo := htfPL
if useHTF and not na(htfHi) and close > htfHi
    htfBias := 1
if useHTF and not na(htfLo) and close < htfLo
    htfBias := -1

// ───────────────────────────── DIVERGENCE / EXHAUSTION ─────────────────────
rsi = ta.rsi(close, 14)
phP = ta.pivothigh(high, 5, 5)
plP = ta.pivotlow(low, 5, 5)
phR = ta.pivothigh(rsi, 5, 5)
plR = ta.pivotlow(rsi, 5, 5)
var float lphP = na
var float pphP = na
var float lplP = na
var float pplP = na
var float lphR = na
var float pphR = na
var float lplR = na
var float pplR = na
if not na(phP)
    pphP := lphP
    lphP := phP
if not na(plP)
    pplP := lplP
    lplP := plP
if not na(phR)
    pphR := lphR
    lphR := phR
if not na(plR)
    pplR := lplR
    lplR := plR
bool bearDiv = useDiv and not na(lphP) and not na(pphP) and not na(lphR) and not na(pphR) and lphP > pphP and lphR < pphR
bool bullDiv = useDiv and not na(lplP) and not na(pplP) and not na(lplR) and not na(pplR) and lplP < pplP and lplR > pplR
bool exhaustHigh = useDiv and rsi >= 70
bool exhaustLow  = useDiv and rsi <= 30
bool revConfirmUp = bullDiv or exhaustLow
bool revConfirmDn = bearDiv or exhaustHigh

// ───────────────────────────── OU HALF-LIFE (to equilibrium) ───────────────
float spr = (useHalfLife and not na(eqm)) ? (close - eqm) : 0.0
float spr1 = nz(spr[1], spr)
float mS = ta.sma(spr, hlLen)
float mS1 = ta.sma(spr1, hlLen)
float covS = ta.sma(spr * spr1, hlLen) - mS * mS1
float varS1 = ta.sma(spr1 * spr1, hlLen) - mS1 * mS1
float betaAR = varS1 > 0 ? covS / varS1 : na
float halfLife = (useHalfLife and not na(betaAR) and betaAR > 0 and betaAR < 1) ? -math.log(2) / math.log(betaAR) : na

// ───────────────────────────── CONFLUENCE + SETUP GRADE ────────────────────
var string setupTxt = "-"
var float  setupScore = 0.0
var int    setupDir = 0
var float  setupProb = na
var float  setupTop = na
var float  setupBot = na

if barstate.islast
    float[] refs = array.new_float(0)
    if not na(vpPOC)
        array.push(refs, vpPOC)
    if not na(nakedAbove)
        array.push(refs, nakedAbove)
    if not na(nakedBelow)
        array.push(refs, nakedBelow)
    if not na(eqhLevel)
        array.push(refs, eqhLevel)
    if not na(eqlLevel)
        array.push(refs, eqlLevel)
    if not na(eqm)
        array.push(refs, eqm)
    if not na(structHi)
        array.push(refs, structHi)
    if not na(structLo)
        array.push(refs, structLo)
    float tol = clusterTol * atrSafe

    float bestScore = 0.0
    int   bestDir = 0
    float bestProb = na
    float bestTop = na
    float bestBot = na
    if array.size(obBox) > 0
        for i = 0 to array.size(obBox) - 1
            bool isBull = array.get(obBull, i)
            float t = array.get(obTop, i)
            float b = array.get(obBot, i)
            float mid = (t + b) / 2.0
            float baseQ = array.get(obQual, i)
            int conf = 0
            if array.size(refs) > 0
                for r = 0 to array.size(refs) - 1
                    if math.abs(array.get(refs, r) - mid) <= tol
                        conf += 1
            string ntag = useVP ? f_nodeTag(mid, vpHi, vpLo, vpStep, vpBinsArr, vpHVNthr, vpLVNthr) : "mid"
            bool pdAlign = isBull ? (not na(pdPos) and pdPos < 0.5) : (not na(pdPos) and pdPos > 0.5)
            bool htfAlign = isBull ? htfBias >= 0 : htfBias <= 0
            bool structAlign = isBull ? bias >= 0 : bias <= 0
            bool rev = isBull ? revConfirmUp : revConfirmDn
            float score = baseQ * 0.5
            score += conf * 7.0
            score += ntag == "HVN" ? 10.0 : ntag == "LVN" ? -6.0 : 0.0
            score += pdAlign ? 10.0 : 0.0
            score += htfAlign ? 8.0 : -4.0
            score += structAlign ? 6.0 : -4.0
            score += rev ? 6.0 : 0.0
            score += (useRegime and regTrend and structAlign) ? 4.0 : 0.0
            score += (useRegime and volCluster) ? -6.0 : 0.0
            float scoreBase = math.max(0.0, math.min(100.0, score))
            if useDecay
                float age = bar_index - array.get(obBar, i)
                score -= math.min(18.0, math.max(0.0, age) / decayBars * 18.0)
                score -= array.get(obTagged, i) ? 8.0 : 0.0
            score := math.max(0.0, math.min(100.0, score))
            float zProb = na
            int   zN = 0
            if useKNN
                [pp, nn] = f_analog(baseQ / 100.0, isBull ? (bias >= 0 ? 1.0 : 0.0) : (bias <= 0 ? 1.0 : 0.0), (nz(regCode, 0) + 2.0) / 4.0, math.max(0.0, math.min(1.0, er)), thrashScore, math.max(0.0, math.min(1.0, (nz(volZ, 0.0) + 3.0) / 6.0)), isBull ? 1 : -1)
                zProb := pp
                zN := nn
                if not na(zProb) and zN >= knnMin
                    score := math.max(0.0, math.min(100.0, score + (zProb - 0.5) * 24.0))
            color bc = isBull ? uiBull : uiBear
            string gl = f_gradeLetter(scoreBase)
            int op = gradedOpacity ? (score >= 80 ? 55 : score >= 68 ? 63 : score >= 55 ? 72 : 82) : 66
            if fadeMitigated and array.get(obTagged, i)
                op := math.min(92, op + 14)
            box.set_bgcolor(array.get(obBox, i), color.new(bc, op))
            box.set_border_color(array.get(obBox, i), color.new(bc, (gradedOpacity and score >= 68) ? 10 : 30))
            label.set_xy(array.get(obLab, i), bar_index + extendBars, mid)
            label.set_text(array.get(obLab, i), (gl == "-" ? "" : gl + " ") + str.tostring(math.round(scoreBase)) + (ntag == "HVN" ? " HVN" : ntag == "LVN" ? " LVN" : "") + (conf >= 2 ? " x" + str.tostring(conf) : "") + (useKNN and not na(zProb) and zN >= knnMin ? " p" + str.tostring(math.round(zProb * 100)) : ""))
            label.set_color(array.get(obLab, i), color.new(bc, scoreBase >= 68 ? 10 : 35))
            if useGrade and not array.get(obTagged, i) and structAlign and pdAlign and score > bestScore
                bestScore := score
                bestDir := isBull ? 1 : -1
                bestProb := zProb
                bestTop := t
                bestBot := b

    setupScore := bestScore
    setupDir := bestDir
    setupProb := bestProb
    setupTop := bestTop
    setupBot := bestBot
    setupTxt := bestDir == 0 ? "-" : (bestDir > 0 ? "LONG " : "SHORT ") + f_gradeLetter(bestScore) + " " + str.tostring(math.round(bestScore))

// ───────────────────────────── DRAW: labels, liquidity, P/D, OTE ───────────
var line[]  L  = array.new<line>()
var label[] LB = array.new<label>()
var box[]   PD = array.new<box>()

if showBOS and (bosUp or chochUp) and barstate.isconfirmed
    label.new(bar_index, structHi, chochUp ? "CHoCH" : "BOS", xloc = xloc.bar_index, style = label.style_label_down, color = color.new(uiBull, 15), textcolor = color.white, size = size.tiny)
if showBOS and (bosDn or chochDn) and barstate.isconfirmed
    label.new(bar_index, structLo, chochDn ? "CHoCH" : "BOS", xloc = xloc.bar_index, style = label.style_label_up, color = color.new(uiBear, 15), textcolor = color.white, size = size.tiny)
if showBOS and showIntl and iChochUp and barstate.isconfirmed
    label.new(bar_index, low, "i", xloc = xloc.bar_index, style = label.style_label_up, color = color.new(uiBull, 45), textcolor = color.white, size = size.tiny)
if showBOS and showIntl and iChochDn and barstate.isconfirmed
    label.new(bar_index, high, "i", xloc = xloc.bar_index, style = label.style_label_down, color = color.new(uiBear, 45), textcolor = color.white, size = size.tiny)
if showSweep and sweepHigh and barstate.isconfirmed
    label.new(bar_index, high, inducementDn ? "x ind" : "x", xloc = xloc.bar_index, style = label.style_label_down, color = color.new(uiBear, 25), textcolor = color.white, size = size.tiny, tooltip = "Sell-side liquidity sweep")
if showSweep and sweepLow and barstate.isconfirmed
    label.new(bar_index, low, inducementUp ? "x ind" : "x", xloc = xloc.bar_index, style = label.style_label_up, color = color.new(uiBull, 25), textcolor = color.white, size = size.tiny, tooltip = "Buy-side liquidity sweep")

if barstate.islast
    for x in L
        line.delete(x)
    array.clear(L)
    for x in LB
        label.delete(x)
    array.clear(LB)
    for x in PD
        box.delete(x)
    array.clear(PD)

    int rightX = bar_index + extendBars
    if array.size(obBox) > 0
        for i = 0 to array.size(obBox) - 1
            box.set_right(array.get(obBox, i), rightX)
    if array.size(fvBox) > 0
        for i = 0 to array.size(fvBox) - 1
            box.set_right(array.get(fvBox, i), rightX)

    if showLiq and not na(eqhLevel)
        array.push(L, line.new(nz(eqhBar, bar_index), eqhLevel, rightX, eqhLevel, xloc = xloc.bar_index, color = color.new(uiBear, 12), style = line.style_dashed, width = 1))
        array.push(LB, label.new(rightX, eqhLevel, "BSL", xloc = xloc.bar_index, style = label.style_label_left, size = size.tiny, textcolor = uiBear, color = color.new(cPanel, 30)))
    if showLiq and not na(eqlLevel)
        array.push(L, line.new(nz(eqlBar, bar_index), eqlLevel, rightX, eqlLevel, xloc = xloc.bar_index, color = color.new(uiBull, 12), style = line.style_dashed, width = 1))
        array.push(LB, label.new(rightX, eqlLevel, "SSL", xloc = xloc.bar_index, style = label.style_label_left, size = size.tiny, textcolor = uiBull, color = color.new(cPanel, 30)))
    if useNakedPOC and not na(nakedAbove)
        array.push(L, line.new(bar_index - 50, nakedAbove, rightX, nakedAbove, xloc = xloc.bar_index, color = color.new(uiGold, 25), style = line.style_dotted, width = 1))
        array.push(LB, label.new(rightX, nakedAbove, "nPOC", xloc = xloc.bar_index, style = label.style_label_left, size = size.tiny, textcolor = uiGold, color = color.new(cPanel, 40)))
    if useNakedPOC and not na(nakedBelow)
        array.push(L, line.new(bar_index - 50, nakedBelow, rightX, nakedBelow, xloc = xloc.bar_index, color = color.new(uiGold, 25), style = line.style_dotted, width = 1))
        array.push(LB, label.new(rightX, nakedBelow, "nPOC", xloc = xloc.bar_index, style = label.style_label_left, size = size.tiny, textcolor = uiGold, color = color.new(cPanel, 40)))

    if showPD and not na(rangeHi) and not na(rangeLo) and not na(eqm)
        int pdLeft = math.min(nz(structHiBar, bar_index), nz(structLoBar, bar_index))
        array.push(PD, box.new(pdLeft, rangeHi, rightX, eqm, border_color = color.new(uiBear, 55), bgcolor = color.new(uiBear, pdOpacity)))
        array.push(PD, box.new(pdLeft, eqm, rightX, rangeLo, border_color = color.new(uiBull, 55), bgcolor = color.new(uiBull, pdOpacity)))
        array.push(L, line.new(pdLeft, eqm, rightX, eqm, xloc = xloc.bar_index, color = color.new(uiAcc, 12), style = line.style_dotted, width = 1))
        array.push(LB, label.new(rightX, eqm, "EQ", xloc = xloc.bar_index, style = label.style_label_left, size = size.tiny, textcolor = uiAcc, color = color.new(cPanel, 30)))
        if showOTE
            array.push(L, line.new(pdLeft, ote62, rightX, ote62, xloc = xloc.bar_index, color = color.new(uiGold, 45), style = line.style_dotted, width = 1))
            array.push(L, line.new(pdLeft, ote79, rightX, ote79, xloc = xloc.bar_index, color = color.new(uiGold, 45), style = line.style_dotted, width = 1))
            array.push(LB, label.new(rightX, ote70, "OTE", xloc = xloc.bar_index, style = label.style_label_left, size = size.tiny, textcolor = uiGold, color = color.new(cPanel, 40)))

    if showGradeLabel and useGrade and setupDir != 0 and setupScore >= 55
        color gc = setupDir > 0 ? uiBull : uiBear
        array.push(LB, label.new(bar_index, setupDir > 0 ? low - atrSafe : high + atrSafe, setupTxt, xloc = xloc.bar_index, style = setupDir > 0 ? label.style_label_up : label.style_label_down, size = size.small, textcolor = color.white, color = color.new(gc, setupScore >= 80 ? 0 : 20)))

    if useTradeMap and useGrade and setupDir != 0 and setupScore >= tmMinScore and not na(setupTop) and not na(setupBot)
        bool lng = setupDir > 0
        float entry = lng ? setupTop : setupBot
        float stop  = lng ? setupBot - tmStopPad * atrSafe : setupTop + tmStopPad * atrSafe
        float risk  = math.abs(entry - stop)
        float[] tg = array.new_float(0)
        if not na(eqm)
            array.push(tg, eqm)
        if not na(eqhLevel)
            array.push(tg, eqhLevel)
        if not na(eqlLevel)
            array.push(tg, eqlLevel)
        if not na(nakedAbove)
            array.push(tg, nakedAbove)
        if not na(nakedBelow)
            array.push(tg, nakedBelow)
        if not na(structHi)
            array.push(tg, structHi)
        if not na(structLo)
            array.push(tg, structLo)
        if not na(vpPOC)
            array.push(tg, vpPOC)
        if array.size(fvBox) > 0
            for fi = 0 to array.size(fvBox) - 1
                array.push(tg, (array.get(fvTop, fi) + array.get(fvBot, fi)) / 2.0)
        float[] valid = array.new_float(0)
        if array.size(tg) > 0
            for gi = 0 to array.size(tg) - 1
                float v = array.get(tg, gi)
                bool okT = lng ? (v > entry + 0.1 * atrSafe) : (v < entry - 0.1 * atrSafe)
                if okT
                    array.push(valid, v)
        float t1 = na
        float t2 = na
        if array.size(valid) > 0
            if lng
                array.sort(valid, order.ascending)
            else
                array.sort(valid, order.descending)
            t1 := array.get(valid, 0)
            if array.size(valid) > 1
                t2 := array.get(valid, 1)
        else
            float rr = array.get(calReactN, 0) > 0 ? math.max(1.5, array.get(calReactSum, 0) / array.get(calReactN, 0)) : 2.0
            t1 := lng ? entry + rr * atrSafe : entry - rr * atrSafe
        int tmRightX = bar_index + extendBars
        color lc = lng ? uiBull : uiBear
        float rr1 = risk > 0 ? math.abs(t1 - entry) / risk : na
        array.push(L, line.new(bar_index, stop, tmRightX, stop, xloc = xloc.bar_index, color = color.new(tmStopCol, 0), style = line.style_solid, width = 2))
        array.push(LB, label.new(tmRightX, stop, "SL " + str.tostring(math.round_to_mintick(stop)), xloc = xloc.bar_index, style = label.style_label_left, size = size.tiny, textcolor = color.white, color = color.new(tmStopCol, 0)))
        array.push(L, line.new(bar_index, entry, tmRightX, entry, xloc = xloc.bar_index, color = color.new(tmEntryCol, 0), style = line.style_dashed, width = 2))
        array.push(LB, label.new(tmRightX, entry, "Entry " + str.tostring(math.round_to_mintick(entry)), xloc = xloc.bar_index, style = label.style_label_left, size = size.tiny, textcolor = color.white, color = color.new(tmEntryCol, 0)))
        array.push(L, line.new(bar_index, t1, tmRightX, t1, xloc = xloc.bar_index, color = color.new(tmTgtCol, 0), style = line.style_dashed, width = 2))
        array.push(LB, label.new(tmRightX, t1, "T1 " + str.tostring(math.round_to_mintick(t1)) + (na(rr1) ? "" : "  " + str.tostring(rr1, "0.0") + "R"), xloc = xloc.bar_index, style = label.style_label_left, size = size.tiny, textcolor = color.white, color = color.new(tmTgtCol, 0)))
        if not na(t2)
            array.push(L, line.new(bar_index, t2, tmRightX, t2, xloc = xloc.bar_index, color = color.new(tmTgtCol, 30), style = line.style_dotted, width = 2))
            array.push(LB, label.new(tmRightX, t2, "T2 " + str.tostring(math.round_to_mintick(t2)), xloc = xloc.bar_index, style = label.style_label_left, size = size.tiny, textcolor = color.white, color = color.new(tmTgtCol, 30)))
        array.push(LB, label.new(bar_index, lng ? stop - 0.3 * atrSafe : stop + 0.3 * atrSafe, (lng ? "LONG" : "SHORT") + " · " + f_gradeLetter(setupScore) + " " + str.tostring(math.round(setupScore)) + (na(setupProb) ? "" : " · p" + str.tostring(math.round(setupProb * 100))) + (na(rr1) ? "" : " · " + str.tostring(rr1, "0.0") + "R"), xloc = xloc.bar_index, style = lng ? label.style_label_up : label.style_label_down, size = size.small, textcolor = color.white, color = color.new(lc, 0)))

// ───────────────────────────── DATA HEALTH ─────────────────────────────────
int healthCode = not (high > low) ? 2 : (not warmedUp or not volOk) ? 1 : 0
string healthTxt = healthCode == 2 ? "CRITICAL" : healthCode == 1 ? "DEGRADED" : "OK"

// ───────────────────────────── ALERTS ──────────────────────────────────────
alertcondition(bosUp or bosDn, "Break of Structure", "Structure: validated break of structure")
alertcondition(chochUp or chochDn, "Change of Character", "Structure: validated change of character")
alertcondition(sweepHigh, "Liquidity sweep (highs)", "Liquidity: sell-side sweep")
alertcondition(sweepLow, "Liquidity sweep (lows)", "Liquidity: buy-side sweep")
alertcondition(bullFVG, "Bullish FVG", "Fair value gap: bullish")
alertcondition(bearFVG, "Bearish FVG", "Fair value gap: bearish")
alertcondition(useGrade and setupDir > 0 and setupScore >= 68, "A-grade long setup", "Setup: A-grade long confluence")
alertcondition(useGrade and setupDir < 0 and setupScore >= 68, "A-grade short setup", "Setup: A-grade short confluence")

// ───────────────────────────── DASHBOARD (unified: all-TF + decision) ───────
int s0 = timeframe.in_seconds()
int s1 = f_nextStdSec(s0)
int s2 = f_nextStdSec(s1)
int s3 = f_nextStdSec(s2)
int s4 = f_nextStdSec(s3)
int s5 = f_nextStdSec(s4)
string tf1 = f_secStr(s1)
string tf2 = f_secStr(s2)
string tf3 = f_secStr(s3)
string tf4 = f_secStr(s4)
string tf5 = f_secStr(s5)
[mb0, mr0] = f_mtf()
[mb1, mr1] = request.security(syminfo.tickerid, tf1, f_mtf(), lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
[mb2, mr2] = request.security(syminfo.tickerid, tf2, f_mtf(), lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
[mb3, mr3] = request.security(syminfo.tickerid, tf3, f_mtf(), lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
[mb4, mr4] = request.security(syminfo.tickerid, tf4, f_mtf(), lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
[mb5, mr5] = request.security(syminfo.tickerid, tf5, f_mtf(), lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)

f_row3(table t, int r, string s0, color k0, string s1, color k1, string s2, color k2) =>
    table.cell(t, 0, r, s0, text_color = k0, text_size = size.small, bgcolor = cSub)
    table.cell(t, 1, r, s1, text_color = k1, text_size = size.small, bgcolor = cSub)
    table.cell(t, 2, r, s2, text_color = k2, text_size = size.small, bgcolor = cSub)

var table tbl = table.new(f_pos(tblPosStr), 3, 24, border_width = 1, frame_width = 1)
if showTable and barstate.islast
    bool pro = tblMode == "Pro"
    int totOB = array.get(calTot, 0)
    int hitOB = array.get(calHit, 0)
    int totFV = array.get(calTot, 1)
    int hitFV = array.get(calHit, 1)
    [oLo, oHi] = f_wilson(hitOB, totOB)
    [fLo, fHi] = f_wilson(hitFV, totFV)
    color  setC = setupDir > 0 ? uiBull : setupDir < 0 ? uiBear : cDim
    string fpHead = na(setupProb) ? "" : "p" + str.tostring(math.round(setupProb * 100))
    string biasTxt = bias == 1 ? "Bullish" : bias == -1 ? "Bearish" : "-"
    color  biasC = bias == 1 ? uiBull : bias == -1 ? uiBear : cDim
    string htfTxt = not useHTF ? "off" : htfBias == 1 ? "Bullish" : htfBias == -1 ? "Bearish" : "-"
    color  htfC = htfBias == 1 ? uiBull : htfBias == -1 ? uiBear : cDim
    string regTxt = regime + " " + str.tostring(adx, "0") + (thrashScore > 0.6 ? " chop" : regTrend ? " ok" : "")
    color  regC = regTrend ? uiBull : volCluster or thrashScore > 0.6 ? uiBear : uiGold
    color  pdC = pdZone == "Premium" ? uiBear : pdZone == "Discount" ? uiBull : cDim
    string pdTxt = pdZone + (na(pdPos) ? "" : pdPos > 1 ? " / above" : pdPos < 0 ? " / below" : " / " + str.tostring(math.round(pdPos * 100)) + "%")
    string hlTxt = na(halfLife) ? (useHalfLife ? "trending" : "off") : str.tostring(math.round(halfLife)) + " bars"
    float  obReact = array.get(calReactN, 0) > 0 ? array.get(calReactSum, 0) / array.get(calReactN, 0) : na
    float  fvReact = array.get(calReactN, 1) > 0 ? array.get(calReactSum, 1) / array.get(calReactN, 1) : na
    string reactTxt = (na(obReact) ? "OB -" : "OB " + str.tostring(obReact, "0.0") + "x") + " " + (na(fvReact) ? "FV -" : "FV " + str.tostring(fvReact, "0.0") + "x")
    float  obRecent = useWalkFwd ? f_recentRate(outHistOB, 20) : na
    float  obAll = totOB > 0 ? hitOB / float(totOB) : na
    float  runZ = useWalkFwd ? f_runsZ(outHistOB) : na
    string trendTxt = (na(obRecent) or na(obAll)) ? "warming up" : (obRecent >= obAll + 0.05 ? "improving" : obRecent <= obAll - 0.05 ? "decaying" : "stable") + (not na(runZ) and math.abs(runZ) > 2.0 ? " · streaky" : "")
    color  trendC = (na(obRecent) or na(obAll)) ? cDim : obRecent <= obAll - 0.05 ? uiBear : obRecent >= obAll + 0.05 ? uiBull : cTxt
    string obPctTxt = totOB < 5 ? "warming" : str.tostring(math.round(hitOB * 100.0 / totOB)) + "%"
    string obCITxt = (totOB < 5 or na(oLo)) ? "" : "[" + str.tostring(math.round(oLo * 100)) + "-" + str.tostring(math.round(oHi * 100)) + "]"
    string fvPctTxt = totFV < 5 ? "warming" : str.tostring(math.round(hitFV * 100.0 / totFV)) + "%"
    string fvCITxt = (totFV < 5 or na(fLo)) ? "" : "[" + str.tostring(math.round(fLo * 100)) + "-" + str.tostring(math.round(fHi * 100)) + "]"
    string fwdTxt = na(setupProb) ? "-" : str.tostring(math.round(setupProb * 100)) + "%"
    color  fwdC = na(setupProb) ? cDim : setupProb >= 0.6 ? uiBull : setupProb <= 0.4 ? uiBear : cTxt

    table.set_bgcolor(tbl, cPanel)
    table.set_frame_color(tbl, cFrame)
    table.set_border_color(tbl, cBord)
    table.cell(tbl, 0, 0, "SETUP", text_color = color.white, text_size = size.normal, bgcolor = color.new(setC, 0))
    table.cell(tbl, 1, 0, setupTxt, text_color = color.white, text_size = size.normal, bgcolor = color.new(setC, 0))
    table.cell(tbl, 2, 0, fpHead, text_color = color.white, text_size = size.normal, bgcolor = color.new(setC, 0))
    f_row3(tbl, 1, "TF", cTxt, "Struct", cTxt, "Regime", cTxt)
    int[]    mbA = array.from(mb0, mb1, mb2, mb3, mb4, mb5)
    int[]    mrA = array.from(mr0, mr1, mr2, mr3, mr4, mr5)
    string[] tfA = array.from(timeframe.period, tf1, tf2, tf3, tf4, tf5)
    int upN = 0
    int dnN = 0
    for r = 0 to 5
        int bb = array.get(mbA, r)
        int rc = array.get(mrA, r)
        if bb == 1
            upN += 1
        if bb == -1
            dnN += 1
        string rTxt = rc == 2 ? "Trend Up" : rc == -2 ? "Trend Dn" : rc == 1 ? "Volatile" : "Range"
        color  rCol = rc == 2 ? uiBull : rc == -2 ? uiBear : rc == 1 ? uiGold : cDim
        f_row3(tbl, r + 2, array.get(tfA, r) + (r == 0 ? " ·" : ""), r == 0 ? cTxt : cDim, bb == 1 ? "Bull" : bb == -1 ? "Bear" : "-", bb == 1 ? uiBull : bb == -1 ? uiBear : cDim, rTxt, rCol)
    int rngN = 6 - upN - dnN
    color agC = upN > dnN and upN >= rngN ? uiBull : dnN > upN and dnN >= rngN ? uiBear : uiGold
    f_row3(tbl, 8, "Align", cDim, "Up " + str.tostring(upN) + " Dn " + str.tostring(dnN) + " Rng " + str.tostring(rngN), agC, upN >= 5 ? "stacked up" : dnN >= 5 ? "stacked dn" : "mixed", agC)

    if not pro
        f_row3(tbl, 9,  "P/D · HTF", cDim, pdTxt, pdC, htfTxt, htfC)
        f_row3(tbl, 10, "OB respect", cDim, obPctTxt, totOB < 5 ? cDim : cTxt, trendTxt, trendC)
        f_row3(tbl, 11, "Fwd · React", cDim, fwdTxt, fwdC, reactTxt, cTxt)
    else
        f_row3(tbl, 9,  "Structure", cDim, biasTxt + (showIntl ? " / i " + (iBias == 1 ? "up" : iBias == -1 ? "dn" : "-") : ""), biasC, "", cSub)
        f_row3(tbl, 10, "Regime", cDim, regTxt, regC, "", cSub)
        f_row3(tbl, 11, "HTF " + htfStr, cDim, htfTxt, htfC, "", cSub)
        f_row3(tbl, 12, "Premium/Disc", cDim, pdTxt, pdC, "", cSub)
        f_row3(tbl, 13, "Order blocks", cDim, str.tostring(array.size(obBox)) + " active", cTxt, "", cSub)
        f_row3(tbl, 14, "OB respect", cDim, obPctTxt, totOB < 5 ? cDim : cTxt, obCITxt, cDim)
        f_row3(tbl, 15, "FVGs", cDim, str.tostring(array.size(fvBox)) + " active", cTxt, "", cSub)
        f_row3(tbl, 16, "FVG respect", cDim, fvPctTxt, totFV < 5 ? cDim : cTxt, fvCITxt, cDim)
        f_row3(tbl, 17, "Liquidity", cDim, not na(eqhLevel) ? "BSL " + str.tostring(math.round_to_mintick(eqhLevel)) : "-", cTxt, not na(eqlLevel) ? "SSL " + str.tostring(math.round_to_mintick(eqlLevel)) : "", cTxt)
        f_row3(tbl, 18, "Naked POC", cDim, not na(nakedAbove) ? "up " + str.tostring(math.round_to_mintick(nakedAbove)) : "-", uiGold, not na(nakedBelow) ? "dn " + str.tostring(math.round_to_mintick(nakedBelow)) : "", uiGold)
        f_row3(tbl, 19, "Half-life", cDim, hlTxt, na(halfLife) ? uiGold : cTxt, "", cSub)
        f_row3(tbl, 20, "Reaction", cDim, reactTxt, cTxt, "", cSub)
        f_row3(tbl, 21, "Respect trend", cDim, trendTxt, trendC, "", cSub)
        f_row3(tbl, 22, "Forward prob", cDim, fwdTxt, fwdC, "", cSub)
        f_row3(tbl, 23, "Data", cDim, healthTxt, healthCode == 0 ? uiBull : healthCode == 1 ? uiGold : uiBear, "", cSub)

// ───────────────────────────── IDENTITY STRIP ──────────────────────────────
var table idTbl = table.new(position.bottom_center, 1, 1)
if showId and barstate.islast
    table.cell(idTbl, 0, 0, "Market Structure & Liquidity   /   " + syminfo.ticker + "   /   " + timeframe.period, text_color = cDim, text_size = size.small, text_halign = text.align_center, bgcolor = color.new(color.gray, 100))

// ───────────────────────────── EXP_* EXPORTS ───────────────────────────────
float obRespRate = array.get(calTot, 0) > 0 ? array.get(calHit, 0) / float(array.get(calTot, 0)) : na
float fvRespRate = array.get(calTot, 1) > 0 ? array.get(calHit, 1) / float(array.get(calTot, 1)) : na
int pdCode = pdZone == "Premium" ? 1 : pdZone == "Discount" ? -1 : 0
int regCodeE = regime == "Trend Up" ? 2 : regime == "Trend Dn" ? -2 : regime == "Volatile" ? 1 : 0
plot(bias,                         "EXP_StructureBias", color = color.new(color.gray, 100), display = display.data_window)
plot(useHTF ? htfBias : 0,         "EXP_HTFBias",       color = color.new(color.gray, 100), display = display.data_window)
plot(structEvent,                  "EXP_StructEvent",   color = color.new(color.gray, 100), display = display.data_window)
plot(regCodeE,                     "EXP_Regime",        color = color.new(color.gray, 100), display = display.data_window)
plot(pdCode,                       "EXP_PremiumDisc",   color = color.new(color.gray, 100), display = display.data_window)
plot(setupDir,                     "EXP_SetupDir",      color = color.new(color.gray, 100), display = display.data_window)
plot(setupScore,                   "EXP_SetupScore",    color = color.new(color.gray, 100), display = display.data_window)
plot(array.size(obBox),            "EXP_ActiveOB",      color = color.new(color.gray, 100), display = display.data_window)
plot(array.size(fvBox),            "EXP_ActiveFVG",     color = color.new(color.gray, 100), display = display.data_window)
plot(sweepHigh ? -1 : sweepLow ? 1 : 0, "EXP_Sweep",    color = color.new(color.gray, 100), display = display.data_window)
plot(nz(obRespRate, -1),           "EXP_OBRespect",     color = color.new(color.gray, 100), display = display.data_window)
plot(nz(fvRespRate, -1),           "EXP_FVGRespect",    color = color.new(color.gray, 100), display = display.data_window)
plot(nz(halfLife, -1),             "EXP_HalfLife",      color = color.new(color.gray, 100), display = display.data_window)
plot(nz(setupProb, -1),            "EXP_ForwardProb",   color = color.new(color.gray, 100), display = display.data_window)
plot(healthCode,                   "EXP_Health",        color = color.new(color.gray, 100), display = display.data_window)
````
