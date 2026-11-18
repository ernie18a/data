Calculation: Fast EMA = EMA(close, shorter lookback)
Calculation: Slow EMA = EMA(close, longer lookback)
Calculation: Relative volume = volume / SMA(volume, relative-volume lookback)
Calculation: Fading volume = Relative volume <= low relative-volume threshold OR (Relative volume[i] < Relative volume[i+1] for every i from 0 through fade lookback minus one AND SMA(Relative volume, fade lookback) < SMA(Relative volume, fade lookback)[fade lookback])
Long: Fast EMA > Slow EMA
Short: Fast EMA <= Slow EMA
Long: Fast EMA crosses above Slow EMA
Short: Fast EMA crosses below Slow EMA
Long: Fast EMA > Slow EMA AND Fading volume AND Fast EMA[1] > Slow EMA[1]
Short: Fast EMA <= Slow EMA AND Fading volume AND Fast EMA[1] <= Slow EMA[1]