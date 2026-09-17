<!-- tradingview-pine-id: PUB;589d7fa2c3d24baeaadea28328685f72 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# KAMA H — TheurgyLabs

Source: https://www.tradingview.com/script/SHjQ67kE-KAMA-H/

## Description

KAMA H is the companion pane for KAMA Regime. It carries the identical decision logic as the overlay version and re-draws it as an oscillator, so you can see what the engine sees: how far price has stretched from its adaptive anchor, and exactly where the signal thresholds sit.

The main histogram is the distance between price and the adaptive average, measured in units of typical bar range: gold above the line, blue below, brighter while the stretch is expanding and dimmer while it contracts. A smoothed signal line rides on top. Dotted lines mark the dead zone and the two learned stretch bands in the same distance units, so a signal is always visible as the histogram reaching a line. An efficiency shading along the bottom shows when the tape is traveling cleanly versus chopping, and a small status card summarizes the current regime, distance, efficiency, band position, and momentum at a glance.

To use it as intended, load it in a pane beneath KAMA Regime with both left at default settings; the triangles in the pane will line up bar for bar with the markers on the price chart. If you change a setting on one, make the same change on the other and they stay in step. On its own, the pane also works as a general stretched-or-not oscillator for any symbol.

All the overlay's optional filters are present here with the same defaults, and every internal reading is exported to the data window for anyone who wants to study the components. Background regime tinting is available in settings and ships off.

Research and educational use only; not financial advice. No prediction is made or implied.

---

## Source Code

````pine
//@version=6
indicator("KAMA H — TheurgyLabs", shorttitle="KAMA H", overlay=false, max_bars_back=500)

// BUILD KAMA H 3.31 - Aug 24 2026: regime background shading now has a
//   toggle, DEFAULT OFF (owner's word) - it was unconditional before.
//   PAIR CATCH-UP in the same stroke: Enable Pain Gate default flips to
//   OFF, matching the overlay's committed 3.3 ruling - the pair had
//   drifted (overlay off, H on), which would have broken the
//   defaults-beside-defaults acceptance. Both files now stamp 3.31 and
//   move as one number again. Display and defaults only; chain untouched.
// BUILD KAMA H 3.2 - Aug 23 2026: THE PANE COMPANION, RE-SPLICED AND
//   RE-SYNCED (owner's word: "update and sync kama H"). CONSTRUCTION: this
//   file IS KAMA 3.2 transformed - the entire chain (inputs at the baked
//   committed defaults, the v3 signal-path repairs, pain gate, DMFI,
//   filters, throttles, the full ledger) is byte-identical by construction;
//   only the display layer and the export prefix differ. The old H (232
//   lines, pre-v3 chain, pre-tune defaults, no pain gate, no LL/HH) is
//   fully superseded - its markers could never match v3.2; these must.
//   ITS DISPLAY LANGUAGE IS KEPT: distance histogram (gold above, blue
//   below, bright while expanding), signal line, dead-zone and band lines
//   in distance units, ER area, regime tint, the 2-column status card
//   (now with the stamp row). SWEPT AS DEAD IN H: the fleet perf table,
//   the monitor table, and the 3.1 board-metrics accumulators that fed
//   them - display-side only, nothing read them here (the Trident H
//   precedent). EXPORT LAW: every column re-prefixed KH - wire is
//   KH Signal, money block KH: - zero collisions beside the overlay
//   (the Opus48MAX lesson). STAMP: 3.2 SHARED with the overlay, the
//   pair as one number. ACCEPTANCE: beside KAMA 3.2 at identical
//   settings - KH Signal equals SQS Signal on every bar, the pane
//   triangles line up with the overlay's, both stamps read 3.2.
// BUILD KAMA 3.2 - Aug 23 2026: THE COMMITTED CONFIG, BAKED (owner's word:
//   "Wire in the defaults as shown and bank the run"). Twelve defaults move
//   to the settings that shot the banked 11.68 leg, so 3.2 AT ALL-DEFAULTS
//   REPRODUCES THE BANKED ENGINE. Old -> new: BuySep 1.5->1.0 ATR; band
//   multipliers 2.0->1.6 both sides; sell-throttle scale 1.0->1.5; regime
//   confirm 3->5 bars; ER buy filter ON->OFF; DMFI sizing ON->OFF; DMFI
//   gate ON->OFF; cascade boost ON->OFF; wick boost ON->OFF; LL filter
//   OFF->ON; geometric sizing ON->OFF. THE SHAPE OF THE TUNE: every sizing
//   multiplier is stripped - with geo, DMFI, cascade and wick all off, every
//   buy is a flat $100, the fleet replay unit, so the engine's own book and
//   the ruler's replay finally speak the same sizing language. Signal-path
//   LOGIC untouched; only input defaults and the stamp moved. The banked
//   rows carry build 3.1 (the files' own echo - content governs); this 3.2
//   is that config made factory.
// BUILD KAMA 3.1 - Aug 23 2026: FLEET PERF TABLE PORT (owner's word, Amnion
//   0.29 canonical). Display only, SIGNAL PATH BYTE-UNTOUCHED. The old
//   performance table is replaced by the fleet standard: AvgDD (typical hole)
//   replaces MaxDD in row 2 - MaxDD stays exported untouched; row 10 appended:
//   Speed %/yr (realized / peakCost / years since first buy) and Pain%
//   (painUsd / peakCost). Display-side accumulators added for the table only
//   (pain, underwater share, avg drawdown, first-buy clock) - nothing reads
//   them back and no rescore follows. GRADE CUTS REFRESHED by the rule the
//   0.29 block itself documents (quintiles of all banked half-cell ratios):
//   master f38eaa5e, 976 cells, Aug 23 2026 -> A 17.54 / B 11.55 / C 8.08 /
//   D 5.15 (were 17.17/11.37/8.02/5.16 on the 880-cell Aug 2 master). One
//   export APPENDED LAST: plain BUILD - the stamp this source never carried,
//   making it shoot-ready. THE CLASSIFICATION STANDS: KAMA's next shoot is a
//   NEW-BUILD shoot (v3 repaired the signal path); the banked "-" halves
//   remain the record of the pre-repair engine, and its two standing cell
//   crowns belong to that ghost.
string V_TAG   = "3.31"
float  V_BUILD = str.tonumber(V_TAG)

// Layer 1: KAMA adaptive midline + dead zone regime + depth/deceleration signals.
// Signal: KAMA distance crosses signal line from depth extreme in correct regime.
// "KAMA finds the mean, depth says it's worth entering, deceleration says now."
//
// v3 (un-retire candidate): the three retirement bugs are already fixed in this file —
//   exact sold-cost (sellQty×avgEntry, not a ratio estimate), cycBuyLots reset on cycle
//   close, and the sellCapOK cap removed (an antipattern for %-of-remaining sells, where
//   cycSellLots is not 1:1 with cycBuyLots). Repaired here: the double/inconsistent MaxDD
//   (realized-only update removed; the full-equity track is now the single source) plus a
//   MaxDD audit (DDopn vs DDcls). RE-RUN on TradingView before trusting any grid number —
//   the F grades are stale, assigned at retirement, not computed from this version.

// ─── INPUTS ─────────────────────────────────────────────────────
string G_KAMA = "KAMA"
i_kamaSrc  = input.source(close, "Source",             group=G_KAMA)
i_erLen    = input.int(10,      "ER Length",           group=G_KAMA, minval=2, maxval=50)
i_erSmooth = input.int(1,       "ER Smoothing",        group=G_KAMA, minval=1, maxval=10, tooltip="EMA on raw ER. 1 = off.")
i_kamaFast = input.int(2,       "Fast Period",         group=G_KAMA, minval=2, maxval=10)
i_kamaSlow = input.int(30,      "Slow Period",         group=G_KAMA, minval=10, maxval=100)
i_dzMult   = input.float(0.3,   "Dead Zone ATR Mult",  group=G_KAMA, minval=0.05, maxval=2.0, step=0.05)
i_atrLen   = input.int(14,      "ATR Length",          group=G_KAMA)

string G_SIG = "Signal"
i_buyThrotOn = input.bool(true, "Buy ATR Throttle",   group=G_SIG, tooltip="Toggle for A/B testing.")
i_buySep     = input.float(1.0, "Buy ATR Separation", group=G_SIG, minval=0.5, maxval=5.0, step=0.5)
i_sigLen     = input.int(3,     "Signal MA Length",    group=G_SIG, minval=2, maxval=10, tooltip="SMA on KAMA distance for companion histogram. Not used in signal trigger.")

string G_BAND = "ER-Scaled Bands"
i_bandMult     = input.float(1.6,  "Buy Band Multiplier",  group=G_BAND, minval=0.5, maxval=5.0, step=0.1, tooltip="Buy band depth = dzWidth × multiplier below KAMA. ER scales this automatically.")
i_sellBandMult = input.float(1.6,  "Sell Band Multiplier", group=G_BAND, minval=0.5, maxval=5.0, step=0.1)
i_learnWeight  = input.float(0.5,  "Learn Weight",         group=G_BAND, minval=0.0, maxval=1.0, step=0.1, tooltip="0 = pure ER-scaled. 0.5 = equal blend. 1.0 = pure penetration-learned.")
i_penSamples   = input.int(100,    "Penetration Samples",  group=G_BAND, minval=20, maxval=500)
i_minSamples   = input.int(22,     "Min Samples Required", group=G_BAND, minval=5, maxval=50)
i_sensitivity  = input.float(0.8,  "Sensitivity Factor",   group=G_BAND, minval=0.1, maxval=2.0, step=0.1, tooltip="Scales learned penetration depth. Higher = deeper bands = fewer signals.")
i_minMult      = input.float(0.1,  "Min Learned Mult",     group=G_BAND, minval=0.01, maxval=1.0, step=0.05)
i_maxMult      = input.float(1.5,  "Max Learned Mult",     group=G_BAND, minval=0.5, maxval=5.0, step=0.1)
i_showBands    = input.bool(true,  "Show Bands",           group=G_BAND)

string G_SELL = "Sell Throttle"
i_sellThrotOn    = input.bool(true,  "Adaptive Sell Throttle", group=G_SELL, tooltip="Dynamic cooldown scaling with KAMA distance extension. More extended = longer between sells.")
i_sellThrotBase  = input.int(4,      "Base Cooldown (bars)",   group=G_SELL, minval=1, maxval=20)
i_sellThrotScale = input.float(1.5,  "Scale (per ATR)",        group=G_SELL, minval=0.1, maxval=5.0, step=0.1, tooltip="Cooldown multiplier grows by this per 1 ATR of positive KAMA distance.")
i_sellThrotMax   = input.float(10.0, "Max Multiplier",         group=G_SELL, minval=2.0, maxval=20.0, step=1.0)

string G_L2 = "Layer 2 — Environment"
i_confirmBars = input.int(5,       "Regime Confirm Bars",  group=G_L2, minval=1, maxval=10, tooltip="Consecutive bars required to confirm a regime flip. Prevents rapid gold/blue switching.")
i_erFilterOn  = input.bool(false,  "ER Buy Filter",        group=G_L2, tooltip="Block buys when ER is high (trending). Mean-reversion works in choppy environments. Toggle for A/B.")
i_erBuyMax    = input.float(0.5,   "Max ER for Buys",      group=G_L2, minval=0.1, maxval=1.0, step=0.05, tooltip="Buys blocked when ER exceeds this. 0.5 = allow in chop/mixed, block in strong trends.")

string G_PAIN = "Pain Gate"
i_usePainGate = input.bool(false, "Enable Pain Gate",          group=G_PAIN, tooltip="Require capitulation pressure for buys, euphoria for sells. Ported from Pulse.")
i_zOverride   = input.float(3.75, "zScore Override Threshold", group=G_PAIN, minval=1.0, maxval=6.0, step=0.25, tooltip="Extreme z-score bypasses pain gate toggle. Always fires on deep capitulation.")
i_vwapLen     = input.int(24,     "Cost Basis Lookback",       group=G_PAIN, minval=5, maxval=200)
i_shortVwap   = input.int(8,      "Recent Buyers Lookback",    group=G_PAIN, minval=3, maxval=50)
i_normLen     = input.int(100,    "Normalization Window",       group=G_PAIN, minval=20, maxval=500)
i_capThresh   = input.float(1.5,  "Capitulation σ",            group=G_PAIN, minval=0.5, maxval=5.0, step=0.25)
i_euphThresh  = input.float(1.5,  "Euphoria σ",                group=G_PAIN, minval=0.5, maxval=5.0, step=0.25)
i_painWindow  = input.int(4,      "Pain Lookback (bars)",       group=G_PAIN, minval=1, maxval=12)

string G_DMFI = "DMFI Conviction"
i_useDmfi      = input.bool(false, "DMFI Buy Sizing",       group=G_DMFI, tooltip="Scale buy $ by money flow exhaustion. Deep negative DMFI = high conviction = bigger buy. Seven for seven fleet-wide.")
i_mfiLen       = input.int(14,     "MFI Length",             group=G_DMFI, minval=5, maxval=50)
i_mfiSmooth    = input.int(3,      "MFI Smoothing",          group=G_DMFI, minval=1, maxval=10)
i_dmfiLen      = input.int(14,     "DMFI Length",            group=G_DMFI, minval=5, maxval=50)
i_dmfiSmooth   = input.int(5,      "DMFI Smoothing",         group=G_DMFI, minval=1, maxval=15)
i_dmfiCeil     = input.float(30,   "DMFI Ceiling",           group=G_DMFI, minval=10, maxval=50, step=1)
i_dmfiMin      = input.float(1.0,  "Min Multiplier",         group=G_DMFI, minval=0.1, maxval=1.0, step=0.1)
i_dmfiMax      = input.float(2.0,  "Max Multiplier",         group=G_DMFI, minval=1.0, maxval=3.0, step=0.1)
i_dmfiGateOn   = input.bool(false, "DMFI Buy Gate",          group=G_DMFI, tooltip="Block buys when DMFI is positive (money flowing in, not capitulating).")
i_dmfiThresh   = input.float(15,   "Gate Threshold",         group=G_DMFI, minval=0, maxval=50, step=5)

string G_CASC = "Cascade Exhaustion"
i_cascExhOn    = input.bool(false, "Cascade Exhaustion Boost", group=G_CASC, tooltip="CRUCIBLE port. Sizes up buys when exhaustion signals agree. Reward-only.")
i_cascMinScore = input.int(2,      "Min Score (0-4)",          group=G_CASC, minval=1, maxval=4)
i_cascBoostMult = input.float(1.5, "Boost Multiplier",         group=G_CASC, minval=1.0, maxval=3.0, step=0.25)
i_cascVolMult  = input.float(2.0,  "Volume Climax Mult",       group=G_CASC, minval=1.5, maxval=5.0, step=0.5)
i_cascWickRatio = input.float(2.0, "Wick Rejection Ratio",     group=G_CASC, minval=1.0, maxval=5.0, step=0.5)

string G_FILT = "Filters"
i_wickBoostOn  = input.bool(false, "Wick Rejection Boost",  group=G_FILT, tooltip="Boost buy size when band-touch bar shows strong lower wick rejection.")
i_wickBoostMult = input.float(1.2, "Wick Boost Multiplier", group=G_FILT, minval=1.0, maxval=2.0, step=0.05)
i_wickThresh   = input.float(1.5,  "Wick Score Threshold",  group=G_FILT, minval=0.5, maxval=5.0, step=0.5)
i_llOn         = input.bool(true,  "LL Filter (Buy)",       group=G_FILT, tooltip="Require new lower low since last buy. Works on structural systems. Default OFF — A/B test.")
i_hhOn         = input.bool(true,  "HH Filter (Sell)",      group=G_FILT, tooltip="Require new higher high since last sell. Universally positive.")

string G_POS = "Layer 3 — Position"
i_mode       = input.string("Accumulate", "Mode", group=G_POS, options=["Accumulate","All-in/All-out"], tooltip="Accumulate: partial buys/sells, multiple entries per cycle. All-in/All-out: single entry, full exit.")
i_buyBase    = input.float(100,  "Buy Base $",       group=G_POS, minval=10, maxval=1000, step=10)
i_sellPct    = input.float(25,   "Sell %",           group=G_POS, minval=5, maxval=100, step=5, tooltip="% of remaining position to sell. 100 = full exit (forced in All-in/All-out mode).")
i_geoOn      = input.bool(false, "Geometric Sizing", group=G_POS, tooltip="Scale buys geometrically. Only in Accumulate mode.")
i_geoMult    = input.float(1.5,  "Geo Multiplier",   group=G_POS, minval=1.0, maxval=3.0, step=0.1)
i_maxBuys    = input.int(16,     "Max Buys/Cycle",   group=G_POS, minval=1, maxval=50, tooltip="Cap on buys per cycle. Only in Accumulate mode.")

string G_DISP = "Display"
i_showER   = input.bool(true,  "Show ER Area",     group=G_DISP)
i_showDZ   = input.bool(true,  "Show DZ Lines",    group=G_DISP)
i_showTbl  = input.bool(true,  "Show Table",       group=G_DISP)
i_showFill = input.bool(false, "Show Regime Fill", group=G_DISP)
i_tblPos   = input.string("Bottom Right", "Table Position", group=G_DISP, options=["Top Left","Top Right","Bottom Left","Bottom Right"])

// ─── KAMA COMPUTATION ───────────────────────────────────────────
float atr     = ta.atr(i_atrLen)
float atrSafe = math.max(atr, syminfo.mintick)

// Efficiency Ratio
float erNum = math.abs(i_kamaSrc - i_kamaSrc[i_erLen])
float erDen = math.sum(math.abs(i_kamaSrc - i_kamaSrc[1]), i_erLen)
float erRaw = erDen != 0 ? erNum / erDen : 0.0
float er    = i_erSmooth > 1 ? ta.ema(erRaw, i_erSmooth) : erRaw

// Adaptive smoothing constant
float fastSC = 2.0 / (i_kamaFast + 1.0)
float slowSC = 2.0 / (i_kamaSlow + 1.0)
float sc     = math.pow(er * (fastSC - slowSC) + slowSC, 2)

// KAMA line
var float kama = na
kama := na(kama) ? i_kamaSrc : kama + sc * (i_kamaSrc - kama)
float kamaAnchored = kama[1]

// ─── DEAD ZONE REGIME (with confirmation buffer) ────────────────
float dzWidth = atr * i_dzMult * (2.0 - er)
float dzUpper = kamaAnchored + dzWidth
float dzLower = kamaAnchored - dzWidth

// Raw regime (instant, used for visual reference)
bool rawBull = close > dzUpper
bool rawBear = close < dzLower

// Confirmed regime (sticky, requires N consecutive bars to flip)
var int bullBars = 0
var int bearBars = 0
var bool confirmedBull = false
var bool confirmedBear = false

bullBars := rawBull ? bullBars + 1 : 0
bearBars := rawBear ? bearBars + 1 : 0

if bullBars >= i_confirmBars
    confirmedBull := true
    confirmedBear := false
if bearBars >= i_confirmBars
    confirmedBear := true
    confirmedBull := false

bool bull = confirmedBull
bool bear = confirmedBear
bool chop = not bull and not bear

// ─── KAMA DISTANCE (for companion + table) ──────────────────────
float kamaDist = (close - kamaAnchored) / atrSafe
float sigLine  = ta.sma(kamaDist, i_sigLen)

// ─── PAIN GATE — RealPnL z-score (ported from Pulse) ────────────
var float cumPV = 0.0
var float cumV  = 0.0
cumPV += hlc3 * volume
cumV  += volume

f_rollingVwap(int length) =>
    float windowPV = cumPV - nz(cumPV[length])
    float windowV  = cumV  - nz(cumV[length])
    windowV > 0 ? windowPV / windowV : hlc3

float costBasis   = f_rollingVwap(i_vwapLen) * 0.4 + f_rollingVwap(i_shortVwap) * 0.6
float plMargin    = costBasis != 0 ? (close - costBasis) / costBasis * 100.0 : 0.0
float volSma      = ta.sma(volume, 20)
float rawPressure = plMargin * (volSma > 0 ? volume / volSma : 1.0)
float pressSma    = ta.sma(rawPressure, i_normLen)
float pressStd    = ta.stdev(rawPressure, i_normLen)
float pressZ      = pressStd > 0 ? (rawPressure - pressSma) / pressStd : 0.0

bool capRecent  = ta.lowest(pressZ,  i_painWindow) <= -i_capThresh
bool euphRecent = ta.highest(pressZ, i_painWindow) >=  i_euphThresh

bool zBuyOverride  = pressZ <= -i_zOverride
bool zSellOverride = pressZ >=  i_zOverride

bool painBuyOK  = not i_usePainGate or zBuyOverride  or capRecent
bool painSellOK = not i_usePainGate or zSellOverride or euphRecent

// ─── DMFI — Double-Pass Money Flow Conviction ───────────────────
float tp_dmfi = (high + low + close) / 3.0
float rawMF   = tp_dmfi * volume
float posMF   = tp_dmfi > tp_dmfi[1] ? rawMF : 0.0
float negMF   = tp_dmfi < tp_dmfi[1] ? rawMF : 0.0
float posMFSum = math.sum(posMF, i_mfiLen)
float negMFSum = math.sum(negMF, i_mfiLen)
float mfRatio  = negMFSum != 0 ? posMFSum / negMFSum : 100.0
float mfiRaw   = 100.0 - (100.0 / (1.0 + mfRatio))
float mfi      = ta.ema(mfiRaw, i_mfiSmooth)

float mfi2pos  = mfi > mfi[1] ? mfi : 0.0
float mfi2neg  = mfi < mfi[1] ? mfi : 0.0
float mfi2pSum = math.sum(mfi2pos, i_dmfiLen)
float mfi2nSum = math.sum(mfi2neg, i_dmfiLen)
float mfi2Ratio = mfi2nSum != 0 ? mfi2pSum / mfi2nSum : 100.0
float mfiOfMfi  = 100.0 - (100.0 / (1.0 + mfi2Ratio))

float dmfi     = 2.0 * mfi - mfiOfMfi
float dmfiEma  = ta.ema(dmfi, i_dmfiSmooth)
float dmfiOsc  = dmfiEma - 50.0

float dmfiPeak  = math.abs(dmfiOsc)
float dmfiScore = math.min(dmfiPeak / i_dmfiCeil, 1.0) * 100.0
float dmfiMult  = i_useDmfi ? nz(i_dmfiMin + (dmfiScore / 100.0) * (i_dmfiMax - i_dmfiMin), 1.0) : 1.0
bool  dmfiBuyOK = not i_dmfiGateOn or dmfiOsc <= i_dmfiThresh

// ─── CASCADE EXHAUSTION (CRUCIBLE port) ─────────────────────────
float cascVolSma   = ta.sma(volume, 20)
bool  cascVolClimax = volume > cascVolSma * i_cascVolMult
float cascPriceVel = close - close[1]
float cascPriceAcc = cascPriceVel - cascPriceVel[1]
bool  cascPriceBot = cascPriceVel < 0 and cascPriceAcc > 0
float cascAtrSma   = ta.sma(atr, 20)
float cascAtrDelta = atr - atr[1]
bool  cascAtrContr = atr > cascAtrSma * 1.5 and cascAtrDelta < 0
float cascWickLo   = math.min(close, open) - low
float cascBodyAbs  = math.max(math.abs(close - open), syminfo.mintick)
bool  cascWickRej  = cascWickLo > cascBodyAbs * i_cascWickRatio and close > open
int   cascBuyScore = (cascVolClimax ? 1 : 0) + (cascPriceBot ? 1 : 0) + (cascAtrContr ? 1 : 0) + (cascWickRej ? 1 : 0)
float cascBuyBoost = i_cascExhOn and cascBuyScore >= i_cascMinScore ? i_cascBoostMult : 1.0

// ─── WICK REJECTION BOOST ───────────────────────────────────────
float wickLo    = math.min(close, open) - low
float wickBody  = math.max(math.abs(close - open), syminfo.mintick)
float wickScore = wickLo / wickBody
float wickBoost = i_wickBoostOn and wickScore >= i_wickThresh ? i_wickBoostMult : 1.0

// ─── LL/HH FILTERS ─────────────────────────────────────────────
var float lastBuyLow   = na
var float lastSellHigh = na

// Regime flip detection (fires ONCE on transition, not every bar)
bool bullFlip = bull and not bull[1]
bool bearFlip = bear and not bear[1]

// Reset on regime changes — reset each tracker when its OWN phase ends,
// not when it begins. Buys fire in bear, sells fire in bull, so the tracker
// must survive across its active phase to actually gate 2nd+ entries.
if bullFlip
    lastBuyLow   := na     // buy phase (bear) just ended → clear for next time
if bearFlip
    lastSellHigh := na     // sell phase (bull) just ended → clear for next time

// LL/HH conditions (computed here, used in signal engine below)
bool llOK = not i_llOn or na(lastBuyLow) or low < lastBuyLow
bool hhOK = not i_hhOn or na(lastSellHigh) or high > lastSellHigh

// ─── PENETRATION-LEARNING BANDS (anchored to KAMA) ─────────────
// Record wick penetrations below/above KAMA in ATR units
var float[] buyPenetrations  = array.new_float(0)
var float[] sellPenetrations = array.new_float(0)

// Buy side: track how far wicks go below KAMA
if low < kamaAnchored
    float pen = math.abs(low - kamaAnchored) / atrSafe
    if array.size(buyPenetrations) >= i_penSamples
        array.shift(buyPenetrations)
    array.push(buyPenetrations, pen)

// Sell side: track how far wicks go above KAMA
if high > kamaAnchored
    float pen = math.abs(high - kamaAnchored) / atrSafe
    if array.size(sellPenetrations) >= i_penSamples
        array.shift(sellPenetrations)
    array.push(sellPenetrations, pen)

// Learned multipliers (ATR units of depth from KAMA)
var float buyLearnedMult  = 0.5
var float sellLearnedMult = 0.5
if array.size(buyPenetrations) >= i_minSamples
    buyLearnedMult := math.max(i_minMult, math.min(i_maxMult, array.avg(buyPenetrations) * i_sensitivity))
if array.size(sellPenetrations) >= i_minSamples
    sellLearnedMult := math.max(i_minMult, math.min(i_maxMult, array.avg(sellPenetrations) * i_sensitivity))

// ER-scaled band levels (pure ER adaptation)
float erBuyBand  = kamaAnchored - dzWidth * i_bandMult
float erSellBand = kamaAnchored + dzWidth * i_sellBandMult

// Learned band levels (pure penetration history)
float learnedBuyBand  = kamaAnchored - atrSafe * buyLearnedMult
float learnedSellBand = kamaAnchored + atrSafe * sellLearnedMult

// Blended: ER sets theoretical depth, learning refines it
float buyBandLevel  = erBuyBand  * (1.0 - i_learnWeight) + learnedBuyBand  * i_learnWeight
float sellBandLevel = erSellBand * (1.0 - i_learnWeight) + learnedSellBand * i_learnWeight

// ─── SIGNAL ENGINE (band-touch + regime + gates) ────────────────
bool bandBuy  = low  <= buyBandLevel  and bear and barstate.isconfirmed
bool bandSell = high >= sellBandLevel and bull and barstate.isconfirmed

// Buy ATR throttle (toggleable for A/B)
var float lastBuyPrice = na
if bullFlip
    lastBuyPrice := na
bool buyThrotOK = not i_buyThrotOn or na(lastBuyPrice) or math.abs(low - lastBuyPrice) >= atr * i_buySep

// Adaptive sell throttle (scales cooldown with KAMA distance extension)
var int lastSellBar = 0
var int sellCount = 0
if bear
    sellCount := 0
float sellThrotMult = 1.0 + math.min(i_sellThrotMax - 1.0, math.max(0.0, kamaDist) * i_sellThrotScale)
int   sellThrotCD   = math.round(i_sellThrotBase * sellThrotMult)
bool  sellThrotOK   = not i_sellThrotOn or sellCount == 0 or lastSellBar == 0 or (bar_index - lastSellBar) >= sellThrotCD

// ER environment filter (mean-reversion suitability)
bool erBuyOK = not i_erFilterOn or er <= i_erBuyMax

// Combined signals (llOK/hhOK computed in LL/HH section above)
bool buySignal  = bandBuy and buyThrotOK and erBuyOK and painBuyOK and dmfiBuyOK and llOK
bool sellSignal = bandSell and sellThrotOK and painSellOK and hhOK

// Track state for throttles + LL/HH
if buySignal
    lastBuyPrice := close
    lastBuyLow   := math.min(nz(lastBuyLow, low), low)
if sellSignal
    lastSellBar  := bar_index
    sellCount    += 1
    lastSellHigh := math.max(nz(lastSellHigh, high), high)

// ═══════════════════════════════════════════════════════════════════
// POSITION MANAGEMENT + CYCLE ACCOUNTING (Layer 3)
// ═══════════════════════════════════════════════════════════════════
bool isAccum = i_mode == "Accumulate"
float effSellPct = isAccum ? i_sellPct : 100.0

var float posQty     = 0.0
var float posCost    = 0.0
var float avgEntry   = 0.0
var int   cycBuyLots = 0
var int   cycSellLots = 0
var float cycSellRev = 0.0
var float cycSoldCost = 0.0
var int   totalBuys  = 0
var int   totalSells = 0
var int   nCycles    = 0
var float totalReal  = 0.0
var float grossWin   = 0.0
var float grossLoss  = 0.0
var int   wins       = 0
var int   losses     = 0
var float peakEquity = 0.0
var float maxDD      = 0.0
var int   totalSigs  = 0
var float totalCostDeployed = 0.0
var float peakPosCost = 0.0
// ── MaxDD AUDIT tracks (diagnostic only — do NOT feed SQS) ──
var float peakReal    = 0.0
var float maxDDClosed = 0.0
var float maxOpenDD   = 0.0

// Capture cycle-close pulse BEFORE reset (for EDGE sync)
bool cycleClosePulse = bandBuy and cycSellLots > 0

// Cycle close: raw band-touch after sells → book completed cycle
// Uses bandBuy (not buySignal) to prevent LL/gate deadlocks
if bandBuy and cycSellLots > 0
    float cycReal = cycSellRev - cycSoldCost
    totalReal += cycReal
    nCycles   += 1
    if cycReal >= 0
        wins     += 1
        grossWin += cycReal
    else
        losses    += 1
        grossLoss += math.abs(cycReal)
    cycBuyLots  := 0
    cycSellLots := 0
    cycSellRev  := 0.0
    cycSoldCost := 0.0

// Execution flags (for SQS Signal — only emit what actually trades)
bool didBuy  = false
bool didSell = false

// Process buy
if buySignal
    bool capOK = not isAccum or cycBuyLots < i_maxBuys
    if capOK
        float units = isAccum and i_geoOn ? math.pow(i_geoMult, math.min(cycBuyLots, 12)) : 1.0
        float buyCost = i_buyBase * units * dmfiMult * cascBuyBoost * wickBoost
        float buyQty = buyCost / close
        if not isAccum and posQty > 0
            posQty := 0.0
            posCost := 0.0
        posQty   += buyQty
        posCost  += buyCost
        avgEntry := posQty > 0 ? posCost / posQty : close
        cycBuyLots += 1
        totalBuys  += 1
        totalSigs  += 1
        totalCostDeployed += buyCost
        didBuy := true

// Process sell
if sellSignal and posQty > 0
    float sellQty = posQty * (effSellPct / 100.0)
    float sellRev = sellQty * close
    cycSellRev  += sellRev
    cycSoldCost += sellQty * avgEntry
    posQty      -= sellQty
    posCost     := avgEntry * posQty
    cycSellLots += 1
    totalSells  += 1
    totalSigs   += 1
    didSell := true
    if not isAccum
        posQty  := 0.0
        posCost := 0.0
        avgEntry := 0.0

// MaxDD tracking (including unrealized)
peakPosCost := math.max(peakPosCost, posCost)
float totalPnL = totalReal + (posQty > 0 ? posQty * (close - avgEntry) : 0.0)
peakEquity := math.max(peakEquity, totalPnL)
maxDD      := math.max(maxDD, peakEquity - totalPnL)
float unreal = posQty > 0 ? posQty * (close - avgEntry) : 0.0
// MaxDD AUDIT — maxDD above is the FULL equity curve (realized + open MTM).
// maxDDClosed = booked give-back only; maxOpenDD = deepest open-position underwater.
peakReal    := math.max(peakReal, totalReal)
maxDDClosed := math.max(maxDDClosed, peakReal - totalReal)
maxOpenDD   := math.max(maxOpenDD, math.max(0.0, -unreal))

// ═══════════════════════════════════════════════════════════════════
//  FLEET SQS SCORING BLOCK (v1.0)
//  Copy into any fleet indicator. Wire the 7 variables below.
//  Score = ∜( WR × PF × MAR × AnnROI )  — all ratio-based.
//  Anchors are FIXED fleet-wide. Do NOT tune per indicator.
// ═══════════════════════════════════════════════════════════════════

// ---- WIRE THESE (change right side to your indicator's variables) ----
float _sqsReal   = totalReal           // realized PnL ($)
int   _sqsWins   = wins                // winning trades/cycles
int   _sqsLosses = losses              // losing trades/cycles
float _sqsGrossW = grossWin            // sum of winning PnL ($)
float _sqsGrossL = grossLoss           // sum of |losing PnL| ($, positive)
float _sqsDD     = maxDD               // max drawdown ($, POSITIVE number)
float _sqsDeploy = totalCostDeployed   // cumulative capital deployed ($)

// ---- FLEET ANCHORS (same in every indicator — do not change) ----
_WRFULL  = 100.0
_PFFULL  = 20.0
_MARFULL = 30.0
_ARFULL  = 50.0

// ---- ELAPSED TIME (auto-tracked) ----
var int _sqsT0 = na
if _sqsDeploy > 0 and na(_sqsT0)
    _sqsT0 := time
float _sqsYears = not na(_sqsT0) ? math.max(float(time - _sqsT0) / (365.25 * 86400000.0), 0.25) : 1.0

// ---- FOUR AXES ----
float _sqsNt  = float(_sqsWins + _sqsLosses)
float _sqsWR  = _sqsNt > 0 ? (_sqsWins / _sqsNt) * 100.0 : 0.0
float _sqsPF  = _sqsGrossL > 0 ? _sqsGrossW / _sqsGrossL : (_sqsGrossW > 0 ? 999.0 : 0.0)
float _sqsROI = _sqsDeploy > 0 ? (_sqsReal / _sqsDeploy) * 100.0 : 0.0
float _sqsDDp = _sqsDeploy > 0 ? (_sqsDD / _sqsDeploy) * 100.0 : 0.0
float _sqsMAR = _sqsDDp > 0 ? _sqsROI / _sqsDDp : (_sqsROI > 0 ? 999.0 : 0.0)
float _sqsAR  = _sqsROI / _sqsYears

// ---- NORMALIZE + SCORE ----
float _nW = math.max(0.0, math.min(100.0, _sqsWR  / _WRFULL  * 100.0))
float _nP = math.max(0.0, math.min(100.0, _sqsPF  / _PFFULL  * 100.0))
float _nM = math.max(0.0, math.min(100.0, _sqsMAR / _MARFULL * 100.0))
float _nA = math.max(0.0, math.min(100.0, _sqsAR  / _ARFULL  * 100.0))
float sqsScore = (_nW <= 0 or _nP <= 0 or _nM <= 0 or _nA <= 0) ? 0.0 : math.pow(_nW * _nP * _nM * _nA, 0.25)

string sqsGrade = sqsScore >= 90 ? "A+" : sqsScore >= 80 ? "A" : sqsScore >= 70 ? "B+" :
     sqsScore >= 60 ? "B" : sqsScore >= 50 ? "C+" : sqsScore >= 40 ? "C" :
     sqsScore >= 30 ? "D" : "F"
color  sqsClr   = sqsScore >= 70 ? #00FF88 : sqsScore >= 40 ? #FFD700 : #FF4444

// Status line: score appears next to indicator name on chart
plot(sqsScore, "KH SQS", display=display.status_line, color=sqsClr)
// ═══════════════════════════════════════════════════════════════════

// ─── PLOTS ──────────────────────────────────────────────────────
// --- PANE (the old H's display language, on the 3.2 chain) ---
bool expanding = math.abs(kamaDist) > math.abs(kamaDist[1])
color histClr = kamaDist > 0 ? (expanding ? #FFD700 : color.new(#FFD700, 50)) : (expanding ? #1E90FF : color.new(#1E90FF, 50))
plot(kamaDist, "Distance Hist", color=histClr, style=plot.style_columns)
plot(sigLine, "Signal MA", color=#FF00FF, linewidth=1)
hline(0, "Zero", color=color.new(color.white, 70), linestyle=hline.style_solid)
float dzUp = dzWidth / atrSafe
plot(i_showDZ ? dzUp : na,  "DZ Upper", color=color.new(color.white, 70), linewidth=1, style=plot.style_stepline)
plot(i_showDZ ? -dzUp : na, "DZ Lower", color=color.new(color.white, 70), linewidth=1, style=plot.style_stepline)
plot(i_showBands ? (buyBandLevel - kamaAnchored) / atrSafe : na,  "Buy Band",  color=color.new(#00FFFF, 40), linewidth=1, style=plot.style_stepline)
plot(i_showBands ? (sellBandLevel - kamaAnchored) / atrSafe : na, "Sell Band", color=color.new(#FF00FF, 40), linewidth=1, style=plot.style_stepline)
p_er   = plot(i_showER ? er * 2.0 : na, "ER x2", color=color.new(er >= 0.5 ? #00FF88 : er >= 0.3 ? #FFD700 : #FF4444, 60), linewidth=1)
p_zero = plot(i_showER ? 0.0 : na, "ER Base", display=display.none)
fill(p_zero, p_er, color=i_showER ? color.new(er >= 0.5 ? #00FF88 : er >= 0.3 ? #FFD700 : #FF4444, 80) : na, title="ER Fill")
plotshape(buySignal  ? kamaDist : na, "Buy",  shape.triangleup,   location.absolute, #00FFFF, size=size.small)
plotshape(sellSignal ? kamaDist : na, "Sell", shape.triangledown, location.absolute, #FF00FF, size=size.small)
bgcolor(i_showFill ? (bull ? color.new(#FFD700, 92) : bear ? color.new(#1E90FF, 92) : na) : na, title="Regime BG")

// Data window exports
plot(kamaDist, "KH Dist", display=display.data_window)
plot(sigLine,  "KH SigLine",   display=display.data_window)
plot(er,       "KH ER",         display=display.data_window)
plot(didBuy ? 1.0 : didSell ? -1.0 : 0.0, "KH Signal", display=display.data_window)
plot(cycleClosePulse ? 1.0 : 0.0, "KH CycClose", display=display.data_window)

// ─── SQS EXPORTS (hidden, for SQS companion pane) ────────────
plot(totalReal,            "KH:Real",     display=display.data_window)
plot(float(wins),          "KH:Wins",     display=display.data_window)
plot(float(losses),        "KH:Losses",   display=display.data_window)
plot(grossWin,             "KH:GrossW",   display=display.data_window)
plot(grossLoss,            "KH:GrossL",   display=display.data_window)
plot(maxDD,                "KH:MaxDD",    display=display.data_window)
plot(totalCostDeployed,    "KH:Deploy",   display=display.data_window)
plot(float(totalSigs),     "KH:Sigs",     display=display.data_window)
plot(float(nCycles),       "KH:Cycles",   display=display.data_window)
plot(peakPosCost,          "KH:PeakCost", display=display.data_window)
plot(maxDDClosed,          "KH:MaxDDClosed", display=display.data_window)
plot(maxOpenDD,            "KH:MaxOpenDD",   display=display.data_window)
plot(V_BUILD,              "KH BUILD",           display=display.data_window)

// ─── TABLE ──────────────────────────────────────────────────────
f_tblPos(string p) =>
    switch p
        "Top Left"     => position.top_left
        "Top Right"    => position.top_right
        "Bottom Left"  => position.bottom_left
        => position.bottom_right

// --- STATUS CARD (the old H's 2-column card, stamp row added) ---
if i_showTbl and barstate.islast
    string ts = size.small
    color rB = #0d0d1a
    var table tbl = table.new(f_tblPos(i_tblPos), 2, 8, border_width=1, border_color=#333355)
    table.cell(tbl, 0, 0, "KAMA H",  text_color=#00FFFF, bgcolor=#1a1a2e, text_size=ts)
    table.cell(tbl, 1, 0, "v" + V_TAG, text_color=#d0d0d0, bgcolor=#1a1a2e, text_size=ts)
    string regStr = bull ? "GOLD" : bear ? "BLUE" : "CHOP"
    color regClr = bull ? color.new(#FFD700, 30) : bear ? color.new(#1E90FF, 30) : color.new(color.gray, 30)
    table.cell(tbl, 0, 1, "Regime",   text_color=color.white, bgcolor=color.new(color.gray, 50), text_size=ts)
    table.cell(tbl, 1, 1, regStr,     text_color=color.white, bgcolor=regClr, text_size=ts)
    color distClr = kamaDist > 0 ? #FFD700 : kamaDist < 0 ? #1E90FF : color.white
    table.cell(tbl, 0, 2, "Distance", text_color=color.white, bgcolor=rB, text_size=ts)
    table.cell(tbl, 1, 2, str.tostring(kamaDist, "#.##"), text_color=distClr, bgcolor=rB, text_size=ts)
    color sigClr = sigLine > 0 ? #FFD700 : sigLine < 0 ? #1E90FF : color.white
    table.cell(tbl, 0, 3, "Signal",   text_color=color.white, bgcolor=rB, text_size=ts)
    table.cell(tbl, 1, 3, str.tostring(sigLine, "#.##"), text_color=sigClr, bgcolor=rB, text_size=ts)
    color erClr = er >= 0.6 ? #00FF88 : er >= 0.3 ? #FFD700 : #FF4444
    table.cell(tbl, 0, 4, "ER",       text_color=color.white, bgcolor=rB, text_size=ts)
    table.cell(tbl, 1, 4, str.tostring(er, "#.###"), text_color=erClr, bgcolor=rB, text_size=ts)
    string depthStr = low <= buyBandLevel ? "BUY ZONE" : high >= sellBandLevel ? "SELL ZONE" : "BETWEEN"
    color depthClr = low <= buyBandLevel ? #00FFFF : high >= sellBandLevel ? #FF00FF : color.gray
    table.cell(tbl, 0, 5, "Depth",    text_color=color.white, bgcolor=rB, text_size=ts)
    table.cell(tbl, 1, 5, depthStr,   text_color=depthClr, bgcolor=rB, text_size=ts)
    string momStr = expanding ? "EXPAND" : "CONTRACT"
    color momClr = expanding ? (kamaDist > 0 ? #FFD700 : #1E90FF) : color.gray
    table.cell(tbl, 0, 6, "Momentum", text_color=color.white, bgcolor=rB, text_size=ts)
    table.cell(tbl, 1, 6, momStr,     text_color=momClr, bgcolor=rB, text_size=ts)
    table.cell(tbl, 0, 7, "DZ Width", text_color=color.white, bgcolor=rB, text_size=ts)
    table.cell(tbl, 1, 7, str.tostring(dzWidth / atrSafe, "#.##") + " ATR", text_color=color.white, bgcolor=rB, text_size=ts)
````
