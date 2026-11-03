Calculation: Close location = (2 × close − high − low) / (high − low), or 0 when high equals low.
Calculation: Pressure Z = Z-score of the cumulative sum of close location × volume × (relative-volume boost when volume > its moving average, otherwise 1) × (1 + absolute close location), minus a configurable moving average of that cumulative sum.
Calculation: Volume sigma Z = Z-score of the square root of the EMA of squared log(volume / previous volume), with the log return set to 0 if either volume is not positive.
Calculation: Effort Z = Z-score of the EMA of close location × relative volume, where relative volume is volume / SMA(volume), or 1 when the SMA is not positive.
Calculation: Efficiency bias = (close − close at the lookback) / sum of absolute close-to-close changes over the lookback, or 0 when the lookback close is unavailable or the sum is not positive.
Calculation: VWAP bias = (close − session-anchored VWAP of typical price) / ATR, or 0 when ATR is not positive.
Calculation: Composite = weighted sum of pressure Z, effort Z, volume sigma Z, (RSI of close − RSI midpoint) scaled by a positive constant, efficiency bias, and VWAP bias; the positive weights decrease in that order.
Calculation: Spread = composite − EMA of composite.
Calculation: Envelope = EMA of composite plus or minus a positive envelope multiplier × standard deviation of composite over the same lookback.
Calculation: Extreme envelope = EMA of composite plus or minus a positive extreme multiplier × standard deviation of composite over the same lookback.
Calculation: Auction skew = (pressure Z + effort Z + VWAP bias) / 3.
Calculation: Confirmed composite pivot = a composite high or low with the same pivot lookback on both sides, evaluated only after the right-side bars have completed. For divergence, compare with the most recent earlier confirmed pivot of the same kind whose confirmation is at least pivot lookback + 1 bars ago and within the divergence scan lookback; use the price high or low on each oscillator pivot bar.
Long: Composite > 0.
Short: Composite < 0.
Long: Spread >= 0.
Short: Spread < 0.
Long: Fast EMA of close >= slow EMA of close AND close >= slow EMA of close.
Short: Fast EMA of close < slow EMA of close AND close < slow EMA of close.
Long: Composite > 0 AND spread > positive minimum spread AND pressure Z > 0 AND effort Z > 0 AND (trend gate disabled OR fast EMA of close >= slow EMA of close AND close >= slow EMA of close) AND (VWAP gate disabled OR close >= session-anchored VWAP) AND (composite > upper envelope OR composite > upper extreme envelope).
Short: Composite < 0 AND spread < negative minimum spread AND pressure Z < 0 AND effort Z < 0 AND (trend gate disabled OR fast EMA of close < slow EMA of close AND close < slow EMA of close) AND (VWAP gate disabled OR close < session-anchored VWAP) AND (composite < lower envelope OR composite < lower extreme envelope).
Long: Pressure Z > 0 AND effort Z < 0 AND composite > 0 AND spread < 0.
Short: Pressure Z < 0 AND effort Z > 0 AND composite < 0 AND spread > 0.
Long: Composite > EMA of composite over the envelope lookback AND spread > 0 AND auction skew > 0.
Short: Composite < EMA of composite over the envelope lookback AND spread < 0 AND auction skew < 0.
Long: A confirmed composite low pivot is higher than the preceding eligible composite low pivot AND its corresponding price low is lower than the preceding pivot's price low.
Short: A confirmed composite high pivot is lower than the preceding eligible composite high pivot AND its corresponding price high is higher than the preceding pivot's price high.
Long: Composite of the last completed higher-timeframe bar > positive state threshold.
Short: Composite of the last completed higher-timeframe bar < negative state threshold.