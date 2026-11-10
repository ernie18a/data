Calculation: Volume delta = buying volume minus selling volume. In wick-based mode, buying volume is volume * (close - low) / (high - low), or volume / 2 when high = low; selling volume is volume minus buying volume. In candle-color mode, buying volume is volume when close >= open and 0 otherwise; selling volume is volume when close < open and 0 otherwise.
Calculation: Cumulative volume delta = cumulative sum of volume delta, either continuously or reset at each daily boundary, with the first bar after reset equal to its volume delta.
Long: Volume delta >= 0
Short: Volume delta < 0
Long: Cumulative volume delta >= 0
Short: Cumulative volume delta < 0
Long: Low < lowest low of the preceding lookback bars AND volume delta > lowest volume delta of the preceding lookback bars AND volume delta < 0
Short: High > highest high of the preceding lookback bars AND volume delta < highest volume delta of the preceding lookback bars AND volume delta > 0