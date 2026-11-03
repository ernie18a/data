Calculation: Normalized CVD = 2 × (percent-rank of the EMA-smoothed raw delta over its normalization lookback − 50), where raw delta = ((close − open) / (high − low)) × min(volume / SMA(volume, volume lookback), cap)^volume weight; use 0 for the body ratio when high = low and 1 for relative volume when its SMA is 0
Calculation: Normalized momentum = 2 × (percent-rank of the EMA-smoothed difference between current Normalized CVD and its value at the momentum lookback − 50)
Calculation: Composite score = EMA of the weighted sum of Normalized CVD and Normalized momentum, using complementary weights
Long: Composite score crosses above 0
Short: Composite score crosses below 0