Calculation: ThresholdA = smaller multiplier * moving average of volume over a lookback (current chart timeframe, current bar included)
Calculation: ThresholdB = larger multiplier * moving average of volume over the same lookback as ThresholdA (smoothing method may differ from ThresholdA's)
Long: close > open AND (volume >= ThresholdA OR volume >= ThresholdB)
Short: close <= open AND (volume >= ThresholdA OR volume >= ThresholdB)