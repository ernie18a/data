Calculation: Rolling IQR = 75th percentile(close, quartile lookback, linear interpolation) - 25th percentile(close, quartile lookback, linear interpolation)
Calculation: Smoothed IQR = SuperSmoother(Rolling IQR, IQR smoothing lookback)
Calculation: Smoothed HLC3 = SuperSmoother(hlc3, midline lookback)
Calculation: Lower sweep band = Smoothed HLC3 - (Smoothed IQR * band width multiplier)
Calculation: Upper sweep band = Smoothed HLC3 + (Smoothed IQR * band width multiplier)
Calculation: Lower outlier fence = Smoothed HLC3 - (Smoothed IQR * outlier multiplier)
Calculation: Upper outlier fence = Smoothed HLC3 + (Smoothed IQR * outlier multiplier)
Long: Smoothed HLC3 > Smoothed HLC3[1]
Short: Smoothed HLC3 < Smoothed HLC3[1]
Long: On a confirmed chart bar, any of the prior sweep-lookback bars had low <= that bar's Lower sweep band OR current low <= current Lower outlier fence; close crosses above Smoothed HLC3; volume >= SMA(volume, volume-average lookback) * active-volume multiplier; the signal cooldown has elapsed since the most recent qualified long or short signal; close > Lowest(low, stop lookback); max(current Upper outlier fence, Highest(high, liquidity lookback)[1]) > close; and (max(current Upper outlier fence, Highest(high, liquidity lookback)[1]) - close) / (close - Lowest(low, stop lookback)) >= minimum risk/reward
Short: On a confirmed chart bar, any of the prior sweep-lookback bars had high >= that bar's Upper sweep band OR current high >= current Upper outlier fence; close crosses below Smoothed HLC3; volume >= SMA(volume, volume-average lookback) * active-volume multiplier; the signal cooldown has elapsed since the most recent qualified long or short signal; Highest(high, stop lookback) > close; min(current Lower outlier fence, Lowest(low, liquidity lookback)[1]) < close; and (close - min(current Lower outlier fence, Lowest(low, liquidity lookback)[1])) / (Highest(high, stop lookback) - close) >= minimum risk/reward