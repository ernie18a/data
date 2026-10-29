Calculation: Bar range = high − low
Calculation: Close location = 2 × ((close − low) / bar range) − 1, clipped to [−1, 1]
Calculation: Directional pressure = 0.65 × candle body direction × (|close − open| / bar range) + 0.35 × close location, clipped to [−1, 1]; candle body direction is 1 if close > open, −1 if close < open, and 0 otherwise
Calculation: Volume delta proxy = volume × directional pressure
Calculation: Order-flow imbalance proxy = volume delta proxy / volume
Calculation: Cumulative volume delta proxy = cumulative sum of volume delta proxy
Calculation: Cumulative volume delta slope score = the z-score of the difference between the current and prior one-bar-offset linear regression values of cumulative volume delta proxy over a lookback, measured over a longer lookback, divided by 3 and clipped to [−1, 1]
Calculation: VWAP deviation score = ((close − VWAP) / ATR) / 3, clipped to [−1, 1]
Calculation: Liquidity score = the z-score of (volume / bar range), divided by 3 and clipped to [−1, 1]
Calculation: Range spread risk = max(0, z-score of (bar range / close))
Calculation: Amihud risk = max(0, z-score of (|ln(close / prior close)| / max(volume × close, 1)))
Calculation: VPIN risk = max(0, z-score of (SMA(|volume delta proxy|) / max(SMA(volume), 1)))
Calculation: Composite score = EMA of ((weighted sum of order-flow imbalance proxy, cumulative volume delta slope score, close location, and VWAP deviation score, plus weighted liquidity confirmation in the direction of that sum) / (1 + weighted range spread risk + weighted VPIN risk + 0.50 × Amihud risk)); liquidity confirmation is the sign of the directional sum multiplied by max(liquidity score, 0)
Calculation: Upside probability = 100 / (1 + exp(−composite score × sensitivity))
Long: Upside probability > bullish threshold AND composite score > minimum score AND (trend filter disabled OR fast EMA > slow EMA) AND (signal mode is every bar OR the prior bar did not meet the long conditions
Short: Upside probability < bearish threshold AND composite score < −minimum score AND (trend filter disabled OR fast EMA < slow EMA) AND (signal mode is every bar OR the prior bar did not meet the short conditions