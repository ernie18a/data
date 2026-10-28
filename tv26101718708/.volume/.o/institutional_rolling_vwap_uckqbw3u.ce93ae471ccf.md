Calculation: Rolling VWAP = volume-weighted average of hlc3 over a rolling time window scaled to the chart timeframe
Calculation: Relative volume = shorter-lookback average volume / longer-lookback average volume
Calculation: Adaptive standard deviation = 20-bar standard deviation of close divided by the square root of the greater of Relative volume and a configurable floor
Long: close > upper outer deviation band AND Relative volume > high-participation threshold OR close < lower inner deviation band AND Relative volume < low-participation threshold
Short: close < lower outer deviation band AND Relative volume > high-participation threshold OR close > upper inner deviation band AND Relative volume < low-participation threshold
