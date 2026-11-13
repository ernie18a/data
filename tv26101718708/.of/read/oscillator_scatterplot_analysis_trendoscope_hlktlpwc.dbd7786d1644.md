Calculation: osc = RSI of close
Calculation: upper band = SMA of osc + multiplier * population standard deviation of osc, and lower band = SMA of osc - multiplier * population standard deviation of osc, both over the same lookback (Bollinger Bands applied to osc)
Long: osc crosses above lower band (previous osc <= previous lower band AND current osc > current lower band)
Short: osc crosses below upper band (previous osc >= previous upper band AND current osc < current upper band)