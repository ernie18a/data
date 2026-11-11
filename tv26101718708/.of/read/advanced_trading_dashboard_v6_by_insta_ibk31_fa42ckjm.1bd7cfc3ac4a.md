Calculation: Bull score = count of these six conditions that are true: RSI between a lower bullish threshold and an upper bullish threshold; shorter-period close EMA > longer-period close EMA; MACD histogram > 0 AND MACD histogram > its previous value; stochastic %K > its EMA-smoothed %D AND %K < an upper threshold; +DI > -DI AND ADX > a trend-strength threshold; close > open AND volume > its SMA.
Calculation: Bear score = count of these six conditions that are true: RSI between a lower bearish threshold and an upper bearish threshold; shorter-period close EMA < longer-period close EMA; MACD histogram < 0 AND MACD histogram < its previous value; stochastic %K < its EMA-smoothed %D AND %K > a lower threshold; -DI > +DI AND ADX > the trend-strength threshold; close < open AND volume > its SMA. The bearish RSI thresholds are below the corresponding bullish RSI thresholds.
Calculation: Buying liquidity = SMA of volume assigned to bars where close > open, with zero assigned to all other bars; selling liquidity = the same SMA of volume assigned to bars where close < open, with zero assigned to all other bars.
Calculation: Doji = absolute value of close minus open <= a fraction of high minus low.
Long: Bull score >= a score threshold.
Short: Bear score >= the same score threshold.
Long: RSI > lower bullish threshold AND RSI < upper bullish threshold.
Short: RSI > lower bearish threshold AND RSI < upper bearish threshold.
Long: shorter-period close EMA > longer-period close EMA.
Short: shorter-period close EMA < longer-period close EMA.
Long: MACD histogram > 0 AND MACD histogram > previous MACD histogram.
Short: MACD histogram < 0 AND MACD histogram < previous MACD histogram.
Long: stochastic %K > its EMA-smoothed %D AND %K < upper threshold.
Short: stochastic %K < its EMA-smoothed %D AND %K > lower threshold.
Long: +DI > -DI AND ADX > trend-strength threshold.
Short: -DI > +DI AND ADX > trend-strength threshold.
Long: close > open.
Short: close < open.
Long: bull score > bear score.
Short: bear score > bull score.
Long: buying liquidity > selling liquidity.
Short: buying liquidity <= selling liquidity.
Long: previous close < previous open AND close > open AND close > previous open AND open < previous close.
Short: previous close > previous open AND close < open AND close < previous open AND open > previous close.
Long: high - low > a multiple of absolute value of close - open AND (close - low) / (small positive offset + high - low) > a lower ratio threshold AND (high - close) / (small positive offset + high - low) < a smaller upper ratio threshold.
Short: high - low > the same multiple of absolute value of close - open AND (high - close) / (small positive offset + high - low) > the lower ratio threshold AND (close - low) / (small positive offset + high - low) < the smaller upper ratio threshold.
Long: close two bars ago < open two bars ago AND previous bar is a doji AND close > open AND close > midpoint of open and close two bars ago.
Short: close two bars ago > open two bars ago AND previous bar is a doji AND close < open AND close < midpoint of open and close two bars ago.
Long: close > open AND previous close > previous open AND close two bars ago > open two bars ago AND close > previous close AND previous close > close two bars ago.
Short: close < open AND previous close < previous open AND close two bars ago < open two bars ago AND close < previous close AND previous close < close two bars ago.
Long: close rate of change > 0 AND bull score > bear score.
Short: close rate of change < 0 AND bear score > bull score.