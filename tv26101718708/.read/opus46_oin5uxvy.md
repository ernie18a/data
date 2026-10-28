# Opus46

- url: https://www.tradingview.com/script/oiN5uXvY-Opus46/
- type: indicator
- pine_id: PUB;a253d1856c9245bf85bab6b35d5dc843
- version: 5.0

## Description

Opus46 is a mean-reversion band-touch signal engine built on structural price events rather than indicator crossovers. It generates long-only buy and sell signals when price interacts with adaptive penetration-learning bands, filtered through a multi-layer conviction and gating system. Designed for crypto perpetual futures and volatile equities across 1H–4H timeframes.

THE CORE IDEA

Most signal systems trigger on indicator crossovers — moving average crosses, oscillator thresholds, or momentum flips. These events have roughly 10% follow-through. Opus46 instead triggers on structural price events: band touches, percentile extremes, and sigma confluences. These produce dramatically higher follow-through because they represent genuine exhaustion at statistically significant price levels, not noise.

HOW IT WORKS

Opus46 builds two primary structures on the chart. First, a 2-line SMMA ribbon (fast 8, slow 32 on HL2) determines the regime — gold for bullish (price outperforming), blue for bearish (price underperforming). The binary regime has no neutral zone or tangled state, giving clean regime transitions and uninterrupted age accumulation for phase boost and maturity gating. Second, penetration-learning bands extend beyond a Donchian channel using an ATR multiplier that adapts over time by learning from historical wick penetration depths. When price touches the lower band in a bearish regime, a buy signal fires. When price touches the upper band in a bullish regime, a sell signal fires. No crossovers involved.

SIGNAL GATES

Raw band touches pass through multiple gates before becoming actionable signals. The regime maturity gate blocks premature signals in fresh regime flips — the regime must have persisted for at least 8 bars or the spread must have reached 1.5 ATR depth. The pain gate (inspired by Pulse's pressure engine) requires recent capitulation (pressZ below -1.5 sigma within the last 4 bars) before buy signals can fire, ensuring the system waits for genuine seller exhaustion rather than buying into the middle of a move. ATR separation enforces minimum distance between consecutive entries (0.5x ATR for buys, 2.0x for sells). Buy and sell cooldowns enforce minimum bar spacing between consecutive signals. An optional lower-low filter (default OFF) requires each buy to be at a new structural low since the last entry.

Z-SCORE OVERRIDE

When the ATR-normalized spread reaches extreme statistical levels (below -3.0 sigma for buys, above 3.75 sigma for sells), the system fires regardless of band position, regime state, maturity, or pain gate conditions. These asymmetric thresholds reflect a bullish structural bias — it takes a more extreme reading to force a sell than a buy. Z-override signals still respect the lower-low filter, ATR separation, and buy cooldown to prevent wasteful clustering during sustained dislocations. Regime and maturity gates are bypassed because extreme statistical events warrant immediate action regardless of trend state.

CONVICTION SIZING

Opus46 stacks five reward-only conviction multipliers on the buy side. All use a minimum of 1.0x, meaning they boost high-conviction entries without penalizing average ones. DMFI (Double-Pass Money Flow Index, calculated as 2xMFI minus RSI of MFI) scales buys from 1.0x to 2.0x based on flow exhaustion — deeply negative DMFI means sellers are capitulating, warranting larger position sizing. Percentile conviction scales from 1.0x to 1.5x based on how statistically extreme the spread is within a 124-bar window. Phase buy boost increases position size as bearish regimes mature, buying more aggressively late in dips when reversal is more probable. Divergence boost applies 1.5x when bullish pivot divergence (spread or RSI) fired within the last 5 bars. Wick rejection boost applies 1.2x when the buy bar shows strong lower wick rejection (close in upper 40% of bar range).
Position sizing follows geometric scaling (1.5x per tier, 5 steps, up to 24 buys per cycle) with optional cascade decay for risk management.

SELL ENGINE

Sells use percentage-of-remaining sizing (default 20%, max 50%), which structurally prevents over-selling. Phase sell boost increases the sell percentage as bullish regimes mature — conservative early to let positions appreciate, aggressive late to capture gains before reversal. Sell-side DMFI and percentile conviction multipliers exist but default to OFF because they over-sell on trending equities where euphoric conditions persist for weeks.

DIVERGENCE DETECTION

Pivot-based divergence (5 left bars, 3 right bars) detects both spread divergence and RSI divergence independently. Bullish divergences (price making lower lows while the indicator makes higher lows) plot as circles (spread) or diamonds (RSI) below bars. Bearish divergences plot above bars. Either type can trigger the divergence boost window for sizing.

VISUAL FEATURES

The chart displays the 2-line SMMA ribbon with regime-colored fill (gold or blue), sage-green penetration-learning bands, conviction-colored buy triangles (cyan tiers darkening with depth), and magenta sell triangles. An optional volume spike background shades the chart when volume exceeds a configurable multiple of its 20-bar SMA — color, multiplier, and transparency are all adjustable (default purple at 75% transparency, 2x threshold). A full performance table tracks realized PnL, profit factor, win rate, expectancy, average drawdown, ROI, and cycle accounting with next buy/sell target levels. The regime label in the table header updates dynamically between GOLD and BLUE to reflect the current regime state.

DEFAULTS

Buy Base $100, Max Buys 24, Geo Factor 1.5x, Donchian 14, Pain Gate ON, DMFI Buy ON (1.0-2.0x), Percentile Buy ON (1.0-1.5x), Z-Override ON (-3.0 sigma buy / 3.75 sigma sell), Regime Maturity ON (8 bars / 1.5 ATR), LL Filter OFF, Sell Base 20%, Sell Max 50%, Buy ATR Sep 0.5x, Sell ATR Sep 2.0x, Sell Cooldown 6 bars, Buy Cooldown 1 bar, Volume Spike BG ON (2x, purple, 75% transparency). DMFI Sell OFF, Percentile Sell OFF, Tail-Risk Breaker OFF.

## Source Code

````pine
//@version=6
// BUILD 616.9 | 2026-07-12 | DEFAULTS BAKE (zero logic change). Basis Guard
//   default OFF -> ON, Guard Sliver default 12.5 -> 1.0 -- the committed board
//   (Guard ON, sliver 1.0, fleet #4, FQS 65.16, wire clean on all 12) is now the
//   factory state; fresh charts reproduce it with no hand-setting. Tooltip
//   default-state text aligned. BUILD export 616.8 -> 616.9. Byte-identical
//   outside these lines; signal path untouched by construction (and proven on
//   tape: Guard OFF at NFLX 2h 20,561 matched the committed 616.7 row to the cent).
// BUILD 616.8 | 2026-07-12 | BASIS GUARD PORT (ninth chassis, default OFF).
//   Any sell fired while close < pre-sell average entry takes only the Guard
//   Sliver % of position instead of the computed sell percent (phase/div/DMFI
//   scaling included in the override). Sell SIZE only, never timing -- signals
//   byte-identical either way. OFF reproduces the committed 616.7 board exactly.
//   Sliver default 12.5, floor 0.25 (CCIBands lesson). Guard + Sliver exported
//   to the data window for leg fingerprinting. Webhook sell payload now reports
//   the effective (Guard-aware) sell percent. FOUND+FIXED: the BUILD export
//   still stamped 616.4 on the shipped 616.7 -- corrected to 616.8 here.
// BUILD 616.7 | 2026-07-11 | PIPELINE EXPORT SURFACE (no logic changes).
//   Swapped unused SQS:Wins / SQS:Losses exports for SQS:TotPnL (DQSx SurvDD
//   input) and Bars (window stamp) — net-zero output count, per the B+RB
//   RE10140 memory lesson. MaxDD confirmed audited (totalPnl peak-trough);
//   PeakCost tracker confirmed. Enables the full four-score pipeline board.
indicator("Opus46", shorttitle="Opus46", overlay=true, max_labels_count=500, max_lines_count=500)

// ══════════════════════════════════════════════════════════════════════
//  OPUS46 616.6 - Jul 7 2026: HTF pen-band A/B levers. Per-side Buy/Sell HTF Band Mode
//  (Off/Chart/HTF/Either/Both, default Off = 616.5 baseline byte-identical). HTF band is a
//  HOMOGENEOUS extension of the chart Donchian-extreme+learned-mult construction (request.security
//  [1]-offset, gaps_off, lookahead_off; NOT midpoint — avoids RUNIC heterogeneity falsification).
//  Auto x4 / Manual 480, daily+ ND string conversion. For sell-patience A/B (Opus48MAX pattern).
//  OPUS46 616.5 - Jul 7 2026: DQSx-ready + standards. (1) Row-3 AvgDD -> MaxDD (totPnL
//  peak-trough) so the geo-sized MaxDD is table-readable for DQSx. (2) SQS export
//  display.none -> status_line (fleet standard). (3) Banned #0044CC -> #4DA6FF. Signal
//  chain UNCHANGED — committed SQSx Rob 60.88 stands; these are display/export only.
//  OPUS46 — Barebones Rebuild
//  Step 1: SMMA Ribbon (XDEV5 construction)
// ══════════════════════════════════════════════════════════════════════

// ─── FUNCTIONS ──────────────────────────────────────────────────────

smma(float src, int len) =>
    var float val = na
    val := na(val) ? ta.sma(src, len) : (val * (len - 1) + src) / len
    val

// ─── INPUTS ─────────────────────────────────────────────────────────

grpRib      = "═══ SMMA RIBBON ═══"
i_src       = input.source(hl2, "Source", group=grpRib)
i_fastLen   = input.int(8,  "Fast SMMA", minval=2, maxval=50, group=grpRib)
i_slowLen   = input.int(32, "Slow SMMA", minval=5, maxval=80, group=grpRib)

grpBand     = "═══ PENETRATION BANDS ═══"
i_donchLen      = input.int(14,    "Donchian Length",       group=grpBand, minval=5, maxval=100)
i_adaptLookback = input.int(100,   "Penetration Samples",  group=grpBand, minval=20, maxval=500, tooltip="Rolling window of wick penetration depths to learn from.")
i_minSamples    = input.int(22,    "Min Samples Required", group=grpBand, minval=5, maxval=100)
i_defaultMult   = input.float(0.5, "Default ATR Mult",     group=grpBand, minval=0.1, maxval=2.0, step=0.1, tooltip="Used before enough samples are collected.")
i_sensitivity   = input.float(0.8, "Sensitivity Factor",   group=grpBand, minval=0.1, maxval=1.5, step=0.1, tooltip="Scales learned multiplier. Lower = more signals.")
i_minMult       = input.float(0.1, "Min Multiplier",       group=grpBand, minval=0.0, maxval=1.0, step=0.1)
i_maxMult       = input.float(1.5, "Max Multiplier",       group=grpBand, minval=0.5, maxval=3.0, step=0.1)
i_showBands     = input.bool(true, "Show Learned Bands",   group=grpBand)

grpHtf      = "=== HTF PEN BAND (A/B) ==="
i_buyHtfMode  = input.string("Off",  "Buy HTF Band Mode",  options=["Off","Chart","HTF","Either","Both"], group=grpHtf, tooltip="Homogeneous HTF Donchian-extreme gate on buys. Off = 616.5 baseline (byte-identical).")
i_sellHtfMode = input.string("Off",  "Sell HTF Band Mode", options=["Off","Chart","HTF","Either","Both"], group=grpHtf, tooltip="HTF structural sell gate (Opus48MAX sell-patience pattern). Off = baseline.")
i_htfMode     = input.string("Auto", "HTF Timeframe Mode", options=["Auto","Manual"], group=grpHtf)
i_htfMult     = input.int(4,   "HTF Auto Multiplier", minval=2, maxval=12, group=grpHtf)
i_htfMan      = input.int(480, "HTF Manual (min)",    minval=60, maxval=1440, step=60, group=grpHtf)
i_showHtfBands= input.bool(false, "Show HTF Bands",   group=grpHtf)

grpZOver    = "═══ Z-SCORE OVERRIDE ═══"
i_zOverride   = input.bool(true,   "Z-Score Override",     group=grpZOver, tooltip="Bypass ALL gates when spread z-score hits extreme σ. Captures capitulation/euphoria regardless of regime.")
i_zBuyThresh  = input.float(-3.0,  "Buy Override ≤ σ",     group=grpZOver, minval=-6.0, maxval=-2.0, step=0.25)
i_zSellThresh = input.float(3.75,  "Sell Override ≥ σ",    group=grpZOver, minval=2.0, maxval=6.0, step=0.25)

grpPain     = "═══ PAIN GATE (crypto) ═══"
i_usePainGate  = input.bool(true,   "Enable Pain Gate",          group=grpPain, tooltip="Require recent capitulation/euphoria before band-touch fires. Universally accretive with reward-only conviction multipliers.")
i_vwapLen      = input.int(24,      "Cost Basis Lookback",       group=grpPain, minval=5, maxval=200)
i_shortVwap    = input.int(8,       "Recent Buyers Lookback",    group=grpPain, minval=3, maxval=50)
i_normLen      = input.int(100,     "Normalization Window",      group=grpPain, minval=20, maxval=500)
i_capThresh    = input.float(1.5,   "Capitulation σ",            group=grpPain, minval=0.5, maxval=5.0, step=0.25)
i_euphThresh   = input.float(1.5,   "Euphoria σ",                group=grpPain, minval=0.5, maxval=5.0, step=0.25)
i_painWindow   = input.int(4,       "Pain Lookback (bars)",      group=grpPain, minval=1, maxval=12, tooltip="Capitulation/euphoria within this many bars opens the gate.")

grpPhase    = "═══ PHASE BOOST ═══"
i_phaseOn       = input.bool(true,  "Enable Phase Sell Boost", group=grpPhase, tooltip="Boosts sell % as gold regimes mature. Conservative early, aggressive late.")
i_phaseScale    = input.float(0.5,  "Sell Boost Scale",        group=grpPhase, minval=0.5, maxval=5.0, step=0.1)
i_phaseMax      = input.float(2.5,  "Sell Boost Max",          group=grpPhase, minval=1.1, maxval=5.0, step=0.1)
i_phaseBuyOn    = input.bool(true,  "Enable Phase Buy Boost",  group=grpPhase, tooltip="Boosts buy $ as blue regimes mature. Conservative early, aggressive late.")
i_phaseBuyScale = input.float(1.0,  "Buy Boost Scale",         group=grpPhase, minval=0.5, maxval=5.0, step=0.1)
i_phaseBuyMax   = input.float(2.5,  "Buy Boost Max",           group=grpPhase, minval=1.1, maxval=5.0, step=0.1)

grpDiv      = "═══ DIVERGENCE ═══"
i_showDiv        = input.bool(true,  "Show Spread Divergence",   group=grpDiv)
i_showRSIDiv     = input.bool(true,  "Show RSI Divergence",      group=grpDiv)
i_divPivL        = input.int(5,      "Pivot Left Bars",           group=grpDiv, minval=2, maxval=20)
i_divPivR        = input.int(3,      "Pivot Right Bars",          group=grpDiv, minval=1, maxval=10)
i_divBoostOn     = input.bool(true,  "Divergence Buy Boost",     group=grpDiv, tooltip="Boost buy size when bullish divergence fired recently (spread OR RSI).")
i_divSellBoostOn = input.bool(false, "Divergence Sell Boost",    group=grpDiv, tooltip="Boost sell % when bearish divergence fired recently. Default OFF — A/B test per asset.")
i_divBoostMult   = input.float(1.5,  "Div Boost Multiplier",     group=grpDiv, minval=1.0, maxval=2.0, step=0.05)
i_divWindow      = input.int(5,      "Div Boost Window (bars)",  group=grpDiv, minval=1, maxval=20)

grpRisk     = "═══ RISK MANAGEMENT ═══"
i_breakerOn     = input.bool(false,  "Tail-Risk Breaker",       group=grpRisk, tooltip="Halt new buys when position DD exceeds threshold. Resumes at recovery level. Default OFF.")
i_breakerHalt   = input.float(20,    "Breaker Halt DD %",       group=grpRisk, minval=5, maxval=50, step=1, tooltip="DD % below avg entry that halts new buys.")
i_breakerResume = input.float(12,    "Breaker Resume DD %",     group=grpRisk, minval=0, maxval=40, step=1, tooltip="DD % recovery level that resumes buying. Hysteresis prevents oscillation.")

grpDMFI     = "═══ DMFI CONVICTION ═══"
i_useDmfi      = input.bool(true,   "Enable DMFI Buy Sizing",  group=grpDMFI, tooltip="Scale buy amounts by money flow exhaustion. Deep negative DMFI = high conviction = bigger position. Seven for seven across all fleet architectures.")
i_useDmfiSell  = input.bool(false,  "Enable DMFI Sell Sizing", group=grpDMFI, tooltip="Scale sell % by money flow euphoria. High positive DMFI = euphoric flow = sell more aggressively. Default OFF — over-sells on trending equities.")
i_mfiLen       = input.int(14,      "MFI Length",              group=grpDMFI)
i_mfiSmooth    = input.int(3,       "MFI Smooth",              group=grpDMFI)
i_dmfiLen      = input.int(14,      "DMFI Length",             group=grpDMFI)
i_dmfiSmooth   = input.int(5,       "DMFI Smooth",             group=grpDMFI)
i_dmfiCeil     = input.float(30,    "Ceiling",                 group=grpDMFI, minval=10, maxval=50, step=1)
i_dmfiMin      = input.float(1.0,   "Min Multiplier",          group=grpDMFI, minval=0.1, maxval=1.0, step=0.1)
i_dmfiMax      = input.float(2.0,   "Max Multiplier",          group=grpDMFI, minval=1.0, maxval=3.0, step=0.1)

grpPctConv  = "═══ PERCENTILE CONVICTION ═══"
i_usePctConv   = input.bool(true,   "Enable Pctile Buy Sizing",  group=grpPctConv, tooltip="Scale buy amounts by how statistically extreme the spread is. Lower percentile = deeper oversold = bigger buy. Complements DMFI (flow) with distribution context.")
i_usePctSell   = input.bool(false,  "Enable Pctile Sell Sizing", group=grpPctConv, tooltip="Scale sell % by how statistically extreme the spread is. Default OFF — can over-sell on trending assets.")
i_pctLookback  = input.int(124,     "Percentile Lookback",       group=grpPctConv, minval=20, maxval=500)
i_pctMin       = input.float(1.0,   "Min Multiplier",            group=grpPctConv, minval=0.1, maxval=1.0, step=0.1)
i_pctMax       = input.float(1.5,   "Max Multiplier",            group=grpPctConv, minval=1.0, maxval=3.0, step=0.1)

// ─── 4-SMMA RIBBON ─────────────────────────────────────────────────

float v1 = smma(i_src, i_fastLen)
float v2 = smma(i_src, i_slowLen)

// ─── REGIME DETECTION (2-line, no neutral zone) ────────────────────

bool  bearish   = v1 < v2
bool  bullish   = not bearish
color ribbonClr = bullish ? #FFD700 : #1E90FF

int regime = bullish ? 1 : bearish ? -1 : 0

// ─── ATR-NORM SPREAD & Z-SCORE ──────────────────────────────────────

float atrNorm       = ta.atr(14)
float atrNormSpread = atrNorm > 0 ? (v1 - v2) / atrNorm * 100 : 0.0
float spreadMean    = ta.sma(atrNormSpread, 124)
float spreadStdev   = ta.stdev(atrNormSpread, 124)
float spreadZ       = spreadStdev > 0 ? (atrNormSpread - spreadMean) / spreadStdev : 0.0

bool  zBuyOverride  = i_zOverride and spreadZ <= i_zBuyThresh and barstate.isconfirmed
bool  zSellOverride = i_zOverride and spreadZ >= i_zSellThresh and barstate.isconfirmed

// ─── PAIN GATE — RealPnL Pressure (Pulse lookback-window) ──────────

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
float pressMean   = ta.sma(rawPressure, i_normLen)
float pressStd    = ta.stdev(rawPressure, i_normLen)
float pressZ      = pressStd > 0 ? (rawPressure - pressMean) / pressStd : 0.0

bool capRecent  = ta.lowest(pressZ,  i_painWindow) <= -i_capThresh
bool euphRecent = ta.highest(pressZ, i_painWindow) >=  i_euphThresh

bool painBuyOK  = not i_usePainGate or capRecent
bool painSellOK = not i_usePainGate or euphRecent

// ─── DMFI — Double-Pass Money Flow Conviction ──────────────────────

float rawMFI    = nz(ta.mfi(hlc3, i_mfiLen), 50.0)
float smoothMFI = ta.sma(rawMFI, i_mfiSmooth)
float dmfiRaw   = 2.0 * smoothMFI - nz(ta.rsi(smoothMFI, i_dmfiLen), 50.0)
float dmfi      = nz(ta.sma(dmfiRaw, i_dmfiSmooth), 0.0)
float dmfiClamp = math.max(-i_dmfiCeil, math.min(i_dmfiCeil, dmfi))
float dmfiMult     = i_useDmfi ? nz(i_dmfiMax - (dmfiClamp + i_dmfiCeil) / (2.0 * i_dmfiCeil) * (i_dmfiMax - i_dmfiMin), 1.0) : 1.0
float dmfiSellMult = i_useDmfiSell ? nz(i_dmfiMin + (dmfiClamp + i_dmfiCeil) / (2.0 * i_dmfiCeil) * (i_dmfiMax - i_dmfiMin), 1.0) : 1.0

// ─── PERCENTILE CONVICTION — Statistical Extremity Sizing ──────────

float pctRank    = nz(ta.percentrank(atrNormSpread, i_pctLookback), 50.0)
float pctBuyConv  = math.max(0.0, (50.0 - pctRank) / 50.0)
float pctSellConv = math.max(0.0, (pctRank - 50.0) / 50.0)
float pctBuyMult  = i_usePctConv ? nz(i_pctMin + pctBuyConv * (i_pctMax - i_pctMin), 1.0) : 1.0
float pctSellMult = i_usePctSell ? nz(i_pctMin + pctSellConv * (i_pctMax - i_pctMin), 1.0) : 1.0

// ─── REGIME PHASE TRACKING (XDEV5) ─────────────────────────────────

// Gold regime → sell boost (sell more as bull matures)
var int   goldAge = 0
var float goldPeakSpread = 0.0
var int   goldCount = 0
var float sumGoldPeaks = 0.0
var float sumGoldAges = 0.0

if bullish
    goldAge += 1
    goldPeakSpread := math.max(goldPeakSpread, math.abs(atrNormSpread))
else
    if bullish[1] and goldAge > 0
        goldCount    += 1
        sumGoldPeaks += goldPeakSpread
        sumGoldAges  += goldAge
    goldAge := 0
    goldPeakSpread := 0.0

float avgGoldPeak     = goldCount > 0 ? sumGoldPeaks / goldCount : goldPeakSpread > 0 ? goldPeakSpread : 1.0
float avgGoldAge      = goldCount > 0 ? sumGoldAges / goldCount : 50.0
float spreadPeakRatio = goldPeakSpread > 0 ? math.abs(atrNormSpread) / goldPeakSpread : 0.0
float regimeAgeNorm   = math.min(1.0, goldAge / math.max(1.0, avgGoldAge))
float phaseBoost      = i_phaseOn ? math.min(i_phaseMax, 1.0 + spreadPeakRatio * regimeAgeNorm * i_phaseScale) : 1.0

// Blue regime → buy boost (buy more as bear matures)
var int   blueAge = 0
var float bluePeakSpread = 0.0
var int   blueCount = 0
var float sumBluePeaks = 0.0
var float sumBlueAges = 0.0

if bearish
    blueAge += 1
    bluePeakSpread := math.max(bluePeakSpread, math.abs(atrNormSpread))
else
    if bearish[1] and blueAge > 0
        blueCount    += 1
        sumBluePeaks += bluePeakSpread
        sumBlueAges  += blueAge
    blueAge := 0
    bluePeakSpread := 0.0

float avgBluePeak       = blueCount > 0 ? sumBluePeaks / blueCount : bluePeakSpread > 0 ? bluePeakSpread : 1.0
float avgBlueAge        = blueCount > 0 ? sumBlueAges / blueCount : 50.0
float spreadTroughRatio = bluePeakSpread > 0 ? math.abs(atrNormSpread) / bluePeakSpread : 0.0
float blueAgeNorm       = math.min(1.0, blueAge / math.max(1.0, avgBlueAge))
float phaseBuyBoost     = i_phaseBuyOn ? math.min(i_phaseBuyMax, 1.0 + spreadTroughRatio * blueAgeNorm * i_phaseBuyScale) : 1.0

// ─── SPREAD DIVERGENCE ──────────────────────────────────────────────

// ─── PIVOT-BASED DIVERGENCE (5L/3R fleet standard) ──────────────────

float rsiVal = ta.rsi(close, 14)
float pivHi  = ta.pivothigh(high, i_divPivL, i_divPivR)
float pivLo  = ta.pivotlow(low, i_divPivL, i_divPivR)

// Track previous pivot values
var float prevPivHiPrice  = na
var float prevPivHiSpread = na
var float prevPivHiRSI    = na
var float prevPivLoPrice  = na
var float prevPivLoSpread = na
var float prevPivLoRSI    = na

float spreadAtPiv = nz(atrNormSpread[i_divPivR])
float rsiAtPiv    = nz(rsiVal[i_divPivR])

// Bearish: price higher high, indicator lower high
bool bearDivSpread = false
bool bearDivRSI    = false
if not na(pivHi)
    if not na(prevPivHiPrice)
        if pivHi > prevPivHiPrice and spreadAtPiv < prevPivHiSpread
            bearDivSpread := true
        if pivHi > prevPivHiPrice and rsiAtPiv < prevPivHiRSI
            bearDivRSI := true
    prevPivHiPrice  := pivHi
    prevPivHiSpread := spreadAtPiv
    prevPivHiRSI    := rsiAtPiv

// Bullish: price lower low, indicator higher low
bool bullDivSpread = false
bool bullDivRSI    = false
if not na(pivLo)
    if not na(prevPivLoPrice)
        if pivLo < prevPivLoPrice and spreadAtPiv > prevPivLoSpread
            bullDivSpread := true
        if pivLo < prevPivLoPrice and rsiAtPiv > prevPivLoRSI
            bullDivRSI := true
    prevPivLoPrice  := pivLo
    prevPivLoSpread := spreadAtPiv
    prevPivLoRSI    := rsiAtPiv

// Combined: either type triggers boost
bool bullDiv = bullDivSpread or bullDivRSI
bool bearDiv = bearDivSpread or bearDivRSI
int barsSinceBullDiv = ta.barssince(bullDiv)
bool recentBullDiv = not na(barsSinceBullDiv) and barsSinceBullDiv <= i_divWindow
float divBoost = i_divBoostOn and recentBullDiv ? i_divBoostMult : 1.0
int barsSinceBearDiv = ta.barssince(bearDiv)
bool recentBearDiv = not na(barsSinceBearDiv) and barsSinceBearDiv <= i_divWindow
float divSellBoost = i_divSellBoostOn and recentBearDiv ? i_divBoostMult : 1.0

// --- HTF PEN BAND (homogeneous: identical Donchian-extreme + learned-mult construction, for A/B) ---
f_bandLevels() =>
    float _atr = ta.atr(14)
    float _dHi = ta.highest(high, i_donchLen)[1]
    float _dLo = ta.lowest(low, i_donchLen)[1]
    var array<float> _bPen = array.new_float()
    var array<float> _sPen = array.new_float()
    if low <= _dLo and _atr > 0
        float _p = (_dLo - low) / _atr
        if _p > 0
            array.push(_bPen, _p)
            if array.size(_bPen) > i_adaptLookback
                array.shift(_bPen)
    if high >= _dHi and _atr > 0
        float _p = (high - _dHi) / _atr
        if _p > 0
            array.push(_sPen, _p)
            if array.size(_sPen) > i_adaptLookback
                array.shift(_sPen)
    var float _bMult = i_defaultMult
    var float _sMult = i_defaultMult
    if array.size(_bPen) >= i_minSamples
        _bMult := math.max(i_minMult, math.min(i_maxMult, array.avg(_bPen) * i_sensitivity))
    if array.size(_sPen) >= i_minSamples
        _sMult := math.max(i_minMult, math.min(i_maxMult, array.avg(_sPen) * i_sensitivity))
    [_dLo - _atr * _bMult, _dHi + _atr * _sMult]

f_bandLevelsOff() =>
    [_b, _s] = f_bandLevels()
    [_b[1], _s[1]]

// ─── PENETRATION-LEARNING BANDS (XDEV5) ─────────────────────────────

float atr = ta.atr(14)

float donchHi = ta.highest(high, i_donchLen)[1]
float donchLo = ta.lowest(low, i_donchLen)[1]

var array<float> buyPenetrations  = array.new_float()
var array<float> sellPenetrations = array.new_float()

bool touchedLower = low <= donchLo
bool touchedUpper = high >= donchHi

if touchedLower and atr > 0
    float pen = (donchLo - low) / atr
    if pen > 0
        array.push(buyPenetrations, pen)
        if array.size(buyPenetrations) > i_adaptLookback
            array.shift(buyPenetrations)

if touchedUpper and atr > 0
    float pen = (high - donchHi) / atr
    if pen > 0
        array.push(sellPenetrations, pen)
        if array.size(sellPenetrations) > i_adaptLookback
            array.shift(sellPenetrations)

var float buyMult  = i_defaultMult
var float sellMult = i_defaultMult

if array.size(buyPenetrations) >= i_minSamples
    float avgPen = array.avg(buyPenetrations) * i_sensitivity
    buyMult := math.max(i_minMult, math.min(i_maxMult, avgPen))

if array.size(sellPenetrations) >= i_minSamples
    float avgPen = array.avg(sellPenetrations) * i_sensitivity
    sellMult := math.max(i_minMult, math.min(i_maxMult, avgPen))

float buyBandLevel  = donchLo - (atr * buyMult)
float sellBandLevel = donchHi + (atr * sellMult)

// HTF pen band (homogeneous [1]-offset, no repaint)
int    _chartTfMin = int(timeframe.in_seconds() / 60)
int    _htfMin     = i_htfMode == "Auto" ? _chartTfMin * i_htfMult : i_htfMan
string _htfStr     = _htfMin >= 1440 ? str.tostring(math.max(1, int(_htfMin / 1440))) + "D" : str.tostring(_htfMin)
[htfBuyBand, htfSellBand] = request.security(syminfo.tickerid, _htfStr, f_bandLevelsOff(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

// ─── INPUTS: SIZING & SIGNALS ───────────────────────────────────────

grpSize     = "═══ POSITION SIZING ═══"
i_buyBase   = input.float(100, "Buy Base $",       minval=1, group=grpSize)
i_geoFactor = input.float(1.5, "Geo Factor",       step=0.1, group=grpSize)
i_geoSteps  = input.int(5, "Geo Steps",            minval=1, maxval=10, group=grpSize)
i_maxBuys   = input.int(24, "Max Buys",            minval=1, group=grpSize)
i_cascadeBase = input.float(1.0, "Cascade Decay",       group=grpSize, minval=0.5, maxval=1.0, step=0.05, tooltip="Each subsequent buy gets this × previous tier. 1.0 (default) = no decay. WARNING: cascade decay combined with geometric sizing is a proven destructive pairing fleet-wide (eliminated majority of realized PnL in testing) — only lower below 1.0 if geo factor is also set to 1.0.")

grpFilt     = "═══ STRUCTURAL FILTERS ═══"
i_llOn           = input.bool(false,  "LL Filter (Buy Side)",     group=grpFilt, tooltip="Require new lower low since last buy before next buy can fire.")
i_hhOn           = input.bool(true,   "HH Filter (Sell Side)",    group=grpFilt, tooltip="Require new higher high since last sell before next sell can fire.")
i_atrSepOn       = input.bool(true,   "ATR Buy Separation",       group=grpFilt, tooltip="Minimum ATR distance between consecutive buys.")
i_atrSepMult     = input.float(0.50,  "ATR Sep Buy Multiplier",   group=grpFilt, minval=0.1, maxval=3.0, step=0.05)
i_sellAtrSepOn   = input.bool(true,   "ATR Sell Separation",      group=grpFilt, tooltip="Minimum ATR distance between consecutive sells.")
i_sellAtrSepMult = input.float(2.0,   "ATR Sep Sell Multiplier",  group=grpFilt, minval=0.1, maxval=3.0, step=0.05)
i_wickBoostOn    = input.bool(true,   "Wick Rejection Boost",     group=grpFilt, tooltip="Boost buy size when band-touch bar shows strong lower wick rejection.")
i_wickBoostMult  = input.float(1.2,   "Wick Boost Multiplier",    group=grpFilt, minval=1.0, maxval=2.0, step=0.05)
i_wickThresh     = input.float(0.6,   "Wick Threshold",           group=grpFilt, minval=0.3, maxval=0.9, step=0.05, tooltip="Close must be in upper X% of bar range. 0.6 = close in upper 40%.")
i_regMatureOn    = input.bool(true,   "Regime Maturity Gate",      group=grpFilt, tooltip="Block signals until regime has matured — enough bars passed OR spread reached sufficient depth. Prevents premature signals in fresh regime flips.")
i_regMinBars     = input.int(8,       "Min Regime Bars",           group=grpFilt, minval=1, maxval=40, tooltip="Minimum bars in current regime before signals allowed.")
i_regMinSpread   = input.float(1.5,   "Min Regime Depth (ATR)",    group=grpFilt, minval=0.1, maxval=3.0, step=0.1, tooltip="Minimum spread depth in ATR units before signals allowed. Either bars OR depth qualifies.")
i_sellCooldown   = input.int(0,       "Sell Cooldown (bars)",      group=grpFilt, minval=0, maxval=10, tooltip="Minimum bars between consecutive sells.")
i_buyCooldown    = input.int(1,       "Buy Cooldown (bars)",       group=grpFilt, minval=0, maxval=10, tooltip="Minimum bars between consecutive buys.")

grpSell     = "═══ SELL ENGINE ═══"
i_sellBase  = input.float(20, "Sell Base %",        minval=1, maxval=100, group=grpSell)
i_sellMax   = input.float(50, "Sell Max %",         minval=1, maxval=100, group=grpSell)
i_maxSells  = input.int(50, "Max Sells",            minval=1, group=grpSell)
i_basisGuard = input.bool(true,  "Basis Guard (below-basis slivers)", group=grpSell, tooltip="Fleet kit, ninth chassis: any sell fired while price is below the pre-sell average entry takes only the Guard Sliver % of position instead of the computed sell percent (phase/div/DMFI scaling included). Keeps loss realizations tiny; the held inventory sells higher later. Changes sell SIZE only, never sell timing -- signals are untouched either way. Default ON at sliver 1.0 -- the committed 616.9 board (fleet #4). Turn OFF to reproduce the old 616.7 board.")
i_guardPct   = input.float(1.0,  "Guard Sliver % (Basis Guard)", group=grpSell, minval=0.25, maxval=50.0, step=0.25, tooltip="Sell %-of-position used below basis when the Guard is ON. 12.5 is the canonical launch value; each chassis probes its own knee (Core 10, XDEV 5, CycleTune 2.5, CCIBands 1.0 floor, CRUCIBLE 2.5 plateau, Simplex 1.0 committed, Opus46 1.0 committed). Floor 0.25 so the ladder cannot run out of road.")

grpDisp     = "═══ DISPLAY ═══"
i_showTable = input.bool(true, "Show Performance Table", group=grpDisp)
i_tblPos    = input.string("Bottom Right", "Table Position", options=["Top Left","Top Center","Top Right","Middle Left","Middle Center","Middle Right","Bottom Left","Bottom Center","Bottom Right"], group=grpDisp)

grpVolSpike = "═══ VOLUME SPIKE ═══"
i_volSpikeOn   = input.bool(true,           "Show Volume Spike BG",  group=grpVolSpike, tooltip="Shade background when volume exceeds the SMA by the specified multiplier.")
i_volSpikeMult = input.float(2.0,           "Volume Multiplier",     group=grpVolSpike, minval=1.1, maxval=10.0, step=0.1, tooltip="Volume must exceed SMA × this value to trigger shading.")
i_volSpikeLen  = input.int(20,              "Volume SMA Length",     group=grpVolSpike, minval=5, maxval=200)
i_volSpikeClr  = input.color(#9B30FF,       "Spike Color",           group=grpVolSpike)
i_volSpikeFade = input.int(75,              "Transparency",          group=grpVolSpike, minval=50, maxval=97, step=1)

grpCascade  = "═══ CASCADE EXHAUSTION (CRUCIBLE port) ═══"
i_cascExhOn      = input.bool(true, "Cascade Exhaustion Boost", group=grpCascade, tooltip="CRUCIBLE port — ON by default (616.4, EARNED 3/3: MSTR 4H +$875/+0.8%, BTC 2H +$798/+5.7%, HYPE 2H +$240/+2.0% — all positive, identical signal structure, sizes up the right bars). Reward-only conviction multiplier that sizes up buys when multiple exhaustion signals agree — volume climax, price deceleration, ATR contraction, wick rejection. Each component asks a different question about whether the selling is genuinely running out of gas. Boost only (min 1.0), never blocks a signal. Buy-side only — sell-side conviction is proven harmful on accumulation-class systems.")
i_cascMinScore   = input.int(2, "Min Components (0-4)", minval=1, maxval=4, group=grpCascade, tooltip="How many of the 4 exhaustion signals must agree before the boost applies. 2 = any two is enough. 4 = all four must line up (very rare).")
i_cascBoostMult  = input.float(1.5, "Boost Multiplier", minval=1.0, maxval=3.0, step=0.25, group=grpCascade, tooltip="Buy size multiplied by this when cascade score meets the minimum. Reward-only: 1.0 when score is below minimum (no penalty).")
i_volClimaxMult  = input.float(3.0, "Vol Climax (× SMA20)", minval=1.5, maxval=10.0, step=0.5, group=grpCascade, tooltip="Volume must exceed its 20-bar SMA by this factor to count as a climax bar.")
i_cascWickRatio  = input.float(2.0, "Wick Rejection Ratio", minval=1.0, maxval=5.0, step=0.5, group=grpCascade, tooltip="Lower wick must be this many times the body size to count as rejection. Separate from Opus46's existing wick boost (which uses close position in range).")

grpThrot    = "═══ SELL THROTTLE (KEEL port) ═══"
i_sellThrotOn    = input.bool(true, "Adaptive Sell Throttle", group=grpThrot, tooltip="Waits longer between sells while the market is running hot, so each sell happens at a better price. ON by default (616.2, EARNED): Opus46 pairs — MSTR 4H +22%, HYPE 2H +13%, MRVL 8H +10%, BTC 2H flat (no rallies to exploit). KEEL pairs 4/4 (+23% to +52%). Only does work on charts with real uptrends; harmless elsewhere. First sell of each cycle always fires instantly. Replaces the fixed Sell Cooldown (now default 0) — do not run both.")
i_sellThrotBase  = input.int(4, "Throttle Base (bars)", minval=1, maxval=20, group=grpThrot)
i_sellThrotScale = input.float(1.0, "Throttle Scale (per σ)", minval=0.25, maxval=4.0, step=0.25, group=grpThrot, tooltip="Cooldown multiplier grows by this much per +1σ of bull spreadZ. mult = 1 + min(cap-1, max(0,spreadZ) × scale).")
i_sellThrotMax   = input.float(10.0, "Throttle Max Mult", minval=2.0, maxval=30.0, step=1.0, group=grpThrot)

grpWH       = "═══ WEBHOOK ═══"
i_pass      = input.string("Rosco888", "Passphrase", group=grpWH)
i_contractType = input.string("auto", "Contract Type", options=["auto", "linear", "inverse"], group=grpWH)

// ─── STRUCTURAL FILTERS (XDEV5/ATHANOR) ────────────────────────────

var float lastBuyPrice = na, var float lastBuyLow = na, var float lastSellHigh = na
var float lastSellPrice = na
var int   lastSellBar = 0
var int   lastBuyBar  = 0

bool llOK         = not i_llOn or na(lastBuyLow) or low < lastBuyLow
bool hhOK         = not i_hhOn or na(lastSellHigh) or high > lastSellHigh
bool atrSepOK     = not i_atrSepOn or na(lastBuyPrice) or math.abs(close - lastBuyPrice) >= i_atrSepMult * atr
bool sellAtrSepOK = not i_sellAtrSepOn or na(lastSellPrice) or (close - lastSellPrice) >= atr * i_sellAtrSepMult

// ─── WICK REJECTION BOOST ────────────────────────────────────────────

float wickScore = (high - low) > 0 ? (close - low) / (high - low) : 0.5
float wickBoost = i_wickBoostOn and wickScore >= i_wickThresh ? i_wickBoostMult : 1.0

// ─── BAND-TOUCH SIGNALS + Z-OVERRIDE + REGIME GATE + FILTERS ───────

// Regime maturity: block signals until regime is established (bars OR depth)
bool regimeBuyMature  = not i_regMatureOn or blueAge >= i_regMinBars or (bluePeakSpread / 100.0) >= i_regMinSpread
bool regimeSellMature = not i_regMatureOn or goldAge >= i_regMinBars or (goldPeakSpread / 100.0) >= i_regMinSpread

// Sell cooldown
bool sellCoolOK = i_sellCooldown == 0 or lastSellBar == 0 or (bar_index - lastSellBar) >= i_sellCooldown

// Buy cooldown
bool buyCoolOK = i_buyCooldown == 0 or lastBuyBar == 0 or (bar_index - lastBuyBar) >= i_buyCooldown

// Band touch: BUY in BEAR + LL + ATR sep, SELL in BULL + HH + ATR sep
bool bandBuyTouch  = low <= buyBandLevel and bearish and regimeBuyMature and painBuyOK and barstate.isconfirmed
bool bandSellTouch = high >= sellBandLevel and bullish and hhOK and sellAtrSepOK and regimeSellMature and sellCoolOK and painSellOK and barstate.isconfirmed

// Combined triggers: band touch OR z-score override (z bypasses regime/maturity/pain; LL + ATR sep + cooldown still apply)
// HTF structural touches (homogeneous with chart bands)
bool chartBuyStruct  = low  <= buyBandLevel
bool htfBuyStruct    = low  <= htfBuyBand
bool chartSellStruct = high >= sellBandLevel
bool htfSellStruct   = high >= htfSellBand
bool buyHtfGate  = i_buyHtfMode  == "Off" ? true : i_buyHtfMode  == "Chart" ? chartBuyStruct  : i_buyHtfMode  == "HTF" ? htfBuyStruct  : i_buyHtfMode  == "Either" ? (chartBuyStruct  or htfBuyStruct)  : (chartBuyStruct  and htfBuyStruct)
bool sellHtfGate = i_sellHtfMode == "Off" ? true : i_sellHtfMode == "Chart" ? chartSellStruct : i_sellHtfMode == "HTF" ? htfSellStruct : i_sellHtfMode == "Either" ? (chartSellStruct or htfSellStruct) : (chartSellStruct and htfSellStruct)

bool sigBuy  = (bandBuyTouch or zBuyOverride) and buyHtfGate
bool sigSell = (bandSellTouch or zSellOverride) and sellHtfGate

// ─── POSITION STATE ─────────────────────────────────────────────────

var int   cycBuyLots  = 0
var int   cycSellLots = 0
var float totalQty    = 0.0
var float totalCost   = 0.0
var float avgEntry    = 0.0

// Tail-risk breaker: halt buys when DD exceeds threshold
var bool breakerActive = false
float ddPct = totalQty > 0 and avgEntry > 0 ? (avgEntry - close) / avgEntry * 100 : 0.0
if i_breakerOn and ddPct >= i_breakerHalt
    breakerActive := true
if i_breakerOn and ddPct <= i_breakerResume
    breakerActive := false
bool breakerOK = not i_breakerOn or not breakerActive

// Final signals with capacity + breaker
// 616.0: if this raw trigger will close the cycle (sells occurred), the lot cap
// must be judged against the fresh cycle (0 lots), not the dying one — otherwise
// the cycle-closing buy is wrongly cap-blocked at the boundary (AZOTH-family ordering bug).
bool cycleWillClose = sigBuy and cycSellLots > 0 and totalQty > 0
int  effBuyLots     = cycleWillClose ? 0 : cycBuyLots
bool buySignal  = sigBuy and effBuyLots < i_maxBuys and breakerOK and buyCoolOK and llOK and atrSepOK
// Adaptive sell throttle (616.1): cooldown stretches with bull extension strength
float sellThrotMult = 1.0 + math.min(i_sellThrotMax - 1.0, math.max(0.0, bullish ? spreadZ : 0.0) * i_sellThrotScale)
int   sellThrotCD   = math.round(i_sellThrotBase * sellThrotMult)
bool  sellThrotOK   = not i_sellThrotOn or cycSellLots == 0 or lastSellBar == 0 or (bar_index - lastSellBar) >= sellThrotCD

bool sellSignal = sigSell and cycSellLots < i_maxSells and totalQty > 0 and sellThrotOK

// ─── CASCADE EXHAUSTION (CRUCIBLE port) ──────────────────────────────
// Four independent questions about whether selling energy is spent:
// 1. Volume climax — is volume spiking? (capitulation/panic signature)
// 2. Price deceleration — price still falling but slowing down (2nd derivative)
// 3. ATR contraction — volatility was elevated but is now declining (storm passing)
// 4. Wick rejection — long lower wick with bullish close (buyers stepping in)
float cascVolSma    = ta.sma(volume, 20)
bool  cascVolClimax = volume > cascVolSma * i_volClimaxMult

float cascPriceVel  = close - close[1]
float cascPriceAcc  = cascPriceVel - cascPriceVel[1]
bool  cascPriceBot  = cascPriceVel < 0 and cascPriceAcc > 0

float cascAtrSma    = ta.sma(atr, 20)
float cascAtrDelta  = atr - atr[1]
bool  cascAtrContr  = atr > cascAtrSma * 1.5 and cascAtrDelta < 0

float cascWickLo    = math.min(close, open) - low
float cascBodyAbs   = math.max(math.abs(close - open), syminfo.mintick)
bool  cascWickRej   = cascWickLo > cascBodyAbs * i_cascWickRatio and close > open

int   cascBuyScore  = (cascVolClimax ? 1 : 0) + (cascPriceBot ? 1 : 0) + (cascAtrContr ? 1 : 0) + (cascWickRej ? 1 : 0)
float cascBuyBoost  = i_cascExhOn and cascBuyScore >= i_cascMinScore ? i_cascBoostMult : 1.0

// Geometric sizing × phase buy boost
int  geoStep   = math.min(i_geoSteps, cycBuyLots)
float geoMult  = math.pow(i_geoFactor, geoStep)
float cascadeDecay = math.pow(i_cascadeBase, cycBuyLots)
float buySize  = i_buyBase * geoMult * cascadeDecay * phaseBuyBoost * divBoost * wickBoost * dmfiMult * pctBuyMult * cascBuyBoost

// Sell sizing: %-of-remaining × phase sell boost
float sellPctCalc = math.min(i_sellMax, i_sellBase * phaseBoost * divSellBoost * dmfiSellMult * pctSellMult)
// BASIS GUARD: below the pre-sell average entry the sell takes only the sliver %.
float sellPctEff = i_basisGuard and totalQty > 0 and close < avgEntry ? i_guardPct : sellPctCalc
float sellQty = totalQty > 0 ? totalQty * (sellPctEff / 100) : 0.0

// ─── CYCLE ACCOUNTING (fleet standard: per-cycle PnL) ───────────────

var float realized      = 0.0
var int   wins          = 0
var int   losses        = 0
var int   totalBuySigs  = 0
var int   totalSellSigs = 0
var int   cycleCount    = 0
var float totalDeployed = 0.0
var float maxCost       = 0.0
var float peakPnl       = 0.0
var float maxDD         = 0.0
var float sumWins       = 0.0
var float sumLosses     = 0.0
var float cycleSellRev  = 0.0
var float cycleSellQty  = 0.0
var float cycPeakPnL    = 0.0
var float cycMaxDD      = 0.0
var float sumCycDD      = 0.0

// Cycle close: raw buy trigger after sells (XDEV5 pattern)
bool rawBuyTrigger = sigBuy
bool bookCycle = false
float bookPnL = 0.0

if rawBuyTrigger and cycSellLots > 0 and totalQty > 0
    float soldCost = cycleSellQty * avgEntry
    bookPnL  := cycleSellRev - soldCost
    bookCycle := true
    cycleSellRev := 0.0
    cycleSellQty := 0.0
    cycSellLots  := 0
    cycBuyLots   := 0
    lastBuyPrice  := na
    lastBuyLow    := na
    lastSellHigh  := na
    lastSellPrice := na
    breakerActive := false

// Position-zero close: if sells reduced position to zero
if totalQty <= 0 and cycSellLots > 0
    float soldCost = cycleSellQty * avgEntry
    bookPnL  := cycleSellRev - soldCost
    bookCycle := true
    cycleSellRev := 0.0
    cycleSellQty := 0.0
    cycSellLots  := 0
    cycBuyLots   := 0
    totalQty     := 0.0
    totalCost    := 0.0
    lastBuyPrice := na
    lastBuyLow   := na
    lastSellHigh := na
    lastSellPrice := na

if bookCycle
    cycleCount += 1
    sumCycDD   += cycMaxDD
    cycPeakPnL := realized + bookPnL
    cycMaxDD   := 0.0
    if bookPnL >= 0
        wins     += 1
        sumWins  += bookPnL
    else
        losses   += 1
        sumLosses += math.abs(bookPnL)
    realized += bookPnL

// Process buy
if buySignal
    float buyQty = buySize / close
    totalQty    += buyQty
    totalCost   += buySize
    avgEntry    := totalQty > 0 ? totalCost / totalQty : close
    cycBuyLots  += 1
    totalBuySigs += 1
    totalDeployed += buySize
    lastBuyPrice := close
    lastBuyLow   := low
    lastBuyBar   := bar_index
    lastSellHigh := na
    lastSellPrice := na
    if totalCost > maxCost
        maxCost := totalCost

// Process sell (accumulate within cycle, book on cycle close)
if sellSignal
    float sellVal = sellQty * close
    cycleSellRev += sellVal
    cycleSellQty += sellQty
    totalQty     -= sellQty
    totalCost    := totalQty * avgEntry
    cycSellLots  += 1
    totalSellSigs += 1
    lastSellHigh := high
    lastBuyLow   := na
    lastSellPrice := close
    lastSellBar  := bar_index

// Drawdown tracking (includes unbooked cycle PnL in unrealized)
float posVal     = totalQty * close
float unrealized = cycleSellRev + posVal - totalCost - (cycleSellQty * avgEntry)
float totalPnl   = realized + unrealized
peakPnl    := math.max(peakPnl, totalPnl)
maxDD      := math.min(maxDD, totalPnl - peakPnl)
cycPeakPnL := math.max(cycPeakPnL, totalPnl)
cycMaxDD   := math.max(cycMaxDD, cycPeakPnL - totalPnl)

// ─── PERFORMANCE METRICS ────────────────────────────────────────────

int   totalTrades = wins + losses
float winRate     = totalTrades > 0 ? float(wins) / float(totalTrades) * 100 : 0.0
float avgWinCalc  = wins > 0 ? sumWins / float(wins) : 0.0
float avgLossCalc = losses > 0 ? -sumLosses / float(losses) : 0.0
float expectancy  = totalTrades > 0 ? realized / float(totalTrades) : 0.0
float pf          = sumLosses > 0 ? sumWins / sumLosses : (sumWins > 0 ? 999.0 : 0.0)
float avgDDVal    = cycleCount > 0 ? -sumCycDD / float(cycleCount) : 0.0
float roiVal      = maxCost > 0 ? realized / maxCost * 100 : 0.0
float dwpVal      = totalDeployed > 0 ? realized / totalDeployed * 100 : 0.0

// ─── PLOTS ──────────────────────────────────────────────────────────

// Learned bands
color bandClr = color.new(#7b8976, 20)
plot(i_showBands ? buyBandLevel[1]  : na, "Buy Band",  bandClr, 1, plot.style_line)
plot(i_showBands ? sellBandLevel[1] : na, "Sell Band", bandClr, 1, plot.style_line)
plot(i_showHtfBands ? htfBuyBand  : na, "HTF Buy Band",  color.new(#00E5FF, 30), 1, plot.style_line)
plot(i_showHtfBands ? htfSellBand : na, "HTF Sell Band", color.new(#FFD700, 30), 1, plot.style_line)

// Outer ribbon: regime-colored, linewidth 2, anchored [1]
plot(v1[1], "Fast Outer", color=ribbonClr[1], linewidth=2)
plot(v2[1], "Slow Outer", color=ribbonClr[1], linewidth=2)

// Fill between outer bands
p_v1 = plot(v1[1], "v1f", color=color.new(ribbonClr[1], 100), display=display.none)
p_v2 = plot(v2[1], "v2f", color=color.new(ribbonClr[1], 100), display=display.none)
fill(p_v1, p_v2, color=color.new(ribbonClr[1], 85), title="Ribbon Fill")

// Buy signals: conviction-colored triangles (cyan tiers)
color buyCol = cycBuyLots <= 1 ? color.new(#00FFFF, 0) : cycBuyLots <= 3 ? color.new(#0088FF, 0) : cycBuyLots <= 5 ? color.new(#4DA6FF, 0) : color.new(#0088FF, 0)
plotshape(buySignal, "Buy", shape.triangleup, location.belowbar, buyCol, size=size.small)

// Sell signals: magenta triangles
plotshape(sellSignal, "Sell", shape.triangledown, location.abovebar, color.new(#FF00FF, 0), size=size.small)

// Divergence dots: lime bull div, orange bear div (fleet standard)
// Spread divergence (circles)
plotshape(i_showDiv and bullDivSpread ? low : na, "Bull Div Spread", shape.circle, location.belowbar, color.new(#00FF00, 0), size=size.tiny, offset=-i_divPivR)
plotshape(i_showDiv and bearDivSpread ? high : na, "Bear Div Spread", shape.circle, location.abovebar, color.new(#FF6B35, 0), size=size.tiny, offset=-i_divPivR)
// RSI divergence (diamonds)
plotshape(i_showRSIDiv and bullDivRSI ? low : na, "Bull Div RSI", shape.diamond, location.belowbar, color.new(#00FFAA, 0), size=size.tiny, offset=-i_divPivR)
plotshape(i_showRSIDiv and bearDivRSI ? high : na, "Bear Div RSI", shape.diamond, location.abovebar, color.new(#FF00FF, 0), size=size.tiny, offset=-i_divPivR)

// ═══════════════════════════════════════════════════════════════════
//  FLEET SQS SCORING BLOCK  —  self-contained, reads own metrics
// ═══════════════════════════════════════════════════════════════════

int   sqsTotalDays   = math.max(1, (time - time[math.min(bar_index, 1)]) > 0 ? bar_index : 1)
float sqsCalendarD   = sqsTotalDays * timeframe.in_seconds() / 86400.0
float sqsYears       = math.max(sqsCalendarD / 365.25, 0.01)
float sqsAbsDD       = math.abs(maxDD)

float sqsWR    = (wins + losses) > 0 ? float(wins) / float(wins + losses) * 100 : 0.0
float sqsPF    = sumLosses > 0 ? sumWins / sumLosses : (sumWins > 0 ? 999.0 : 0.0)
float sqsMAR   = sqsAbsDD > 0 ? realized / sqsAbsDD : (realized > 0 ? 999.0 : 0.0)
float sqsAnnROI = maxCost > 0 ? (realized / maxCost) / sqsYears * 100 : 0.0

float nWR   = math.min(100.0, sqsWR    / 95.0  * 100)
float nPF   = math.min(100.0, sqsPF    / 10.0  * 100)
float nMAR  = math.min(100.0, sqsMAR   / 10.0  * 100)
float nROI  = math.min(100.0, sqsAnnROI / 30.0 * 100)

float sqsScore = nWR > 0 and nPF > 0 and nMAR > 0 and nROI > 0 ? math.pow(nWR * nPF * nMAR * nROI, 0.25) : 0.0
string sqsGrade = sqsScore >= 90 ? "S" : sqsScore >= 80 ? "A" : sqsScore >= 70 ? "A-" : sqsScore >= 60 ? "B+" : sqsScore >= 50 ? "B" : sqsScore >= 40 ? "B-" : sqsScore >= 30 ? "C" : sqsScore >= 20 ? "D" : "F"

// ═══════════════════════════════════════════════════════════════════

// SQS Signal plot (hidden, for external SQS companion)
float sqsSig = buySignal ? 1.0 : sellSignal ? -1.0 : 0.0
plot(sqsSig, "SQS Signal", color=color.new(color.blue, 100), display=display.status_line)

// ── SQS EXPORT PLOTS (hidden, wired to SQS companion pane) ─────
plot(realized,                   "SQS:Real",     color=color.new(color.blue, 100), display=display.data_window)
plot(totalPnl,                   "SQS:TotPnL",   color=color.new(color.blue, 100), display=display.data_window)
plot(bar_index,                  "Bars",         color=color.new(color.blue, 100), display=display.data_window)
plot(sumWins,                    "SQS:GrossW",   color=color.new(color.blue, 100), display=display.data_window)
plot(sumLosses,                  "SQS:GrossL",   color=color.new(color.blue, 100), display=display.data_window)
plot(math.abs(maxDD),            "SQS:MaxDD",    color=color.new(color.blue, 100), display=display.data_window)
plot(totalDeployed,              "SQS:Deploy",   color=color.new(color.blue, 100), display=display.data_window)
plot(float(totalBuySigs + totalSellSigs), "SQS:Sigs", color=color.new(color.blue, 100), display=display.data_window)
plot(float(cycleCount),          "SQS:Cycles",   color=color.new(color.blue, 100), display=display.data_window)
plot(maxCost,                    "SQS:PeakCost", color=color.new(color.blue, 100), display=display.data_window)

// Volume spike background
float volSpikeSma = ta.sma(volume, i_volSpikeLen)
bool  volSpike = i_volSpikeOn and volume >= volSpikeSma * i_volSpikeMult
bgcolor(volSpike ? color.new(i_volSpikeClr, i_volSpikeFade) : na, title="Volume Spike BG")

// ─── PERFORMANCE TABLE ──────────────────────────────────────────────

f_signColor(val) =>
    val > 0 ? color.new(#00FF88, 0) : val < 0 ? color.new(#FF4444, 0) : color.new(#d0d0d0, 0)

var tPos = switch i_tblPos
    "Top Left"      => position.top_left
    "Top Center"    => position.top_center
    "Top Right"     => position.top_right
    "Middle Left"   => position.middle_left
    "Middle Center" => position.middle_center
    "Middle Right"  => position.middle_right
    "Bottom Left"   => position.bottom_left
    "Bottom Center" => position.bottom_center
    => position.bottom_right

var table perfTbl = table.new(tPos, 4, 13, border_color=#333355, border_width=1, frame_color=#333355, frame_width=1)

hBg = #1a1a2e
rBg = #0d0d1a
dim = #d0d0d0

if barstate.islast and i_showTable
    table.cell(perfTbl, 0, 0, "Opus46 616.6",  text_color=#FFD700, bgcolor=hBg, text_size=size.small, text_halign=text.align_left)
    table.cell(perfTbl, 1, 0, str.tostring(timeframe.period), text_color=#00FFFF, bgcolor=hBg, text_size=size.small)
    table.cell(perfTbl, 2, 0, sqsGrade + " " + str.tostring(sqsScore, "#.#"), text_color=sqsScore >= 70 ? #00FF88 : sqsScore >= 50 ? #FFD700 : #FF4444, bgcolor=hBg, text_size=size.small)
    table.cell(perfTbl, 3, 0, bullish ? "GOLD" : "BLUE", text_color=bullish ? #FFD700 : #0088FF, bgcolor=hBg, text_size=size.small)

    table.cell(perfTbl, 0, 1, "Realized", text_color=dim, bgcolor=rBg, text_size=size.small, text_halign=text.align_left)
    table.cell(perfTbl, 1, 1, "$" + str.tostring(realized, "#.##"), text_color=f_signColor(realized), bgcolor=rBg, text_size=size.small)
    table.cell(perfTbl, 2, 1, "PF", text_color=dim, bgcolor=rBg, text_size=size.small)
    table.cell(perfTbl, 3, 1, str.tostring(pf, "#.##"), text_color=f_signColor(pf - 1), bgcolor=rBg, text_size=size.small)

    table.cell(perfTbl, 0, 2, "Win %", text_color=dim, bgcolor=rBg, text_size=size.small, text_halign=text.align_left)
    table.cell(perfTbl, 1, 2, str.tostring(winRate, "#.#") + "%", text_color=winRate >= 80 ? #00FF88 : winRate >= 60 ? #FFD700 : #FF4444, bgcolor=rBg, text_size=size.small)
    table.cell(perfTbl, 2, 2, "W / L", text_color=dim, bgcolor=rBg, text_size=size.small)
    table.cell(perfTbl, 3, 2, str.tostring(wins) + " / " + str.tostring(losses), text_color=dim, bgcolor=rBg, text_size=size.small)

    table.cell(perfTbl, 0, 3, "Expect.", text_color=dim, bgcolor=rBg, text_size=size.small, text_halign=text.align_left)
    table.cell(perfTbl, 1, 3, "$" + str.tostring(expectancy, "#.##"), text_color=f_signColor(expectancy), bgcolor=rBg, text_size=size.small)
    table.cell(perfTbl, 2, 3, "MaxDD", text_color=dim, bgcolor=rBg, text_size=size.small)
    table.cell(perfTbl, 3, 3, "$" + str.tostring(maxDD, "#.##"), text_color=#FF4444, bgcolor=rBg, text_size=size.small)

    table.cell(perfTbl, 0, 4, "AvgWin", text_color=dim, bgcolor=rBg, text_size=size.small, text_halign=text.align_left)
    table.cell(perfTbl, 1, 4, "$" + str.tostring(avgWinCalc, "#.##"), text_color=#00FF88, bgcolor=rBg, text_size=size.small)
    table.cell(perfTbl, 2, 4, "AvgLoss", text_color=dim, bgcolor=rBg, text_size=size.small)
    table.cell(perfTbl, 3, 4, "$" + str.tostring(avgLossCalc, "#.##"), text_color=#FF4444, bgcolor=rBg, text_size=size.small)

    table.cell(perfTbl, 0, 5, "Signals", text_color=dim, bgcolor=rBg, text_size=size.small, text_halign=text.align_left)
    table.cell(perfTbl, 1, 5, str.tostring(totalBuySigs) + " " + str.tostring(totalSellSigs), text_color=dim, bgcolor=rBg, text_size=size.small)
    table.cell(perfTbl, 2, 5, "Cycles", text_color=dim, bgcolor=rBg, text_size=size.small)
    table.cell(perfTbl, 3, 5, str.tostring(cycleCount), text_color=dim, bgcolor=rBg, text_size=size.small)

    table.cell(perfTbl, 0, 6, "TotalPnL", text_color=dim, bgcolor=rBg, text_size=size.small, text_halign=text.align_left)
    table.cell(perfTbl, 1, 6, "$" + str.tostring(totalPnl, "#.##"), text_color=f_signColor(totalPnl), bgcolor=rBg, text_size=size.small)
    table.cell(perfTbl, 2, 6, "Unreal.", text_color=dim, bgcolor=rBg, text_size=size.small)
    table.cell(perfTbl, 3, 6, "$" + str.tostring(unrealized, "#.##"), text_color=f_signColor(unrealized), bgcolor=rBg, text_size=size.small)

    table.cell(perfTbl, 0, 7, "ROI", text_color=dim, bgcolor=rBg, text_size=size.small, text_halign=text.align_left)
    table.cell(perfTbl, 1, 7, str.tostring(roiVal, "#.##") + "%", text_color=f_signColor(roiVal), bgcolor=rBg, text_size=size.small)
    table.cell(perfTbl, 2, 7, "DWP", text_color=dim, bgcolor=rBg, text_size=size.small)
    table.cell(perfTbl, 3, 7, str.tostring(dwpVal, "#.#") + "%", text_color=f_signColor(dwpVal), bgcolor=rBg, text_size=size.small)

    table.cell(perfTbl, 0, 8, "PosVal", text_color=dim, bgcolor=rBg, text_size=size.small, text_halign=text.align_left)
    table.cell(perfTbl, 1, 8, "$" + str.tostring(posVal, "#.##"), text_color=dim, bgcolor=rBg, text_size=size.small)
    table.cell(perfTbl, 2, 8, "Cost", text_color=dim, bgcolor=rBg, text_size=size.small)
    table.cell(perfTbl, 3, 8, "$" + str.tostring(totalCost, "#.##"), text_color=dim, bgcolor=rBg, text_size=size.small)

    table.cell(perfTbl, 0, 9, "AvgEntry", text_color=dim, bgcolor=rBg, text_size=size.small, text_halign=text.align_left)
    table.cell(perfTbl, 1, 9, str.tostring(avgEntry, "#.##"), text_color=dim, bgcolor=rBg, text_size=size.small)
    table.cell(perfTbl, 2, 9, "Deployed", text_color=dim, bgcolor=rBg, text_size=size.small)
    table.cell(perfTbl, 3, 9, "$" + str.tostring(totalDeployed, "#.##"), text_color=dim, bgcolor=rBg, text_size=size.small)

    table.cell(perfTbl, 0, 10, "CycBuy", text_color=dim, bgcolor=rBg, text_size=size.small, text_halign=text.align_left)
    table.cell(perfTbl, 1, 10, str.tostring(cycBuyLots) + "/" + str.tostring(i_maxBuys), text_color=#00FFFF, bgcolor=rBg, text_size=size.small)
    table.cell(perfTbl, 2, 10, "CycSell", text_color=dim, bgcolor=rBg, text_size=size.small)
    table.cell(perfTbl, 3, 10, str.tostring(cycSellLots), text_color=dim, bgcolor=rBg, text_size=size.small)

    float roiMax = maxCost > 0 ? realized / maxCost * 100 : 0.0
    table.cell(perfTbl, 0, 11, "MaxCost", text_color=dim, bgcolor=rBg, text_size=size.small, text_halign=text.align_left)
    table.cell(perfTbl, 1, 11, "$" + str.tostring(maxCost, "#.##"), text_color=dim, bgcolor=rBg, text_size=size.small)
    table.cell(perfTbl, 2, 11, "ROI/Max", text_color=dim, bgcolor=rBg, text_size=size.small)
    table.cell(perfTbl, 3, 11, str.tostring(roiMax, "#.##") + "%", text_color=f_signColor(roiMax), bgcolor=rBg, text_size=size.small)

    // Next buy/sell targets
    table.cell(perfTbl, 0, 12, "Nxt Buy", text_color=#1E90FF, bgcolor=hBg, text_size=size.small, text_halign=text.align_left)
    table.cell(perfTbl, 1, 12, "$" + str.tostring(buyBandLevel, "#.##"), text_color=#1E90FF, bgcolor=hBg, text_size=size.small)
    table.cell(perfTbl, 2, 12, "Nxt Sell", text_color=#FFD700, bgcolor=hBg, text_size=size.small)
    table.cell(perfTbl, 3, 12, "$" + str.tostring(sellBandLevel, "#.##"), text_color=#FFD700, bgcolor=hBg, text_size=size.small)

// ─── WEBHOOK ALERTS ─────────────────────────────────────────────────

plot(sellThrotMult, "Sell Throttle Mult", display=display.data_window)
plot(sellThrotCD,   "Sell Throttle CD",   display=display.data_window)
plot(cascBuyScore, "Cascade Score", display=display.data_window)
plot(cascBuyBoost, "Cascade Boost", display=display.data_window)
plot(i_basisGuard ? 1 : 0, "Guard",  display=display.data_window)
plot(i_guardPct,           "Sliver", display=display.data_window)
plot(616.9, "BUILD", display=display.data_window)

alertcondition(buySignal,  "Opus46 Buy",  "Opus46 Buy Signal")
alertcondition(sellSignal, "Opus46 Sell", "Opus46 Sell Signal")

string cType = i_contractType == "auto" ? (str.contains(syminfo.ticker, "USD.P") ? "inverse" : "linear") : i_contractType
string regStr = bullish ? "bullish" : "bearish"
string buyTrigger  = zBuyOverride ? "z-override" : "band-touch"
string sellTrigger = zSellOverride ? "z-override" : "band-touch"

string bPay = '{"passphrase":"' + i_pass + '","symbol":"' + syminfo.ticker + '","side":"Buy","type":"' + cType + '","dollar":' + str.tostring(math.round(buySize, 2)) + ',"sellPct":0,"tier":' + str.tostring(cycBuyLots) + ',"trigger":"' + buyTrigger + '","sigId":"B_' + str.tostring(bar_index) + '","regime":"' + regStr + '","spreadZ":' + str.tostring(math.round(spreadZ, 2)) + ',"pressZ":' + str.tostring(math.round(pressZ, 2)) + ',"dmfi":' + str.tostring(math.round(dmfi, 2)) + ',"cascade":' + str.tostring(cascBuyScore) + ',"phaseBuyBoost":' + str.tostring(math.round(phaseBuyBoost, 2)) + ',"cycBuyLots":' + str.tostring(cycBuyLots) + ',"totalPnL":' + str.tostring(math.round(totalPnl, 2)) + ',"posQty":' + str.tostring(math.round(totalQty, 6)) + ',"price":' + str.tostring(close) + ',"bar_time":' + str.tostring(time) + '}'
string sPay = '{"passphrase":"' + i_pass + '","symbol":"' + syminfo.ticker + '","side":"Sell","type":"' + cType + '","dollar":0,"sellPct":' + str.tostring(math.round(sellPctEff, 2)) + ',"tier":' + str.tostring(cycSellLots) + ',"trigger":"' + sellTrigger + '","sigId":"S_' + str.tostring(bar_index) + '","regime":"' + regStr + '","spreadZ":' + str.tostring(math.round(spreadZ, 2)) + ',"pressZ":' + str.tostring(math.round(pressZ, 2)) + ',"dmfi":' + str.tostring(math.round(dmfi, 2)) + ',"phaseBoost":' + str.tostring(math.round(phaseBoost, 2)) + ',"totalPnL":' + str.tostring(math.round(totalPnl, 2)) + ',"posQty":' + str.tostring(math.round(totalQty, 6)) + ',"price":' + str.tostring(close) + ',"bar_time":' + str.tostring(time) + '}'

if buySignal
    alert(bPay, alert.freq_once_per_bar_close)

if sellSignal
    alert(sPay, alert.freq_once_per_bar_close)
````
