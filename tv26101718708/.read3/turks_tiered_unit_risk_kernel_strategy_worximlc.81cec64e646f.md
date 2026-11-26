Calculation: Graded exposure = average over four progressively longer lookbacks of clamp((close − SMA(close, lookback)) / (ramp-width multiplier × sqrt(lookback / longest lookback) × ATR(ramp lookback)), 0, 1)
Calculation: Quantised exposure = graded exposure when step count is zero; otherwise retain the previous quantised exposure until the graded exposure differs from it by at least the step-trigger fraction of one step, then round the graded exposure to the nearest step
Calculation: Effective exposure = quantised exposure when NWE gating is disabled or the configured source is at or above the causal Nadaraya-Watson Envelope mean; otherwise max(previous effective exposure, quantised exposure)
Calculation: Target weight = min(off-state floor + (1 − off-state floor) × risk scale × effective exposure, gross exposure cap)
Long: confirmed chart bar AND position flat AND effective exposure > 0
Exit: long, confirmed chart bar AND effective exposure = 0
Long: confirmed chart bar AND target weight > target weight one chart bar ago
Exit: long, confirmed chart bar AND target weight < target weight one chart bar ago