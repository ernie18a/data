# Adaptive Consensus Trail  Structure, Regime & Self

- url: https://www.tradingview.com/script/0nHScBxq-Adaptive-Consensus-Trail-Structure-Regime-Self/
- type: indicator
- pine_id: PUB;68c982aa2b6645a7913b0f538f97fb8e
- version: 3.0

## Description

Adaptive Consensus Trail — Structure, Regime & Self-Test

A trailing stop that sits on the agreement of several structural references, adapts to the market regime, and forward-tests its own signals so the numbers it shows are measured, not asserted.

What it is

Most trailing stops follow one idea — an ATR band, a SuperTrend, a moving average. This one places the stop where a small committee of independent structural references agree, reads how confident that agreement is, widens or tightens itself according to the market regime, and then continuously audits its own flips and reports the edge it actually produced on your data.

The committee has five members, each locating support/resistance from a different lens:

Anchored VWAP band — fair value for the session/week/month
Session / naked volume Point-of-Control — the price the most volume traded at, carried forward until revisited
Fair-Value-Gap midpoint — unfilled imbalance
Swing pivot — structural memory
Order-flow absorption — where aggressive buying/selling was absorbed (via Bulk Volume Classification)

Why these parts belong in one script (mashup justification)

Each reference alone whipsaws on an index, and each is right in different conditions. They are combined because they correct one another, and the entire value of the script is in that interaction — not in any single line:

A reliability layer scores every reference's historical respect rate with a Wilson lower bound, so a reference that keeps getting ignored loses its vote instead of dragging the stop around.
A consensus layer keeps only the densest agreeing cluster of references, so the stop sits on genuine agreement rather than on an average nobody respects, and far-apart references never force a permanent "no signal."

A regime layer (efficiency ratio + ADX + band-width + a volatility-cluster read + a Hurst persistence estimate) widens the band and tightens the flip confirmation in chop — this is what removes the whipsaw.

A self-test layer forward-scores every flip and recalibrates the confidence number so it means what it says.

Split apart, these are five overlays that each mislead in a range. Wired together, they are one self-correcting, self-auditing trail. That is the reason for combining them.
How it works (six layers)

References are computed on the bar close.

Reliability — rolling-capped respect counts per reference give a Wilson lower-bound "trust." POC is a magnet, so it is judged by forward reaction (did price reject away before breaking through?), not a same-bar close, which keeps its trust honest.

Consensus — the densest agreeing cluster within an ATR band becomes the trail's target; the envelope and confidence are measured on that cluster only.

Adaptive backbone — an efficiency-ratio / regime-adaptive band (Adaptive, Chandelier, or Blend) that widens in chop.

The trail — high confidence pulls the stop toward structure (floored a minimum ATR off price); low confidence rides the wide band, so it flips less in noise.
Self-test — every flip is forward-resolved by triple-barrier first-touch against an unconditional base rate, split by strength tier and by regime, with a walk-forward in-sample→out-of-sample check, a runs test of independence, a Brier score, and a confidence recalibration.

How to use it

Read the top banner for the one-line bias — BULLISH / BEARISH / WAIT — and the READ legend for what to do. The coloured line is your stop: support in an uptrend, resistance in a downtrend. BUY / SELL labels print only on confirmed, sufficiently-confident, higher-timeframe-aligned flips.

The dashboard gives detail top-down: each reference's level and trust, the consensus, raw → calibrated confidence, regime (with Hurst and ADX), the higher-timeframe invalidation stop, and a FULL / HALF / STAND-ASIDE suggestion.

Before sizing, open the Self-Test panel and read the Edge column (hit% − base%), not the raw hit-rate. A ★ means the edge's confidence interval clears the base rate. Prefer signals where the walk-forward change isn't badly negative and the runs test isn't "streaky." Being honest about it: on many indices this tool shows real edge in range and volatile regimes on higher timeframes and little-to-none on very low timeframes or once a trend is already confirmed — the panel makes that transparent so you can pick your spots.

Works on any market

Set the Price source, and for symbols with no native volume set a Borrow-volume proxy (e.g. a futures contract). The panel theme adapts to your chart background automatically. Backbone: Adaptive / Chandelier / Blend. Absorption: order-flow (BVC) or simple. An optional intrabar resolution builds a finer volume profile where available.

Originality

The committee-of-references design, the cluster-not-average consensus, the reliability weighting that lets references lose their vote, the forward-reaction POC respect test, and the confidence self-calibration are the author's own work. The underlying techniques are standard and fully credited below.

Non-repaint

References, regime, consensus and the trail all evaluate on the close of the bar; the live bar is provisional and settles on close. Self-test events are logged and resolved only on confirmed bars and resolve on bars after their trigger at fixed barriers, so hit / base / edge use no look-ahead. The higher-timeframe stop uses a lookahead-off request.

Concept credits

Wilson score interval (E. B. Wilson); efficiency ratio (P. Kaufman); ADX / DMI / ATR / volatility-stop lineage (J. W. Wilder); anchored VWAP (industry standard); volume profile / value area / point-of-control — Market Profile (J. P. Steidlmayer, developed by J. F. Dalton); triple-barrier first-touch labelling (M. López de Prado); runs test of randomness (A. Wald & J. Wolfowitz); rescaled-range / Hurst exponent (H. E. Hurst); Brier score (G. W. Brier); Bulk Volume Classification / VPIN (D. Easley, M. López de Prado & M. O'Hara); reliability-bin (isotonic-style) calibration is standard forecasting practice.
Limitations & disclaimer

"Absorption" is a volume proxy — base data has no true tick order flow, so the buy/sell split is estimated from bar moves, not measured. Confidence is context, not a promise of profit. The self-test is descriptive of past behaviour on the loaded symbol (fixed barriers, no costs or slippage) — a study aid, not a backtest and not a guarantee. A measured edge is what flips did historically here, not a forecast.

This script is for research and education only. It is not financial advice, not a recommendation to buy or sell, and not a guarantee of any outcome. Trading carries risk of loss; your decisions are your own. Test on your own data and use independent risk management before relying on it.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
// =============================================================================
//  © Market_Logic_India                                                 MPL-2.0
//  ADAPTIVE CONSENSUS TRAIL — Structure, Regime & Self-Test                 v1.1
//  v1.1 — Correctness + house-standard pass:
//    • Hoisted a double-computed ta.sma (bandwidth ratio) out of a ternary so it runs once per bar,
//      unconditionally — clears CW10004; output unchanged.
//    • Added the MPL-2.0 header, an EXP_ export bus, and a round-trip COST model: the self-test panel
//      now shows Net R (R-expectancy net of cost) and exports it.
//  A regime-aware trailing stop built on the AGREEMENT of several structural
//  levels, with a confidence read and a built-in forward self-test.
// -----------------------------------------------------------------------------
//  WHAT IT IS
//    An adaptive trailing stop whose level is the AGREEMENT of a small committee
//    of independent structural references: an anchored volume-weighted-average
//    band, a session / naked volume point-of-control, a fair-value-gap midpoint,
//    a swing pivot, and a volume-absorption reference. Confidence is read from
//    how tightly those references CLUSTER (not from averaging them), and that
//    confidence governs how hard the stop is pulled toward structure versus how
//    wide it rides. The engine then forward-tests its OWN direction flips and
//    reports the measured EDGE over an unconditional base rate, so the numbers
//    it shows are observed on your data, not asserted.
//
//  WHY THESE PARTS BELONG IN ONE SCRIPT (mashup justification)
//    Each reference answers "where is structural support / resistance" from a
//    DIFFERENT lens — fair value (VWAP), traded-volume value (POC), imbalance
//    (FVG), swing memory (pivots) and absorption (volume). Any one alone
//    whipsaws on an index like this. The value is the COORDINATION, and the
//    parts only work because they are wired together:
//      * a RELIABILITY layer scores each reference's historical respect rate
//        (Wilson lower bound) so a chronically-ignored reference stops voting;
//      * a CONSENSUS layer keeps only the densest reliability-weighted CLUSTER,
//        so far-apart references never force a permanent "no agreement" and the
//        trail sits on agreement, not on an average nobody respects;
//      * a REGIME layer (efficiency ratio + ADX + band-width + a volatility-
//        cluster read + a Hurst persistence estimate) WIDENS the band in chop
//        and tightens the flip confirmation — this is what removes the whipsaw;
//      * a CALIBRATION layer audits the whole thing forward and recalibrates the
//        confidence number so it means what it says.
//    Split apart these are five overlays that each mislead in range; wired
//    together they are one self-correcting, self-auditing trail. That
//    interaction is the reason for combining them.
//
//  HOW IT WORKS (six layers)
//    1 References -> 2 Wilson reliability (rolling-capped respect counts;
//    "warming" under N samples; POC judged by FORWARD reaction, not same-bar) ->
//    3 densest agreeing cluster within an ATR band becomes the consensus;
//    envelope and confidence are measured on the CLUSTER only -> 4 an
//    efficiency-ratio / regime-adaptive trailing backbone whose width and flip-
//    confirmation breach grow in chop -> 5 confidence-governed trail (high
//    confidence pulls toward structure, floored a minimum ATR off price; low
//    confidence rides the wide band) -> 6 a forward self-test (triple-barrier
//    first-touch on the trail's own flips, base rate, Wilson interval, per-tier
//    and per-regime split, walk-forward in-sample -> out-of-sample, runs test,
//    a Brier score and a confidence recalibration).
//
//  HOW TO USE
//    Read the top banner for the one-line bias (BULLISH / BEARISH / WAIT) and
//    the READ legend for what to do. The dashboard adds detail top-down: each
//    reference LEVEL + TRUST, the CONSENSUS line, raw -> calibrated CONFIDENCE,
//    REGIME (with Hurst and ADX), the higher-timeframe invalidation stop and a
//    FULL / HALF / STAND-ASIDE suggestion. The coloured line is the trail and
//    doubles as a stop: it is support in an uptrend, resistance in a downtrend.
//    Flip labels (BUY / SELL) print only on confirmed, sufficiently-confident,
//    higher-timeframe-aligned flips. Before sizing, open the Calibration panel
//    and read the EDGE column (hit% minus base%), never the raw hit-rate, and
//    prefer signals where the walk-forward change is not badly negative and the
//    runs test is not "streaky". An index intraday is often mean-reverting, so
//    expect more WAIT on 1–3 min than on 15 min+.
//
//  ORIGINALITY
//    The individual techniques below are standard and credited. What is original
//    here is the committee-of-references design, the cluster-not-average
//    consensus, the reliability weighting that lets references lose their vote,
//    the forward-reaction POC respect test, and the self-calibration that turns
//    the confidence read into an audited, recalibrated probability.
//
//  NON-REPAINT
//    References, regime, consensus and the trail evaluate on the CLOSE of the
//    bar; the live bar is provisional and settles on close. Self-test events are
//    logged and resolved only on CONFIRMED bars and resolve on bars AFTER their
//    trigger at fixed barriers, so hit / base / edge use no look-ahead. The
//    higher-timeframe stop uses a lookahead-off request.
//
//  CONCEPT CREDITS (techniques are standard; this implementation is the author's)
//    Wilson score interval — E. B. Wilson (1927). Efficiency ratio — P. Kaufman.
//    ADX / DMI / ATR / volatility-stop lineage — J. W. Wilder. Anchored VWAP —
//    industry standard. Volume profile / value area / point-of-control — Market
//    Profile (J. P. Steidlmayer; developed by J. F. Dalton). Triple-barrier
//    first-touch labelling — M. Lopez de Prado. Runs test of randomness —
//    A. Wald & J. Wolfowitz. Rescaled-range / Hurst exponent — H. E. Hurst.
//    Brier score — G. W. Brier. Bulk Volume Classification / VPIN order-flow —
//    D. Easley, M. Lopez de Prado & M. O'Hara. Reliability-bin (isotonic-style)
//    calibration —
//    standard forecasting practice.
//
//  HONESTY / LIMITATIONS
//    POC is an ATR-binned session / naked volume point-of-control; "absorption"
//    is a volume proxy — base data has no true tick order flow, so the buy/sell
//    split is ESTIMATED from bar moves (Bulk Volume Classification), not measured.
//    Confidence is CONTEXT, not a promise of profit. The self-test is
//    DESCRIPTIVE of past behaviour on the loaded symbol — fixed barriers, no
//    costs or slippage — a study aid, not a backtest or a guarantee. A measured
//    edge is what flips did historically here, not a forecast.
//
//  DISCLAIMER
//    For research and education only. This script is NOT financial advice, NOT a
//    recommendation to buy or sell, and NOT a guarantee of any outcome. Trading
//    carries risk of loss; you alone are responsible for your decisions. Test on
//    your own data and use independent risk management before relying on it.
// =============================================================================
indicator("Adaptive Consensus Trail — Structure, Regime & Self", "Consensus Trail", overlay = true,
     max_labels_count = 500, max_lines_count = 500, max_boxes_count = 250)

// ============================ INPUTS =========================================
gA = "1 · Structural references (the committee)"
useVWAP   = input.bool(true,  "Anchored VWAP band",            group = gA)
usePOC    = input.bool(true,  "Session / naked POC",            group = gA, tooltip = "Volume point-of-control anchored to each session. The developing-session POC acts as a live magnet; when a session ends its POC is frozen as a 'naked POC' that persists until price revisits it. Trust is measured against the stable naked levels, so POC finally records real breaks instead of hugging price.")
useFVG    = input.bool(true,  "Fair Value Gap (CE midpoint)",   group = gA)
useSwing  = input.bool(true,  "Swing pivot (structure)",        group = gA)
useAbsorp = input.bool(true,  "Absorption (volume proxy)",      group = gA)
vwapAnchor  = input.string("Session", "VWAP anchor", options = ["Session","Week","Month"], group = gA)
vwapStdMult = input.float(1.0, "VWAP band σ mult", minval = 0.0, step = 0.1, group = gA)
pocBinAtr   = input.float(0.25,"POC bin width (×ATR)", minval = 0.05, step = 0.05, group = gA)
pocMaxNaked = input.int(12, "Naked POCs to keep", minval = 2, maxval = 60, group = gA, tooltip = "How many unfilled prior-session POC levels to carry forward as support/resistance magnets. Oldest are dropped past this cap.")
pivLeft     = input.int(8,   "Swing left",  minval = 1, group = gA)
pivRight    = input.int(8,   "Swing right", minval = 1, group = gA)
absLen      = input.int(60,  "Absorption lookback", minval = 10, maxval = 400, group = gA)
absMode     = input.string("Order-flow (BVC)", "Absorption method", options = ["Order-flow (BVC)","Simple (volume extreme)"], group = gA, tooltip = "Order-flow (BVC) = Bulk Volume Classification: split each bar's volume into buy/sell via the standardised close-to-close move, then mark where AGGRESSIVE flow was ABSORBED (heavy selling that failed to break down = support; heavy buying that failed to break up = resistance). Simple = the low/high of the highest-volume up/down bar.")
bvcLen      = input.int(20,  "BVC volatility window", minval = 5, maxval = 100, group = gA)

gR = "2 · Reliability & respect"
calCap     = input.int(40,  "Rolling sample cap per anchor", minval = 10, maxval = 200, group = gR)
minSamples = input.int(5,   "Min samples before trusting",  minval = 2, maxval = 30, group = gR)
priorW     = input.float(0.50,"Neutral weight while warming", minval = 0.0, maxval = 1.0, step = 0.05, group = gR)
touchTolAtr= input.float(0.20,"Touch zone tolerance (×ATR)",  minval = 0.05, step = 0.05, group = gR)
pocRespHz  = input.int(10,  "POC respect horizon (bars)",  minval = 3, maxval = 60, group = gR, tooltip = "POC is a magnet, so a same-bar close test scores it as 'held' almost every time. Instead, after price touches a naked POC, wait this many bars and judge by FORWARD reaction: did price reject away from the level before breaking through it? That yields an honest respect rate.")
pocRespATR = input.float(0.5, "POC reject / break margin (×ATR)", minval = 0.1, maxval = 3.0, step = 0.1, group = gR)

gC = "3 · Consensus & confidence"
atrLen      = input.int(14,  "ATR length", minval = 1, group = gC)
clusterAtr  = input.float(0.60,"Cluster band width (×ATR)", minval = 0.1, step = 0.05, group = gC,
     tooltip = "Anchors within this price band of each other count as ONE agreeing cluster. The densest cluster (most reliability-weight) becomes the consensus. Envelope and confidence are measured on this cluster only.")
consMode    = input.string("Weighted median", "Cluster consensus", options = ["Weighted median","Most conservative"], group = gC,
     tooltip = "Weighted median = robust centre of the cluster. Most conservative = the cluster member closest to price (tighter stop, the choice from the FVG/order-flow design).")
wAgree      = input.float(0.35,"Confidence: cluster agreement w", minval = 0, maxval = 1, step = 0.05, group = gC)
wTight      = input.float(0.20,"Confidence: cluster tightness w", minval = 0, maxval = 1, step = 0.05, group = gC)
wRel        = input.float(0.25,"Confidence: anchor reliability w", minval = 0, maxval = 1, step = 0.05, group = gC)
wReg        = input.float(0.20,"Confidence: regime quality w",    minval = 0, maxval = 1, step = 0.05, group = gC)
minConf     = input.float(0.55,"Min confidence to suggest a trade", minval = 0, maxval = 1, step = 0.05, group = gC)

gT = "4 · Trail & de-whipsaw"
baseMult   = input.float(3.0, "Base ATR multiplier", minval = 0.5, maxval = 12, step = 0.1, group = gT)
trailMode  = input.string("Adaptive consensus", "Trailing backbone", options = ["Adaptive consensus","Chandelier","Blend"], group = gT, tooltip = "The wide fallback the trail rides when confidence is low. Adaptive consensus = ATR band around the mid, widened in chop. Chandelier = hangs from the recent highest-high / lowest-low minus ATR (holds trends better, resists shake-outs). Blend = average of the two.")
chandLen   = input.int(22, "Chandelier lookback (bars)", minval = 5, maxval = 100, group = gT, tooltip = "Highest-high / lowest-low window for the Chandelier backbone.")
multLoK    = input.float(0.80,"Band scale @ calm (×base)", minval = 0.3, maxval = 1.5, step = 0.05, group = gT)
multHiK    = input.float(1.80,"Band scale @ volatile (×base)", minval = 1.0, maxval = 4.0, step = 0.05, group = gT)
rankLen    = input.int(200, "Volatility-rank lookback", minval = 30, maxval = 1000, group = gT)
chopK      = input.float(0.60,"Widen further in chop (× by 1-ER)", minval = 0, maxval = 2, step = 0.05, group = gT)
atrFloor   = input.float(1.0, "Min stop distance from price (×ATR)", minval = 0.1, step = 0.05, group = gT, tooltip = "Stops closer than ~1×ATR sit inside normal noise and trigger on it the majority of the time within a few bars, so the trail is never floored tighter than this off price.")
confStruct = input.float(0.55,"Confidence to pull stop to structure", minval = 0, maxval = 1, step = 0.05, group = gT)
confK      = input.float(0.50,"Flip confirm breach (×ATR)", minval = 0, maxval = 3, step = 0.05, group = gT)
chopConfirmK = input.float(0.60,"  + extra breach in chop (×thrash)", minval = 0, maxval = 3, step = 0.05, group = gT, tooltip = "Adds to the confirm breach in proportion to the thrash score, so flips need a bigger move to trigger in choppy tape.")
rangeConfirmAdd = input.float(0.50,"  + extra breach when not trending (×ATR)", minval = 0, maxval = 3, step = 0.05, group = gT)
rangeWiden = input.float(1.30,"Widen band ×, when not trending", minval = 1.0, maxval = 3.0, step = 0.05, group = gT)
minHold    = input.int(2,   "Min bars between flips", minval = 0, maxval = 50, group = gT)

gReg = "5 · Regime & persistence"
erLen   = input.int(14,  "Efficiency-ratio length", minval = 2, maxval = 60, group = gReg)
adxLen  = input.int(14,  "ADX / DMI length", minval = 2, maxval = 60, group = gReg)
adxTrd  = input.float(20.0,"ADX trend threshold", minval = 5, maxval = 50, group = gReg)
erTrd   = input.float(0.30,"ER trend threshold", minval = 0.05, maxval = 0.95, step = 0.01, group = gReg)
bbwLen  = input.int(20,  "BB-width length", minval = 5, maxval = 100, group = gReg)
clustDecay = input.float(0.20,"Vol-cluster decay", minval = 0.02, maxval = 0.9, step = 0.01, group = gReg)
clustThr   = input.float(1.5, "Vol-cluster z threshold", minval = 0.5, maxval = 4.0, step = 0.1, group = gReg)
useHurst   = input.bool(true, "Hurst exponent (trend vs mean-revert)", group = gReg, tooltip = "Rescaled-range Hurst over a window. H>0.5 = persistent / trend-following; H<0.5 = anti-persistent / mean-reverting; ~0.5 = random walk. Many indices are <0.5 intraday, which is why the engine often says WAIT. Hurst refines the trend gate and the regime-quality score.")
hurstLen   = input.int(80,  "Hurst window (bars)", minval = 20, maxval = 300, group = gReg)
hurstBuf   = input.float(0.02,"Hurst neutral buffer around 0.5", minval = 0.0, maxval = 0.2, step = 0.01, group = gReg)

gH = "6 · Higher-timeframe stop"
showHtf  = input.bool(true, "Plot HTF Supertrend stop (wider SL)", group = gH)
htfMult  = input.int(5, "HTF = chart × this", minval = 2, maxval = 60, group = gH)

gV = "7 · Display & readability"
themeMode  = input.string("Auto", "Panel theme", options = ["Auto","Dark","Light"], group = gV, tooltip = "Auto reads the chart background colour and picks readable panel colours automatically. Force Dark or Light if you prefer.")
showZone   = input.bool(true, "Consensus cluster zone", group = gV)
showLabels = input.bool(true, "Confirmed BUY / SELL labels", group = gV)
labelMinConf = input.float(0.50,"  only label flips ≥ this confidence", minval = 0, maxval = 1, step = 0.05, group = gV, tooltip = "Low-confidence flips are noise by the engine's own logic; this hides them. 0.50 keeps moderate and strong only. Set 0 to show every flip.")
htfAlignLabels = input.bool(true,"  only label flips aligned with HTF stop", group = gV, tooltip = "Top-down filter: only label a flip when it agrees with the higher-timeframe stop direction. Cuts counter-trend range whipsaw. Turn off to show more signals.")
maxFlipLabels = input.int(300, "  keep last N flip labels", minval = 10, maxval = 500, group = gV, tooltip = "Object-pool cap: how many historical BUY/SELL labels to keep on the chart. Higher shows more past signals.")
showTable  = input.bool(true, "Committee dashboard", group = gV)
tblPos     = input.string("top_right","Dashboard position", options = ["top_right","top_left","bottom_right","bottom_left"], group = gV)
warnBg     = input.bool(true, "Faint state background (bull / bear / wait)", group = gV, tooltip = "Tints the whole pane very faintly: teal = bullish, red = bearish, grey = no clear trend / stand aside. A glance tells a non-technical reader the current read.")
plainBanner= input.bool(false, "Plain-language banner (top centre)", group = gV, tooltip = "A big BULLISH / BEARISH / WAIT headline that mirrors the SUGGESTION row, for at-a-glance decisions.")
plainLabels= input.bool(true, "Plain BUY / SELL flip labels", group = gV, tooltip = "Labels confirmed flips as BUY / SELL (STRONG on high-confidence flips) instead of internal tier codes.")
colorBars  = input.bool(true, "Colour price bars by state", group = gV, tooltip = "Paints candles teal (bullish) / red (bearish) / grey (wait). Turn off to keep native up/down candles; the background tint still conveys state.")
showHowTo  = input.bool(false, "How-to-read legend", group = gV)
showKey    = input.bool(false, "Legend key (decode marks / lines)", group = gV)
keyPos     = input.string("bottom_left","Legend key position", options = ["top_right","top_left","bottom_right","bottom_left"], group = gV)
showId     = input.bool(false, "Identity strip (name · symbol · TF)", group = gV)

gK = "8 · Self-test (forward calibration)"
calEnable  = input.bool(true, "Run the forward self-test (background)", group = gK, tooltip = "Logs every confirmed flip and, a horizon later, resolves it by triple-barrier first-touch. Reports hit% vs an unconditional base rate, the EDGE between them with a Wilson interval, a regime split, a walk-forward in-sample -> out-of-sample check, a runs test, a Brier score and a confidence recalibration. Lightweight; leave on even with the panel hidden.")
showCalib  = input.bool(false, "Show self-test panel", group = gK)
calPos     = input.string("bottom_right","Self-test panel position", options = ["top_right","top_left","bottom_right","bottom_left"], group = gK)
calHorizon = input.int(20, "Evaluation horizon (bars)", minval = 3, maxval = 200, group = gK)
calFavATR  = input.float(1.0, "Target barrier (×ATR, your 1R)", minval = 0.2, maxval = 6.0, step = 0.1, group = gK, tooltip = "A flip is a HIT if price reaches this many ATR in the flip's direction before the stop barrier.")
calStopATR = input.float(1.0, "Stop barrier (×ATR)", minval = 0.2, maxval = 6.0, step = 0.1, group = gK)
costR      = input.float(0.30, "Round-trip cost (R) — subtracted for Net R", minval = 0.0, maxval = 3.0, step = 0.05, group = gK, tooltip = "Round-trip cost (brokerage + STT + slippage + optimistic fill) in R — as a fraction of the stop risk (Stop barrier × ATR). With a target of calFav×ATR and stop of calStop×ATR, gross R-expectancy = hit%·(target/stop + 1) − 1; Net R subtracts this cost. Net R > 0 = the flip edge is tradeable after costs. Default 0.30 suits 1m NIFTY futures.")
calMinSamp = input.int(8, "Min resolved flips to trust a cell", minval = 3, maxval = 50, group = gK)
calIsTarget= input.int(40, "Walk-forward in-sample size", minval = 10, maxval = 200, group = gK, tooltip = "The first N resolved flips freeze as in-sample; everything after is held out. The in-sample -> out-of-sample change is a direct overfit / decay check.")

gX = "9 · Data source, alerts & export"
srcPrice     = input.source(hlc3, "Price source (structure & value)", group = gX, tooltip = "Feeds the VWAP, POC and value calculations so the script adapts to any instrument. hlc3 (typical price) is the default; close / ohlc4 also work.")
volBorrowSym = input.symbol("", "Borrow volume from symbol (no-volume fix)", group = gX, tooltip = "For instruments with no native volume (e.g. some cash indices). Enter a volume-bearing proxy such as its futures / continuous contract. Only activates when the chart symbol truly reports no volume.")
intrabarTf   = input.string("Auto (finest)","Intrabar resolution for volume / POC", options = ["Auto (finest)","1 tick","1 second","1 minute","Off (chart bar)"], group = gX, tooltip = "Distributes each bar's volume across finer sub-bars for a more accurate volume point-of-control. Auto uses 1-minute (the widely-available finest); 1 tick / 1 second need a compatible plan and symbol and fall back automatically if unavailable.")
enableExports= input.bool(true, "Export series to Data Window", group = gX, tooltip = "Publishes the trail, direction, confidence (raw & calibrated), regime, Hurst, HTF stop, edge and Brier as titled Data-Window plots so other scripts can read them via request.security().")
alertFilter  = input.string("All flips","Combined alert fires on", options = ["All flips","Long only","Short only","Strong only","HTF-aligned only"], group = gX, tooltip = "Drives the single combined alert() call. The granular flip alertconditions remain available separately.")

// ============================ THEME (adaptive to chart background) ============
_bgC   = chart.bg_color
_bgLum = na(_bgC) ? 0.0 : color.r(_bgC) * 0.299 + color.g(_bgC) * 0.587 + color.b(_bgC) * 0.114
isDark = themeMode == "Auto" ? _bgLum < 128 : themeMode == "Dark"
uiBull = isDark ? color.rgb(38, 166, 154)  : color.rgb(0, 137, 123)   // teal
uiBear = isDark ? color.rgb(239, 83, 80)   : color.rgb(211, 47, 47)   // red
uiGold = isDark ? color.rgb(214, 174, 90)  : color.rgb(176, 132, 12)  // consensus
uiNeut = isDark ? color.rgb(120, 130, 140) : color.rgb(110, 118, 128) // dim
cTxt   = isDark ? color.rgb(222, 226, 230) : color.rgb(33, 37, 41)
cPanel = isDark ? color.new(color.rgb(18, 22, 28), 12) : color.new(color.rgb(248, 249, 250), 8)
cGrid  = isDark ? color.new(color.rgb(70, 78, 86), 40) : color.new(color.rgb(180, 188, 196), 40)

// perceived luminance -> auto-contrast chip text (dark on bright, white on dark)
f_lum(color c)  => na(c) ? 0.0 : color.r(c) * 0.299 + color.g(c) * 0.587 + color.b(c) * 0.114
f_chip(color c) => f_lum(c) > 140 ? color.rgb(12, 14, 18) : color.white

// ============================ VOLUME (borrow for no-volume symbols) ==========
var bool nativeVolSeen = false
if volume > 0
    nativeVolSeen := true
useBorrow    = str.length(volBorrowSym) > 0 and not nativeVolSeen
volBorrowRaw = request.security(volBorrowSym, timeframe.period, volume, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
float volEff = useBorrow and not na(volBorrowRaw) ? volBorrowRaw : volume

// Bulk Volume Classification (Easley, Lopez de Prado & O'Hara): split each bar's
// volume into buy / sell from the standardised close-to-close move (logistic CDF
// approximation). Used by the order-flow absorption references.
_bvcRet = close - close[1]
_bvcStd = ta.stdev(_bvcRet, bvcLen)
_bvcZ   = nz(_bvcStd) > 0 ? _bvcRet / _bvcStd : 0.0
buyFrac = 1.0 / (1.0 + math.exp(-1.702 * _bvcZ))          // ~normal CDF
buyVolS  = volEff * buyFrac
sellVolS = volEff * (1.0 - buyFrac)

// ============================ DATA HEALTH ====================================
hVolOK = not na(volEff) and volEff > 0
var int hPresent = 0
var int hTotal   = 0
if barstate.isconfirmed
    hTotal   += 1
    hPresent += hVolOK ? 1 : 0
hVolRatio = hTotal > 0 ? hPresent / float(hTotal) : 0.0
hHealth   = ta.cum(nz(volEff)) > 0 ? (hVolRatio >= 0.80 ? "ok" : "vol gaps") : "no volume"
hClass    = syminfo.type == "futures" ? "futures" : syminfo.type == "index" ? "index" : syminfo.type == "stock" or syminfo.type == "fund" ? "equity" : syminfo.type == "crypto" ? "crypto" : (syminfo.type == "forex" or syminfo.type == "cfd") ? "fx/cfd" : "generic"

// ============================ HELPERS ========================================
atr     = ta.atr(atrLen)
atrSafe = math.max(nz(atr, high - low), syminfo.mintick)   // never na (warm-up safe)
tol     = atrSafe * touchTolAtr

// Wilson score interval (95%) -> [lower, upper] of a respect rate
f_wilson(hits, total) =>
    float lo = na
    float hi = na
    if total > 0
        z      = 1.96
        phat   = hits / (total * 1.0)
        denom  = 1.0 + z * z / total
        centre = phat + z * z / (2.0 * total)
        margin = z * math.sqrt((phat * (1.0 - phat) + z * z / (4.0 * total)) / total)
        lo := (centre - margin) / denom
        hi := (centre + margin) / denom
    [lo, hi]

// Rescaled-range (R/S) Hurst exponent over `len` bars, built chronologically.
//   H > 0.5 persistent / trending · H < 0.5 anti-persistent / mean-reverting.
f_hurst(len) =>
    float m = 0.0
    for k = 0 to len - 1
        m += nz(math.log(close[k] / close[k + 1]))
    m := m / len
    float cum = 0.0
    float mx  = -1e18
    float mn  =  1e18
    float ss  = 0.0
    for k = 0 to len - 1
        idx = (len - 1) - k                                   // oldest -> newest
        r   = nz(math.log(close[idx] / close[idx + 1]))
        cum += r - m
        mx  := math.max(mx, cum)
        mn  := math.min(mn, cum)
        ss  += math.pow(r - m, 2)
    float rng = mx - mn
    float s   = math.sqrt(ss / len)
    (rng > 0 and s > 0) ? math.log(rng / s) / math.log(len) : 0.5

// (session / naked POC engine lives inline in the ANCHORS layer below, since it
//  carries persistent var state across bars)

// Absorption reference: where AGGRESSIVE order flow was ABSORBED.
//   support  = low of the bar with the heaviest SELL flow that still closed up
//              (selling absorbed -> buyers defended);
//   resistance = high of the bar with the heaviest BUY flow that still closed down
//              (buying absorbed -> sellers defended).
// "Simple" mode falls back to the extreme of the highest-volume directional bar.
f_absLow(len) =>
    bl = float(na)
    bv = -1.0
    for i = 0 to len - 1
        flow = absMode == "Order-flow (BVC)" ? nz(sellVolS[i]) : nz(volEff[i])
        cond = absMode == "Order-flow (BVC)" ? close[i] >= open[i] : close[i] > open[i]
        if cond and flow > bv
            bv := flow
            bl := low[i]
    bl
f_absHigh(len) =>
    bh = float(na)
    bv = -1.0
    for i = 0 to len - 1
        flow = absMode == "Order-flow (BVC)" ? nz(buyVolS[i]) : nz(volEff[i])
        cond = absMode == "Order-flow (BVC)" ? close[i] <= open[i] : close[i] < open[i]
        if cond and flow > bv
            bv := flow
            bh := high[i]
    bh

// push a candidate (level, weight) if valid
f_add(lvArr, wtArr, cond, level, w) =>
    if cond and not na(level) and not na(w)
        array.push(lvArr, level)
        array.push(wtArr, w)
    lvArr

// dominant cluster -> [consensus, envLo, envHi, clusterW, totW, members, avgRel]
f_cluster(levels, weights, band, mostConservative, longSide) =>
    b        = na(band) or band <= 0 ? syminfo.mintick : band   // warm-up safe
    n        = array.size(levels)
    cons     = float(na)
    envLo    = float(na)
    envHi    = float(na)
    clusterW = 0.0
    totW     = n > 0 ? array.sum(weights) : 0.0
    members  = 0
    avgRel   = float(na)
    if n > 0 and totW > 0
        // find the anchor whose ATR-band neighbourhood holds the most weight
        bestC = 0
        bestW = -1.0
        for i = 0 to n - 1
            li = array.get(levels, i)
            wi = 0.0
            for j = 0 to n - 1
                if math.abs(array.get(levels, j) - li) <= b
                    wi += array.get(weights, j)
            if wi > bestW
                bestW := wi
                bestC := i
        cLvl = array.get(levels, bestC)
        clusterW := bestW
        // gather members of the dominant cluster
        mLv = array.new_float(0)
        mWt = array.new_float(0)
        for j = 0 to n - 1
            if math.abs(array.get(levels, j) - cLvl) <= b
                array.push(mLv, array.get(levels, j))
                array.push(mWt, array.get(weights, j))
        members := array.size(mLv)
        if members > 0
            envLo := array.min(mLv)
            envHi := array.max(mLv)
            avgRel := array.sum(mWt) / members
            if mostConservative
                // closest member to price on the correct side
                cons := longSide ? array.max(mLv) : array.min(mLv)
            else
                // weighted median of cluster members (O(m^2), m is tiny)
                half = array.sum(mWt) / 2.0
                for i = 0 to members - 1
                    li = array.get(mLv, i)
                    below = 0.0
                    above = 0.0
                    for j = 0 to members - 1
                        d = array.get(mLv, j)
                        if d < li
                            below += array.get(mWt, j)
                        else if d > li
                            above += array.get(mWt, j)
                    if below <= half and above <= half and na(cons)
                        cons := li
                if na(cons)
                    cons := envLo
    [cons, envLo, envHi, clusterW, totW, members, avgRel]

// ============================ REGIME =========================================
// Three (mostly) independent reads: efficiency, directional strength, vol regime
erNum = math.abs(close - close[erLen])
erDen = math.sum(math.abs(close - close[1]), erLen)
er    = erDen > 0 ? erNum / erDen : 0.0
[diP, diM, adx] = ta.dmi(adxLen, adxLen)
basis = ta.sma(close, bbwLen)
dev   = ta.stdev(close, bbwLen)
bbw   = basis != 0 ? (4.0 * dev) / basis : 0.0
float bbwSma = ta.sma(bbw, 50)   // hoisted: runs every bar (was computed twice, once conditionally)
bbwR  = bbwSma > 0 ? bbw / bbwSma : 1.0
// self-exciting volatility cluster
logRet = math.abs(nz(ta.change(math.log(close))))
var float clustI = 0.0
clustI := clustI * math.exp(-clustDecay) + logRet
cMean  = ta.sma(clustI, 100)
cStd   = ta.stdev(clustI, 100)
clustZ = cStd != 0 ? (clustI - cMean) / cStd : 0.0
volCluster = clustZ > clustThr

// Hurst exponent: persistence (trend) vs anti-persistence (mean reversion)
hurst    = useHurst ? f_hurst(hurstLen) : 0.5
hMeanRev = hurst < 0.5 - hurstBuf                                  // mean-reverting

trendMa  = ta.ema(close, 50)
trending = adx > adxTrd and er > erTrd and (not useHurst or not hMeanRev)
string regime = volCluster and not trending ? "Volatile" : trending ? (close > trendMa ? "Trend Up" : "Trend Dn") : "Range"
bool regTrend = trending and not volCluster

// regime thrash (recent decay-weighted regime flips)
var int regCode = 0
regCode := regime == "Trend Up" ? 2 : regime == "Trend Dn" ? -2 : regime == "Volatile" ? 1 : 0
float thrash = 0.0
for k = 0 to 9
    thrash += nz(regCode[k], 0) != nz(regCode[k + 1], 0) ? math.pow(0.85, k) : 0.0
float thrashScore = math.min(1.0, thrash / 4.0)

// regime quality 0..1 -> feeds confidence and the trail width (now Hurst-aware)
hurstPersist = math.max(0.0, math.min(1.0, (hurst - 0.5) / 0.3))   // 0 at H<=0.5, 1 at H>=0.8
regQuality = math.max(0.0, math.min(1.0,
     0.32 * (regTrend ? 1.0 : 0.0)
   + 0.22 * math.min(1.0, er / math.max(erTrd, 0.01))
   + 0.16 * math.min(1.0, adx / 40.0)
   + 0.15 * (1.0 - thrashScore)
   + 0.15 * (useHurst ? hurstPersist : 0.5)))

// ============================ ANCHORS (Layer 1) ==============================
anchorCond = vwapAnchor == "Session" ? timeframe.change("D") : vwapAnchor == "Week" ? timeframe.change("W") : timeframe.change("M")
[vwapVal, vwapUpper, vwapLower] = ta.vwap(srcPrice, anchorCond, vwapStdMult)

// ---- Session / naked POC engine ----------------------------------------------
// Developing-session volume-at-price (ATR-binned), frozen into a persistent
// "naked POC" each time the session rolls; naked levels are carried forward until
// price revisits them. The committee magnet is the nearest of {naked, developing};
// POC *trust* is judged only on the stable naked levels (see f_calib wiring).
var map<int, float> sessVol   = map.new<int, float>()
var float           sessBinW  = na
var float           devPoc    = na
var float[]         nakedPoc  = array.new_float(0)
pocNewSession = timeframe.change("D")
if pocNewSession
    if not na(devPoc)
        array.push(nakedPoc, devPoc)
        while array.size(nakedPoc) > pocMaxNaked
            array.shift(nakedPoc)
    map.clear(sessVol)
    sessBinW := na
    devPoc   := na
if na(sessBinW)
    sessBinW := math.max(atrSafe * pocBinAtr, syminfo.mintick)
// intrabar volume distribution for a finer profile (falls back to the chart bar)
// True tick data cannot be fetched via request.security_lower_tf, so "1 tick"
// maps to the finest resolution Pine can actually request (1 second); it still
// falls back to the chart bar automatically when seconds data is unavailable.
ltfRes   = (intrabarTf == "1 tick" or intrabarTf == "1 second") ? "1S" : "1"    // Auto / 1 minute -> "1"
chartSec = timeframe.in_seconds(timeframe.period)
ltfSec   = timeframe.in_seconds(ltfRes)
useLtf   = intrabarTf != "Off (chart bar)" and not useBorrow and ltfSec < chartSec
ltfSrc = array.new_float(0)
ltfVol = array.new_float(0)
if useLtf
    [aSrc, aVol] = request.security_lower_tf(syminfo.tickerid, ltfRes, [srcPrice, volume])
    ltfSrc := aSrc
    ltfVol := aVol
// add this bar's volume to the developing profile and recompute the densest bin
f_pocAdd(m, float bw, float pr, float vo) =>
    if not na(pr) and bw > 0
        int   kk0 = int(pr / bw)
        float c0  = map.contains(m, kk0) ? map.get(m, kk0) : 0.0
        map.put(m, kk0, c0 + nz(vo, 1.0))
if useLtf and array.size(ltfVol) > 0
    for si = 0 to array.size(ltfVol) - 1
        f_pocAdd(sessVol, sessBinW, array.get(ltfSrc, si), array.get(ltfVol, si))
else
    f_pocAdd(sessVol, sessBinW, srcPrice, volEff)
if map.size(sessVol) > 0
    ks2   = map.keys(sessVol)
    bK    = 0
    bV    = -1.0
    for j = 0 to array.size(ks2) - 1
        kk = array.get(ks2, j)
        vv = map.get(sessVol, kk)
        if vv > bV
            bV := vv
            bK := kk
    devPoc := bV < 0 ? na : (bK + 0.5) * sessBinW
// nearest naked POC on each side of price (stable levels -> meaningful trust)
float nakedSup = na
float nakedRes = na
if array.size(nakedPoc) > 0
    for i = 0 to array.size(nakedPoc) - 1
        lvl = array.get(nakedPoc, i)
        if lvl < close and (na(nakedSup) or (close - lvl) < (close - nakedSup))
            nakedSup := lvl
        if lvl > close and (na(nakedRes) or (lvl - close) < (nakedRes - close))
            nakedRes := lvl
// committee magnet = nearest of {naked, developing} on each side
float pocSup = nakedSup
float pocRes = nakedRes
if not na(devPoc)
    if devPoc < close and (na(pocSup) or (close - devPoc) < (close - pocSup))
        pocSup := devPoc
    if devPoc > close and (na(pocRes) or (devPoc - close) < (pocRes - close))
        pocRes := devPoc
float poc = devPoc                                   // dashboard shows the live POC

var float fvgBullCE = na
var float fvgBearCE = na
if low > high[2]
    fvgBullCE := (low + high[2]) / 2.0
if high < low[2]
    fvgBearCE := (high + low[2]) / 2.0

phP = ta.pivothigh(pivLeft, pivRight)
plP = ta.pivotlow(pivLeft, pivRight)
var float lastPL = na
var float lastPH = na
if not na(plP)
    lastPL := plP
if not na(phP)
    lastPH := phP

absLow  = f_absLow(absLen)
absHigh = f_absHigh(absLen)

// ============================ RELIABILITY (Layer 2) ==========================
// rolling-capped respect counts per anchor type -> Wilson lower bound = trust
var int[] calTot = array.new_int(5, 0)
var int[] calHit = array.new_int(5, 0)

f_calib(idx, Ls, Rs) =>
    hit = false
    tot = false
    // support: price travels DOWN to the level, then we need a CLEAR verdict —
    // a bounce (close clearly ABOVE the zone) = respected, a break (close clearly
    // BELOW) = failed. A close INSIDE the zone is ambiguous and is NOT logged,
    // which stops a level that merely hugs price (a rolling POC) from trivially
    // scoring 100%.
    if not na(Ls) and low <= Ls + tol and nz(low[1], low) > Ls + tol
        if close > Ls + tol
            tot := true
            hit := true
        else if close < Ls - tol
            tot := true
    // resistance: travels UP to the level; clear rejection vs clear break.
    if not na(Rs) and high >= Rs - tol and nz(high[1], high) < Rs - tol
        if close < Rs - tol
            tot := true
            hit := true
        else if close > Rs + tol
            tot := true
    if tot
        array.set(calTot, idx, array.get(calTot, idx) + 1)
        if hit
            array.set(calHit, idx, array.get(calHit, idx) + 1)
        // rolling cap: halve both when total saturates so reputation adapts
        if array.get(calTot, idx) >= calCap
            array.set(calTot, idx, int(array.get(calTot, idx) / 2))
            array.set(calHit, idx, int(array.get(calHit, idx) / 2))

f_calib(0, useVWAP ? vwapLower : na,                       useVWAP ? vwapUpper : na)
// POC uses a FORWARD-REACTION respect test (below), not the same-bar f_calib —
// a magnet level trivially "holds" on the close of the touch bar.
f_calib(2, useFVG ? fvgBullCE : na,                        useFVG ? fvgBearCE : na)
f_calib(3, useSwing ? lastPL : na,                         useSwing ? lastPH : na)
f_calib(4, useAbsorp ? absLow : na,                        useAbsorp ? absHigh : na)

// ---- POC forward-reaction respect engine -------------------------------------
// Queue each fresh touch of a naked POC, then resolve it `pocRespHz` bars later by
// first-touch: did price reject away from the level by pocRespATR·ATR (respected)
// before breaking through it by the same margin (failed)? Writes calTot/calHit[1].
var int[]   pqBar = array.new_int(0)
var float[] pqLvl = array.new_float(0)
var float[] pqAtr = array.new_float(0)
var int[]   pqDir = array.new_int(0)                       // +1 support · -1 resistance
if usePOC and barstate.isconfirmed
    // fresh touch from the correct side
    if not na(nakedSup) and low <= nakedSup + tol and nz(low[1], low) > nakedSup + tol
        array.push(pqBar, bar_index)
        array.push(pqLvl, nakedSup)
        array.push(pqAtr, atrSafe)
        array.push(pqDir, 1)
    if not na(nakedRes) and high >= nakedRes - tol and nz(high[1], high) < nakedRes - tol
        array.push(pqBar, bar_index)
        array.push(pqLvl, nakedRes)
        array.push(pqAtr, atrSafe)
        array.push(pqDir, -1)
    // resolve
    int qi = 0
    while qi < array.size(pqBar)
        int   pAge = bar_index - array.get(pqBar, qi)
        float pLvl = array.get(pqLvl, qi)
        float pA   = array.get(pqAtr, qi)
        int   pDr  = array.get(pqDir, qi)
        float rejUp = pLvl + pocRespATR * pA
        float rejDn = pLvl - pocRespATR * pA
        bool respected = pDr > 0 ? high >= rejUp : low  <= rejDn   // rejected AWAY from level
        bool broke     = pDr > 0 ? low  <= rejDn : high >= rejUp   // pushed THROUGH level
        bool done = false
        bool win  = false
        if pAge >= 1 and respected and broke
            done := true                                          // ambiguous -> discard (not counted)
        else if pAge >= 1 and respected
            done := true
            win  := true
        else if pAge >= 1 and broke
            done := true
        else if pAge >= pocRespHz
            done := true                                          // timeout -> discard
        if done
            if win or broke                                       // only count clean reject/break
                if not (respected and broke)
                    array.set(calTot, 1, array.get(calTot, 1) + 1)
                    if win
                        array.set(calHit, 1, array.get(calHit, 1) + 1)
                    if array.get(calTot, 1) >= calCap
                        array.set(calTot, 1, int(array.get(calTot, 1) / 2))
                        array.set(calHit, 1, int(array.get(calHit, 1) / 2))
            array.remove(pqBar, qi)
            array.remove(pqLvl, qi)
            array.remove(pqAtr, qi)
            array.remove(pqDir, qi)
        else
            qi += 1
    while array.size(pqBar) > 200
        array.shift(pqBar)
        array.shift(pqLvl)
        array.shift(pqAtr)
        array.shift(pqDir)

f_trust(idx) =>
    t = array.get(calTot, idx)
    h = array.get(calHit, idx)
    [lo, hiU] = f_wilson(h, t)
    t < minSamples ? priorW : nz(lo, priorW)

relV  = f_trust(0)
relP  = f_trust(1)
relF  = f_trust(2)
relS  = f_trust(3)
relAb = f_trust(4)

// ============================ CONSENSUS (Layer 3) ============================
band = atrSafe * clusterAtr
mostCons = consMode == "Most conservative"

// support-side committee (anchors below price)
sLv = array.new_float(0)
sWt = array.new_float(0)
f_add(sLv, sWt, useVWAP   and not na(vwapLower) and vwapLower < close, vwapLower, relV)
f_add(sLv, sWt, usePOC    and not na(pocSup),                         pocSup,    relP)
f_add(sLv, sWt, useFVG    and not na(fvgBullCE) and fvgBullCE < close, fvgBullCE, relF)
f_add(sLv, sWt, useSwing  and not na(lastPL) and lastPL < close,      lastPL,    relS)
f_add(sLv, sWt, useAbsorp and not na(absLow) and absLow < close,      absLow,    relAb)
[sCons, sLo, sHi, sCW, sTW, sMem, sRel] = f_cluster(sLv, sWt, band, mostCons, true)

// resistance-side committee (anchors above price)
rLv = array.new_float(0)
rWt = array.new_float(0)
f_add(rLv, rWt, useVWAP   and not na(vwapUpper) and vwapUpper > close, vwapUpper, relV)
f_add(rLv, rWt, usePOC    and not na(pocRes),                         pocRes,    relP)
f_add(rLv, rWt, useFVG    and not na(fvgBearCE) and fvgBearCE > close, fvgBearCE, relF)
f_add(rLv, rWt, useSwing  and not na(lastPH) and lastPH > close,      lastPH,    relS)
f_add(rLv, rWt, useAbsorp and not na(absHigh) and absHigh > close,    absHigh,   relAb)
[rCons, rLoB, rHiB, rCW, rTW, rMem, rRel] = f_cluster(rLv, rWt, band, mostCons, false)

// prune naked POCs that price has now revisited (filled) — done AFTER the
// committees and f_calib have judged this bar's touch, so a fill still counts.
if array.size(nakedPoc) > 0
    int pi = 0
    while pi < array.size(nakedPoc)
        float lvl = array.get(nakedPoc, pi)
        if high >= lvl and low <= lvl
            array.remove(nakedPoc, pi)
        else
            pi += 1

// ---- confidence per side (measured on the CLUSTER, so it actually varies) ---
f_conf(cons, lo, hi, cw, tw, rel) =>
    c = 0.0
    if not na(cons) and tw > 0
        agree = cw / tw                                            // fraction of committee in cluster
        tight = 1.0 - math.min(1.0, (hi - lo) / math.max(band, syminfo.mintick))
        c := wAgree * agree + wTight * tight + wRel * nz(rel) + wReg * regQuality
        c := math.max(0.0, math.min(1.0, c)) * (1.0 - 0.5 * thrashScore)
    c
sConf = f_conf(sCons, sLo, sHi, sCW, sTW, sRel)
rConf = f_conf(rCons, rLoB, rHiB, rCW, rTW, rRel)

// ============================ ADAPTIVE BANDS (Layer 4 backbone) ==============
volRank = ta.percentrank(atr, rankLen) / 100.0
scaler  = multLoK + (multHiK - multLoK) * volRank
effMult = baseMult * scaler * (1.0 + chopK * (1.0 - er)) * (regTrend ? 1.0 : rangeWiden)  // widen in chop / range
// mid-anchored adaptive band (the engine's default)
upAdap  = hl2 + effMult * atr
dnAdap  = hl2 - effMult * atr
// Chandelier band: hangs from the recent extreme minus/plus ATR (holds trends)
chandHi = ta.highest(high, chandLen)
chandLo = ta.lowest(low,  chandLen)
upChand = chandLo + effMult * atr
dnChand = chandHi - effMult * atr
upBand  = trailMode == "Chandelier" ? upChand : trailMode == "Blend" ? (upAdap + upChand) / 2.0 : upAdap
dnBand  = trailMode == "Chandelier" ? dnChand : trailMode == "Blend" ? (dnAdap + dnChand) / 2.0 : dnAdap

// ============================ THE TRAIL (Layer 5) ===========================
// Confidence governs WHICH stop, never parks it on price (no v1 feedback loop).
//   high conf -> pull toward structural consensus, floored atrFloor*ATR off price
//   low  conf -> the wide adaptive band -> fewer flips
var int   dir   = 1
var float trail = na
var int   lastFlip = na

longFloor  = close - atrFloor * atr
shortFloor = close + atrFloor * atr
longTarget  = (sConf >= confStruct and not na(sCons)) ? math.min(sCons, longFloor)  : dnBand
shortTarget = (rConf >= confStruct and not na(rCons)) ? math.max(rCons, shortFloor) : upBand

// confirmation breach grows in chop and when not trending -> far fewer flips in range
confKeff = confK + chopConfirmK * thrashScore + (regTrend ? 0.0 : rangeConfirmAdd)

if na(trail)
    trail := dir == 1 ? longTarget : shortTarget
    lastFlip := bar_index
else
    canFlip = na(lastFlip) or (bar_index - lastFlip) >= minHold
    if dir == 1
        trail := math.max(trail, longTarget)
        if canFlip and close < trail - confKeff * atr
            dir := -1
            trail := shortTarget
            lastFlip := bar_index
    else
        trail := math.min(trail, shortTarget)
        if canFlip and close > trail + confKeff * atr
            dir := 1
            trail := longTarget
            lastFlip := bar_index

// active-side readouts
aConf = dir == 1 ? sConf : rConf
aLo   = dir == 1 ? sLo   : rLoB
aHi   = dir == 1 ? sHi   : rHiB
aMem  = dir == 1 ? sMem  : rMem
aTot  = dir == 1 ? array.size(sLv) : array.size(rLv)
qScore = int(math.round(aConf * 100))
sizeTxt = aConf >= minConf + 0.20 ? "FULL" : aConf >= minConf ? "HALF" : "STAND ASIDE"

// strength tier for confirmed flips
flipUp = dir == 1  and dir[1] == -1
flipDn = dir == -1 and dir[1] == 1
tier   = aConf >= 0.70 ? 2 : aConf >= 0.50 ? 1 : 0

// ============================ CALIBRATION (Layer 6) =========================
// Forward-test the trail's OWN flips by triple-barrier first-touch, measure the
// EDGE over an identically-measured unconditional base rate, split by tier and
// regime, and audit it with a walk-forward IS->OOS split and a runs test.
int regBucket = regTrend ? 1 : regime == "Volatile" ? 2 : 0   // 0 range 1 trend 2 vol

// per-tier (0 WEAK 1 MOD 2 STRONG) and per-regime (0 range 1 trend 2 vol) tallies
var int[] tierTot = array.new_int(3, 0)
var int[] tierHit = array.new_int(3, 0)
var int[] tierUp  = array.new_int(3, 0)
var int[] tierDn  = array.new_int(3, 0)
var int[] cregTot = array.new_int(3, 0)
var int[] cregHit = array.new_int(3, 0)
var int[] cregUp  = array.new_int(3, 0)
var int[] cregDn  = array.new_int(3, 0)
var int cfTot = 0
var int cfHit = 0
// walk-forward IS / OOS
var int  isN = 0
var int  isHit = 0
var int  oosN = 0
var int  oosHit = 0
var bool isFrozen = false
// Wald-Wolfowitz runs-test state
var int rtN1 = 0
var int rtN2 = 0
var int rtRuns = 0
var int rtPrev = -2
// pending flip events
var int[]   fqBar  = array.new_int(0)
var float[] fqPx   = array.new_float(0)
var float[] fqAtr  = array.new_float(0)
var int[]   fqDir  = array.new_int(0)
var int[]   fqTier = array.new_int(0)
var int[]   fqReg  = array.new_int(0)
var float[] fqConf = array.new_float(0)
// confidence-reliability bins (0-.2 .2-.4 .4-.6 .6-.8 .8-1) + Brier accumulator
var int[]   cbTot   = array.new_int(5, 0)
var int[]   cbHit   = array.new_int(5, 0)
var float   brierSum = 0.0
var int     brierN   = 0
var float   sumConf  = 0.0
// unconditional base-rate sampler
var int baseN  = 0
var int baseUp = 0
var int baseDn = 0
var int[]   bqBar = array.new_int(0)
var float[] bqPx  = array.new_float(0)
var float[] bqAtr = array.new_float(0)

if calEnable and barstate.isconfirmed and not na(atr) and atr > 0
    // ---- log a new flip event ----
    if flipUp or flipDn
        array.push(fqBar, bar_index)
        array.push(fqPx,  close)
        array.push(fqAtr, atrSafe)
        array.push(fqDir, flipUp ? 1 : -1)
        array.push(fqTier, tier)
        array.push(fqReg, regBucket)
        array.push(fqConf, aConf)
    // ---- resolve pending flips (first-touch triple barrier) ----
    int i = 0
    while i < array.size(fqBar)
        int   age = bar_index - array.get(fqBar, i)
        float p0  = array.get(fqPx, i)
        float a0  = array.get(fqAtr, i)
        int   dr  = array.get(fqDir, i)
        float fav = dr > 0 ? p0 + calFavATR * a0 : p0 - calFavATR * a0
        float adv = dr > 0 ? p0 - calStopATR * a0 : p0 + calStopATR * a0
        bool favHit = dr > 0 ? high >= fav : low  <= fav
        bool advHit = dr > 0 ? low  <= adv : high >= adv
        bool resolved = false
        bool win = false
        if age >= 1 and favHit and advHit
            resolved := true
            win := false                                  // ambiguous same-bar -> conservative miss
        else if age >= 1 and favHit
            resolved := true
            win := true
        else if age >= 1 and advHit
            resolved := true
            win := false
        else if age >= calHorizon
            resolved := true
            win := false                                  // timeout -> no follow-through
        if resolved
            int ti = array.get(fqTier, i)
            int rg = array.get(fqReg, i)
            cfTot += 1
            cfHit += win ? 1 : 0
            array.set(tierTot, ti, array.get(tierTot, ti) + 1)
            array.set(cregTot, rg, array.get(cregTot, rg) + 1)
            if win
                array.set(tierHit, ti, array.get(tierHit, ti) + 1)
                array.set(cregHit, rg, array.get(cregHit, rg) + 1)
            if dr > 0
                array.set(tierUp, ti, array.get(tierUp, ti) + 1)
                array.set(cregUp, rg, array.get(cregUp, rg) + 1)
            else
                array.set(tierDn, ti, array.get(tierDn, ti) + 1)
                array.set(cregDn, rg, array.get(cregDn, rg) + 1)
            // runs test on the chronological win/loss sequence
            int o = win ? 1 : 0
            // calibration of the confidence number: Brier + reliability bins
            float cf = array.get(fqConf, i)
            brierSum += math.pow(cf - o, 2)
            brierN   += 1
            sumConf  += cf
            int cbin = math.min(4, math.max(0, int(cf * 5)))
            array.set(cbTot, cbin, array.get(cbTot, cbin) + 1)
            if o == 1
                array.set(cbHit, cbin, array.get(cbHit, cbin) + 1)
            if o == 1
                rtN1 += 1
            else
                rtN2 += 1
            if rtPrev == -2 or o != rtPrev
                rtRuns += 1
            rtPrev := o
            // walk-forward IS / OOS partition
            if not isFrozen
                isN += 1
                isHit += o
                if isN >= calIsTarget
                    isFrozen := true
            else
                oosN += 1
                oosHit += o
            array.remove(fqBar, i)
            array.remove(fqPx, i)
            array.remove(fqAtr, i)
            array.remove(fqDir, i)
            array.remove(fqTier, i)
            array.remove(fqReg, i)
            array.remove(fqConf, i)
        else
            i += 1
    // ---- unconditional base-rate sampler (one event per confirmed bar) ----
    array.push(bqBar, bar_index)
    array.push(bqPx,  close)
    array.push(bqAtr, atrSafe)
    int b = 0
    while b < array.size(bqBar)
        int   age2 = bar_index - array.get(bqBar, b)
        float bp0  = array.get(bqPx, b)
        float ba0  = array.get(bqAtr, b)
        bool upHit = high >= bp0 + calFavATR * ba0
        bool dnHit = low  <= bp0 - calFavATR * ba0
        bool bres = false
        int  oc = 0                                       // 0 none/ambiguous · 1 up · 2 dn
        if age2 >= 1 and upHit and dnHit
            bres := true
        else if age2 >= 1 and upHit
            bres := true
            oc := 1
        else if age2 >= 1 and dnHit
            bres := true
            oc := 2
        else if age2 >= calHorizon
            bres := true
        if bres
            baseN += 1
            baseUp += oc == 1 ? 1 : 0
            baseDn += oc == 2 ? 1 : 0
            array.remove(bqBar, b)
            array.remove(bqPx, b)
            array.remove(bqAtr, b)
        else
            b += 1
    // ---- bound memory ----
    while array.size(fqBar) > 500
        array.shift(fqBar)
        array.shift(fqPx)
        array.shift(fqAtr)
        array.shift(fqDir)
        array.shift(fqTier)
        array.shift(fqReg)
        array.shift(fqConf)
    while array.size(bqBar) > 500
        array.shift(bqBar)
        array.shift(bqPx)
        array.shift(bqAtr)

// base rates + edge helper
baseUpRate = baseN > 0 ? baseUp / float(baseN) : na
baseDnRate = baseN > 0 ? baseDn / float(baseN) : na
// edge for a cell given hits/total and the up/down event counts (direction-weighted base)
f_edge(int hit, int tot, int up, int dn) =>
    float hr   = tot > 0 ? hit / float(tot) : na
    float wb   = (up + dn) > 0 and not na(baseUpRate) ? (up * baseUpRate + dn * baseDnRate) / (up + dn) : na
    [lo, hiU]  = f_wilson(hit, tot)
    float edge = (na(hr) or na(wb)) ? na : hr - wb
    bool  sig  = not na(lo) and not na(wb) and lo > wb
    [hr, wb, edge, lo, hiU, sig]
// runs-test Z and walk-forward degradation (computed once for the panel)
float rtZ = na
bool  rtStreaky = false
int   rtTot = rtN1 + rtN2
if rtTot >= 20 and rtN1 > 0 and rtN2 > 0
    float mu = 2.0 * rtN1 * rtN2 / rtTot + 1.0
    float vr = 2.0 * rtN1 * rtN2 * (2.0 * rtN1 * rtN2 - rtTot) / (math.pow(rtTot, 2) * (rtTot - 1))
    if vr > 0
        rtZ := (rtRuns - mu) / math.sqrt(vr)
        rtStreaky := math.abs(rtZ) > 1.96
float isRate    = isN  > 0 ? isHit  / float(isN)  : na
float oosRate   = oosN > 0 ? oosHit / float(oosN) : na
float wfDegrade = (not na(isRate) and not na(oosRate)) ? oosRate - isRate : na

// calibrated confidence: map raw confidence through the reliability bin it lands in
int   aBin    = math.min(4, math.max(0, int(aConf * 5)))
float calConf = array.get(cbTot, aBin) >= calMinSamp ? array.get(cbHit, aBin) / float(array.get(cbTot, aBin)) : na
int   qCal    = na(calConf) ? na : int(math.round(calConf * 100))
// Brier score of the confidence number + over/under-confidence gap
float brier    = brierN > 0 ? brierSum / brierN : na
float meanPred = brierN > 0 ? sumConf / brierN : na
float realized = cfTot > 0 ? cfHit / float(cfTot) : na
float calGap   = (not na(meanPred) and not na(realized)) ? meanPred - realized : na

// cost model: gross R-expectancy for the (possibly asymmetric) target/stop barrier, net of cost.
// win pays target/stop in R, loss pays −1R, so gross R = hit·(rr+1) − 1 with rr = target/stop.
float rrCal    = calStopATR > 0 ? calFavATR / calStopATR : na
float grossRc  = (na(realized) or na(rrCal)) ? na : realized * (rrCal + 1.0) - 1.0
float netRc    = na(grossRc) ? na : grossRc - costR


// ============================ HTF INVALIDATION STOP =========================
// self-contained adaptive Supertrend, evaluated in the HTF context
f_htf() =>
    a   = ta.atr(atrLen)
    e1n = math.abs(close - close[erLen])
    e1d = math.sum(math.abs(close - close[1]), erLen)
    e1  = e1d > 0 ? e1n / e1d : 0.0
    vr  = ta.percentrank(a, rankLen) / 100.0
    m   = baseMult * (multLoK + (multHiK - multLoK) * vr) * (1.0 + chopK * (1.0 - e1))
    up  = hl2 + m * a
    dn  = hl2 - m * a
    var float st = na
    var int   sd = 1
    st := na(st) ? dn : sd == 1 ? math.max(st, dn) : math.min(st, up)
    if sd == 1 and close < st
        sd := -1
        st := up
    else if sd == -1 and close > st
        sd := 1
        st := dn
    [st, sd]
// HTF string built from the chart's actual seconds × multiplier, so it is a
// genuine HIGHER timeframe on every base (minute, hour, day, week, seconds).
// The old "multiplier × mult" produced a raw minute count that mis-mapped on
// daily/weekly/seconds charts (e.g. a Daily chart asked for 5 MINUTES).
int _htfSecs = timeframe.in_seconds() * htfMult
htfTfStr = _htfSecs % 604800 == 0 ? str.tostring(_htfSecs / 604800) + "W" : _htfSecs % 86400 == 0 ? str.tostring(_htfSecs / 86400) + "D" : _htfSecs % 60 == 0 ? str.tostring(_htfSecs / 60) : str.tostring(_htfSecs) + "S"
[htfStop, htfDir] = request.security(syminfo.tickerid, htfTfStr, f_htf(), lookahead = barmerge.lookahead_off)

// ============================ VISUALS =======================================
baseHue  = dir == 1 ? uiBull : uiBear
trailCol = color.from_gradient(aConf, 0.0, 1.0, color.new(baseHue, 72), color.new(baseHue, 0))
plot(dir == 1  ? trail : na, "Trail (up)",   color = trailCol, linewidth = 2, style = plot.style_linebr)
plot(dir == -1 ? trail : na, "Trail (down)", color = trailCol, linewidth = 2, style = plot.style_linebr)

// consensus cluster zone (small by construction: only the agreeing members)
zHi = showZone ? aHi : na
zLo = showZone ? aLo : na
pZHi = plot(zHi, "Cluster hi", color = color.new(uiGold, 100))
pZLo = plot(zLo, "Cluster lo", color = color.new(uiGold, 100))
zoneCol = color.from_gradient(aConf, 0.0, 1.0, color.new(uiNeut, 90), color.new(uiGold, 80))
fill(pZHi, pZLo, color = showZone ? zoneCol : na, title = "Consensus zone")

// HTF invalidation stop (wider; the real "trend is wrong" line)
htfCol = htfDir == 1 ? color.new(uiBull, 55) : color.new(uiBear, 55)
plot(showHtf ? htfStop : na, "HTF stop", color = htfCol, linewidth = 1, style = plot.style_stepline)

// ---- plain-language state (mirrors the SUGGESTION row) ----
//   1 = bullish · -1 = bearish · 0 = no clear trend / wait
int dispState = sizeTxt == "STAND ASIDE" ? 0 : dir == 1 ? 1 : -1

// faint state background: teal = bullish, red = bearish, grey = wait
stateBg = dispState == 1 ? color.new(uiBull, 92) : dispState == -1 ? color.new(uiBear, 92) : color.new(uiNeut, 90)
bgcolor(warnBg ? stateBg : na, title = "State tint")

// optional bar colouring by state (off by default; native candles otherwise)
barcolor(colorBars ? (dispState == 1 ? uiBull : dispState == -1 ? uiBear : color.new(uiNeut, 40)) : na, title = "State bars")

// confirmed-flip labels, sized by strength tier (context, not mechanical entry)
tierCol = tier == 2 ? baseHue : tier == 1 ? color.new(baseHue, 25) : color.new(uiNeut, 10)
tierSz  = tier == 2 ? size.normal : tier == 1 ? size.small : size.tiny
alignUp = not htfAlignLabels or htfDir == 1
alignDn = not htfAlignLabels or htfDir == -1
labelOK = showLabels and aConf >= labelMinConf
var label[] flipLabels = array.new_label(0)
f_flipLabel(bool up) =>
    string word = plainLabels ? ((tier == 2 ? "STRONG " : "") + (up ? "BUY" : "SELL")) : ((tier == 2 ? "STRONG " : tier == 1 ? "MOD " : "WEAK ") + str.tostring(qScore))
    label lb = label.new(bar_index, trail, (up ? "▲ " : "▼ ") + word, style = up ? label.style_label_up : label.style_label_down, color = tierCol, textcolor = f_chip(tierCol), size = tierSz)
    array.push(flipLabels, lb)
    while array.size(flipLabels) > maxFlipLabels
        label.delete(array.shift(flipLabels))
if labelOK and flipUp and alignUp
    f_flipLabel(true)
if labelOK and flipDn and alignDn
    f_flipLabel(false)

// diagnostics (data window only)
plot(aConf * 100,      "EXP_ConfidencePct", color = color.new(color.blue, 100), display = display.data_window)
plot(regQuality * 100, "EXP_RegimeQPct",   color = color.new(color.blue, 100), display = display.data_window)
plot(thrashScore,      "EXP_Thrash",        color = color.new(color.blue, 100), display = display.data_window)

// ============================ DASHBOARD =====================================
f_pos(s) => s == "top_left" ? position.top_left : s == "bottom_right" ? position.bottom_right : s == "bottom_left" ? position.bottom_left : position.top_right

f_trustTxt(idx) =>
    t = array.get(calTot, idx)
    h = array.get(calHit, idx)
    t < minSamples ? "warming" : str.tostring(math.round(h * 100.0 / t)) + "%"

f_trustCol(idx) =>
    t = array.get(calTot, idx)
    h = array.get(calHit, idx)
    t < minSamples ? uiNeut : color.from_gradient(h * 1.0 / t, 0.30, 0.85, uiBear, uiBull)

f_lvl(useIt, sup, res) => not useIt ? "off" : dir == 1 ? (na(sup) ? "—" : str.tostring(sup, format.mintick)) : (na(res) ? "—" : str.tostring(res, format.mintick))

var table tb = table.new(f_pos(tblPos), 3, 12, border_width = 1, border_color = cGrid, frame_color = cGrid, frame_width = 1)
f_cell(c, r, t, col, ha) => table.cell(tb, c, r, t, text_size = size.small, text_color = col, bgcolor = cPanel, text_halign = ha)
f_hdr(c, t, ha)         => table.cell(tb, c, 0, t, text_size = size.small, text_color = cTxt, bgcolor = color.new(uiGold, 70), text_halign = ha)

if showTable and barstate.islast
    f_hdr(0, "COMMITTEE", text.align_left)
    f_hdr(1, "LEVEL", text.align_right)
    f_hdr(2, "TRUST", text.align_right)

    f_cell(0, 1, "VWAP band", cTxt, text.align_left)
    f_cell(1, 1, f_lvl(useVWAP, vwapLower, vwapUpper), cTxt, text.align_right)
    f_cell(2, 1, f_trustTxt(0), f_trustCol(0), text.align_right)

    f_cell(0, 2, "POC", cTxt, text.align_left)
    f_cell(1, 2, not usePOC ? "off" : na(poc) ? "—" : str.tostring(poc, format.mintick), cTxt, text.align_right)
    f_cell(2, 2, f_trustTxt(1), f_trustCol(1), text.align_right)

    f_cell(0, 3, "FVG CE", cTxt, text.align_left)
    f_cell(1, 3, f_lvl(useFVG, fvgBullCE, fvgBearCE), cTxt, text.align_right)
    f_cell(2, 3, f_trustTxt(2), f_trustCol(2), text.align_right)

    f_cell(0, 4, "Swing", cTxt, text.align_left)
    f_cell(1, 4, f_lvl(useSwing, lastPL, lastPH), cTxt, text.align_right)
    f_cell(2, 4, f_trustTxt(3), f_trustCol(3), text.align_right)

    f_cell(0, 5, "Absorption", cTxt, text.align_left)
    f_cell(1, 5, f_lvl(useAbsorp, absLow, absHigh), cTxt, text.align_right)
    f_cell(2, 5, f_trustTxt(4), f_trustCol(4), text.align_right)

    f_cell(0, 6, "CONSENSUS", cTxt, text.align_left)
    f_cell(1, 6, na(trail) ? "—" : str.tostring(trail, format.mintick), uiGold, text.align_right)
    f_cell(2, 6, str.tostring(aMem) + "/" + str.tostring(aTot) + " agree", cTxt, text.align_right)

    confC = color.from_gradient(aConf, 0.0, 1.0, uiBear, uiBull)
    f_cell(0, 7, "CONFIDENCE", cTxt, text.align_left)
    f_cell(1, 7, str.tostring(qScore) + (na(qCal) ? " / 100" : " → " + str.tostring(qCal)), confC, text.align_right)
    f_cell(2, 7, dir == 1 ? "LONG" : "SHORT", dir == 1 ? uiBull : uiBear, text.align_right)

    regC = regTrend ? uiBull : regime == "Volatile" ? uiBear : uiGold
    f_cell(0, 8, "REGIME", cTxt, text.align_left)
    f_cell(1, 8, regime, regC, text.align_right)
    hurstC = not useHurst ? cTxt : hurst > 0.53 ? uiBull : hurst < 0.47 ? uiBear : uiGold
    f_cell(2, 8, (useHurst ? "H " + str.tostring(hurst, "0.00") + " · " : "") + "ADX" + str.tostring(adx, "0"), hurstC, text.align_right)

    f_cell(0, 9, "HTF stop", cTxt, text.align_left)
    f_cell(1, 9, na(htfStop) ? "—" : str.tostring(htfStop, format.mintick), htfDir == 1 ? uiBull : uiBear, text.align_right)
    f_cell(2, 9, "HTF " + htfTfStr, cTxt, text.align_right)

    sugC = sizeTxt == "FULL" ? uiBull : sizeTxt == "HALF" ? uiGold : uiBear
    table.cell(tb, 0, 10, "SUGGESTION", text_size = size.small, text_color = cTxt, bgcolor = color.new(sugC, 78), text_halign = text.align_left)
    table.cell(tb, 1, 10, sizeTxt, text_size = size.small, text_color = sugC, bgcolor = color.new(sugC, 78), text_halign = text.align_right)
    table.cell(tb, 2, 10, regime == "Volatile" ? "vol" : "ok", text_size = size.small, text_color = cTxt, bgcolor = color.new(sugC, 78), text_halign = text.align_right)

    dataCol = hHealth == "ok" ? uiBull : hHealth == "no volume" ? uiBear : uiGold
    f_cell(0, 11, "DATA", cTxt, text.align_left)
    f_cell(1, 11, hHealth + (useBorrow ? " · borrowed" : ""), dataCol, text.align_right)
    f_cell(2, 11, hClass, cTxt, text.align_right)

// ============================ CALIBRATION PANEL =============================
// Past-only. HIT = a flip reached the target barrier before the stop within the
// horizon. BASE = the same move's unconditional rate (direction-weighted).
// EDGE = HIT - BASE; only a positive edge beats chance. ★ = Wilson lower bound
// clears base. Read the EDGE column, never the hit-rate alone.
var table cal = table.new(f_pos(calPos), 6, 13, border_width = 1, border_color = cGrid, frame_color = cGrid, frame_width = 1)
f_calHdr(c, t, ha) => table.cell(cal, c, 0, t, text_size = size.tiny, text_color = f_chip(uiGold), bgcolor = color.new(uiGold, 30), text_halign = ha)
f_calCell(c, r, t, col, ha) => table.cell(cal, c, r, t, text_size = size.tiny, text_color = col, bgcolor = cPanel, text_halign = ha)
f_calRow(int r, string lbl, int hit, int tot, int up, int dn) =>
    [hr, wb, edge, lo, hiU, sig] = f_edge(hit, tot, up, dn)
    string hTxt = tot == 0 ? "—" : tot < calMinSamp ? "warm" : str.tostring(math.round(hr * 100)) + "%"
    string bTxt = na(wb) ? "—" : str.tostring(math.round(wb * 100)) + "%"
    string eTxt = na(edge) ? "—" : (edge >= 0 ? "+" : "") + str.tostring(math.round(edge * 100)) + (sig ? " ★" : "")
    string ciTxt = na(lo) ? "—" : str.tostring(math.round(lo * 100)) + "–" + str.tostring(math.round(hiU * 100))
    color eCol = na(edge) ? uiNeut : tot < calMinSamp ? uiNeut : edge > 0 ? uiBull : edge < 0 ? uiBear : uiGold
    f_calCell(0, r, lbl, cTxt, text.align_left)
    f_calCell(1, r, str.tostring(tot), cTxt, text.align_center)
    f_calCell(2, r, hTxt, tot < calMinSamp ? uiNeut : cTxt, text.align_center)
    f_calCell(3, r, bTxt, uiNeut, text.align_center)
    f_calCell(4, r, eTxt, eCol, text.align_center)
    f_calCell(5, r, ciTxt, cTxt, text.align_right)
if calEnable and showCalib and barstate.islast
    f_calHdr(0, "CALIBRATION", text.align_left)
    f_calHdr(1, "n", text.align_center)
    f_calHdr(2, "Hit", text.align_center)
    f_calHdr(3, "Base", text.align_center)
    f_calHdr(4, "Edge", text.align_center)
    f_calHdr(5, "95% CI", text.align_right)
    f_calRow(1, "STRONG", array.get(tierHit, 2), array.get(tierTot, 2), array.get(tierUp, 2), array.get(tierDn, 2))
    f_calRow(2, "MOD",    array.get(tierHit, 1), array.get(tierTot, 1), array.get(tierUp, 1), array.get(tierDn, 1))
    f_calRow(3, "WEAK",   array.get(tierHit, 0), array.get(tierTot, 0), array.get(tierUp, 0), array.get(tierDn, 0))
    f_calRow(4, "ALL",    cfHit, cfTot, array.get(tierUp,0)+array.get(tierUp,1)+array.get(tierUp,2), array.get(tierDn,0)+array.get(tierDn,1)+array.get(tierDn,2))
    f_calRow(5, "· range",array.get(cregHit, 0), array.get(cregTot, 0), array.get(cregUp, 0), array.get(cregDn, 0))
    f_calRow(6, "· trend",array.get(cregHit, 1), array.get(cregTot, 1), array.get(cregUp, 1), array.get(cregDn, 1))
    f_calRow(7, "· vol",  array.get(cregHit, 2), array.get(cregTot, 2), array.get(cregUp, 2), array.get(cregDn, 2))
    // walk-forward IS -> OOS row
    string wfTxt = not isFrozen ? "warming " + str.tostring(isN) + "/" + str.tostring(calIsTarget) : oosN < 5 ? "live forming" : str.tostring(math.round(isRate * 100)) + "→" + str.tostring(math.round(oosRate * 100)) + " (" + str.tostring(math.round(nz(wfDegrade) * 100), "+0;-0") + ")"
    color wfCol = (not isFrozen or oosN < 5 or na(wfDegrade)) ? uiNeut : wfDegrade >= -0.05 ? uiBull : wfDegrade <= -0.12 ? uiBear : uiGold
    f_calCell(0, 8, "IS→live Δ", cTxt, text.align_left)
    f_calCell(1, 8, wfTxt, wfCol, text.align_left)
    f_calCell(2, 8, "", cTxt, text.align_center)
    f_calCell(3, 8, "", cTxt, text.align_center)
    f_calCell(4, 8, "", cTxt, text.align_center)
    f_calCell(5, 8, "", cTxt, text.align_right)
    // runs-test row
    string rtTxt = rtTot < 20 ? "warming (" + str.tostring(rtTot) + ")" : (rtStreaky ? "⚠ streaky" : "✓ independent") + (na(rtZ) ? "" : " Z=" + str.tostring(rtZ, "0.0"))
    color rtCol = rtTot < 20 ? uiNeut : rtStreaky ? uiBear : uiBull
    f_calCell(0, 9, "Runs test", cTxt, text.align_left)
    f_calCell(1, 9, rtTxt, rtCol, text.align_left)
    f_calCell(2, 9, "", cTxt, text.align_center)
    f_calCell(3, 9, "", cTxt, text.align_center)
    f_calCell(4, 9, "", cTxt, text.align_center)
    f_calCell(5, 9, "", cTxt, text.align_right)
    // Brier score of the confidence number (lower = better; 0.25 = no skill)
    string brTxt = brierN < calMinSamp ? "warming (" + str.tostring(brierN) + ")" : str.tostring(brier, "0.000") + (brier < 0.25 ? " ✓" : "")
    color  brCol = brierN < calMinSamp ? uiNeut : brier < 0.20 ? uiBull : brier < 0.25 ? uiGold : uiBear
    f_calCell(0, 10, "Brier", cTxt, text.align_left)
    f_calCell(1, 10, brTxt, brCol, text.align_left)
    f_calCell(2, 10, "", cTxt, text.align_center)
    f_calCell(3, 10, "", cTxt, text.align_center)
    f_calCell(4, 10, "", cTxt, text.align_center)
    f_calCell(5, 10, "", cTxt, text.align_right)
    // confidence over/under diagnosis (predicted mean vs realized hit-rate)
    string cgTxt = na(calGap) ? "—" : math.abs(calGap) <= 0.05 ? "✓ calibrated" : calGap > 0 ? "over " + str.tostring(math.round(calGap * 100)) : "under " + str.tostring(math.round(-calGap * 100))
    color  cgCol = na(calGap) ? uiNeut : math.abs(calGap) <= 0.05 ? uiBull : calGap > 0 ? uiBear : uiGold
    f_calCell(0, 11, "Conf calib", cTxt, text.align_left)
    f_calCell(1, 11, cgTxt, cgCol, text.align_left)
    f_calCell(2, 11, "", cTxt, text.align_center)
    f_calCell(3, 11, "", cTxt, text.align_center)
    f_calCell(4, 11, "", cTxt, text.align_center)
    f_calCell(5, 11, "", cTxt, text.align_right)
    // net-of-cost R-expectancy (ALL flips): gross R and Net R after the round-trip cost
    string nrTxt = na(netRc) ? "warming" : (grossRc >= 0 ? "+" : "") + str.tostring(grossRc, "0.00") + "R → net " + (netRc >= 0 ? "+" : "") + str.tostring(netRc, "0.00") + "R"
    color  nrCol = na(netRc) ? uiNeut : netRc > 0 ? uiBull : uiBear
    f_calCell(0, 12, "Net R  (cost " + str.tostring(costR, "0.00") + ")", cTxt, text.align_left)
    f_calCell(1, 12, nrTxt, nrCol, text.align_left)
    f_calCell(2, 12, "", cTxt, text.align_center)
    f_calCell(3, 12, "", cTxt, text.align_center)
    f_calCell(4, 12, "", cTxt, text.align_center)
    f_calCell(5, 12, "", cTxt, text.align_right)

// ============================ PLAIN-LANGUAGE BANNER =========================
var table banner = table.new(position.top_center, 1, 1)
if plainBanner and barstate.islast
    string bTxt = dispState == 1 ? "▲ BULLISH   ·   trail is SUPPORT below price" : dispState == -1 ? "▼ BEARISH   ·   trail is RESISTANCE above price" : "●   NO CLEAR TREND   ·   WAIT / stand aside"
    color  bCol = dispState == 1 ? uiBull : dispState == -1 ? uiBear : uiNeut
    string sub  = sizeTxt == "FULL" ? "  (high confidence)" : sizeTxt == "HALF" ? "  (moderate — size down)" : ""
    table.cell(banner, 0, 0, "   " + bTxt + sub + "   ", text_size = size.large, text_color = f_chip(bCol), bgcolor = color.new(bCol, 0), text_halign = text.align_center)

// ============================ HOW TO READ ===================================
var table howT = table.new(keyPos == "bottom_left" or keyPos == "top_left" ? position.middle_left : position.middle_right, 2, 5, border_width = 1, border_color = cGrid, frame_color = cGrid, frame_width = 1)
f_how(int r, string sym, color sc, string meaning) =>
    table.cell(howT, 0, r, sym, text_size = size.tiny, text_color = f_chip(sc), bgcolor = color.new(sc, 15), text_halign = text.align_center)
    table.cell(howT, 1, r, meaning, text_size = size.tiny, text_color = cTxt, bgcolor = cPanel, text_halign = text.align_left)
if showHowTo and barstate.islast
    table.cell(howT, 0, 0, "READ", text_size = size.tiny, text_color = f_chip(uiGold), bgcolor = color.new(uiGold, 30), text_halign = text.align_center)
    table.cell(howT, 1, 0, "what to do", text_size = size.tiny, text_color = uiNeut, bgcolor = color.new(uiGold, 30), text_halign = text.align_left)
    f_how(1, "▲ BULLISH", uiBull, "Uptrend — favour longs; trail is your stop below")
    f_how(2, "▼ BEARISH", uiBear, "Downtrend — favour shorts; trail is your stop above")
    f_how(3, "● WAIT",    uiNeut, "No clear trend — stand aside until it picks a side")
    f_how(4, "BUY / SELL",uiGold, "A confirmed flip in the trend's direction")

// ============================ LEGEND KEY ====================================
var table keyT = table.new(f_pos(keyPos), 2, 7, border_width = 1, border_color = cGrid, frame_color = cGrid, frame_width = 1)
f_key(int r, string sym, color sc, string meaning) =>
    table.cell(keyT, 0, r, sym, text_size = size.tiny, text_color = sc, bgcolor = cPanel, text_halign = text.align_center)
    table.cell(keyT, 1, r, meaning, text_size = size.tiny, text_color = uiNeut, bgcolor = cPanel, text_halign = text.align_left)
if showKey and barstate.islast
    table.cell(keyT, 0, 0, "KEY", text_size = size.tiny, text_color = f_chip(uiGold), bgcolor = color.new(uiGold, 30), text_halign = text.align_center)
    table.cell(keyT, 1, 0, "mark / line", text_size = size.tiny, text_color = uiNeut, bgcolor = color.new(uiGold, 30), text_halign = text.align_left)
    f_key(1, "▬", uiBull, "Consensus trail (teal up · red down)")
    f_key(2, "▮", uiGold, "Cluster zone (where anchors agree)")
    f_key(3, "▬", color.new(uiBull, 55), "HTF stop (the wider 'trend is wrong' line)")
    f_key(4, "▲ ▼", uiBull, "BUY / SELL flip (sized by confidence)")
    f_key(5, "★", uiGold, "Calibration: edge clears base rate")
    f_key(6, "▨", uiNeut, "Background: green bull · red bear · grey wait")

// ============================ IDENTITY STRIP ================================
var table idT = table.new(position.bottom_center, 1, 1)
if showId and barstate.islast
    table.cell(idT, 0, 0, "Adaptive Consensus Trail  ·  " + syminfo.ticker + "  ·  " + timeframe.period, text_size = size.small, text_color = uiNeut, bgcolor = color.new(cPanel, 20), text_halign = text.align_center)

// ============================ DATA-WINDOW EXPORTS ===========================
[allHr, allWb, allEdge, allLo, allHiU, allSig] = f_edge(cfHit, cfTot, array.get(tierUp,0)+array.get(tierUp,1)+array.get(tierUp,2), array.get(tierDn,0)+array.get(tierDn,1)+array.get(tierDn,2))
plot(enableExports ? trail : na,                 "EXP_ConsensusTrail",      display = display.data_window)
plot(enableExports ? dir : na,                   "EXP_TrailDirection",        display = display.data_window)
plot(enableExports ? aConf * 100 : na,           "EXP_Confidence", display = display.data_window)
plot(enableExports ? regCode : na,               "EXP_RegimeCode",     display = display.data_window)
plot(enableExports and useHurst ? hurst : na,    "EXP_Hurst",      display = display.data_window)
plot(enableExports and not na(calConf) ? calConf * 100 : na, "EXP_ConfidenceCalibrated", display = display.data_window)
plot(enableExports and not na(brier) ? brier : na, "EXP_BrierScore",    display = display.data_window)
plot(enableExports and not na(htfStop) ? htfStop : na, "EXP_HTFStop", display = display.data_window)
plot(enableExports and not na(allEdge) ? allEdge * 100 : na, "EXP_EdgePts", display = display.data_window)
plot(enableExports and not na(grossRc) ? grossRc : na, "EXP_ExpR", display = display.data_window)
plot(enableExports and not na(netRc) ? netRc : na, "EXP_NetR", display = display.data_window)

// ============================ ALERTS ========================================
alertcondition(flipUp, "Trail flip LONG",  "Consensus Trail flipped LONG on {{ticker}} {{interval}}")
alertcondition(flipDn, "Trail flip SHORT", "Consensus Trail flipped SHORT on {{ticker}} {{interval}}")
alertcondition(flipUp and tier == 2, "Strong LONG flip",  "Consensus Trail STRONG long flip on {{ticker}} {{interval}}")
alertcondition(flipDn and tier == 2, "Strong SHORT flip", "Consensus Trail STRONG short flip on {{ticker}} {{interval}}")

// combined, filter-driven alert (single configurable notification)
aHtfOK = (flipUp and htfDir == 1) or (flipDn and htfDir == -1)
aFire = alertFilter == "Long only" ? flipUp : alertFilter == "Short only" ? flipDn : alertFilter == "Strong only" ? ((flipUp or flipDn) and tier == 2) : alertFilter == "HTF-aligned only" ? aHtfOK : (flipUp or flipDn)
if aFire
    string side = flipUp ? "LONG" : "SHORT"
    alert("Consensus Trail — " + side + " flip on " + syminfo.ticker + " " + timeframe.period + "  (conf " + str.tostring(qScore) + ", " + regime + ")", alert.freq_once_per_bar_close)
````
