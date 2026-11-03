Calculation: Confirmed swing high/low = a bar whose high/low is the highest/lowest across the sensitivity-length bars before and after it; use it only after the bars after it have completed.
Calculation: RSI = relative strength index of close; compare RSI values at successive confirmed swing highs or successive confirmed swing lows.
Calculation: ATR = average true range.
Calculation: Sweep reference high/low = highest high / lowest low of the previous twice-lookback bars, excluding the current bar.
Calculation: Upper/lower trend band = EMA-smoothed SMA of EMA(close, trend length) ± EMA of absolute close-to-basis deviation over three times trend length × band multiplier.
Long: On a completed bar, low < sweep reference low AND close > sweep reference low AND sweep reference low − low ≥ ATR × minimum wick penetration AND lower wick / (high − low) × 100 ≥ minimum rejection percentage AND (volume filter disabled OR volume > volume moving average × volume multiplier) AND (EMA filter disabled OR close < EMA) AND cooldown since prior bullish sweep has elapsed.
Long: A confirmed swing low has a lower price than the preceding confirmed swing low AND a higher RSI value; mark when bullish divergence display is enabled.
Long: Trend direction is bullish when close > upper trend band; retain bullish direction until close < lower trend band.
Short: On a completed bar, high > sweep reference high AND close < sweep reference high AND high − sweep reference high ≥ ATR × minimum wick penetration AND upper wick / (high − low) × 100 ≥ minimum rejection percentage AND (volume filter disabled OR volume > volume moving average × volume multiplier) AND (EMA filter disabled OR close > EMA) AND cooldown since prior bearish sweep has elapsed.
Short: A confirmed swing high has a higher price than the preceding confirmed swing high AND a lower RSI value; mark when bearish divergence display is enabled.
Short: Trend direction is bearish when close < lower trend band; retain bearish direction until close > upper trend band.
Exit: Long, an active divergence trailing stop is crossed by close (close < stop) OR RSI ≥ overbought level.
Exit: Short, an active divergence trailing stop is crossed by close (close > stop) OR RSI ≤ oversold level.