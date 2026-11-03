Calculation: Smoothed average of a series = SMA of its EMA, using the same lookback for both.
Calculation: Baseline = smoothed average of close using the baseline lookback.
Calculation: Step = smoothed average of high minus low using the step lookback.
Calculation: Bands = baseline plus or minus one, two, or three times step.
Calculation: Warmup = maximum of three times the baseline lookback and the step lookback plus the warmup offset.
Long: Baseline > previous baseline.
Short: Baseline < previous baseline.
Long: Baseline > previous baseline AND close > any band.
Short: Baseline <= previous baseline AND close < any band.
Long: Close > baseline + two steps.
Short: Close < baseline - two steps.
Long: RSI >= upper display threshold.
Short: RSI <= lower display threshold, where the lower threshold is the RSI maximum minus the upper display threshold.
Long: Bar index >= warmup AND baseline > previous baseline AND close > baseline + step AND RSI >= signal threshold AND (volume filter disabled OR volume <= 0 OR volume > volume SMA multiplied by volume multiplier).
Short: Bar index >= warmup AND baseline <= previous baseline AND close < baseline - step AND RSI <= RSI maximum minus signal threshold AND (volume filter disabled OR volume <= 0 OR volume > volume SMA multiplied by volume multiplier).