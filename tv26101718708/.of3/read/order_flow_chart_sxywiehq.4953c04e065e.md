Calculation: Buy volume = volume * ((close - low) / (high - low)) when high > low, otherwise volume * 0.5
Calculation: Sell volume = volume - Buy volume
Calculation: Volume delta = Buy volume - Sell volume
Calculation: Smoothed volume delta = EMA(Volume delta, delta smoothing lookback)
Calculation: Cumulative delta = cumulative sum of Smoothed volume delta on chart bars, reset at the start of each T1 period using the current, still-forming T1 period
Calculation: Buy percentage = Buy volume / volume * 100
Calculation: Smoothed buy percentage = EMA(Buy percentage, separate buy-percentage lookback)
Long: Smoothed volume delta > delta polarity threshold
Short: Smoothed volume delta <= delta polarity threshold
Long: volume >= SMA(volume, block volume average lookback) * block volume multiplier AND close >= open
Short: volume >= SMA(volume, block volume average lookback) * block volume multiplier AND close < open
Long: Smoothed buy percentage >= imbalance threshold
Short: Smoothed buy percentage <= 100 - imbalance threshold
Long: Smoothed buy percentage >= imbalance threshold AND Smoothed buy percentage[1] < imbalance threshold
Short: Smoothed buy percentage <= 100 - imbalance threshold AND Smoothed buy percentage[1] > 100 - imbalance threshold
Long: Cumulative delta > cumulative polarity threshold
Short: Cumulative delta <= cumulative polarity threshold
Long: Cumulative delta crosses above cumulative polarity threshold
Short: Cumulative delta crosses below cumulative polarity threshold
Long: Cumulative delta > cumulative polarity threshold AND Smoothed buy percentage > buy-percentage balance threshold
Short: Cumulative delta < cumulative polarity threshold AND Smoothed buy percentage < buy-percentage balance threshold
Long: close > VWAP(hlc3, T1 anchor, chart bars in the current, still-forming T1 period)
Short: close <= VWAP(hlc3, T1 anchor, chart bars in the current, still-forming T1 period)