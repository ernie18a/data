<!-- tradingview-pine-id: PUB;d9d8a227c7704a35b6d0603716525812 -->
<!-- tradingviewscripts-format: 1 -->
# Razor Fractal Mirror

Source: https://www.tradingview.com/script/uiLgbtZg-Razor-Fractal-Mirror/

## Description

Historical analog projection and market-state intelligence

Razor Fractal Mirror scans the recent history of the current chart for past price structures that resemble what's happening right now, then projects how those historical structures resolved forward in time — as a probabilistic scenario, not a prediction.

What It Does

1. Structure Matching
The indicator normalizes the last Pattern Length bars (log-return or percent-change shape, user's choice) and compares that shape against thousands of historical windows going back up to the configured Historical Search Depth. Each candidate is scored on three components:
•	Shape correlation — how closely the normalized price path matches
•	Normalized error — RMSE between the current and candidate paths
•	Regime compatibility (optional) — whether the candidate occurred in a similar trend/volatility regime, measured via EMA distance and ATR-normalized volatility
These three scores combine into a single composite similarity score, weighted by user-configurable inputs.

2. Analog Selection

The engine keeps the three strongest, non-overlapping matches — minimum spacing is enforced so it isn't just picking adjacent bars of the same move — that clear the minimum similarity threshold.

3. Forward Projection

For each matched analog, the indicator replays what price actually did in the bars after that historical structure, rescaled proportionally to the current price. These are blended into a similarity-weighted consensus path, with the individual analog paths shown as secondary "mirror" lines and a confidence cloud representing the spread between them.

4. Mirror Quality Scoring

A composite 0–100 score (graded A+ through D) built from average similarity, regime match, path stability (agreement between analogs plus cloud compactness), and outcome reliability (historical reward-to-risk and target-hit rates from those same analogs).

5. Decision Layer

Combines Mirror Quality, analog agreement, projected move size (in ATR), and optional multi-timeframe bias fusion (four configurable timeframes) into a state: ACTIONABLE, WATCH, or AVOID. Includes early and confirmation checkpoints plus a calculated invalidation level.

6. Live Lifecycle Tracking

Once a mirror is locked, the indicator tracks price adherence to the projected path bar-by-bar, flags drift or invalidation in real time, and records the eventual outcome into a rolling forecast library. That library feeds an adaptive "analog reputation" score that adjusts future decision scoring based on how this specific setup's projections have actually performed — and reports whether the model is trending IMPROVING, STABLE, or DEGRADING.

7. Projection Anchoring

Three modes control how projections behave once drawn: Locked Snapshot (freezes the projection at capture so it doesn't repaint as price moves), Hybrid (controlled refresh), and Live Projection (recalculates continuously).

Why It's Useful

Most "pattern matching" tools just eyeball similar-looking chart shapes. This engine quantifies similarity mathematically (correlation, error, and regime fit), requires multiple independent historical analogs to agree before calling a setup actionable, and — critically — tracks its own projections against real subsequent price action so traders can see adherence, drift, and invalidation as they happen rather than only in hindsight.

Why It's Unique

•	Analog selection uses a three-factor composite score, not simple pattern-shape correlation alone.
•	Self-tracking forecasts: locked projections are graded against real outcomes and feed an adaptive reputation score — the tool has a memory of its own track record.
•	Snapshot anchoring prevents repainting of the displayed projection, addressing a common criticism of analog and projection-style indicators.
•	Multi-timeframe fusion cross-checks the projected direction against bias and confidence readings from four additional timeframes before flagging a setup actionable.

Important Notes

 Historical similarity does not guarantee a repeated outcome. Projections are analytical scenarios derived from historical analog behavior, not financial advice or a guarantee of future price action. Always combine with proper risk management and a trade plan.

---

## Source Code

````pine
//@version=6
indicator("Razor Fractal Mirror", shorttitle="Razor Fractal Mirror", overlay=true, scale=scale.none, max_bars_back=5000, max_lines_count=500, max_labels_count=150, max_boxes_count=300)

//──────────────────────────────────────────────────────────────────────────────
// RAZOR FRACTAL MIRROR
// Historical analog projection and market-state intelligence
//
// This indicator compares the current normalized price structure with past
// market structures, ranks the strongest historical analogs, and projects
// their subsequent paths into the future. The weighted consensus path,
// confidence cloud, quality model, adaptive statistics, multi-timeframe
// fusion, persistent snapshots, lifecycle tracking, and alerts are intended
// to support probabilistic market analysis—not deterministic prediction.
//
// IMPORTANT
// • Historical similarity does not guarantee a repeated outcome.
// • Projections are analytical scenarios, not financial advice.
// • Locked Snapshot mode preserves the generated path after capture.
// • All chart objects use bar-index price anchoring.
//──────────────────────────────────────────────────────────────────────────────

plot(close, "1708 Price Binding", color=color.new(color.white, 100), display=display.none, force_overlay=true)

// INPUTS
groupEngine = "Mirror Engine"
patternLen      = input.int(24, "Pattern Length", minval=8, maxval=80, group=groupEngine, tooltip="Number of recent bars used to define the current structure.")
futureLen       = input.int(20, "Projection Length", minval=5, maxval=60, group=groupEngine, tooltip="Number of future bars shown by the historical analog projection.")
searchDepth     = input.int(900, "Historical Search Depth", minval=200, maxval=4000, group=groupEngine)
scanStep        = input.int(3, "Scan Step", minval=1, maxval=20, group=groupEngine)
minSimilarity   = input.float(62.0, "Minimum Similarity", minval=0.0, maxval=100.0, step=1.0, group=groupEngine, tooltip="Minimum composite score required for a historical structure to qualify as an analog.")
minimumSpacing  = input.int(20, "Minimum Match Spacing", minval=1, maxval=200, group=groupEngine)

groupModel = "Similarity Model"
shapeWeight     = input.float(0.58, "Shape Weight", minval=0.0, maxval=1.0, step=0.01, group=groupModel)
errorWeight     = input.float(0.22, "Normalized Error Weight", minval=0.0, maxval=1.0, step=0.01, group=groupModel)
regimeWeight    = input.float(0.20, "Regime Weight", minval=0.0, maxval=1.0, step=0.01, group=groupModel)
errorScale      = input.float(8.0, "Error Sensitivity", minval=1.0, maxval=30.0, step=0.5, group=groupModel)
useLogReturns   = input.bool(true, "Use Log-Normalized Shape", group=groupModel)

groupRegime = "Regime Filter"
useRegimeFilter = input.bool(true, "Enable Regime-Aware Matching", group=groupRegime)
trendLen        = input.int(50, "Trend Length", minval=10, maxval=200, group=groupRegime)
atrLen          = input.int(14, "ATR Length", minval=5, maxval=100, group=groupRegime)
regimeTolerance = input.float(35.0, "Regime Tolerance", minval=5.0, maxval=100.0, step=5.0, group=groupRegime)

groupProjection = "Projection Engine"
showConsensus   = input.bool(true, "Show Consensus Path", group=groupProjection)
showMirrors     = input.bool(true, "Show Secondary Mirrors", group=groupProjection)
showTunnel      = input.bool(true, "Show Confidence Cloud", group=groupProjection)
smoothLen       = input.int(3, "Path Smoothing", minval=1, maxval=8, group=groupProjection)
consensusWidth  = input.int(4, "Consensus Width", minval=2, maxval=6, group=groupProjection)
mirrorWidth     = input.int(1, "Mirror Width", minval=1, maxval=2, group=groupProjection)
cloudOpacity   = input.int(86, "Cloud Opacity", minval=70, maxval=96, group=groupProjection)
neutralThreshold = input.float(0.15, "Neutral Move Threshold %", minval=0.0, maxval=1.0, step=0.05, group=groupProjection)

groupDecision = "Decision Layer"
showDecisionMap = input.bool(true, "Show Decision Map", group=groupDecision)
minimumQuality  = input.float(66.0, "Actionable Quality", minval=0.0, maxval=100.0, step=1.0, group=groupDecision)
minimumAgreement = input.float(66.0, "Actionable Agreement", minval=0.0, maxval=100.0, step=1.0, group=groupDecision)
minimumMoveATR  = input.float(0.35, "Minimum Projected Move ATR", minval=0.0, maxval=5.0, step=0.05, group=groupDecision)
riskBuffer      = input.float(1.0, "Invalidation Risk Multiplier", minval=0.25, maxval=3.0, step=0.25, group=groupDecision)
showCheckpoint1 = input.bool(true, "Show Early Checkpoint", group=groupDecision)
showCheckpoint2 = input.bool(true, "Show Confirmation Checkpoint", group=groupDecision)

groupSnapshot = "Projection Anchoring"
projectionMode = input.string(
     "Locked Snapshot",
     "Projection Mode",
     options=["Locked Snapshot", "Hybrid", "Live Projection"],
     group=groupSnapshot,
     tooltip="Locked Snapshot preserves the captured path. Hybrid allows controlled refreshing. Live Projection recalculates from current price.")
snapshotRefreshBars = input.int(0, "Snapshot Refresh Bars (0 = Never)", minval=0, maxval=500, group=groupSnapshot)
refreshOnNewActionable = input.bool(false, "Refresh on New Actionable Setup", group=groupSnapshot)

groupLifecycle = "Live Mirror Lifecycle"
enableLifecycle   = input.bool(true, "Enable Locked Mirror Tracking", group=groupLifecycle)
autoLockActionable = input.bool(true, "Auto-Lock Actionable Mirrors", group=groupLifecycle)
minimumLockScore  = input.float(72.0, "Minimum Lock Score", minval=0.0, maxval=100.0, step=1.0, group=groupLifecycle)
adherenceToleranceATR = input.float(0.75, "Adherence Tolerance ATR", minval=0.10, maxval=3.0, step=0.05, group=groupLifecycle)
driftToleranceATR = input.float(1.50, "Drift Threshold ATR", minval=0.25, maxval=5.0, step=0.10, group=groupLifecycle)
showLockedPath   = input.bool(true, "Show Locked Forecast", group=groupLifecycle)
showTrackingBadge = input.bool(true, "Show Tracking Badge", group=groupLifecycle)
resetAfterBars   = input.int(8, "Result Hold Bars", minval=1, maxval=100, group=groupLifecycle)

groupAdaptive = "Adaptive Intelligence"
enableAdaptive     = input.bool(true, "Enable Adaptive Intelligence", group=groupAdaptive)
maxLibrarySize     = input.int(30, "Forecast Library Size", minval=5, maxval=100, group=groupAdaptive)
reputationWeight   = input.float(0.20, "Reputation Weight", minval=0.0, maxval=0.50, step=0.05, group=groupAdaptive)
densityTarget      = input.int(8, "Strong Analog Density", minval=3, maxval=30, group=groupAdaptive)

groupFusion = "Multi-Timeframe Fusion"
enableFusion      = input.bool(true, "Enable MTF Fusion", group=groupFusion)
fusionTf1         = input.timeframe("5", "Fusion Timeframe 1", group=groupFusion)
fusionTf2         = input.timeframe("15", "Fusion Timeframe 2", group=groupFusion)
fusionTf3         = input.timeframe("30", "Fusion Timeframe 3", group=groupFusion)
fusionTf4         = input.timeframe("60", "Fusion Timeframe 4", group=groupFusion)
minimumFusionAgreement = input.float(75.0, "Actionable MTF Agreement", minval=25.0, maxval=100.0, step=25.0, group=groupFusion)
fusionImpact      = input.float(0.20, "Fusion Score Weight", minval=0.0, maxval=0.50, step=0.05, group=groupFusion)
requireFusionForActionable = input.bool(true, "Require Fusion for Actionable", group=groupFusion)

groupAlerts = "Alerts"
enableAlerts         = input.bool(true, "Enable Alerts", group=groupAlerts)
alertOnActionable    = input.bool(true, "Actionable Mirror", group=groupAlerts)
alertOnSnapshot      = input.bool(true, "New Snapshot", group=groupAlerts)
alertOnTrack         = input.bool(false, "Forecast On Track", group=groupAlerts)
alertOnDrift         = input.bool(true, "Forecast Drifting", group=groupAlerts)
alertOnInvalidation  = input.bool(true, "Mirror Invalidated", group=groupAlerts)
alertOnTarget        = input.bool(true, "Target Reached", group=groupAlerts)
alertOncePerBarClose = input.bool(true, "Alerts Once Per Bar Close", group=groupAlerts)

groupPublication = "Display Controls"
displayMode = input.string(
     "Clean",
     "Display Mode",
     options=["Full", "Clean", "Projection Only", "Dashboard Only"],
     group=groupPublication,
     tooltip="Clean is recommended for normal use. Full exposes all analytical objects and checkpoints.")
showDashboard = input.bool(true, "Show Dashboard", group=groupPublication)
showHistoricalMarkers = input.bool(false, "Show Historical Match Markers", group=groupPublication)
showTechnicalRows = input.bool(true, "Show Technical Dashboard Rows", group=groupPublication)
showAdvancedRows = input.bool(true, "Show Advanced Dashboard Rows", group=groupPublication)
showBranding = input.bool(true, "Show Razor Branding", group=groupPublication)

groupVisual = "Visuals"
showMatchMarker = input.bool(false, "Mark Historical Matches", group=groupVisual)
showAnchor      = input.bool(true, "Show Projection Anchor", group=groupVisual)
dashboardPos    = input.string("Middle Right", "Dashboard Position",
     options=["Top Right", "Middle Right", "Bottom Right", "Top Left", "Middle Left", "Bottom Left"], group=groupVisual)

// COLORS
bullColor      = color.rgb(34, 211, 153)
bearColor      = color.rgb(248, 113, 113)
goldColor      = color.rgb(245, 194, 66)
cyanColor      = color.rgb(56, 189, 248)
violetColor    = color.rgb(167, 139, 250)
panelBg        = color.rgb(8, 14, 28)
panelBg2       = color.rgb(14, 23, 42)
mutedText      = color.rgb(148, 163, 184)
frameColor     = color.rgb(201, 162, 39)

// HELPERS
f_position(string value) =>
    switch value
        "Top Right"    => position.top_right
        "Middle Right" => position.middle_right
        "Bottom Right" => position.bottom_right
        "Top Left"     => position.top_left
        "Middle Left"  => position.middle_left
        => position.bottom_left

f_normValue(int offset, int oldestOffset) =>
    float base = close[oldestOffset]
    float value = close[offset]
    useLogReturns ? math.log(value / base) : (value / base - 1.0)

f_regimeTrend(int offset) =>
    float basis = ta.ema(close, trendLen)[offset]
    float atrValue = ta.atr(atrLen)[offset]
    atrValue > 0.0 ? (close[offset] - basis) / atrValue : 0.0

f_regimeVolatility(int offset) =>
    float atrValue = ta.atr(atrLen)[offset]
    close[offset] != 0.0 ? atrValue / close[offset] * 100.0 : 0.0

f_regimeScore(int candidateEndOffset) =>
    if not useRegimeFilter
        100.0
    else
        float currentTrend = f_regimeTrend(0)
        float candidateTrend = f_regimeTrend(candidateEndOffset)
        float currentVol = f_regimeVolatility(0)
        float candidateVol = f_regimeVolatility(candidateEndOffset)
        float trendDelta = math.abs(currentTrend - candidateTrend)
        float volDeltaPct = currentVol > 0.0 ? math.abs(candidateVol - currentVol) / currentVol * 100.0 : 0.0
        float trendScore = 100.0 / (1.0 + trendDelta)
        float volatilityScore = math.max(0.0, 100.0 - volDeltaPct)
        float rawScore = trendScore * 0.60 + volatilityScore * 0.40
        rawScore >= regimeTolerance ? rawScore : rawScore * 0.50

f_similarity(int candidateEndOffset) =>
    int currentOldest = patternLen - 1
    int candidateOldest = candidateEndOffset + patternLen - 1
    float meanCurrent = 0.0
    float meanCandidate = 0.0

    for i = 0 to patternLen - 1
        int currentOffset = patternLen - 1 - i
        int candidateOffset = candidateEndOffset + patternLen - 1 - i
        meanCurrent += f_normValue(currentOffset, currentOldest)
        meanCandidate += f_normValue(candidateOffset, candidateOldest)

    meanCurrent /= patternLen
    meanCandidate /= patternLen

    float covariance = 0.0
    float varianceCurrent = 0.0
    float varianceCandidate = 0.0
    float squaredError = 0.0

    for i = 0 to patternLen - 1
        int currentOffset = patternLen - 1 - i
        int candidateOffset = candidateEndOffset + patternLen - 1 - i
        float currentValue = f_normValue(currentOffset, currentOldest)
        float candidateValue = f_normValue(candidateOffset, candidateOldest)
        float currentCentered = currentValue - meanCurrent
        float candidateCentered = candidateValue - meanCandidate
        covariance += currentCentered * candidateCentered
        varianceCurrent += currentCentered * currentCentered
        varianceCandidate += candidateCentered * candidateCentered
        float delta = currentValue - candidateValue
        squaredError += delta * delta

    float denominator = math.sqrt(varianceCurrent * varianceCandidate)
    float correlation = denominator > 0.0 ? covariance / denominator : 0.0
    float shapeScore = math.max(0.0, math.min(100.0, (correlation + 1.0) * 50.0))
    float rmse = math.sqrt(squaredError / patternLen)
    float normalizedErrorScore = 100.0 / (1.0 + rmse * errorScale * 100.0)
    float rScore = f_regimeScore(candidateEndOffset)
    float totalWeight = shapeWeight + errorWeight + regimeWeight
    float combined = totalWeight > 0.0 ? (shapeScore * shapeWeight + normalizedErrorScore * errorWeight + rScore * regimeWeight) / totalWeight : shapeScore
    math.max(0.0, math.min(100.0, combined))

f_rawProjectedPrice(int candidateEndOffset, int stepForward) =>
    float candidateEndPrice = close[candidateEndOffset]
    float candidateFuturePrice = close[candidateEndOffset - stepForward]
    float ratio = candidateEndPrice != 0.0 ? candidateFuturePrice / candidateEndPrice : 1.0
    close * ratio

f_smoothedProjectedPrice(int candidateEndOffset, int stepForward) =>
    float sum = 0.0
    int count = 0
    int startStep = math.max(0, stepForward - smoothLen + 1)
    for s = startStep to stepForward
        sum += s == 0 ? close : f_rawProjectedPrice(candidateEndOffset, s)
        count += 1
    count > 0 ? sum / count : close

f_isSeparated(int offset, int selectedA, int selectedB) =>
    bool separatedA = na(selectedA) or math.abs(offset - selectedA) >= minimumSpacing
    bool separatedB = na(selectedB) or math.abs(offset - selectedB) >= minimumSpacing
    separatedA and separatedB

f_consensusPrice(int stepForward, int o1, float s1, int o2, float s2, int o3, float s3) =>
    float weightedPrice = 0.0
    float totalWeight = 0.0
    if not na(o1) and not na(s1)
        weightedPrice += f_smoothedProjectedPrice(o1, stepForward) * s1
        totalWeight += s1
    if not na(o2) and not na(s2)
        weightedPrice += f_smoothedProjectedPrice(o2, stepForward) * s2
        totalWeight += s2
    if not na(o3) and not na(s3)
        weightedPrice += f_smoothedProjectedPrice(o3, stepForward) * s3
        totalWeight += s3
    totalWeight > 0.0 ? weightedPrice / totalWeight : close

f_directionText(float projectedEnd) =>
    projectedEnd > close ? "BULLISH" : projectedEnd < close ? "BEARISH" : "NEUTRAL"

f_directionColor(float projectedEnd) =>
    projectedEnd > close ? bullColor : projectedEnd < close ? bearColor : mutedText

f_clearLines(line[] container) =>
    int count = array.size(container)
    if count > 0
        for i = count - 1 to 0
            line.delete(array.get(container, i))
        array.clear(container)

f_clearLabels(label[] container) =>
    int count = array.size(container)
    if count > 0
        for i = count - 1 to 0
            label.delete(array.get(container, i))
        array.clear(container)

f_clearBoxes(box[] container) =>
    int count = array.size(container)
    if count > 0
        for i = count - 1 to 0
            box.delete(array.get(container, i))
        array.clear(container)



f_drawMirror(int candidateOffset, color pathColor, line[] container) =>
    float previousPrice = close
    for step = 1 to futureLen
        float nextPrice = f_smoothedProjectedPrice(candidateOffset, step)
        line segment = line.new(
             x1=bar_index + step - 1,
             y1=previousPrice,
             x2=bar_index + step,
             y2=nextPrice,
             xloc=xloc.bar_index,
             extend=extend.none,
             color=pathColor,
             width=mirrorWidth,
             style=line.style_solid,
             force_overlay=true)
        array.push(container, segment)
        previousPrice := nextPrice


// MULTI-TIMEFRAME FUSION HELPERS
f_tfBias(string tf) =>
    request.security(
         syminfo.tickerid,
         tf,
         close > ta.ema(close, trendLen) and ta.ema(close, trendLen) > ta.ema(close, trendLen)[1] ? 1 :
         close < ta.ema(close, trendLen) and ta.ema(close, trendLen) < ta.ema(close, trendLen)[1] ? -1 :
         0,
         gaps=barmerge.gaps_off,
         lookahead=barmerge.lookahead_off)

f_tfConfidence(string tf) =>
    request.security(
         syminfo.tickerid,
         tf,
         math.min(
              100.0,
              math.abs(close - ta.ema(close, trendLen)) /
              math.max(ta.atr(atrLen), syminfo.mintick) * 35.0 +
              math.abs(ta.ema(close, trendLen) - ta.ema(close, trendLen)[1]) /
              math.max(ta.atr(atrLen), syminfo.mintick) * 120.0),
         gaps=barmerge.gaps_off,
         lookahead=barmerge.lookahead_off)

f_biasText(int bias) =>
    bias > 0 ? "BULLISH" : bias < 0 ? "BEARISH" : "NEUTRAL"

f_biasColor(int bias) =>
    bias > 0 ? bullColor : bias < 0 ? bearColor : goldColor

// DRAWING CONTAINERS
var line[] consensusLines = array.new_line()
var line[] mirror1Lines = array.new_line()
var line[] mirror2Lines = array.new_line()
var line[] mirror3Lines = array.new_line()
var line[] anchorLines = array.new_line()
var line[] upperCloudLines = array.new_line()
var line[] lowerCloudLines = array.new_line()
var box[] cloudFillBoxes = array.new_box()
var label[] endpointLabels = array.new_label()
var label[] historyLabels = array.new_label()
var line[] decisionLines = array.new_line()
var label[] decisionLabels = array.new_label()
var line[] lockedPathLines = array.new_line()
var line[] trackingLines = array.new_line()
var label[] trackingLabels = array.new_label()
var line[] snapshotConsensusLines = array.new_line()
var line[] snapshotMirrorLines = array.new_line()
var line[] snapshotBoundaryLines = array.new_line()
var box[] snapshotCloudBoxes = array.new_box()
var label[] snapshotLabels = array.new_label()

// STATE
var float bestScore = na
var float secondScore = na
var float thirdScore = na
var int bestOffset = na
var int secondOffset = na
var int thirdOffset = na
var float consensusEnd = na
var float agreement = na
var float averageSimilarity = na
var float bullishOutcomeRate = na
var float averageHistoricalMove = na
var float avgMFE = na
var float avgMAE = na
var float probability1ATR = na
var float probability2ATR = na
var float avgTimeToPeak = na
var float mirrorQuality = na
var string mirrorGrade = "—"
var float regimeQuality = na
var float stabilityScore = na
var float outcomeReliability = na
var float decisionScore = na
var string decisionState = "SEARCHING"
var float checkpoint1Price = na
var float checkpoint2Price = na
var float invalidationPrice = na
var float projectedMoveATR = na
var int analogDensity = 0
var float regimeConsensus = na
var float historicalReliability = na
var float forecastHealth = na
var float analogReputation = 50.0
var string modelDrift = "STABLE"
var int tfBias1 = 0
var int tfBias2 = 0
var int tfBias3 = 0
var int tfBias4 = 0
var float tfConfidence1 = na
var float tfConfidence2 = na
var float tfConfidence3 = na
var float tfConfidence4 = na
var float fusionAgreement = na
var float fusionConfidence = na
var int fusionBias = 0
var string dominantTf = "—"
var bool fusionConflict = false
var bool resultRecorded = false
var float[] forecastScores = array.new_float()
var float[] forecastErrors = array.new_float()


// LOCKED MIRROR STATE
var bool mirrorLocked = false
var int lockBarIndex = na
var int lockLength = na
var int lockDirection = 0
var float lockEntryPrice = na
var float lockAtr = na
var float lockInvalidation = na
var float lockDecisionScore = na
var float lockQuality = na
var string lockGrade = "—"
var string trackingState = "IDLE"
var float adherenceScore = na
var float trackingErrorATR = na
var int completedSteps = 0
var int resultBarIndex = na
var float[] lockedPrices = array.new_float()

// FIXED SNAPSHOT STATE
varip bool snapshotActive = false
varip int snapshotBarIndex = na
varip int snapshotLength = na
varip int snapshotDirection = 0
varip float snapshotEntry = na
varip float snapshotInvalidation = na
varip float snapshotDecisionScore = na
varip float snapshotQuality = na
varip string snapshotGrade = "—"
varip string snapshotDecisionState = "SEARCHING"
varip float[] snapshotConsensus = array.new_float()
varip float[] snapshotUpper = array.new_float()
varip float[] snapshotLower = array.new_float()
varip float[] snapshotMirror1 = array.new_float()
varip float[] snapshotMirror2 = array.new_float()
varip float[] snapshotMirror3 = array.new_float()

// ALERT EVENT STATE
var string previousDecisionState = "SEARCHING"
var string previousTrackingState = "IDLE"
var bool previousSnapshotActive = false
var bool actionableEvent = false
var bool snapshotEvent = false
var bool onTrackEvent = false
var bool driftEvent = false
var bool invalidationEvent = false
var bool targetEvent = false

bool enoughHistory = bar_index > searchDepth + patternLen + futureLen + trendLen + 10

if barstate.islast
    // MULTI-TIMEFRAME MIRROR FUSION
    tfBias1 := enableFusion ? f_tfBias(fusionTf1) : 0
    tfBias2 := enableFusion ? f_tfBias(fusionTf2) : 0
    tfBias3 := enableFusion ? f_tfBias(fusionTf3) : 0
    tfBias4 := enableFusion ? f_tfBias(fusionTf4) : 0

    tfConfidence1 := enableFusion ? f_tfConfidence(fusionTf1) : na
    tfConfidence2 := enableFusion ? f_tfConfidence(fusionTf2) : na
    tfConfidence3 := enableFusion ? f_tfConfidence(fusionTf3) : na
    tfConfidence4 := enableFusion ? f_tfConfidence(fusionTf4) : na

    int bullTfCount = (tfBias1 > 0 ? 1 : 0) + (tfBias2 > 0 ? 1 : 0) + (tfBias3 > 0 ? 1 : 0) + (tfBias4 > 0 ? 1 : 0)
    int bearTfCount = (tfBias1 < 0 ? 1 : 0) + (tfBias2 < 0 ? 1 : 0) + (tfBias3 < 0 ? 1 : 0) + (tfBias4 < 0 ? 1 : 0)
    int directionalTfCount = bullTfCount + bearTfCount

    fusionBias := bullTfCount > bearTfCount ? 1 : bearTfCount > bullTfCount ? -1 : 0
    fusionAgreement := directionalTfCount > 0 ? math.max(bullTfCount, bearTfCount) / 4.0 * 100.0 : 0.0

    float confidenceSum = nz(tfConfidence1) + nz(tfConfidence2) + nz(tfConfidence3) + nz(tfConfidence4)
    fusionConfidence := confidenceSum / 4.0
    fusionConflict := bullTfCount > 0 and bearTfCount > 0

    float maxTfConfidence = math.max(tfConfidence1, math.max(tfConfidence2, math.max(tfConfidence3, tfConfidence4)))
    dominantTf :=
         maxTfConfidence == tfConfidence1 ? fusionTf1 :
         maxTfConfidence == tfConfidence2 ? fusionTf2 :
         maxTfConfidence == tfConfidence3 ? fusionTf3 :
         fusionTf4
    f_clearLines(consensusLines)
    f_clearLines(mirror1Lines)
    f_clearLines(mirror2Lines)
    f_clearLines(mirror3Lines)
    f_clearLines(anchorLines)
    f_clearLines(upperCloudLines)
    f_clearLines(lowerCloudLines)
    f_clearBoxes(cloudFillBoxes)
    f_clearLabels(endpointLabels)
    f_clearLabels(historyLabels)
    f_clearLines(decisionLines)
    f_clearLabels(decisionLabels)
    f_clearLines(lockedPathLines)
    f_clearLines(trackingLines)
    f_clearLabels(trackingLabels)
    f_clearLines(snapshotConsensusLines)
    f_clearLines(snapshotMirrorLines)
    f_clearLines(snapshotBoundaryLines)
    f_clearBoxes(snapshotCloudBoxes)
    f_clearLabels(snapshotLabels)

    bestScore := na
    secondScore := na
    thirdScore := na
    bestOffset := na
    secondOffset := na
    thirdOffset := na
    consensusEnd := na
    agreement := na
    averageSimilarity := na
    bullishOutcomeRate := na
    averageHistoricalMove := na
    avgMFE := na
    avgMAE := na
    probability1ATR := na
    probability2ATR := na
    avgTimeToPeak := na
    mirrorQuality := na
    mirrorGrade := "—"
    regimeQuality := na
    stabilityScore := na
    outcomeReliability := na
    decisionScore := na
    decisionState := "SEARCHING"
    checkpoint1Price := na
    checkpoint2Price := na
    invalidationPrice := na
    projectedMoveATR := na
    analogDensity := 0
    regimeConsensus := na
    historicalReliability := na
    forecastHealth := na

    if enoughHistory
        int minimumOffset = patternLen + futureLen + 5
        int maximumOffset = math.min(searchDepth, bar_index - patternLen - trendLen - 2)

        for candidateOffset = minimumOffset to maximumOffset by scanStep
            float score = f_similarity(candidateOffset)
            if score >= minSimilarity
                analogDensity += 1
                if na(bestScore) or score > bestScore
                    if f_isSeparated(candidateOffset, bestOffset, secondOffset)
                        thirdScore := secondScore
                        thirdOffset := secondOffset
                        secondScore := bestScore
                        secondOffset := bestOffset
                        bestScore := score
                        bestOffset := candidateOffset
                else if (na(secondScore) or score > secondScore) and f_isSeparated(candidateOffset, bestOffset, na)
                    thirdScore := secondScore
                    thirdOffset := secondOffset
                    secondScore := score
                    secondOffset := candidateOffset
                else if (na(thirdScore) or score > thirdScore) and f_isSeparated(candidateOffset, bestOffset, secondOffset)
                    thirdScore := score
                    thirdOffset := candidateOffset

        bool v1 = not na(bestOffset)
        bool v2 = not na(secondOffset)
        bool v3 = not na(thirdOffset)
        int validCount = (v1 ? 1 : 0) + (v2 ? 1 : 0) + (v3 ? 1 : 0)

        float scoreSum = 0.0
        int positiveOutcomes = 0
        float historicalMoveSum = 0.0
        float mfeSum = 0.0
        float maeSum = 0.0
        int hit1Count = 0
        int hit2Count = 0
        float timeToPeakSum = 0.0

        int[] offsets = array.from(bestOffset, secondOffset, thirdOffset)
        float[] scores = array.from(bestScore, secondScore, thirdScore)

        if validCount > 0
            for idx = 0 to 2
                int off = array.get(offsets, idx)
                float sc = array.get(scores, idx)
                if not na(off)
                    scoreSum += sc
                    float entry = close[off]
                    float histAtr = ta.atr(atrLen)[off]
                    float finalMove = (close[off - futureLen] / entry - 1.0) * 100.0
                    positiveOutcomes += finalMove > 0.0 ? 1 : 0
                    historicalMoveSum += finalMove

                    float maxFav = 0.0
                    float maxAdv = 0.0
                    int peakBar = 0

                    for step = 1 to futureLen
                        float highMove = high[off - step] - entry
                        float lowMove = low[off - step] - entry
                        if finalMove >= 0.0
                            if highMove > maxFav
                                maxFav := highMove
                                peakBar := step
                            maxAdv := math.min(maxAdv, lowMove)
                        else
                            if -lowMove > maxFav
                                maxFav := -lowMove
                                peakBar := step
                            maxAdv := math.min(maxAdv, -highMove)

                    float mfeAtr = histAtr > 0.0 ? maxFav / histAtr : 0.0
                    float maeAtr = histAtr > 0.0 ? math.abs(maxAdv) / histAtr : 0.0
                    mfeSum += mfeAtr
                    maeSum += maeAtr
                    hit1Count += mfeAtr >= 1.0 ? 1 : 0
                    hit2Count += mfeAtr >= 2.0 ? 1 : 0
                    timeToPeakSum += peakBar

            averageSimilarity := scoreSum / validCount
            bullishOutcomeRate := positiveOutcomes / validCount * 100.0
            averageHistoricalMove := historicalMoveSum / validCount
            avgMFE := mfeSum / validCount
            avgMAE := maeSum / validCount
            probability1ATR := hit1Count / validCount * 100.0
            probability2ATR := hit2Count / validCount * 100.0
            avgTimeToPeak := timeToPeakSum / validCount

            int bullCount = 0
            int bearCount = 0
            for idx = 0 to 2
                int off = array.get(offsets, idx)
                if not na(off)
                    float endpoint = f_smoothedProjectedPrice(off, futureLen)
                    bullCount += endpoint > close ? 1 : 0
                    bearCount += endpoint < close ? 1 : 0
            agreement := math.max(bullCount, bearCount) / validCount * 100.0
            consensusEnd := f_consensusPrice(futureLen, bestOffset, bestScore, secondOffset, secondScore, thirdOffset, thirdScore)

            // MIRROR QUALITY ENGINE
            // Pattern fit: average similarity
            // Regime quality: average regime compatibility of selected analogs
            // Stability: agreement plus cloud compactness
            // Outcome reliability: balance between MFE potential and MAE risk
            float regimeSum = 0.0
            if v1
                regimeSum += f_regimeScore(bestOffset)
            if v2
                regimeSum += f_regimeScore(secondOffset)
            if v3
                regimeSum += f_regimeScore(thirdOffset)
            regimeQuality := regimeSum / validCount

            float end1 = v1 ? f_smoothedProjectedPrice(bestOffset, futureLen) : consensusEnd
            float end2 = v2 ? f_smoothedProjectedPrice(secondOffset, futureLen) : consensusEnd
            float end3 = v3 ? f_smoothedProjectedPrice(thirdOffset, futureLen) : consensusEnd
            float endpointSpread = math.max(end1, math.max(end2, end3)) - math.min(end1, math.min(end2, end3))
            float spreadAtr = ta.atr(atrLen) > 0.0 ? endpointSpread / ta.atr(atrLen) : 0.0
            float compactness = 100.0 / (1.0 + spreadAtr)
            stabilityScore := agreement * 0.65 + compactness * 0.35

            float rewardRiskQuality = avgMAE > 0.0 ? math.min(100.0, avgMFE / avgMAE * 35.0) : math.min(100.0, avgMFE * 35.0)
            outcomeReliability := rewardRiskQuality * 0.55 + probability1ATR * 0.30 + probability2ATR * 0.15

            mirrorQuality := averageSimilarity * 0.35 + regimeQuality * 0.20 + stabilityScore * 0.25 + outcomeReliability * 0.20
            mirrorGrade :=
                 mirrorQuality >= 90.0 ? "A+" :
                 mirrorQuality >= 82.0 ? "A" :
                 mirrorQuality >= 74.0 ? "B+" :
                 mirrorQuality >= 66.0 ? "B" :
                 mirrorQuality >= 58.0 ? "C+" :
                 mirrorQuality >= 50.0 ? "C" : "D"

            // MIRROR DECISION ENGINE
            float currentAtr = ta.atr(atrLen)
            float rawProjectedMove = consensusEnd - close
            float directionSign = rawProjectedMove >= 0.0 ? 1.0 : -1.0
            projectedMoveATR := currentAtr > 0.0 ? math.abs(rawProjectedMove) / currentAtr : 0.0

            float moveAdequacy = math.min(100.0, projectedMoveATR / math.max(minimumMoveATR, 0.01) * 65.0)
            decisionScore := mirrorQuality * 0.55 + agreement * 0.25 + moveAdequacy * 0.20

            bool qualityPass = mirrorQuality >= minimumQuality
            bool agreementPass = agreement >= minimumAgreement
            bool movePass = projectedMoveATR >= minimumMoveATR

            decisionState :=
                 qualityPass and agreementPass and movePass ? "ACTIONABLE" :
                 mirrorQuality >= minimumQuality * 0.82 and agreement >= 50.0 ? "WATCH" :
                 "AVOID"

            // CLUSTER & ADAPTIVE INTELLIGENCE
            regimeConsensus := regimeQuality
            float densityScore = math.min(100.0, analogDensity / math.max(densityTarget, 1) * 100.0)
            historicalReliability := mirrorQuality * 0.45 + outcomeReliability * 0.30 + stabilityScore * 0.25

            if enableAdaptive
                float reputationBlend = analogReputation * reputationWeight
                float baseBlend = decisionScore * (1.0 - reputationWeight)
                decisionScore := baseBlend + reputationBlend

            if enableFusion
                float fusionDirectionalScore =
                     fusionBias == 0 ? 40.0 :
                     fusionBias == (consensusEnd >= close ? 1 : -1) ? fusionAgreement :
                     100.0 - fusionAgreement
                decisionScore := decisionScore * (1.0 - fusionImpact) + fusionDirectionalScore * fusionImpact

            forecastHealth :=
                 mirrorQuality * 0.30 +
                 agreement * 0.20 +
                 stabilityScore * 0.20 +
                 outcomeReliability * 0.15 +
                 densityScore * 0.15

            bool fusionPass =
                 not enableFusion or
                 not requireFusionForActionable or
                 (fusionAgreement >= minimumFusionAgreement and
                  fusionBias == (consensusEnd >= close ? 1 : -1))

            decisionState :=
                 qualityPass and agreementPass and movePass and forecastHealth >= 60.0 and fusionPass ? "ACTIONABLE" :
                 forecastHealth >= 48.0 ? "WATCH" :
                 "AVOID"

            checkpoint1Price := f_consensusPrice(
                 math.max(1, int(math.round(futureLen * 0.33))),
                 bestOffset, bestScore, secondOffset, secondScore, thirdOffset, thirdScore)

            checkpoint2Price := f_consensusPrice(
                 math.max(1, int(math.round(futureLen * 0.66))),
                 bestOffset, bestScore, secondOffset, secondScore, thirdOffset, thirdScore)

            float historicalRiskATR = math.max(avgMAE, 0.35) * riskBuffer
            invalidationPrice := close - directionSign * currentAtr * historicalRiskATR

            // FIXED SNAPSHOT CAPTURE
            bool snapshotExpired =
                 snapshotRefreshBars > 0 and
                 snapshotActive and
                 not na(snapshotBarIndex) and
                 bar_index - snapshotBarIndex >= snapshotRefreshBars

            bool newActionableRefresh =
                 refreshOnNewActionable and
                 snapshotActive and
                 decisionState == "ACTIONABLE" and
                 snapshotDecisionState != "ACTIONABLE"

            bool shouldCaptureSnapshot =
                 projectionMode != "Live Projection" and
                 validCount > 0 and
                 (not snapshotActive or snapshotExpired or newActionableRefresh)

            if shouldCaptureSnapshot
                snapshotActive := true
                snapshotBarIndex := bar_index
                snapshotLength := futureLen
                snapshotDirection := consensusEnd >= close ? 1 : -1
                snapshotEntry := close
                snapshotInvalidation := invalidationPrice
                snapshotDecisionScore := decisionScore
                snapshotQuality := mirrorQuality
                snapshotGrade := mirrorGrade
                snapshotDecisionState := decisionState

                array.clear(snapshotConsensus)
                array.clear(snapshotUpper)
                array.clear(snapshotLower)
                array.clear(snapshotMirror1)
                array.clear(snapshotMirror2)
                array.clear(snapshotMirror3)

                array.push(snapshotConsensus, close)
                array.push(snapshotUpper, close)
                array.push(snapshotLower, close)
                array.push(snapshotMirror1, close)
                array.push(snapshotMirror2, close)
                array.push(snapshotMirror3, close)

                for snapStep = 1 to futureLen
                    float sp1 = v1 ? f_smoothedProjectedPrice(bestOffset, snapStep) : close
                    float sp2 = v2 ? f_smoothedProjectedPrice(secondOffset, snapStep) : sp1
                    float sp3 = v3 ? f_smoothedProjectedPrice(thirdOffset, snapStep) : sp1
                    float sc = f_consensusPrice(
                         snapStep,
                         bestOffset, bestScore,
                         secondOffset, secondScore,
                         thirdOffset, thirdScore)

                    array.push(snapshotConsensus, sc)
                    array.push(snapshotUpper, math.max(sp1, math.max(sp2, sp3)))
                    array.push(snapshotLower, math.min(sp1, math.min(sp2, sp3)))
                    array.push(snapshotMirror1, sp1)
                    array.push(snapshotMirror2, sp2)
                    array.push(snapshotMirror3, sp3)

            // LOCK / UPDATE MIRROR LIFECYCLE
            bool canLock =
                 enableLifecycle and
                 autoLockActionable and
                 not mirrorLocked and
                 decisionState == "ACTIONABLE" and
                 decisionScore >= minimumLockScore

            if canLock
                mirrorLocked := true
                lockBarIndex := bar_index
                lockLength := futureLen
                lockDirection := consensusEnd >= close ? 1 : -1
                lockEntryPrice := close
                lockAtr := currentAtr
                lockInvalidation := invalidationPrice
                lockDecisionScore := decisionScore
                lockQuality := mirrorQuality
                lockGrade := mirrorGrade
                trackingState := "LOCKED"
                adherenceScore := 100.0
                trackingErrorATR := 0.0
                completedSteps := 0
                resultBarIndex := na
                resultRecorded := false
                array.clear(lockedPrices)

                // Store the complete projected path, including the anchor.
                array.push(lockedPrices, close)
                for lockStep = 1 to futureLen
                    float lockPrice = f_consensusPrice(
                         lockStep,
                         bestOffset, bestScore,
                         secondOffset, secondScore,
                         thirdOffset, thirdScore)
                    array.push(lockedPrices, lockPrice)

            if mirrorLocked
                int elapsed = bar_index - lockBarIndex
                completedSteps := math.max(0, math.min(elapsed, lockLength))

                if elapsed > 0 and elapsed <= lockLength and array.size(lockedPrices) > elapsed
                    float expectedNow = array.get(lockedPrices, elapsed)
                    float absoluteError = math.abs(close - expectedNow)
                    trackingErrorATR := lockAtr > 0.0 ? absoluteError / lockAtr : 0.0
                    adherenceScore := math.max(0.0, 100.0 - trackingErrorATR / adherenceToleranceATR * 50.0)

                    bool invalidated =
                         lockDirection > 0 ? low <= lockInvalidation :
                         high >= lockInvalidation

                    if invalidated
                        trackingState := "INVALIDATED"
                        resultBarIndex := bar_index
                    else if trackingErrorATR >= driftToleranceATR
                        trackingState := "DRIFTING"
                    else if trackingErrorATR <= adherenceToleranceATR
                        trackingState := "ON TRACK"
                    else
                        trackingState := "DEVIATING"

                if elapsed >= lockLength and trackingState != "INVALIDATED"
                    float lockedTarget = array.size(lockedPrices) > lockLength ? array.get(lockedPrices, lockLength) : lockEntryPrice
                    bool directionCorrect =
                         lockDirection > 0 ? close > lockEntryPrice :
                         close < lockEntryPrice
                    bool targetRegionReached =
                         lockDirection > 0 ? high >= lockedTarget :
                         low <= lockedTarget

                    trackingState := targetRegionReached ? "TARGET REACHED" : directionCorrect ? "DIRECTION RIGHT" : "MISSED"
                    resultBarIndex := na(resultBarIndex) ? bar_index : resultBarIndex

                if not na(resultBarIndex) and not resultRecorded
                    float resultScore =
                         trackingState == "TARGET REACHED" ? 100.0 :
                         trackingState == "DIRECTION RIGHT" ? 72.0 :
                         trackingState == "ON TRACK" ? 68.0 :
                         trackingState == "DEVIATING" ? 45.0 :
                         trackingState == "DRIFTING" ? 28.0 :
                         0.0

                    float finalError = na(trackingErrorATR) ? 2.0 : trackingErrorATR
                    array.push(forecastScores, resultScore)
                    array.push(forecastErrors, finalError)

                    if array.size(forecastScores) > maxLibrarySize
                        array.shift(forecastScores)
                    if array.size(forecastErrors) > maxLibrarySize
                        array.shift(forecastErrors)

                    resultRecorded := true

                    int libSizeNow = array.size(forecastScores)
                    if libSizeNow > 0
                        float scoreTotal = 0.0
                        for r = 0 to libSizeNow - 1
                            scoreTotal += array.get(forecastScores, r)
                        analogReputation := scoreTotal / libSizeNow

                        if libSizeNow >= 6
                            int recentCount = math.min(3, libSizeNow)
                            float recentAvg = 0.0
                            float priorAvg = 0.0
                            int priorCount = 0

                            for r = 0 to recentCount - 1
                                recentAvg += array.get(forecastScores, libSizeNow - 1 - r)
                            recentAvg /= recentCount

                            for r = 0 to libSizeNow - recentCount - 1
                                priorAvg += array.get(forecastScores, r)
                                priorCount += 1
                            priorAvg := priorCount > 0 ? priorAvg / priorCount : recentAvg

                            modelDrift :=
                                 recentAvg >= priorAvg + 8.0 ? "IMPROVING" :
                                 recentAvg <= priorAvg - 8.0 ? "DEGRADING" :
                                 "STABLE"

                bool resultExpired =
                     not na(resultBarIndex) and
                     bar_index - resultBarIndex >= resetAfterBars

                if resultExpired
                    mirrorLocked := false
                    lockBarIndex := na
                    lockLength := na
                    lockDirection := 0
                    lockEntryPrice := na
                    lockAtr := na
                    lockInvalidation := na
                    lockDecisionScore := na
                    lockQuality := na
                    lockGrade := "—"
                    trackingState := "IDLE"
                    adherenceScore := na
                    trackingErrorATR := na
                    completedSteps := 0
                    resultBarIndex := na
                    resultRecorded := false
                    array.clear(lockedPrices)

        // Secondary mirrors: intentionally subtle
        if showMirrors and displayMode == "Full" and (projectionMode == "Live Projection" or (projectionMode == "Hybrid" and not snapshotActive))
            if v1
                f_drawMirror(bestOffset, color.new(cyanColor, 70), mirror1Lines)
            if v2
                f_drawMirror(secondOffset, color.new(violetColor, 82), mirror2Lines)
            if v3
                f_drawMirror(thirdOffset, color.new(color.white, 90), mirror3Lines)

        // Continuous-style confidence cloud using supported Pine primitives
        // Boundary lines create a smooth envelope; translucent boxes fill each segment.
        if showTunnel and displayMode != "Dashboard Only" and validCount > 0 and (projectionMode == "Live Projection" or (projectionMode == "Hybrid" and not snapshotActive))
            float previousUpper = close
            float previousLower = close
            float cloudMove = (consensusEnd / close - 1.0) * 100.0
            color cloudColor =
                 math.abs(cloudMove) <= neutralThreshold ? goldColor :
                 cloudMove > 0.0 ? bullColor : bearColor

            for step = 1 to futureLen
                float p1 = v1 ? f_smoothedProjectedPrice(bestOffset, step) : na
                float p2 = v2 ? f_smoothedProjectedPrice(secondOffset, step) : p1
                float p3 = v3 ? f_smoothedProjectedPrice(thirdOffset, step) : p1

                float nextUpper = math.max(p1, math.max(p2, p3))
                float nextLower = math.min(p1, math.min(p2, p3))

                line upperSegment = line.new(
                     x1=bar_index + step - 1,
                     y1=previousUpper,
                     x2=bar_index + step,
                     y2=nextUpper,
                     xloc=xloc.bar_index,
                     extend=extend.none,
                     color=color.new(cloudColor, 55),
                     width=1,
                     style=line.style_solid,
                     force_overlay=true)
                array.push(upperCloudLines, upperSegment)

                line lowerSegment = line.new(
                     x1=bar_index + step - 1,
                     y1=previousLower,
                     x2=bar_index + step,
                     y2=nextLower,
                     xloc=xloc.bar_index,
                     extend=extend.none,
                     color=color.new(cloudColor, 55),
                     width=1,
                     style=line.style_solid,
                     force_overlay=true)
                array.push(lowerCloudLines, lowerSegment)

                float segmentTop = math.max(previousUpper, nextUpper)
                float segmentBottom = math.min(previousLower, nextLower)

                box fillSegment = box.new(
                     left=bar_index + step - 1,
                     top=segmentTop,
                     right=bar_index + step,
                     bottom=segmentBottom,
                     xloc=xloc.bar_index,
                     border_color=color.new(cloudColor, 100),
                     bgcolor=color.new(cloudColor, cloudOpacity),
                     force_overlay=true)
                array.push(cloudFillBoxes, fillSegment)

                previousUpper := nextUpper
                previousLower := nextLower

        // Dominant consensus path
        if showConsensus and displayMode != "Dashboard Only" and validCount > 0 and (projectionMode == "Live Projection" or (projectionMode == "Hybrid" and not snapshotActive))
            float previousConsensus = close
            for step = 1 to futureLen
                float nextConsensus = f_consensusPrice(step, bestOffset, bestScore, secondOffset, secondScore, thirdOffset, thirdScore)
                float segmentMove = nextConsensus - previousConsensus
                color directionalGold =
                     segmentMove > 0.0 ? color.rgb(255, 211, 84) :
                     segmentMove < 0.0 ? color.rgb(255, 176, 72) :
                     goldColor
                line consensusSegment = line.new(
                     x1=bar_index + step - 1,
                     y1=previousConsensus,
                     x2=bar_index + step,
                     y2=nextConsensus,
                     xloc=xloc.bar_index,
                     extend=extend.none,
                     color=directionalGold,
                     width=consensusWidth,
                     style=line.style_solid,
                     force_overlay=true)
                array.push(consensusLines, consensusSegment)
                previousConsensus := nextConsensus

        // FIXED SNAPSHOT RENDERER
        if snapshotActive and projectionMode != "Live Projection" and displayMode != "Dashboard Only" and array.size(snapshotConsensus) > 1
            int snapSize = array.size(snapshotConsensus)
            int snapEnd = math.min(snapshotLength, snapSize - 1)
            color snapCloudColor =
                 snapshotDirection > 0 ? bullColor :
                 snapshotDirection < 0 ? bearColor :
                 goldColor

            if showTunnel
                for step = 1 to snapEnd
                    float prevUpper = array.get(snapshotUpper, step - 1)
                    float nextUpper = array.get(snapshotUpper, step)
                    float prevLower = array.get(snapshotLower, step - 1)
                    float nextLower = array.get(snapshotLower, step)

                    line upperSnap = line.new(
                         x1=snapshotBarIndex + step - 1,
                         y1=prevUpper,
                         x2=snapshotBarIndex + step,
                         y2=nextUpper,
                         xloc=xloc.bar_index,
                         extend=extend.none,
                         color=color.new(snapCloudColor, 58),
                         width=1,
                         style=line.style_solid,
                         force_overlay=true)
                    array.push(snapshotBoundaryLines, upperSnap)

                    line lowerSnap = line.new(
                         x1=snapshotBarIndex + step - 1,
                         y1=prevLower,
                         x2=snapshotBarIndex + step,
                         y2=nextLower,
                         xloc=xloc.bar_index,
                         extend=extend.none,
                         color=color.new(snapCloudColor, 58),
                         width=1,
                         style=line.style_solid,
                         force_overlay=true)
                    array.push(snapshotBoundaryLines, lowerSnap)

                    box snapFill = box.new(
                         left=snapshotBarIndex + step - 1,
                         top=math.max(prevUpper, nextUpper),
                         right=snapshotBarIndex + step,
                         bottom=math.min(prevLower, nextLower),
                         xloc=xloc.bar_index,
                         border_color=color.new(snapCloudColor, 100),
                         bgcolor=color.new(snapCloudColor, cloudOpacity),
                         force_overlay=true)
                    array.push(snapshotCloudBoxes, snapFill)

            if showMirrors and displayMode == "Full"
                for step = 1 to snapEnd
                    float m1Prev = array.get(snapshotMirror1, step - 1)
                    float m1Next = array.get(snapshotMirror1, step)
                    float m2Prev = array.get(snapshotMirror2, step - 1)
                    float m2Next = array.get(snapshotMirror2, step)
                    float m3Prev = array.get(snapshotMirror3, step - 1)
                    float m3Next = array.get(snapshotMirror3, step)

                    line sm1 = line.new(
                         snapshotBarIndex + step - 1, m1Prev,
                         snapshotBarIndex + step, m1Next,
                         xloc=xloc.bar_index,
                         color=color.new(cyanColor, 72),
                         width=1,
                         force_overlay=true)
                    array.push(snapshotMirrorLines, sm1)

                    line sm2 = line.new(
                         snapshotBarIndex + step - 1, m2Prev,
                         snapshotBarIndex + step, m2Next,
                         xloc=xloc.bar_index,
                         color=color.new(violetColor, 84),
                         width=1,
                         force_overlay=true)
                    array.push(snapshotMirrorLines, sm2)

                    line sm3 = line.new(
                         snapshotBarIndex + step - 1, m3Prev,
                         snapshotBarIndex + step, m3Next,
                         xloc=xloc.bar_index,
                         color=color.new(color.white, 91),
                         width=1,
                         force_overlay=true)
                    array.push(snapshotMirrorLines, sm3)

            if showConsensus
                for step = 1 to snapEnd
                    float cPrev = array.get(snapshotConsensus, step - 1)
                    float cNext = array.get(snapshotConsensus, step)
                    line fixedConsensus = line.new(
                         snapshotBarIndex + step - 1, cPrev,
                         snapshotBarIndex + step, cNext,
                         xloc=xloc.bar_index,
                         extend=extend.none,
                         color=goldColor,
                         width=consensusWidth,
                         style=line.style_solid,
                         force_overlay=true)
                    array.push(snapshotConsensusLines, fixedConsensus)

            float snapshotEndPrice = array.get(snapshotConsensus, snapEnd)
            float snapshotMove = snapshotEntry != 0.0 ? (snapshotEndPrice / snapshotEntry - 1.0) * 100.0 : 0.0

            label originBadge = label.new(
                 x=snapshotBarIndex,
                 y=snapshotEntry,
                 text="SNAPSHOT",
                 xloc=xloc.bar_index,
                 yloc=yloc.price,
                 style=label.style_label_right,
                 color=color.new(goldColor, 15),
                 textcolor=panelBg,
                 size=size.tiny,
                 force_overlay=true)
            array.push(snapshotLabels, originBadge)

            label fixedBadge = label.new(
                 x=snapshotBarIndex + snapEnd,
                 y=snapshotEndPrice,
                 text=(snapshotDirection > 0 ? "▲ BULLISH MIRROR" : "▼ BEARISH MIRROR") +
                      "\n" + str.tostring(snapshotMove, "+#.##;-#.##") + "%" +
                      "\n" + snapshotDecisionState +
                      "\nQuality " + snapshotGrade + "  " + str.tostring(snapshotQuality, "#") + "%",
                 xloc=xloc.bar_index,
                 yloc=yloc.price,
                 style=label.style_label_left,
                 color=snapshotDirection > 0 ? bullColor : bearColor,
                 textcolor=panelBg,
                 size=size.small,
                 force_overlay=true)
            array.push(snapshotLabels, fixedBadge)

            if displayMode == "Full"
                line fixedInvalidation = line.new(
                     x1=snapshotBarIndex,
                     y1=snapshotInvalidation,
                     x2=snapshotBarIndex + snapEnd,
                     y2=snapshotInvalidation,
                     xloc=xloc.bar_index,
                     extend=extend.none,
                     color=color.new(bearColor, 20),
                     width=1,
                     style=line.style_dotted,
                     force_overlay=true)
                array.push(snapshotConsensusLines, fixedInvalidation)

        // LOCKED FORECAST & LIVE TRACKING
        if enableLifecycle and
           displayMode == "Full" and
           projectionMode != "Locked Snapshot" and
           mirrorLocked and
           array.size(lockedPrices) > 1
            int elapsed = math.max(0, bar_index - lockBarIndex)
            int visibleEnd = math.min(lockLength, array.size(lockedPrices) - 1)

            if showLockedPath
                for step = 1 to visibleEnd
                    float lockedPrev = array.get(lockedPrices, step - 1)
                    float lockedNext = array.get(lockedPrices, step)
                    bool historicalSegment = step <= elapsed
                    color lockedColor =
                         historicalSegment ? color.new(mutedText, 45) :
                         lockDirection > 0 ? color.new(bullColor, 12) :
                         color.new(bearColor, 12)

                    line lockedSegment = line.new(
                         x1=lockBarIndex + step - 1,
                         y1=lockedPrev,
                         x2=lockBarIndex + step,
                         y2=lockedNext,
                         xloc=xloc.bar_index,
                         extend=extend.none,
                         color=lockedColor,
                         width=historicalSegment ? 1 : 3,
                         style=historicalSegment ? line.style_dotted : line.style_solid,
                         force_overlay=true)
                    array.push(lockedPathLines, lockedSegment)

            if elapsed > 0 and elapsed <= lockLength and array.size(lockedPrices) > elapsed
                float expectedNow = array.get(lockedPrices, elapsed)

                line trackingConnector = line.new(
                     x1=bar_index,
                     y1=expectedNow,
                     x2=bar_index,
                     y2=close,
                     xloc=xloc.bar_index,
                     extend=extend.none,
                     color=trackingState == "ON TRACK" ? bullColor :
                           trackingState == "DRIFTING" or trackingState == "INVALIDATED" ? bearColor :
                           goldColor,
                     width=2,
                     style=line.style_dashed,
                     force_overlay=true)
                array.push(trackingLines, trackingConnector)

                if showTrackingBadge
                    color trackingColor =
                         trackingState == "ON TRACK" or trackingState == "TARGET REACHED" ? bullColor :
                         trackingState == "DRIFTING" or trackingState == "INVALIDATED" or trackingState == "MISSED" ? bearColor :
                         goldColor

                    label trackingBadge = label.new(
                         x=bar_index,
                         y=close,
                         text=trackingState +
                              "\nAdherence " + (not na(adherenceScore) ? str.tostring(adherenceScore, "#") + "%" : "—") +
                              "\nStep " + str.tostring(completedSteps) + "/" + str.tostring(lockLength),
                         xloc=xloc.bar_index,
                         yloc=yloc.price,
                         style=label.style_label_left,
                         color=color.new(trackingColor, 10),
                         textcolor=panelBg,
                         size=size.tiny,
                         force_overlay=true)
                    array.push(trackingLabels, trackingBadge)

        // ADAPTIVE DECISION MAP
        if showDecisionMap and displayMode == "Full" and validCount > 0 and (projectionMode == "Live Projection" or (projectionMode == "Hybrid" and not snapshotActive))
            int checkpoint1Bar = bar_index + math.max(1, int(math.round(futureLen * 0.33)))
            int checkpoint2Bar = bar_index + math.max(1, int(math.round(futureLen * 0.66)))
            int endpointBar = bar_index + futureLen

            color decisionColor =
                 decisionState == "ACTIONABLE" ? bullColor :
                 decisionState == "WATCH" ? goldColor :
                 bearColor

            if showCheckpoint1
                line cp1Line = line.new(
                     x1=bar_index,
                     y1=checkpoint1Price,
                     x2=checkpoint1Bar,
                     y2=checkpoint1Price,
                     xloc=xloc.bar_index,
                     extend=extend.none,
                     color=color.new(decisionColor, 48),
                     width=1,
                     style=line.style_dashed,
                     force_overlay=true)
                array.push(decisionLines, cp1Line)

                label cp1Label = label.new(
                     x=checkpoint1Bar,
                     y=checkpoint1Price,
                     text="EARLY\n" + str.tostring(checkpoint1Price, format.mintick),
                     xloc=xloc.bar_index,
                     yloc=yloc.price,
                     style=label.style_label_left,
                     color=color.new(decisionColor, 22),
                     textcolor=panelBg,
                     size=size.tiny,
                     force_overlay=true)
                array.push(decisionLabels, cp1Label)

            if showCheckpoint2
                line cp2Line = line.new(
                     x1=bar_index,
                     y1=checkpoint2Price,
                     x2=checkpoint2Bar,
                     y2=checkpoint2Price,
                     xloc=xloc.bar_index,
                     extend=extend.none,
                     color=color.new(decisionColor, 34),
                     width=1,
                     style=line.style_dashed,
                     force_overlay=true)
                array.push(decisionLines, cp2Line)

                label cp2Label = label.new(
                     x=checkpoint2Bar,
                     y=checkpoint2Price,
                     text="CONFIRM\n" + str.tostring(checkpoint2Price, format.mintick),
                     xloc=xloc.bar_index,
                     yloc=yloc.price,
                     style=label.style_label_left,
                     color=color.new(decisionColor, 12),
                     textcolor=panelBg,
                     size=size.tiny,
                     force_overlay=true)
                array.push(decisionLabels, cp2Label)

            line invalidationLine = line.new(
                 x1=bar_index,
                 y1=invalidationPrice,
                 x2=endpointBar,
                 y2=invalidationPrice,
                 xloc=xloc.bar_index,
                 extend=extend.none,
                 color=color.new(bearColor, 12),
                 width=1,
                 style=line.style_dotted,
                 force_overlay=true)
            array.push(decisionLines, invalidationLine)

            label invalidationLabel = label.new(
                 x=endpointBar,
                 y=invalidationPrice,
                 text="MIRROR INVALIDATION\n" + str.tostring(invalidationPrice, format.mintick),
                 xloc=xloc.bar_index,
                 yloc=yloc.price,
                 style=label.style_label_left,
                 color=color.new(bearColor, 18),
                 textcolor=panelBg,
                 size=size.tiny,
                 force_overlay=true)
            array.push(decisionLabels, invalidationLabel)

        if showAnchor and displayMode == "Full" and validCount > 0 and (projectionMode == "Live Projection" or (projectionMode == "Hybrid" and not snapshotActive))
            float anchorRange = ta.atr(atrLen) * 0.45
            line anchorLine = line.new(
                 x1=bar_index,
                 y1=close - anchorRange,
                 x2=bar_index,
                 y2=close + anchorRange,
                 xloc=xloc.bar_index,
                 extend=extend.none,
                 color=goldColor,
                 width=2,
                 style=line.style_dotted,
                 force_overlay=true)
            array.push(anchorLines, anchorLine)

        if validCount > 0 and (projectionMode == "Live Projection" or (projectionMode == "Hybrid" and not snapshotActive))
            float consensusMove = (consensusEnd / close - 1.0) * 100.0
            label consensusLabel = label.new(
                 x=bar_index + futureLen,
                 y=consensusEnd,
                 text=(consensusEnd >= close ? "▲ BULLISH" : "▼ BEARISH") +
                      "\n" + str.tostring(consensusMove, "+#.##;-#.##") + "%" +
                      "\n" + decisionState + "  " + str.tostring(decisionScore, "#") + "%" +
                      "\nQuality " + mirrorGrade + "  " + str.tostring(mirrorQuality, "#") + "%",
                 xloc=xloc.bar_index,
                 yloc=yloc.price,
                 style=label.style_label_left,
                 color=consensusEnd >= close ? bullColor : bearColor,
                 textcolor=panelBg,
                 size=size.small,
                 force_overlay=true)
            array.push(endpointLabels, consensusLabel)

        if showMatchMarker and showHistoricalMarkers and displayMode == "Full"
            if v1
                label l1 = label.new(bar_index - bestOffset, close[bestOffset], "M1", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_down, color=color.new(goldColor, 15), textcolor=panelBg, size=size.tiny, force_overlay=true)
                array.push(historyLabels, l1)
            if v2
                label l2 = label.new(bar_index - secondOffset, close[secondOffset], "M2", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_down, color=color.new(cyanColor, 20), textcolor=panelBg, size=size.tiny, force_overlay=true)
                array.push(historyLabels, l2)
            if v3
                label l3 = label.new(bar_index - thirdOffset, close[thirdOffset], "M3", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_down, color=color.new(violetColor, 20), textcolor=panelBg, size=size.tiny, force_overlay=true)
                array.push(historyLabels, l3)

// ALERT EVENT DETECTION
if barstate.islast
    actionableEvent := decisionState == "ACTIONABLE" and previousDecisionState != "ACTIONABLE"
    snapshotEvent := snapshotActive and not previousSnapshotActive
    onTrackEvent := trackingState == "ON TRACK" and previousTrackingState != "ON TRACK"
    driftEvent := trackingState == "DRIFTING" and previousTrackingState != "DRIFTING"
    invalidationEvent := trackingState == "INVALIDATED" and previousTrackingState != "INVALIDATED"
    targetEvent := trackingState == "TARGET REACHED" and previousTrackingState != "TARGET REACHED"

    previousDecisionState := decisionState
    previousTrackingState := trackingState
    previousSnapshotActive := snapshotActive

// ALERT CONDITIONS
alertcondition(
     enableAlerts and alertOnActionable and actionableEvent,
     "Razor Fractal Mirror — Actionable",
     "Razor Fractal Mirror: ACTIONABLE setup on {{ticker}} {{interval}}.")

alertcondition(
     enableAlerts and alertOnSnapshot and snapshotEvent,
     "Razor Fractal Mirror — New Snapshot",
     "Razor Fractal Mirror: New persistent projection snapshot on {{ticker}} {{interval}}.")

alertcondition(
     enableAlerts and alertOnTrack and onTrackEvent,
     "Razor Fractal Mirror — On Track",
     "Razor Fractal Mirror: Forecast is ON TRACK on {{ticker}} {{interval}}.")

alertcondition(
     enableAlerts and alertOnDrift and driftEvent,
     "Razor Fractal Mirror — Drifting",
     "Razor Fractal Mirror: Forecast is DRIFTING on {{ticker}} {{interval}}.")

alertcondition(
     enableAlerts and alertOnInvalidation and invalidationEvent,
     "Razor Fractal Mirror — Invalidated",
     "Razor Fractal Mirror: Projection INVALIDATED on {{ticker}} {{interval}}.")

alertcondition(
     enableAlerts and alertOnTarget and targetEvent,
     "Razor Fractal Mirror — Target Reached",
     "Razor Fractal Mirror: Forecast target reached on {{ticker}} {{interval}}.")

// Dynamic alert messages
bool alertFrequencyPass = not alertOncePerBarClose or barstate.isconfirmed
if enableAlerts and alertFrequencyPass
    if alertOnActionable and actionableEvent
        alert("Razor Fractal Mirror | ACTIONABLE | " + syminfo.ticker + " | Quality " + str.tostring(mirrorQuality, "#") + "% | Decision " + str.tostring(decisionScore, "#") + "%", alert.freq_once_per_bar)
    if alertOnSnapshot and snapshotEvent
        alert("Razor Fractal Mirror | NEW SNAPSHOT | " + syminfo.ticker + " | " + (snapshotDirection > 0 ? "BULLISH" : "BEARISH") + " | Quality " + snapshotGrade, alert.freq_once_per_bar)
    if alertOnDrift and driftEvent
        alert("Razor Fractal Mirror | DRIFTING | " + syminfo.ticker + " | Error " + str.tostring(trackingErrorATR, "#.##") + " ATR", alert.freq_once_per_bar)
    if alertOnInvalidation and invalidationEvent
        alert("Razor Fractal Mirror | INVALIDATED | " + syminfo.ticker, alert.freq_once_per_bar)
    if alertOnTarget and targetEvent
        alert("Razor Fractal Mirror | TARGET REACHED | " + syminfo.ticker, alert.freq_once_per_bar)

// DASHBOARD
var table dashboard = table.new(f_position(dashboardPos), 2, 46, frame_color=frameColor, frame_width=1, border_width=0)

if barstate.islast and showDashboard and displayMode != "Projection Only"
    string stateText = na(consensusEnd) ? "SEARCHING" : f_directionText(consensusEnd)
    color stateColor = na(consensusEnd) ? mutedText : f_directionColor(consensusEnd)
    float projectedMove = not na(consensusEnd) ? (consensusEnd / close - 1.0) * 100.0 : na

    string agreementText = na(agreement) ? "—" : agreement >= 100.0 ? "FULL" : agreement >= 66.0 ? "STRONG" : "SPLIT"
    color agreementColor = na(agreement) ? mutedText : agreement >= 100.0 ? bullColor : agreement >= 66.0 ? goldColor : bearColor

    string regimeText =
         not useRegimeFilter ? "OFF" :
         f_regimeTrend(0) > 0.75 ? "BULL TREND" :
         f_regimeTrend(0) < -0.75 ? "BEAR TREND" :
         "BALANCED"

    table.cell(dashboard, 0, 0, showBranding ? "RAZOR" : "MIRROR", text_color=goldColor, bgcolor=panelBg, text_size=size.small)
    table.cell(dashboard, 1, 0, "FRACTAL MIRROR", text_color=color.white, bgcolor=panelBg, text_size=size.small)

    table.cell(dashboard, 0, 1, "MIRROR BIAS", text_color=mutedText, bgcolor=panelBg2, text_size=size.tiny)
    table.cell(dashboard, 1, 1, stateText, text_color=stateColor, bgcolor=panelBg2, text_size=size.tiny)

    table.cell(dashboard, 0, 2, "PROJECTED MOVE", text_color=mutedText, bgcolor=panelBg, text_size=size.tiny)
    table.cell(dashboard, 1, 2, not na(projectedMove) ? str.tostring(projectedMove, "+#.##;-#.##") + "%" : "—", text_color=stateColor, bgcolor=panelBg, text_size=size.tiny)

    table.cell(dashboard, 0, 3, "MIRROR AGREEMENT", text_color=mutedText, bgcolor=panelBg2, text_size=size.tiny)
    table.cell(dashboard, 1, 3, agreementText, text_color=agreementColor, bgcolor=panelBg2, text_size=size.tiny)

    table.cell(dashboard, 0, 4, "AVG SIMILARITY", text_color=mutedText, bgcolor=panelBg, text_size=size.tiny)
    table.cell(dashboard, 1, 4, not na(averageSimilarity) ? str.tostring(averageSimilarity, "#.0") + "%" : "—", text_color=goldColor, bgcolor=panelBg, text_size=size.tiny)

    table.cell(dashboard, 0, 5, "BULL OUTCOME RATE", text_color=mutedText, bgcolor=panelBg2, text_size=size.tiny)
    table.cell(dashboard, 1, 5, not na(bullishOutcomeRate) ? str.tostring(bullishOutcomeRate, "#") + "%" : "—", text_color=not na(bullishOutcomeRate) and bullishOutcomeRate >= 50.0 ? bullColor : bearColor, bgcolor=panelBg2, text_size=size.tiny)

    table.cell(dashboard, 0, 6, "AVG OUTCOME", text_color=mutedText, bgcolor=panelBg, text_size=size.tiny)
    table.cell(dashboard, 1, 6, not na(averageHistoricalMove) ? str.tostring(averageHistoricalMove, "+#.##;-#.##") + "%" : "—", text_color=not na(averageHistoricalMove) and averageHistoricalMove >= 0.0 ? bullColor : bearColor, bgcolor=panelBg, text_size=size.tiny)

    table.cell(dashboard, 0, 7, showTechnicalRows ? "AVG MFE" : "", text_color=mutedText, bgcolor=panelBg2, text_size=size.tiny)
    table.cell(dashboard, 1, 7, not na(avgMFE) ? str.tostring(avgMFE, "#.##") + " ATR" : "—", text_color=bullColor, bgcolor=panelBg2, text_size=size.tiny)

    table.cell(dashboard, 0, 8, showTechnicalRows ? "AVG MAE" : "", text_color=mutedText, bgcolor=panelBg, text_size=size.tiny)
    table.cell(dashboard, 1, 8, not na(avgMAE) ? str.tostring(avgMAE, "#.##") + " ATR" : "—", text_color=bearColor, bgcolor=panelBg, text_size=size.tiny)

    table.cell(dashboard, 0, 9, showTechnicalRows ? "REACH 1 ATR" : "", text_color=mutedText, bgcolor=panelBg2, text_size=size.tiny)
    table.cell(dashboard, 1, 9, not na(probability1ATR) ? str.tostring(probability1ATR, "#") + "%" : "—", text_color=goldColor, bgcolor=panelBg2, text_size=size.tiny)

    table.cell(dashboard, 0, 10, showTechnicalRows ? "REACH 2 ATR" : "", text_color=mutedText, bgcolor=panelBg, text_size=size.tiny)
    table.cell(dashboard, 1, 10, not na(probability2ATR) ? str.tostring(probability2ATR, "#") + "%" : "—", text_color=goldColor, bgcolor=panelBg, text_size=size.tiny)

    table.cell(dashboard, 0, 11, showTechnicalRows ? "TIME TO PEAK" : "", text_color=mutedText, bgcolor=panelBg2, text_size=size.tiny)
    table.cell(dashboard, 1, 11, not na(avgTimeToPeak) ? str.tostring(avgTimeToPeak, "#.0") + " bars" : "—", text_color=cyanColor, bgcolor=panelBg2, text_size=size.tiny)

    table.cell(dashboard, 0, 12, showTechnicalRows ? "BEST HIST MATCH" : "", text_color=mutedText, bgcolor=panelBg, text_size=size.tiny)
    table.cell(dashboard, 1, 12, not na(bestScore) ? str.tostring(bestScore, "#.0") + "%" : "—", text_color=goldColor, bgcolor=panelBg, text_size=size.tiny)

    table.cell(dashboard, 0, 13, showTechnicalRows ? "MARKET REGIME" : "", text_color=mutedText, bgcolor=panelBg2, text_size=size.tiny)
    table.cell(dashboard, 1, 13, regimeText, text_color=cyanColor, bgcolor=panelBg2, text_size=size.tiny)

    color qualityColor =
         na(mirrorQuality) ? mutedText :
         mirrorQuality >= 82.0 ? bullColor :
         mirrorQuality >= 66.0 ? goldColor :
         mirrorQuality >= 50.0 ? color.rgb(251, 146, 60) :
         bearColor

    table.cell(dashboard, 0, 14, showTechnicalRows ? "MIRROR QUALITY" : "", text_color=mutedText, bgcolor=panelBg, text_size=size.tiny)
    table.cell(dashboard, 1, 14, mirrorGrade + "  " + (not na(mirrorQuality) ? str.tostring(mirrorQuality, "#") + "%" : "—"), text_color=qualityColor, bgcolor=panelBg, text_size=size.small)

    table.cell(dashboard, 0, 15, showTechnicalRows ? "REGIME MATCH" : "", text_color=mutedText, bgcolor=panelBg2, text_size=size.tiny)
    table.cell(dashboard, 1, 15, not na(regimeQuality) ? str.tostring(regimeQuality, "#") + "%" : "—", text_color=cyanColor, bgcolor=panelBg2, text_size=size.tiny)

    table.cell(dashboard, 0, 16, showTechnicalRows ? "PATH STABILITY" : "", text_color=mutedText, bgcolor=panelBg, text_size=size.tiny)
    table.cell(dashboard, 1, 16, not na(stabilityScore) ? str.tostring(stabilityScore, "#") + "%" : "—", text_color=goldColor, bgcolor=panelBg, text_size=size.tiny)

    table.cell(dashboard, 0, 17, showTechnicalRows ? "OUTCOME RELIABILITY" : "", text_color=mutedText, bgcolor=panelBg2, text_size=size.tiny)
    table.cell(dashboard, 1, 17, not na(outcomeReliability) ? str.tostring(outcomeReliability, "#") + "%" : "—", text_color=qualityColor, bgcolor=panelBg2, text_size=size.tiny)

    color decisionColor =
         decisionState == "ACTIONABLE" ? bullColor :
         decisionState == "WATCH" ? goldColor :
         decisionState == "AVOID" ? bearColor :
         mutedText

    table.cell(dashboard, 0, 18, "DECISION STATE", text_color=mutedText, bgcolor=panelBg, text_size=size.tiny)
    table.cell(dashboard, 1, 18, decisionState, text_color=decisionColor, bgcolor=panelBg, text_size=size.small)

    table.cell(dashboard, 0, 19, "DECISION SCORE", text_color=mutedText, bgcolor=panelBg2, text_size=size.tiny)
    table.cell(dashboard, 1, 19, not na(decisionScore) ? str.tostring(decisionScore, "#") + "%" : "—", text_color=decisionColor, bgcolor=panelBg2, text_size=size.tiny)

    table.cell(dashboard, 0, 20, "MOVE POTENTIAL", text_color=mutedText, bgcolor=panelBg, text_size=size.tiny)
    table.cell(dashboard, 1, 20, not na(projectedMoveATR) ? str.tostring(projectedMoveATR, "#.##") + " ATR" : "—", text_color=stateColor, bgcolor=panelBg, text_size=size.tiny)

    table.cell(dashboard, 0, 21, "EARLY CHECKPOINT", text_color=mutedText, bgcolor=panelBg2, text_size=size.tiny)
    table.cell(dashboard, 1, 21, not na(checkpoint1Price) ? str.tostring(checkpoint1Price, format.mintick) : "—", text_color=goldColor, bgcolor=panelBg2, text_size=size.tiny)

    table.cell(dashboard, 0, 22, "INVALIDATION", text_color=mutedText, bgcolor=panelBg, text_size=size.tiny)
    table.cell(dashboard, 1, 22, not na(invalidationPrice) ? str.tostring(invalidationPrice, format.mintick) : "—", text_color=bearColor, bgcolor=panelBg, text_size=size.tiny)

    color trackingColor =
         trackingState == "ON TRACK" or trackingState == "TARGET REACHED" ? bullColor :
         trackingState == "DRIFTING" or trackingState == "INVALIDATED" or trackingState == "MISSED" ? bearColor :
         trackingState == "IDLE" ? mutedText :
         goldColor

    table.cell(dashboard, 0, 23, showAdvancedRows ? "LOCKED MIRROR" : "", text_color=mutedText, bgcolor=panelBg2, text_size=size.tiny)
    table.cell(dashboard, 1, 23, mirrorLocked ? "ACTIVE" : "IDLE", text_color=mirrorLocked ? bullColor : mutedText, bgcolor=panelBg2, text_size=size.tiny)

    table.cell(dashboard, 0, 24, showAdvancedRows ? "TRACKING STATE" : "", text_color=mutedText, bgcolor=panelBg, text_size=size.tiny)
    table.cell(dashboard, 1, 24, trackingState, text_color=trackingColor, bgcolor=panelBg, text_size=size.tiny)

    table.cell(dashboard, 0, 25, showAdvancedRows ? "PATH ADHERENCE" : "", text_color=mutedText, bgcolor=panelBg2, text_size=size.tiny)
    table.cell(dashboard, 1, 25, not na(adherenceScore) ? str.tostring(adherenceScore, "#") + "%" : "—", text_color=trackingColor, bgcolor=panelBg2, text_size=size.tiny)

    table.cell(dashboard, 0, 26, showAdvancedRows ? "TRACKING ERROR" : "", text_color=mutedText, bgcolor=panelBg, text_size=size.tiny)
    table.cell(dashboard, 1, 26, not na(trackingErrorATR) ? str.tostring(trackingErrorATR, "#.##") + " ATR" : "—", text_color=trackingColor, bgcolor=panelBg, text_size=size.tiny)

    table.cell(dashboard, 0, 27, showAdvancedRows ? "FORECAST PROGRESS" : "", text_color=mutedText, bgcolor=panelBg2, text_size=size.tiny)
    table.cell(dashboard, 1, 27, mirrorLocked ? str.tostring(completedSteps) + "/" + str.tostring(lockLength) : "—", text_color=goldColor, bgcolor=panelBg2, text_size=size.tiny)

    color healthColor =
         na(forecastHealth) ? mutedText :
         forecastHealth >= 75.0 ? bullColor :
         forecastHealth >= 55.0 ? goldColor :
         bearColor

    color driftColor =
         modelDrift == "IMPROVING" ? bullColor :
         modelDrift == "DEGRADING" ? bearColor :
         goldColor

    table.cell(dashboard, 0, 28, showAdvancedRows ? "FORECAST HEALTH" : "", text_color=mutedText, bgcolor=panelBg, text_size=size.tiny)
    table.cell(dashboard, 1, 28, not na(forecastHealth) ? str.tostring(forecastHealth, "#") + "%" : "—", text_color=healthColor, bgcolor=panelBg, text_size=size.small)

    table.cell(dashboard, 0, 29, showAdvancedRows ? "ANALOG DENSITY" : "", text_color=mutedText, bgcolor=panelBg2, text_size=size.tiny)
    table.cell(dashboard, 1, 29, str.tostring(analogDensity), text_color=cyanColor, bgcolor=panelBg2, text_size=size.tiny)

    table.cell(dashboard, 0, 30, showAdvancedRows ? "REGIME CONSENSUS" : "", text_color=mutedText, bgcolor=panelBg, text_size=size.tiny)
    table.cell(dashboard, 1, 30, not na(regimeConsensus) ? str.tostring(regimeConsensus, "#") + "%" : "—", text_color=cyanColor, bgcolor=panelBg, text_size=size.tiny)

    table.cell(dashboard, 0, 31, showAdvancedRows ? "ANALOG REPUTATION" : "", text_color=mutedText, bgcolor=panelBg2, text_size=size.tiny)
    table.cell(dashboard, 1, 31, str.tostring(analogReputation, "#") + "%", text_color=goldColor, bgcolor=panelBg2, text_size=size.tiny)

    table.cell(dashboard, 0, 32, showAdvancedRows ? "MODEL DRIFT" : "", text_color=mutedText, bgcolor=panelBg, text_size=size.tiny)
    table.cell(dashboard, 1, 32, modelDrift, text_color=driftColor, bgcolor=panelBg, text_size=size.tiny)

    table.cell(dashboard, 0, 33, showAdvancedRows ? "LIBRARY SIZE" : "", text_color=mutedText, bgcolor=panelBg2, text_size=size.tiny)
    table.cell(dashboard, 1, 33, str.tostring(array.size(forecastScores)) + "/" + str.tostring(maxLibrarySize), text_color=color.white, bgcolor=panelBg2, text_size=size.tiny)

    color fusionBiasColor = f_biasColor(fusionBias)
    color fusionAgreementColor =
         fusionAgreement >= minimumFusionAgreement ? bullColor :
         fusionAgreement >= 50.0 ? goldColor :
         bearColor

    table.cell(dashboard, 0, 34, showAdvancedRows ? "MTF FUSION BIAS" : "", text_color=mutedText, bgcolor=panelBg, text_size=size.tiny)
    table.cell(dashboard, 1, 34, enableFusion ? f_biasText(fusionBias) : "OFF", text_color=enableFusion ? fusionBiasColor : mutedText, bgcolor=panelBg, text_size=size.small)

    table.cell(dashboard, 0, 35, showAdvancedRows ? "MTF AGREEMENT" : "", text_color=mutedText, bgcolor=panelBg2, text_size=size.tiny)
    table.cell(dashboard, 1, 35, enableFusion ? str.tostring(fusionAgreement, "#") + "%" : "—", text_color=fusionAgreementColor, bgcolor=panelBg2, text_size=size.tiny)

    table.cell(dashboard, 0, 36, fusionTf1, text_color=mutedText, bgcolor=panelBg, text_size=size.tiny)
    table.cell(dashboard, 1, 36, f_biasText(tfBias1) + "  " + str.tostring(tfConfidence1, "#") + "%", text_color=f_biasColor(tfBias1), bgcolor=panelBg, text_size=size.tiny)

    table.cell(dashboard, 0, 37, fusionTf2, text_color=mutedText, bgcolor=panelBg2, text_size=size.tiny)
    table.cell(dashboard, 1, 37, f_biasText(tfBias2) + "  " + str.tostring(tfConfidence2, "#") + "%", text_color=f_biasColor(tfBias2), bgcolor=panelBg2, text_size=size.tiny)

    table.cell(dashboard, 0, 38, fusionTf3, text_color=mutedText, bgcolor=panelBg, text_size=size.tiny)
    table.cell(dashboard, 1, 38, f_biasText(tfBias3) + "  " + str.tostring(tfConfidence3, "#") + "%", text_color=f_biasColor(tfBias3), bgcolor=panelBg, text_size=size.tiny)

    table.cell(dashboard, 0, 39, fusionTf4, text_color=mutedText, bgcolor=panelBg2, text_size=size.tiny)
    table.cell(dashboard, 1, 39, f_biasText(tfBias4) + "  " + str.tostring(tfConfidence4, "#") + "%", text_color=f_biasColor(tfBias4), bgcolor=panelBg2, text_size=size.tiny)

    table.cell(dashboard, 0, 40, showAdvancedRows ? "DOMINANT TF" : "", text_color=mutedText, bgcolor=panelBg, text_size=size.tiny)
    table.cell(dashboard, 1, 40, enableFusion ? dominantTf + (fusionConflict ? "  CONFLICT" : "") : "—", text_color=fusionConflict ? bearColor : cyanColor, bgcolor=panelBg, text_size=size.tiny)

    table.cell(dashboard, 0, 41, showAdvancedRows ? "PROJECTION MODE" : "", text_color=mutedText, bgcolor=panelBg2, text_size=size.tiny)
    table.cell(dashboard, 1, 41, projectionMode, text_color=goldColor, bgcolor=panelBg2, text_size=size.tiny)

    table.cell(dashboard, 0, 42, showAdvancedRows ? "SNAPSHOT STATUS" : "", text_color=mutedText, bgcolor=panelBg, text_size=size.tiny)
    table.cell(dashboard, 1, 42, snapshotActive ? "PERSISTENT LOCK" : "CAPTURING", text_color=snapshotActive ? bullColor : mutedText, bgcolor=panelBg, text_size=size.tiny)

    table.cell(dashboard, 0, 43, showAdvancedRows ? "SNAPSHOT AGE" : "", text_color=mutedText, bgcolor=panelBg2, text_size=size.tiny)
    table.cell(dashboard, 1, 43, snapshotActive ? str.tostring(bar_index - snapshotBarIndex) + " bars" : "—", text_color=cyanColor, bgcolor=panelBg2, text_size=size.tiny)

    table.cell(dashboard, 0, 44, "DISPLAY MODE", text_color=mutedText, bgcolor=panelBg, text_size=size.tiny)
    table.cell(dashboard, 1, 44, displayMode, text_color=goldColor, bgcolor=panelBg, text_size=size.tiny)

    table.cell(dashboard, 0, 45, "ALERTS", text_color=mutedText, bgcolor=panelBg2, text_size=size.tiny)
    table.cell(dashboard, 1, 45, enableAlerts ? "ARMED" : "OFF", text_color=enableAlerts ? bullColor : mutedText, bgcolor=panelBg2, text_size=size.tiny)
````
