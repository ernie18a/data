Calculation: Intrabar delta = sum of lower-timeframe volume for bars with close ≥ open, minus volume for bars with close < open; use lower-timeframe bars within the current chart bar. If the lower timeframe is unavailable or not lower than the chart timeframe, use chart-bar volume with the same sign rule.
Calculation: Delta EMA = exponential moving average of intrabar delta.
Calculation: SSL channel state = bullish when close is above the longer-lookback simple moving average of high, bearish when close is below the longer-lookback simple moving average of low, and otherwise retain the previous state; the upper and lower channel lines swap according to that state.
Calculation: PVSRA level = elevated when volume is at least its moving average times the level threshold, or when volume × (high − low) is at a rolling lookback high; the second threshold is higher than the first.
Long: Close > upper VWAP band 1
Short: Close < lower VWAP band 1
Long: High exceeds upper VWAP band 1 by at least the minimum penetration percentage and close < upper VWAP band 1, subject to the same-side cooldown
Short: Low falls below lower VWAP band 1 by at least the minimum penetration percentage and close > lower VWAP band 1, subject to the same-side cooldown
Long: Close crosses above VWAP
Short: Close crosses below VWAP
Long: Delta EMA crosses above zero
Short: Delta EMA crosses below zero
Long: Close > open AND PVSRA level is at least the lower volume threshold
Short: Close ≤ open AND PVSRA level is at least the lower volume threshold
Long: SSL channel state changes to bullish, long cooldown has elapsed, and alternation permits a long; while pending, confirm before expiry when delta EMA > 0, or when exhaustion-flip confirmation is enabled, delta EMA crosses above zero after reaching the negative exhaustion threshold within the lookback; cancel if the SSL state changes to bearish or the pending signal expires
Short: SSL channel state changes to bearish, short cooldown has elapsed, and alternation permits a short; while pending, confirm before expiry when delta EMA < 0, or when exhaustion-flip confirmation is enabled, delta EMA crosses below zero after reaching the positive exhaustion threshold within the lookback; cancel if the SSL state changes to bullish or the pending signal expires