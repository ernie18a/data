Calculation: Momentum Z-score = (current close change − its rolling mean) / rolling standard deviation of close changes
Calculation: Body ratio = absolute(close − open) / (high − low)
Calculation: Confirmed swing high/low = pivot high/low requiring the same configurable number of bars on both sides; use the latest confirmed pivot as the structural level
Calculation: Bullish/bearish sweep level = lowest low/highest high over the preceding configurable lookback bars
Calculation: Volume ratio = current volume / its rolling average
Calculation: Bull/Bear SMC score = sum of directional structure break (MSB: 30, otherwise BMS: 20), same-side sweep (20), nearby unmitigated same-side HPZ order blocks (1: 10; 2+: 18), opposite-side unfilled FVGs as targets (1: 5; 2+: 10), directional momentum Z-score (strong: 12; moderate: 7; mild: 3), volume ratio (above 1: 2; above 1.3: 5; above 2: 8), and candle direction/body (matching direction: 3; body ratio above 0.6: 6); subtract 10 for opposing Z-score beyond 1 and 8 for 2+ nearby opposing HPZs; clamp to 0–100. A nearby HPZ is unmitigated, has score at least the configurable HPZ threshold, and is within 2 ATR of close. Use current-bar ATR(14), volume, candle, and momentum values and active zones.
Long: Close crosses above the latest confirmed swing high (previous close at or below it) AND momentum Z-score exceeds the configurable positive threshold
Long: Close crosses above the latest confirmed swing high (previous close at or below it) AND body ratio > 0.5
Long: Low < preceding-lookback lowest low AND close > that level AND close > open
Long: Bull SMC score ≥ configurable minimum AND (bullish MSB OR bullish sweep) AND (volume filter disabled OR volume ratio ≥ configurable minimum) AND same-direction cooldown elapsed
Short: Close crosses below the latest confirmed swing low (previous close at or above it) AND momentum Z-score is below the negative configurable threshold
Short: Close crosses below the latest confirmed swing low (previous close at or above it) AND body ratio > 0.5
Short: High > preceding-lookback highest high AND close < that level AND close < open
Short: Bear SMC score ≥ configurable minimum AND (bearish MSB OR bearish sweep) AND (volume filter disabled OR volume ratio ≥ configurable minimum) AND same-direction cooldown elapsed
Exit: Long, close crosses below the latest tracked swing low and momentum Z-score is below the negative configurable threshold
Exit: Short, close crosses above the latest tracked swing high and momentum Z-score exceeds the configurable positive threshold