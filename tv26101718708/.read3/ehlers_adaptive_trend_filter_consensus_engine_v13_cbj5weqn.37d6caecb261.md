Calculation: fast filter path = 2-pole Ehlers SuperSmoother(close, shared signal lookback)
Calculation: fast filter baseline = 2-pole Ehlers SuperSmoother(fast filter path, shared longer anchor lookback) × baseline multiplier
Calculation: core filter path = 3-pole Ehlers SuperSmoother(close, shared signal lookback)
Calculation: core filter baseline = 2-pole Ehlers SuperSmoother(core filter path, shared longer anchor lookback) × baseline multiplier
Calculation: adaptive filter path = MAMA(close, fast limit, slow limit)
Calculation: adaptive filter baseline = FAMA(close, fast limit, slow limit)
Calculation: chart path = fast filter path in Fast mode; core filter path in Hybrid or Smooth mode; adaptive filter path in Adaptive mode
Calculation: chart baseline = fast filter baseline in Fast mode; core filter baseline in Hybrid mode; 3-pole Ehlers SuperSmoother(core filter path, shared longer anchor lookback) × baseline multiplier in Smooth mode; adaptive filter baseline in Adaptive mode
Long: chart path > chart baseline
Short: chart path <= chart baseline
Long: fast filter path > fast filter baseline
Short: fast filter path <= fast filter baseline
Long: core filter path > core filter baseline
Short: core filter path <= core filter baseline
Long: adaptive filter path > adaptive filter baseline
Short: adaptive filter path <= adaptive filter baseline
Long: close > close[n]
Short: close <= close[n]
Calculation: bearish cluster stage = 0 below the cluster-count parameter, 1 at or above it, 2 after the shorter persistence threshold, or 3 after the longer persistence threshold; count names whose fast and core filter paths exceed their baselines while the adaptive filter path is at or below its baseline
Calculation: bullish cluster stage = 0 below the cluster-count parameter, 1 at or above it, 2 after the shorter persistence threshold, or 3 after the longer persistence threshold; count names whose adaptive filter path exceeds its baseline while the fast and core filter paths are at or below their baselines
Long: bullish cluster stage > bullish cluster stage[1] on chart bars of T1 or higher
Short: bearish cluster stage > bearish cluster stage[1] on chart bars of T1 or higher