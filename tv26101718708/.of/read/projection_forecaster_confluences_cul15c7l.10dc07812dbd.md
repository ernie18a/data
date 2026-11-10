Calculation: Clamp(x) = max(-1, min(1, x)).
Calculation: Trend score = one half of the sum of two terms, each +1 when respectively the shorter-period close EMA > the intermediate-period close EMA and the intermediate-period close EMA > the longer-period close EMA, otherwise -1.
Calculation: Momentum score = Clamp(RSI weight × (close RSI − RSI midpoint) / RSI normalization + MACD weight × MACD histogram / ATR).
Calculation: Higher-timeframe score = +1 when close > close EMA on a higher timeframe, otherwise -1. On non-intraday charts use the chart timeframe instead. With lookahead disabled, historical chart bars use the last completed higher-timeframe bar; a live bar can use the still-forming higher-timeframe bar.
Calculation: Flow score = Clamp(EMA of signed volume / (SMA of volume + small positive constant)), where signed volume is volume when close > open, negative volume when close < open, and zero otherwise.
Calculation: Mean-reversion score = Clamp(−(close − session VWAP of typical price) / (ATR multiplier × ATR)).
Calculation: Bias = Clamp(EMA of the weighted sum of trend, momentum, higher-timeframe, flow, and mean-reversion scores divided by the sum of their weights; use 1 as the divisor if the weight sum is zero).
Calculation: Directional state = absolute bias >= neutral threshold AND (range detection disabled OR ADX >= range threshold).
Long: Bias > 0 AND directional state.
Short: Bias < 0 AND directional state.
Long: Trend score >= 0 OR momentum score >= 0 OR higher-timeframe score >= 0 OR flow score >= 0 OR mean-reversion score >= 0.
Short: Trend score < 0 OR momentum score < 0 OR higher-timeframe score < 0 OR flow score < 0 OR mean-reversion score < 0.
Long: Bias > 0 AND directional state AND (previous bias <= 0 OR previous directional state is false).
Short: Bias < 0 AND directional state AND (previous bias >= 0 OR previous directional state is false).
Long: Bias > 0 AND directional state AND absolute bias >= strong-conviction threshold AND (previous absolute bias < strong-conviction threshold OR previous directional state is false).
Short: Bias < 0 AND directional state AND absolute bias >= strong-conviction threshold AND (previous absolute bias < strong-conviction threshold OR previous directional state is false).