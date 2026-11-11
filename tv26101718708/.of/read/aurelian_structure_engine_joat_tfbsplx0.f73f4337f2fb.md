Calculation: Confirmed swing high or low = a high or low that is respectively the highest or lowest over equal numbers of bars before and after it; it becomes available after the confirming bars close.
Calculation: Upward break = at least two swing highs have been confirmed AND close > latest confirmed swing high + ATR × buffer multiplier AND the same condition was false on the preceding bar.
Calculation: Downward break = at least two swing lows have been confirmed AND close < latest confirmed swing low - ATR × buffer multiplier AND the same condition was false on the preceding bar.
Calculation: Structure side = long after an upward break and short after a downward break, remaining unchanged until the opposite break; initially neutral.
Calculation: Yearly anchored VWAP = cumulative sum of typical price × volume divided by cumulative volume since the start of the year; use typical price when cumulative volume is not positive.
Calculation: Pressure = EMA of volume × (2 × close - high - low) / (high - low), divided by the greater of the EMA of volume using the same length and 1; use zero for the numerator contribution when high equals low.
Calculation: Relative volume = volume divided by the greater of the SMA of volume and 1.
Calculation: Signal cooldown = enough bars have elapsed since the most recent long or short gated signal, or no such signal has occurred. Update its starting bar whenever either gated signal occurs.
Long: Structure side = long.
Short: Structure side = short.
Long: Close > EMA of close AND EMA of close > yearly anchored VWAP.
Short: Close < EMA of close AND EMA of close < yearly anchored VWAP.
Long: Pressure >= 0.
Short: Pressure < 0.
Long: Higher-timeframe bias is disabled OR the last completed higher-timeframe close > its EMA of close.
Short: Higher-timeframe bias is enabled AND the last completed higher-timeframe close < its EMA of close.
Long: Signal cooldown is satisfied AND upward break AND close > EMA of close AND EMA of close > yearly anchored VWAP AND (higher-timeframe bias is disabled OR the last completed higher-timeframe close > its EMA of close) AND (pressure > positive threshold OR relative volume >= threshold).
Short: Signal cooldown is satisfied AND downward break AND close < EMA of close AND EMA of close < yearly anchored VWAP AND (higher-timeframe bias is disabled OR the last completed higher-timeframe close < its EMA of close) AND (pressure < negative threshold OR relative volume >= threshold).