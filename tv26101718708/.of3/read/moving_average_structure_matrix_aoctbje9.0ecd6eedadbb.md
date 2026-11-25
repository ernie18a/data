Calculation: Selected source = configured choice of open, high, low, close, HL2, HLC3, OHLC4, or HLCC4.
Calculation: Moving-average set = distinct enabled MA(source, type_i, lookback_i) values, with separate type, lookback, and horizon-rank parameters; equal horizons are excluded from ordering; fast/slow cohort membership is fixed from original unique specifications using the configured rank or length split.
Calculation: Ensemble center = mean(moving-average set); bundle high = max(moving-average set); bundle low = min(moving-average set); bundle width = bundle high - bundle low.
Calculation: Normalized distance(x) = x / ATR(ATR lookback), 100*x / abs(ensemble center), or x / StDev(selected source, stdev lookback), according to the configured normalization mode.
Calculation: Order coherence = 100 * sum(pair weight * pair sign) / sum(pair weight), over distinct MA pairs with unequal configured horizons; pair sign is +1 when normalized(faster MA - slower MA) exceeds the pair-separation parameter, -1 when it is below its negative, and 0 otherwise; pair weight is horizon distance raised to the configured weight power, where horizon distance is rank difference or 1 + abs(log(faster lookback / slower lookback)).
Calculation: MA slope_i = normalized(MA_i - MA_i[slope lookback]); slope coherence = 100 * sum(MA slope_i) / sum(abs(MA slope_i)), or 0 when the denominator is 0.
Calculation: Slope energy = clamp(100 * mean(abs(MA slope_i)) / slope-energy scale, 0, 100).
Calculation: Fast and slow centroids = means of the configured fast and slow MA cohorts; cohort spread = normalized(fast centroid - slow centroid).
Calculation: Bias composite = order-coherence weight * order coherence + slope-coherence weight * slope coherence + cohort-spread weight * clamp(100 * cohort spread / cohort-bias scale, -100, 100).
Calculation: Structure bias = +1 when bias composite is positive and at least the bias threshold, -1 when negative and at most the negative bias threshold, and 0 otherwise.
Calculation: Normalized bundle width = normalized(bundle width); width rank = PercentRank(normalized bundle width, width-rank lookback); width change = normalized bundle width - normalized bundle width[motion lookback]; geometry width change = (bundle width - bundle width[motion lookback]) / current normalization denominator, multiplied by 100 in percentage mode.
Calculation: Centroid slope = normalized(ensemble center - ensemble center[slope lookback]); centroid acceleration = centroid slope - centroid slope[deceleration lookback].
Calculation: Reorder rate = 100 * sum(pair sign reversals over reorder lookback) / (current eligible pair count * reorder lookback); a reversal compares successive nonzero signs for the same pair.
Calculation: Structure ready = valid MA and cohort configuration, complete available MA geometry, at least one eligible pair, nonempty fast and slow cohorts, and all configured normalization, slope, rank, reorder, history, and warm-up requirements satisfied.
Calculation: Compression = structure ready AND width rank <= compression-rank maximum AND slope energy <= compression-energy maximum AND abs(order coherence) <= compression-order maximum AND reorder rate < churn-reorder threshold.
Calculation: Recent compression = compression occurred from one through the configured release-origin lookback bars ago.
Calculation: Release = structure ready AND structure bias != 0 AND recent compression AND structure bias * order coherence >= release-order minimum AND width change >= release-width minimum AND (geometric width required is false OR geometry width change >= release-width minimum) AND structure bias * centroid acceleration >= release-acceleration minimum.
Calculation: Pullback = structure ready AND structure bias != 0 AND close is between bundle low and bundle high AND structure bias * order coherence >= pullback-order floor AND structure bias * slow-cohort slope coherence >= slow-slope-hold threshold AND NOT release.
Calculation: Deceleration = structure ready AND structure bias != 0 AND structure bias * order coherence >= pullback-order floor AND (slope energy <= slope energy[deceleration lookback] - deceleration-energy drop OR abs(slope coherence) <= abs(slope coherence[deceleration lookback]) - deceleration-slope drop OR (width change <= -deceleration-width minimum AND (geometric width required is false OR geometry width change <= -deceleration-width minimum))) AND NOT release AND NOT pullback.
Calculation: Expansion = structure ready AND structure bias != 0 AND structure bias * order coherence >= directional-order threshold AND structure bias * slope coherence >= directional-slope threshold AND structure bias * (close - ensemble center) >= 0 AND NOT release AND NOT pullback.
Calculation: Lifecycle phase = compression if compression, else release if release, else pullback if pullback, else deceleration if deceleration, else expansion if expansion, else transition.
Calculation: Confirmed phase entry = confirmed bar on a standard time-based chart AND structure ready AND the known prior bias/phase state changed to the current state AND current state age equals the configured phase-event age.
Calculation: Structural failure = confirmed bar AND active directional cycle AND (structure bias is opposite the cycle direction OR (close breaches the prior closed slow-cohort centroid AND (cycle direction * order coherence is below the structural-failure order floor OR cycle direction * slow-cohort slope coherence is at or below the negative structural-failure slow-slope flip))).
Calculation: Directional cycle = start or restart on a release phase entry with nonzero structure bias, or on an expansion phase entry with nonzero bias when no cycle is active, bias differs from the cycle direction, or the cycle has reclaimed; clear on structural failure or when cycle age exceeds the configured maximum.
Calculation: First touch = confirmed bar AND a directional cycle was active before the bar AND the cycle has not touched before AND current low <= prior closed bundle high AND current high >= prior closed bundle low AND structure bias equals cycle direction.
Calculation: Reclaim boundary = the first tradable tick strictly above the selected upper bundle edge plus configured tick clearance for a long cycle, or strictly below the selected lower edge minus clearance for a short cycle; the selected edge is the frozen prior closed bundle at first touch or the latest prior closed bundle, according to the configured boundary mode.
Calculation: Reclaim = confirmed bar AND active directional cycle AND a first touch occurred on an earlier bar AND the cycle has not reclaimed AND structure bias equals cycle direction AND cycle direction * order coherence >= pullback-order floor AND close crosses the reclaim boundary from the adverse side (prior close < boundary and current close >= boundary for long; prior close > boundary and current close <= boundary for short).
Calculation: Higher-timeframe structure = the same structure calculations run on T1 and optionally T2 bars; each chart bar uses the latest completed T1/T2 bar, with profile-specific caps applied to higher-timeframe lookbacks.
Calculation: Full timeframe alignment = at least one enabled, valid strictly higher timeframe is ready and has the same nonzero structure bias as the ready chart structure; when both layers are enabled, T2 is strictly higher than T1 and both must agree.
Calculation: Alignment gain = full timeframe alignment AND the aligned direction differs from the prior chart bar's aligned direction.
Calculation: Extension direction = structure bias when structure is ready, nonzero, and structure bias * (close - fast centroid) / current ATR >= extension-distance parameter; otherwise 0. Extension entry occurs when confirmed bar, prior chart structure was ready, current extension direction is nonzero, and it differs from the prior bar's extension direction.
Calculation: Checkpoint watch = an enabled, admitted watch started by a reclaim, retaining that reclaim's direction and boundary; subsequent confirmed chart bars are monitored only while structure remains ready, excluding the reclaim bar and ending at the first adverse close or configured watch-window limit.
Calculation: Initial checkpoint hold = a valid checkpoint watch survives the configured number of consecutive subsequent confirmed chart closes on or beyond its boundary in the reclaim direction, with configured hold bars <= watch-window bars.
Calculation: Checkpoint loss = a valid checkpoint watch's first subsequent confirmed chart close crosses to the adverse side of its boundary before the watch window expires.
Long: structure ready AND structure bias = +1.
Short: structure ready AND structure bias = -1.
Long: confirmed phase entry AND lifecycle phase = release AND structure bias = +1.
Short: confirmed phase entry AND lifecycle phase = release AND structure bias = -1.
Long: confirmed phase entry AND lifecycle phase = expansion AND structure bias = +1.
Short: confirmed phase entry AND lifecycle phase = expansion AND structure bias = -1.
Long: first touch AND cycle direction = +1.
Short: first touch AND cycle direction = -1.
Long: reclaim AND cycle direction = +1.
Short: reclaim AND cycle direction = -1.
Long: alignment gain AND aligned direction = +1.
Short: alignment gain AND aligned direction = -1.
Long: extension entry AND extension direction = +1.
Short: extension entry AND extension direction = -1.
Long: structural failure AND cycle direction = -1.
Short: structural failure AND cycle direction = +1.
Long: initial checkpoint hold AND reclaim direction = +1.
Short: initial checkpoint hold AND reclaim direction = -1.
Exit: long, checkpoint loss AND reclaim direction = +1.
Exit: short, checkpoint loss AND reclaim direction = -1.