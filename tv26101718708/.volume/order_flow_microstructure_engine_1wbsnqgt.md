# Order Flow Microstructure Engine

- url: https://www.tradingview.com/script/1WBsNQgT-Order-Flow-Microstructure-Engine/
- type: indicator
- pine_id: PUB;d670c11b47fb461aa1b31e47b26e2bbc
- version: 1.0

## Description

# Order Flow Microstructure Engine 

**Order Flow Microstructure Engine** condenses a full stack of order-flow and market-microstructure measures into a single decision: one confidence %, one tier, and one action with entry/stop levels — shown in an adaptive on-chart dashboard. It is built to answer one question on every bar: *are aggressive buyers or aggressive sellers in control, and how convinced should you be?*

This is not a bundle of unrelated indicators placed on one chart. Every component measures a **different facet of the same process** — the buy/sell auction happening inside each bar — and they are combined inside **one probabilistic model**. The reason for the mashup, and how the parts interact, is described below as the guidelines require.

**Why these components are combined (mashup justification)**
No single order-flow measure is reliable alone: raw delta misleads during absorption, CVD drifts, footprint imbalances appear in chop, and toxicity rises at both reversals and breakouts. Because these weaknesses are *partially independent*, fusing the measures correctly cancels noise that any one of them carries. The original element is **how** the fusion is done — not what is plotted.

**How it works (the pipeline)**
1. *Reconstruction.* Lower-timeframe sub-bars are pulled and each is classified buy/sell with a tick-rule cascade (after Lee & Ready). Where the data plan exposes native volume footprint, real bid/ask is used and aggregated into the same price bins. The dashboard always shows whether it is running on reconstructed (`RECON`) or native (`NATIVE`) data.
2. *Factors.* From that base it derives Aggressor Imbalance Ratio, Cumulative Volume Delta, footprint imbalances/POC, auction Value-Area efficiency (acceptance vs rejection), integrated multi-level Order-Flow Imbalance (depth-weighted), VPIN-style flow toxicity, Kyle's lambda price-impact/liquidity, a directional self-exciting (Hawkes) intensity, and a square-root-law absorption measure.
3. *Fusion (the original part).* Each factor is mapped to a probability and combined in Bayesian log-odds. Crucially, the flow-derived factors are **decorrelated before fusion** using an effective-sample-size (design-effect) shrinkage, so factors that are really the *same evidence* (AIR, delta, CVD, footprint, OFI) cannot inflate confidence just by agreeing. Structurally independent factors (auction efficiency, MOC, Hawkes, absorption, cross-instrument) enter at full weight. The posterior is then gated by multi-timeframe and multi-horizon consensus and damped by a regime-thrash (chop) penalty, producing one confidence → a 5-tier ladder → an action.

Without this combination you would get several conflicting opinions; the value is the **correlation-aware fusion** that turns them into one calibrated read.

**How to use it**
- Apply to a liquid instrument on an intraday timeframe (1m–1h). Defaults are tuned for index futures on 5-minute charts with 5-second sub-bars.
- Read the Compact dashboard top-down: ACTION + confidence %, Tier (position-size guidance), Entry/Stop, then CO-FIRE confluence, multi-timeframe and regime/stability. Switch "Table view mode" to Full for a complete factor-by-factor breakdown.
- On-chart triangles mark Tier-1/Tier-2 long/short signals across history; footprint boxes show the intrabar buy/sell distribution.
- For other markets: change the **Market preset** (group 01). Choose **CUSTOM** to set your own session, MOC window, footprint bin sizing and CVD reset — making it usable on any instrument in any market.
- The dashboard theme auto-adapts to a light or dark chart background.

**What makes it original**
Correlation-aware decorrelated Bayesian fusion of order-flow factors; a native-footprint seam that uses real bid/ask when available and transparently falls back to reconstruction; layered multi-horizon + multi-timeframe + cross-instrument confirmation on a microstructure base; and a regime-stability filter that penalizes only genuine directional reversals, not same-direction intensity changes.

**Honesty / limitations**
On most retail feeds, order flow here is reconstructed from lower-timeframe data via the tick rule (~75–80% trade-sign accuracy), not true exchange bid/ask, unless your plan provides native footprint data. The data source is shown in the dashboard. This is an analytic and educational tool, not financial advice and not a guarantee of results.

**Concept credits**
Lee & Ready (trade sign); Kyle (price impact / lambda); Easley, López de Prado & O'Hara (VPIN); Cont, Kukanov & Stoikov and Xu, Gould & Howison (OFI / multi-level OFI); Hawkes and Bacry–Muzy (self-exciting intensity); Almgren and Tóth–Bouchaud (square-root impact law); Kaufman (Efficiency-Ratio adaptation); Steidlmayer (Market Profile / Value Area); Kish (design effect). All Pine implementations are original re-derivations; no external script code is used.

**Disclaimer**
For research and educational purposes only. Nothing here is financial advice. Markets carry risk and past behaviour does not guarantee future results. Always do your own research and manage risk.

## Source Code

````pine
//@version=6
// =============================================================================
//  ORDER FLOW MICROSTRUCTURE ENGINE (OFME)
// -----------------------------------------------------------------------------
//  A single-overlay, multi-factor order-flow & market-microstructure decision
//  engine. It reconstructs intrabar buy/sell activity from lower-timeframe
//  data (or native volume footprint where the data plan supports it), derives
//  a stack of microstructure factors, fuses them with a correlation-aware
//  Bayesian model, and renders one consolidated decision dashboard plus
//  on-chart signals. Works on any liquid instrument and any intraday timeframe.
//
//  WHAT IT COMPUTES (factor stack)
//    • Aggressor Imbalance Ratio (AIR) — tick-rule classified buy/sell pressure
//    • Cumulative Volume Delta (CVD) with selectable reset modes
//    • Volume footprint bins, imbalances, POC, auction Value-Area efficiency
//    • Integrated multi-level Order-Flow Imbalance (depth-weighted)
//    • VPIN-style flow-toxicity and Kyle's lambda (price-impact / liquidity)
//    • Directional self-exciting (Hawkes) intensity & square-root-law absorption
//    • Kaufman Efficiency-Ratio adaptive smoothing; HMM-free 5-state regime
//    • Multi-timeframe & multi-horizon confirmation; cross-instrument confirm
//
//  HOW THE PIECES FIT (why it is a mashup, not a bundle)
//    These are not independent indicators stacked for show — each measures a
//    DIFFERENT facet of the same order-flow process, and they are combined in
//    ONE probabilistic model. Flow-derived factors (AIR/CVD/Δ/footprint/OFI)
//    are intentionally DECORRELATED before fusion (effective-sample-size
//    shrinkage) so that redundant agreement does not inflate confidence, while
//    structurally independent factors (auction efficiency, MOC, Hawkes,
//    absorption, cross-instrument) enter at full weight. The Bayesian posterior
//    is then gated by higher-timeframe and multi-horizon consensus and damped
//    by a regime-thrash (chop) penalty. The result is a single confidence and
//    tier, not seven separate opinions.
//
//  CONCEPT CREDITS (methods this engine operationalizes)
//    Tick-rule / trade sign:        Lee & Ready (1991)
//    Order-Flow Imbalance:          Cont, Kukanov & Stoikov (2014)
//    Multi-level OFI:               Xu, Gould & Howison (2018)
//    Price impact / liquidity λ:    Kyle (1985)
//    Flow toxicity (VPIN):          Easley, López de Prado & O'Hara (2012)
//    Self-exciting intensity:       Hawkes (1971); Bacry, Muzy et al.
//    Square-root impact law:        Almgren et al.; Tóth, Bouchaud et al.
//    Efficiency Ratio adaptation:   Kaufman (KAMA)
//    Market/auction profile:        Steidlmayer (Market Profile), POC/Value Area
//    Bayesian log-odds fusion / effective sample size: Kish design effect.
//  All factor implementations here are original Pine re-derivations; no code
//  from other scripts is used.
//
//  DEFAULTS: tuned for index futures on a 5-minute chart with 5-second
//  sub-bars. Every market-specific value is exposed as an input — switch the
//  "Market preset" to CUSTOM to configure session, MOC window, bin sizing and
//  reset behaviour for any instrument in any market.
//
//  DISCLAIMER: For research and educational purposes only. This is an analytic
//  tool, not financial advice, and not a guarantee of future results. Order
//  flow on most retail feeds is RECONSTRUCTED from lower-timeframe data (tick
//  rule, ~75-80% trade-sign accuracy), not true exchange bid/ask, unless your
//  plan provides native footprint data. Always do your own research and manage
//  risk. © Original work by the script author; released for the TradingView
//  community.
// =============================================================================

indicator(title = "Order Flow Microstructure Engine", shorttitle = "OFM Engine", overlay = true, max_bars_back = 1000, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500, max_polylines_count = 100)

// =============================================================================
//                                  INPUTS
// =============================================================================

gAC = "01 · Data & Market Source"
assetClass = input.string("NIFTY", "Market preset",
     options = ["NIFTY", "NSE_STOCK", "US_FUT", "US_ETF", "US_STOCK", "COMMODITY", "CRYPTO", "CUSTOM"],
     group = gAC,
     tooltip = "Presets session timezone, MOC window, factor weights, footprint bin sizing and CVD reset for a market. The engine runs on whatever symbol your chart shows.\n\nNIFTY (default): index futures (NSE).\nNSE_STOCK / US_STOCK: single stocks.\nUS_FUT / COMMODITY: CME/COMEX/NYMEX futures.\nUS_ETF: US ETFs.\nCRYPTO: perpetuals (24/7).\nCUSTOM: uses YOUR manual values in the Session / MOC / Footprint groups — pick this to configure any instrument in any market.")

acStrictGuard = input.bool(false, "Strict guard: error on incompatible symbols",
     group = gAC,
     tooltip = "OFF (default): the engine runs on any symbol so you can apply it anywhere; a mismatch note appears in the dashboard. ON: refuses to run when the chart symbol does not match the selected preset (useful once you have settled on a market).")

g1 = "02 · Reconstruction Source"
subTfStr = input.string("5S", "Sub-bar timeframe", options = ["1S", "5S", "10S", "15S", "30S"], group = g1, tooltip = "5S = 60 sub-bars per 5m chart bar. Default optimal.")
fpSource = input.string("Reconstruction", "Footprint data source",
     options = ["Reconstruction", "Native (Premium)", "Auto"], group = g1,
     tooltip = "Reconstruction (default): tick-rule from sub-bars, works on any plan — identical to v0.2.10.\nNative (Premium): request.footprint() real bid/ask, Premium/Ultimate only.\nAuto: native when available, else falls back to reconstruction.")
fpNativeTicks = input.int(5, "Native: ticks per footprint row", minval = 1, maxval = 1000, group = g1,
     tooltip = "Row granularity for native footprint (1 tick = syminfo.mintick). Native rows are aggregated into the 'Bins per bar' structure. ~5 for NIFTY; scale up for high-priced instruments.")
fpNativeVA = input.int(70, "Native: Value Area %", minval = 30, maxval = 90, group = g1)
fpNativeImb = input.int(300, "Native: imbalance % (300 = 3x)", minval = 100, maxval = 900, group = g1)

g2 = "03 · Trade Classification"
strongWt = input.float(1.0, "Strong-tick weight", minval = 0.5, maxval = 1.5, step = 0.1, group = g2)
mixedWt  = input.float(0.5, "Mixed-tick weight",  minval = 0.1, maxval = 1.0, step = 0.1, group = g2)

g3 = "04 · Aggressor Imbalance (AIR)"
airLen      = input.int(20, "AIR smoothing window", minval = 5, maxval = 100, group = g3)
airAccLen   = input.int(3,  "AIR accel window",     minval = 2, maxval = 20,  group = g3)
volGateMul  = input.float(0.8, "Volume gate × 20-bar avg", minval = 0.3, maxval = 2.0, step = 0.1, group = g3)

g4 = "11 · Market-On-Close Imbalance"
mocStartH = input.int(14, "MOC window start hour",   minval = 0, maxval = 23, group = g4)
mocStartM = input.int(45, "MOC window start minute", minval = 0, maxval = 59, group = g4)
mocEndH   = input.int(15, "MOC window end hour",     minval = 0, maxval = 23, group = g4)
mocEndM   = input.int(15, "MOC window end minute",   minval = 0, maxval = 59, group = g4)
mocVolMul = input.float(1.5, "MOC volume threshold × 20d avg", minval = 1.0, maxval = 3.0, step = 0.1, group = g4)

g5 = "09 · Flow Toxicity (VPIN)"
vpinBuckets    = input.int(50, "Volume buckets per VPIN window", minval = 20, maxval = 100, group = g5)
vpinSmooth     = input.int(20, "VPIN smoothing window",          minval = 5,  maxval = 50,  group = g5)
vpinMode = input.string("Bar bucket", "VPIN bucketing", options = ["Bar bucket", "Volume clock"], group = g5,
     tooltip = "Bar bucket (default, = v0.2.10): one chart bar = one bucket.\nVolume clock (faithful VPIN): equal-volume buckets accumulated across bars — the real Easley-LdP-O'Hara method.")
vpinBucketVolTarget = input.float(1.0, "Volume-clock bucket size (× 20-bar avg vol)", minval = 0.2, maxval = 5.0, step = 0.1, group = g5,
     tooltip = "Only used in Volume clock mode. Target volume per bucket.")

g6 = "10 · Price Impact (Kyle Lambda)"
lambdaLen     = input.int(20, "Lambda rolling window (bars)", minval = 5, maxval = 100, group = g6)

g7 = "14 · Regime Classifier"
stateBullStrong = input.float(2.0, "STRONG-BULL threshold score",  minval = 1.0, maxval = 4.0, step = 0.25, group = g7)
stateBullMild   = input.float(0.7, "BULL threshold score",         minval = 0.3, maxval = 2.0, step = 0.1,  group = g7)
stateBearMild   = input.float(-0.7, "BEAR threshold score",        minval = -2.0, maxval = -0.3, step = 0.1, group = g7)
stateBearStrong = input.float(-2.0, "STRONG-BEAR threshold score", minval = -4.0, maxval = -1.0, step = 0.25, group = g7)

gHW = "15 · Regime Stability (Thrash)"
hawkesEnable    = input.bool(true,  "Enable thrash suppression",          group = gHW, tooltip = "Dampens confidence when regime is flipping back-and-forth in recent bars (chop/noise detection)")
thrashMode      = input.string("Directional", "Thrash definition", options = ["Directional", "Any change (legacy)"], group = gHW, tooltip = "Directional (default, v0.5 fix): only bull<->bear reversals are chaos; same-direction intensity steps (BULL<->STRONG-BULL) are NOT. Prevents clean trends being flagged CHAOS.\nAny change (legacy v0.4.x): every regime-code change counts as a flip.")
hawkesWindow    = input.int(10,     "Lookback window (bars)",             minval = 5,  maxval = 30,  group = gHW)
hawkesDecay     = input.float(0.85, "Decay factor (older changes weighted less)", minval = 0.5, maxval = 0.99, step = 0.01, group = gHW, tooltip = "Higher = older flips count more, Lower = only recent flips matter")
hawkesMaxThrash = input.float(4.0,  "Max thrash count for full penalty",  minval = 2.0, maxval = 10.0, step = 0.5, group = gHW, tooltip = "Number of decayed regime changes that produces 100% penalty")
hawkesPenalty   = input.float(0.5,  "Max confidence penalty (0-1)",       minval = 0.1, maxval = 0.9, step = 0.05, group = gHW, tooltip = "0.5 = up to 50% confidence reduction when thrash is maxed out")

gER = "13 · Adaptive Smoothing (Efficiency Ratio)"
erEnable        = input.bool(true,  "Enable ER-adapted AIR smoothing",    group = gER, tooltip = "AIR smoothing window adapts based on price efficiency (trend vs chop)")
erPeriod        = input.int(10,     "ER calculation period (bars)",       minval = 5,  maxval = 30,  group = gER)
erFastAlpha     = input.float(0.40, "Fast alpha (trending markets)",      minval = 0.10, maxval = 0.80, step = 0.05, group = gER, tooltip = "EMA alpha when ER is high (strong trend). Higher = more responsive.")
erSlowAlpha     = input.float(0.05, "Slow alpha (choppy markets)",        minval = 0.01, maxval = 0.30, step = 0.01, group = gER, tooltip = "EMA alpha when ER is low (chop). Lower = more stable.")
erThreshTrend   = input.float(0.65, "ER above this = trending",           minval = 0.40, maxval = 0.90, step = 0.05, group = gER, tooltip = "Display threshold for 'trending' label in dashboard")
erThreshChop    = input.float(0.30, "ER below this = chop",               minval = 0.10, maxval = 0.50, step = 0.05, group = gER, tooltip = "Display threshold for 'chop' label in dashboard")

gBA = "16 · Bayesian Fusion"
bayesEnable     = input.bool(true,  "Use Bayesian posterior as confidence", group = gBA, tooltip = "When enabled, confidence = Bayesian posterior. When disabled, falls back to v0.2.4a additive scoring.")
bayesPrior      = input.float(0.50, "Neutral prior P(bull)",              minval = 0.30, maxval = 0.70, step = 0.05, group = gBA, tooltip = "Prior probability of bullish outcome with no information. 0.5 = no bias.")
bayesAirWt      = input.float(0.70, "AIR likelihood weight",              minval = 0.10, maxval = 1.00, step = 0.05, group = gBA, tooltip = "How strongly AIR shifts the posterior. Higher = AIR matters more.")
bayesDeltaWt    = input.float(0.60, "Δ bar likelihood weight",            minval = 0.10, maxval = 1.00, step = 0.05, group = gBA)
bayesCvdWt      = input.float(0.40, "CVD likelihood weight",              minval = 0.10, maxval = 1.00, step = 0.05, group = gBA)
bayesFpWt       = input.float(0.55, "Footprint pattern weight",           minval = 0.10, maxval = 1.00, step = 0.05, group = gBA)
bayesAccelWt    = input.float(0.45, "AIR acceleration weight",            minval = 0.10, maxval = 1.00, step = 0.05, group = gBA)
bayesMocWt      = input.float(0.35, "MOC imbalance weight (last)",        minval = 0.00, maxval = 1.00, step = 0.05, group = gBA)
bayesAuctionWt  = input.float(0.40, "Auction efficiency weight",          minval = 0.00, maxval = 1.00, step = 0.05, group = gBA, tooltip = "How strongly auction efficiency shifts posterior. High efficiency + directional = strong confirmation; low efficiency = trapped flow warning.")
fusionMode      = input.string("Decorrelated", "Fusion mode (Phase 2)", options = ["Legacy", "Decorrelated"], group = gBA, tooltip = "Legacy: v0.3.0 behaviour — flow signals (AIR, Δ, CVD, ΔAIR, FP) summed in log-odds as if independent. Overconfident, since they're all derived from the same signed-flow series.\nDecorrelated (default): shrinks the flow-family's combined contribution by its effective independence (Kish design-effect / equicorrelation model), so redundant agreement no longer inflates confidence. MOC and Auction are left at full weight (more independent).")
fusionCorrLen   = input.int(20, "Decorrelation lookback (bars)", minval = 10, maxval = 100, group = gBA, tooltip = "Rolling window for measuring correlation among flow signals. Only used in Decorrelated mode.")

gAE = "07 · Auction Efficiency"
auctionEnable   = input.bool(true,  "Enable auction efficiency scoring",  group = gAE, tooltip = "Computes Value Area / Total volume per bar. High = acceptance, low = rejection.")
auctionVAPct    = input.float(0.70, "Value Area volume threshold",        minval = 0.50, maxval = 0.85, step = 0.05, group = gAE, tooltip = "Standard market profile = 0.70 (70% of volume). Lower = wider VA, more bars look 'efficient'.")
auctionEffHigh  = input.float(0.65, "Efficient threshold (≥ = healthy)",  minval = 0.50, maxval = 0.80, step = 0.05, group = gAE, tooltip = "Above this, auction is doing good price discovery")
auctionEffLow   = input.float(0.45, "Inefficient threshold (≤ = trapped)", minval = 0.30, maxval = 0.55, step = 0.05, group = gAE, tooltip = "Below this, auction is rejecting prices = potential trap")

gP3 = "12 · Advanced Flow Factors"
// Integrated multi-level OFI (Cont-Kukanov-Stoikov / Xu-Gould-Howison proxy)
ofiEnable     = input.bool(true,  "Enable integrated multi-level OFI",   group = gP3, tooltip = "Depth-weighted order-flow imbalance across footprint rows. Flow near the close (best levels) weighted highest, deeper levels decay (Xu-Gould-Howison). Uses real bid/ask when native footprint is on.")
ofiDepthDecay = input.float(1.5,  "OFI depth decay (bins)",              minval = 0.5, maxval = 6.0, step = 0.5, group = gP3, tooltip = "Exponential decay scale (in bins) for level weighting. Lower = only near-close levels matter.")
bayesOfiWt    = input.float(0.55, "OFI likelihood weight",               minval = 0.00, maxval = 1.00, step = 0.05, group = gP3)
// Directional Hawkes intensity (Bacry-Muzy self-exciting)
hawkesIntEnable = input.bool(true,  "Enable directional Hawkes intensity", group = gP3, tooltip = "Self-exciting buy/sell event intensity. Clustered same-direction delta bursts excite same-direction intensity → momentum-clustering signal.")
hawkesIntDecay  = input.float(0.80, "Hawkes intensity decay",             minval = 0.50, maxval = 0.98, step = 0.02, group = gP3, tooltip = "Exponential kernel decay per bar. Higher = intensity persists longer.")
hawkesEventMult = input.float(1.2,  "Event threshold (× avg |Δ|)",        minval = 0.5, maxval = 3.0, step = 0.1, group = gP3, tooltip = "A bar is a directional 'event' when |barDelta| exceeds this × rolling average |barDelta|.")
bayesHawkesWt   = input.float(0.45, "Hawkes intensity weight",            minval = 0.00, maxval = 1.00, step = 0.05, group = gP3)
// Square-root-law absorption (Almgren / Tóth-Bouchaud)
absorbEnable  = input.bool(true,  "Enable √-law absorption",             group = gP3, tooltip = "Compares realized impact to the square-root-law prediction impact ∝ √(|Δ|/V). Realized << predicted = passive absorption (flow soaked up, reversal candidate). Realized >> predicted = fragile/low-liquidity expansion.")
sqrtLawY      = input.float(1.0,  "√-law impact coefficient Y",          minval = 0.2, maxval = 3.0, step = 0.1, group = gP3, tooltip = "Scales predicted impact = Y · ATR · √(|barDelta| / avgVol). Calibrate so typical absorption ratio ≈ 1.")
absorbLow     = input.float(0.6,  "Absorption ratio low (≤ = absorbed)", minval = 0.2, maxval = 0.9, step = 0.05, group = gP3)
absorbHigh    = input.float(1.6,  "Absorption ratio high (≥ = fragile)", minval = 1.1, maxval = 3.0, step = 0.1, group = gP3)
bayesAbsorbWt = input.float(0.40, "Absorption weight",                   minval = 0.00, maxval = 1.00, step = 0.05, group = gP3)
showSecP3     = input.bool(true,  "▸ Show Phase 3 dashboard section",    group = gP3, tooltip = "OFI / Hawkes-dir / Absorption rows. Off by default to reduce clutter.")

gP4 = "19 · Multi-Horizon & Cross-Instrument"
// Multi-horizon posterior consensus (Kolm-Turiel-Westray multi-horizon spirit)
mhEnable      = input.bool(true,  "Enable multi-horizon consensus",      group = gP4, tooltip = "Blends the Bayesian posterior across short/medium/long horizons (EMA). When all three horizons agree directionally, confidence gets a bonus; when they split, a penalty. A time-domain analogue of CO-FIRE.")
mhMedLen      = input.int(8,   "Medium horizon (bars)",                  minval = 3,  maxval = 30,  group = gP4)
mhLongLen     = input.int(21,  "Long horizon (bars)",                    minval = 10, maxval = 80,  group = gP4)
mhAgreeBonus  = input.float(0.10, "Consensus bonus (all agree)",         minval = 0.00, maxval = 0.30, step = 0.01, group = gP4)
mhSplitPenalty= input.float(0.10, "Split penalty (horizons disagree)",   minval = 0.00, maxval = 0.30, step = 0.01, group = gP4)
// Cross-instrument confirmation (NIFTY <-> BANKNIFTY lead-lag)
crossEnable   = input.bool(true,  "Enable cross-instrument confirmation", group = gP4, tooltip = "Fetches a flow proxy from a paired instrument (e.g. BANKNIFTY when you're on NIFTY) and checks directional agreement. Agreement confirms; divergence warns.")
crossSymbol   = input.symbol("NSE:BANKNIFTY1!", "Paired instrument",     group = gP4, tooltip = "Set to the OTHER index than the one charted. On NIFTY1! use BANKNIFTY1! and vice-versa. Must be a tradable correlated instrument.")
crossThresh   = input.float(0.25, "Cross direction threshold",           minval = 0.05, maxval = 0.60, step = 0.05, group = gP4, tooltip = "How strong the cross-instrument flow proxy must be to count as directional.")
bayesXinstWt  = input.float(0.40, "Cross-instrument weight",             minval = 0.00, maxval = 1.00, step = 0.05, group = gP4)
showSecP4     = input.bool(true,  "▸ Show Phase 4 dashboard section",    group = gP4, tooltip = "Multi-horizon consensus + cross-instrument rows. Off by default.")

gSW = "08 · Liquidity Sweeps"
sweepEnable     = input.bool(true,  "Enable sweep detection",             group = gSW, tooltip = "Detects when price runs above/below recent pivots and reclaims within same bar = liquidity sweep + reversal candidate")
sweepLookback   = input.int(20,     "Sweep pivot lookback (bars)",        minval = 5,  maxval = 50, group = gSW, tooltip = "Search window for the recent pivot whose level got swept")
sweepVolMul     = input.float(1.3,  "Volume threshold (× 20-bar avg)",    minval = 1.0, maxval = 3.0, step = 0.1, group = gSW, tooltip = "Volume spike required to confirm sweep (not just minor wick poke)")
sweepReclaimPct = input.float(0.4,  "Min reclaim (% of wick)",            minval = 0.2, maxval = 0.8, step = 0.05, group = gSW, tooltip = "How much of the sweep wick must be reclaimed to count as a valid sweep (0.4 = close back below 60% of the wick high)")
sweepShowMarker = input.bool(true,  "Show ⚡ sweep markers on chart",      group = gSW)
sweepMarkerSize = input.string("Small", "Marker size",                    options = ["Tiny", "Small", "Normal", "Large"], group = gSW)

gCF = "17 · Confluence (CO-FIRE)"
coFireEnable    = input.bool(true,  "Enable CO-FIRE detection",           group = gCF, tooltip = "Detects when multiple microstructure dimensions agree directionally. Adds bonus to confidence.")
coFireBonus     = input.float(0.10, "Confidence bonus per dim aligned",   minval = 0.02, maxval = 0.20, step = 0.01, group = gCF, tooltip = "Each dimension agreeing adds this much to final confidence (capped at 30% total)")
coFireShowBadge = input.bool(true,  "Show CO-FIRE badge on chart",        group = gCF, tooltip = "Small label appears above bars where 3+ dimensions align")

g5T = "20 · Confidence Tiers"
tier5Enable     = input.bool(true,  "Use 5-tier confidence ladder",       group = g5T, tooltip = "Maps confidence to Tier 1 (highest) → Tier 5 (lowest). Each tier suggests position size guidance.")
tier1Min        = input.float(0.85, "Tier 1 min confidence",              minval = 0.70, maxval = 0.95, step = 0.05, group = g5T, tooltip = "Top tier: full size")
tier2Min        = input.float(0.70, "Tier 2 min confidence",              minval = 0.55, maxval = 0.85, step = 0.05, group = g5T, tooltip = "Strong: 75% size")
tier3Min        = input.float(0.55, "Tier 3 min confidence",              minval = 0.40, maxval = 0.70, step = 0.05, group = g5T, tooltip = "Standard: 50% size")
tier4Min        = input.float(0.40, "Tier 4 min confidence",              minval = 0.25, maxval = 0.55, step = 0.05, group = g5T, tooltip = "Reduced: 25% size")
// Below tier 4 = Tier 5 / NO TRADE

gPV = "22 · Pivot-Anchored Levels"
pivotEnable     = input.bool(true,  "Use pivot-anchored entries",         group = gPV, tooltip = "Replaces mechanical buffer with nearest swing high/low. Falls back to mechanical when no recent pivot exists.")
pivotLeft       = input.int(5,      "Pivot left bars",                    minval = 2,  maxval = 20, group = gPV, tooltip = "Bars on left of pivot for confirmation")
pivotRight      = input.int(2,      "Pivot right bars",                   minval = 1,  maxval = 10, group = gPV, tooltip = "Bars on right (already confirmed at this lookback)")
pivotMaxLookback = input.int(30,    "Pivot search window (bars)",         minval = 10, maxval = 100, group = gPV, tooltip = "How far back to look for a usable pivot before falling back to mechanical buffer")

gDS = "27 · Dashboard"
viewMode        = input.string("Compact", "Table view mode", options = ["Compact", "Full"], group = gDS, tooltip = "Compact (default): the essential decision rows — ACTION, Tier, Entry/Stop, CO-FIRE, MTF, Regime, Stability, Top driver.\nFull: expands every section — BQS breakdown, pressure, institutional, advanced factors, footprint, auction/sweeps and reasoning.")
chartSignalMode = input.string("Strong only", "Chart signal density",
     options = ["Strong only", "All signals"],
     group = gDS,
     tooltip = "Strong only (default): CO-FIRE/sweep/imbalance markers and entry/stop lines render only on Tier 1/2 setups with confluence. Reduces chart clutter to actually-strong signals (~5-15% of bars).\nAll signals: legacy v0.2.7 behavior, may show markers on majority of bars.")
histSignals = input.bool(true, "Full-history signal markers (all bars)", group = gDS, tooltip = "Plots Tier 1/2 buy/sell triangles and CO-FIRE dots on EVERY historical bar using plotshape (no drawing-object cap). The label-based CF badges / entry-stop lines are still limited to recent bars by Pine's 500-object ceiling; these markers are not. Turn off for a cleaner chart.")
histSignalTiers = input.string("Tier 1+2", "History marker selectivity", options = ["Tier 1 only", "Tier 1+2", "Tier 1-3"], group = gDS, tooltip = "Which tiers get a full-history marker. Looser = more markers further back.")

showSecAction   = input.bool(true,  "▸ Action / Decision",     group = gDS, tooltip = "Top action row + plan + tier + entry/stop")
showSecRegime   = input.bool(true,  "▸ Regime + Stability",    group = gDS)
showSecBQS      = input.bool(true,  "▸ Confidence Breakdown (BQS)", group = gDS, tooltip = "Per-component contribution to Bayesian posterior")
showSecPressure = input.bool(true,  "▸ Pressure (Δ, CVD, AIR)",     group = gDS)
showSecInst     = input.bool(true,  "▸ Institutional (MOC, VPIN, λ)", group = gDS, tooltip = "OFF by default — open when needed")
showSecFP       = input.bool(true,  "▸ Footprint Pattern",     group = gDS)
showSecSweep    = input.bool(true,  "▸ Auction + Sweeps",      group = gDS, tooltip = "Auction efficiency + recent sweep status")
showSecReason   = input.bool(true,  "▸ Reasoning",             group = gDS)

gMTF = "18 · Multi-Timeframe Confluence"
mtfMode   = input.string("Aligned required", "MTF mode",
     options = ["Aligned required", "Aligned preferred", "Ignore MTF"],
     group = gMTF,
     tooltip = "Aligned required (default): forces WAIT when higher TF posterior contradicts current TF direction. Prevents counter-trend trades.\nAligned preferred: allows trade but downgrades confidence on disagreement.\nIgnore MTF: legacy behavior, no MTF gate.")
mtfAuto   = input.bool(true, "Auto-select HTF (3× current TF)",
     group = gMTF,
     tooltip = "When ON: auto-maps current TF to a higher TF (1m→5m, 5m→15m, 15m→60m, etc.)\nWhen OFF: uses the manual HTF override below.")
mtfManual = input.timeframe("60", "Manual HTF override",
     group = gMTF,
     tooltip = "Only used when Auto-select is OFF. Common values: '15' (15m), '60' (1h), '240' (4h), 'D' (daily).")
mtfBullThresh = input.float(0.55, "HTF posterior > this = BULL",
     minval = 0.50, maxval = 0.70, step = 0.01, group = gMTF,
     tooltip = "Posterior threshold for HTF directional classification. 0.55 = mild bull required.")
mtfBearThresh = input.float(0.45, "HTF posterior < this = BEAR",
     minval = 0.30, maxval = 0.50, step = 0.01, group = gMTF,
     tooltip = "Posterior threshold for HTF directional classification. 0.45 = mild bear required.")
mtfAlignedBonus    = input.float(0.15, "Confidence bonus when aligned",
     minval = 0.00, maxval = 0.30, step = 0.05, group = gMTF,
     tooltip = "Multiplier added to confidence when current TF and HTF agree directionally.")
mtfDisagreeDownweight = input.float(0.6, "Confidence multiplier when disagreed (preferred mode)",
     minval = 0.2, maxval = 0.9, step = 0.05, group = gMTF,
     tooltip = "Used in 'Aligned preferred' mode: confidence multiplied by this factor on disagreement.")

mtf2Enable = input.bool(true, "Enable HTF2 (second higher TF)",
     group = gMTF,
     tooltip = "When ON: a second higher TF is checked. Strict mode requires NEITHER HTF to contradict. Catches 'intraday bounce inside larger downtrend' setups.\nWhen OFF: only HTF1 is checked (legacy v0.2.9 behavior).")
mtf2Auto = input.bool(true, "Auto-select HTF2 (≈12× current TF)",
     group = gMTF,
     tooltip = "Auto-maps: 5m→60m, 15m→4h, 30m→4h, 1h→D, etc.")
mtf2Manual = input.timeframe("240", "Manual HTF2 override",
     group = gMTF,
     tooltip = "Only used when HTF2 Auto-select is OFF.")

g8 = "21 · Decision & Entries"
entryBuffer    = input.float(8.0,  "Entry buffer (points above/below ref)", minval = 1.0, maxval = 50.0, step = 0.5, group = g8, tooltip = "Distance from reference price for entry trigger")
invalidBuffer  = input.float(15.0, "Invalidation buffer (points)",          minval = 5.0, maxval = 100.0, step = 1.0, group = g8, tooltip = "Stop-loss distance from current price")
minConfidence  = input.float(0.4, "Minimum confidence to call ACTION",      minval = 0.2, maxval = 0.9, step = 0.05, group = g8, tooltip = "Below this confidence, action shows WAIT")

gFP = "06 · Volume Footprint"
showFootprint  = input.bool(true, "Render footprint boxes on bars", group = gFP)
fpBars         = input.int(50, "History depth (bars to render)",     minval = 10, maxval = 100, group = gFP, tooltip = "Number of recent bars showing footprint boxes")
fpBins         = input.int(8,  "Bins per bar",                       minval = 4,  maxval = 14,  group = gFP, tooltip = "Number of price bins per bar's footprint")
fpBinMode      = input.string("By bar range", "Bin sizing method",   options = ["By bar range", "By percentage"], group = gFP, tooltip = "Bar range = bin size = (high-low)/bins. Percentage = bin size = pct of price (consistent width across bars).")
fpBinPct       = input.float(0.05, "Bin width as % of price",        minval = 0.01, maxval = 0.50, step = 0.01, group = gFP, tooltip = "Only used if Bin sizing = By percentage. 0.05% on NIFTY 24000 ≈ 12-point bins.")
fpImbThresh    = input.float(0.65, "Imbalance threshold (% one-side)", minval = 0.55, maxval = 0.85, step = 0.05, group = gFP, tooltip = "Min one-side dominance to mark as imbalance bin (▲▼)")
fpMinVol       = input.float(0.3, "Min bar volume (× 20-bar avg) to render", minval = 0.1, maxval = 1.0, step = 0.1, group = gFP, tooltip = "Skip footprint on low-volume bars (lunch lull, etc.)")
fpAlphaMax     = input.int(28, "Box max opacity (lower = more opaque)", minval = 10, maxval = 80, group = gFP, tooltip = "Transparency for the highest-volume bins (lower = more solid / vivid).")
fpAlphaMin     = input.int(74, "Box min opacity (lower = more opaque)", minval = 50, maxval = 95, group = gFP, tooltip = "Transparency for the lowest-volume bins.")
fpBoxWidthPct  = input.int(80, "Box width % of bar spacing",           minval = 40, maxval = 100, group = gFP, tooltip = "How wide each footprint box is within the bar")
fpShowPoc      = input.bool(true, "Highlight POC (peak vol bin)",     group = gFP, tooltip = "Draw distinct yellow border on the highest-volume bin per bar")
fpPocColor     = input.color(#FFD600, "POC border color",             group = gFP)

gDM = "24 · Display Mode"
displayMode = input.string("Footprint Only", "Visual style",
     options = ["Footprint Only", "Compact (delta candles only)", "Both (dense)"],
     group = gDM,
     tooltip = "Footprint Only = boxes inside bars. Compact = embedded delta-fill candles, no boxes. Both = dense, only useful on wide bars and large screens.")

gDC = "25 · Delta Candles"
showDeltaCandle = input.bool(true, "Show delta-fill inside body",     group = gDC, tooltip = "Inner-fill candle showing delta as % of body. Strong colored fill = strong delta backing the move.")
dcStyle         = input.string("Half body", "Fill style",             options = ["Half body", "Full body"], group = gDC, tooltip = "Half = centered around midpoint, Full = anchored at min/max of body")
dcDivAlt        = input.bool(true, "Use divergence colors when delta contradicts price", group = gDC)
dcBullCol       = input.color(#00D68F, "Bull delta",      group = gDC, inline = "dc1")
dcBearCol       = input.color(#FF3D71, "Bear delta",      group = gDC, inline = "dc1")
dcBullDivCol    = input.color(#FFB800, "Bull-but-Δ-sell", group = gDC, inline = "dc2", tooltip = "Green candle but negative delta — sellers absorbed price up. Possible exhaustion.")
dcBearDivCol    = input.color(#A020F0, "Bear-but-Δ-buy",  group = gDC, inline = "dc2", tooltip = "Red candle but positive delta — buyers absorbed price down. Possible reversal.")

gDV = "23 · Price-Delta Divergence"
showDivergence  = input.bool(true, "Detect price-delta divergence",   group = gDV, tooltip = "Flags bars where signed delta direction contradicts candle direction.")
colorDivBars    = input.bool(true, "Color bar background on divergence", group = gDV)
divBgColor      = input.color(color.new(#FFB800, 88), "Divergence bg tint", group = gDV)

gRS = "05 · Cumulative Volume Delta"
cvdResetMode = input.string("Session start", "When to reset CVD",
     options = ["Never", "Session start", "Higher TF (auto)", "Fixed higher TF", "Fixed time of day", "Trend change"],
     group = gRS,
     tooltip = "Controls when cumulative volume delta resets to zero. Session start is default for intraday NIFTY trading.")
cvdFixedTf      = input.timeframe("D", "Fixed higher TF (if selected)", group = gRS)
cvdResetHour    = input.int(9,  "Fixed reset hour",   minval = 0, maxval = 23, group = gRS)
cvdResetMin     = input.int(15, "Fixed reset minute", minval = 0, maxval = 59, group = gRS)
cvdTrendLen     = input.int(14, "Trend (Supertrend) length", minval = 5, maxval = 50, group = gRS)
cvdTrendMul     = input.float(3.0, "Trend (Supertrend) ATR multiplier", minval = 1.0, maxval = 6.0, step = 0.25, group = gRS)

g9 = "26 · Session"
sessTZ    = input.string("Asia/Kolkata", "Timezone", options = ["Asia/Kolkata", "America/New_York", "Europe/London", "UTC"], group = g9)

g10 = "28 · Visual & Colors"
showDash     = input.bool(true,  "Show Decision Table",         group = g10)
showSignals  = input.bool(true,  "Show entry/invalidation lines on chart", group = g10)
showRegimeBg = input.bool(true,  "Tint background by regime",   group = g10)
tablePos     = input.string("top_right", "Table position", options = ["top_right", "top_left", "bottom_right", "bottom_left", "middle_right", "middle_left"], group = g10)
tableSize    = input.string("small", "Table text size", options = ["tiny", "small", "normal"], group = g10)

bullClr     = input.color(#00ff9d, "Bull color",     group = g10, inline = "c1")
bearClr     = input.color(#ff3d71, "Bear color",     group = g10, inline = "c1")
neuClr      = input.color(#8B949E, "Neutral color",  group = g10, inline = "c1")
strongBull  = input.color(#00ff9d, "Strong bull",    group = g10, inline = "c2")
strongBear  = input.color(#ff3d71, "Strong bear",    group = g10, inline = "c2")

// =============================================================================
//                    ASSET CLASS DETECTION & PRESET RESOLUTION
// =============================================================================
// User explicitly picks asset class. We validate the chart matches that class,
// then derive ALL preset-dependent values (TZ, MOC times, Bayesian weights,
// FP bin %, CVD reset mode) from the user's selection.
//
// The asset class detection here is a SOFT MATCH used only for warnings —
// the user's explicit selection is authoritative. We refuse to run if the
// symbol clearly doesn't match the asset class category (strict guard mode).

chartTfSec = timeframe.in_seconds()

// --- Symbol fingerprinting for soft-match validation ---
string symRoot = syminfo.root  // e.g. "NIFTY" for NIFTY1!, empty for non-futures
string symType = syminfo.type  // "stock", "futures", "fund", "crypto", "forex", "index", "economic", "dr"
string symPrefix = syminfo.prefix  // exchange prefix e.g. "NSE", "NASDAQ", "BINANCE"
string symTicker = syminfo.ticker
bool isFut    = symType == "futures"
bool isStock  = symType == "stock" or symType == "dr"
bool isFund   = symType == "fund"
bool isCryptoTV = symType == "crypto"
bool isForex  = symType == "forex"
bool isIndex  = symType == "index"
bool isEcon   = symType == "economic"

// --- Detect "invalid" asset categories (excluded by design) ---
bool isExcludedClass = isForex or isIndex or isEcon or symType == "options"

// --- Validate chart symbol matches the user's selected asset class ---
bool classMatches = false
string classMismatchMsg = ""
if assetClass == "NIFTY"
    classMatches := isFut and (symPrefix == "NSE" or symPrefix == "BSE")
    classMismatchMsg := classMatches ? "" : "NIFTY preset expects NSE/BSE index futures (e.g. NIFTY1!, BANKNIFTY1!). Current symbol does not match."
else if assetClass == "NSE_STOCK"
    classMatches := isStock and (symPrefix == "NSE" or symPrefix == "BSE")
    classMismatchMsg := classMatches ? "" : "NSE_STOCK preset expects NSE/BSE single stocks (e.g. RELIANCE, INFY)."
else if assetClass == "US_FUT"
    classMatches := isFut and (symPrefix == "CME" or symPrefix == "CME_MINI" or symPrefix == "CBOT" or symPrefix == "NYMEX" or symPrefix == "COMEX")
    classMismatchMsg := classMatches ? "" : "US_FUT preset expects CME/CBOT futures (e.g. ES1!, NQ1!, ZN1!)."
else if assetClass == "US_ETF"
    classMatches := isFund and (symPrefix == "NYSE" or symPrefix == "NASDAQ" or symPrefix == "AMEX" or symPrefix == "ARCA")
    classMismatchMsg := classMatches ? "" : "US_ETF preset expects US-listed ETFs (e.g. SPY, QQQ, IWM)."
else if assetClass == "US_STOCK"
    classMatches := isStock and (symPrefix == "NYSE" or symPrefix == "NASDAQ" or symPrefix == "AMEX")
    classMismatchMsg := classMatches ? "" : "US_STOCK preset expects US-listed single stocks (e.g. AAPL, TSLA)."
else if assetClass == "COMMODITY"
    classMatches := isFut and (symPrefix == "COMEX" or symPrefix == "NYMEX" or symPrefix == "CBOT" or symPrefix == "ICEUS")
    classMismatchMsg := classMatches ? "" : "COMMODITY preset expects COMEX/NYMEX/CBOT futures (e.g. GC1!, CL1!, SI1!)."
else if assetClass == "CRYPTO"
    classMatches := isCryptoTV or (isFut and (symPrefix == "BINANCE" or symPrefix == "BYBIT" or symPrefix == "OKX"))
    classMismatchMsg := classMatches ? "" : "CRYPTO preset expects perpetuals from Binance/Bybit/OKX (e.g. BTCUSDT.P)."
else if assetClass == "CUSTOM"
    classMatches := true  // user-configured: run on any instrument, no preset enforcement
    classMismatchMsg := ""

if barstate.islast
    if chartTfSec < 60 or chartTfSec > 3600
        runtime.error("OFME: chart timeframe must be between 1m and 1h. Current: " + timeframe.period)
    if acStrictGuard and assetClass != "CUSTOM" and isExcludedClass
        runtime.error("OFME: this symbol type (forex/options/spot index/economic) produces unreliable reconstructed flow. Select the CUSTOM preset to override, or disable Strict guard.")
    if acStrictGuard and assetClass != "CUSTOM" and not classMatches
        runtime.error("OFME: " + classMismatchMsg + " Switch the chart symbol, change the Market preset (or use CUSTOM), or disable Strict guard.")

// TF above 15m enters DEGRADED MODE — sub-bar dependent features unreliable
bool tfDegraded = chartTfSec > 900

// =============================================================================
//                          PRESET RESOLUTION
// =============================================================================
// Effective values derived from asset class selection.
// These shadow the corresponding raw inputs in the calculations below.

// Session timezone
string sessTZ_eff = sessTZ  // default to user's input
if assetClass == "NIFTY" or assetClass == "NSE_STOCK"
    sessTZ_eff := "Asia/Kolkata"
else if assetClass == "US_FUT" or assetClass == "US_ETF" or assetClass == "US_STOCK" or assetClass == "COMMODITY"
    sessTZ_eff := "America/New_York"
else if assetClass == "CRYPTO"
    sessTZ_eff := "UTC"

// MOC window times (24/7 markets get a never-true window)
int mocStartH_eff = mocStartH
int mocStartM_eff = mocStartM
int mocEndH_eff   = mocEndH
int mocEndM_eff   = mocEndM
bool mocEnabled_eff = true  // false for crypto (24/7)
if assetClass == "NIFTY" or assetClass == "NSE_STOCK"
    mocStartH_eff := 15
    mocStartM_eff := 15
    mocEndH_eff   := 15
    mocEndM_eff   := 30
else if assetClass == "US_FUT" or assetClass == "US_ETF" or assetClass == "US_STOCK"
    mocStartH_eff := 15
    mocStartM_eff := 45
    mocEndH_eff   := 16
    mocEndM_eff   := 0
else if assetClass == "COMMODITY"
    mocStartH_eff := 14
    mocStartM_eff := 25
    mocEndH_eff   := 14
    mocEndM_eff   := 30
else if assetClass == "CRYPTO"
    mocEnabled_eff := false
    mocStartH_eff := 0
    mocStartM_eff := 0
    mocEndH_eff   := 0
    mocEndM_eff   := 0

// Bayesian weights (per asset class characteristics)
float bayesAirWt_eff   = bayesAirWt
float bayesCvdWt_eff   = bayesCvdWt
float bayesMocWt_eff   = bayesMocWt
if assetClass == "NIFTY"
    bayesAirWt_eff := 0.70
    bayesCvdWt_eff := 0.40
    bayesMocWt_eff := 0.35
else if assetClass == "NSE_STOCK"
    bayesAirWt_eff := 0.65
    bayesCvdWt_eff := 0.45
    bayesMocWt_eff := 0.30
else if assetClass == "US_FUT"
    bayesAirWt_eff := 0.70
    bayesCvdWt_eff := 0.40
    bayesMocWt_eff := 0.35
else if assetClass == "US_ETF"
    bayesAirWt_eff := 0.65
    bayesCvdWt_eff := 0.45
    bayesMocWt_eff := 0.30
else if assetClass == "US_STOCK"
    bayesAirWt_eff := 0.60
    bayesCvdWt_eff := 0.45
    bayesMocWt_eff := 0.25
else if assetClass == "COMMODITY"
    bayesAirWt_eff := 0.65
    bayesCvdWt_eff := 0.45
    bayesMocWt_eff := 0.30
else if assetClass == "CRYPTO"
    bayesAirWt_eff := 0.55
    bayesCvdWt_eff := 0.55
    bayesMocWt_eff := 0.0

// Footprint bin % (scaled to asset's typical price range / volatility)
float fpBinPct_eff = fpBinPct
if assetClass == "NIFTY" or assetClass == "US_FUT" or assetClass == "COMMODITY" or assetClass == "US_ETF"
    fpBinPct_eff := 0.05
else if assetClass == "NSE_STOCK" or assetClass == "US_STOCK" or assetClass == "CRYPTO"
    fpBinPct_eff := 0.08

// CVD reset mode (24/7 markets need HTF reset instead of session reset)
string cvdResetMode_eff = cvdResetMode
if assetClass == "CRYPTO"
    cvdResetMode_eff := "Higher TF (auto)"

// =============================================================================
//                            SUB-BAR DATA REQUEST
// =============================================================================

[subOpens, subHighs, subLows, subCloses, subVols] = request.security_lower_tf(syminfo.tickerid, subTfStr, [open, high, low, close, volume], calc_bars_count = 200000)

// =============================================================================
//                       TICK-RULE CLASSIFICATION (CORE)
// =============================================================================
// 7-priority classifier (improvement over v0.2.2's 5-case):
//   1. close > open       → buy (full weight)
//   2. close < open       → sell (full weight)
//   3. close > prev close → buy (uptick rule)
//   4. close < prev close → sell (downtick rule)
//   5. prev sub-bar was buy → continue buy (momentum carry — NEW)
//   6. prev sub-bar was sell → continue sell (momentum carry — NEW)
//   7. close == open      → buy (final fallback)
// This matches the official TradingView CVD reference implementation.

float barDelta     = 0.0
float buyVolBar    = 0.0
float sellVolBar   = 0.0
int   nSubBars     = na(subCloses) ? 0 : array.size(subCloses)
int   nClassified  = 0

// Determine effective bin size based on user's chosen method
float barRange = high - low
float binSize  = barRange > 0 ? barRange / fpBins : syminfo.mintick
if fpBinMode == "By percentage"
    binSize := math.max(syminfo.mintick, close * fpBinPct_eff / 100.0)
// Note: when bin sizing is percentage-based and bar range is small,
// some bins may extend beyond the bar — we handle this in render block

// Footprint per-bar bin arrays (sized once, cleared and refilled each bar)
var array<float> binBuyVol  = array.new<float>(fpBins, 0.0)
var array<float> binSellVol = array.new<float>(fpBins, 0.0)
for j = 0 to fpBins - 1
    array.set(binBuyVol,  j, 0.0)
    array.set(binSellVol, j, 0.0)

if nSubBars > 0
    float prevSubClose = array.get(subCloses, 0)
    // Track previous sub-bar's classification sign for momentum-carry rule
    float prevSubSign = 0.0
    for i = 0 to nSubBars - 1
        float o = array.get(subOpens,  i)
        float h = array.get(subHighs,  i)
        float l = array.get(subLows,   i)
        float c = array.get(subCloses, i)
        float v = array.get(subVols,   i)

        if v > 0 and not na(c) and not na(prevSubClose) and not na(o) and not na(h) and not na(l)
            float rng = h - l
            float clv = rng > 0 ? ((c - l) - (h - c)) / rng : 0.0

            // 7-priority cascade
            float sign = 0.0
            if c > o
                sign := strongWt
            else if c < o
                sign := -strongWt
            else if c > prevSubClose
                sign := strongWt
            else if c < prevSubClose
                sign := -strongWt
            else if prevSubSign > 0
                sign := mixedWt
            else if prevSubSign < 0
                sign := -mixedWt
            else
                // Final fallback: CLV-weighted (was zero-tick in v0.2.2)
                sign := math.abs(clv) > 0.1 ? mixedWt * clv : 0.0

            float sv = sign * v
            barDelta := barDelta + sv
            if sv > 0
                buyVolBar  := buyVolBar  + math.abs(sv)
            else if sv < 0
                sellVolBar := sellVolBar + math.abs(sv)

            // ── FOOTPRINT BIN ALLOCATION ──
            if barRange > 0 and binSize > 0
                float subTypicalPx = (h + l + c) / 3.0
                float distFromLow  = subTypicalPx - low
                int binIdx = int(math.floor(distFromLow / binSize))
                binIdx := math.max(0, math.min(fpBins - 1, binIdx))
                float absV = math.abs(sv)
                if sv > 0
                    array.set(binBuyVol,  binIdx, array.get(binBuyVol,  binIdx) + absV)
                else if sv < 0
                    array.set(binSellVol, binIdx, array.get(binSellVol, binIdx) + absV)

            nClassified := nClassified + 1
            prevSubClose := c
            prevSubSign  := sign

bool barDataOk = nSubBars > 0 and (nClassified / float(nSubBars)) >= 0.3

// =============================================================================
//           NATIVE FOOTPRINT OVERRIDE (v0.3 — request.footprint seam)
// =============================================================================
// When enabled + available, replaces tick-rule reconstruction with real
// bid/ask footprint. Native rows are aggregated into the SAME fpBins structure,
// so ALL downstream logic (patterns, auction, render, EXP) is unchanged.
// Conditional call: when fpSource = "Reconstruction", request.footprint() is
// never invoked — behaviour is byte-for-byte the legacy reconstruction path.
// Falls back to recon automatically when native returns na (non-premium plan
// or no data for the bar).
bool fpWantNative = fpSource == "Native (Premium)" or fpSource == "Auto"
footprint fpObj = fpWantNative ? request.footprint(fpNativeTicks, fpNativeVA, fpNativeImb) : na
string fpDataSource = "RECON"
if not na(fpObj)
    float nBuy  = fpObj.buy_volume()
    float nSell = fpObj.sell_volume()
    float nDel  = fpObj.delta()
    if not na(nBuy) and not na(nSell)
        // Override canonical flow with real bid/ask totals
        buyVolBar  := nBuy
        sellVolBar := nSell
        barDelta   := nDel
        // Re-zero bins, then refill from native rows mapped into fpBins by price
        for j = 0 to fpBins - 1
            array.set(binBuyVol,  j, 0.0)
            array.set(binSellVol, j, 0.0)
        array<volume_row> fpRows = fpObj.rows()
        int nFpRows = array.size(fpRows)
        if nFpRows > 0 and barRange > 0 and binSize > 0
            for ri = 0 to nFpRows - 1
                volume_row vr = array.get(fpRows, ri)
                float rMid = (vr.up_price() + vr.down_price()) / 2.0
                int bidx = int(math.floor((rMid - low) / binSize))
                bidx := math.max(0, math.min(fpBins - 1, bidx))
                array.set(binBuyVol,  bidx, array.get(binBuyVol,  bidx) + vr.buy_volume())
                array.set(binSellVol, bidx, array.get(binSellVol, bidx) + vr.sell_volume())
        fpDataSource := "NATIVE"
        barDataOk := true

// =============================================================================
//                              SESSION HANDLING
// =============================================================================

dayKey = year(time, sessTZ_eff) * 10000 + month(time, sessTZ_eff) * 100 + dayofmonth(time, sessTZ_eff)
newSession = dayKey != dayKey[1]

// =============================================================================
//                         CVD RESET MODE LOGIC
// =============================================================================
// Compute the reset trigger based on user's chosen mode.

// Supertrend-based reset (used only if mode == "Trend change")
[stValue, stDirection] = ta.supertrend(cvdTrendMul, cvdTrendLen)
bool trendChangeReset = ta.change(stDirection) != 0

// Fixed time-of-day reset (used only if mode == "Fixed time of day")
int curMinForReset = hour(time, sessTZ_eff) * 60 + minute(time, sessTZ_eff)
int resetTimeT     = cvdResetHour * 60 + cvdResetMin
bool fixedTimeCross = curMinForReset >= resetTimeT and curMinForReset[1] < resetTimeT

// Higher TF auto (steps based on chart TF)
string autoHtf = "D"
int chartSec = timeframe.in_seconds()
if chartSec <= 60
    autoHtf := "60"
else if chartSec <= 10800
    autoHtf := "D"
else if chartSec <= 43200
    autoHtf := "W"
else
    autoHtf := "M"
bool autoHtfChange  = timeframe.change(autoHtf)
bool fixedHtfChange = timeframe.change(cvdFixedTf)

bool cvdReset = false
if cvdResetMode_eff == "Never"
    cvdReset := false
else if cvdResetMode_eff == "Session start"
    cvdReset := newSession
else if cvdResetMode_eff == "Higher TF (auto)"
    cvdReset := autoHtfChange
else if cvdResetMode_eff == "Fixed higher TF"
    cvdReset := fixedHtfChange
else if cvdResetMode_eff == "Fixed time of day"
    cvdReset := fixedTimeCross
else if cvdResetMode_eff == "Trend change"
    cvdReset := trendChangeReset

// =============================================================================
//                                    CVD
// =============================================================================

var float cvd = 0.0
if cvdReset
    cvd := 0.0
if barDataOk
    cvd := cvd + barDelta

// =============================================================================
//                       KAUFMAN EFFICIENCY RATIO (ER)
// =============================================================================
// ER measures price efficiency: |net change over N bars| / sum(|each bar change|)
// Range: 0 (pure chop) to 1 (pure trend). Used for adaptive AIR smoothing.

float netChange = math.abs(close - close[erPeriod])
float sumAbsChange = 0.0
for k = 1 to erPeriod
    sumAbsChange := sumAbsChange + math.abs(close[k - 1] - close[k])
float er = sumAbsChange > 0 ? netChange / sumAbsChange : 0.0
// Clamp ER strictly to [0, 1] (handles edge cases at session boundaries)
er := math.max(0.0, math.min(1.0, er))

// Map ER to dynamic alpha: trending → fast, chop → slow
// alpha = slow + (fast - slow) * ER
float erAlpha = erSlowAlpha + (erFastAlpha - erSlowAlpha) * er

// =============================================================================
//                                    AIR
// =============================================================================

float totalActiveVol = buyVolBar + sellVolBar
float barAir = totalActiveVol > 0 ? (buyVolBar - sellVolBar) / totalActiveVol : 0.0

// AIR smoothing — switchable between flat SMA (v0.2.3 behavior) and ER-adapted EMA
var float airSmoothedAdaptive = na
if barDataOk
    if na(airSmoothedAdaptive)
        airSmoothedAdaptive := barAir
    else
        airSmoothedAdaptive := airSmoothedAdaptive + erAlpha * (barAir - airSmoothedAdaptive)

float airSmoothedFlat = ta.sma(barAir, airLen)
float airSmoothed = erEnable ? airSmoothedAdaptive : airSmoothedFlat

float airAccel = ta.change(airSmoothed, airAccLen)

float volAvg20 = ta.sma(volume, 20)
bool  volPass  = volume > volAvg20 * volGateMul

// =============================================================================
//                         MOC (Market-On-Close) IMBALANCE
// =============================================================================

int curMin     = hour(time, sessTZ_eff) * 60 + minute(time, sessTZ_eff)
int mocStartT  = mocStartH_eff * 60 + mocStartM_eff
int mocEndT    = mocEndH_eff * 60 + mocEndM_eff
bool inMocWin  = curMin >= mocStartT and curMin < mocEndT

var float mocDelta = 0.0
var float mocVol   = 0.0
var float mocImbalance = na
var float lastMocImb   = na
var float lastMocVol   = na

if newSession
    mocDelta := 0.0
    mocVol   := 0.0
    mocImbalance := na

if inMocWin and barDataOk
    mocDelta := mocDelta + barDelta
    mocVol   := mocVol + volume

// Compute live MOC during window
if inMocWin and mocVol > 0
    mocImbalance := mocDelta / mocVol

// Latch end-of-window value as "last completed MOC"
if not inMocWin and inMocWin[1]
    lastMocImb := mocImbalance
    lastMocVol := mocVol

bool mocStrong = not na(mocImbalance) and math.abs(mocImbalance) > 0.5 and mocVol > volAvg20 * mocVolMul

// =============================================================================
//                              VPIN-LITE (volume-bucketed)
// =============================================================================
// Original Easley-Lopez de Prado-O'Hara VPIN: aggregate sub-bar buy/sell volume
// into equal-volume buckets, compute |buy - sell| / total per bucket, average.
// Here we approximate by treating each chart bar as one "bucket" if its volume
// is roughly average, then smoothing.

var array<float> vpinBucketImb = array.new<float>(0)
var array<float> vpinBucketVol = array.new<float>(0)
var float vcBuyAcc  = 0.0
var float vcSellAcc = 0.0

if barDataOk and totalActiveVol > 0
    if vpinMode == "Bar bucket"
        float bucketImb = math.abs(buyVolBar - sellVolBar) / totalActiveVol
        array.push(vpinBucketImb, bucketImb)
        array.push(vpinBucketVol, totalActiveVol)
        if array.size(vpinBucketImb) > vpinBuckets
            array.shift(vpinBucketImb)
            array.shift(vpinBucketVol)
    else
        // Volume clock: accumulate across bars into equal-volume buckets
        float vcTarget = nz(volAvg20, totalActiveVol) * vpinBucketVolTarget
        vcBuyAcc  := vcBuyAcc  + buyVolBar
        vcSellAcc := vcSellAcc + sellVolBar
        float vcAccTot = vcBuyAcc + vcSellAcc
        if vcTarget > 0 and vcAccTot >= vcTarget
            float bucketImb = math.abs(vcBuyAcc - vcSellAcc) / vcAccTot
            array.push(vpinBucketImb, bucketImb)
            array.push(vpinBucketVol, vcAccTot)
            if array.size(vpinBucketImb) > vpinBuckets
                array.shift(vpinBucketImb)
                array.shift(vpinBucketVol)
            vcBuyAcc  := 0.0
            vcSellAcc := 0.0

float vpinRaw = na
if array.size(vpinBucketImb) >= 10
    float sumImb = 0.0
    float sumVol = 0.0
    int sz = array.size(vpinBucketImb)
    for i = 0 to sz - 1
        float w = array.get(vpinBucketVol, i)
        sumImb := sumImb + array.get(vpinBucketImb, i) * w
        sumVol := sumVol + w
    vpinRaw := sumVol > 0 ? sumImb / sumVol : na

float vpin = ta.sma(vpinRaw, vpinSmooth)
// percentrank computed unconditionally for series consistency; mask to na if vpin is na
float vpinPctileRaw = ta.percentrank(nz(vpin, 0), 100)
float vpinPctile = na(vpin) ? na : vpinPctileRaw

// =============================================================================
//                            KYLE'S LAMBDA (sub-bar)
// =============================================================================
// λ = |bar price change| / |signed volume| (price impact per unit net flow).

float barReturnAbs = math.abs(close - close[1])
float barLambda = math.abs(barDelta) > 0 ? barReturnAbs / math.abs(barDelta) : na
float lambdaSm = ta.sma(barLambda, lambdaLen)
// percentrank computed unconditionally for series consistency; mask to na if lambdaSm is na
float lambdaPctileRaw = ta.percentrank(nz(lambdaSm, 0), 200)
float lambdaPctile = na(lambdaSm) ? na : lambdaPctileRaw

// =============================================================================
//                           DIVERGENCE DETECTION
// =============================================================================
// Bar shows divergence when signed-delta direction contradicts bar's price direction.
// E.g., green candle (close > open) but barDelta < 0 = sellers absorbed (rev down).
// Or:    red candle (close < open) but barDelta > 0 = buyers absorbed (rev up).
// This is the cleanest absorption signal available without bid/ask depth.

bool barIsBull = close > open
bool barIsBear = close < open
bool deltaIsPos = barDelta > 0
bool deltaIsNeg = barDelta < 0

bool divergence = barDataOk and ((barIsBull and deltaIsNeg) or (barIsBear and deltaIsPos))
// Strong divergence requires meaningful delta magnitude (else just doji noise)
bool strongDiv = divergence and volume > volAvg20 * 0.8 and math.abs(barDelta) > volume * 0.15

string divType = "none"
if strongDiv
    divType := barIsBull ? "bull-trap" : "bear-trap"
else if divergence
    divType := barIsBull ? "weak-sell-abs" : "weak-buy-abs"

// =============================================================================
//                       EMBEDDED DELTA CANDLE CALCULATION
// =============================================================================
// Inspired by LuxAlgo Vol Delta Candles. Inside each candle body, render a
// smaller inner candle showing delta as % of total active volume.

float totalActVol = buyVolBar + sellVolBar
float normDelta   = totalActVol > 0 ? barDelta / totalActVol : 0.0
float aNorm       = math.abs(normDelta)
bool  dcPos       = normDelta >= 0

float bodyMin = math.min(open, close)
float bodyMax = math.max(open, close)
float bodyAvg = math.avg(open, close)
float bodyAbs = bodyMax - bodyMin

float dcBase  = na
float dcValue = na
if barDataOk and bodyAbs > 0 and totalActVol > 0
    if dcStyle == "Half body"
        dcBase  := bodyAvg
        dcValue := bodyAvg + normDelta * bodyAbs / 2.0
    else  // Full body
        dcBase  := dcPos ? bodyMin : bodyMax
        dcValue := dcPos ? bodyMin + aNorm * bodyAbs : bodyMax - aNorm * bodyAbs

// Delta-candle color: divergence-aware if user enabled it
color dcCol = na
if barDataOk
    if dcDivAlt and divergence
        dcCol := barIsBull ? dcBullDivCol : dcBearDivCol
    else
        dcCol := dcPos ? dcBullCol : dcBearCol
    dcCol := color.new(dcCol, 30)
// =============================================================================
//                           FOOTPRINT PATTERN ANALYSIS
// =============================================================================
// From the per-bar bin arrays, compute:
//   - Peak volume bin (price level where most action concentrated)
//   - Imbalance bin (strongest one-side dominance, if any exceeds threshold)
//   - Pattern: P-shape (buy at top), b-shape (sell at bottom), balanced, mixed
//   - Single prints (empty bins between filled bins = magnets)

float peakVolPrice    = na
float imbalancePrice  = na
float imbalancePct    = na
int   imbalanceSide   = 0  // +1 buy-dom, -1 sell-dom, 0 none
int   singlePrintCnt  = 0
int   patternCode     = 0  // -2 b-strong, -1 b-mild, 0 balanced, +1 P-mild, +2 P-strong
string patternName    = "balanced"

if barDataOk and barRange > 0
    float maxBinVol = 0.0
    int   maxBinIdx = -1
    int   strongImbIdx = -1
    float strongImbPct = 0.0
    int   strongImbSide = 0

    // Pass 1: find peak-volume bin, strongest imbalance, count single prints
    for j = 0 to fpBins - 1
        float bv = array.get(binBuyVol,  j)
        float sv = array.get(binSellVol, j)
        float tv = bv + sv
        if tv > maxBinVol
            maxBinVol := tv
            maxBinIdx := j
        if tv > 0
            float buyPct = bv / tv
            float sellPct = sv / tv
            if buyPct >= fpImbThresh and buyPct > strongImbPct
                strongImbPct := buyPct
                strongImbIdx := j
                strongImbSide := 1
            else if sellPct >= fpImbThresh and sellPct > strongImbPct
                strongImbPct := sellPct
                strongImbIdx := j
                strongImbSide := -1
        else
            // bin has zero volume — potential single print
            // (only count as single print if it sits BETWEEN filled bins)
            if j > 0 and j < fpBins - 1
                float prevTv = array.get(binBuyVol, j-1) + array.get(binSellVol, j-1)
                float nextTv = array.get(binBuyVol, j+1) + array.get(binSellVol, j+1)
                if prevTv > 0 and nextTv > 0
                    singlePrintCnt := singlePrintCnt + 1

    if maxBinIdx >= 0
        peakVolPrice := low + (maxBinIdx + 0.5) * binSize

    if strongImbIdx >= 0
        imbalancePrice := low + (strongImbIdx + 0.5) * binSize
        imbalancePct   := strongImbPct
        imbalanceSide  := strongImbSide

    // Pattern classification: where does volume mass sit in the bar?
    // Sum volume in TOP half vs BOTTOM half
    float topHalfVol = 0.0
    float botHalfVol = 0.0
    int halfPoint = int(fpBins / 2)
    for j = 0 to fpBins - 1
        float tv = array.get(binBuyVol, j) + array.get(binSellVol, j)
        if j >= halfPoint
            topHalfVol := topHalfVol + tv
        else
            botHalfVol := botHalfVol + tv

    float totalBarVol = topHalfVol + botHalfVol
    if totalBarVol > 0
        float topPct = topHalfVol / totalBarVol
        // P-shape: volume stacks at top with net-buy character (continuation up or absorption at resistance)
        // b-shape: volume stacks at bottom with net-sell character (continuation down or absorption at support)
        bool isNetBuy  = barDelta > 0
        bool isNetSell = barDelta < 0

        if topPct >= 0.65 and isNetBuy
            patternCode := 2
            patternName := "P-strong"
        else if topPct >= 0.60 and isNetBuy
            patternCode := 1
            patternName := "P-shape"
        else if topPct <= 0.35 and isNetSell
            patternCode := -2
            patternName := "b-strong"
        else if topPct <= 0.40 and isNetSell
            patternCode := -1
            patternName := "b-shape"
        else if topPct >= 0.60 and isNetSell
            // Volume at top but net sell = sell absorbed at highs (BEARISH continuation likely)
            patternCode := -1
            patternName := "sell@top"
        else if topPct <= 0.40 and isNetBuy
            // Volume at bottom but net buy = buy absorbed at lows (BULLISH reversal)
            patternCode := 1
            patternName := "buy@btm"

// =============================================================================
//                         AUCTION EFFICIENCY SCORE
// =============================================================================
// auction_efficiency = Value Area volume / Total bar volume
//
// Value Area = contiguous range of bins containing auctionVAPct of total volume,
// built outward from POC by always adding the higher-volume neighbor.
//
// High efficiency (>= auctionEffHigh) = market accepted these prices (healthy auction)
// Low efficiency (<= auctionEffLow)   = rejection / distribution / trapped flow
// Mid                                  = mixed / transitional

float auctionEff   = na
string auctionLab  = "n/a"
color  auctionCol  = neuClr
float auctionContrib = 0.0  // signed contribution: + supports direction, - opposes

if auctionEnable and barDataOk and totalActiveVol > 0
    // Find POC bin (highest single-bin volume)
    int pocIdx = 0
    float pocVol = 0.0
    for j = 0 to fpBins - 1
        float tv = array.get(binBuyVol, j) + array.get(binSellVol, j)
        if tv > pocVol
            pocVol := tv
            pocIdx := j

    // Build Value Area outward from POC by adding higher-volume neighbor
    float vaVol  = pocVol
    int vaLow    = pocIdx
    int vaHigh   = pocIdx
    float vaTarget = totalActiveVol * auctionVAPct
    int safetyCounter = 0
    while vaVol < vaTarget and safetyCounter < fpBins
        float volAbove = vaHigh < fpBins - 1 ? array.get(binBuyVol, vaHigh + 1) + array.get(binSellVol, vaHigh + 1) : -1.0
        float volBelow = vaLow  > 0          ? array.get(binBuyVol, vaLow  - 1) + array.get(binSellVol, vaLow  - 1) : -1.0
        if volAbove < 0 and volBelow < 0
            break
        if volAbove >= volBelow
            vaHigh := vaHigh + 1
            vaVol  := vaVol + volAbove
        else
            vaLow  := vaLow - 1
            vaVol  := vaVol + volBelow
        safetyCounter := safetyCounter + 1

    auctionEff := vaVol / totalActiveVol

    if auctionEff >= auctionEffHigh
        auctionLab := "efficient"
        auctionCol := bullClr
    else if auctionEff <= auctionEffLow
        auctionLab := "TRAPPED"
        auctionCol := bearClr
    else
        auctionLab := "mixed"
        auctionCol := neuClr

    // Auction contribution to Bayesian fusion:
    // Efficient + net buy = strong + (confirms buy)
    // Efficient + net sell = strong - (confirms sell)
    // Inefficient = warning - direction opposite to current bar direction (trap)
    bool isNetBuyBar = buyVolBar > sellVolBar
    if auctionEff >= auctionEffHigh
        // Efficient: support whichever side dominates
        auctionContrib := isNetBuyBar ? 0.6 : -0.6
    else if auctionEff <= auctionEffLow
        // Inefficient: contrarian — flip the dominant side's signal (trap warning)
        auctionContrib := isNetBuyBar ? -0.4 : 0.4
    else
        auctionContrib := 0.0

// =============================================================================
//                  PHASE 3 — ADVANCED MICROSTRUCTURE FACTORS
// =============================================================================

// ── (1) Integrated multi-level OFI ──────────────────────────────────────────
// Depth-weighted signed flow across footprint rows. Rows nearest the close
// (best levels) carry full weight; deeper rows decay exponentially, mirroring
// Xu-Gould-Howison multi-level OFI. Uses real bid/ask when native footprint on.
//   OFI = Σ_j w_j·(buy_j − sell_j) / Σ_j w_j·(buy_j + sell_j) ∈ [−1, +1]
float ofiNorm = 0.0
if ofiEnable and barDataOk and binSize > 0
    float ofiNum = 0.0
    float ofiDen = 0.0
    for j = 0 to fpBins - 1
        float bvj = array.get(binBuyVol,  j)
        float svj = array.get(binSellVol, j)
        float tvj = bvj + svj
        if tvj > 0
            float binCenter = low + (j + 0.5) * binSize
            float distBins  = math.abs(binCenter - close) / binSize
            float wj = math.exp(-distBins / ofiDepthDecay)
            ofiNum := ofiNum + wj * (bvj - svj)
            ofiDen := ofiDen + wj * tvj
    ofiNorm := ofiDen > 0 ? ofiNum / ofiDen : 0.0
ofiNorm := math.max(-1.0, math.min(1.0, ofiNorm))

// ── (2) Directional Hawkes intensity ────────────────────────────────────────
// Self-exciting buy/sell event intensities (exponential kernel, Bacry-Muzy).
// A bar is a directional 'event' when |barDelta| exceeds a rolling threshold;
// each event excites same-side intensity, which then decays. The normalized
// difference is a momentum-clustering signal.
var float lamBuy  = 0.0
var float lamSell = 0.0
float absDeltaAvg = ta.sma(math.abs(barDelta), 20)
float hawkesDir = 0.0
if hawkesIntEnable
    lamBuy  := lamBuy  * hawkesIntDecay
    lamSell := lamSell * hawkesIntDecay
    if barDataOk and not na(absDeltaAvg) and math.abs(barDelta) > absDeltaAvg * hawkesEventMult
        if barDelta > 0
            lamBuy  := lamBuy  + 1.0
        else if barDelta < 0
            lamSell := lamSell + 1.0
    float lamTot = lamBuy + lamSell
    hawkesDir := lamTot > 0 ? (lamBuy - lamSell) / lamTot : 0.0
hawkesDir := math.max(-1.0, math.min(1.0, hawkesDir))

// ── (3) Square-root-law absorption ──────────────────────────────────────────
// Almgren / Tóth-Bouchaud: expected impact ∝ √(|signed vol| / avg vol).
// Realized impact far BELOW prediction = passive absorption (flow soaked up,
// price held → fade the flow). Far ABOVE = fragile expansion (thin book,
// confirm the flow). absorbSignal points AGAINST delta when absorbed, WITH
// delta when fragile.
float absVolAvg   = volAvg20
float atrNow      = ta.atr(14)
float predImpact  = (not na(absVolAvg) and absVolAvg > 0 and not na(atrNow)) ? sqrtLawY * atrNow * math.sqrt(math.abs(barDelta) / absVolAvg) : na
float realImpact  = math.abs(close - open)
float absorbRatio = (absorbEnable and not na(predImpact) and predImpact > 0) ? realImpact / predImpact : na
float absorbSignal = 0.0
if absorbEnable and not na(absorbRatio) and barDataOk
    // (ratio − 1): <0 absorbed, >0 fragile. Sign by delta direction.
    int   dSign = barDelta > 0 ? 1 : barDelta < 0 ? -1 : 0
    float mag   = math.max(-1.0, math.min(1.0, absorbRatio - 1.0))
    absorbSignal := dSign * mag
absorbSignal := math.max(-1.0, math.min(1.0, absorbSignal))

string absorbLab = "n/a"
if absorbEnable and not na(absorbRatio)
    absorbLab := absorbRatio <= absorbLow ? "ABSORBED" : absorbRatio >= absorbHigh ? "fragile" : "normal"

// =============================================================================
//              PHASE 4a — CROSS-INSTRUMENT CONFIRMATION (lead-lag)
// =============================================================================
// Pulls a lightweight signed-flow proxy from a correlated paired instrument
// (NIFTY <-> BANKNIFTY). Directional agreement confirms the local read; a
// persistent cross-instrument divergence is an early warning. Kept cheap: one
// security request returning a single composite in [-1, +1].
crossProxyExpr() =>
    float chg3   = ta.change(close, 3)
    float atrX   = nz(ta.atr(14), 1)
    float momX   = math.max(-1.0, math.min(1.0, chg3 / atrX))
    float vdX    = close > open ? volume : close < open ? -volume : 0.0
    float vdNorm = math.max(-1.0, math.min(1.0, vdX / nz(ta.sma(volume, 20), 1)))
    0.6 * momX + 0.4 * vdNorm
float crossFlow = crossEnable ? request.security(crossSymbol, timeframe.period, crossProxyExpr(), lookahead = barmerge.lookahead_off) : na
int crossDir = (not na(crossFlow) and crossFlow > crossThresh) ? 1 : (not na(crossFlow) and crossFlow < -crossThresh) ? -1 : 0

// =============================================================================
//                          REGIME CLASSIFIER (5-state)
// =============================================================================
// Score = weighted sum of normalized signals
//   +ve = bullish, -ve = bearish
// Components:
//   - airSmoothed       : range -1..+1, weight 1.0
//   - sign(barDelta) * min(|barDelta|/avgVol, 1) : weight 0.8
//   - sign(cvd) * (1 - exp(-|cvd|/k)) : weight 0.5  (CVD pressure, capped)
//   - airAccel (clipped -0.5..+0.5) * 2 : weight 0.6
//   - mocImbalance (if available) : weight 0.4

// Normalize CVD scale relative to session activity
// Pine v6 has no math.tanh, so use a bounded ratio: x / (1 + |x|) which has range (-1, +1)
float cvdRatio = barDataOk and volAvg20 > 0 ? cvd / (volAvg20 * 50) : 0.0
float cvdNorm  = cvdRatio / (1.0 + math.abs(cvdRatio))
float deltaNorm = barDataOk and volume > 0 ? math.max(-1.0, math.min(1.0, barDelta / volume)) : 0.0
float airAccelNorm = math.max(-1.0, math.min(1.0, nz(airAccel, 0) * 4.0))
float mocComp = na(mocImbalance) ? 0.0 : math.max(-1.0, math.min(1.0, mocImbalance))
// Footprint pattern contribution: maps -2..+2 code to -1..+1 weight
float fpComp = patternCode / 2.0

float regimeScore = nz(airSmoothed, 0) * 1.0 + deltaNorm * 0.8 + cvdNorm * 0.5 + airAccelNorm * 0.6 + mocComp * 0.4 + fpComp * 0.5

string regimeName = "NEUTRAL"
color regimeCol  = neuClr
int   regimeCode = 0
if regimeScore >= stateBullStrong
    regimeName := "STRONG-BULL"
    regimeCol  := strongBull
    regimeCode := 2
else if regimeScore >= stateBullMild
    regimeName := "BULL"
    regimeCol  := bullClr
    regimeCode := 1
else if regimeScore <= stateBearStrong
    regimeName := "STRONG-BEAR"
    regimeCol  := strongBear
    regimeCode := -2
else if regimeScore <= stateBearMild
    regimeName := "BEAR"
    regimeCol  := bearClr
    regimeCode := -1

// Risk gates from VPIN and Lambda
bool toxicFlow    = not na(vpin) and vpin > 0.4
bool thinLiquid   = not na(lambdaPctile) and lambdaPctile > 70
bool riskElevated = toxicFlow or thinLiquid

// =============================================================================
//                  HAWKES-STYLE REGIME-THRASH SUPPRESSION
// =============================================================================
// Detects regime-flip clustering. Many recent flips = noise/chop, suppress
// confidence. Few or no recent flips = stable regime, full confidence.
//
// Implementation: weighted count of regime changes in lookback window,
// with exponential decay so older flips contribute less.

float decayedThrash = 0.0
if hawkesEnable and bar_index > hawkesWindow
    for k = 0 to hawkesWindow - 1
        float decayWeight = math.pow(hawkesDecay, k)
        float ev = 0.0
        if thrashMode == "Directional"
            // v0.5 fix: only DIRECTIONAL instability is chaos. A trend stepping
            // BULL<->STRONG-BULL (same sign) is NOT thrash. Full weight on a true
            // bull<->bear reversal; half weight on entering/leaving NEUTRAL.
            float dK  = math.sign(nz(regimeCode[k],     0))
            float dK1 = math.sign(nz(regimeCode[k + 1], 0))
            bool reversal     = dK != 0 and dK1 != 0 and dK != dK1
            bool neutralCross = (dK == 0) != (dK1 == 0)
            ev := reversal ? 1.0 : (neutralCross ? 0.5 : 0.0)
        else
            // Legacy (v0.4.x): any regime-code change counts as a flip
            ev := nz(regimeCode[k], 0) != nz(regimeCode[k + 1], 0) ? 1.0 : 0.0
        decayedThrash := decayedThrash + ev * decayWeight

// Normalize: thrash score in [0, 1] where 1 = maxed out
float thrashScore = hawkesEnable ? math.min(1.0, decayedThrash / hawkesMaxThrash) : 0.0

// Confidence penalty proportional to thrash
float thrashPenalty = thrashScore * hawkesPenalty

// Stability label for dashboard
string stabilityLabel = "stable"
color  stabilityCol   = bullClr
if thrashScore > 0.7
    stabilityLabel := "CHAOS"
    stabilityCol   := bearClr
else if thrashScore > 0.4
    stabilityLabel := "noisy"
    stabilityCol   := color.new(#FFB800, 0)
else if thrashScore > 0.2
    stabilityLabel := "settling"
    stabilityCol   := neuClr

// =============================================================================
//                       PIVOT-ANCHORED LEVEL DETECTION
// =============================================================================
// Find nearest confirmed pivot high above current price and pivot low below.
// These become the anchors for entry/invalidation when pivotEnable is true.

float pvHigh = ta.pivothigh(high, pivotLeft, pivotRight)
float pvLow  = ta.pivotlow(low,  pivotLeft, pivotRight)

// Search backwards for nearest pivot levels relative to current price.
// Use historical-indexed values of the already-computed series (Pine v6 best practice).
float nearPvHighAbove = na
float nearPvLowBelow  = na
for k = 0 to pivotMaxLookback - 1
    if na(nearPvHighAbove)
        float ph = pvHigh[k]
        if not na(ph) and ph > close
            nearPvHighAbove := ph
    if na(nearPvLowBelow)
        float pl = pvLow[k]
        if not na(pl) and pl < close
            nearPvLowBelow := pl

// =============================================================================
//                       LIQUIDITY SWEEP ENGINE
// =============================================================================
// Detects stop-runs at recent pivots that get reclaimed within the same bar.
// Bull sweep: low ran below recent pivot low, close back above (long candidate)
// Bear sweep: high ran above recent pivot high, close back below (short candidate)
// Requires volume confirmation (≥ sweepVolMul × volAvg20).

// Find the recent pivot levels to test against (within sweepLookback window)
float sweepRefHigh = na
float sweepRefLow  = na
for k = 1 to sweepLookback
    if na(sweepRefHigh)
        float ph = pvHigh[k]
        if not na(ph)
            sweepRefHigh := ph
    if na(sweepRefLow)
        float pl = pvLow[k]
        if not na(pl)
            sweepRefLow := pl

// Bull sweep detection
bool sweepBull = false
float sweepBullLvl = na
if sweepEnable and not na(sweepRefLow) and volume > volAvg20 * sweepVolMul
    bool sweptBelow = low < sweepRefLow
    // Reclaim: close must be back above the pivot, AND close must reclaim sweepReclaimPct of the wick below
    float wickBelow = sweepRefLow - low  // depth of penetration
    bool reclaimed = close > sweepRefLow and (close - low) >= wickBelow * (1.0 + sweepReclaimPct)
    if sweptBelow and reclaimed
        sweepBull := true
        sweepBullLvl := sweepRefLow

// Bear sweep detection
bool sweepBear = false
float sweepBearLvl = na
if sweepEnable and not na(sweepRefHigh) and volume > volAvg20 * sweepVolMul
    bool sweptAbove = high > sweepRefHigh
    float wickAbove = high - sweepRefHigh
    bool reclaimed = close < sweepRefHigh and (high - close) >= wickAbove * (1.0 + sweepReclaimPct)
    if sweptAbove and reclaimed
        sweepBear := true
        sweepBearLvl := sweepRefHigh

// Sweep state: which direction (+1 bull / -1 bear / 0 none)
int sweepDir = sweepBull ? 1 : sweepBear ? -1 : 0

// Memorize most recent sweep direction + level for dashboard reporting
var int sweepLastDir = 0
var float sweepLastLvl = na
var int sweepLastBar = na
if sweepDir != 0
    sweepLastDir := sweepDir
    sweepLastLvl := sweepDir > 0 ? sweepBullLvl : sweepBearLvl
    sweepLastBar := bar_index

int sweepBarsAgo = na(sweepLastBar) ? na : bar_index - sweepLastBar

// =============================================================================
//                       BAYESIAN FUSION (confidence engine)
// =============================================================================
// Each signal mapped to P(bull) ∈ [0,1] via logistic squash.
// Combine via odds-ratio multiplication (log-odds sum is mathematically equivalent).
// Final posterior = sigmoid(prior_log_odds + Σ weight_i × signal_log_odds_i)
//
// This is rigorous Bayesian fusion under conditional independence assumption.

// Helper: sigmoid-style signal-to-P(bull) mapping
//   input x ∈ approx [-1, +1], output P ∈ (0, 1)
//   gain controls steepness — higher = more confident shifts per unit signal
sigSquash(float x, float gain) =>
    1.0 / (1.0 + math.exp(-gain * x))

// Compact, locale-neutral number formatting: 75,303 -> 75.3K, 1,250,000 -> 1.3M
fmtNum(float x) =>
    float a = math.abs(x)
    a >= 1e12 ? str.tostring(x / 1e12, "0.0") + "T" : a >= 1e9 ? str.tostring(x / 1e9, "0.0") + "B" : a >= 1e6 ? str.tostring(x / 1e6, "0.0") + "M" : a >= 1e3 ? str.tostring(x / 1e3, "0.0") + "K" : str.tostring(x, "#,###")

// Darken a color toward black (f < 1), preserving its transparency. Used to
// make accent text dense/legible on light chart backgrounds.
darken(color c, float f) =>
    color.rgb(color.r(c) * f, color.g(c) * f, color.b(c) * f, color.t(c))

// Convert each signal to P(bull):
float pAir   = sigSquash(nz(airSmoothed, 0), 3.0)
float pDelta = sigSquash(deltaNorm, 3.0)
float pCvd   = sigSquash(cvdNorm, 2.5)
float pAccel = sigSquash(airAccelNorm, 2.5)
float pMoc   = sigSquash(mocComp, 2.0)
float pFp    = sigSquash(fpComp, 2.5)
float pAuction = sigSquash(auctionContrib, 2.5)  // NEW: auction efficiency contribution
float pOfi     = sigSquash(ofiNorm, 3.0)         // Phase 3: multi-level OFI
float pHawkes  = sigSquash(hawkesDir, 2.5)       // Phase 3: directional Hawkes intensity
float pAbsorb  = sigSquash(absorbSignal, 2.5)    // Phase 3: √-law absorption
float pXinst   = sigSquash(nz(crossFlow, 0.0), 2.5)  // Phase 4: cross-instrument flow

// Convert P to log-odds: ln(P / (1-P))
logOdds(float p) =>
    float safeP = math.max(0.001, math.min(0.999, p))
    math.log(safeP / (1.0 - safeP))

// Helper: render a visual bar for log-odds contribution (BQS display layer)
bqsViz(float x) =>
    float mag = math.min(1.0, math.abs(x) / 1.5)
    int filled = int(math.round(mag * 4))
    string bars = ""
    for n = 0 to 3
        bars := bars + (n < filled ? "●" : "○")
    bars

// =============================================================================
//              PHASE 2 — FUSION DECORRELATION (effective independence)
// =============================================================================
// The flow family (AIR, Δ bar, CVD, ΔAIR, Footprint) is all derived from the
// same signed order-flow series, so summing their log-odds as independent
// evidence double-counts and inflates confidence. We measure their average
// pairwise correlation over a rolling window and shrink the family's combined
// contribution toward that of N_eff independent signals (Kish design effect,
// equicorrelation model):  N_eff = N / (1 + (N-1)·ρ̄),  shrink = N_eff / N.
// MOC and Auction are NOT shrunk — they carry more independent information.
// During warm-up (ta.correlation = na) ρ̄ → 0, shrink → 1 (legacy behaviour).
corrClamp(float x) =>
    math.max(0.0, math.min(1.0, nz(x, 0.0)))

float _airS = nz(airSmoothed, 0.0)
float rAD = ta.correlation(_airS,        deltaNorm,    fusionCorrLen)
float rAC = ta.correlation(_airS,        cvdNorm,      fusionCorrLen)
float rAX = ta.correlation(_airS,        airAccelNorm, fusionCorrLen)
float rAF = ta.correlation(_airS,        fpComp,       fusionCorrLen)
float rDC = ta.correlation(deltaNorm,    cvdNorm,      fusionCorrLen)
float rDX = ta.correlation(deltaNorm,    airAccelNorm, fusionCorrLen)
float rDF = ta.correlation(deltaNorm,    fpComp,       fusionCorrLen)
float rCX = ta.correlation(cvdNorm,      airAccelNorm, fusionCorrLen)
float rCF = ta.correlation(cvdNorm,      fpComp,       fusionCorrLen)
float rXF = ta.correlation(airAccelNorm, fpComp,       fusionCorrLen)
float rhoBar = (corrClamp(rAD) + corrClamp(rAC) + corrClamp(rAX) + corrClamp(rAF) + corrClamp(rDC) + corrClamp(rDX) + corrClamp(rDF) + corrClamp(rCX) + corrClamp(rCF) + corrClamp(rXF)) / 10.0

float nFam = 5.0
float nEff = nFam / (1.0 + (nFam - 1.0) * rhoBar)
float fusionShrink = nEff / nFam                       // ∈ (0, 1], =1 when uncorrelated
float famShrink = fusionMode == "Decorrelated" ? fusionShrink : 1.0

float priorLO  = logOdds(bayesPrior)
float airLO    = logOdds(pAir)   * bayesAirWt_eff * famShrink
float deltaLO  = logOdds(pDelta) * bayesDeltaWt   * famShrink
float cvdLO    = logOdds(pCvd)   * bayesCvdWt_eff * famShrink
float accelLO  = logOdds(pAccel) * bayesAccelWt   * famShrink
float mocLO    = logOdds(pMoc)   * bayesMocWt_eff
float fpLO     = logOdds(pFp)    * bayesFpWt       * famShrink
float auctionLO = auctionEnable ? logOdds(pAuction) * bayesAuctionWt : 0.0
// Phase 3 contributors. OFI is flow-derived → subject to famShrink. Hawkes
// intensity and √-law absorption are more independent → full weight.
float ofiLO     = ofiEnable     ? logOdds(pOfi)    * bayesOfiWt * famShrink : 0.0
float hawkesLO  = hawkesIntEnable ? logOdds(pHawkes) * bayesHawkesWt : 0.0
float absorbLO  = absorbEnable  ? logOdds(pAbsorb) * bayesAbsorbWt : 0.0
// Phase 4: cross-instrument confirmation (independent — not flow-family shrunk)
float xinstLO   = (crossEnable and not na(crossFlow)) ? logOdds(pXinst) * bayesXinstWt : 0.0

float totalLO  = priorLO + airLO + deltaLO + cvdLO + accelLO + mocLO + fpLO + auctionLO + ofiLO + hawkesLO + absorbLO + xinstLO
float posterior = 1.0 / (1.0 + math.exp(-totalLO))

// Bayesian confidence: distance from 0.5 (neutral), scaled to [0, 1]
// posterior = 0.5 → confidence 0; posterior = 1.0 or 0.0 → confidence 1.0
float bayesConf = math.abs(posterior - 0.5) * 2.0
// Bayesian direction: +1 if posterior > 0.5, -1 if < 0.5
int bayesDir = posterior > 0.5 ? 1 : posterior < 0.5 ? -1 : 0

// =============================================================================
//              PHASE 4b — MULTI-HORIZON POSTERIOR CONSENSUS
// =============================================================================
// Blends the posterior across short/medium/long horizons (EMA). When all three
// horizons sit on the same side of 0.5, conviction is durable → bonus. When
// they split, the signal is transitional → penalty. Time-domain CO-FIRE.
float postMed  = ta.ema(posterior, mhMedLen)
float postLong = ta.ema(posterior, mhLongLen)
int mhS = posterior > 0.5 ? 1 : posterior < 0.5 ? -1 : 0
int mhM = postMed  > 0.5 ? 1 : postMed  < 0.5 ? -1 : 0
int mhL = postLong > 0.5 ? 1 : postLong < 0.5 ? -1 : 0
bool mhAllAgree = mhS != 0 and mhS == mhM and mhM == mhL
bool mhSplit    = (mhS != mhM and mhM != 0 and mhS != 0) or (mhS != mhL and mhL != 0 and mhS != 0)
// Consensus in [-1,+1]: average of the three horizon signs
float mhConsensus = (mhS + mhM + mhL) / 3.0
float mhBlend = (posterior + postMed + postLong) / 3.0
float mhBonus = 0.0
if mhEnable
    mhBonus := mhAllAgree ? mhAgreeBonus : (mhSplit ? -mhSplitPenalty : 0.0)

// =============================================================================
//                       MTF CONFLUENCE FILTER
// =============================================================================
// Fetches a lightweight HTF posterior proxy and gates the current-TF action
// against it. Designed for performance: uses a simplified HTF model (not the
// full Bayesian fusion re-run on HTF) to avoid duplicate sub-bar requests.
//
// HTF proxy = sigmoid of:
//   normalized close-momentum (price velocity over 14 bars)
//   + volume-weighted close direction (cleaned tick-rule on HTF)
//   + supertrend direction
// This is a lightweight directional consensus, not a full Bayesian replica.

// Auto HTF1 resolution map based on current chart TF (immediate context)
string mtfHtf = mtfManual
if mtfAuto
    if chartTfSec <= 60
        mtfHtf := "5"
    else if chartTfSec <= 120
        mtfHtf := "10"
    else if chartTfSec <= 180
        mtfHtf := "15"
    else if chartTfSec <= 300
        mtfHtf := "15"
    else if chartTfSec <= 900
        mtfHtf := "60"
    else if chartTfSec <= 1800
        mtfHtf := "60"
    else if chartTfSec <= 3600
        mtfHtf := "240"
    else
        mtfHtf := "D"

// Auto HTF2 resolution map based on current chart TF (broader trend context)
string mtfHtf2 = mtf2Manual
if mtf2Auto
    if chartTfSec <= 60
        mtfHtf2 := "15"
    else if chartTfSec <= 120
        mtfHtf2 := "30"
    else if chartTfSec <= 180
        mtfHtf2 := "60"
    else if chartTfSec <= 300
        mtfHtf2 := "60"
    else if chartTfSec <= 900
        mtfHtf2 := "240"
    else if chartTfSec <= 1800
        mtfHtf2 := "240"
    else if chartTfSec <= 3600
        mtfHtf2 := "D"
    else
        mtfHtf2 := "W"

// HTF proxy expression — kept lightweight intentionally
htfProxyExpr() =>
    float mom = ta.change(close, 14) / nz(ta.atr(14), 1)
    [stV, stD] = ta.supertrend(3.0, 14)
    float stDir = stD == -1 ? 1.0 : -1.0
    float volDeltaProxy = close > open ? volume : -volume
    float volDeltaNorm = volDeltaProxy / nz(ta.sma(volume, 20), 1)
    // Combine into a single composite, then squash to [0,1]
    float composite = mom * 0.5 + stDir * 0.4 + volDeltaNorm * 0.3
    float htfPost = 1.0 / (1.0 + math.exp(-composite))
    htfPost

// Fetch HTF1 posterior — uses lookahead_off for non-repainting behavior
float htfPosterior = mtfMode == "Ignore MTF" ? 0.5 : request.security(syminfo.tickerid, mtfHtf, htfProxyExpr(), lookahead = barmerge.lookahead_off)

// Fetch HTF2 posterior (only if enabled)
float htf2Posterior = (mtfMode == "Ignore MTF" or not mtf2Enable) ? 0.5 : request.security(syminfo.tickerid, mtfHtf2, htfProxyExpr(), lookahead = barmerge.lookahead_off)

// HTF1 direction classification
int htfDir = 0
string htfDirLabel = "NEUT"
color  htfDirCol = neuClr
if htfPosterior > mtfBullThresh
    htfDir := 1
    htfDirLabel := "BULL"
    htfDirCol := bullClr
else if htfPosterior < mtfBearThresh
    htfDir := -1
    htfDirLabel := "BEAR"
    htfDirCol := bearClr

// HTF2 direction classification
int htf2Dir = 0
string htf2DirLabel = "NEUT"
color  htf2DirCol = neuClr
if htf2Posterior > mtfBullThresh
    htf2Dir := 1
    htf2DirLabel := "BULL"
    htf2DirCol := bullClr
else if htf2Posterior < mtfBearThresh
    htf2Dir := -1
    htf2DirLabel := "BEAR"
    htf2DirCol := bearClr

// Per-HTF alignment check (each HTF aligned if same direction OR HTF is neutral)
bool htf1Aligned = htfDir == 0 or bayesDir == 0 or htfDir == bayesDir
bool htf1Disagreed = htfDir != 0 and bayesDir != 0 and htfDir != bayesDir

bool htf2Aligned = htf2Dir == 0 or bayesDir == 0 or htf2Dir == bayesDir
bool htf2Disagreed = htf2Dir != 0 and bayesDir != 0 and htf2Dir != bayesDir

// Overall MTF alignment: both must not contradict (when HTF2 enabled)
bool mtfAligned = htf1Aligned and (not mtf2Enable or htf2Aligned)
bool mtfDisagreed = htf1Disagreed or (mtf2Enable and htf2Disagreed)
bool mtfActive = mtfMode != "Ignore MTF"

// Status string for dashboard — combined when HTF2 enabled
string mtfStatus = ""
color  mtfStatusCol = neuClr
if not mtfActive
    mtfStatus := "off"
    mtfStatusCol := color.new(color.silver, 50)
else if mtf2Enable
    // Dual HTF display: e.g., "✓✓ BULL/BULL" or "✓✗ BULL/BEAR"
    string h1Sym = htf1Aligned ? "✓" : "✗"
    string h2Sym = htf2Aligned ? "✓" : "✗"
    mtfStatus := h1Sym + h2Sym + " " + htfDirLabel + "/" + htf2DirLabel
    if htf1Aligned and htf2Aligned and bayesDir != 0 and htfDir != 0 and htf2Dir != 0
        mtfStatusCol := bayesDir > 0 ? bullClr : bearClr
    else if htf1Disagreed or htf2Disagreed
        mtfStatusCol := bearClr
    else
        mtfStatusCol := neuClr
else
    // Single HTF display: legacy v0.2.9 behavior
    if mtfAligned and bayesDir != 0 and htfDir != 0
        mtfStatus := "✓ aligned " + htfDirLabel
        mtfStatusCol := htfDirCol
    else if mtfDisagreed
        mtfStatus := "✗ conflict " + htfDirLabel
        mtfStatusCol := bearClr
    else
        mtfStatus := htfDirLabel + " (no current edge)"
        mtfStatusCol := neuClr

// =============================================================================
//                       BQS-STYLE COMPONENT BREAKDOWN
// =============================================================================
// Transparent display of each component's contribution to posterior.
// Each "contribution" = how much that signal pushed posterior away from prior.

float airContrib   = airLO
float deltaContrib = deltaLO
float cvdContrib   = cvdLO
float accelContrib = accelLO
float mocContrib   = mocLO
float fpContrib    = fpLO
float auctionBQSContrib = auctionLO  // NEW: auction's contribution to log-odds

// Top driver: find the largest-magnitude Bayesian contribution
// Used for Compact mode's "Top:" row to preserve a sliver of transparency
string topDriverName = "—"
float topDriverVal = 0.0
float topDriverMax = math.abs(airContrib)
topDriverName := "AIR"
topDriverVal := airContrib
if math.abs(deltaContrib) > topDriverMax
    topDriverMax := math.abs(deltaContrib)
    topDriverName := "Δ bar"
    topDriverVal := deltaContrib
if math.abs(cvdContrib) > topDriverMax
    topDriverMax := math.abs(cvdContrib)
    topDriverName := "CVD"
    topDriverVal := cvdContrib
if math.abs(fpContrib) > topDriverMax
    topDriverMax := math.abs(fpContrib)
    topDriverName := "FP"
    topDriverVal := fpContrib
if math.abs(accelContrib) > topDriverMax
    topDriverMax := math.abs(accelContrib)
    topDriverName := "Δ AIR"
    topDriverVal := accelContrib
if math.abs(mocContrib) > topDriverMax
    topDriverMax := math.abs(mocContrib)
    topDriverName := "MOC"
    topDriverVal := mocContrib
if math.abs(auctionBQSContrib) > topDriverMax
    topDriverMax := math.abs(auctionBQSContrib)
    topDriverName := "Auction"
    topDriverVal := auctionBQSContrib

// Penalties (subtracted from bayesConf)
float riskPenalty   = riskElevated ? 0.20 : 0.0
float thrashPenaltyBQS = thrashScore * hawkesPenalty

// =============================================================================
//                       CO-FIRE (cross-dimension alignment)
// =============================================================================
// Counts how many independent microstructure dimensions point the same way.
// Dimensions: AIR, Δ bar, CVD, footprint pattern, divergence, MOC
// Each contributes +1 if aligned with posterior direction, 0 if neutral, -1 if opposed

int coFireCount = 0
int coFireMax = 0  // total dimensions checked

if bayesDir != 0
    // AIR
    if math.abs(nz(airSmoothed, 0)) > 0.15
        coFireMax := coFireMax + 1
        if (bayesDir > 0 and airSmoothed > 0) or (bayesDir < 0 and airSmoothed < 0)
            coFireCount := coFireCount + 1
    // Delta
    if math.abs(barDelta) > volume * 0.10
        coFireMax := coFireMax + 1
        if (bayesDir > 0 and barDelta > 0) or (bayesDir < 0 and barDelta < 0)
            coFireCount := coFireCount + 1
    // CVD
    if math.abs(cvdNorm) > 0.15
        coFireMax := coFireMax + 1
        if (bayesDir > 0 and cvd > 0) or (bayesDir < 0 and cvd < 0)
            coFireCount := coFireCount + 1
    // Footprint pattern
    if math.abs(patternCode) >= 1
        coFireMax := coFireMax + 1
        if (bayesDir > 0 and patternCode > 0) or (bayesDir < 0 and patternCode < 0)
            coFireCount := coFireCount + 1
    // Last MOC (if available)
    if not na(lastMocImb) and math.abs(lastMocImb) > 0.2
        coFireMax := coFireMax + 1
        if (bayesDir > 0 and lastMocImb > 0) or (bayesDir < 0 and lastMocImb < 0)
            coFireCount := coFireCount + 1
    // Liquidity sweep (if fired this bar)
    if sweepEnable and sweepDir != 0
        coFireMax := coFireMax + 1
        if (bayesDir > 0 and sweepDir > 0) or (bayesDir < 0 and sweepDir < 0)
            coFireCount := coFireCount + 1
    // Auction efficiency: efficient + directional = aligned
    if auctionEnable and not na(auctionEff) and auctionEff >= auctionEffHigh
        coFireMax := coFireMax + 1
        bool isNetBuyAuction = buyVolBar > sellVolBar
        if (bayesDir > 0 and isNetBuyAuction) or (bayesDir < 0 and not isNetBuyAuction)
            coFireCount := coFireCount + 1
    // Phase 3: multi-level OFI
    if ofiEnable and math.abs(ofiNorm) > 0.15
        coFireMax := coFireMax + 1
        if (bayesDir > 0 and ofiNorm > 0) or (bayesDir < 0 and ofiNorm < 0)
            coFireCount := coFireCount + 1
    // Phase 3: directional Hawkes intensity
    if hawkesIntEnable and math.abs(hawkesDir) > 0.20
        coFireMax := coFireMax + 1
        if (bayesDir > 0 and hawkesDir > 0) or (bayesDir < 0 and hawkesDir < 0)
            coFireCount := coFireCount + 1
    // Phase 4: cross-instrument confirmation
    if crossEnable and crossDir != 0
        coFireMax := coFireMax + 1
        if crossDir == bayesDir
            coFireCount := coFireCount + 1

float coFireRatio = coFireMax > 0 ? float(coFireCount) / coFireMax : 0.0
// CO-FIRE bonus: scaled to confidence (max 30% extra)
float coFireBonusVal = coFireEnable and coFireMax >= 3 ? math.min(0.30, coFireCount * coFireBonus) : 0.0
bool coFireFires = coFireEnable and coFireMax >= 3 and coFireCount >= 3

// =============================================================================
//                       FINAL CONFIDENCE COMPUTATION
// =============================================================================
// Backbone: Bayesian posterior (when enabled) OR additive regime score (fallback)
// Adjustments: risk penalty, thrash penalty, CO-FIRE bonus, MTF gate
//
// BONUS FIX 1 (v0.2.9): CHAOS override — when stability is CHAOS, suppress
// CO-FIRE bonus to zero. Chaos signals + alignment = noise reinforcing noise.
//
// BONUS FIX 2 (v0.2.9): MTF gate — when 'Aligned required' mode + disagreement,
// confidence forced toward zero (action falls back to WAIT below).

float baseConf = bayesEnable ? bayesConf : math.min(1.0, math.abs(regimeScore) / 3.0)

// CHAOS override: cancel CO-FIRE bonus when stability is CHAOS
float coFireBonusEff = thrashScore > 0.7 ? 0.0 : coFireBonusVal

// MTF gate: apply mode-dependent multiplier to confidence
float mtfMultiplier = 1.0
if mtfMode == "Aligned required"
    // Strict: disagreement forces confidence to near-zero (action becomes WAIT)
    if mtfDisagreed
        mtfMultiplier := 0.0
    else if mtfAligned and bayesDir != 0 and htfDir != 0
        // Bonus for genuine alignment
        mtfMultiplier := 1.0 + mtfAlignedBonus
else if mtfMode == "Aligned preferred"
    // Soft: disagreement downweights but doesn't kill
    if mtfDisagreed
        mtfMultiplier := mtfDisagreeDownweight
    else if mtfAligned and bayesDir != 0 and htfDir != 0
        mtfMultiplier := 1.0 + mtfAlignedBonus
// else "Ignore MTF": multiplier stays 1.0

float confidence = math.max(0.0, math.min(1.0, (baseConf - riskPenalty - thrashPenaltyBQS + coFireBonusEff + mhBonus) * mtfMultiplier))

// Effective direction: Bayesian when enabled, regime code when not
int effectiveDir = bayesEnable ? bayesDir : (regimeCode > 0 ? 1 : regimeCode < 0 ? -1 : 0)

// =============================================================================
//                       5-TIER CONFIDENCE LADDER
// =============================================================================

string confTier = "Tier 5"
string tierSize = "NO TRADE"
color  tierCol  = neuClr
int    tierCode = 5
if tier5Enable
    if confidence >= tier1Min
        confTier := "Tier 1"
        tierSize := "Full size"
        tierCol  := effectiveDir > 0 ? strongBull : strongBear
        tierCode := 1
    else if confidence >= tier2Min
        confTier := "Tier 2"
        tierSize := "75% size"
        tierCol  := effectiveDir > 0 ? bullClr : bearClr
        tierCode := 2
    else if confidence >= tier3Min
        confTier := "Tier 3"
        tierSize := "50% size"
        tierCol  := effectiveDir > 0 ? color.new(bullClr, 20) : color.new(bearClr, 20)
        tierCode := 3
    else if confidence >= tier4Min
        confTier := "Tier 4"
        tierSize := "25% size"
        tierCol  := color.new(#FFB800, 0)
        tierCode := 4
    else
        confTier := "Tier 5"
        tierSize := "NO TRADE"
        tierCol  := neuClr
        tierCode := 5

// =============================================================================
//                  VIEW MODE + STRONG-ONLY FILTERS
// =============================================================================
// Compact mode (default): table shows essential rows only.
// Strong-only mode (default): chart markers/lines render only on Tier 1/2
// confluence setups, drastically reducing chart clutter.

bool isCompact = viewMode == "Compact"
bool isStrongOnly = chartSignalMode == "Strong only"

// Strong-tier check: Tier 1 or Tier 2 only (top 2 of 5-tier ladder)
bool isStrongTier = tierCode <= 2

// CO-FIRE chart-render gate: strong-only requires Tier 1/2 AND 4+ dims aligned
bool coFireRenderOk = coFireEnable and coFireFires and (not isStrongOnly or (isStrongTier and coFireCount >= 4))

// Sweep chart-render gate: strong-only requires aligned-with-Bayesian sweep on strong tier
bool sweepBullRenderOk = sweepEnable and sweepBull and (not isStrongOnly or (isStrongTier and bayesDir > 0))
bool sweepBearRenderOk = sweepEnable and sweepBear and (not isStrongOnly or (isStrongTier and bayesDir < 0))

// Imbalance marker threshold: strong-only raises from 80% to 90%
float imbMarkerThreshold = isStrongOnly ? 0.90 : 0.80

// Entry/stop lines: strong-only requires Tier 1/2
bool entryRenderOk = confidence >= minConfidence and (not isStrongOnly or isStrongTier)

// =============================================================================
//                       ACTION DETERMINATION
// =============================================================================

string action = "WAIT"
color  actionCol = neuClr
string actionDetail = ""
string pivotNote = "—"

float entryLvl = na
float invalLvl = na

// Use pivot levels when available + enabled; fall back to mechanical buffer
bool usePivots = pivotEnable and not na(nearPvHighAbove) and not na(nearPvLowBelow)

if confidence >= minConfidence and effectiveDir != 0
    if effectiveDir > 0
        action := confidence >= tier1Min ? "STRONG BUY" : confidence >= tier3Min ? "BUY ON PULLBACK" : "WATCH BUY"
        actionCol := tierCol
        if usePivots
            entryLvl := nearPvHighAbove
            invalLvl := nearPvLowBelow
            pivotNote := "Pivot anchored (PH/PL)"
            actionDetail := "Enter on close above " + str.tostring(entryLvl, format.mintick) + " · stop " + str.tostring(invalLvl, format.mintick)
        else
            entryLvl := close + entryBuffer
            invalLvl := close - invalidBuffer
            pivotNote := "Mechanical buffer (no pivot found)"
            actionDetail := "Enter above " + str.tostring(entryLvl, format.mintick) + " · stop " + str.tostring(invalLvl, format.mintick)
    else
        action := confidence >= tier1Min ? "STRONG SELL" : confidence >= tier3Min ? "SELL ON BOUNCE" : "WATCH SELL"
        actionCol := tierCol
        if usePivots
            entryLvl := nearPvLowBelow
            invalLvl := nearPvHighAbove
            pivotNote := "Pivot anchored (PH/PL)"
            actionDetail := "Enter on close below " + str.tostring(entryLvl, format.mintick) + " · stop " + str.tostring(invalLvl, format.mintick)
        else
            entryLvl := close - entryBuffer
            invalLvl := close + invalidBuffer
            pivotNote := "Mechanical buffer (no pivot found)"
            actionDetail := "Enter below " + str.tostring(entryLvl, format.mintick) + " · stop " + str.tostring(invalLvl, format.mintick)
else
    action := "WAIT"
    actionCol := neuClr
    actionDetail := riskElevated ? "Risk elevated — VPIN/λ flagged" : thrashScore > 0.4 ? "Regime thrashing — chop suspected" : "Signal weak; standby"

// Reasoning bullets (max 4 lines)
string reason1 = ""
string reason2 = ""
string reason3 = ""
string reason4 = ""

if math.abs(nz(airSmoothed, 0)) > 0.3
    reason1 := "AIR " + (airSmoothed > 0 ? "+" : "") + str.tostring(airSmoothed, "0.00") + " · " + (airSmoothed > 0 ? "buy aggression" : "sell aggression")

if math.abs(deltaNorm) > 0.2
    reason2 := "Δ bar " + (barDelta > 0 ? "+" : "") + fmtNum(barDelta) + " · " + (barDelta > 0 ? "buyers active" : "sellers active")

if math.abs(cvdNorm) > 0.3
    reason3 := "CVD " + (cvd > 0 ? "+" : "") + fmtNum(cvd) + " · session " + (cvd > 0 ? "bullish" : "bearish")

if riskElevated
    reason4 := (toxicFlow ? "⚠ Toxic flow (VPIN " + str.tostring(vpin, "0.00") + ")" : "") + (thinLiquid ? " ⚠ Thin liquidity" : "")
else if not na(mocImbalance) and math.abs(mocImbalance) > 0.4
    reason4 := "MOC " + (mocImbalance > 0 ? "+" : "") + str.tostring(mocImbalance, "0.00") + " institutional " + (mocImbalance > 0 ? "buying" : "selling")
else if math.abs(patternCode) >= 1 and not na(imbalancePrice)
    reason4 := "Footprint " + patternName + " · imb @ " + str.tostring(imbalancePrice, format.mintick)

// =============================================================================
//                          ON-CHART VISUALIZATION
// =============================================================================

// Background tint priority: divergence > regime (divergence is rarer + more actionable)
color regBg = showRegimeBg ? color.new(regimeCol, 92) : na
color divBg = showDivergence and colorDivBars and divergence ? divBgColor : na
bgcolor(not na(divBg) ? divBg : regBg, title = "BG tint (regime/divergence)")

// Entry / Invalidation lines (rendered only on last bar)
var line entryLine = na
var line invalLine = na
var label entryLbl = na
var label invalLbl = na

if showSignals and barstate.islast
    if not na(entryLine)
        line.delete(entryLine)
    if not na(invalLine)
        line.delete(invalLine)
    if not na(entryLbl)
        label.delete(entryLbl)
    if not na(invalLbl)
        label.delete(invalLbl)
    if not na(entryLvl) and entryRenderOk
        entryLine := line.new(bar_index - 20, entryLvl, bar_index + 10, entryLvl, color = actionCol, style = line.style_dashed, width = 1, extend = extend.right)
        entryLbl  := label.new(bar_index + 10, entryLvl, "ENTRY " + str.tostring(entryLvl, format.mintick), xloc = xloc.bar_index, yloc = yloc.price, color = color.new(actionCol, 70), textcolor = color.white, style = label.style_label_left, size = size.small)
    if not na(invalLvl) and entryRenderOk
        invalLine := line.new(bar_index - 20, invalLvl, bar_index + 10, invalLvl, color = color.new(color.red, 30), style = line.style_dotted, width = 1, extend = extend.right)
        invalLbl  := label.new(bar_index + 10, invalLvl, "STOP " + str.tostring(invalLvl, format.mintick), xloc = xloc.bar_index, yloc = yloc.price, color = color.new(color.red, 70), textcolor = color.white, style = label.style_label_left, size = size.small)

// CO-FIRE badge — small label above bar when 3+ dimensions align (strong-only mode raises bar to Tier 1/2 + 4+ dims)
if coFireShowBadge and coFireRenderOk
    string cfTxt = "CF " + str.tostring(coFireCount) + "/" + str.tostring(coFireMax)
    color  cfCol = effectiveDir > 0 ? bullClr : bearClr
    label.new(bar_index, high + (high - low) * 0.05, cfTxt, xloc = xloc.bar_index, yloc = yloc.price, color = color.new(cfCol, 30), textcolor = color.white, style = label.style_label_down, size = size.tiny)

// Liquidity sweep markers — ⚡ symbol below bull-sweep low / above bear-sweep high (strong-only adds Tier 1/2 + Bayesian alignment gate)
sizeMap(string s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Normal" ? size.normal : size.large

if sweepShowMarker
    if sweepBullRenderOk
        label.new(bar_index, low - (high - low) * 0.10, "⚡", xloc = xloc.bar_index, yloc = yloc.price, color = color.new(bullClr, 30), textcolor = color.white, style = label.style_label_up, size = sizeMap(sweepMarkerSize))
    if sweepBearRenderOk
        label.new(bar_index, high + (high - low) * 0.10, "⚡", xloc = xloc.bar_index, yloc = yloc.price, color = color.new(bearClr, 30), textcolor = color.white, style = label.style_label_down, size = sizeMap(sweepMarkerSize))

// ── FULL-HISTORY SIGNAL MARKERS (plotshape: every bar, no object cap) ────────
// label.new/line.new above are limited to 500 objects and GC oldest-first, so
// they only cover recent history. These plotshape markers render across ALL
// loaded bars so you can see every past signal. Each is one plot.
int  histTierMax = histSignalTiers == "Tier 1 only" ? 1 : histSignalTiers == "Tier 1+2" ? 2 : 3
bool sigActive   = confidence >= minConfidence and tierCode <= histTierMax
bool histLong    = histSignals and sigActive and effectiveDir > 0
bool histShort   = histSignals and sigActive and effectiveDir < 0
bool histLongT1  = histLong  and tierCode == 1
bool histLongT2  = histLong  and tierCode >= 2
bool histShortT1 = histShort and tierCode == 1
bool histShortT2 = histShort and tierCode >= 2
plotshape(histLongT1,  "Hist STRONG BUY",  style = shape.triangleup,   location = location.belowbar, color = strongBull, size = size.small, display = display.all)
plotshape(histLongT2,  "Hist BUY",         style = shape.triangleup,   location = location.belowbar, color = bullClr,    size = size.tiny,  display = display.all)
plotshape(histShortT1, "Hist STRONG SELL", style = shape.triangledown, location = location.abovebar, color = strongBear, size = size.small, display = display.all)
plotshape(histShortT2, "Hist SELL",        style = shape.triangledown, location = location.abovebar, color = bearClr,    size = size.tiny,  display = display.all)


// =============================================================================
//                         FOOTPRINT BOX RENDERING
// =============================================================================
// Strategy: render boxes for THIS bar each time it executes. Pine's garbage
// collector auto-deletes oldest boxes when limit hit. With max_boxes_count=500
// and fpBins=8 boxes per bar, we keep ~62 most recent bars worth (~5 hours
// on 5m chart). User's fpBars setting controls rendering eligibility, but
// auto-GC handles cleanup. We also gate render on volume (skip dead-zone bars).
//
// Imbalance markers use labels with auto-cleanup (max_labels_count=300).
// Display mode controls whether boxes vs delta candles vs both are shown.

bool fpEnabled = displayMode == "Footprint Only" or displayMode == "Both (dense)"
bool shouldRenderFp = showFootprint and fpEnabled and barDataOk and volume > volAvg20 * fpMinVol and barRange > 0 and binSize > 0

if shouldRenderFp
    // Find max bin volume + index of POC (peak volume bin)
    float maxBinV = 0.0
    int   pocIdx  = -1
    for j = 0 to fpBins - 1
        float tv = array.get(binBuyVol, j) + array.get(binSellVol, j)
        if tv > maxBinV
            maxBinV := tv
            pocIdx  := j

    if maxBinV > 0
        float widthHalf = fpBoxWidthPct / 200.0
        int boxLeft  = bar_index
        int boxRight = bar_index + 1

        for j = 0 to fpBins - 1
            float bv = array.get(binBuyVol,  j)
            float sv = array.get(binSellVol, j)
            float tv = bv + sv

            if tv > 0
                // Bin price range — supports both bar-range and percentage bin sizing
                float binBottom = low + j * binSize
                float binTop    = binBottom + binSize
                // Clip to bar range so percentage-mode bins don't extend beyond bar
                binTop    := math.min(binTop, high)
                binBottom := math.max(binBottom, low)
                if binTop <= binBottom
                    continue

                float buyPct = bv / tv
                float sellPct = sv / tv

                color binCol = neuClr
                if buyPct >= 0.55
                    binCol := bullClr
                else if sellPct >= 0.55
                    binCol := bearClr

                float volRatio = tv / maxBinV
                int alphaVal = int(fpAlphaMin - (fpAlphaMin - fpAlphaMax) * volRatio)
                alphaVal := math.max(fpAlphaMax, math.min(fpAlphaMin, alphaVal))

                color boxBg = color.new(binCol, alphaVal)

                // POC highlight: distinct border for the peak-volume bin
                bool isPoc = fpShowPoc and j == pocIdx
                color boxBorder = isPoc ? fpPocColor : color.new(binCol, 90)
                int   boxBorderW = isPoc ? 2 : 1

                box.new(boxLeft, binTop, boxRight, binBottom, border_color = boxBorder, border_width = boxBorderW, bgcolor = boxBg)

                // Imbalance marker — only on the strongest imbalance bin, and only when
                // imbalance is STRONG (>= 0.80) to prevent visual clutter from common
                // 65% imbalances. Also restricted to recent bars via fpMarkerBars input.
                bool strongImbalance = not na(imbalancePct) and imbalancePct >= imbMarkerThreshold
                if strongImbalance and not na(imbalancePrice) and j == int(math.floor((imbalancePrice - low) / binSize))
                    float midPrice = (binBottom + binTop) / 2.0
                    string markerTxt = imbalanceSide > 0 ? "▲" : "▼"
                    color markerCol = imbalanceSide > 0 ? bullClr : bearClr
                    label.new(bar_index, midPrice, markerTxt, xloc = xloc.bar_index, yloc = yloc.price, color = color.new(color.black, 100), textcolor = markerCol, style = label.style_none, size = size.small)

// =============================================================================
//                  EMBEDDED DELTA CANDLE & DIVERGENCE BG
// =============================================================================
// Delta candle: small inner-fill candle inside each bar body showing delta %
// Divergence bg: tint background of divergent bars (toggle)

bool dcEnabled = displayMode == "Compact (delta candles only)" or displayMode == "Both (dense)"
bool shouldRenderDc = showDeltaCandle and dcEnabled and barDataOk and not na(dcValue) and not na(dcBase)

// plotcandle renders only when not na — gate via na assignments
float pcBase  = shouldRenderDc ? dcBase  : na
float pcValue = shouldRenderDc ? dcValue : na
plotcandle(pcBase, pcBase, pcValue, pcValue, "Delta candle", color = dcCol, wickcolor = na, bordercolor = na, display = display.all - display.status_line)
// Note: divergence background tint is handled by the merged bgcolor() call earlier in the script
// =============================================================================
//                                DECISION TABLE
// =============================================================================

posMap(string p) =>
    result = p == "top_left" ? position.top_left : p == "top_right" ? position.top_right : p == "bottom_left" ? position.bottom_left : p == "bottom_right" ? position.bottom_right : p == "middle_left" ? position.middle_left : position.middle_right
    result

szMap(string s) =>
    result = s == "tiny" ? size.tiny : s == "small" ? size.small : size.normal
    result

var table dash = table.new(posMap(tablePos), 3, 52, bgcolor = color.new(color.gray, 90), frame_color = color.new(color.gray, 50), frame_width = 1, border_color = color.new(color.gray, 80), border_width = 1)

if showDash and barstate.islast
    // Adaptive theme: read chart background luminance and pick a light or dark
    // panel so the table stays readable on any chart color scheme.
    color _cbg = chart.bg_color
    float _bgLum = na(_cbg) ? 20.0 : (0.299 * color.r(_cbg) + 0.587 * color.g(_cbg) + 0.114 * color.b(_cbg))
    bool isLightBg = _bgLum > 140
    color txtMain = isLightBg ? #0E1014 : #E6EDF3
    color txtDim  = isLightBg ? color.new(#262A30, 0) : color.new(color.silver, 30)
    color accent  = isLightBg ? #16438C : #58A6FF
    color hdrBg   = isLightBg ? color.new(#E3E8EF, 0) : color.new(#161B22, 0)
    color rowBg   = isLightBg ? color.new(#F4F6F9, 0) : color.new(#0D1117, 20)
    color sep     = isLightBg ? color.new(#D5DBE2, 0) : color.new(#21262D, 0)
    // Adaptive VALUE palette: on a light chart the neon bull/bear/neutral inks are
    // illegible, so darken them to dense, saturated equivalents. On dark charts the
    // originals are kept. cWarn replaces the inline amber.
    color cBull  = isLightBg ? darken(bullClr, 0.52)    : bullClr
    color cBear  = isLightBg ? darken(bearClr, 0.62)    : bearClr
    color cNeu   = isLightBg ? darken(neuClr, 0.55)     : neuClr
    color cWarn  = isLightBg ? #8A5200 : #FFB800
    // Precomputed semantic colors come from the logic above (neon-tuned); darken
    // them too so ACTION / Regime / Tier / Stability / MTF / Auction read on light.
    if isLightBg
        actionCol    := darken(actionCol, 0.55)
        regimeCol    := darken(regimeCol, 0.55)
        tierCol      := darken(tierCol, 0.55)
        stabilityCol := darken(stabilityCol, 0.55)
        mtfStatusCol := darken(mtfStatusCol, 0.55)
        auctionCol   := darken(auctionCol, 0.55)
        htfDirCol    := darken(htfDirCol, 0.55)
        htf2DirCol   := darken(htf2DirCol, 0.55)
    sz     = szMap(tableSize)
    szSml  = size.tiny

    int r = 0

    // ─── HEADER ──────────────────────────────────────────
    table.cell(dash, 0, r, "ORDER FLOW ENGINE", text_color = accent, bgcolor = hdrBg, text_size = sz, text_halign = text.align_left)
    table.cell(dash, 1, r, timeframe.period + "+" + subTfStr, text_color = txtMain, bgcolor = hdrBg, text_size = szSml)
    statusTxt = (fpDataSource == "NATIVE" ? "◆NAT " : "") + (tfDegraded ? "⚡ DEGRADED" : barDataOk ? "● LIVE" : "⚠ STALE")
    statusCol = tfDegraded ? color.new(cWarn, 0) : barDataOk ? cBull : cBear
    table.cell(dash, 2, r, statusTxt, text_color = statusCol, bgcolor = hdrBg, text_size = szSml, text_halign = text.align_right)
    r := r + 1

    // ─── ASSET CLASS ROW ─────────────────────────────────
    string acTuningLabel = ""
    color  acTuningCol   = cNeu
    if assetClass == "NIFTY"
        acTuningLabel := "Tuned"
        acTuningCol   := cBull
    else if classMatches
        acTuningLabel := "Preset · validate"
        acTuningCol   := color.new(cWarn, 0)
    else
        acTuningLabel := "⚠ Mismatch"
        acTuningCol   := cBear
    table.cell(dash, 0, r, "Asset", text_color = txtDim, bgcolor = rowBg, text_size = szSml, text_halign = text.align_left)
    table.cell(dash, 1, r, assetClass, text_color = accent, bgcolor = rowBg, text_size = szSml, text_halign = text.align_center)
    table.cell(dash, 2, r, acTuningLabel, text_color = acTuningCol, bgcolor = rowBg, text_size = szSml, text_halign = text.align_right)
    r := r + 1

    // ─── ACTION SECTION (collapsible) ────────────────────
    if showSecAction
        // Tier-graded background: vivid for Tier 1, dim for Tier 5
        // Direction-colored (green/red for buy/sell, gray for WAIT)
        color tierBg  = sep        // default fallback
        color actTxt  = txtMain    // default dark text (WAIT / gray stripe)
        if effectiveDir != 0 and confidence >= minConfidence
            // Active trade direction — color by tier strength
            color baseDir = effectiveDir > 0 ? cBull : cBear
            int baseT = tierCode == 1 ? 50 : tierCode == 2 ? 65 : tierCode == 3 ? 78 : tierCode == 4 ? 85 : 92
            // On light charts, make the stripe much more solid so bright text reads.
            int tierTransparency = isLightBg ? math.max(12, baseT - 45) : baseT
            tierBg := color.new(baseDir, tierTransparency)
            actTxt := isLightBg ? color.white : actionCol
        else if tierCode == 4
            // Tier 4 weak — amber tint regardless of direction
            tierBg := color.new(cWarn, isLightBg ? 40 : 85)
            actTxt := isLightBg ? color.white : actionCol
        // else Tier 5 / WAIT: keep default sep (dim gray) + dark text

        table.cell(dash, 0, r, "ACTION", text_color = txtDim, bgcolor = tierBg, text_size = szSml, text_halign = text.align_left)
        table.cell(dash, 1, r, action, text_color = actTxt, bgcolor = tierBg, text_size = sz, text_halign = text.align_center)
        confTxt = str.tostring(confidence * 100, "0") + "%"
        table.cell(dash, 2, r, confTxt, text_color = actTxt, bgcolor = tierBg, text_size = sz, text_halign = text.align_right)
        r := r + 1

        // Tier (5-tier ladder)
        if tier5Enable
            table.cell(dash, 0, r, "Tier", text_color = txtDim, bgcolor = rowBg, text_size = szSml, text_halign = text.align_left)
            table.cell(dash, 1, r, confTier, text_color = tierCol, bgcolor = rowBg, text_size = szSml, text_halign = text.align_center)
            table.cell(dash, 2, r, tierSize, text_color = tierCol, bgcolor = rowBg, text_size = szSml, text_halign = text.align_right)
            r := r + 1

        // Plan (hidden in Compact mode)
        if not isCompact
            table.cell(dash, 0, r, "Plan", text_color = txtDim, bgcolor = rowBg, text_size = szSml, text_halign = text.align_left)
            table.cell(dash, 1, r, actionDetail, text_color = txtMain, bgcolor = rowBg, text_size = szSml, text_halign = text.align_left)
            table.cell(dash, 2, r, "", text_color = txtMain, bgcolor = rowBg, text_size = szSml)
            r := r + 1

        // Entry/Invalidation
        entryStr = na(entryLvl) ? "—" : str.tostring(entryLvl, format.mintick)
        invalStr = na(invalLvl) ? "—" : str.tostring(invalLvl, format.mintick)
        table.cell(dash, 0, r, "Entry / Stop", text_color = txtDim, bgcolor = rowBg, text_size = szSml, text_halign = text.align_left)
        table.cell(dash, 1, r, entryStr, text_color = actionCol, bgcolor = rowBg, text_size = szSml, text_halign = text.align_center)
        table.cell(dash, 2, r, invalStr, text_color = color.new(color.red, 20), bgcolor = rowBg, text_size = szSml, text_halign = text.align_right)
        r := r + 1

        // Pivot anchor note (hidden in Compact mode)
        if pivotEnable and not isCompact
            color pvCol = usePivots ? cBull : cNeu
            table.cell(dash, 0, r, "Anchor", text_color = txtDim, bgcolor = rowBg, text_size = szSml, text_halign = text.align_left)
            table.cell(dash, 1, r, pivotNote, text_color = pvCol, bgcolor = rowBg, text_size = szSml, text_halign = text.align_left)
            table.cell(dash, 2, r, "", bgcolor = rowBg)
            r := r + 1

        // CO-FIRE status — in Compact mode, only show when actually firing
        bool showCoFireRow = coFireEnable and coFireMax > 0 and (not isCompact or coFireFires)
        if showCoFireRow
            cfStat = str.tostring(coFireCount) + "/" + str.tostring(coFireMax) + " dims align"
            cfBonus = coFireBonusVal > 0 ? "+" + str.tostring(coFireBonusVal * 100, "0") + "%" : "—"
            color cfStatCol = coFireFires ? (effectiveDir > 0 ? cBull : cBear) : cNeu
            table.cell(dash, 0, r, "CO-FIRE", text_color = txtDim, bgcolor = rowBg, text_size = szSml, text_halign = text.align_left)
            table.cell(dash, 1, r, cfStat, text_color = cfStatCol, bgcolor = rowBg, text_size = szSml)
            table.cell(dash, 2, r, cfBonus, text_color = cfStatCol, bgcolor = rowBg, text_size = szSml, text_halign = text.align_right)
            r := r + 1

        // MTF Confluence row (Compact + Full both show this when MTF active)
        if mtfActive
            string mtfRight = ""
            if mtf2Enable
                // Dual HTF: show both timeframes
                mtfRight := mtfHtf + "/" + mtfHtf2 + " · " + str.tostring(htfPosterior * 100, "0") + "/" + str.tostring(htf2Posterior * 100, "0") + "%"
            else
                mtfRight := mtfHtf + " · " + str.tostring(htfPosterior * 100, "0") + "%"
            table.cell(dash, 0, r, "MTF", text_color = txtDim, bgcolor = rowBg, text_size = szSml, text_halign = text.align_left)
            table.cell(dash, 1, r, mtfStatus, text_color = mtfStatusCol, bgcolor = rowBg, text_size = szSml)
            table.cell(dash, 2, r, mtfRight, text_color = mtfStatusCol, bgcolor = rowBg, text_size = szSml, text_halign = text.align_right)
            r := r + 1

        // Top driver row — Compact mode only (preserves transparency about which signal drives the call)
        if isCompact and bayesEnable
            color tdCol = topDriverVal > 0.1 ? cBull : topDriverVal < -0.1 ? cBear : cNeu
            string tdStr = topDriverName + " " + str.tostring(topDriverVal, "+0.00;-0.00")
            table.cell(dash, 0, r, "Top", text_color = txtDim, bgcolor = rowBg, text_size = szSml, text_halign = text.align_left)
            table.cell(dash, 1, r, tdStr, text_color = tdCol, bgcolor = rowBg, text_size = szSml)
            table.cell(dash, 2, r, "driver", text_color = txtDim, bgcolor = rowBg, text_size = szSml, text_halign = text.align_right)
            r := r + 1

    // ─── REGIME SECTION (collapsible) ────────────────────
    if showSecRegime
        table.cell(dash, 0, r, "REGIME", text_color = txtDim, bgcolor = sep, text_size = szSml, text_halign = text.align_left)
        table.cell(dash, 1, r, regimeName, text_color = regimeCol, bgcolor = sep, text_size = sz, text_halign = text.align_center)
        table.cell(dash, 2, r, "score " + str.tostring(regimeScore, "0.00"), text_color = regimeCol, bgcolor = sep, text_size = szSml, text_halign = text.align_right)
        r := r + 1

        // Stability (Hawkes) — only show if enabled
        if hawkesEnable
            stabIcon = thrashScore > 0.7 ? "⚠" : thrashScore > 0.4 ? "~" : "●"
            stabRight = "thrash " + str.tostring(thrashScore * 100, "0") + "%"
            table.cell(dash, 0, r, "Stability", text_color = txtDim, bgcolor = rowBg, text_size = szSml, text_halign = text.align_left)
            table.cell(dash, 1, r, stabIcon + " " + stabilityLabel, text_color = stabilityCol, bgcolor = rowBg, text_size = szSml)
            table.cell(dash, 2, r, stabRight, text_color = stabilityCol, bgcolor = rowBg, text_size = szSml, text_halign = text.align_right)
            r := r + 1

    // ─── BQS BREAKDOWN SECTION (collapsible) ─────────────
    if showSecBQS and bayesEnable and not isCompact
        table.cell(dash, 0, r, "── BQS BREAKDOWN ──", text_color = accent, bgcolor = hdrBg, text_size = szSml, text_halign = text.align_left)
        table.cell(dash, 1, r, str.tostring(posterior * 100, "0") + "%", text_color = posterior > 0.5 ? cBull : cBear, bgcolor = hdrBg, text_size = szSml, text_halign = text.align_center)
        table.cell(dash, 2, r, "posterior", text_color = txtDim, bgcolor = hdrBg, text_size = szSml, text_halign = text.align_right)
        r := r + 1

        // AIR contribution
        color airBQS = airContrib > 0.1 ? cBull : airContrib < -0.1 ? cBear : cNeu
        table.cell(dash, 0, r, "AIR", text_color = txtDim, bgcolor = rowBg, text_size = szSml, text_halign = text.align_left)
        table.cell(dash, 1, r, str.tostring(airContrib, "+0.00;-0.00"), text_color = airBQS, bgcolor = rowBg, text_size = szSml)
        table.cell(dash, 2, r, bqsViz(airContrib), text_color = airBQS, bgcolor = rowBg, text_size = szSml, text_halign = text.align_right)
        r := r + 1

        // Δ bar contribution
        color dBQS = deltaContrib > 0.1 ? cBull : deltaContrib < -0.1 ? cBear : cNeu
        table.cell(dash, 0, r, "Δ bar", text_color = txtDim, bgcolor = rowBg, text_size = szSml, text_halign = text.align_left)
        table.cell(dash, 1, r, str.tostring(deltaContrib, "+0.00;-0.00"), text_color = dBQS, bgcolor = rowBg, text_size = szSml)
        table.cell(dash, 2, r, bqsViz(deltaContrib), text_color = dBQS, bgcolor = rowBg, text_size = szSml, text_halign = text.align_right)
        r := r + 1

        // CVD contribution
        color cBQS = cvdContrib > 0.1 ? cBull : cvdContrib < -0.1 ? cBear : cNeu
        table.cell(dash, 0, r, "CVD", text_color = txtDim, bgcolor = rowBg, text_size = szSml, text_halign = text.align_left)
        table.cell(dash, 1, r, str.tostring(cvdContrib, "+0.00;-0.00"), text_color = cBQS, bgcolor = rowBg, text_size = szSml)
        table.cell(dash, 2, r, bqsViz(cvdContrib), text_color = cBQS, bgcolor = rowBg, text_size = szSml, text_halign = text.align_right)
        r := r + 1

        // Footprint contribution
        color fBQS = fpContrib > 0.1 ? cBull : fpContrib < -0.1 ? cBear : cNeu
        table.cell(dash, 0, r, "FP", text_color = txtDim, bgcolor = rowBg, text_size = szSml, text_halign = text.align_left)
        table.cell(dash, 1, r, str.tostring(fpContrib, "+0.00;-0.00"), text_color = fBQS, bgcolor = rowBg, text_size = szSml)
        table.cell(dash, 2, r, bqsViz(fpContrib), text_color = fBQS, bgcolor = rowBg, text_size = szSml, text_halign = text.align_right)
        r := r + 1

        // Auction efficiency contribution
        if auctionEnable
            color aBQS = auctionBQSContrib > 0.1 ? cBull : auctionBQSContrib < -0.1 ? cBear : cNeu
            table.cell(dash, 0, r, "Auction", text_color = txtDim, bgcolor = rowBg, text_size = szSml, text_halign = text.align_left)
            table.cell(dash, 1, r, str.tostring(auctionBQSContrib, "+0.00;-0.00"), text_color = aBQS, bgcolor = rowBg, text_size = szSml)
            table.cell(dash, 2, r, bqsViz(auctionBQSContrib), text_color = aBQS, bgcolor = rowBg, text_size = szSml, text_halign = text.align_right)
            r := r + 1

        // Penalties summary
        penTxt = "risk -" + str.tostring(riskPenalty, "0.00") + " · thrash -" + str.tostring(thrashPenaltyBQS, "0.00")
        table.cell(dash, 0, r, "Penalties", text_color = txtDim, bgcolor = rowBg, text_size = szSml, text_halign = text.align_left)
        table.cell(dash, 1, r, penTxt, text_color = txtDim, bgcolor = rowBg, text_size = szSml, text_halign = text.align_left)
        table.cell(dash, 2, r, "", bgcolor = rowBg)
        r := r + 1

        // Decorrelation (Phase 2): shows flow-family effective independence
        color decCol = fusionMode == "Decorrelated" ? (fusionShrink < 0.6 ? color.new(cWarn, 0) : cBull) : txtDim
        string decTxt = fusionMode == "Decorrelated" ? "×" + str.tostring(fusionShrink, "0.00") + " (ρ̄ " + str.tostring(rhoBar, "0.00") + ")" : "legacy (off)"
        string decRight = fusionMode == "Decorrelated" ? "N_eff " + str.tostring(nEff, "0.0") + "/5" : "—"
        table.cell(dash, 0, r, "Decorrel", text_color = txtDim, bgcolor = rowBg, text_size = szSml, text_halign = text.align_left)
        table.cell(dash, 1, r, decTxt, text_color = decCol, bgcolor = rowBg, text_size = szSml, text_halign = text.align_left)
        table.cell(dash, 2, r, decRight, text_color = decCol, bgcolor = rowBg, text_size = szSml, text_halign = text.align_right)
        r := r + 1

    // ─── PRESSURE METRICS (collapsible) ──────────────────
    if showSecPressure and not isCompact
        table.cell(dash, 0, r, "── PRESSURE ──", text_color = accent, bgcolor = hdrBg, text_size = szSml, text_halign = text.align_left)
        table.cell(dash, 1, r, "", bgcolor = hdrBg)
        table.cell(dash, 2, r, "", bgcolor = hdrBg)
        r := r + 1

        // Δ bar
        deltaSign = barDelta > 0 ? "▲" : barDelta < 0 ? "▼" : "·"
        deltaC = barDelta > 0 ? cBull : barDelta < 0 ? cBear : cNeu
        table.cell(dash, 0, r, "Δ bar", text_color = txtDim, bgcolor = rowBg, text_size = szSml, text_halign = text.align_left)
        table.cell(dash, 1, r, deltaSign + " " + fmtNum(math.abs(barDelta)), text_color = deltaC, bgcolor = rowBg, text_size = szSml)
        table.cell(dash, 2, r, "sub " + str.tostring(nClassified) + "/" + str.tostring(nSubBars), text_color = txtDim, bgcolor = rowBg, text_size = szSml, text_halign = text.align_right)
        r := r + 1

        // CVD
        cvdSign = cvd > 0 ? "▲" : cvd < 0 ? "▼" : "·"
        cvdC = cvd > 0 ? cBull : cvd < 0 ? cBear : cNeu
        table.cell(dash, 0, r, "CVD", text_color = txtDim, bgcolor = rowBg, text_size = szSml, text_halign = text.align_left)
        table.cell(dash, 1, r, cvdSign + " " + fmtNum(math.abs(cvd)), text_color = cvdC, bgcolor = rowBg, text_size = szSml)
        table.cell(dash, 2, r, "session", text_color = txtDim, bgcolor = rowBg, text_size = szSml, text_halign = text.align_right)
        r := r + 1

        // AIR
        airC = na(airSmoothed) ? cNeu : airSmoothed > 0.2 ? cBull : airSmoothed < -0.2 ? cBear : cNeu
        airTxt = na(airSmoothed) ? "—" : str.tostring(airSmoothed, "0.00")
        airLabel = na(airSmoothed) ? "warm-up" : math.abs(airSmoothed) > 0.4 ? "STRONG" : math.abs(airSmoothed) > 0.2 ? "medium" : "balanced"
        table.cell(dash, 0, r, "AIR", text_color = txtDim, bgcolor = rowBg, text_size = szSml, text_halign = text.align_left)
        table.cell(dash, 1, r, airTxt, text_color = airC, bgcolor = rowBg, text_size = szSml)
        table.cell(dash, 2, r, airLabel, text_color = airC, bgcolor = rowBg, text_size = szSml, text_halign = text.align_right)
        r := r + 1

        // Δ AIR
        accC = na(airAccel) ? cNeu : airAccel > 0.05 ? cBull : airAccel < -0.05 ? cBear : cNeu
        accTxt = na(airAccel) ? "—" : str.tostring(airAccel, "0.00")
        accLab = na(airAccel) ? "—" : math.abs(airAccel) > 0.1 ? "ACCEL" : "stable"
        table.cell(dash, 0, r, "Δ AIR", text_color = txtDim, bgcolor = rowBg, text_size = szSml, text_halign = text.align_left)
        table.cell(dash, 1, r, accTxt, text_color = accC, bgcolor = rowBg, text_size = szSml)
        table.cell(dash, 2, r, accLab, text_color = accC, bgcolor = rowBg, text_size = szSml, text_halign = text.align_right)
        r := r + 1

        // ER (Kaufman Efficiency Ratio) — show even if disabled, just label "off"
        if erEnable
            erC = er > erThreshTrend ? cBull : er < erThreshChop ? cBear : cNeu
            erLab = er > erThreshTrend ? "TREND" : er < erThreshChop ? "chop" : "mixed"
            erRight = "α=" + str.tostring(erAlpha, "0.00")
            table.cell(dash, 0, r, "ER", text_color = txtDim, bgcolor = rowBg, text_size = szSml, text_halign = text.align_left)
            table.cell(dash, 1, r, str.tostring(er, "0.00") + " " + erLab, text_color = erC, bgcolor = rowBg, text_size = szSml)
            table.cell(dash, 2, r, erRight, text_color = txtDim, bgcolor = rowBg, text_size = szSml, text_halign = text.align_right)
            r := r + 1

        // Buy %
        bsRatio = totalActiveVol > 0 ? buyVolBar / totalActiveVol * 100 : 50
        bsC = bsRatio > 60 ? cBull : bsRatio < 40 ? cBear : cNeu
        table.cell(dash, 0, r, "Buy %", text_color = txtDim, bgcolor = rowBg, text_size = szSml, text_halign = text.align_left)
        table.cell(dash, 1, r, str.tostring(bsRatio, "0") + "%", text_color = bsC, bgcolor = rowBg, text_size = szSml)
        table.cell(dash, 2, r, str.tostring(100 - bsRatio, "0") + "% sell", text_color = bsC, bgcolor = rowBg, text_size = szSml, text_halign = text.align_right)
        r := r + 1

        // Vol Gate
        vgStat = volPass ? "PASS" : "low"
        vgC = volPass ? cBull : txtDim
        table.cell(dash, 0, r, "Vol gate", text_color = txtDim, bgcolor = rowBg, text_size = szSml, text_halign = text.align_left)
        table.cell(dash, 1, r, vgStat, text_color = vgC, bgcolor = rowBg, text_size = szSml)
        table.cell(dash, 2, r, str.tostring(volume / nz(volAvg20, 1), "0.0") + "×", text_color = txtMain, bgcolor = rowBg, text_size = szSml, text_halign = text.align_right)
        r := r + 1

    // ─── INSTITUTIONAL / RISK (collapsible) ──────────────
    if showSecInst and not isCompact
        table.cell(dash, 0, r, "── INSTITUTIONAL ──", text_color = accent, bgcolor = hdrBg, text_size = szSml, text_halign = text.align_left)
        table.cell(dash, 1, r, "", bgcolor = hdrBg)
        table.cell(dash, 2, r, "", bgcolor = hdrBg)
        r := r + 1

        // MOC
        mocC = cNeu
        mocTxt = "—"
        mocLab = "off-window"
        if inMocWin and not na(mocImbalance)
            mocC := mocImbalance > 0.2 ? cBull : mocImbalance < -0.2 ? cBear : cNeu
            mocTxt := (mocImbalance > 0 ? "+" : "") + str.tostring(mocImbalance, "0.00")
            mocLab := mocStrong ? "STRONG" : math.abs(mocImbalance) > 0.4 ? "medium" : "weak"
        else if not na(lastMocImb)
            mocC := lastMocImb > 0.2 ? cBull : lastMocImb < -0.2 ? cBear : cNeu
            mocTxt := "last " + (lastMocImb > 0 ? "+" : "") + str.tostring(lastMocImb, "0.00")
            mocLab := "closed"
        table.cell(dash, 0, r, "MOC imb", text_color = txtDim, bgcolor = rowBg, text_size = szSml, text_halign = text.align_left)
        table.cell(dash, 1, r, mocTxt, text_color = mocC, bgcolor = rowBg, text_size = szSml)
        table.cell(dash, 2, r, mocLab, text_color = mocC, bgcolor = rowBg, text_size = szSml, text_halign = text.align_right)
        r := r + 1

        // VPIN
        vpinC = na(vpin) ? cNeu : vpin > 0.4 ? cBear : vpin > 0.3 ? color.new(color.yellow, 30) : cBull
        vpinTxt = na(vpin) ? "—" : str.tostring(vpin, "0.00")
        vpinLab = na(vpin) ? "warm-up" : vpin > 0.4 ? "TOXIC" : vpin > 0.3 ? "elevated" : "normal"
        table.cell(dash, 0, r, "VPIN", text_color = txtDim, bgcolor = rowBg, text_size = szSml, text_halign = text.align_left)
        table.cell(dash, 1, r, vpinTxt, text_color = vpinC, bgcolor = rowBg, text_size = szSml)
        table.cell(dash, 2, r, vpinLab, text_color = vpinC, bgcolor = rowBg, text_size = szSml, text_halign = text.align_right)
        r := r + 1

        // Kyle's Lambda
        lamC = na(lambdaPctile) ? cNeu : lambdaPctile > 70 ? cBear : lambdaPctile < 30 ? cBull : cNeu
        lamTxt = na(lambdaSm) ? "—" : str.tostring(lambdaSm, "0.0000")
        lamLab = na(lambdaPctile) ? "warm-up" : lambdaPctile > 70 ? "THIN" : lambdaPctile < 30 ? "liquid" : "normal"
        table.cell(dash, 0, r, "Kyle λ", text_color = txtDim, bgcolor = rowBg, text_size = szSml, text_halign = text.align_left)
        table.cell(dash, 1, r, lamTxt, text_color = lamC, bgcolor = rowBg, text_size = szSml)
        table.cell(dash, 2, r, lamLab, text_color = lamC, bgcolor = rowBg, text_size = szSml, text_halign = text.align_right)
        r := r + 1

    // ─── PHASE 3 — ADVANCED FACTORS (collapsible) ─────────
    if showSecP3 and not isCompact
        table.cell(dash, 0, r, "── PHASE 3 ──", text_color = accent, bgcolor = hdrBg, text_size = szSml, text_halign = text.align_left)
        table.cell(dash, 1, r, "", bgcolor = hdrBg)
        table.cell(dash, 2, r, "", bgcolor = hdrBg)
        r := r + 1

        // Integrated OFI
        if ofiEnable
            color ofiC = ofiNorm > 0.15 ? cBull : ofiNorm < -0.15 ? cBear : cNeu
            string ofiLab = math.abs(ofiNorm) > 0.4 ? "STRONG" : math.abs(ofiNorm) > 0.15 ? "tilt" : "balanced"
            table.cell(dash, 0, r, "OFI (multi-lvl)", text_color = txtDim, bgcolor = rowBg, text_size = szSml, text_halign = text.align_left)
            table.cell(dash, 1, r, str.tostring(ofiNorm, "+0.00;-0.00"), text_color = ofiC, bgcolor = rowBg, text_size = szSml)
            table.cell(dash, 2, r, ofiLab, text_color = ofiC, bgcolor = rowBg, text_size = szSml, text_halign = text.align_right)
            r := r + 1

        // Directional Hawkes intensity
        if hawkesIntEnable
            color hwC = hawkesDir > 0.2 ? cBull : hawkesDir < -0.2 ? cBear : cNeu
            string hwLab = math.abs(hawkesDir) > 0.5 ? "clustered" : math.abs(hawkesDir) > 0.2 ? "building" : "diffuse"
            table.cell(dash, 0, r, "Hawkes dir", text_color = txtDim, bgcolor = rowBg, text_size = szSml, text_halign = text.align_left)
            table.cell(dash, 1, r, str.tostring(hawkesDir, "+0.00;-0.00"), text_color = hwC, bgcolor = rowBg, text_size = szSml)
            table.cell(dash, 2, r, hwLab, text_color = hwC, bgcolor = rowBg, text_size = szSml, text_halign = text.align_right)
            r := r + 1

        // √-law absorption
        if absorbEnable
            color abC = na(absorbRatio) ? cNeu : absorbRatio <= absorbLow ? color.new(cWarn, 0) : absorbRatio >= absorbHigh ? cBull : cNeu
            string abTxt = na(absorbRatio) ? "—" : str.tostring(absorbRatio, "0.00") + "×"
            table.cell(dash, 0, r, "Absorption", text_color = txtDim, bgcolor = rowBg, text_size = szSml, text_halign = text.align_left)
            table.cell(dash, 1, r, abTxt, text_color = abC, bgcolor = rowBg, text_size = szSml)
            table.cell(dash, 2, r, absorbLab, text_color = abC, bgcolor = rowBg, text_size = szSml, text_halign = text.align_right)
            r := r + 1

    // ─── PHASE 4 — MULTI-HORIZON & CROSS-INSTRUMENT (collapsible) ──
    if showSecP4 and not isCompact
        table.cell(dash, 0, r, "── PHASE 4 ──", text_color = accent, bgcolor = hdrBg, text_size = szSml, text_halign = text.align_left)
        table.cell(dash, 1, r, "", bgcolor = hdrBg)
        table.cell(dash, 2, r, "", bgcolor = hdrBg)
        r := r + 1

        // Multi-horizon consensus
        if mhEnable
            color mhC = mhConsensus > 0.3 ? cBull : mhConsensus < -0.3 ? cBear : cNeu
            string mhLab = mhAllAgree ? "ALIGNED" : mhSplit ? "split" : "mixed"
            string mhBon = mhBonus > 0 ? "+" + str.tostring(mhBonus * 100, "0") + "%" : mhBonus < 0 ? str.tostring(mhBonus * 100, "0") + "%" : "—"
            table.cell(dash, 0, r, "Multi-horizon", text_color = txtDim, bgcolor = rowBg, text_size = szSml, text_halign = text.align_left)
            table.cell(dash, 1, r, mhLab + " (" + str.tostring(mhBlend * 100, "0") + "%)", text_color = mhC, bgcolor = rowBg, text_size = szSml)
            table.cell(dash, 2, r, mhBon, text_color = mhC, bgcolor = rowBg, text_size = szSml, text_halign = text.align_right)
            r := r + 1

        // Cross-instrument
        if crossEnable
            color xC = crossDir > 0 ? cBull : crossDir < 0 ? cBear : cNeu
            string xLab = crossDir == 0 ? "neutral" : (crossDir == bayesDir ? "confirms" : "diverges")
            color xLabC = crossDir == 0 ? cNeu : (crossDir == bayesDir ? cBull : cBear)
            string xTxt = na(crossFlow) ? "—" : str.tostring(crossFlow, "+0.00;-0.00")
            table.cell(dash, 0, r, "X-instr", text_color = txtDim, bgcolor = rowBg, text_size = szSml, text_halign = text.align_left)
            table.cell(dash, 1, r, xTxt, text_color = xC, bgcolor = rowBg, text_size = szSml)
            table.cell(dash, 2, r, xLab, text_color = xLabC, bgcolor = rowBg, text_size = szSml, text_halign = text.align_right)
            r := r + 1

    // ─── FOOTPRINT (collapsible) ──────────────────────────
    if showSecFP and not isCompact
        table.cell(dash, 0, r, "── FOOTPRINT ──", text_color = accent, bgcolor = hdrBg, text_size = szSml, text_halign = text.align_left)
        table.cell(dash, 1, r, "", bgcolor = hdrBg)
        table.cell(dash, 2, r, "", bgcolor = hdrBg)
        r := r + 1

        // Pattern
        fpPatCol = patternCode > 0 ? cBull : patternCode < 0 ? cBear : cNeu
        fpPatLab = ""
        if patternCode == 2
            fpPatLab := "continuation up"
        else if patternCode == 1
            fpPatLab := patternName == "buy@btm" ? "absorption ↑" : "buy-stack top"
        else if patternCode == -1
            fpPatLab := patternName == "sell@top" ? "absorption ↓" : "sell-stack bot"
        else if patternCode == -2
            fpPatLab := "continuation dn"
        else
            fpPatLab := "no edge"
        table.cell(dash, 0, r, "Pattern", text_color = txtDim, bgcolor = rowBg, text_size = szSml, text_halign = text.align_left)
        table.cell(dash, 1, r, patternName, text_color = fpPatCol, bgcolor = rowBg, text_size = szSml)
        table.cell(dash, 2, r, fpPatLab, text_color = fpPatCol, bgcolor = rowBg, text_size = szSml, text_halign = text.align_right)
        r := r + 1

        // Imbalance
        imbCol = imbalanceSide > 0 ? cBull : imbalanceSide < 0 ? cBear : cNeu
        imbTxt = na(imbalancePrice) ? "—" : str.tostring(imbalancePrice, format.mintick)
        imbLab = na(imbalancePrice) ? "none" : (imbalanceSide > 0 ? "▲ " : "▼ ") + str.tostring(imbalancePct * 100, "0") + "%"
        table.cell(dash, 0, r, "Imbalance", text_color = txtDim, bgcolor = rowBg, text_size = szSml, text_halign = text.align_left)
        table.cell(dash, 1, r, imbTxt, text_color = imbCol, bgcolor = rowBg, text_size = szSml)
        table.cell(dash, 2, r, imbLab, text_color = imbCol, bgcolor = rowBg, text_size = szSml, text_halign = text.align_right)
        r := r + 1

        // Peak vol bin
        peakTxt = na(peakVolPrice) ? "—" : str.tostring(peakVolPrice, format.mintick)
        table.cell(dash, 0, r, "Peak vol @", text_color = txtDim, bgcolor = rowBg, text_size = szSml, text_halign = text.align_left)
        table.cell(dash, 1, r, peakTxt, text_color = txtMain, bgcolor = rowBg, text_size = szSml)
        table.cell(dash, 2, r, "max activity", text_color = txtDim, bgcolor = rowBg, text_size = szSml, text_halign = text.align_right)
        r := r + 1

        // Single prints
        spCol = singlePrintCnt > 0 ? color.new(color.yellow, 20) : txtDim
        spLab = singlePrintCnt == 0 ? "none" : singlePrintCnt == 1 ? "1 gap" : str.tostring(singlePrintCnt) + " gaps"
        spDetail = singlePrintCnt > 0 ? "magnet level" : "—"
        table.cell(dash, 0, r, "Single prints", text_color = txtDim, bgcolor = rowBg, text_size = szSml, text_halign = text.align_left)
        table.cell(dash, 1, r, spLab, text_color = spCol, bgcolor = rowBg, text_size = szSml)
        table.cell(dash, 2, r, spDetail, text_color = spCol, bgcolor = rowBg, text_size = szSml, text_halign = text.align_right)
        r := r + 1

        // Divergence
        divCol = divergence ? (strongDiv ? color.new(cWarn, 0) : color.new(cWarn, 40)) : txtDim
        divTxt = divergence ? (strongDiv ? "STRONG" : "mild") : "none"
        divDetail = divergence ? divType : "aligned"
        table.cell(dash, 0, r, "Divergence", text_color = txtDim, bgcolor = rowBg, text_size = szSml, text_halign = text.align_left)
        table.cell(dash, 1, r, divTxt, text_color = divCol, bgcolor = rowBg, text_size = szSml)
        table.cell(dash, 2, r, divDetail, text_color = divCol, bgcolor = rowBg, text_size = szSml, text_halign = text.align_right)
        r := r + 1

    // ─── AUCTION + SWEEPS (collapsible) ────────────────────
    if showSecSweep and not isCompact
        table.cell(dash, 0, r, "── AUCTION + SWEEPS ──", text_color = accent, bgcolor = hdrBg, text_size = szSml, text_halign = text.align_left)
        table.cell(dash, 1, r, "", bgcolor = hdrBg)
        table.cell(dash, 2, r, "", bgcolor = hdrBg)
        r := r + 1

        // Auction Efficiency row
        if auctionEnable
            string auctionTxt = na(auctionEff) ? "—" : str.tostring(auctionEff * 100, "0") + "%"
            string auctionDetail = na(auctionEff) ? "warm-up" : "VA " + str.tostring(auctionVAPct * 100, "0") + "%"
            table.cell(dash, 0, r, "Auction", text_color = txtDim, bgcolor = rowBg, text_size = szSml, text_halign = text.align_left)
            table.cell(dash, 1, r, auctionTxt + " " + auctionLab, text_color = auctionCol, bgcolor = rowBg, text_size = szSml)
            table.cell(dash, 2, r, auctionDetail, text_color = txtDim, bgcolor = rowBg, text_size = szSml, text_halign = text.align_right)
            r := r + 1

        // Sweep status row
        if sweepEnable
            string sweepCur = sweepBull ? "⚡ BULL sweep" : sweepBear ? "⚡ BEAR sweep" : "—"
            color  sweepCurCol = sweepBull ? cBull : sweepBear ? cBear : txtDim
            string sweepCurDetail = ""
            if sweepBull
                sweepCurDetail := "swept " + str.tostring(sweepBullLvl, format.mintick)
            else if sweepBear
                sweepCurDetail := "swept " + str.tostring(sweepBearLvl, format.mintick)
            else
                sweepCurDetail := "no sweep"
            table.cell(dash, 0, r, "Sweep (now)", text_color = txtDim, bgcolor = rowBg, text_size = szSml, text_halign = text.align_left)
            table.cell(dash, 1, r, sweepCur, text_color = sweepCurCol, bgcolor = rowBg, text_size = szSml)
            table.cell(dash, 2, r, sweepCurDetail, text_color = sweepCurCol, bgcolor = rowBg, text_size = szSml, text_halign = text.align_right)
            r := r + 1

            // Last sweep memory
            if sweepLastDir != 0 and not na(sweepLastLvl) and not na(sweepBarsAgo)
                string lastStr = (sweepLastDir > 0 ? "▲ bull " : "▼ bear ") + str.tostring(sweepLastLvl, format.mintick)
                string agoStr = str.tostring(sweepBarsAgo) + " bars ago"
                color  lastCol = sweepLastDir > 0 ? cBull : cBear
                table.cell(dash, 0, r, "Sweep (last)", text_color = txtDim, bgcolor = rowBg, text_size = szSml, text_halign = text.align_left)
                table.cell(dash, 1, r, lastStr, text_color = lastCol, bgcolor = rowBg, text_size = szSml)
                table.cell(dash, 2, r, agoStr, text_color = txtDim, bgcolor = rowBg, text_size = szSml, text_halign = text.align_right)
                r := r + 1

    // ─── REASONING (collapsible) ──────────────────────────
    if showSecReason and not isCompact
        table.cell(dash, 0, r, "── REASONING ──", text_color = accent, bgcolor = hdrBg, text_size = szSml, text_halign = text.align_left)
        table.cell(dash, 1, r, "", bgcolor = hdrBg)
        table.cell(dash, 2, r, "", bgcolor = hdrBg)
        r := r + 1

        if reason1 != ""
            table.cell(dash, 0, r, "•", text_color = cBull, bgcolor = rowBg, text_size = szSml, text_halign = text.align_right)
            table.cell(dash, 1, r, reason1, text_color = txtMain, bgcolor = rowBg, text_size = szSml, text_halign = text.align_left)
            table.cell(dash, 2, r, "", bgcolor = rowBg)
            r := r + 1
        if reason2 != ""
            table.cell(dash, 0, r, "•", text_color = cBull, bgcolor = rowBg, text_size = szSml, text_halign = text.align_right)
            table.cell(dash, 1, r, reason2, text_color = txtMain, bgcolor = rowBg, text_size = szSml, text_halign = text.align_left)
            table.cell(dash, 2, r, "", bgcolor = rowBg)
            r := r + 1
        if reason3 != ""
            table.cell(dash, 0, r, "•", text_color = cBull, bgcolor = rowBg, text_size = szSml, text_halign = text.align_left)
            table.cell(dash, 1, r, reason3, text_color = txtMain, bgcolor = rowBg, text_size = szSml, text_halign = text.align_left)
            table.cell(dash, 2, r, "", bgcolor = rowBg)
            r := r + 1
        if reason4 != ""
            table.cell(dash, 0, r, "•", text_color = riskElevated ? cBear : cBull, bgcolor = rowBg, text_size = szSml, text_halign = text.align_right)
            table.cell(dash, 1, r, reason4, text_color = txtMain, bgcolor = rowBg, text_size = szSml, text_halign = text.align_left)
            table.cell(dash, 2, r, "", bgcolor = rowBg)
            r := r + 1

    // ─── FOOTER ────────────────────────────────────────
    string vfMode = isCompact ? "Compact" : "Full"
    string vfSig  = isStrongOnly ? "Strong" : "All"
    string vfMtf  = mtfActive ? (mtf2Enable ? "dual-HTF" : "single-HTF") : "no-MTF"
    string vfFus  = fusionMode == "Decorrelated" ? "DEC" : "LEG"
    table.cell(dash, 0, r, "v1.0 · " + assetClass + " · " + fpDataSource + "/" + vfFus + " · " + vfMode + "/" + vfSig + "/" + vfMtf, text_color = color.new(txtDim, 50), bgcolor = hdrBg, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, r, "", bgcolor = hdrBg)
    table.cell(dash, 2, r, syminfo.ticker, text_color = color.new(txtDim, 50), bgcolor = hdrBg, text_size = size.tiny, text_halign = text.align_right)

// =============================================================================
//                            EXPORT PLOTS (data_window)
// =============================================================================

// =============================================================================
//                            EXPORT PLOTS (data_window)
// =============================================================================
// Continuous math outputs are kept individual at full precision (one plot each).
// Discrete codes/flags are bit-packed into EXP_FLAGS so the script stays under
// Pine's 64-plot limit with ZERO loss of information. Decode map is below.
// EXP_FUSION_RHOBAR was dropped (derivable):  rhoBar = (1 / EXP_FUSION_SHRINK - 1) / 4

plot(barDelta,    "EXP_BAR_DELTA",     color = color.new(color.gray, 100), display = display.data_window)
plot(cvd,         "EXP_CVD",           color = color.new(color.gray, 100), display = display.data_window)
plot(airSmoothed, "EXP_AIR_SMOOTH",    color = color.new(color.gray, 100), display = display.data_window)
plot(nz(lastMocImb, 0),   "EXP_MOC_LAST", color = color.new(color.gray, 100), display = display.data_window)
plot(nz(vpin, 0),         "EXP_VPIN",     color = color.new(color.gray, 100), display = display.data_window)
plot(nz(lambdaSm, 0),     "EXP_LAMBDA",   color = color.new(color.gray, 100), display = display.data_window)
plot(regimeScore,  "EXP_REGIME_SCORE", color = color.new(color.gray, 100), display = display.data_window)
plot(confidence,   "EXP_CONFIDENCE",   color = color.new(color.gray, 100), display = display.data_window)
plot(nz(entryLvl, 0), "EXP_ENTRY_LVL", color = color.new(color.gray, 100), display = display.data_window)
plot(nz(invalLvl, 0), "EXP_INVAL_LVL", color = color.new(color.gray, 100), display = display.data_window)
plot(nz(imbalancePrice, 0), "EXP_FP_IMB_PRICE", color = color.new(color.gray, 100), display = display.data_window)
plot(thrashScore,         "EXP_THRASH_SCORE",    color = color.new(color.gray, 100), display = display.data_window)
plot(er,                  "EXP_ER",              color = color.new(color.gray, 100), display = display.data_window)
plot(posterior,           "EXP_POSTERIOR",       color = color.new(color.gray, 100), display = display.data_window)
plot(coFireRatio,         "EXP_COFIRE_RATIO",    color = color.new(color.gray, 100), display = display.data_window)
plot(nz(auctionEff, 0),   "EXP_AUCTION_EFF",     color = color.new(color.gray, 100), display = display.data_window)
plot(fusionShrink,        "EXP_FUSION_SHRINK",   color = color.new(color.gray, 100), display = display.data_window)
plot(ofiNorm,             "EXP_OFI",             color = color.new(color.gray, 100), display = display.data_window)
plot(hawkesDir,           "EXP_HAWKES_DIR",      color = color.new(color.gray, 100), display = display.data_window)
plot(nz(absorbRatio, 0),  "EXP_ABSORB_RATIO",    color = color.new(color.gray, 100), display = display.data_window)
plot(mhConsensus,         "EXP_MH_CONSENSUS",    color = color.new(color.gray, 100), display = display.data_window)
plot(nz(crossFlow, 0),    "EXP_XINST_FLOW",      color = color.new(color.gray, 100), display = display.data_window)
// Removed to fit Pine's plot budget (each plot costs 2 units; ceiling 64).
// All are recoverable downstream:
//   EXP_AIR_ACCEL        = change(EXP_AIR_SMOOTH)        (N-bar difference)
//   EXP_MH_BLEND         = mean(EXP_POSTERIOR over horizons)  (or ~ from CONSENSUS)
//   EXP_HTF_POSTERIOR    = mtfDir lives in EXP_FLAGS
//   EXP_FUSION_RHOBAR    = (1/EXP_FUSION_SHRINK - 1)/4
//   EXP_FP_PEAK_PRICE / EXP_PIVOT_HIGH_ABOVE / EXP_PIVOT_LOW_BELOW = diagnostics


// ── EXP_FLAGS: packed discrete signals (lossless). Let F = floor(EXP_FLAGS): ──
//   regimeCode  = (F        % 10) - 2     // -2..+2  (STRONG-BEAR..STRONG-BULL)
//   patternCode = (F/10     % 10) - 2     // -2..+2  (footprint pattern)
//   divCode     = (F/100    % 10)         // 0 none · 1 weak · 2 strong divergence
//   tierCode    = (F/1000   % 10)         // 1..5    (confidence tier)
//   sweepDir    = (F/10000  % 10) - 1     // -1/0/+1 (liquidity sweep)
//   mtfDir      = (F/100000 % 10) - 1     // -1/0/+1 (HTF1 direction)
//   bayesDir    = (F/1e6    % 10) - 1     // -1/0/+1 (posterior direction)
//   dataOk      = (F/1e7    % 10)         // 0/1
//   fpNative    = (F/1e8    % 10)         // 0/1     (1 = native footprint active)
int divCodeExp = strongDiv ? 2 : divergence ? 1 : 0
float expFlags = (regimeCode + 2) + (patternCode + 2) * 10 + divCodeExp * 100 + tierCode * 1000 + (sweepDir + 1) * 10000 + (htfDir + 1) * 100000 + (bayesDir + 1) * 1000000 + (barDataOk ? 1 : 0) * 10000000 + (fpDataSource == "NATIVE" ? 1 : 0) * 100000000
plot(expFlags, "EXP_FLAGS", color = color.new(color.gray, 100), display = display.data_window)


// =============================================================================
//                                  ALERTS
// =============================================================================

alertcondition(regimeCode == 2  and regimeCode[1] < 2,  "OFME → STRONG-BULL",   "OFME: Regime entered STRONG-BULL")
alertcondition(regimeCode == -2 and regimeCode[1] > -2, "OFME → STRONG-BEAR",   "OFME: Regime entered STRONG-BEAR")
alertcondition(regimeCode == 1  and regimeCode[1] <= 0, "OFME → BULL",          "OFME: Regime turned BULL")
alertcondition(regimeCode == -1 and regimeCode[1] >= 0, "OFME → BEAR",          "OFME: Regime turned BEAR")
alertcondition(toxicFlow and not toxicFlow[1],          "OFME Toxic Flow ON",   "OFME: VPIN crossed toxic threshold")
alertcondition(thinLiquid and not thinLiquid[1],        "OFME Thin Liquidity",  "OFME: Kyle's lambda elevated — liquidity thinning")
alertcondition(mocStrong and not mocStrong[1],          "OFME Strong MOC",      "OFME: Strong institutional MOC imbalance")
alertcondition(confidence >= 0.7 and confidence[1] < 0.7, "OFME High Confidence", "OFME: Decision confidence ≥ 70%")
alertcondition(patternCode >= 2 and patternCode[1] < 2,   "OFME FP P-strong",       "OFME: Footprint P-strong pattern (continuation up)")
alertcondition(patternCode <= -2 and patternCode[1] > -2, "OFME FP b-strong",       "OFME: Footprint b-strong pattern (continuation down)")
alertcondition(patternName == "buy@btm" and patternName[1] != "buy@btm", "OFME FP Buy Absorption", "OFME: Footprint buy absorption at bar lows")
alertcondition(patternName == "sell@top" and patternName[1] != "sell@top", "OFME FP Sell Absorption", "OFME: Footprint sell absorption at bar highs")
alertcondition(strongDiv and not strongDiv[1], "OFME Strong Divergence", "OFME: Strong price-delta divergence — absorption/exhaustion signal")
alertcondition(cvdReset and not cvdReset[1], "OFME CVD Reset", "OFME: CVD just reset")
alertcondition(thrashScore > 0.7 and thrashScore[1] <= 0.7, "OFME Regime Chaos", "OFME: Regime thrashing detected — high chop/noise, signals dampened")
alertcondition(er > erThreshTrend and er[1] <= erThreshTrend, "OFME Trend Onset", "OFME: Kaufman ER crossed into trending regime")
alertcondition(er < erThreshChop and er[1] >= erThreshChop, "OFME Chop Onset", "OFME: Kaufman ER dropped into chop regime")
alertcondition(posterior > 0.80 and posterior[1] <= 0.80, "OFME Posterior >80%", "OFME: Bayesian posterior crossed 80% (very high bull conviction)")
alertcondition(posterior < 0.20 and posterior[1] >= 0.20, "OFME Posterior <20%", "OFME: Bayesian posterior crossed 20% (very high bear conviction)")
alertcondition(coFireFires and not coFireFires[1], "OFME CO-FIRE", "OFME: 3+ microstructure dimensions align (strong confluence)")
alertcondition(tierCode == 1 and tierCode[1] != 1, "OFME Tier 1 Entry", "OFME: Tier 1 confidence reached — full size entry candidate")
alertcondition(usePivots and confidence >= minConfidence and confidence[1] < minConfidence, "OFME Pivot-Anchored Entry", "OFME: Pivot-anchored entry signal fired")
alertcondition(sweepBull and not sweepBull[1], "OFME Bull Sweep", "OFME: Liquidity sweep below pivot low + reclaim — potential long reversal")
alertcondition(sweepBear and not sweepBear[1], "OFME Bear Sweep", "OFME: Liquidity sweep above pivot high + reclaim — potential short reversal")
alertcondition(auctionEnable and not na(auctionEff) and auctionEff <= auctionEffLow and auctionEff[1] > auctionEffLow, "OFME Auction Trapped", "OFME: Auction efficiency dropped to TRAPPED — distribution / rejection warning")
alertcondition(mtfActive and mtfAligned and bayesDir != 0 and htfDir != 0 and not (mtfAligned[1] and bayesDir[1] != 0 and htfDir[1] != 0), "OFME MTF Aligned", "OFME: Multi-timeframe direction confluence established")
alertcondition(mtfActive and mtfDisagreed and not mtfDisagreed[1], "OFME MTF Conflict", "OFME: Higher TF disagrees with current TF — trade signal suppressed")
````
