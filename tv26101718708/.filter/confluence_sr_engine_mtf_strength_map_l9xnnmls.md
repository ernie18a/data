# Confluence S/R Engine - MTF Strength Map

- url: https://www.tradingview.com/script/l9XNNmLs-Confluence-S-R-Engine-MTF-Strength-Map/
- type: indicator
- pine_id: PUB;88c6c285fc554bba8cb7df7b6d80b3b7
- version: 5.0

## Description

## Confluence S/R Engine - MTF Strength Map

An open-source, multi-method support and resistance zone engine that scores price areas by the agreement of independent structural, volumetric and timeframe-based signals.

---

### Why this script exists (mashup justification)

Most retail support and resistance tools use one method - pivots, or VWAP, or a volume profile POC, or Fibonacci bands. Each works in some conditions and fails in others. A pivot may have no volume behind it; a POC may sit in dead air with no structural confirmation; a Fibonacci band may coincide with nothing.

The premise of this engine is simple: a price level identified independently by several different methods, across several different timeframes, is more meaningful than the same price identified by only one method. This is the confluence principle, written formally.

To make that principle usable, this script does four things a simple mashup cannot:

1. Collects 12 different method types in one pass. Each method places a vote at a price level with an associated weight, method-type tag, and timeframe tag.
2. Clusters nearby votes within a configurable distance in ATR units, so a POC at 23,510, a swing low at 23,505 and an HTF pivot at 23,512 are treated as one zone, not three.
3. Scores each cluster on five dimensions (level quality, method diversity, timeframe diversity, recency, tightness) into a single 0-10 composite, with a small bonus when an absorption candle is also present.
4. Exports the resulting zones as numerical signals downstream Pine scripts can read as input sources, so this engine can act as a reference layer for any other strategy or visualisation you build.

The components are not just plotted side by side. They are fused. The cluster step is what justifies combining them, because clustering only adds value when you have multiple independent inputs to cluster. A single-method version of this script would not produce the same output, because the score is, by construction, a function of how many independent methods agree.

---

### What this version adds

A small set of additions tighten signal quality and make the engine more honest about its own behaviour:

- Multi-window volume consensus. The absorption-bonus (+0.5) and naked POC creation now require volume to exceed a percentile across three lookback windows using a majority-vote rule. This prevents a single-window volume spike during a regime transition from inflating a zone's score.
- Hawkes pre-kill warning. A self-exciting point process detects volatility clustering. Each bar whose absolute return exceeds about 2 standard deviations raises an intensity which decays each bar. When intensity exceeds the warning multiple of its baseline (default 3.0x), the engine flags the regime row to "DGR vol" and raises the show-threshold for new zones, so during volatility clusters the chart shows only top-tier confluence.
- Calibration tracker (descriptive only, optional panel off by default). Every qualifying zone is logged at formation. After a configurable horizon (default 10 bars), the engine checks whether price moved by at least 0.5 x ATR in the expected direction. Users who want to see the engine's measured hit-rate by score tier can turn the panel on; the tracker itself runs regardless, so EXP_* plots stay populated for downstream scripts. Past data, not a backtest, prediction, or advice.
- Compact 5-row snapshot panel. The on-chart panel shows only what a trader actually needs: top zone, bias, nearest levels (S below and R above with ATR distance), regime (zones + fortress count + health code combined), and asset. No statistics in the main panel.

---

### The 12 methods (organised by weight tier)

- Tier A (heaviest, weight 2.5): Anchored Volume Profile POC, naked (untested) historical POCs, Tier-1 anchor candle highs and lows, absorption candle highs/lows/closes, per-HTF volume-bucketed POCs.
- Tier B (weight 2.0): Value Area High and Low, recent native-timeframe swing pivots, Anchored VWAP, Fibonacci 0.618 bands.
- Tier C (weight 1.5, with HTF multiplier): Multi-timeframe pivots, so a Daily pivot weighs more than a 1-hour pivot.
- Tier D (weight 1.0): Anchored VWAP +/-1 sigma bands, Fibonacci 0.382 bands, prior swing levels.
- Tier E (lightest, weight 0.5): Anchored VWAP +/-2 sigma bands, Fibonacci 1.0 bands, HTF closes.

The anchor used by AVWAP, the volume profile and the Fibonacci bands is the most recent Tier-1 anchor candle - a candle that, by configurable percentile thresholds across three lookback windows, shows both unusually high volume and unusually wide range. This means the AVWAP and profile reset onto a new participation node rather than running indefinitely from a fixed session start.

---

### The 5-dimension scoring rubric

Each cluster scores as the sum of:

- Level quality (max 3.0) - based on the highest tier of any method in the cluster.
- Method diversity (max 2.5) - more independent method types in the cluster scores higher than the same type appearing multiple times.
- Timeframe diversity (max 2.0) - methods from more distinct timeframes (native + HTF1..HTF4) score higher.
- Recency (max 1.5) - recent methods score higher than ones from long ago.
- Tightness (max 1.0) - clusters whose constituent prices sit within a narrow ATR band score higher than wide, sloppy clusters.

Plus a +0.5 absorption bonus if an absorption candle (high volume, narrow range, mid-bar close) is part of the cluster. Total is capped at 10.

A "fortress" zone is simply a cluster whose composite score is at or above the user's fortress threshold (default 8.0). The word is a label for a high-score zone - it is not a claim about future price behaviour.

---

### How to read the chart

- Green band - support zone (cluster centre below current price).
- Red band - resistance zone (cluster centre above current price).
- Yellow-green band - support whose score is at or above the fortress threshold.
- Yellow-orange band - resistance whose score is at or above the fortress threshold.
- Bolder, more opaque band - higher composite score.
- Star glyph on the label - fortress-grade zone.
- Dot glyph on the label - cluster contains at least one absorption candle.
- Triangle up/down - currently acting as support / resistance.
- "S 8.6 (5m)" - score 8.6, built from 5 distinct method types.

The snapshot panel (top-right by default, position configurable) is a compact 5-row table showing only decision-grade information:

1. **Top Zone** - the single highest-scoring zone (price, score, direction, fortress flag).
2. **Bias** - POC imbalance state (bullish / bearish / neutral with the buy-volume percentage).
3. **Levels** - nearest support below + nearest resistance above, with distance in ATR units. Answers "what should I watch right now?" in one line.
4. **Regime** - zones count, fortress count, and data-health code in one row. Health reads "OK" if all sources are valid, "DGR" if degraded, "DGR vol" if the Hawkes warning is active, "CRIT" if no volume.
5. **Asset** - auto-detected class (Equity / Futures / Index / FX / CFD / Crypto) plus symbol.

An optional **calibration panel** can be turned on in the input group. When enabled, it shows in a separate small table the engine's measured hit-rate by score tier (4-star, 5-star, fortress, all zones) with sample size N, Wilson 95% confidence interval, and a live tracker status. Off by default to keep the chart clean. Past-only descriptive data - not a backtest, not a prediction.

---

### How to use it (intended use)

This is a decision-support and context layer. It is meant to be combined with your own entry and exit logic, your own risk management, and your own discretion.

Suggested workflows:

- As a context filter. Look at price relative to the nearest support and resistance zones before taking a setup from your usual system. Trades into a strong opposing zone are higher risk; trades away from one are lower risk.
- As a structural map. When price approaches a fortress-grade zone, expect a reaction is more likely than at a low-score zone. The reaction can be a bounce, a break, or a long consolidation - the engine does not predict which.
- As an input for other Pine scripts. Attach this engine to your chart, then in any downstream indicator or strategy you build, use input.source() to pick any of the visible plots (POC, VAH, VAL, AVWAP, sigma bands, Fib bands, HTF1-4 POCs) or any of the 28 hidden EXP_* data-window outputs as a real-time reference for your logic.
- For multi-timeframe alignment. Turn on multiple HTFs (default 60m, 4h, Daily, optionally Weekly). When zones cluster across HTF and native pivots, the score reflects that automatically.

---

### How not to use it

- Do not treat any zone as a buy or sell signal. A high-score zone is a likely reaction area; it does not tell you which direction price will go next.
- Do not use it as a standalone strategy. This engine has no entry rules, no stop rules, no position-sizing and no exit logic. It is a map, not a plan.
- Do not assume the score is a probability. It is a composite of structural evidence, not a calibrated statistical model.
- Do not rely on it alone on volumeless symbols (e.g. some spot indices). On instruments without true volume the engine auto-downgrades - the data-health row will tell you when this is the case. POC, VAH, VAL and AVWAP-based methods are weaker without volume.
- Do not back-test it as a strategy. It is an indicator and is published as such; the engine does not place trades.

---

### Key settings you might want to adjust

- Detection mode: "Percentile + Consensus" (default) is more robust; "Legacy" matches older volume x average rules if you prefer simple thresholds.
- Min strength to display: raise (e.g. 6.0) to see only the strongest zones; lower (e.g. 2.0) to see everything.
- Fortress threshold: controls when the special highlight colour appears (default 8.0).
- Auto-scale lookbacks: leave ON so the same defaults work from 1-minute intraday to 1-week swing charts. The reference timeframe is 15 minutes; everything scales from there.
- HTF1..HTF4: pick the higher timeframes meaningful to your style. Defaults are 1h, 4h, Daily and (optional) Weekly.
- Min directional ratio for bias: controls how lopsided LTF flow must be to flip the bias to bullish or bearish.
- Multi-window volume consensus: leave ON to gate the absorption bonus and naked POC creation on majority agreement across three lookback windows.
- Hawkes pre-kill: leave ON to suppress lower-score zones during volatility clusters. Default warning threshold is 3.0x baseline (less sensitive than v3.2 to avoid over-suppression on higher timeframes). Lower it for stricter behaviour, raise it to mute the filter further.
- Calibration tracker: ON by default for logging, but the panel itself is OFF by default to keep the chart clean. Turn on "Show calibration panel on chart" if you want to see the hit-rate breakdown. Horizon (default 10 bars) is how far forward each zone is followed; the minimum-move threshold (default 0.5 x ATR) is what counts as the zone being respected.

---

### Limitations you should know

- Volume dependency. Several methods (POC, VAH, VAL, AVWAP, absorption, naked POC, HTF POCs) require valid volume. On spot indices and some FX symbols there is no true volume; the data-health row will show "Degraded" or "Critical" and the engine will lean on range-based methods only.
- Anchor recency. The engine reuses the most recent Tier-1 anchor candle. If no anchor has formed in a long quiet period, the AVWAP/profile-based methods are stale and their contribution to the score falls off via the recency dimension.
- HTF latency. Higher-timeframe data only updates when each HTF closes. Until the first HTF close has occurred since chart load, HTF-based methods may show "off" in the data-health detail.
- Pivot lag is structural. Pivot detection requires pivotLen bars on each side, which means the most recent swing pivots can only be confirmed pivotLen bars after the actual high or low. This is structural, not a script bug.
- Last-bar drawing. Zone boxes redraw on the last bar each time. This is intentional - the engine shows the current zone map, not a historical map of past zones.
- Calibration is descriptive only. The optional panel reports past outcomes using a fixed rule (move of at least 0.5 x ATR within N bars). It is not a backtest, prediction, or strategy result, and does not include costs or slippage.
- Hawkes warning is a suppression layer, not a market call. When the engine enters the pre-kill state, it raises the show-threshold by 1.5 (capped at the fortress level) until volatility intensity returns to baseline. Risk control, not a "market is about to reverse" signal.
- Not a strategy. No trades, no equity curve, no backtest.

---

### Alerts (10 included)

01 Tier-1 anchor formed. 02 Absorption anchor formed. 03 Price crossed POC. 04 Price crossed VA edge. 05 Price entered top zone. 06 Price broke top zone. 07 Fortress zone interaction. 08 POC bias flipped. 09 Nearest S/R crossed. 10 Data health changed. All alerts use barstate.isconfirmed so they do not repaint.

---

### Outputs for downstream scripts

In addition to the visible chart plots, the engine exposes hidden EXP_* series (visible in the Data Window) so other Pine scripts can read its state. These cover the top zones (price, score, direction, fortress flag), the synthesised top-zone summary, POC bias and buy-ratio, nearest support and resistance prices and their ATR distances, fortress count, and event pulses (zone entered, zone broken, bias flipped, data-health changed, Tier-1 anchor formed).

To use them from another script of your own: attach this engine to the chart, then in your downstream script create an input.source(close, "S/R source") field and select any EXP_* series from the dropdown.

---

### Chart, symbol and timeframe (for clarity)

The publication chart shows this engine running on its own, with no other indicators or drawings present. The chart watermark shows the symbol and timeframe at the top of the chart. The engine's own snapshot table (top-right) additionally displays the detected asset class and the active ticker, so users can confirm what they are looking at.

---

### Disclaimer

This script is published for educational and informational purposes only. It is not investment advice, not a recommendation to buy, sell or hold any instrument, and not a solicitation to trade. Past behaviour of any pattern, level, signal or zone shown by this script does not guarantee future results. Trading involves substantial risk of loss and may not be suitable for every investor. You alone are responsible for your trading decisions, position sizing, risk management and capital. Before committing real money, please do your own research and consider speaking with a qualified, locally-licensed financial professional.

The optional calibration panel (off by default) is descriptive only. It reports past outcomes using a fixed rule. It is not a backtest, prediction, or probability, and does not account for transaction costs or slippage.

Open-source. Released under the Mozilla Public License 2.0 (TradingView default). Feedback and constructive comments are welcome.

## Source Code

````pine
// Released under the Mozilla Public License 2.0 (TradingView default)
// Educational and informational use only. Not financial advice.
// ======================================================================================
//   Confluence S/R Engine - MTF Strength Map
// ======================================================================================
//
//  WHAT IT IS
//  ----------
//  A multi-timeframe support/resistance map. Rather than plotting one method's levels,
//  it gathers price levels from several independent, well-established techniques, merges
//  the ones that agree, scores each merged level for conviction (0-10) and draws only the
//  strongest as horizontal lines. Where many methods independently point at the same
//  price, that price is shown as a stronger level - confluence made explicit.
//
//  WHY THE METHODS ARE COMBINED (mashup rationale)
//  -----------------------------------------------
//  Any single S/R technique is noisy and regime-dependent: a pivot can be random, a lone
//  volume POC can be stale, a VWAP band can be untested. Each method answers a different
//  question - where did participation concentrate (volume profile / POC), where is the
//  anchored fair value and its dispersion (anchored VWAP + sigma + Fibonacci bands), where
//  did structure turn (pivots, MTF pivots), where did large size get absorbed (absorption
//  candles), and what do higher timeframes care about (per-HTF POCs and pivots). The
//  engine treats each as one "vote". Agreement across independent methods is far more
//  informative than any method alone, so the components are not stacked for show - the
//  whole point of the script is what they say jointly.
//
//  HOW THE COMPONENTS WORK TOGETHER (pipeline)
//  -------------------------------------------
//   1 COLLECT - every enabled method contributes price "votes", each tagged with a tier
//               (importance), a method id, a source timeframe and an age.
//   2 CLUSTER - votes within an ATR-scaled merge distance are fused into one level; the
//               cluster remembers how many distinct methods and timeframes it spans.
//   3 SCORE   - each cluster gets a 0-10 conviction score from: top tier present, method
//               diversity, timeframe spread, recency, tightness, an absorption bonus, and
//               a bounded respect-rate nudge from this symbol's own historical hit-rate.
//   4 REGIME  - path efficiency + a variance ratio classify the tape as Range (levels tend
//               to hold -> solid lines) or Trend (levels tend to break -> dashed lines),
//               and lift the show-threshold slightly in a trend so only the best survive.
//   5 RENDER  - the strongest levels draw as lines with a bright core + soft glow whose
//               opacity scales with score, plus a compact dashboard and a how-to-read key.
//
//  HONESTY LAYER
//  -------------
//  A calibration tracker logs every qualifying top level at formation and checks, after a
//  fixed horizon, whether price actually moved as a level of that strength implies. It
//  reports a hit-rate with a Wilson 95% confidence interval, and feeds the bounded respect
//  nudge above. This is descriptive history on the symbol in front of you - not a backtest
//  and not a forward guarantee.
//
//  HOW TO USE
//  ----------
//  Read the strongest lines as decision zones, not exact triggers. Solid = range-grade
//  (fade/mean-revert bias), dashed = trend-grade (levels more likely to give way). The
//  star marks fortress-grade confluence. The dashboard summarises the top level, regime,
//  order-flow bias, nearest support/resistance and the calibration read. Tune via the
//  numbered settings groups; the included defaults are calibrated for NSE:NIFTY on
//  intraday timeframes - other symbols/timeframes may want different windows.
//
//  ORIGINALITY
//  -----------
//  The contribution is the confluence engine itself: a tier/diversity/timeframe/recency/
//  tightness scoring of merged multi-method votes, conditioned by a live regime read and
//  grounded by an on-symbol respect-rate calibration with confidence intervals. The
//  underlying techniques are credited below; the way they are unified, scored and
//  validated here is the original work. Computed on the last bar; never repaints history.
//
//  CONCEPT CREDITS (underlying public techniques)
//  ----------------------------------------------
//  - Market/Volume Profile, POC & Value Area .......... J. Peter Steidlmayer
//  - Anchored VWAP as an analytical reference ......... popularised by Brian Shannon
//  - Variance-ratio test (random-walk diagnostic) ..... Andrew Lo & A. Craig MacKinlay
//  - Efficiency ratio / path efficiency ............... Perry Kaufman
//  - Wilson score confidence interval ................. Edwin B. Wilson
//  - Pivot/swing structure & Fibonacci proportions .... classical public-domain methods
//
//  DISCLAIMER
//  ----------
//  For research and education only. Nothing here is financial advice, a solicitation, or a
//  guarantee of results. Support/resistance levels are probabilistic context, not signals;
//  markets can and do break any level. Test on your own symbol and timeframe and manage
//  your own risk. Past behaviour does not guarantee future behaviour.
// ======================================================================================

//@version=6
indicator("Confluence S/R Engine - MTF Strength Map",
     shorttitle      = "CSR v5",
     overlay         = true,
     max_bars_back   = 5000,
     max_boxes_count = 500,
     max_lines_count = 500,
     max_labels_count= 500)

// v5 — COHERENT MTF CORE: one S/R map that is IDENTICAL on every chart timeframe.
//   The problem in v4.x: every detection method ran on the CHART timeframe's bars, so the
//   swings, lookback windows (in bar-count), ATR-scaled tolerances and the regime read all
//   changed when you switched chart TF — producing different levels and different strengths
//   on 1m vs 15m vs 1h, which read as "contradictory". v5 fixes that at the source:
//   • The primary map is built ONLY from a FIXED anchor-TF ladder (base 15m + 60m/240m/D/W via
//     request.security, lookahead_off) — POCs, HTF pivots, and classic prior-period H/L/C
//     (PDH/PDL, PWH/PWL, …). None of these depend on the chart TF, so the map is the same on
//     every chart. The chart is now just a viewport (zoom), not an input to the levels.
//   • Clustering tolerance, tightness and line separation are a FIXED % of price (not chart
//     ATR), so the same neighbours merge identically on every TF.
//   • The trend/range regime that styles the lines and lifts the show-threshold is read from a
//     FIXED TF (default Daily), so solid/dashed and which levels survive are TF-invariant.
//   • In core mode the strength score is purely STRUCTURAL (tier / method diversity / anchor-TF
//     spread / tightness), so it is byte-identical across chart TFs. The honest v4.1 triple-
//     barrier calibration still runs and is shown as descriptive context, but it no longer
//     perturbs the coherent score (so scores can't drift per TF). Turn "core" off to return to
//     the v4.1 chart-TF engine; turn "local layer" on to overlay chart-TF levels (this breaks
//     cross-TF identity by design, for scalpers who want the granular read). With the overlay on
//     the two layers are drawn DIFFERENTLY so they're never confused: fixed anchor-TF core levels
//     are solid/dashed with a glow and a "· NTF" tag; chart-TF local levels are dotted, hairline,
//     dimmer, and marked "◦ … · loc".
//   The 12-method detection, clustering, 5-dimension scoring, Hawkes suppression, the v4.1
//   ml_calib honesty layer and all 28 exports are otherwise intact.
import Market_Logic_India/ml_calib/2 as cal

// ========================================================================
//  0 - COHERENT MTF CORE  (same levels on every chart timeframe)
// ========================================================================
string grpCore = "00 · Coherent MTF Core (same levels on every timeframe)"
bool   useMtfCore = input.bool(true, "Coherent MTF core map (identical across chart TFs)", group=grpCore,
     tooltip="ON (default): the map is built only from a fixed anchor-TF ladder (base TF below + the HTF 1-4 in group 11), so the SAME support/resistance lines and strengths appear on every chart timeframe — the chart TF only zooms. OFF: the v4.1 chart-timeframe engine (levels re-derived from the chart's own bars, so they differ per TF).")
string coreBaseTf = input.timeframe("15", "Core base anchor TF", group=grpCore,
     tooltip="The lowest rung of the fixed anchor ladder. The higher rungs are HTF 1-4 in group 11 (default 60m / 240m / D / W). All are fetched via request.security with lookahead off, so the map never depends on the chart TF.")
float  coreClusterPct = input.float(0.15, "Core cluster tolerance (% of price)", minval=0.02, maxval=1.0, step=0.01, group=grpCore,
     tooltip="TF-invariant merge distance: anchor-TF votes within this % of price of each other fuse into one level. Also sets tightness and minimum line separation in core mode. Larger = fewer, broader consensus levels.")
string coreRegimeTf = input.timeframe("D", "Core regime TF (trend/range read)", group=grpCore,
     tooltip="The trend/range regime that styles lines (solid=holds / dashed=breaks) and lifts the show-threshold is read from THIS fixed TF in core mode, so the styling is identical on every chart TF.")
bool   useLocalLayer = input.bool(false, "Also show chart-TF local levels (breaks cross-TF identity)", group=grpCore,
     tooltip="ON: additionally blend in the chart timeframe's own detected levels (anchors, chart volume profile, chart pivots, AVWAP). Gives scalpers the granular per-TF read, but by definition those levels differ per chart TF, so the map is no longer identical across timeframes. OFF (default): pure coherent core.")

// ========================================================================
//  1 - ASSET CLASS AUTO-DETECT  +  DATA-INTEGRITY LAYER
// ========================================================================
string symType = syminfo.type
bool isEquity  = symType == "stock"  or symType == "fund"
bool isFutures = symType == "futures"
bool isIndex   = symType == "index" or symType == "economic"
bool isFx      = symType == "forex"  or symType == "cfd"
bool isCrypto  = symType == "crypto"

string assetClassTxt = isEquity ? "Equity" : isFutures ? "Futures" : isIndex ? "Index" : isFx ? "FX/CFD" : isCrypto ? "Crypto" : "Generic"
int assetClassCode = isEquity ? 1 : isFutures ? 2 : isIndex ? 3 : isFx ? 4 : isCrypto ? 5 : 0

bool volExists       = not na(volume) and volume > 0
var int volPresentCnt = 0
var int volTotalCnt   = 0
if barstate.isconfirmed
    volTotalCnt   += 1
    volPresentCnt += volExists ? 1 : 0
float volAvailRatio  = volTotalCnt > 0 ? volPresentCnt / volTotalCnt : 0.0
bool  volReliable    = volAvailRatio >= 0.80
bool  useVolumeMode  = volReliable

bool barRangeValid = high > low and not na(high) and not na(low)

// ========================================================================
//  2 - DATA SOURCE  +  AUTO-SCALE LOOKBACKS
// ========================================================================
string grpData = "01 · Data & Source"
float  srcPrice = input.source(hlc3, "AVWAP / band source", group=grpData,
     tooltip="The engine reads the chart's OHLCV directly, so it already runs on any symbol or market with no changes. This source only sets the price used for the anchored-VWAP, sigma and Fibonacci band votes (hlc3 is standard; close, hl2 or ohlc4 also work). Pivots, volume profile and absorption always use the chart's high/low/volume.")

string grpScale = "02 · Auto-Scale"
bool   autoScaleLookbacks = input.bool(true, "Auto-scale lookbacks to chart TF", group=grpScale,
     tooltip="ON: pivot length, percentile windows and zone aging scale to chart TF using a 15-min reference. OFF: use raw bar counts below.")
int    refTfMins = input.int(15, "Reference TF (minutes)", minval=1, maxval=10080, group=grpScale,
     tooltip="The TF at which the default bar-count inputs are calibrated.")

int   chartTfSecs = timeframe.in_seconds(timeframe.period)
float refTfSecs   = refTfMins * 60.0
float scaleFactor = autoScaleLookbacks ? math.max(0.1, math.min(20.0, refTfSecs / math.max(chartTfSecs, 1.0))) : 1.0

f_scaleLookback(int base) =>
    math.max(2, int(math.round(base * scaleFactor)))

// ========================================================================
//  3 - INPUTS
// ========================================================================
string grpAnchor = "03 · Tier-1 Anchors (high-participation candles)"
string detectMode = input.string("Percentile + Consensus", "Detection mode",
     options=["Legacy (volume x avg)", "Percentile + Consensus"], group=grpAnchor,
     tooltip="Percentile+Consensus uses 3 lookback windows and multi-window agreement. Legacy is the simple volume x avg + range x ATR rule.")
float volPctThresh   = input.float(90.0, "Volume percentile threshold", minval=50.0, maxval=99.0, step=1.0, group=grpAnchor)
float rangePctThresh = input.float(80.0, "Range percentile threshold",  minval=50.0, maxval=99.0, step=1.0, group=grpAnchor)
string consensusMode = input.string("Majority (2 of 3)", "Window consensus",
     options=["Any window", "Majority (2 of 3)", "All windows"], group=grpAnchor)
int shortWinBase  = input.int(20,  "Short window (base bars)",  minval=10, maxval=50,  group=grpAnchor)
int midWinBase    = input.int(50,  "Medium window (base bars)", minval=20, maxval=100, group=grpAnchor)
int longWinBase   = input.int(100, "Long window (base bars)",   minval=50, maxval=200, group=grpAnchor)
float volMultInput   = input.float(2.5, "Legacy: Volume x avg threshold", minval=1.0, step=0.1, group=grpAnchor)
float rangeMultInput = input.float(1.5, "Legacy: Range x ATR threshold",  minval=1.0, step=0.1, group=grpAnchor)
int maxAnchors    = input.int(3,    "Max active anchors", minval=1, maxval=5, group=grpAnchor)

int shortWin = f_scaleLookback(shortWinBase)
int midWin   = f_scaleLookback(midWinBase)
int longWin  = f_scaleLookback(longWinBase)

string grpAbsorption = "04 · Absorption Anchors"
bool  useAbsorption  = input.bool(true, "Detect absorption anchors", group=grpAbsorption,
     tooltip="High-volume + narrow-range + mid-close candles - high-participation events.")
float absRangeMaxPct = input.float(50.0, "Max range percentile for absorption", minval=10.0, maxval=70.0, step=1.0, group=grpAbsorption)
float absCloseMidMax = input.float(0.35, "Max close offset from bar middle (0-0.5)", minval=0.10, maxval=0.50, step=0.05, group=grpAbsorption)
int   maxAbsorptions = input.int(5, "Max active absorption anchors", minval=1, maxval=10, group=grpAbsorption)

string grpAVWAP = "05 · Anchored VWAP & Sigma Bands (votes)"
bool  useAVWAPVote = input.bool(true,  "Use AVWAP as confluence vote", group=grpAVWAP,
     tooltip="AVWAP, sigma and Fib bands are no longer drawn on the chart in v4. They still feed the confluence engine as level votes. Toggle off to drop them entirely.")
bool  showBand1  = input.bool(true,  "Include +/-1 sigma votes", group=grpAVWAP)
bool  showBand2  = input.bool(true,  "Include +/-2 sigma votes", group=grpAVWAP)

string grpFib = "06 · Fibonacci AVWAP Bands (votes)"
bool  useFibBands = input.bool(true,  "Enable Fibonacci AVWAP votes", group=grpFib)
float fibBaseMult = input.float(3.0,  "Base sigma multiplier", minval=1.0, maxval=5.0, step=0.1, group=grpFib)
bool  showFib382  = input.bool(true,  "Include 0.382 votes", group=grpFib, inline="fib1")
bool  showFib618  = input.bool(true,  "Include 0.618 votes", group=grpFib, inline="fib1")
bool  showFib1    = input.bool(true,  "Include 1.0 votes",   group=grpFib, inline="fib2")

string grpVP = "07 · Anchored Volume Profile (votes)"
bool  useVP       = input.bool(true,  "Enable Volume Profile from anchor", group=grpVP)
int   vpLevels    = input.int(25,     "Profile rows", minval=10, maxval=50, group=grpVP)
float vpValueArea = input.float(70.0, "Value Area %", minval=50.0, maxval=90.0, step=1.0, group=grpVP) / 100.0
bool  trackNakedPOC = input.bool(true, "Track naked POCs (untested historical POCs)", group=grpVP)

string grpHTFVP = "08 · Per-HTF Volume POCs (votes)"
bool  useHTFVP    = input.bool(true, "Enable per-HTF POCs", group=grpHTFVP,
     tooltip="True per-HTF volume-bucketed POC.")
int   htfVPLevels = input.int(20, "HTF profile lookback (bars)", minval=10, maxval=50, group=grpHTFVP)
int   htfVPRows   = input.int(14, "HTF profile rows", minval=8, maxval=40, group=grpHTFVP)

string grpImb = "09 · POC Imbalance Bias"
bool  useImbalance = input.bool(true, "Use LTF imbalance to bias POC", group=grpImb)
string imbLtf      = input.timeframe("1", "LTF for imbalance calculation", group=grpImb)
float imbThreshold = input.float(0.60, "Min directional ratio for bias", minval=0.50, maxval=0.80, step=0.01, group=grpImb)

string grpStruct = "10 · Structural Pivots (votes)"
int   pivotLenBase  = input.int(10, "Pivot length (base bars)", minval=2, group=grpStruct)
bool  useVolFilter  = input.bool(true, "Volume-filter pivots", group=grpStruct,
     tooltip="Auto-disabled on volumeless instruments.")
float volFilterMult = input.float(1.2, "Min volume x avg for pivot", minval=1.0, step=0.1, group=grpStruct)

int pivotLen = f_scaleLookback(pivotLenBase)

string grpMTF = "11 · Multi-Timeframe Levels"
bool   useHTF1 = input.bool(true,  "Use HTF 1", group=grpMTF, inline="htf1")
string htf1    = input.timeframe("60",  "",     group=grpMTF, inline="htf1")
bool   useHTF2 = input.bool(true,  "Use HTF 2", group=grpMTF, inline="htf2")
string htf2    = input.timeframe("240", "",     group=grpMTF, inline="htf2")
bool   useHTF3 = input.bool(true,  "Use HTF 3", group=grpMTF, inline="htf3")
string htf3    = input.timeframe("D",   "",     group=grpMTF, inline="htf3")
bool   useHTF4 = input.bool(true,  "Use HTF 4", group=grpMTF, inline="htf4")
string htf4    = input.timeframe("W",   "",     group=grpMTF, inline="htf4")

string grpRegime = "12 · Regime Read (trend vs range)"
bool  useRegime    = input.bool(true, "Condition lines on trend/range regime", group=grpRegime,
     tooltip="ON: path efficiency + a variance ratio classify the market as Range (S/R holds -> solid lines) or Trend (S/R fragile -> dashed lines). In a trend the show-threshold is lifted slightly so only the strongest levels survive.")
int   regWinBase   = input.int(40, "Regime window (base bars)", minval=10, maxval=200, group=grpRegime)
float regEffTrend  = input.float(0.40, "Trend efficiency threshold", minval=0.20, maxval=0.80, step=0.05, group=grpRegime,
     tooltip="Path efficiency (net move / path length) at or above this reads as trending.")
float regEffRange  = input.float(0.28, "Range efficiency threshold", minval=0.10, maxval=0.60, step=0.02, group=grpRegime)
int   regVrK       = input.int(5, "Variance-ratio horizon k", minval=2, maxval=20, group=grpRegime)
int   regVrLen     = input.int(100, "Variance-ratio window", minval=20, maxval=300, group=grpRegime)
float regTrendLift = input.float(0.5, "Trend show-threshold lift (score pts)", minval=0.0, maxval=3.0, step=0.5, group=grpRegime)

string grpZone = "13 · Level Construction & Strength"
float zoneWidthATR    = input.float(0.3, "Base zone half-width (x ATR)", minval=0.1, step=0.1, group=grpZone,
     tooltip="Used only for the alert hit-test band around each level. The drawn object is a thin line at the level itself.")
float clusterATR      = input.float(0.5, "Cluster merge distance (x ATR)", minval=0.1, step=0.1, group=grpZone,
     tooltip="Method votes within this ATR distance of each other are merged into the same zone.")
float minStrengthShow = input.float(4.0, "Min strength to display (0-10)", minval=0.0, maxval=10.0, step=0.5, group=grpZone)
float fortressLevel   = input.float(8.0, "Fortress threshold (0-10)",  minval=6.0, maxval=10.0, step=0.5, group=grpZone)
float minZoneSepATR   = input.float(0.85, "Min separation between shown lines (x ATR)", minval=0.0, maxval=5.0, step=0.05, group=grpZone,
     tooltip="When two lines would sit closer than this, only the stronger is drawn. Tighter spacing than a box-based map because thin lines crowd more easily. 0 disables.")
bool  autoThinIntraday = input.bool(true, "Auto-thin lines on intraday TFs", group=grpZone,
     tooltip="On 1/2/3-min charts raises the effective show-threshold and widens separation, so the map stays decision-grade.")
bool  snapToTier      = input.bool(true, "Snap tight clusters to strongest level", group=grpZone,
     tooltip="When a cluster is tight, place the line on the highest-tier contributing level (precise wick/POC) instead of the weighted mean. Loose clusters keep the weighted mean.")

string grpValid = "14 · Respect-Rate Validation"
bool  useRespect   = input.bool(true, "Nudge score by historical respect rate", group=grpValid,
     tooltip="Reads the calibration tracker's hit-rate for each score-bin and applies a small bounded bonus/penalty, so a level's strength reflects how often similar levels have actually held on THIS symbol. Needs the calibration tracker on.")
float respectBonus = input.float(0.3, "Max respect bonus/penalty (score pts)", minval=0.0, maxval=1.0, step=0.1, group=grpValid)
int   respectMinN  = input.int(5, "Min samples before nudging", minval=3, maxval=50, group=grpValid)

string grpDisplay = "15 · Display & Theme"
int   maxZonesDisplay = input.int(12, "Max lines shown", minval=5, maxval=30, group=grpDisplay)
bool  showStrengthLabel = input.bool(true, "Show strength labels", group=grpDisplay)
int   lineLeftBars      = input.int(60, "Line left-extension (bars)", minval=10, maxval=480, group=grpDisplay)
int   zoneExtend        = input.int(40, "Line right-extension (bars)", minval=10, group=grpDisplay)
bool  showMagnet        = input.bool(true, "Show nearest naked-POC magnet", group=grpDisplay)
bool  showSnapshot      = input.bool(true, "Show snapshot table", group=grpDisplay)
string snapshotPos      = input.string("Top Right", "Snapshot position",
     options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grpDisplay)
bool   showLegend       = input.bool(true, "Show how-to-read legend", group=grpDisplay,
     tooltip="A small plain-English key explaining what the coloured lines and strength words mean.")
string legendPos        = input.string("Bottom Left", "Legend position",
     options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grpDisplay)
bool   adaptiveColors   = input.bool(true, "Adapt colours to chart background", group=grpDisplay)
string themeOpt         = input.string("Auto", "Panel theme", options=["Auto","Dark","Light"], group=grpDisplay,
     tooltip="Auto reads the chart background luminance so the panels stay legible on any colour scheme. Force Dark or Light to override.")
bool   useGlow          = input.bool(true, "Neon glow on S/R lines", group=grpDisplay,
     tooltip="Draws soft halos under each level so conviction reads at a glance. Off = thin core line only.")
string panelFontOpt     = input.string("Small", "Table font size", options=["Tiny","Small","Normal","Large"], group=grpDisplay,
     tooltip="Font size for the snapshot, legend and calibration tables.")
string labelFontOpt     = input.string("Small", "On-chart label size", options=["Tiny","Small","Normal","Large"], group=grpDisplay,
     tooltip="Font size for the on-chart S/R strength labels and the magnet marker.")

color colSupport      = input.color(color.new(color.green, 70), "Support tint",    group=grpDisplay)
color colResistance   = input.color(color.new(color.red,   70), "Resistance tint", group=grpDisplay)
color colFortressSup  = input.color(color.rgb(180, 255, 100, 40), "Fortress-Support tint",    group=grpDisplay)
color colFortressRes  = input.color(color.rgb(255, 180,  60, 40), "Fortress-Resistance tint", group=grpDisplay)
color colMagnet       = input.color(color.new(color.fuchsia, 20), "Magnet color", group=grpDisplay)

// === Adaptive palette (auto-reads chart background luminance; override via Panel theme) ===
float _bgLum    = 0.299 * color.r(chart.bg_color) + 0.587 * color.g(chart.bg_color) + 0.114 * color.b(chart.bg_color)
bool  isLightBg = themeOpt == "Light" ? true : themeOpt == "Dark" ? false : (adaptiveColors and _bgLum >= 140)

// on-chart S/R line colours — teal support / magenta resistance, vivid for fortress-grade levels
color colSupEff     = not adaptiveColors ? colSupport     : isLightBg ? #0e9e76 : #21dfac
color colResEff     = not adaptiveColors ? colResistance  : isLightBg ? #b81d5b : #df216d
color colFortSupEff = not adaptiveColors ? colFortressSup : isLightBg ? #0b8f6a : #5af0c8
color colFortResEff = not adaptiveColors ? colFortressRes : isLightBg ? #d11a6a : #ff5d8f

// dashboard surfaces (adaptive: dark on dark charts, light on light charts)
color uiPanelBg = isLightBg ? color.new(#ffffff, 6) : color.new(#0d1117, 8)
color uiRowBg   = isLightBg ? color.new(#e9edf2, 0) : color.new(#161d2b, 0)
color uiBorder  = isLightBg ? color.new(#c2c8d0, 0) : color.new(#2b3340, 0)
color uiText    = isLightBg ? #10151d : #f2f4f8
color uiTextDim = isLightBg ? #707a86 : #9aa3b2

color snapPanelBg = uiPanelBg
color snapRowBg   = uiRowBg
color snapFrame   = uiBorder
color snapBorder  = uiBorder

// === Unified semantic colours (shared by line labels, snapshot, calibration, legend) ===
color cPos  = isLightBg ? #0e7c5a : #2dd4bf
color cNeg  = isLightBg ? #c62828 : #ff6b6b
color cWarn = isLightBg ? #9a6a00 : #e3b341
color cInfo = isLightBg ? #1f6feb : #79c0ff

// === Resolved font sizes (from the Display group) ===
string panelTxtSize = panelFontOpt == "Tiny" ? size.tiny : panelFontOpt == "Normal" ? size.normal : panelFontOpt == "Large" ? size.large : size.small
string labelTxtSize = labelFontOpt == "Tiny" ? size.tiny : labelFontOpt == "Normal" ? size.normal : labelFontOpt == "Large" ? size.large : size.small

string grpMVC   = "16 · Multi-Window Volume Consensus"
bool  useMVC    = input.bool(true, "Require multi-window volume confirmation", group=grpMVC)
float mvcPct    = input.float(75.0, "Volume percentile threshold", minval=50.0, maxval=95.0, step=1.0, group=grpMVC)
int   mvcShort  = input.int(20,  "Short window (bars)", minval=10, maxval=50,  group=grpMVC)
int   mvcMid    = input.int(50,  "Mid window (bars)",   minval=20, maxval=100, group=grpMVC)
int   mvcLong   = input.int(100, "Long window (bars)",  minval=50, maxval=250, group=grpMVC)
string mvcCons  = input.string("Majority (2 of 3)", "Window consensus", options=["Any window", "Majority (2 of 3)", "All windows"], group=grpMVC)

string grpCal    = "17 · Calibration Tracker"
bool  calEnable  = input.bool(true, "Enable calibration tracker (data logging)", group=grpCal,
     tooltip="Logs every qualifying top-zone at formation and scores it after the horizon. Feeds the respect-rate nudge and the confidence read. Descriptive history only - not a backtest.")
bool  calShowPanel = input.bool(false, "Show calibration panel on chart", group=grpCal)
string calPanelPos = input.string("Bottom Right", "Calibration panel position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grpCal)
int   calHorizon = input.int(10, "Evaluation horizon (bars)", minval=3, maxval=50, group=grpCal)
float calMoveATR = input.float(0.5, "Minimum move (x ATR) for hit", minval=0.1, maxval=2.0, step=0.1, group=grpCal)
int   isEndT     = input.time(timestamp("2025-01-01 00:00"), "Walk-forward: in-sample ends", group=grpCal, tooltip="Touches resolving on/before this are in-sample; after it are out-of-sample. The OOS respect-rate (exported) is the trustworthy one; before you have OOS samples it reads 'warming'.")
int   oosEndT    = input.time(timestamp("2026-01-01 00:00"), "Walk-forward: out-of-sample ends", group=grpCal)

// ========================================================================
//  4 - GLOBAL HELPERS
// ========================================================================
f_addMethodEx(array<float> pricesArr, array<float> weightsArr,
              array<int>   tierArr,  array<int>   typeArr,
              array<int>   tfArr,    array<int>   ageArr,
              float p, float w, int tier, int typeId, int tfId, int ageBar) =>
    if not na(p) and w > 0 and not na(w)
        array.push(pricesArr,  p)
        array.push(weightsArr, w)
        array.push(tierArr,    tier)
        array.push(typeArr,    typeId)
        array.push(tfArr,      tfId)
        array.push(ageArr,     ageBar)

f_snapPos(string s) =>
    switch s
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        =>                position.top_right

// Pick black or white text for best contrast on a given fill colour.
f_textOn(color c) =>
    float lum = 0.299 * color.r(c) + 0.587 * color.g(c) + 0.114 * color.b(c)
    lum >= 150 ? color.rgb(15, 18, 28) : color.rgb(245, 247, 250)

// Plain-English strength tier from the 0-10 score.
f_strengthWord(float s) =>
    s >= fortressLevel ? "Very Strong" : s >= 6.5 ? "Strong" : s >= 5.0 ? "Moderate" : "Weak"

f_calBin(float s) =>
    int b = -1
    if s >= fortressLevel
        b := 2
    else if s >= 5.0
        b := 1
    else if s >= 4.0
        b := 0
    b

f_volumeBucketPOC(int len, int rows) =>
    float profHigh = ta.highest(high, len)
    float profLow  = ta.lowest (low,  len)
    float step     = (profHigh - profLow) / rows
    float pocPx    = na
    if step > 0 and not na(profHigh) and not na(profLow)
        array<float> buckets = array.new<float>(rows, 0.0)
        for k = 0 to len - 1
            float bH = high[k]
            float bL = low [k]
            float bV = nz(volume[k])
            float bR = bH - bL
            int   lvl = 0
            float lvlPx = profLow
            while lvl < rows and lvlPx < profHigh
                if bH >= lvlPx and bL < lvlPx + step
                    float contrib = bR == 0 ? bV : bV * step / bR
                    array.set(buckets, lvl, array.get(buckets, lvl) + contrib)
                lvl   += 1
                lvlPx += step
        float maxV  = -1.0
        int   maxLv = 0
        for r = 0 to rows - 1
            float v = array.get(buckets, r)
            if v > maxV
                maxV  := v
                maxLv := r
        pocPx := profLow + (maxLv + 0.5) * step
    pocPx

// v5 — path-efficiency + variance-ratio pair, self-contained so it can be evaluated on a
//      FIXED regime TF via request.security (keeps trend/range styling identical across chart TFs).
f_regimePair() =>
    float nd  = math.abs(close - close[regWinBase])
    float pl_ = math.sum(math.abs(close - close[1]), regWinBase)
    float ef  = pl_ > 0 ? nd / pl_ : 0.0
    float lr1 = math.log(close / math.max(nz(close[1], close), 0.0001))
    float vv1 = ta.variance(lr1, regVrLen)
    float lrk = math.log(close / math.max(nz(close[regVrK], close), 0.0001))
    float vvk = ta.variance(lrk, regVrLen)
    float vr_ = (vv1 > 0 and regVrK > 0) ? vvk / (regVrK * vv1) : 1.0
    [ef, vr_]

// ========================================================================
//  5 - CORE CALCULATIONS
// ========================================================================
float atrVal = ta.atr(14)
float volAvg = ta.sma(volume, 20)
bool  effVolFilter = useVolFilter and useVolumeMode

// ========================================================================
//  5b - MULTI-WINDOW VOLUME CONSENSUS
// ========================================================================
float mvcVolPctShort = ta.percentile_linear_interpolation(volume, mvcShort, mvcPct)
float mvcVolPctMid   = ta.percentile_linear_interpolation(volume, mvcMid,   mvcPct)
float mvcVolPctLong  = ta.percentile_linear_interpolation(volume, mvcLong,  mvcPct)
int   mvcHits = (volume >= mvcVolPctShort ? 1 : 0) + (volume >= mvcVolPctMid ? 1 : 0) + (volume >= mvcVolPctLong ? 1 : 0)
int   mvcReq  = mvcCons == "Any window" ? 1 : mvcCons == "Majority (2 of 3)" ? 2 : 3
bool  mvcConfirmed = (useMVC and useVolumeMode) ? (mvcHits >= mvcReq) : true

// ========================================================================
//  5c - REGIME READ  (path efficiency + variance ratio)
// ========================================================================
int   regWin     = f_scaleLookback(regWinBase)
float reg_netDisp = math.abs(close - close[regWin])
float reg_pathLen = math.sum(math.abs(close - close[1]), regWin)
float reg_eff     = reg_pathLen > 0 ? reg_netDisp / reg_pathLen : 0.0      // 0..1, high = clean/trending

float reg_r1   = math.log(close / math.max(nz(close[1], close), 0.0001))
float reg_var1 = ta.variance(reg_r1, regVrLen)
float reg_rk   = math.log(close / math.max(nz(close[regVrK], close), 0.0001))
float reg_vark = ta.variance(reg_rk, regVrLen)
float reg_vr   = (reg_var1 > 0 and regVrK > 0) ? reg_vark / (regVrK * reg_var1) : 1.0

// v5 — in core mode read the regime from a FIXED TF so trend/range styling and the show-threshold
//      lift are identical on every chart TF (otherwise a chart-TF regime would flip solid/dashed
//      and change which levels survive per TF, defeating the coherent map).
[coreEff, coreVr] = request.security(syminfo.tickerid, coreRegimeTf, f_regimePair(), lookahead=barmerge.lookahead_off)
if useMtfCore and useRegime
    reg_eff := na(coreEff) ? reg_eff : coreEff
    reg_vr  := na(coreVr)  ? reg_vr  : coreVr

bool regTrending = useRegime and (reg_eff >= regEffTrend or reg_vr >= 1.15)
bool regPinning  = useRegime and (reg_eff <  regEffRange and reg_vr <= 0.85)
string regimeTxt = not useRegime ? "off" : regTrending ? "Trend" : regPinning ? "Range" : "Mixed"
float regLift    = regTrending ? regTrendLift : 0.0

// ========================================================================
//  6 - LAYER 1A - TIER-1 ANCHOR DETECTION
// ========================================================================
float vPctShort_raw = ta.percentile_linear_interpolation(volume, shortWin, volPctThresh)
float vPctMid_raw   = ta.percentile_linear_interpolation(volume, midWin,   volPctThresh)
float vPctLong_raw  = ta.percentile_linear_interpolation(volume, longWin,  volPctThresh)
float vPctShort = useVolumeMode ? vPctShort_raw : na
float vPctMid   = useVolumeMode ? vPctMid_raw   : na
float vPctLong  = useVolumeMode ? vPctLong_raw  : na

float barRange  = high - low
float rPctShort = ta.percentile_linear_interpolation(barRange, shortWin, rangePctThresh)
float rPctMid   = ta.percentile_linear_interpolation(barRange, midWin,   rangePctThresh)
float rPctLong  = ta.percentile_linear_interpolation(barRange, longWin,  rangePctThresh)

int volWindowHits = useVolumeMode ?
     (volume >= vPctShort ? 1 : 0) + (volume >= vPctMid ? 1 : 0) + (volume >= vPctLong ? 1 : 0) : 0
int rangeWindowHits =
     (barRange >= rPctShort ? 1 : 0) + (barRange >= rPctMid ? 1 : 0) + (barRange >= rPctLong ? 1 : 0)

int consensusReq = consensusMode == "Any window" ? 1 : consensusMode == "Majority (2 of 3)" ? 2 : 3
bool volConsensus   = useVolumeMode ? volWindowHits   >= consensusReq : true
bool rangeConsensus = rangeWindowHits >= consensusReq

bool isTier1Legacy = useVolumeMode ? (volume >= volMultInput * volAvg and barRange >= rangeMultInput * atrVal) :
                                     (barRange >= rangeMultInput * atrVal)
bool isTier1Modern = volConsensus and rangeConsensus
bool isTier1 = detectMode == "Legacy (volume x avg)" ? isTier1Legacy : isTier1Modern

// ========================================================================
//  7 - LAYER 1B - ABSORPTION ANCHOR DETECTION  (no candle tint in v4)
// ========================================================================
float rPctShortAbs = ta.percentile_linear_interpolation(barRange, shortWin, absRangeMaxPct)
float rPctMidAbs   = ta.percentile_linear_interpolation(barRange, midWin,   absRangeMaxPct)
float rPctLongAbs  = ta.percentile_linear_interpolation(barRange, longWin,  absRangeMaxPct)

int rangeBelowAbsHits = (barRange <= rPctShortAbs ? 1 : 0) + (barRange <= rPctMidAbs ? 1 : 0) + (barRange <= rPctLongAbs ? 1 : 0)
bool rangeIsNarrow = rangeBelowAbsHits >= consensusReq

float barMid = (high + low) / 2.0
float closeOffset = barRange > 0 ? math.abs(close - barMid) / barRange : 1.0
bool  closeInMid  = closeOffset <= absCloseMidMax

bool isAbsorption = useAbsorption and useVolumeMode and volConsensus and rangeIsNarrow and closeInMid and mvcConfirmed

// ========================================================================
//  8 - LAYER 1C - ANCHOR ARRAY MANAGEMENT
// ========================================================================
var array<int>   anchorBars = array.new<int>()
var array<float> anchorHigh = array.new<float>()
var array<float> anchorLow  = array.new<float>()

if isTier1 and barstate.isconfirmed
    array.unshift(anchorBars, bar_index)
    array.unshift(anchorHigh, high)
    array.unshift(anchorLow,  low)
    if array.size(anchorBars) > maxAnchors
        array.pop(anchorBars)
        array.pop(anchorHigh)
        array.pop(anchorLow)

var array<int>   absBars   = array.new<int>()
var array<float> absHighs  = array.new<float>()
var array<float> absLows   = array.new<float>()
var array<float> absCloses = array.new<float>()

if isAbsorption and barstate.isconfirmed
    array.unshift(absBars,   bar_index)
    array.unshift(absHighs,  high)
    array.unshift(absLows,   low)
    array.unshift(absCloses, close)
    if array.size(absBars) > maxAbsorptions
        array.pop(absBars)
        array.pop(absHighs)
        array.pop(absLows)
        array.pop(absCloses)

// ========================================================================
//  9 - LAYER 2 - ANCHORED VWAP + SIGMA + FIB  (votes only; not plotted)
// ========================================================================
int mostRecentAnchorBar = array.size(anchorBars) > 0 ? array.get(anchorBars, 0) : na
bool isAnchorBar = not na(mostRecentAnchorBar) and bar_index == mostRecentAnchorBar

[avwapVal,    avwapUpper1, avwapLower1] = ta.vwap(srcPrice, isAnchorBar, 1.0)
[_avwap2c,    avwapUpper2, avwapLower2] = ta.vwap(srcPrice, isAnchorBar, 2.0)
[_fib382c,    fibUp382,    fibDn382   ] = ta.vwap(srcPrice, isAnchorBar, fibBaseMult * 0.382)
[_fib618c,    fibUp618,    fibDn618   ] = ta.vwap(srcPrice, isAnchorBar, fibBaseMult * 0.618)
[_fib1c,      fibUp1,      fibDn1     ] = ta.vwap(srcPrice, isAnchorBar, fibBaseMult * 1.000)

bool avwapHealthy = useVolumeMode and useAVWAPVote and not na(avwapVal)

// ========================================================================
// 10 - LAYER 3A - ANCHORED VOLUME PROFILE -> POC / VAH / VAL  (votes only)
// ========================================================================
var float pocPrice = na
var float vahPrice = na
var float valPrice = na
var bool  vpBuilt  = false

var array<float> nakedPOCPrices = array.new<float>()
var array<int>   nakedPOCBars   = array.new<int>()
var int prevAnchorBar = na

if useVP and useVolumeMode and isTier1 and barstate.isconfirmed
    if not na(pocPrice) and trackNakedPOC and not na(prevAnchorBar) and mvcConfirmed
        array.unshift(nakedPOCPrices, pocPrice)
        array.unshift(nakedPOCBars,   prevAnchorBar)
        if array.size(nakedPOCPrices) > 10
            array.pop(nakedPOCPrices)
            array.pop(nakedPOCBars)
    prevAnchorBar := bar_index

if useVP and useVolumeMode and barstate.islast and array.size(anchorBars) > 0
    int ab = array.get(anchorBars, 0)
    int profileLen = bar_index - ab
    if profileLen > 2 and profileLen < 4900
        float profHigh = high[profileLen]
        float profLow  = low [profileLen]
        for k = 0 to profileLen - 1
            profHigh := math.max(profHigh, high[k])
            profLow  := math.min(profLow,  low [k])
        float priceStep = (profHigh - profLow) / vpLevels
        if priceStep > 0
            array<float> volBuckets = array.new<float>(vpLevels, 0.0)
            for k = 0 to profileLen - 1
                float bH = high[k]
                float bL = low [k]
                float bV = nz(volume[k])
                float bR = bH - bL
                int   lvl = 0
                float lvlPrice = profLow
                while lvl < vpLevels and lvlPrice < profHigh
                    if bH >= lvlPrice and bL < lvlPrice + priceStep
                        float contrib = bR == 0 ? bV : bV * priceStep / bR
                        array.set(volBuckets, lvl, array.get(volBuckets, lvl) + contrib)
                    lvl      += 1
                    lvlPrice += priceStep
            int pocLvl = array.indexof(volBuckets, array.max(volBuckets))
            pocPrice := profLow + (pocLvl + 0.5) * priceStep
            float totalVA = array.sum(volBuckets) * vpValueArea
            float vaSum   = array.get(volBuckets, pocLvl)
            int upperLvl = pocLvl
            int lowerLvl = pocLvl
            while vaSum < totalVA
                if upperLvl >= vpLevels - 1 and lowerLvl <= 0
                    break
                float volAbove = upperLvl < vpLevels - 1 ? array.get(volBuckets, upperLvl + 1) : 0.0
                float volBelow = lowerLvl > 0 ? array.get(volBuckets, lowerLvl - 1) : 0.0
                if volAbove == 0 and volBelow == 0
                    break
                if volAbove >= volBelow
                    vaSum    += volAbove
                    upperLvl += 1
                else
                    vaSum    += volBelow
                    lowerLvl -= 1
            vahPrice := profLow + (upperLvl + 1) * priceStep
            valPrice := profLow +  lowerLvl       * priceStep
            vpBuilt  := true

if trackNakedPOC and barstate.isconfirmed and array.size(nakedPOCPrices) > 0
    int i = array.size(nakedPOCPrices) - 1
    while i >= 0
        float npp = array.get(nakedPOCPrices, i)
        if math.sign(close[1] - npp) != math.sign(close - npp)
            array.remove(nakedPOCPrices, i)
            array.remove(nakedPOCBars,   i)
        i -= 1

// ========================================================================
// 11 - LAYER 3B - POC IMBALANCE BIAS (LTF flow)
// ========================================================================
float upVolFlow = close >= open ? volume : 0.0
float dnVolFlow = close <  open ? volume : 0.0
array<float> ltfUpVol = request.security_lower_tf(syminfo.tickerid, imbLtf, upVolFlow)
array<float> ltfDnVol = request.security_lower_tf(syminfo.tickerid, imbLtf, dnVolFlow)

var int   pocBias     = 0
var float pocBuyRatio = 0.5
var bool  imbalanceHealthy = false

if useImbalance and useVolumeMode and barstate.islast and not na(pocPrice) and array.size(ltfUpVol) > 0
    float totalUp = 0.0
    float totalDn = 0.0
    int ltfN = array.size(ltfUpVol)
    for k = 0 to ltfN - 1
        totalUp += nz(array.get(ltfUpVol, k))
        totalDn += nz(array.get(ltfDnVol, k))
    float total = totalUp + totalDn
    if total > 0
        pocBuyRatio := totalUp / total
        pocBias     := pocBuyRatio >= imbThreshold ? 1 : pocBuyRatio <= (1.0 - imbThreshold) ? -1 : 0
        imbalanceHealthy := true

// ========================================================================
// 12 - LAYER 3C - PER-HTF VP-POCs (votes only; bundled fetch)
// ========================================================================
f_htfAll(string tf) =>
    request.security(syminfo.tickerid, tf,
         [f_volumeBucketPOC(htfVPLevels, htfVPRows),
          ta.pivothigh(high, 5, 5),
          ta.pivotlow (low,  5, 5),
          close],
         lookahead=barmerge.lookahead_off)

[htf1POC_raw, h1ph_raw, h1pl_raw, h1c_raw] = f_htfAll(htf1)
[htf2POC_raw, h2ph_raw, h2pl_raw, h2c_raw] = f_htfAll(htf2)
[htf3POC_raw, h3ph_raw, h3pl_raw, h3c_raw] = f_htfAll(htf3)
[htf4POC_raw, h4ph_raw, h4pl_raw, h4c_raw] = f_htfAll(htf4)
float htf1POC = useHTFVP and useHTF1 and useVolumeMode ? htf1POC_raw : na
float htf2POC = useHTFVP and useHTF2 and useVolumeMode ? htf2POC_raw : na
float htf3POC = useHTFVP and useHTF3 and useVolumeMode ? htf3POC_raw : na
float htf4POC = useHTFVP and useHTF4 and useVolumeMode ? htf4POC_raw : na

var float htf1POC_last = na
var int   htf1POC_bar  = na
var float htf2POC_last = na
var int   htf2POC_bar  = na
var float htf3POC_last = na
var int   htf3POC_bar  = na
var float htf4POC_last = na
var int   htf4POC_bar  = na

if not na(htf1POC) and htf1POC != htf1POC_last
    htf1POC_last := htf1POC
    htf1POC_bar := bar_index
if not na(htf2POC) and htf2POC != htf2POC_last
    htf2POC_last := htf2POC
    htf2POC_bar := bar_index
if not na(htf3POC) and htf3POC != htf3POC_last
    htf3POC_last := htf3POC
    htf3POC_bar := bar_index
if not na(htf4POC) and htf4POC != htf4POC_last
    htf4POC_last := htf4POC
    htf4POC_bar := bar_index

// ========================================================================
// 12b - COHERENT MTF CORE FETCHES  (base-TF bundle + prior-period H/L/C, all fixed-TF)
// ========================================================================
// Base anchor rung (default 15m): same bundle shape as the HTF fetch — POC + pivots + close.
[cbPOC_raw, cbph_raw, cbpl_raw, cbc_raw] = request.security(syminfo.tickerid, coreBaseTf,
     [f_volumeBucketPOC(htfVPLevels, htfVPRows),
      ta.pivothigh(high, 5, 5),
      ta.pivotlow (low,  5, 5),
      close],
     lookahead=barmerge.lookahead_off)
float cbPOC = useMtfCore and useVolumeMode ? cbPOC_raw : na

var float cbPOC_last = na
var int   cbPOC_bar  = na
var float cbph_last  = na
var int   cbph_bar   = na
var float cbpl_last  = na
var int   cbpl_bar   = na
if not na(cbPOC) and cbPOC != cbPOC_last
    cbPOC_last := cbPOC
    cbPOC_bar  := bar_index
if not na(cbph_raw)
    cbph_last := cbph_raw
    cbph_bar  := bar_index
if not na(cbpl_raw)
    cbpl_last := cbpl_raw
    cbpl_bar  := bar_index

// Classic prior-period H/L/C for each anchor rung — PDH/PDL, PWH/PWL, etc.  These are anchored
// to the wall-clock period boundary, not to any bar-count, so they are identical on every chart TF.
f_prevHLC(string tf) => request.security(syminfo.tickerid, tf, [high[1], low[1], close[1]], lookahead=barmerge.lookahead_off)
[pB_h, pB_l, pB_c] = f_prevHLC(coreBaseTf)
[p1_h, p1_l, p1_c] = f_prevHLC(htf1)
[p2_h, p2_l, p2_c] = f_prevHLC(htf2)
[p3_h, p3_l, p3_c] = f_prevHLC(htf3)
[p4_h, p4_l, p4_c] = f_prevHLC(htf4)

// TF-invariant absolute price tolerance (a fixed % of price) for merge / tightness / separation.
float corePxTol = math.max(close * coreClusterPct / 100.0, syminfo.mintick)

// ========================================================================
// 13 - LAYER 4 - STRUCTURAL LEVELS  (votes only; no markers)
// ========================================================================
float ph = ta.pivothigh(high, pivotLen, pivotLen)
float pl = ta.pivotlow (low,  pivotLen, pivotLen)

bool phValid = not na(ph) and (not effVolFilter or volume[pivotLen] >= volFilterMult * volAvg[pivotLen])
bool plValid = not na(pl) and (not effVolFilter or volume[pivotLen] >= volFilterMult * volAvg[pivotLen])

var array<float> swingHighs    = array.new<float>()
var array<float> swingLows     = array.new<float>()
var array<int>   swingHighBars = array.new<int>()
var array<int>   swingLowBars  = array.new<int>()

if phValid
    array.unshift(swingHighs,    ph)
    array.unshift(swingHighBars, bar_index - pivotLen)
    if array.size(swingHighs) > 10
        array.pop(swingHighs)
        array.pop(swingHighBars)
if plValid
    array.unshift(swingLows,    pl)
    array.unshift(swingLowBars, bar_index - pivotLen)
    if array.size(swingLows) > 10
        array.pop(swingLows)
        array.pop(swingLowBars)

// ========================================================================
// 14 - LAYER 5 - MULTI-TIMEFRAME PIVOTS  (from bundled fetch)
// ========================================================================
float h1ph = useHTF1 ? h1ph_raw : na
float h1pl = useHTF1 ? h1pl_raw : na
float h1c  = useHTF1 ? h1c_raw  : na
float h2ph = useHTF2 ? h2ph_raw : na
float h2pl = useHTF2 ? h2pl_raw : na
float h2c  = useHTF2 ? h2c_raw  : na
float h3ph = useHTF3 ? h3ph_raw : na
float h3pl = useHTF3 ? h3pl_raw : na
float h3c  = useHTF3 ? h3c_raw  : na
float h4ph = useHTF4 ? h4ph_raw : na
float h4pl = useHTF4 ? h4pl_raw : na
float h4c  = useHTF4 ? h4c_raw  : na

var float h1ph_last = na
var float h1pl_last = na
var float h2ph_last = na
var float h2pl_last = na
var float h3ph_last = na
var float h3pl_last = na
var float h4ph_last = na
var float h4pl_last = na
var int h1ph_bar = na
var int h1pl_bar = na
var int h2ph_bar = na
var int h2pl_bar = na
var int h3ph_bar = na
var int h3pl_bar = na
var int h4ph_bar = na
var int h4pl_bar = na

if not na(h1ph)
    h1ph_last := h1ph
    h1ph_bar := bar_index
if not na(h1pl)
    h1pl_last := h1pl
    h1pl_bar := bar_index
if not na(h2ph)
    h2ph_last := h2ph
    h2ph_bar := bar_index
if not na(h2pl)
    h2pl_last := h2pl
    h2pl_bar := bar_index
if not na(h3ph)
    h3ph_last := h3ph
    h3ph_bar := bar_index
if not na(h3pl)
    h3pl_last := h3pl
    h3pl_bar := bar_index
if not na(h4ph)
    h4ph_last := h4ph
    h4ph_bar := bar_index
if not na(h4pl)
    h4pl_last := h4pl
    h4pl_bar := bar_index

bool htf1Healthy = useHTF1 and (not na(h1ph_last) or not na(h1pl_last) or not na(h1c))
bool htf2Healthy = useHTF2 and (not na(h2ph_last) or not na(h2pl_last) or not na(h2c))
bool htf3Healthy = useHTF3 and (not na(h3ph_last) or not na(h3pl_last) or not na(h3c))
bool htf4Healthy = useHTF4 and (not na(h4ph_last) or not na(h4pl_last) or not na(h4c))

// ========================================================================
// 15 - CALIBRATION STATE (declared early so the respect nudge can read it)
// ========================================================================
var int[]   cal_total    = array.new_int(3, 0)
var int[]   cal_correct  = array.new_int(3, 0)
var int[]   pend_bar     = array.new_int(0)
var float[] pend_price   = array.new_float(0)
var float[] pend_atr     = array.new_float(0)
var int[]   pend_dir     = array.new_int(0)
var int[]   pend_bin     = array.new_int(0)
var int[]   pend_t0      = array.new_int(0)          // v4.1: signal time, for the OOS split

// v4.1 — regime-matched base rate, walk-forward OOS, and LTF high/low for path-honest fills
[qHi_cal, qLo_cal] = request.security_lower_tf(syminfo.tickerid, imbLtf, [high, low])
int nLtfCal = array.size(qHi_cal)
var int     baseN  = 0
var int     baseUp = 0
var int     baseDn = 0
var int[]   bq_bar = array.new_int(0)
var float[] bq_px  = array.new_float(0)
var float[] bq_atr = array.new_float(0)
var float   isN = 0.0
var float   isW = 0.0
var float   oosN = 0.0
var float   oosW = 0.0

// v4.1 — nudge each zone by ITS score-bin's Wilson-floored edge over the regime-matched base,
//        proportionally (not a binary ±bonus). A +15pp Wilson-floored edge earns the full bonus.
f_respectNudge(float s, int dir) =>
    float nudge = 0.0
    if useRespect and calEnable
        int b = f_calBin(s)
        if b >= 0
            int tot = array.get(cal_total, b)
            int cor = array.get(cal_correct, b)
            if tot >= respectMinN
                float lo   = cal.wilsonLo(cor, tot, 1.64) / 100.0
                float base = dir > 0 ? (baseN > 0 ? baseUp / float(baseN) : 0.5) : (baseN > 0 ? baseDn / float(baseN) : 0.5)
                float edge = lo - base
                nudge := respectBonus * math.max(-1.0, math.min(1.0, edge / 0.15))
    nudge

// ========================================================================
// 16 - ZONE / LINE STORAGE & TOP-ZONE METADATA
// ========================================================================
var array<line>  srLines  = array.new<line>()
var array<label> srLabels = array.new<label>()

var float topZonePrice      = na
var float topZoneScore      = na
var bool  topZoneIsSupport  = true
var bool  topZoneIsFortress = false
var int   topZoneMethodCnt  = 0
var float topZoneUpper      = na
var float topZoneLower      = na
var int   totalRenderedZones = 0
var int   fortressZonesCount = 0

var float exp_zone1_px  = na
var float exp_zone1_sc  = na
var int   exp_zone1_dir = 0
var int   exp_zone1_ft  = 0
var float exp_zone2_px  = na
var float exp_zone2_sc  = na
var int   exp_zone2_dir = 0
var int   exp_zone2_ft  = 0
var float exp_zone3_px  = na
var float exp_zone3_sc  = na
var int   exp_zone3_dir = 0
var int   exp_zone3_ft  = 0

var int   exp_supportsAbovePrice    = 0
var int   exp_resistancesAbovePrice = 0
var int   exp_supportsBelowPrice    = 0
var int   exp_resistancesBelowPrice = 0
var float exp_nearestSupportPx      = na
var float exp_nearestSupportSc      = na
var float exp_nearestResistancePx   = na
var float exp_nearestResistanceSc   = na
var float exp_distToNearestSupATR   = na
var float exp_distToNearestResATR   = na

var float exp_topZoneDistATR = na
var float exp_topZoneDistPct = na

var float exp_lastAnchorHigh = na
var float exp_lastAnchorLow  = na
var int   exp_lastAnchorAge  = na
var int   exp_absorptionCount = 0

var int   exp_nakedPocCount         = 0
var float exp_nakedPocNearestPx     = na
var float exp_nakedPocNearestDistATR = na

var float prevTopScore   = na
var int   prevPocBias    = 0
var int   prevFortressCnt = 0
var bool  prevHealthOK   = true

// ========================================================================
// 17 - METHOD COLLECTION -> CLUSTERING -> SCORING -> LINE RENDER
// ========================================================================
if barstate.islast
    if array.size(srLines) > 0
        for i = 0 to array.size(srLines) - 1
            line.delete(array.get(srLines, i))
        array.clear(srLines)
    if array.size(srLabels) > 0
        for i = 0 to array.size(srLabels) - 1
            label.delete(array.get(srLabels, i))
        array.clear(srLabels)

    topZonePrice      := na
    topZoneScore      := na
    topZoneIsSupport  := true
    topZoneIsFortress := false
    topZoneMethodCnt  := 0
    topZoneUpper      := na
    topZoneLower      := na
    totalRenderedZones := 0
    fortressZonesCount := 0

    exp_zone1_px  := na
    exp_zone1_sc  := na
    exp_zone1_dir := 0
    exp_zone1_ft  := 0
    exp_zone2_px  := na
    exp_zone2_sc  := na
    exp_zone2_dir := 0
    exp_zone2_ft  := 0
    exp_zone3_px  := na
    exp_zone3_sc  := na
    exp_zone3_dir := 0
    exp_zone3_ft  := 0

    exp_supportsAbovePrice    := 0
    exp_resistancesAbovePrice := 0
    exp_supportsBelowPrice    := 0
    exp_resistancesBelowPrice := 0
    exp_nearestSupportPx      := na
    exp_nearestSupportSc      := na
    exp_nearestResistancePx   := na
    exp_nearestResistanceSc   := na
    exp_distToNearestSupATR   := na
    exp_distToNearestResATR   := na
    exp_topZoneDistATR        := na
    exp_topZoneDistPct        := na

    array<float> mPrices  = array.new<float>()
    array<float> mWeights = array.new<float>()
    array<int>   mTiers   = array.new<int>()
    array<int>   mTypes   = array.new<int>()
    array<int>   mTFs     = array.new<int>()
    array<int>   mAges    = array.new<int>()

    int anchorAge = array.size(anchorBars) > 0 ? array.get(anchorBars, 0) : bar_index

    // v5 — coherent-core switch. When core is on, only fixed anchor-TF votes build the primary map
    //      (so it is identical on every chart TF). The chart-timeframe votes below are pushed only
    //      when core is off, or when the user explicitly overlays the local layer.
    bool useLocal = (not useMtfCore) or useLocalLayer

    // ---- Coherent MTF core votes (base rung + classic prior-period levels; all fixed-TF) ----
    // Type ids: 1 POC · 7 pivot · 13 prior-period H/L · 10 prior close.  TF ids: base=5, HTF1..4=1..4.
    if useMtfCore
        // base rung (default 15m): POC + pivots
        if not na(cbPOC_last)
            f_addMethodEx(mPrices, mWeights, mTiers, mTypes, mTFs, mAges, cbPOC_last, 2.5 * 1.4, 3, 1, 5, bar_index)
        if not na(cbph_last)
            f_addMethodEx(mPrices, mWeights, mTiers, mTypes, mTFs, mAges, cbph_last, 1.5, 3, 7, 5, bar_index)
        if not na(cbpl_last)
            f_addMethodEx(mPrices, mWeights, mTiers, mTypes, mTFs, mAges, cbpl_last, 1.5, 3, 7, 5, bar_index)
        // base rung prior-period H/L/C
        if not na(pB_h)
            f_addMethodEx(mPrices, mWeights, mTiers, mTypes, mTFs, mAges, pB_h, 1.3, 3, 13, 5, bar_index)
        if not na(pB_l)
            f_addMethodEx(mPrices, mWeights, mTiers, mTypes, mTFs, mAges, pB_l, 1.3, 3, 13, 5, bar_index)
        if not na(pB_c)
            f_addMethodEx(mPrices, mWeights, mTiers, mTypes, mTFs, mAges, pB_c, 0.6, 1, 10, 5, bar_index)
        // higher rungs' prior-period H/L (PDH/PDL, PWH/PWL, …) — weight & tier climb with the TF
        if useHTF1 and not na(p1_h)
            f_addMethodEx(mPrices, mWeights, mTiers, mTypes, mTFs, mAges, p1_h, 1.3 * 1.3, 3, 13, 1, bar_index)
        if useHTF1 and not na(p1_l)
            f_addMethodEx(mPrices, mWeights, mTiers, mTypes, mTFs, mAges, p1_l, 1.3 * 1.3, 3, 13, 1, bar_index)
        if useHTF2 and not na(p2_h)
            f_addMethodEx(mPrices, mWeights, mTiers, mTypes, mTFs, mAges, p2_h, 1.3 * 1.7, 4, 13, 2, bar_index)
        if useHTF2 and not na(p2_l)
            f_addMethodEx(mPrices, mWeights, mTiers, mTypes, mTFs, mAges, p2_l, 1.3 * 1.7, 4, 13, 2, bar_index)
        if useHTF3 and not na(p3_h)
            f_addMethodEx(mPrices, mWeights, mTiers, mTypes, mTFs, mAges, p3_h, 1.3 * 2.2, 5, 13, 3, bar_index)
        if useHTF3 and not na(p3_l)
            f_addMethodEx(mPrices, mWeights, mTiers, mTypes, mTFs, mAges, p3_l, 1.3 * 2.2, 5, 13, 3, bar_index)
        if useHTF4 and not na(p4_h)
            f_addMethodEx(mPrices, mWeights, mTiers, mTypes, mTFs, mAges, p4_h, 1.3 * 2.8, 5, 13, 4, bar_index)
        if useHTF4 and not na(p4_l)
            f_addMethodEx(mPrices, mWeights, mTiers, mTypes, mTFs, mAges, p4_l, 1.3 * 2.8, 5, 13, 4, bar_index)

    float pocWeight = useImbalance and pocBias != 0 ? 3.0 : 2.5
    if useLocal and useVP and vpBuilt
        f_addMethodEx(mPrices, mWeights, mTiers, mTypes, mTFs, mAges, pocPrice, pocWeight, 5, 1, 0, anchorAge)
    if useLocal and trackNakedPOC and array.size(nakedPOCPrices) > 0
        for i = 0 to array.size(nakedPOCPrices) - 1
            f_addMethodEx(mPrices, mWeights, mTiers, mTypes, mTFs, mAges,
                 array.get(nakedPOCPrices, i), 2.5, 5, 2, 0, array.get(nakedPOCBars, i))
    if useLocal and array.size(anchorHigh) > 0
        f_addMethodEx(mPrices, mWeights, mTiers, mTypes, mTFs, mAges, array.get(anchorHigh, 0), 2.5, 5, 3, 0, anchorAge)
        f_addMethodEx(mPrices, mWeights, mTiers, mTypes, mTFs, mAges, array.get(anchorLow,  0), 2.5, 5, 3, 0, anchorAge)
    if useLocal and useAbsorption and array.size(absBars) > 0
        for ai = 0 to array.size(absBars) - 1
            int aBar = array.get(absBars, ai)
            f_addMethodEx(mPrices, mWeights, mTiers, mTypes, mTFs, mAges, array.get(absHighs,  ai), 2.5, 5, 11, 0, aBar)
            f_addMethodEx(mPrices, mWeights, mTiers, mTypes, mTFs, mAges, array.get(absLows,   ai), 2.5, 5, 11, 0, aBar)
            f_addMethodEx(mPrices, mWeights, mTiers, mTypes, mTFs, mAges, array.get(absCloses, ai), 2.5, 5, 11, 0, aBar)
    if useHTFVP
        if useHTF1 and not na(htf1POC_last)
            f_addMethodEx(mPrices, mWeights, mTiers, mTypes, mTFs, mAges, htf1POC_last, 2.5 * 1.0, 5, 12, 1, nz(htf1POC_bar, anchorAge))
        if useHTF2 and not na(htf2POC_last)
            f_addMethodEx(mPrices, mWeights, mTiers, mTypes, mTFs, mAges, htf2POC_last, 2.5 * 1.2, 5, 12, 2, nz(htf2POC_bar, anchorAge))
        if useHTF3 and not na(htf3POC_last)
            f_addMethodEx(mPrices, mWeights, mTiers, mTypes, mTFs, mAges, htf3POC_last, 2.5 * 1.5, 5, 12, 3, nz(htf3POC_bar, anchorAge))
        if useHTF4 and not na(htf4POC_last)
            f_addMethodEx(mPrices, mWeights, mTiers, mTypes, mTFs, mAges, htf4POC_last, 2.5 * 2.0, 5, 12, 4, nz(htf4POC_bar, anchorAge))

    if useLocal and useVP and vpBuilt
        f_addMethodEx(mPrices, mWeights, mTiers, mTypes, mTFs, mAges, vahPrice, 2.0, 4, 4, 0, anchorAge)
        f_addMethodEx(mPrices, mWeights, mTiers, mTypes, mTFs, mAges, valPrice, 2.0, 4, 4, 0, anchorAge)
    if useLocal and array.size(swingHighs) > 0
        f_addMethodEx(mPrices, mWeights, mTiers, mTypes, mTFs, mAges, array.get(swingHighs, 0), 2.0, 4, 5, 0, array.get(swingHighBars, 0))
    if useLocal and array.size(swingLows) > 0
        f_addMethodEx(mPrices, mWeights, mTiers, mTypes, mTFs, mAges, array.get(swingLows, 0), 2.0, 4, 5, 0, array.get(swingLowBars, 0))
    if useLocal and avwapHealthy
        f_addMethodEx(mPrices, mWeights, mTiers, mTypes, mTFs, mAges, avwapVal, 2.0, 4, 6, 0, anchorAge)
    if useLocal and useFibBands and showFib618 and avwapHealthy
        f_addMethodEx(mPrices, mWeights, mTiers, mTypes, mTFs, mAges, fibUp618, 2.0, 4, 9, 0, anchorAge)
        f_addMethodEx(mPrices, mWeights, mTiers, mTypes, mTFs, mAges, fibDn618, 2.0, 4, 9, 0, anchorAge)

    if useHTF1 and not na(h1ph_last)
        f_addMethodEx(mPrices, mWeights, mTiers, mTypes, mTFs, mAges, h1ph_last, 1.5 * 1.0, 3, 7, 1, nz(h1ph_bar, anchorAge))
    if useHTF1 and not na(h1pl_last)
        f_addMethodEx(mPrices, mWeights, mTiers, mTypes, mTFs, mAges, h1pl_last, 1.5 * 1.0, 3, 7, 1, nz(h1pl_bar, anchorAge))
    if useHTF2 and not na(h2ph_last)
        f_addMethodEx(mPrices, mWeights, mTiers, mTypes, mTFs, mAges, h2ph_last, 1.5 * 1.5, 3, 7, 2, nz(h2ph_bar, anchorAge))
    if useHTF2 and not na(h2pl_last)
        f_addMethodEx(mPrices, mWeights, mTiers, mTypes, mTFs, mAges, h2pl_last, 1.5 * 1.5, 3, 7, 2, nz(h2pl_bar, anchorAge))
    if useHTF3 and not na(h3ph_last)
        f_addMethodEx(mPrices, mWeights, mTiers, mTypes, mTFs, mAges, h3ph_last, 1.5 * 2.0, 3, 7, 3, nz(h3ph_bar, anchorAge))
    if useHTF3 and not na(h3pl_last)
        f_addMethodEx(mPrices, mWeights, mTiers, mTypes, mTFs, mAges, h3pl_last, 1.5 * 2.0, 3, 7, 3, nz(h3pl_bar, anchorAge))
    if useHTF4 and not na(h4ph_last)
        f_addMethodEx(mPrices, mWeights, mTiers, mTypes, mTFs, mAges, h4ph_last, 1.5 * 3.0, 3, 7, 4, nz(h4ph_bar, anchorAge))
    if useHTF4 and not na(h4pl_last)
        f_addMethodEx(mPrices, mWeights, mTiers, mTypes, mTFs, mAges, h4pl_last, 1.5 * 3.0, 3, 7, 4, nz(h4pl_bar, anchorAge))

    if useLocal and showBand1 and avwapHealthy
        f_addMethodEx(mPrices, mWeights, mTiers, mTypes, mTFs, mAges, avwapUpper1, 1.0, 2, 8, 0, anchorAge)
        f_addMethodEx(mPrices, mWeights, mTiers, mTypes, mTFs, mAges, avwapLower1, 1.0, 2, 8, 0, anchorAge)
    if useLocal and useFibBands and showFib382 and avwapHealthy
        f_addMethodEx(mPrices, mWeights, mTiers, mTypes, mTFs, mAges, fibUp382, 1.0, 2, 9, 0, anchorAge)
        f_addMethodEx(mPrices, mWeights, mTiers, mTypes, mTFs, mAges, fibDn382, 1.0, 2, 9, 0, anchorAge)
    if useLocal and array.size(swingHighs) > 1
        f_addMethodEx(mPrices, mWeights, mTiers, mTypes, mTFs, mAges,
             array.get(swingHighs, 1), 1.0, 2, 5, 0, array.get(swingHighBars, 1))
    if useLocal and array.size(swingLows) > 1
        f_addMethodEx(mPrices, mWeights, mTiers, mTypes, mTFs, mAges,
             array.get(swingLows, 1), 1.0, 2, 5, 0, array.get(swingLowBars, 1))

    if useLocal and showBand2 and avwapHealthy
        f_addMethodEx(mPrices, mWeights, mTiers, mTypes, mTFs, mAges, avwapUpper2, 0.5, 1, 8, 0, anchorAge)
        f_addMethodEx(mPrices, mWeights, mTiers, mTypes, mTFs, mAges, avwapLower2, 0.5, 1, 8, 0, anchorAge)
    if useLocal and useFibBands and showFib1 and avwapHealthy
        f_addMethodEx(mPrices, mWeights, mTiers, mTypes, mTFs, mAges, fibUp1, 0.5, 1, 9, 0, anchorAge)
        f_addMethodEx(mPrices, mWeights, mTiers, mTypes, mTFs, mAges, fibDn1, 0.5, 1, 9, 0, anchorAge)
    if useHTF1 and not na(h1c)
        f_addMethodEx(mPrices, mWeights, mTiers, mTypes, mTFs, mAges, h1c, 0.5 * 1.0, 1, 10, 1, bar_index)
    if useHTF2 and not na(h2c)
        f_addMethodEx(mPrices, mWeights, mTiers, mTypes, mTFs, mAges, h2c, 0.5 * 1.5, 1, 10, 2, bar_index)
    if useHTF3 and not na(h3c)
        f_addMethodEx(mPrices, mWeights, mTiers, mTypes, mTFs, mAges, h3c, 0.5 * 2.0, 1, 10, 3, bar_index)
    if useHTF4 and not na(h4c)
        f_addMethodEx(mPrices, mWeights, mTiers, mTypes, mTFs, mAges, h4c, 0.5 * 3.0, 1, 10, 4, bar_index)

    // v5 — in core mode the "unit" is a FIXED % of price (TF-invariant), not chart ATR, so the same
    //      neighbours merge, the same tightness reads and the same separation applies on every chart TF.
    float scoreUnit = useMtfCore ? corePxTol : atrVal
    float mergeDist = useMtfCore ? corePxTol : clusterATR * atrVal
    float halfWidth = useMtfCore ? (zoneWidthATR * corePxTol) : (zoneWidthATR * atrVal) / 2.0
    int   n = array.size(mPrices)

    if n > 1
        for i = 1 to n - 1
            float kp = array.get(mPrices,  i)
            float kw = array.get(mWeights, i)
            int   kt = array.get(mTiers,   i)
            int   ky = array.get(mTypes,   i)
            int   kf = array.get(mTFs,     i)
            int   ka = array.get(mAges,    i)
            int j = i - 1
            while j >= 0 and array.get(mPrices, j) > kp
                array.set(mPrices,  j + 1, array.get(mPrices,  j))
                array.set(mWeights, j + 1, array.get(mWeights, j))
                array.set(mTiers,   j + 1, array.get(mTiers,   j))
                array.set(mTypes,   j + 1, array.get(mTypes,   j))
                array.set(mTFs,     j + 1, array.get(mTFs,     j))
                array.set(mAges,    j + 1, array.get(mAges,    j))
                j -= 1
            array.set(mPrices,  j + 1, kp)
            array.set(mWeights, j + 1, kw)
            array.set(mTiers,   j + 1, kt)
            array.set(mTypes,   j + 1, ky)
            array.set(mTFs,     j + 1, kf)
            array.set(mAges,    j + 1, ka)

    array<float> clusterCenters    = array.new<float>()
    array<float> clusterRawWeights = array.new<float>()
    array<int>   clusterCounts     = array.new<int>()
    array<float> clusterMins       = array.new<float>()
    array<float> clusterMaxs       = array.new<float>()
    array<int>   clusterMaxTiers   = array.new<int>()
    array<int>   clusterTypeSets   = array.new<int>()
    array<int>   clusterTFSets     = array.new<int>()
    array<float> clusterAvgAge     = array.new<float>()
    array<bool>  clusterHasAbsorb  = array.new<bool>()
    array<float> clusterTierPx     = array.new<float>()   // price of the highest-tier vote (for snap)

    if n > 0
        float curCenter = array.get(mPrices,  0)
        float curWeight = array.get(mWeights, 0)
        int   curCount  = 1
        float curMin    = curCenter
        float curMax    = curCenter
        float curSum    = curCenter * curWeight
        float curWSum   = curWeight
        int   curMaxTier = array.get(mTiers, 0)
        float curTierPx  = curCenter
        int   curTypeSet = int(math.round(math.pow(2, array.get(mTypes, 0))))
        int   curTFSet   = int(math.round(math.pow(2, array.get(mTFs,   0))))
        float curAgeSum  = array.get(mAges, 0) * curWeight
        bool  curHasAbs  = array.get(mTypes, 0) == 11

        if n > 1
            for i = 1 to n - 1
                float p = array.get(mPrices,  i)
                float w = array.get(mWeights, i)
                int   t = array.get(mTiers,   i)
                int   ty = array.get(mTypes,  i)
                int   tf = array.get(mTFs,    i)
                int   ag = array.get(mAges,   i)
                if math.abs(p - curCenter) <= mergeDist
                    curSum     += p * w
                    curWSum    += w
                    curWeight  += w
                    curCount   += 1
                    curMin     := math.min(curMin, p)
                    curMax     := math.max(curMax, p)
                    curCenter  := curSum / curWSum
                    if t > curMaxTier
                        curMaxTier := t
                        curTierPx  := p
                    int typeBit = int(math.round(math.pow(2, ty)))
                    int tfBit   = int(math.round(math.pow(2, tf)))
                    curTypeSet := (curTypeSet % (typeBit * 2)) >= typeBit ? curTypeSet : curTypeSet + typeBit
                    curTFSet   := (curTFSet   % (tfBit   * 2)) >= tfBit   ? curTFSet   : curTFSet   + tfBit
                    curAgeSum  += ag * w
                    if ty == 11
                        curHasAbs := true
                else
                    array.push(clusterCenters,    curCenter)
                    array.push(clusterRawWeights, curWeight)
                    array.push(clusterCounts,     curCount)
                    array.push(clusterMins,       curMin)
                    array.push(clusterMaxs,       curMax)
                    array.push(clusterMaxTiers,   curMaxTier)
                    array.push(clusterTypeSets,   curTypeSet)
                    array.push(clusterTFSets,     curTFSet)
                    array.push(clusterAvgAge,     curAgeSum / curWSum)
                    array.push(clusterHasAbsorb,  curHasAbs)
                    array.push(clusterTierPx,     curTierPx)
                    curCenter  := p
                    curWeight  := w
                    curCount   := 1
                    curMin     := p
                    curMax     := p
                    curSum     := p * w
                    curWSum    := w
                    curMaxTier := t
                    curTierPx  := p
                    curTypeSet := int(math.round(math.pow(2, ty)))
                    curTFSet   := int(math.round(math.pow(2, tf)))
                    curAgeSum  := ag * w
                    curHasAbs  := ty == 11

        array.push(clusterCenters,    curCenter)
        array.push(clusterRawWeights, curWeight)
        array.push(clusterCounts,     curCount)
        array.push(clusterMins,       curMin)
        array.push(clusterMaxs,       curMax)
        array.push(clusterMaxTiers,   curMaxTier)
        array.push(clusterTypeSets,   curTypeSet)
        array.push(clusterTFSets,     curTFSet)
        array.push(clusterAvgAge,     curAgeSum / curWSum)
        array.push(clusterHasAbsorb,  curHasAbs)
        array.push(clusterTierPx,     curTierPx)

    array<float> clusterScores = array.new<float>()
    int nC0 = array.size(clusterCenters)

    if nC0 > 0
        for ci = 0 to nC0 - 1
            int tierMax = array.get(clusterMaxTiers, ci)
            float lvlScore = tierMax == 5 ? 3.0 : tierMax == 4 ? 2.25 : tierMax == 3 ? 1.5 : tierMax == 2 ? 0.75 : 0.25

            int ts = array.get(clusterTypeSets, ci)
            int typeCount = 0
            int tsTmp = ts
            for biT = 0 to 13
                if tsTmp % 2 == 1
                    typeCount += 1
                tsTmp := int(math.floor(tsTmp / 2.0))
            float divScore = typeCount >= 5 ? 2.5 : typeCount == 4 ? 2.0 : typeCount == 3 ? 1.5 : typeCount == 2 ? 1.0 : 0.5

            int tfs = array.get(clusterTFSets, ci)
            int tfCount = 0
            int tfsTmp = tfs
            for biF = 0 to 5
                if tfsTmp % 2 == 1
                    tfCount += 1
                tfsTmp := int(math.floor(tfsTmp / 2.0))
            float tfScore = tfCount >= 4 ? 2.0 : tfCount == 3 ? 1.5 : tfCount == 2 ? 1.0 : 0.5

            float avgAge = array.get(clusterAvgAge, ci)
            int   barsAgo = bar_index - int(avgAge)
            int recCloseT = int(math.round(50  * scaleFactor))
            int recMidT   = int(math.round(200 * scaleFactor))
            int recFarT   = int(math.round(500 * scaleFactor))
            float recScore = barsAgo <= recCloseT ? 1.5 : barsAgo <= recMidT ? 1.0 : barsAgo <= recFarT ? 0.5 : 0.0

            float zMin = array.get(clusterMins, ci)
            float zMax = array.get(clusterMaxs, ci)
            float wAtr = scoreUnit > 0 ? (zMax - zMin) / scoreUnit : 0.0
            float tightScore = wAtr <= 0.0 ? 1.0 : wAtr <= 0.15 ? 0.85 : wAtr <= 0.30 ? 0.5 : wAtr <= 0.50 ? 0.25 : 0.0

            float compositeScore = lvlScore + divScore + tfScore + recScore + tightScore
            if array.get(clusterHasAbsorb, ci)
                compositeScore := compositeScore + 0.5
            // v5 — in core mode the score is purely STRUCTURAL (so it is identical on every chart TF);
            //       the honest calibration still runs and is shown, but does not perturb the coherent score.
            compositeScore := compositeScore + (useMtfCore ? 0.0 : f_respectNudge(compositeScore, array.get(clusterCenters, ci) <= close ? 1 : -1))
            compositeScore := math.max(0.0, math.min(10.0, compositeScore))
            array.push(clusterScores, compositeScore)

    int nC = array.size(clusterCenters)
    if nC > 1
        for i = 1 to nC - 1
            float ks = array.get(clusterScores, i)
            float kC = array.get(clusterCenters, i)
            float kW = array.get(clusterRawWeights, i)
            int   kN = array.get(clusterCounts, i)
            float kMin = array.get(clusterMins, i)
            float kMax = array.get(clusterMaxs, i)
            int   kMT  = array.get(clusterMaxTiers, i)
            int   kTS  = array.get(clusterTypeSets, i)
            int   kFS  = array.get(clusterTFSets,   i)
            float kAA  = array.get(clusterAvgAge,   i)
            bool  kHA  = array.get(clusterHasAbsorb, i)
            float kTP  = array.get(clusterTierPx,   i)
            int j = i - 1
            while j >= 0 and array.get(clusterScores, j) < ks
                array.set(clusterScores,    j + 1, array.get(clusterScores,    j))
                array.set(clusterCenters,   j + 1, array.get(clusterCenters,   j))
                array.set(clusterRawWeights,j + 1, array.get(clusterRawWeights,j))
                array.set(clusterCounts,    j + 1, array.get(clusterCounts,    j))
                array.set(clusterMins,      j + 1, array.get(clusterMins,      j))
                array.set(clusterMaxs,      j + 1, array.get(clusterMaxs,      j))
                array.set(clusterMaxTiers,  j + 1, array.get(clusterMaxTiers,  j))
                array.set(clusterTypeSets,  j + 1, array.get(clusterTypeSets,  j))
                array.set(clusterTFSets,    j + 1, array.get(clusterTFSets,    j))
                array.set(clusterAvgAge,    j + 1, array.get(clusterAvgAge,    j))
                array.set(clusterHasAbsorb, j + 1, array.get(clusterHasAbsorb, j))
                array.set(clusterTierPx,    j + 1, array.get(clusterTierPx,    j))
                j -= 1
            array.set(clusterScores,    j + 1, ks)
            array.set(clusterCenters,   j + 1, kC)
            array.set(clusterRawWeights,j + 1, kW)
            array.set(clusterCounts,    j + 1, kN)
            array.set(clusterMins,      j + 1, kMin)
            array.set(clusterMaxs,      j + 1, kMax)
            array.set(clusterMaxTiers,  j + 1, kMT)
            array.set(clusterTypeSets,  j + 1, kTS)
            array.set(clusterTFSets,    j + 1, kFS)
            array.set(clusterAvgAge,    j + 1, kAA)
            array.set(clusterHasAbsorb, j + 1, kHA)
            array.set(clusterTierPx,    j + 1, kTP)

    int renderCount = math.min(array.size(clusterCenters), maxZonesDisplay)
    int exportCount = math.min(array.size(clusterCenters), 3)
    int iterCount   = math.max(renderCount, exportCount)
    int exportSlot  = 0

    // Intraday declutter: raise the show-threshold and widen separation on fast TFs.
    // v5 — the intraday declutter is a chart-TF adjustment; in core mode it is OFF so the show-threshold
    //      and line separation are identical on every chart TF (the map must not thin differently per TF).
    float ltfStrBoost = useMtfCore ? 0.0 : (autoThinIntraday ? (chartTfSecs <= 60 ? 1.0 : chartTfSecs <= 180 ? 0.5 : 0.0) : 0.0)
    float ltfSepMult  = useMtfCore ? 1.0 : ((autoThinIntraday and chartTfSecs <= 180) ? 1.5 : 1.0)
    float minSepPx    = minZoneSepATR * ltfSepMult * scoreUnit
    array<float> drawnCenters = array.new<float>()

    int lineLeft  = bar_index - math.min(bar_index, lineLeftBars)
    int lineRight = bar_index + zoneExtend

    if iterCount > 0
        for i = 0 to iterCount - 1
            float center = array.get(clusterCenters, i)
            float score  = array.get(clusterScores,  i)
            int   cnt    = array.get(clusterCounts,  i)
            float zMin   = array.get(clusterMins,    i)
            float zMax   = array.get(clusterMaxs,    i)
            bool  hasAbs = array.get(clusterHasAbsorb, i)
            float tierPx = array.get(clusterTierPx,  i)

            float effMinStrength = math.min(minStrengthShow + regLift + ltfStrBoost, fortressLevel)
            if score >= effMinStrength
                // accuracy: snap a TIGHT cluster to its strongest-tier vote
                float clWAtr = scoreUnit > 0 ? (zMax - zMin) / scoreUnit : 0.0
                float drawPx = (snapToTier and clWAtr <= 0.15 and not na(tierPx)) ? tierPx : center

                float effHalfWidth = math.max(halfWidth, scoreUnit * 0.10)
                float upper = drawPx + effHalfWidth
                float lower = drawPx - effHalfWidth

                bool isSupport = drawPx < close
                int typeSetForCluster = array.get(clusterTypeSets, i)
                bool hasPOC = (typeSetForCluster % 4) >= 2
                if useImbalance and hasPOC and pocBias != 0
                    isSupport := pocBias == 1

                bool isFortress = score >= fortressLevel
                // one saturated hue per side; STRENGTH drives intensity (opacity) monotonically,
                // so stronger = darker/bolder and weaker = lighter. Fortress keeps width + ★ + full opacity.
                color baseColor = isSupport ? colSupEff : colResEff

                // v5 — LAYER CLASS: a cluster is "core" if any FIXED anchor-TF vote backs it (tf ids 1..5,
                //      bits >= 1); it is "chart-TF local" only if its sole source is the chart TF (tf id 0,
                //      bit 0).  We only visually separate the two when the local overlay is blended over the
                //      core (otherwise every level is core and there is nothing to contrast).
                int  tfsCls        = array.get(clusterTFSets, i)
                bool hasChartVote  = tfsCls % 2 == 1
                bool hasAnchorVote = int(math.floor(tfsCls / 2.0)) > 0
                bool distinguishLayers = useMtfCore and useLocalLayer
                bool isLocalOnly = distinguishLayers and hasChartVote and not hasAnchorVote

                bool doDraw = i < renderCount
                if doDraw and minSepPx > 0 and array.size(drawnCenters) > 0
                    for dci = 0 to array.size(drawnCenters) - 1
                        if math.abs(drawPx - array.get(drawnCenters, dci)) < minSepPx
                            doDraw := false
                            break

                if doDraw
                    // strength = bright core + soft double-halo glow; halo opacity scales with score
                    // colour intensity scales with strength — conviction 0..1 across score 3..10,
                    // applied to the core line, the halo fill and the label text/background alike
                    float conv    = math.min(1.0, math.max(0.0, (score - 3.0) / 7.0))
                    int   coreW   = isFortress ? 3 : score >= 7.0 ? 2 : 1
                    int   coreT   = isFortress ? 0 : int(math.round((1.0 - conv) * 55.0))   // strong = solid/dark, weak = faint/light
                    int   glowT1  = int(math.round(92.0 - conv * 30.0))                     // inner halo bolder for stronger
                    int   glowT2  = math.min(97, glowT1 + 12)                               // outer halo fainter
                    // regime sets fragility: Range -> solid (holds), Trend -> dashed (breaks)
                    string lstyle = regPinning ? line.style_solid : regTrending ? line.style_dashed : line.style_solid
                    color  cRGB   = baseColor

                    // v5 — chart-TF LOCAL levels recede so the fixed anchor-TF CORE map reads as primary:
                    //   local = dotted, hairline, no glow, more transparent.  Core keeps solid/dashed + glow.
                    bool drawGlow = useGlow and not isLocalOnly
                    if isLocalOnly
                        lstyle := line.style_dotted
                        coreW  := 1
                        coreT  := math.min(78, coreT + 24)

                    if drawGlow
                        line gl2 = line.new(lineLeft, drawPx, lineRight, drawPx,
                             color=color.new(cRGB, glowT2), width=coreW + 5, style=line.style_solid)
                        array.push(srLines, gl2)
                        line gl1 = line.new(lineLeft, drawPx, lineRight, drawPx,
                             color=color.new(cRGB, glowT1), width=coreW + 3, style=line.style_solid)
                        array.push(srLines, gl1)
                    line cln = line.new(lineLeft, drawPx, lineRight, drawPx,
                         color=color.new(cRGB, coreT), width=coreW, style=lstyle)
                    array.push(srLines, cln)
                    array.push(drawnCenters, drawPx)
                    totalRenderedZones += 1
                    if isFortress
                        fortressZonesCount += 1

                    if showStrengthLabel
                        string dirArrow = isSupport ? "▲" : "▼"
                        string dirWord  = isSupport ? "Support" : "Resistance"
                        string strWord  = f_strengthWord(score)
                        // v5 — tag the layer: chart-TF LOCAL levels get "· loc"; fixed anchor-TF CORE levels
                        //      get "· NTF" = how many fixed anchor TFs back this level (its cross-TF confluence).
                        string mtfTag = ""
                        if distinguishLayers and isLocalOnly
                            mtfTag := "  · loc"
                        else if useMtfCore
                            int tfcL = 0
                            int tfsTmpL = int(math.floor(array.get(clusterTFSets, i) / 2.0))   // drop bit 0 (chart TF); count anchor bits only
                            for biL = 0 to 4
                                if tfsTmpL % 2 == 1
                                    tfcL += 1
                                tfsTmpL := int(math.floor(tfsTmpL / 2.0))
                            mtfTag := "  · " + str.tostring(tfcL) + "TF"
                        string layerMark = isLocalOnly ? "◦ " : ""
                        string labelTxt = layerMark + dirArrow + " " + dirWord + " · " + strWord + "  (" + str.tostring(score, "#.#") + ")" + mtfTag
                        int   lblBgT = int(math.round(42.0 - conv * 34.0))     // strong label = bold/dark (8), weak = light (42)
                        int   lblTxT = int(math.round((1.0 - conv) * 45.0))    // strong text opaque, weak text lighter
                        if isLocalOnly                                          // local labels recede too
                            lblBgT := math.min(72, lblBgT + 24)
                            lblTxT := math.min(58, lblTxT + 18)
                        label lb = label.new(lineRight, drawPx, labelTxt,
                             style=label.style_label_left,
                             color=color.new(cRGB, lblBgT),
                             textcolor=color.new(f_textOn(cRGB), lblTxT),
                             size=labelTxtSize)
                        array.push(srLabels, lb)

                if i == 0
                    topZonePrice      := drawPx
                    topZoneScore      := score
                    topZoneIsSupport  := isSupport
                    topZoneIsFortress := isFortress
                    topZoneMethodCnt  := cnt
                    topZoneUpper      := upper
                    topZoneLower      := lower

                if exportSlot < 3
                    int sDir = isSupport  ? 1 : -1
                    int sFt  = isFortress ? 1 :  0
                    if exportSlot == 0
                        exp_zone1_px  := drawPx
                        exp_zone1_sc  := score
                        exp_zone1_dir := sDir
                        exp_zone1_ft  := sFt
                    if exportSlot == 1
                        exp_zone2_px  := drawPx
                        exp_zone2_sc  := score
                        exp_zone2_dir := sDir
                        exp_zone2_ft  := sFt
                    if exportSlot == 2
                        exp_zone3_px  := drawPx
                        exp_zone3_sc  := score
                        exp_zone3_dir := sDir
                        exp_zone3_ft  := sFt
                    exportSlot += 1

                if isSupport
                    if drawPx >= close
                        exp_supportsAbovePrice += 1
                    else
                        exp_supportsBelowPrice += 1
                    if drawPx <= close
                        if na(exp_nearestSupportPx) or drawPx > exp_nearestSupportPx
                            exp_nearestSupportPx := drawPx
                            exp_nearestSupportSc := score
                else
                    if drawPx >= close
                        exp_resistancesAbovePrice += 1
                    else
                        exp_resistancesBelowPrice += 1
                    if drawPx >= close
                        if na(exp_nearestResistancePx) or drawPx < exp_nearestResistancePx
                            exp_nearestResistancePx := drawPx
                            exp_nearestResistanceSc := score

    if not na(topZonePrice) and atrVal > 0
        exp_topZoneDistATR := (close - topZonePrice) / atrVal
        exp_topZoneDistPct := close != 0 ? (close - topZonePrice) / close * 100.0 : na

    if not na(exp_nearestSupportPx) and atrVal > 0
        exp_distToNearestSupATR := (close - exp_nearestSupportPx) / atrVal
    if not na(exp_nearestResistancePx) and atrVal > 0
        exp_distToNearestResATR := (exp_nearestResistancePx - close) / atrVal

    if array.size(anchorBars) > 0
        int aBar = array.get(anchorBars, 0)
        exp_lastAnchorHigh := array.get(anchorHigh, 0)
        exp_lastAnchorLow  := array.get(anchorLow,  0)
        exp_lastAnchorAge  := bar_index - aBar

    exp_absorptionCount := array.size(absBars)

    exp_nakedPocCount := array.size(nakedPOCPrices)
    if array.size(nakedPOCPrices) > 0
        float bestDist = na
        float bestPx   = na
        for npI = 0 to array.size(nakedPOCPrices) - 1
            float pxN = array.get(nakedPOCPrices, npI)
            float d   = math.abs(close - pxN)
            if na(bestDist) or d < bestDist
                bestDist := d
                bestPx   := pxN
        exp_nakedPocNearestPx := bestPx
        exp_nakedPocNearestDistATR := atrVal > 0 ? bestDist / atrVal : na

// ========================================================================
// 17b - MAGNET MARKER (nearest naked POC)
// ========================================================================
var label magLabel = na
if barstate.islast
    if not na(magLabel)
        label.delete(magLabel)
    if showMagnet and not na(exp_nakedPocNearestPx)
        string magTxt = "◎ Magnet (untested)" + (na(exp_nakedPocNearestDistATR) ? "" : "  " + str.tostring(exp_nakedPocNearestDistATR, "#.#") + "a")
        magLabel := label.new(bar_index + zoneExtend, exp_nakedPocNearestPx, magTxt,
             style=label.style_label_left, color=colMagnet, textcolor=f_textOn(colMagnet), size=labelTxtSize)

// ========================================================================
// 18 - CALIBRATION TRACKER
// ========================================================================
f_wilson(int hits, int total) =>
    float lo = na
    float hi = na
    if total >= 5
        float p   = hits / float(total)
        float z   = 1.96
        float den = 1.0 + z * z / total
        float c   = (p + z * z / (2.0 * total)) / den
        float h   = z * math.sqrt(p * (1.0 - p) / total + z * z / (4.0 * total * total)) / den
        lo := math.max(0.0, c - h)
        hi := math.min(1.0, c + h)
    [lo, hi]

if calEnable and barstate.isconfirmed
    if not na(topZonePrice) and not na(topZoneScore)
        int bin = f_calBin(topZoneScore)
        if bin >= 0
            bool dup = false
            if array.size(pend_bar) > 0
                for di = 0 to array.size(pend_bar) - 1
                    int    pb = array.get(pend_bar,   di)
                    float  pp = array.get(pend_price, di)
                    if bar_index - pb < calHorizon and math.abs(pp - topZonePrice) < atrVal * 0.5
                        dup := true
                        break
            if not dup
                array.push(pend_bar,   bar_index)
                array.push(pend_price, topZonePrice)
                array.push(pend_atr,   atrVal)
                array.push(pend_dir,   topZoneIsSupport ? 1 : -1)
                array.push(pend_bin,   bin)
                array.push(pend_t0,    time)

    // v4.1 — regime-matched base rate: unconditional forward move, resolved at the horizon
    if not na(atrVal) and atrVal > 0.0
        array.push(bq_bar, bar_index)
        array.push(bq_px,  close)
        array.push(bq_atr, atrVal)
    if array.size(bq_bar) > 0
        int bidx = 0
        while bidx < array.size(bq_bar)
            if bar_index - array.get(bq_bar, bidx) >= calHorizon
                float be = array.get(bq_px,  bidx)
                float ba = array.get(bq_atr, bidx)
                baseN  += 1
                baseUp += (close - be) >= calMoveATR * ba ? 1 : 0
                baseDn += (be - close) >= calMoveATR * ba ? 1 : 0
                array.remove(bq_bar, bidx)
                array.remove(bq_px,  bidx)
                array.remove(bq_atr, bidx)
            else
                bidx := bidx + 1
        while array.size(bq_bar) > 400
            array.shift(bq_bar)
            array.shift(bq_px)
            array.shift(bq_atr)

    // v4.1 — triple-barrier respect (reject-first = held vs break-first = broken), firstHit ties, OOS split
    if array.size(pend_bar) > 0
        int idx = 0
        while idx < array.size(pend_bar)
            int   pb = array.get(pend_bar,   idx)
            float p0 = array.get(pend_price, idx)
            float a0 = array.get(pend_atr,   idx)
            int   dr = array.get(pend_dir,   idx)
            int   bn = array.get(pend_bin,   idx)
            int   t0 = array.get(pend_t0,    idx)
            float rejLvl = dr > 0 ? p0 + calMoveATR * a0 : p0 - calMoveATR * a0
            float brkLvl = dr > 0 ? p0 - calMoveATR * a0 : p0 + calMoveATR * a0
            bool  hitReject = dr > 0 ? high >= rejLvl : low  <= rejLvl
            bool  hitBreak  = dr > 0 ? low  <= brkLvl : high >= brkLvl
            bool  tmOut     = bar_index - pb >= calHorizon
            if hitReject or hitBreak or tmOut
                bool respected = false
                if hitReject and hitBreak and nLtfCal > 0
                    int fh = cal.firstHit(qHi_cal, qLo_cal, brkLvl, rejLvl, dr > 0, true)
                    respected := fh == 1
                else if hitReject
                    respected := true
                else if hitBreak
                    respected := false
                else
                    respected := dr > 0 ? (close - p0) >= calMoveATR * a0 : (p0 - close) >= calMoveATR * a0
                array.set(cal_total, bn, array.get(cal_total, bn) + 1)
                if respected
                    array.set(cal_correct, bn, array.get(cal_correct, bn) + 1)
                int phase = cal.phaseOf(t0, isEndT, oosEndT)
                if phase == 1
                    isN += 1.0
                    isW += respected ? 1.0 : 0.0
                else
                    oosN += 1.0
                    oosW += respected ? 1.0 : 0.0
                array.remove(pend_bar,   idx)
                array.remove(pend_price, idx)
                array.remove(pend_atr,   idx)
                array.remove(pend_dir,   idx)
                array.remove(pend_bin,   idx)
                array.remove(pend_t0,    idx)
            else
                idx := idx + 1

    while array.size(pend_bar) > 200
        array.shift(pend_bar)
        array.shift(pend_price)
        array.shift(pend_atr)
        array.shift(pend_dir)
        array.shift(pend_bin)
        array.shift(pend_t0)

int   calTotalAll = array.get(cal_total, 0) + array.get(cal_total, 1) + array.get(cal_total, 2)
int   calHitAll   = array.get(cal_correct, 0) + array.get(cal_correct, 1) + array.get(cal_correct, 2)
float calConfidence = calTotalAll >= respectMinN ? calHitAll * 100.0 / calTotalAll : na

// ========================================================================
// 19 - DATA-HEALTH AGGREGATE
// ========================================================================
bool anchorOK   = array.size(anchorBars) > 0
bool vpOK       = vpBuilt or not useVP
bool htfAnyOK   = (not useHTF1 or htf1Healthy) and (not useHTF2 or htf2Healthy) and (not useHTF3 or htf3Healthy) and (not useHTF4 or htf4Healthy)
bool imbOK      = not useImbalance or imbalanceHealthy or not useVolumeMode

int healthCode = not useVolumeMode ? 2 :
     (not anchorOK or not vpOK or not htfAnyOK or not imbOK) ? 1 : 0

string healthTxt = healthCode == 0 ? "OK - all sources valid" :
                   healthCode == 1 ? "Degraded" : "Critical - no volume"

string healthDetail =
     (useVolumeMode ? "Vol ok "    : "Vol off ")    +
     (anchorOK      ? "Anchor ok " : "Anchor off ") +
     (vpOK          ? "VP ok "     : "VP off ")     +
     (imbOK         ? "Imb ok "    : "Imb off ")    +
     ((not useHTF1 or htf1Healthy) ? "HTF1 ok " : "HTF1 off ") +
     ((not useHTF2 or htf2Healthy) ? "HTF2 ok " : "HTF2 off ") +
     ((not useHTF3 or htf3Healthy) ? "HTF3 ok " : "HTF3 off ") +
     ((not useHTF4 or htf4Healthy) ? "HTF4 ok " : "HTF4 off ") +
     "Regime " + regimeTxt + " (eff " + str.tostring(reg_eff, "#.##") + ", VR " + str.tostring(reg_vr, "#.##") + ") " +
     (na(calConfidence) ? "Conf warming" : "Conf " + str.tostring(math.round(calConfidence)) + "%")

// ========================================================================
// 20 - COMPACT SNAPSHOT PANEL
// ========================================================================
if barstate.islast and showSnapshot
    var table snapTable = table.new(f_snapPos(snapshotPos), 2, 9,
         bgcolor=snapPanelBg,
         border_color=snapBorder,
         border_width=1,
         frame_color=snapFrame,
         frame_width=1)
    table.clear(snapTable, 0, 0, 1, 8)

    color rowBg = snapRowBg
    color labTx = uiTextDim

    // Row 0 - Top zone
    bool topZoneValid = not na(topZonePrice) and not na(topZoneScore)
    string topZoneDir  = topZoneIsSupport ? "▲ Support" : "▼ Resistance"
    string topZoneFort = topZoneIsFortress ? "★ " : ""
    string topZoneTxt = topZoneValid ?
         (topZoneFort + topZoneDir + "  " + str.tostring(topZonePrice, format.mintick) +
          "  (" + str.tostring(topZoneScore, "#.#") + ")") : "-"
    color  topZoneCol = not topZoneValid ? uiTextDim : topZoneIsSupport ? cPos : cNeg
    table.cell(snapTable, 0, 0, "Zone", text_color=labTx, text_size=panelTxtSize, text_formatting=text.format_bold,
         bgcolor=rowBg, text_halign=text.align_left,
         tooltip="Strongest nearby level: star=fortress, support/resistance, price, strength /10.")
    table.cell(snapTable, 1, 0, topZoneTxt, text_color=topZoneCol, text_size=panelTxtSize, text_formatting=text.format_bold,
         bgcolor=rowBg, text_halign=text.align_left)

    // Row 1 - Regime
    string regWord2 = regimeTxt
    color  regCol2 = regTrending ? cWarn : regPinning ? cPos : uiTextDim
    string regTxt = not useRegime ? "off" : regWord2 + "  eff " + str.tostring(reg_eff, "#.##")
    table.cell(snapTable, 0, 1, "Regime", text_color=labTx, text_size=panelTxtSize, text_formatting=text.format_bold,
         bgcolor=rowBg, text_halign=text.align_left,
         tooltip="Trend = levels fragile (dashed lines). Range = levels hold (solid lines). From path efficiency + variance ratio.")
    table.cell(snapTable, 1, 1, regTxt, text_color=regCol2, text_size=panelTxtSize, text_formatting=text.format_bold,
         bgcolor=rowBg, text_halign=text.align_left)

    // Row 2 - Bias
    bool biasValid = useImbalance and not na(pocPrice) and imbalanceHealthy
    bool biasNoVol = useImbalance and not useVolumeMode
    string biasState = pocBias == 1 ? "Bull" : pocBias == -1 ? "Bear" : "Neutral"
    string biasTxt = biasValid ?
         (biasState + "  " + str.tostring(pocBuyRatio * 100, "#") + "%") :
         biasNoVol ? "n/a" : "-"
    color  biasCol = biasValid ?
         (pocBias == 1 ? cPos : pocBias == -1 ? cNeg : uiTextDim) :
         biasNoVol ? cWarn : uiTextDim
    table.cell(snapTable, 0, 2, "Bias", text_color=labTx, text_size=panelTxtSize, text_formatting=text.format_bold,
         bgcolor=rowBg, text_halign=text.align_left, tooltip="Order-flow bias from the POC buy ratio.")
    table.cell(snapTable, 1, 2, biasTxt, text_color=biasCol, text_size=panelTxtSize, text_formatting=text.format_bold,
         bgcolor=rowBg, text_halign=text.align_left)

    // Row 3 - Nearest support
    string supTxt = (not na(exp_nearestSupportPx) and not na(exp_distToNearestSupATR)) ?
         (str.tostring(exp_nearestSupportPx, format.mintick) + "  " + str.tostring(exp_distToNearestSupATR, "#.#") + "a") : "-"
    color  supCol = na(exp_nearestSupportPx) ? uiTextDim : cInfo
    table.cell(snapTable, 0, 3, "Sup", text_color=labTx, text_size=panelTxtSize, text_formatting=text.format_bold,
         bgcolor=rowBg, text_halign=text.align_left, tooltip="Nearest support below price, distance in ATR.")
    table.cell(snapTable, 1, 3, supTxt, text_color=supCol, text_size=panelTxtSize, text_formatting=text.format_bold,
         bgcolor=rowBg, text_halign=text.align_left)

    // Row 4 - Nearest resistance
    string resTxt = (not na(exp_nearestResistancePx) and not na(exp_distToNearestResATR)) ?
         (str.tostring(exp_nearestResistancePx, format.mintick) + "  " + str.tostring(exp_distToNearestResATR, "#.#") + "a") : "-"
    color  resCol = na(exp_nearestResistancePx) ? uiTextDim : cInfo
    table.cell(snapTable, 0, 4, "Res", text_color=labTx, text_size=panelTxtSize, text_formatting=text.format_bold,
         bgcolor=rowBg, text_halign=text.align_left, tooltip="Nearest resistance above price, distance in ATR.")
    table.cell(snapTable, 1, 4, resTxt, text_color=resCol, text_size=panelTxtSize, text_formatting=text.format_bold,
         bgcolor=rowBg, text_halign=text.align_left)

    // Row 5 - Top-zone distance
    string distTxt = "-"
    if topZoneValid and not na(exp_topZoneDistATR)
        distTxt := str.tostring(exp_topZoneDistATR, "#.#") + "a"
        if not na(exp_topZoneDistPct)
            distTxt := distTxt + "  " + str.tostring(exp_topZoneDistPct, "#.##") + "%"
    color distCol = (topZoneValid and not na(exp_topZoneDistATR)) ? cInfo : uiTextDim
    table.cell(snapTable, 0, 5, "Dist", text_color=labTx, text_size=panelTxtSize, text_formatting=text.format_bold,
         bgcolor=rowBg, text_halign=text.align_left, tooltip="Signed distance from price to the top level (ATR and %).")
    table.cell(snapTable, 1, 5, distTxt, text_color=distCol, text_size=panelTxtSize, text_formatting=text.format_bold,
         bgcolor=rowBg, text_halign=text.align_left)

    // Row 6 - Naked POC magnet
    string npTxt = na(exp_nakedPocNearestPx) ? "none" :
         (str.tostring(exp_nakedPocNearestPx, format.mintick) +
          (na(exp_nakedPocNearestDistATR) ? "" : "  " + str.tostring(exp_nakedPocNearestDistATR, "#.#") + "a") +
          "  x" + str.tostring(exp_nakedPocCount))
    color npCol = na(exp_nakedPocNearestPx) ? uiTextDim : cInfo
    table.cell(snapTable, 0, 6, "nPOC", text_color=labTx, text_size=panelTxtSize, text_formatting=text.format_bold,
         bgcolor=rowBg, text_halign=text.align_left, tooltip="Nearest untested POC (magnet), ATR distance, count tracked.")
    table.cell(snapTable, 1, 6, npTxt, text_color=npCol, text_size=panelTxtSize, text_formatting=text.format_bold,
         bgcolor=rowBg, text_halign=text.align_left)

    // Row 7 - Confidence / regime / health
    string healthShort = healthCode == 0 ? "OK" : healthCode == 1 ? "DGR" : "CRIT"
    string confTxt = na(calConfidence) ? "warming" : str.tostring(math.round(calConfidence)) + "%"
    string regimeTxt7 = str.tostring(totalRenderedZones) + "L  " + str.tostring(fortressZonesCount) + "★  " + confTxt + "  " + healthShort
    color  regimeCol7 = healthCode == 2 ? cNeg : healthCode == 1 ? cWarn :
                       (not na(calConfidence) and calConfidence >= 55) ? cPos : uiText
    table.cell(snapTable, 0, 7, "Conf", text_color=labTx, text_size=panelTxtSize, text_formatting=text.format_bold,
         bgcolor=rowBg, text_halign=text.align_left, tooltip=healthDetail)
    table.cell(snapTable, 1, 7, regimeTxt7, text_color=regimeCol7, text_size=panelTxtSize, text_formatting=text.format_bold,
         bgcolor=rowBg, text_halign=text.align_left, tooltip=healthDetail)

    // Row 8 - Asset
    table.cell(snapTable, 0, 8, "Asset", text_color=labTx, text_size=panelTxtSize, text_formatting=text.format_bold,
         bgcolor=rowBg, text_halign=text.align_left)
    table.cell(snapTable, 1, 8, assetClassTxt + " " + syminfo.ticker, text_color=cInfo,
         text_size=panelTxtSize, text_formatting=text.format_bold, bgcolor=rowBg, text_halign=text.align_left)

// ========================================================================
// 20b - HOW-TO-READ LEGEND (plain English key)
// ========================================================================
if barstate.islast and showLegend
    bool legShowLocal = useMtfCore and useLocalLayer
    int  legRows = legShowLocal ? 8 : 7
    var table legendTable = table.new(f_snapPos(legendPos), 2, legRows,
         bgcolor=snapPanelBg, border_color=snapBorder, border_width=1,
         frame_color=snapFrame, frame_width=1)
    table.clear(legendTable, 0, 0, 1, legRows - 1)

    table.cell(legendTable, 0, 0, useMtfCore ? "How to read · MTF core" : "How to read", text_color=uiText, text_size=panelTxtSize, text_formatting=text.format_bold,
         bgcolor=snapRowBg, text_halign=text.align_left,
         tooltip=useMtfCore ? "Coherent MTF core is ON: these levels are built from a fixed anchor-TF ladder, so the same lines and strengths appear on every chart timeframe. The chart TF only zooms." : "Chart-timeframe engine: levels are re-derived from this chart's own bars, so they differ per timeframe.")
    table.cell(legendTable, 1, 0, "", bgcolor=snapRowBg)
    table.merge_cells(legendTable, 0, 0, 1, 0)

    table.cell(legendTable, 0, 1, "▲ Teal line", text_color=cPos, text_size=panelTxtSize, text_formatting=text.format_bold,
         bgcolor=snapRowBg, text_halign=text.align_left)
    table.cell(legendTable, 1, 1, "Support — price may bounce up", text_color=uiText, text_size=panelTxtSize, text_formatting=text.format_bold,
         bgcolor=snapRowBg, text_halign=text.align_left)

    table.cell(legendTable, 0, 2, "▼ Pink line", text_color=cNeg, text_size=panelTxtSize, text_formatting=text.format_bold,
         bgcolor=snapRowBg, text_halign=text.align_left)
    table.cell(legendTable, 1, 2, "Resistance — price may stall / drop", text_color=uiText, text_size=panelTxtSize, text_formatting=text.format_bold,
         bgcolor=snapRowBg, text_halign=text.align_left)

    table.cell(legendTable, 0, 3, "★ / Very Strong", text_color=cWarn, text_size=panelTxtSize, text_formatting=text.format_bold,
         bgcolor=snapRowBg, text_halign=text.align_left)
    table.cell(legendTable, 1, 3, "Brighter & bolder = more important", text_color=uiText, text_size=panelTxtSize, text_formatting=text.format_bold,
         bgcolor=snapRowBg, text_halign=text.align_left)

    table.cell(legendTable, 0, 4, "Solid / Dashed", text_color=uiTextDim, text_size=panelTxtSize, text_formatting=text.format_bold,
         bgcolor=snapRowBg, text_halign=text.align_left)
    table.cell(legendTable, 1, 4, "Range: tends to hold  /  Trend: may break", text_color=uiText, text_size=panelTxtSize, text_formatting=text.format_bold,
         bgcolor=snapRowBg, text_halign=text.align_left)

    table.cell(legendTable, 0, 5, "◎ Magnet", text_color=cInfo, text_size=panelTxtSize, text_formatting=text.format_bold,
         bgcolor=snapRowBg, text_halign=text.align_left)
    table.cell(legendTable, 1, 5, "Untested level price may be pulled to", text_color=uiText, text_size=panelTxtSize, text_formatting=text.format_bold,
         bgcolor=snapRowBg, text_halign=text.align_left)

    table.cell(legendTable, 0, 6, useMtfCore ? "── glow · N TF" : "MTF core: off", text_color=cInfo, text_size=panelTxtSize, text_formatting=text.format_bold,
         bgcolor=snapRowBg, text_halign=text.align_left)
    table.cell(legendTable, 1, 6, useMtfCore ? "Fixed anchor-TF level — same on every chart TF (N = TFs agreeing)" : "Levels are chart-TF specific (v4.1 engine)", text_color=uiText, text_size=panelTxtSize, text_formatting=text.format_bold,
         bgcolor=snapRowBg, text_halign=text.align_left)

    if legShowLocal
        table.cell(legendTable, 0, 7, "◦ ···· dotted · loc", text_color=uiTextDim, text_size=panelTxtSize, text_formatting=text.format_bold,
             bgcolor=snapRowBg, text_halign=text.align_left)
        table.cell(legendTable, 1, 7, "Chart-TF local level — this timeframe only (overlay)", text_color=uiText, text_size=panelTxtSize, text_formatting=text.format_bold,
             bgcolor=snapRowBg, text_halign=text.align_left)

// ========================================================================
// 21 - OPTIONAL CALIBRATION PANEL
// ========================================================================
if calEnable and calShowPanel and barstate.islast
    var table calTable = table.new(f_snapPos(calPanelPos), 4, 6,
         bgcolor=snapPanelBg, border_color=snapBorder, border_width=1,
         frame_color=snapFrame,
         frame_width=1)
    table.clear(calTable, 0, 0, 3, 5)

    color calHdrBg = snapRowBg
    color calRowBg = snapRowBg
    color calLabTx = uiText
    color calHdrTx = uiTextDim
    color calDimTx = uiTextDim

    table.cell(calTable, 0, 0, "Calibration (past)", text_color=calHdrTx, bgcolor=calHdrBg,
         text_size=panelTxtSize, text_formatting=text.format_bold, text_halign=text.align_left,
         tooltip="Descriptive past data. Logs each qualifying top-level, checks after " + str.tostring(calHorizon) + " bars whether price moved >= " + str.tostring(calMoveATR) + "x ATR as expected. Not a backtest.")
    table.cell(calTable, 1, 0, "N",        text_color=calHdrTx, bgcolor=calHdrBg, text_size=panelTxtSize, text_formatting=text.format_bold, text_halign=text.align_center)
    table.cell(calTable, 2, 0, "Hit rate", text_color=calHdrTx, bgcolor=calHdrBg, text_size=panelTxtSize, text_formatting=text.format_bold, text_halign=text.align_center)
    table.cell(calTable, 3, 0, "95% CI",   text_color=calHdrTx, bgcolor=calHdrBg, text_size=panelTxtSize, text_formatting=text.format_bold, text_halign=text.align_right)

    int   total4   = array.get(cal_total,   0)
    int   hit4     = array.get(cal_correct, 0)
    int   total5   = array.get(cal_total,   1)
    int   hit5     = array.get(cal_correct, 1)
    int   totalFt  = array.get(cal_total,   2)
    int   hitFt    = array.get(cal_correct, 2)
    int   totalAll = total4 + total5 + totalFt
    int   hitAll   = hit4 + hit5 + hitFt

    string[] tierLabels = array.from("4-star", "5-star", "Fortress", "All levels")
    int[]    tierTotals = array.from(total4, total5, totalFt, totalAll)
    int[]    tierHits   = array.from(hit4,   hit5,   hitFt,   hitAll)

    for r = 0 to 3
        int    rT = array.get(tierTotals, r)
        int    rH = array.get(tierHits,   r)
        string rL = array.get(tierLabels, r)
        float  rate_pct = rT > 0 ? rH * 100.0 / rT : na
        [lo, hi] = f_wilson(rH, rT)
        string rateTxt = rT == 0 ? "-" : rT < 5 ? "warming up" : str.tostring(rate_pct, "#.#") + "%"
        string ciTxt   = na(lo) ? "-" : str.tostring(math.round(lo * 100)) + "-" + str.tostring(math.round(hi * 100)) + "%"
        color  rateCol = calDimTx
        if rT >= 5
            if rate_pct >= 60.0
                rateCol := cPos
            else if rate_pct >= 50.0
                rateCol := cWarn
            else
                rateCol := cNeg
        table.cell(calTable, 0, r + 1, rL,                text_color=calLabTx, bgcolor=calRowBg, text_size=panelTxtSize, text_formatting=text.format_bold, text_halign=text.align_left)
        table.cell(calTable, 1, r + 1, str.tostring(rT),  text_color=calLabTx, bgcolor=calRowBg, text_size=panelTxtSize, text_formatting=text.format_bold, text_halign=text.align_center)
        table.cell(calTable, 2, r + 1, rateTxt,           text_color=rateCol,  bgcolor=calRowBg, text_size=panelTxtSize, text_formatting=text.format_bold, text_halign=text.align_center)
        table.cell(calTable, 3, r + 1, ciTxt,             text_color=calLabTx, bgcolor=calRowBg, text_size=panelTxtSize, text_formatting=text.format_bold, text_halign=text.align_right)

    int pendN = array.size(pend_bar)
    int oldestAge = 0
    if pendN > 0
        int firstBar = array.get(pend_bar, 0)
        oldestAge := bar_index - firstBar
    string trackerTxt = "Past data only - no forward guarantee"
    if pendN > 0
        trackerTxt := str.tostring(pendN) + " pending - oldest " + str.tostring(oldestAge) + "b ago"
    table.cell(calTable, 0, 5, trackerTxt, text_color=calDimTx, bgcolor=calHdrBg,
         text_size=panelTxtSize, text_formatting=text.format_bold, text_halign=text.align_left)
    table.cell(calTable, 1, 5, "", bgcolor=calHdrBg)
    table.cell(calTable, 2, 5, "", bgcolor=calHdrBg)
    table.cell(calTable, 3, 5, "", bgcolor=calHdrBg)
    table.merge_cells(calTable, 0, 5, 3, 5)

// ========================================================================
// 22 - ALERTS  (trimmed to S/R-relevant events)
// ========================================================================
float topUpper = topZoneUpper
float topLower = topZoneLower
bool priceInTopZone = not na(topZonePrice) and not na(topUpper) and not na(topLower) and close <= topUpper and close >= topLower
bool priceBrokeTopZone = not na(topZonePrice) and not na(topUpper) and not na(topLower) and ((close > topUpper and close[1] <= topUpper) or (close < topLower and close[1] >= topLower))

bool fortressEntered   = fortressZonesCount > prevFortressCnt
bool fortressLost      = fortressZonesCount < prevFortressCnt
bool biasFlippedBull   = pocBias == 1 and prevPocBias != 1
bool biasFlippedBear   = pocBias == -1 and prevPocBias != -1
bool biasFlippedNeut   = pocBias == 0 and prevPocBias != 0
bool biasFlipped       = biasFlippedBull or biasFlippedBear or biasFlippedNeut
bool healthDegraded    = healthCode > 0 and prevHealthOK
bool healthRestored    = healthCode == 0 and not prevHealthOK
bool nearestSRcross  = (not na(exp_nearestSupportPx) and ta.cross(close, exp_nearestSupportPx)) or
                       (not na(exp_nearestResistancePx) and ta.cross(close, exp_nearestResistancePx))

alertcondition(barstate.isconfirmed and isTier1,
     title="01 - Tier-1 anchor formed",
     message="{{ticker}} {{interval}} - Tier-1 anchor candle")

alertcondition(barstate.isconfirmed and isAbsorption,
     title="02 - Absorption anchor formed",
     message="{{ticker}} {{interval}} - Absorption candle (high vol, narrow range, mid close)")

alertcondition(barstate.isconfirmed and priceInTopZone,
     title="03 - Price entered top level",
     message="{{ticker}} {{interval}} - Price entered top S/R level")

alertcondition(barstate.isconfirmed and priceBrokeTopZone,
     title="04 - Price broke top level",
     message="{{ticker}} {{interval}} - Price broke through top S/R level")

alertcondition(barstate.isconfirmed and topZoneIsFortress and (priceInTopZone or priceBrokeTopZone),
     title="05 - Fortress level interaction",
     message="{{ticker}} {{interval}} - Price interacting with fortress-grade level")

alertcondition(barstate.isconfirmed and biasFlipped,
     title="06 - POC bias flipped",
     message="{{ticker}} {{interval}} - POC imbalance flipped")

alertcondition(barstate.isconfirmed and nearestSRcross,
     title="07 - Nearest S/R crossed",
     message="{{ticker}} {{interval}} - Price crossed nearest support or resistance")

alertcondition(barstate.isconfirmed and (healthDegraded or healthRestored),
     title="08 - Data health changed",
     message="{{ticker}} {{interval}} - Data integrity status changed")

if barstate.isconfirmed
    prevTopScore    := topZoneScore
    prevPocBias     := pocBias
    prevFortressCnt := fortressZonesCount
    prevHealthOK    := healthCode == 0

// ========================================================================
// 23 - EXPORT PLOTS (hidden, consumable via request.security)
// ========================================================================
plot(exp_zone1_px,                "EXP_Zone1_Price",        display=display.data_window)
plot(exp_zone1_sc,                "EXP_Zone1_Score",        display=display.data_window)
plot(exp_zone1_dir,               "EXP_Zone1_Direction",    display=display.data_window)
plot(exp_zone1_ft,                "EXP_Zone1_Fortress",     display=display.data_window)
plot(exp_zone2_px,                "EXP_Zone2_Price",        display=display.data_window)
plot(exp_zone2_sc,                "EXP_Zone2_Score",        display=display.data_window)
plot(exp_zone3_px,                "EXP_Zone3_Price",        display=display.data_window)
plot(exp_zone3_sc,                "EXP_Zone3_Score",        display=display.data_window)

plot(topZonePrice,                "EXP_TopZone_Price",      display=display.data_window)
plot(topZoneScore,                "EXP_TopZone_Score",      display=display.data_window)
plot(topZoneIsSupport  ? 1 : -1,  "EXP_TopZone_Direction",  display=display.data_window)
plot(topZoneIsFortress ? 1 :  0,  "EXP_TopZone_Fortress",   display=display.data_window)
plot(pocBias,                     "EXP_POC_Bias",           display=display.data_window)

plot(exp_nearestSupportPx,        "EXP_NearestSupport_Price",    display=display.data_window)
plot(exp_nearestResistancePx,     "EXP_NearestResistance_Price", display=display.data_window)
plot(exp_distToNearestSupATR,     "EXP_DistToSupport_ATR",       display=display.data_window)
plot(exp_distToNearestResATR,     "EXP_DistToResistance_ATR",    display=display.data_window)

plot(fortressZonesCount,          "EXP_Fortress_Count",     display=display.data_window)
plot(regTrending ? 1 : regPinning ? -1 : 0, "EXP_Regime",  display=display.data_window)
plot(na(calConfidence) ? na : calConfidence, "EXP_Confidence_Pct", display=display.data_window)
float respectOOS = oosN > 0.0 ? oosW / oosN * 100.0 : na
float respectIS  = isN  > 0.0 ? isW  / isN  * 100.0 : na
plot(na(respectOOS) ? na : respectOOS, "EXP_Respect_OOS_Pct", display=display.data_window)
plot((na(respectIS) or na(respectOOS)) ? na : respectIS - respectOOS, "EXP_Respect_Degrade", display=display.data_window)
plot(healthCode,                  "EXP_Data_Health_Code",   display=display.data_window)

// ======================================================================================
//   End - Confluence S/R Engine v5 (Coherent MTF Core)
// ======================================================================================
````
