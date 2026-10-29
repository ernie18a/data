Calculation: Demand Index = EMA of the ratio of the smaller to the larger absolute buying and selling pressure, using the smoothing lookback; buying pressure and selling pressure are defined below.
Calculation: Buying and selling pressure = if close > open, volume and volume / (3 × close × (close − open) / (open × range)); otherwise, volume / (3 × close × (close − open) / (open × range)) and volume, respectively.
Calculation: Range = max(high, previous bar high) − min(low, previous bar low), optionally smoothed using either a simple moving average or the arithmetic mean of the current range and its lookback parameter; replace zero range with 1.
Long: Demand Index > 0
Short: Demand Index < 0