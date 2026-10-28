Calculation: Directional pressure = clipped weighted combination of candle body direction times body size/range and close location within the bar.
Calculation: Order flow imbalance = (volume-weighted directional pressure) / volume.
Calculation: Cumulative volume delta = cumulative volume-weighted directional pressure; its slope is the linear-regression slope over a lookback, standardized by its rolling z-score and scaled/clipped to [-1, 1].
Calculation: Close location = clipped position of the close within the bar range, scaled to [-1, 1].
Calculation: VWAP score = clipped (close − current-session VWAP) / ATR, scaled to [-1, 1].
Calculation: Liquidity score = clipped rolling z-score of volume / bar range, scaled to [-1, 1].
Calculation: Spread risk = maximum of zero and the rolling z-score of bar range / close.
Calculation: Toxic-flow risk = maximum of zero and the rolling z-score of the ratio of the rolling mean absolute volume delta to the rolling mean volume.
Calculation: Illiquidity risk = maximum of zero and the rolling z-score of absolute log close-to-close return / (volume × close).
Calculation: Composite score = EMA-smoothed, risk-adjusted weighted sum of order flow imbalance, cumulative volume delta score, close location, VWAP score, and directional liquidity confirmation; divide by one plus weighted spread risk, toxic-flow risk, and illiquidity risk. Directional liquidity confirmation is the sign of the weighted directional sum times the positive part of the liquidity score.
Calculation: Upside probability = 100 / (1 + exp(−composite score × sensitivity)).
Long: upside probability ≥ bullish threshold OR (upside probability > bullish threshold AND composite score > minimum score AND fast EMA > slow EMA AND previous bar did not satisfy all three conditions)
Short: upside probability ≤ bearish threshold OR (upside probability < bearish threshold AND composite score < −minimum score AND fast EMA < slow EMA AND previous bar did not satisfy all three conditions)