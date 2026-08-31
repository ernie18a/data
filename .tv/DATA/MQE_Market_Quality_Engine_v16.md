<!-- tradingview-pine-id: PUB;03c3c74b52904832b755b8c1e7f37d6f -->
<!-- tradingviewscripts-format: 1 -->
# MQE - Market Quality Engine v1.6

Source: https://www.tradingview.com/script/vqtOItbm/

## Description

# MQE — Market Quality Engine v1.6

**MQE is not a buy/sell signal generator.** It is a Decision Support System that measures the quality of the current market environment on a standardized 0-100 scale. Its purpose is not to dictate "Buy" or "Sell," but to present, transparently and explainably, how favorable current market conditions are for opening a directional position.

## Methodology

MQE combines evidence from five independent analytical engines:

- **Trend Engine** — Evaluates market structure direction using EMA structure, AlphaTrend, and Comparative Relative Strength (CRS) against a benchmark (default BIST:XU100).
- **Flow Engine** — Measures directional capital commitment using a Cumulative Delta Volume (CDV) approximation; unlike raw volume, it prioritizes directional information over mere activity. The engine's highest-weighted criterion (40%) is whether CDV's fast average (EMA5) remains above its slow average (SMA68) — a strong, sustained CDV reading is interpreted as confirmation that the underlying scenario has not broken down.
- **Opportunity Conditions Engine** — Built around Relative ATR, this engine evaluates "tradability" rather than raw volatility; neither extreme compression nor extreme expansion is treated as inherently favorable.
- **Participation Engine** — Uses Relative Volume to assess whether sufficient market participation supports the current move; it is non-directional and primarily feeds into the Confidence output.
- **Momentum Engine** — MFI-based; deliberately avoids classic overbought/oversold interpretation and instead evaluates the persistence of directional energy as a supporting, confirmatory layer.

The output of these five engines is combined using regime-adaptive weighting — based on the current market **Regime** (Bull Trend / Bear Trend / Range / Transition) — into independent **Long Score** and **Short Score** values (0-100). Contradictions between engines are captured separately by a **Penalty** mechanism that only ever reduces the score, while the internal consistency of the evidence is reported through a fully independent **Confidence** value (0-100) that never alters the score itself. A high score paired with low confidence signals an environment that looks attractive but is backed by inconsistent evidence; high score with high confidence signals strong agreement across all evidence families.

For quick manual screening, MQE also provides a composite **Grade** (A+ through D), calculated separately for both directions.

## Dashboard

Two independent panels are provided: a **Primary Dashboard** (Long/Short Score, Confidence, Regime, and per-engine summaries — shown side-by-side for both the last closed bar and the live bar), and a **Diagnostics Panel** (per-engine breakdowns, penalty sources, raw indicator values, and active confirmation timeframes).

## Timeframe Adaptivity

Higher-timeframe confirmation and the AlphaTrend calculation automatically scale to the chart's timeframe (from 5-minute up to weekly), so no manual configuration is required by default; manual overrides remain available for advanced customization.

## Credit

The AlphaTrend calculation logic is adapted from the publicly known AlphaTrend concept originally developed by Kıvanç Özbilgiç.

## Disclaimer

MQE is not financial advice; it provides a statistical assessment of market conditions only. Past performance or evidence consistency does not guarantee future price behavior. All trading decisions and risk management remain the sole responsibility of the user.

---

## Source Code

````pine
// ============================================================================
// MQE — Market Quality Engine v1.6
// "See the Market. Measure the Opportunity."
// Implemented per MQE Developer Handbook v1.0 (Chapters 1-10)
// Architecture: Data -> Cache -> Feature Engines -> Regime -> Score ->
//               Penalty & Confidence -> Dashboard -> Alerts
// ============================================================================
//@version=6
indicator("MQE - Market Quality Engine v1.6", shorttitle="MQE v1.6", overlay=true, max_labels_count=200, max_lines_count=200)

// ============================================================================
// SECTION 1 — INPUTS
// ============================================================================

// --- Trend Engine Settings ---
g_trend               = "Trend Engine Settings"
i_emaFastLen           = input.int(50, "EMA Fast Length", group=g_trend)
i_emaSlowLen           = input.int(200, "EMA Slow Length", group=g_trend)
i_crsLen               = input.int(20, "CRS Lookback (Relative Strength)", group=g_trend)
i_benchmarkSymbol      = input.symbol("BIST:XU100", "Benchmark Symbol (CRS)", group=g_trend)
i_alphaTrendLen        = input.int(14, "AlphaTrend ATR Length", group=g_trend)
i_alphaTrendMult       = input.float(1.0, "AlphaTrend Multiplier", step=0.1, group=g_trend)
i_alphaTrendMfiLen     = input.int(14, "AlphaTrend MFI Length", group=g_trend)
i_mtfAutoMode          = input.bool(true, "Auto-Select MTF / AlphaTrend Timeframes (Recommended)", group=g_trend)
i_alphaTrendTF         = input.timeframe("120", "AlphaTrend Timeframe (Manual Override — used only if Auto-Select is OFF)", group=g_trend)
i_mtfEnable            = input.bool(true, "Enable Multi-Timeframe Confirmation", group=g_trend)
i_mtfTimeframe         = input.timeframe("60", "Confirmation Timeframe (Manual Override — used only if Auto-Select is OFF)", group=g_trend)

// --- Flow Engine Settings ---
g_flow                 = "Flow Engine Settings"
i_cdvSlopeLen          = input.int(5, "CDV Slope Length", group=g_flow)
i_cdvNormLen           = input.int(100, "CDV Normalization Lookback", group=g_flow)
i_cdvFastLen           = input.int(5, "CDV Fast EMA Length (Primary Signal)", group=g_flow)
i_cdvSlowLen           = input.int(68, "CDV Slow SMA Length (Primary Signal)", group=g_flow)

// --- Opportunity Conditions Settings ---
g_opp                  = "Opportunity Conditions Settings"
i_atrLen               = input.int(14, "ATR Length", group=g_opp)
i_atrRelLen            = input.int(100, "Relative ATR Lookback", group=g_opp)
i_compressionThresh    = input.float(0.75, "Compression Threshold (Rel. ATR)", step=0.05, group=g_opp)
i_expansionThresh      = input.float(1.30, "Expansion Threshold (Rel. ATR)", step=0.05, group=g_opp)
i_oppStabilityLen      = input.int(5, "Opportunity Stability Length", group=g_opp)

// --- Participation Engine Settings ---
g_part                  = "Participation Engine Settings"
i_rvolLen               = input.int(20, "RVOL Average Length", group=g_part)
i_rvolPersistLen        = input.int(5, "RVOL Persistence Length", group=g_part)

// --- Momentum Engine Settings ---
g_mom                   = "Momentum Engine Settings"
i_mfiLen                = input.int(14, "MFI Length", group=g_mom)
i_mfiSlopeLen           = input.int(5, "MFI Slope Length", group=g_mom)

// --- Scoring Weights (Relative Importance, Chapter 7.7 / 5.8 Hierarchy) ---
g_score                 = "Scoring Weights (Relative Importance)"
i_wTrend                = input.float(30, "Trend Weight (Highest)", group=g_score)
i_wFlow                 = input.float(30, "Flow Weight (High — CDV EMA/SMA Cross)", group=g_score)
i_wOpp                  = input.float(20, "Opportunity Weight (Medium)", group=g_score)
i_wPart                 = input.float(15, "Participation Weight (Medium)", group=g_score)
i_wMom                  = input.float(10, "Momentum Weight (Supporting)", group=g_score)

// --- Regime Settings ---
g_regime                = "Regime Settings"
i_regimeBullBearThresh  = input.float(25, "Bull/Bear Directional Bias Threshold", group=g_regime)
i_regimeStabilityLen    = input.int(5, "Regime Stability Bars (Full Confidence)", group=g_regime)

// --- Dashboard Settings ---
g_dash                  = "Dashboard Settings"
i_showPrimary           = input.bool(true, "Show Primary Dashboard", group=g_dash)
i_showDiagnostics       = input.bool(true, "Show Diagnostics Panel", group=g_dash)
i_primaryPos            = input.string("Bottom Right", "Primary Dashboard Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=g_dash)
i_diagPos               = input.string("Bottom Left", "Diagnostics Panel Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=g_dash)
i_textSize              = input.string("Normal", "Text Size", options=["Tiny","Small","Normal","Large"], group=g_dash)

// --- Alert Settings ---
g_alert                  = "Alert Settings"
i_longAlertThresh        = input.float(70, "Long Score Alert Threshold", group=g_alert)
i_shortAlertThresh       = input.float(70, "Short Score Alert Threshold", group=g_alert)
i_confAlertThresh        = input.float(80, "Confidence Alert Threshold", group=g_alert)

// --- Developer Settings ---
g_dev                     = "Developer Settings"
i_debugMode               = input.bool(false, "Enable Debug Mode", group=g_dev)

// ============================================================================
// SECTION 2 — UTILITY FUNCTIONS
// ============================================================================

f_clamp(x, lo, hi) =>
    math.max(lo, math.min(hi, x))

f_normalize(x, lo, hi) =>
    rng = hi - lo
    rng == 0 ? 50.0 : f_clamp((x - lo) / rng * 100.0, 0.0, 100.0)

f_safeDiv(a, b) =>
    b == 0 ? 0.0 : a / b

f_statusLabel(evidenceScore) =>
    evidenceScore >= 80 ? "Strong" : evidenceScore >= 60 ? "Moderate" : evidenceScore >= 40 ? "Neutral" : evidenceScore >= 20 ? "Weak" : "Very Weak"

f_confLabel(c) =>
    c >= 90 ? "Exceptional" : c >= 75 ? "Strong" : c >= 60 ? "Acceptable" : c >= 40 ? "Mixed" : c >= 20 ? "Weak" : "Extremely Uncertain"

f_tablePos(p) =>
    switch p
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.top_right

f_textSize(s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.small

// ============================================================================
// SECTION 3 — DATA LAYER & CACHE LAYER (Chapter 4)
// Every expensive calculation is executed exactly once and stored (cache*).
// Feature Engines below only READ from these cached values.
// ============================================================================

// -- Benchmark data (single security call, reused for CRS) --
cacheBenchClose = request.security(i_benchmarkSymbol, timeframe.period, close, lookahead=barmerge.lookahead_off)

// -- Trend cache --
cacheEMA50  = ta.ema(close, i_emaFastLen)
cacheEMA200 = ta.ema(close, i_emaSlowLen)
cacheAssetROC = ta.roc(close, i_crsLen)
cacheBenchROC = ta.roc(cacheBenchClose, i_crsLen)
cacheCRS      = cacheAssetROC - cacheBenchROC

// -- Auto-selected MTF / AlphaTrend timeframes --
// Ensures Chart < MTF Confirmation < AlphaTrend ordering always holds,
// regardless of which chart timeframe the user is currently viewing.
// timeframe.in_seconds() is used instead of string matching because Pine's
// timeframe.period string format is inconsistent across chart types.
chartSeconds = timeframe.in_seconds(timeframe.period)

autoMtfTF = switch true
    chartSeconds <= 300   => "30"    // Chart <= 5m  -> 30m
    chartSeconds <= 900   => "60"    // Chart <= 15m -> 1h
    chartSeconds <= 1200  => "60"    // Chart <= 20m -> 1h
    chartSeconds <= 1800  => "60"    // Chart <= 30m -> 1h
    chartSeconds <= 3600  => "120"   // Chart <= 1h  -> 2h
    chartSeconds <= 7200  => "240"   // Chart <= 2h  -> 4h
    chartSeconds <= 14400 => "1D"    // Chart <= 4h  -> 1D
    timeframe.isdaily     => "1W"    // Chart 1D     -> 1W
    timeframe.isweekly    => "1M"    // Chart 1W     -> 1M
    => "1W"

autoAlphaTF = switch true
    chartSeconds <= 300   => "60"    // Chart <= 5m  -> 1h
    chartSeconds <= 900   => "120"   // Chart <= 15m -> 2h
    chartSeconds <= 1200  => "120"   // Chart <= 20m -> 2h
    chartSeconds <= 1800  => "120"   // Chart <= 30m -> 2h
    chartSeconds <= 3600  => "240"   // Chart <= 1h  -> 4h
    chartSeconds <= 7200  => "1D"    // Chart <= 2h  -> 1D
    chartSeconds <= 14400 => "1W"    // Chart <= 4h  -> 1W
    timeframe.isdaily     => "1M"    // Chart 1D     -> 1M
    timeframe.isweekly    => "3M"    // Chart 1W     -> 3M
    => "3M"

finalMtfTF   = i_mtfAutoMode ? autoMtfTF   : i_mtfTimeframe
finalAlphaTF = i_mtfAutoMode ? autoAlphaTF : i_alphaTrendTF

// AlphaTrend — recursive adaptive trend line computed on its own timeframe
// (single security call; lookahead_off enforces "no future information" rule 4.3)
f_alphaTrend(atrLen, mult, mfiLen) =>
    var float at = na
    atrVal  = ta.atr(atrLen)
    mfiVal  = ta.mfi(hlc3, mfiLen)
    upT     = low  - atrVal * mult
    downT   = high + atrVal * mult
    at := mfiVal >= 50 ? (upT   < nz(at[1]) ? nz(at[1]) : upT) :
                          (downT > nz(at[1]) ? nz(at[1]) : downT)
    at

cacheAlphaTrend = request.security(syminfo.tickerid, finalAlphaTF, f_alphaTrend(i_alphaTrendLen, i_alphaTrendMult, i_alphaTrendMfiLen), lookahead=barmerge.lookahead_off)

// Multi-timeframe confirmation (single security call, reused across engines)
cacheHigherTFTrendUp = request.security(syminfo.tickerid, finalMtfTF, close > ta.ema(close, i_emaFastLen), lookahead=barmerge.lookahead_off)

// -- Opportunity (volatility) cache --
cacheATR            = ta.atr(i_atrLen)
cacheATRAvg         = ta.sma(cacheATR, i_atrRelLen)
cacheRelativeATR    = f_safeDiv(cacheATR, cacheATRAvg)
cacheATRPercentRank = ta.percentrank(cacheATR, i_atrRelLen)

// -- Participation cache --
cacheVolumeAvg      = ta.sma(volume, i_rvolLen)
cacheRelativeVolume = f_safeDiv(volume, cacheVolumeAvg)

// -- Momentum cache --
cacheMFI = ta.mfi(hlc3, i_mfiLen)

// -- Flow cache (CDV approximation via intrabar buy/sell volume split) --
barRange   = high - low
cacheBuyVol  = barRange != 0 ? volume * (close - low)  / barRange : 0.0
cacheSellVol = barRange != 0 ? volume * (high - close) / barRange : 0.0
cacheCDV      = ta.cum(cacheBuyVol - cacheSellVol)
cacheCDVSlope = ta.change(cacheCDV, i_cdvSlopeLen)
cacheCDVSlopeRank = ta.percentrank(cacheCDVSlope, i_cdvNormLen)
cacheCDV_EMAFast  = ta.ema(cacheCDV, i_cdvFastLen)
cacheCDV_SMASlow  = ta.sma(cacheCDV, i_cdvSlowLen)

// ============================================================================
// SECTION 4 — TREND ENGINE (Chapter 5.2)
// Question: "How favorable is current market structure for directional trading?"
// Evidence: EMA structure, AlphaTrend, CRS, MTF confirmation
// ============================================================================

trend_emaBullish     = cacheEMA50 > cacheEMA200
trend_priceAboveEMA  = close > cacheEMA50
trend_alphaBullish   = close > cacheAlphaTrend
trend_crsBullish     = cacheCRS > 0
trend_mtfBullish     = i_mtfEnable ? cacheHigherTFTrendUp : trend_emaBullish

trend_bullVotes = (trend_emaBullish ? 1 : 0) + (trend_priceAboveEMA ? 1 : 0) + (trend_alphaBullish ? 1 : 0) + (trend_crsBullish ? 1 : 0) + (trend_mtfBullish ? 1 : 0)

trend_longEvidence  = trend_bullVotes / 5.0 * 100.0
trend_shortEvidence = (5.0 - trend_bullVotes) / 5.0 * 100.0
trend_confidence    = math.abs(trend_bullVotes - 2.5) / 2.5 * 100.0

trend_emaSeparationPct = f_safeDiv(math.abs(cacheEMA50 - cacheEMA200), close) * 100.0
trend_strength         = f_normalize(trend_emaSeparationPct, 0.0, 5.0)
trend_direction        = trend_longEvidence > trend_shortEvidence ? "Bullish" : trend_longEvidence < trend_shortEvidence ? "Bearish" : "Neutral"
trend_status            = f_statusLabel(math.max(trend_longEvidence, trend_shortEvidence))

// ============================================================================
// SECTION 5 — FLOW ENGINE (Chapter 5.3)
// Question: "Is money consistently flowing in one direction?"
// Weighted evidence (not equal-vote): the CDV Fast EMA vs Slow SMA cross is
// treated as the dominant, regime-defining criterion (40%) — a strong,
// sustained CDV reading means the trade scenario is not broken. The other
// three criteria (slope, acceleration, price/flow alignment) provide
// shorter-term, confirmatory evidence at lower weight.
// ============================================================================

flow_cdvEmaAboveSma   = cacheCDV_EMAFast > cacheCDV_SMASlow   // PRIMARY signal
flow_cdvRising        = cacheCDVSlope > 0
flow_cdvAccelerating  = cacheCDVSlopeRank > 50
flow_priceFlowAligned = (ta.change(close, i_cdvSlopeLen) > 0) == flow_cdvRising

// Unweighted count, kept only for the Debug panel's quick "x/4" overview
flow_bullVotes = (flow_cdvEmaAboveSma ? 1 : 0) + (flow_cdvRising ? 1 : 0) + (flow_cdvAccelerating ? 1 : 0) + (flow_priceFlowAligned ? 1 : 0)

// Weighted score — this is what actually drives Long/Short evidence
flow_bullScore = (flow_cdvEmaAboveSma ? 40.0 : 0.0) + (flow_cdvRising ? 20.0 : 0.0) + (flow_cdvAccelerating ? 20.0 : 0.0) + (flow_priceFlowAligned ? 20.0 : 0.0)

flow_longEvidence  = flow_bullScore
flow_shortEvidence = 100.0 - flow_bullScore
flow_confidence    = math.abs(flow_bullScore - 50.0) / 50.0 * 100.0
flow_status         = f_statusLabel(math.max(flow_longEvidence, flow_shortEvidence))
flow_cdvTrendLabel  = flow_cdvRising ? "Rising" : "Falling"
flow_cdvCrossLabel  = flow_cdvEmaAboveSma ? "Bullish" : "Bearish"

// ============================================================================
// SECTION 6 — OPPORTUNITY CONDITIONS ENGINE (Chapter 5.4)
// Question: "Is the current market environment suitable for opening a position?"
// Non-directional: contributes equal tradability evidence to Long and Short.
// ============================================================================

opp_movementSufficient = cacheRelativeATR >= i_compressionThresh and cacheRelativeATR <= i_expansionThresh * 1.5
opp_percentileHealthy  = cacheATRPercentRank > 15 and cacheATRPercentRank < 90
opp_stabilityGood      = ta.stdev(cacheRelativeATR, i_oppStabilityLen) < ta.stdev(cacheRelativeATR, i_oppStabilityLen * 2)
opp_expansionOrPrep    = cacheRelativeATR > cacheRelativeATR[i_oppStabilityLen] or cacheRelativeATR <= i_compressionThresh

opp_votes = (opp_movementSufficient ? 1 : 0) + (opp_percentileHealthy ? 1 : 0) + (opp_stabilityGood ? 1 : 0) + (opp_expansionOrPrep ? 1 : 0)

opp_tradability = opp_votes / 4.0 * 100.0
opp_confidence  = math.abs(opp_votes - 2.0) / 2.0 * 100.0
opp_isCompressed = cacheRelativeATR < i_compressionThresh
opp_isExpanding   = cacheRelativeATR > i_expansionThresh
opp_status        = opp_isCompressed ? "Compressed" : opp_isExpanding ? "Expanding" : f_statusLabel(opp_tradability)

// ============================================================================
// SECTION 7 — PARTICIPATION ENGINE (Chapter 5.5)
// Question: "Are enough market participants actively supporting price movement?"
// Non-directional: primarily a Confidence contributor, limited Score influence.
// ============================================================================

part_aboveAverage  = cacheRelativeVolume > 1.0
part_persistent    = ta.sma(cacheRelativeVolume, i_rvolPersistLen) > 1.0
part_stable        = ta.stdev(cacheRelativeVolume, i_rvolPersistLen) < ta.stdev(cacheRelativeVolume, i_rvolPersistLen * 2)
part_exceptional   = cacheRelativeVolume > 1.2

part_votes = (part_aboveAverage ? 1 : 0) + (part_persistent ? 1 : 0) + (part_stable ? 1 : 0) + (part_exceptional ? 1 : 0)

part_quality    = part_votes / 4.0 * 100.0
part_confidence = math.abs(part_votes - 2.0) / 2.0 * 100.0
part_status      = f_statusLabel(part_quality)

// ============================================================================
// SECTION 8 — MOMENTUM ENGINE (Chapter 5.6)
// Question: "Is the current directional movement gaining or losing energy?"
// Overbought/oversold thresholds are intentionally NOT used (5.6.7).
// ============================================================================

mom_mfiRising       = cacheMFI > cacheMFI[i_mfiSlopeLen]
mom_smoothedRising  = ta.sma(cacheMFI, i_mfiSlopeLen) > ta.sma(cacheMFI, i_mfiSlopeLen)[i_mfiSlopeLen]
mom_aboveMidpoint    = cacheMFI > 50

mom_bullVotes = (mom_mfiRising ? 1 : 0) + (mom_smoothedRising ? 1 : 0) + (mom_aboveMidpoint ? 1 : 0)

mom_longEvidence  = mom_bullVotes / 3.0 * 100.0
mom_shortEvidence = (3.0 - mom_bullVotes) / 3.0 * 100.0
mom_confidence    = math.abs(mom_bullVotes - 1.5) / 1.5 * 100.0
mom_status         = f_statusLabel(math.max(mom_longEvidence, mom_shortEvidence))

// ============================================================================
// SECTION 9 — REGIME ENGINE (Chapter 6)
// Classifies market context from Feature Engine outputs only. No raw data,
// no scoring, no penalties are computed here (6.12 Engineering Constraints).
// ============================================================================

reg_trendBias = trend_longEvidence - trend_shortEvidence   // -100..100
reg_flowBias  = flow_longEvidence  - flow_shortEvidence     // -100..100
reg_momBias   = mom_longEvidence   - mom_shortEvidence      // -100..100

reg_directionalBias = reg_trendBias * 0.40 + reg_flowBias * 0.35 + reg_momBias * 0.25

reg_lowConsistency = trend_confidence < 40 or flow_confidence < 40 or opp_confidence < 40

reg_type = "Range"
if reg_directionalBias > i_regimeBullBearThresh and opp_tradability >= 50
    reg_type := "Bull Trend"
else if reg_directionalBias < -i_regimeBullBearThresh and opp_tradability >= 50
    reg_type := "Bear Trend"
else if reg_lowConsistency
    reg_type := "Transition"
else
    reg_type := "Range"

var string reg_prevType   = ""
var int    reg_stableBars = 0
reg_changed = reg_type != reg_prevType
reg_stableBars := reg_changed ? 0 : reg_stableBars + 1
reg_prevType := reg_type

reg_stabilityScore = f_clamp(reg_stableBars / i_regimeStabilityLen * 100.0, 0.0, 100.0)
reg_confidence      = (trend_confidence + flow_confidence + mom_confidence) / 3.0
reg_emoji            = reg_type == "Bull Trend" ? "🟢" : reg_type == "Bear Trend" ? "🔴" : reg_type == "Transition" ? "🟡" : "⚪"

// ============================================================================
// SECTION 10 — SCORE ENGINE / QES (Chapter 7)
// Adaptive weighting per regime (7.8/6.10), then weighted-average composite.
// Weighted average keeps output naturally bounded within 0-100 (7.19).
// ============================================================================

score_wTrend = i_wTrend
score_wFlow  = i_wFlow
score_wOpp   = i_wOpp
score_wPart  = i_wPart
score_wMom   = i_wMom

if reg_type == "Bull Trend" or reg_type == "Bear Trend"
    score_wTrend := i_wTrend * 1.2
    score_wFlow  := i_wFlow * 1.1
    score_wMom   := i_wMom * 0.8
else if reg_type == "Range"
    score_wTrend := i_wTrend * 0.8
    score_wOpp   := i_wOpp * 1.2
    score_wPart  := i_wPart * 1.2
else if reg_type == "Transition"
    score_wTrend := i_wTrend * 0.7
    score_wFlow  := i_wFlow * 0.7

score_sumWeights = score_wTrend + score_wFlow + score_wOpp + score_wPart + score_wMom

score_longComposite  = (trend_longEvidence * score_wTrend + flow_longEvidence * score_wFlow + opp_tradability * score_wOpp + part_quality * score_wPart + mom_longEvidence * score_wMom) / score_sumWeights
score_shortComposite = (trend_shortEvidence * score_wTrend + flow_shortEvidence * score_wFlow + opp_tradability * score_wOpp + part_quality * score_wPart + mom_shortEvidence * score_wMom) / score_sumWeights

// ============================================================================
// SECTION 11 — PENALTY ENGINE (Chapter 8)
// Penalties only ever reduce the score. Each source is independent (8.10)
// and the combined effect is bounded (8.17).
// ============================================================================

pen_trendConflict       = trend_emaBullish != trend_alphaBullish ? 8.0 : 0.0
pen_flowConflict        = (ta.change(close, i_cdvSlopeLen) > 0) != flow_cdvRising ? 10.0 : 0.0
pen_participationWeak   = cacheRelativeVolume < 0.7 ? 6.0 : 0.0
pen_oppDeterioration    = opp_confidence < 30 ? 6.0 : 0.0
pen_momFailure          = (trend_longEvidence > trend_shortEvidence and mom_bullVotes == 0) or (trend_shortEvidence > trend_longEvidence and mom_bullVotes == 3) ? 5.0 : 0.0
pen_regimeInstability   = reg_stableBars < 2 ? 6.0 : 0.0
pen_mtfConflict         = i_mtfEnable and (cacheHigherTFTrendUp != trend_emaBullish) ? 7.0 : 0.0

pen_total = f_clamp(pen_trendConflict + pen_flowConflict + pen_participationWeak + pen_oppDeterioration + pen_momFailure + pen_regimeInstability + pen_mtfConflict, 0.0, 40.0)

// ============================================================================
// SECTION 12 — CONFIDENCE ENGINE (Chapter 8)
// Confidence never modifies feature values; it is a fully independent output.
// ============================================================================

conf_base = (trend_confidence * score_wTrend + flow_confidence * score_wFlow + opp_confidence * score_wOpp + part_confidence * score_wPart + mom_confidence * score_wMom) / score_sumWeights
conf_mtfAdj       = i_mtfEnable ? (cacheHigherTFTrendUp == trend_emaBullish ? 5.0 : -5.0) : 0.0
conf_stabilityAdj = (reg_stabilityScore - 50.0) / 50.0 * 10.0

conf_final = f_clamp(conf_base + conf_mtfAdj + conf_stabilityAdj - pen_total * 0.5, 0.0, 100.0)
conf_label  = f_confLabel(conf_final)

// ============================================================================
// FINAL SCORES — bounded 0-100, penalty applied last (Chapter 7 / 8)
// ============================================================================

score_finalLong  = f_clamp(score_longComposite - pen_total, 0.0, 100.0)
score_finalShort = f_clamp(score_shortComposite - pen_total, 0.0, 100.0)

// ============================================================================
// GRADE ENGINE — Composite screening grade for manual scanning
// Not part of the frozen Chapter 7 Score Engine; this is a convenience
// overlay for ranking symbols quickly during manual tarama. Uses only
// already-computed engine outputs (no re-calculation, no new indicators).
// ============================================================================

grade_volScore = f_clamp(cacheRelativeVolume * 100.0, 0.0, 100.0)
grade_atrScore = f_clamp(cacheRelativeATR * 100.0, 0.0, 100.0)
grade_crsScore = f_clamp(cacheCRS * 20.0, 0.0, 100.0)   // floor added: raw formula had no lower bound

grade_trendStrong = trend_status == "Strong"
grade_flowStrong  = flow_status == "Strong"
grade_mtfAligned  = i_mtfEnable ? (cacheHigherTFTrendUp == trend_emaBullish) : true
grade_regimeBull  = reg_type == "Bull Trend"
grade_alphaBull   = trend_alphaBullish

grade_base = score_finalLong * 0.20 + conf_final * 0.20 + opp_tradability * 0.10 + part_quality * 0.10 + mom_longEvidence * 0.08 + reg_stabilityScore * 0.08 + cacheMFI * 0.07 + grade_volScore * 0.05 + grade_atrScore * 0.03 + grade_crsScore * 0.04

grade_bonus = (grade_regimeBull ? 2.0 : 0.0) + (grade_trendStrong ? 2.0 : 0.0) + (grade_flowStrong ? 2.0 : 0.0) + (grade_mtfAligned ? 2.0 : 0.0) + (grade_alphaBull ? 2.0 : 0.0)

grade_score  = f_clamp(grade_base + grade_bonus, 0.0, 100.0)   // final clamp: base(max 95)+bonus(max 10) could exceed 100
grade_letter = grade_score >= 97 ? "A+" : grade_score >= 90 ? "A" : grade_score >= 85 ? "A-" : grade_score >= 80 ? "B+" : grade_score >= 70 ? "B" : grade_score >= 60 ? "C" : "D"

// --- Short-side mirror ---
// MFI and CRS are directional raw inputs (high MFI / positive CRS favors Long),
// so they are mirrored here to avoid a hidden Long bias in the Short grade.
grade_mfiScoreShort = 100.0 - cacheMFI
grade_crsScoreShort = f_clamp(-cacheCRS * 20.0, 0.0, 100.0)

grade_trendStrongShort = trend_status == "Strong" and trend_direction == "Bearish"
grade_flowStrongShort  = flow_status == "Strong" and flow_cdvTrendLabel == "Falling"
grade_regimeBear       = reg_type == "Bear Trend"
grade_alphaBearish     = not trend_alphaBullish
// mtfAligned is direction-agnostic (checks HTF/LTF agreement either way), reused as-is

grade_baseShort = score_finalShort * 0.20 + conf_final * 0.20 + opp_tradability * 0.10 + part_quality * 0.10 + mom_shortEvidence * 0.08 + reg_stabilityScore * 0.08 + grade_mfiScoreShort * 0.07 + grade_volScore * 0.05 + grade_atrScore * 0.03 + grade_crsScoreShort * 0.04

grade_bonusShort = (grade_regimeBear ? 2.0 : 0.0) + (grade_trendStrongShort ? 2.0 : 0.0) + (grade_flowStrongShort ? 2.0 : 0.0) + (grade_mtfAligned ? 2.0 : 0.0) + (grade_alphaBearish ? 2.0 : 0.0)

grade_scoreShort  = f_clamp(grade_baseShort + grade_bonusShort, 0.0, 100.0)
grade_letterShort = grade_scoreShort >= 97 ? "A+" : grade_scoreShort >= 90 ? "A" : grade_scoreShort >= 85 ? "A-" : grade_scoreShort >= 80 ? "B+" : grade_scoreShort >= 70 ? "B" : grade_scoreShort >= 60 ? "C" : "D"

// --- Best-direction selection (for the compact header display) ---
grade_bestIsLong = grade_score >= grade_scoreShort
grade_bestScore  = grade_bestIsLong ? grade_score : grade_scoreShort
grade_bestLetter = grade_bestIsLong ? grade_letter : grade_letterShort
grade_bestSide   = grade_bestIsLong ? "L" : "S"

// ============================================================================
// SECTION 13 — DASHBOARD (Chapter 9)
// Two independent panels. Rendered only on the last bar for performance
// (10.9 Performance Philosophy). Visualization never affects calculations.
// ============================================================================

var table ui_primary = table.new(f_tablePos(i_primaryPos), 7, 10, border_width=1)
var table ui_diag     = table.new(f_tablePos(i_diagPos), 2, 20, border_width=1)

f_scoreColor(v) => v >= 70 ? color.new(color.green, 20) : v >= 45 ? color.new(color.orange, 20) : color.new(color.red, 20)

// Trail columns are read via [5]..[1] historical reference (fully confirmed,
// never-repainting values from the last 5 completed bars), plus the current
// (live) bar in the rightmost column. Column layout: Label | T-5 | T-4 | T-3 | T-2 | T-1 | Now
if barstate.islast and i_showPrimary
    ts = f_textSize(i_textSize)
    table.cell(ui_primary, 0, 0, "MQE v1.6", text_color=color.white, bgcolor=color.new(color.blue, 40), text_size=ts)
    table.cell(ui_primary, 1, 0, "T-5", text_color=color.white, bgcolor=color.new(color.blue, 40), text_size=ts)
    table.cell(ui_primary, 2, 0, "T-4", text_color=color.white, bgcolor=color.new(color.blue, 40), text_size=ts)
    table.cell(ui_primary, 3, 0, "T-3", text_color=color.white, bgcolor=color.new(color.blue, 40), text_size=ts)
    table.cell(ui_primary, 4, 0, "T-2", text_color=color.white, bgcolor=color.new(color.blue, 40), text_size=ts)
    table.cell(ui_primary, 5, 0, "T-1", text_color=color.white, bgcolor=color.new(color.blue, 40), text_size=ts)
    table.cell(ui_primary, 6, 0, "Now", text_color=color.white, bgcolor=color.new(color.blue, 40), text_size=ts)

    table.cell(ui_primary, 0, 1, "Grade", text_color=color.white, text_size=ts)
    table.cell(ui_primary, 1, 1, str.tostring(math.round(grade_bestScore[5])), text_color=color.white, bgcolor=f_scoreColor(grade_bestScore[5]), text_size=ts)
    table.cell(ui_primary, 2, 1, str.tostring(math.round(grade_bestScore[4])), text_color=color.white, bgcolor=f_scoreColor(grade_bestScore[4]), text_size=ts)
    table.cell(ui_primary, 3, 1, str.tostring(math.round(grade_bestScore[3])), text_color=color.white, bgcolor=f_scoreColor(grade_bestScore[3]), text_size=ts)
    table.cell(ui_primary, 4, 1, str.tostring(math.round(grade_bestScore[2])), text_color=color.white, bgcolor=f_scoreColor(grade_bestScore[2]), text_size=ts)
    table.cell(ui_primary, 5, 1, str.tostring(math.round(grade_bestScore[1])), text_color=color.white, bgcolor=f_scoreColor(grade_bestScore[1]), text_size=ts)
    table.cell(ui_primary, 6, 1, grade_bestLetter + " (" + str.tostring(math.round(grade_bestScore)) + " " + grade_bestSide + ")", text_color=color.white, bgcolor=f_scoreColor(grade_bestScore), text_size=ts)

    table.cell(ui_primary, 0, 2, "Long Score",  text_color=color.white, text_size=ts)
    table.cell(ui_primary, 1, 2, str.tostring(math.round(score_finalLong[5])), text_color=color.white, bgcolor=f_scoreColor(score_finalLong[5]), text_size=ts)
    table.cell(ui_primary, 2, 2, str.tostring(math.round(score_finalLong[4])), text_color=color.white, bgcolor=f_scoreColor(score_finalLong[4]), text_size=ts)
    table.cell(ui_primary, 3, 2, str.tostring(math.round(score_finalLong[3])), text_color=color.white, bgcolor=f_scoreColor(score_finalLong[3]), text_size=ts)
    table.cell(ui_primary, 4, 2, str.tostring(math.round(score_finalLong[2])), text_color=color.white, bgcolor=f_scoreColor(score_finalLong[2]), text_size=ts)
    table.cell(ui_primary, 5, 2, str.tostring(math.round(score_finalLong[1])), text_color=color.white, bgcolor=f_scoreColor(score_finalLong[1]), text_size=ts)
    table.cell(ui_primary, 6, 2, str.tostring(math.round(score_finalLong)),    text_color=color.white, bgcolor=f_scoreColor(score_finalLong), text_size=ts)

    table.cell(ui_primary, 0, 3, "Short Score", text_color=color.white, text_size=ts)
    table.cell(ui_primary, 1, 3, str.tostring(math.round(score_finalShort[5])), text_color=color.white, bgcolor=f_scoreColor(score_finalShort[5]), text_size=ts)
    table.cell(ui_primary, 2, 3, str.tostring(math.round(score_finalShort[4])), text_color=color.white, bgcolor=f_scoreColor(score_finalShort[4]), text_size=ts)
    table.cell(ui_primary, 3, 3, str.tostring(math.round(score_finalShort[3])), text_color=color.white, bgcolor=f_scoreColor(score_finalShort[3]), text_size=ts)
    table.cell(ui_primary, 4, 3, str.tostring(math.round(score_finalShort[2])), text_color=color.white, bgcolor=f_scoreColor(score_finalShort[2]), text_size=ts)
    table.cell(ui_primary, 5, 3, str.tostring(math.round(score_finalShort[1])), text_color=color.white, bgcolor=f_scoreColor(score_finalShort[1]), text_size=ts)
    table.cell(ui_primary, 6, 3, str.tostring(math.round(score_finalShort)),    text_color=color.white, bgcolor=f_scoreColor(score_finalShort), text_size=ts)

    table.cell(ui_primary, 0, 4, "Confidence", text_color=color.white, text_size=ts)
    table.cell(ui_primary, 1, 4, str.tostring(math.round(conf_final[5])), text_color=color.white, bgcolor=f_scoreColor(conf_final[5]), text_size=ts)
    table.cell(ui_primary, 2, 4, str.tostring(math.round(conf_final[4])), text_color=color.white, bgcolor=f_scoreColor(conf_final[4]), text_size=ts)
    table.cell(ui_primary, 3, 4, str.tostring(math.round(conf_final[3])), text_color=color.white, bgcolor=f_scoreColor(conf_final[3]), text_size=ts)
    table.cell(ui_primary, 4, 4, str.tostring(math.round(conf_final[2])), text_color=color.white, bgcolor=f_scoreColor(conf_final[2]), text_size=ts)
    table.cell(ui_primary, 5, 4, str.tostring(math.round(conf_final[1])), text_color=color.white, bgcolor=f_scoreColor(conf_final[1]), text_size=ts)
    table.cell(ui_primary, 6, 4, str.tostring(math.round(conf_final)) + " (" + conf_label + ")", text_color=color.white, bgcolor=f_scoreColor(conf_final), text_size=ts)

    table.cell(ui_primary, 0, 5, "Regime", text_color=color.white, text_size=ts)
    table.cell(ui_primary, 6, 5, reg_emoji + " " + reg_type, text_color=color.white, text_size=ts)

    table.cell(ui_primary, 0, 6, "Trend", text_color=color.white, text_size=ts)
    table.cell(ui_primary, 6, 6, trend_direction + " (" + trend_status + ")", text_color=color.white, text_size=ts)

    table.cell(ui_primary, 0, 7, "Flow", text_color=color.white, text_size=ts)
    table.cell(ui_primary, 6, 7, flow_cdvTrendLabel + " (" + flow_status + ")", text_color=color.white, text_size=ts)

    table.cell(ui_primary, 0, 8, "Opportunity", text_color=color.white, text_size=ts)
    table.cell(ui_primary, 6, 8, opp_status, text_color=color.white, text_size=ts)

    table.cell(ui_primary, 0, 9, "Participation", text_color=color.white, text_size=ts)
    table.cell(ui_primary, 6, 9, part_status, text_color=color.white, text_size=ts)

if barstate.islast and i_showDiagnostics
    ts2 = f_textSize(i_textSize)
    table.cell(ui_diag, 0, 0,  "Diagnostics", text_color=color.white, bgcolor=color.new(color.gray, 40), text_size=ts2)
    table.cell(ui_diag, 1, 0,  "", bgcolor=color.new(color.gray, 40), text_size=ts2)
    table.cell(ui_diag, 0, 1,  "Trend Long/Short",  text_color=color.white, text_size=ts2)
    table.cell(ui_diag, 1, 1,  str.tostring(math.round(trend_longEvidence)) + " / " + str.tostring(math.round(trend_shortEvidence)), text_color=color.white, text_size=ts2)
    table.cell(ui_diag, 0, 2,  "Flow Long/Short", text_color=color.white, text_size=ts2)
    table.cell(ui_diag, 1, 2,  str.tostring(math.round(flow_longEvidence)) + " / " + str.tostring(math.round(flow_shortEvidence)), text_color=color.white, text_size=ts2)
    table.cell(ui_diag, 0, 3,  "Opportunity (Tradability)", text_color=color.white, text_size=ts2)
    table.cell(ui_diag, 1, 3,  str.tostring(math.round(opp_tradability)), text_color=color.white, text_size=ts2)
    table.cell(ui_diag, 0, 4,  "Participation Quality", text_color=color.white, text_size=ts2)
    table.cell(ui_diag, 1, 4,  str.tostring(math.round(part_quality)), text_color=color.white, text_size=ts2)
    table.cell(ui_diag, 0, 5,  "Momentum Long/Short", text_color=color.white, text_size=ts2)
    table.cell(ui_diag, 1, 5,  str.tostring(math.round(mom_longEvidence)) + " / " + str.tostring(math.round(mom_shortEvidence)), text_color=color.white, text_size=ts2)
    table.cell(ui_diag, 0, 6,  "Penalty (Total)", text_color=color.white, text_size=ts2)
    table.cell(ui_diag, 1, 6,  "-" + str.tostring(math.round(pen_total)), text_color=color.white, text_size=ts2)
    table.cell(ui_diag, 0, 7,  "Relative ATR", text_color=color.white, text_size=ts2)
    table.cell(ui_diag, 1, 7,  str.tostring(cacheRelativeATR, "#.##"), text_color=color.white, text_size=ts2)
    table.cell(ui_diag, 0, 8,  "Relative Volume", text_color=color.white, text_size=ts2)
    table.cell(ui_diag, 1, 8,  str.tostring(cacheRelativeVolume, "#.##"), text_color=color.white, text_size=ts2)
    table.cell(ui_diag, 0, 9,  "MFI", text_color=color.white, text_size=ts2)
    table.cell(ui_diag, 1, 9,  str.tostring(math.round(cacheMFI)), text_color=color.white, text_size=ts2)
    table.cell(ui_diag, 0, 10, "CDV Slope", text_color=color.white, text_size=ts2)
    table.cell(ui_diag, 1, 10, flow_cdvTrendLabel, text_color=color.white, text_size=ts2)
    table.cell(ui_diag, 0, 11, "CDV EMA/SMA Cross (Primary)", text_color=color.white, text_size=ts2)
    table.cell(ui_diag, 1, 11, flow_cdvCrossLabel, text_color=color.white, bgcolor=(flow_cdvEmaAboveSma ? color.new(color.green, 60) : color.new(color.red, 60)), text_size=ts2)
    table.cell(ui_diag, 0, 12, "MTF Alignment", text_color=color.white, text_size=ts2)
    table.cell(ui_diag, 1, 12, (i_mtfEnable ? (cacheHigherTFTrendUp == trend_emaBullish ? "Aligned" : "Conflict") : "Disabled"), text_color=color.white, text_size=ts2)
    table.cell(ui_diag, 0, 13, "Regime Stability", text_color=color.white, text_size=ts2)
    table.cell(ui_diag, 1, 13, str.tostring(math.round(reg_stabilityScore)) + "% (" + str.tostring(reg_stableBars) + " bars)", text_color=color.white, text_size=ts2)
    table.cell(ui_diag, 0, 14, "CRS", text_color=color.white, text_size=ts2)
    table.cell(ui_diag, 1, 14, str.tostring(cacheCRS, "#.##"), text_color=color.white, text_size=ts2)
    table.cell(ui_diag, 0, 15, "AlphaTrend Confirm", text_color=color.white, text_size=ts2)
    table.cell(ui_diag, 1, 15, (trend_alphaBullish ? "Bullish" : "Bearish"), text_color=color.white, text_size=ts2)
    table.cell(ui_diag, 0, 16, "Long Grade", text_color=color.white, text_size=ts2)
    table.cell(ui_diag, 1, 16, grade_letter + " (" + str.tostring(math.round(grade_score)) + ")", text_color=color.white, text_size=ts2)
    table.cell(ui_diag, 0, 17, "Short Grade", text_color=color.white, text_size=ts2)
    table.cell(ui_diag, 1, 17, grade_letterShort + " (" + str.tostring(math.round(grade_scoreShort)) + ")", text_color=color.white, text_size=ts2)
    table.cell(ui_diag, 0, 18, "Active MTF Timeframe", text_color=color.white, text_size=ts2)
    table.cell(ui_diag, 1, 18, finalMtfTF + (i_mtfAutoMode ? " (Auto)" : " (Manual)"), text_color=color.white, text_size=ts2)
    table.cell(ui_diag, 0, 19, "Active AlphaTrend Timeframe", text_color=color.white, text_size=ts2)
    table.cell(ui_diag, 1, 19, finalAlphaTF + (i_mtfAutoMode ? " (Auto)" : " (Manual)"), text_color=color.white, text_size=ts2)

// Chart overlays for visual reference
plot(cacheEMA50,  "EMA 50",  color=color.new(color.aqua, 40))
plot(cacheEMA200, "EMA 200", color=color.new(color.orange, 40))
plot(cacheAlphaTrend, "AlphaTrend (HTF)", color=color.new(color.purple, 20), linewidth=2)

// ============================================================================
// SECTION 14 — ALERTS (Chapter 9.10-9.12)
// State-transition oriented; avoids alert fatigue from constant score updates.
// ============================================================================

alertcondition(ta.crossover(score_finalLong, i_longAlertThresh), title="MQE Long Score Alert", message="MQE: Long Score crossed above threshold")
alertcondition(ta.crossover(score_finalShort, i_shortAlertThresh), title="MQE Short Score Alert", message="MQE: Short Score crossed above threshold")
alertcondition(ta.crossover(conf_final, i_confAlertThresh), title="MQE Confidence Alert", message="MQE: Confidence crossed above threshold")
alertcondition(ta.crossunder(conf_final, 40), title="MQE Confidence Warning", message="MQE: Confidence fell below acceptable range")
alertcondition(reg_changed and reg_type == "Bull Trend", title="MQE Bull Trend Started", message="MQE: Bull Trend regime detected")
alertcondition(reg_changed and reg_type == "Bear Trend", title="MQE Bear Trend Started", message="MQE: Bear Trend regime detected")
alertcondition(reg_changed and reg_type == "Transition", title="MQE Transition Detected", message="MQE: Market entered Transition regime")
alertcondition(pen_total >= 25, title="MQE Major Penalty Active", message="MQE: Major analytical conflict detected")

// ============================================================================
// SECTION 15 — DEBUG TOOLS (Chapter 10.12)
// Disabled by default. Exposes raw votes for validation/calibration.
// ============================================================================

var table ui_debug = table.new(position.middle_right, 2, 6, border_width=1)
if barstate.islast and i_debugMode
    table.cell(ui_debug, 0, 0, "DEBUG", text_color=color.white, bgcolor=color.new(color.maroon, 30))
    table.cell(ui_debug, 1, 0, "", bgcolor=color.new(color.maroon, 30))
    table.cell(ui_debug, 0, 1, "Trend Votes", text_color=color.white)
    table.cell(ui_debug, 1, 1, str.tostring(trend_bullVotes) + "/5", text_color=color.white)
    table.cell(ui_debug, 0, 2, "Flow Votes", text_color=color.white)
    table.cell(ui_debug, 1, 2, str.tostring(flow_bullVotes) + "/4", text_color=color.white)
    table.cell(ui_debug, 0, 3, "Opportunity Votes", text_color=color.white)
    table.cell(ui_debug, 1, 3, str.tostring(opp_votes) + "/4", text_color=color.white)
    table.cell(ui_debug, 0, 4, "Participation Votes", text_color=color.white)
    table.cell(ui_debug, 1, 4, str.tostring(part_votes) + "/4", text_color=color.white)
    table.cell(ui_debug, 0, 5, "Momentum Votes", text_color=color.white)
    table.cell(ui_debug, 1, 5, str.tostring(mom_bullVotes) + "/3", text_color=color.white)
````
