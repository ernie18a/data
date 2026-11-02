Calculation: Momentum score = mean of RSI of close and percentile rank of rate of change of close, evaluated on the previous chart bar.
Calculation: Trend score = mean of ADX and clamp(50 + 20 × 100 × (shorter-period EMA of close − longer-period EMA of close) / longer-period EMA of close, 0, 100), evaluated on the previous chart bar.
Calculation: Volatility score = clamp(50 × ATR / SMA of ATR, 0, 100), evaluated on the previous chart bar; use an ATR-to-SMA ratio of 1 when the ratio is unavailable.
Calculation: Total score = weighted mean of momentum, trend, and volatility scores, clamped to 0–100; use equal weights if all weights are zero, and replace an unavailable trend or volatility score with 0.
Calculation: Higher-timeframe EMA gap = 100 × absolute difference between shorter-period and longer-period EMAs of close / longer-period EMA of close, using the last completed higher-timeframe bar.
Long: Momentum score is available AND higher-timeframe EMA gap ≥ flat threshold AND shorter-period higher-timeframe EMA > longer-period higher-timeframe EMA.
Short: Momentum score is available AND higher-timeframe EMA gap ≥ flat threshold AND shorter-period higher-timeframe EMA ≤ longer-period higher-timeframe EMA.
Long: Momentum score, trend score, volatility score, or total score ≥ bullish score threshold.
Short: Momentum score, trend score, volatility score, or total score < bearish score threshold.
Long: Momentum score is available AND total score ≥ high signal threshold AND higher-timeframe EMA gap < flat threshold.
Long: Momentum score is available AND total score ≥ middle signal threshold AND total score < high signal threshold AND higher-timeframe EMA gap ≥ flat threshold AND shorter-period higher-timeframe EMA > longer-period higher-timeframe EMA.
Short: Momentum score is available AND total score < high signal threshold AND higher-timeframe EMA gap ≥ flat threshold AND shorter-period higher-timeframe EMA ≤ longer-period higher-timeframe EMA.