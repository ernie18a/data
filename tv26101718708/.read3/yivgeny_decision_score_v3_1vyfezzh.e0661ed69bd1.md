Calculation: Short moving average = SMA(close, short-MA lookback) when the MA-type parameter selects SMA, otherwise EMA(close, short-MA lookback)
Calculation: Confirmation candle = close > open AND close > high[1] AND volume >= SMA(volume, volume-average lookback) * confirmation-volume multiplier
Calculation: Breakout trigger = close > highest(high, breakout base lookback * breakout conversion multiplier)[1] AND close > open AND volume >= SMA(volume, volume-average lookback) * breakout-volume multiplier AND close >= highest(high, upper-range lookback)[1] * upper-range threshold multiplier
Calculation: Pullback trigger = low <= short moving average * (1 - dip threshold fraction) AND close > short moving average AND Confirmation candle AND SMA(close, long-MA lookback) > SMA(close, long-MA lookback)[long-MA slope lookback ago] AND short moving average > short moving average[short-MA slope lookback ago]
Calculation: Long-MA bounce trigger = low <= SMA(close, long-MA lookback) * (1 + touch-tolerance fraction) AND close > SMA(close, long-MA lookback) AND Confirmation candle
Long: Breakout trigger
Long: NOT Breakout trigger AND Pullback trigger
Long: NOT Breakout trigger AND NOT Pullback trigger AND Long-MA bounce trigger