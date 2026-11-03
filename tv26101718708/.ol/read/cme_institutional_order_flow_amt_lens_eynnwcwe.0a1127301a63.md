Calculation: Candle range = max(high - low, minimum price increment); lower wick = min(open, close) - low; upper wick = high - max(open, close); body = abs(close - open).
Calculation: Estimated volume delta = volume * (2 * (close - low) / candle range - 1).
Calculation: Relative volume = volume / SMA(volume); if the SMA is not positive, use 1. On the designated chart timeframe, use volume divided by the mean volume of all preceding completed bars at the same local hour when enough such bars exist and their mean is positive; otherwise use the SMA-based value.
Long: close >= open.
Short: close < open.
Long: estimated volume delta > 0.
Short: estimated volume delta < 0.
Long: (low < previous low OR low < low two bars ago) AND estimated volume delta > 0 AND (close > open OR close > low + reclaim fraction * candle range).
Short: (high > previous high OR high > high two bars ago) AND estimated volume delta < 0 AND (close < open OR close < high - reclaim fraction * candle range).
Long: bar time outside the opening blackout AND lower wick / candle range >= absorption wick threshold AND close >= low + midpoint fraction * candle range AND (relative volume >= absorption volume threshold OR abs(estimated volume delta) / SMA(abs(estimated volume delta)) >= delta effort threshold) AND (estimated volume delta < 0 OR abs(estimated volume delta) / volume >= absorption delta threshold).
Short: bar time outside the opening blackout AND upper wick / candle range >= absorption wick threshold AND close <= high - midpoint fraction * candle range AND (relative volume >= absorption volume threshold OR abs(estimated volume delta) / SMA(abs(estimated volume delta)) >= delta effort threshold) AND (estimated volume delta > 0 OR abs(estimated volume delta) / volume >= absorption delta threshold).
Long: relative volume >= drive volume threshold AND body / candle range >= drive body threshold AND close > open AND estimated volume delta > 0.
Short: relative volume >= drive volume threshold AND body / candle range >= drive body threshold AND close < open AND estimated volume delta < 0.