Calculation: Confirmed pivot high or low = the high or low of a chart bar whose high or low qualifies as a Pine pivot using equal left and right lookbacks; it becomes available only after the right-side bars complete. Main and internal pivots use independent lookbacks, with the internal lookback shorter.
Calculation: Structure direction = initially bullish; process each confirmed main pivot high before any main pivot low on the same bar. If a pivot high exceeds the preceding main pivot high while direction is bearish, set direction to bullish when change-of-character detection is enabled. If a pivot low is less than or equal to the preceding main pivot low while direction is bullish, set direction to bearish when change-of-character detection is enabled. Update each preceding pivot after processing it.
Calculation: Higher-timeframe structure direction = initially bullish; on each newly confirmed higher-timeframe pivot, set direction to bullish if its high exceeds the preceding higher-timeframe pivot high, then set direction to bearish if its low is below the preceding higher-timeframe pivot low. Use the last completed higher-timeframe bar historically and the still-forming higher-timeframe bar in real time.
Long: Confirmed main pivot high > preceding main pivot high AND structure direction before processing the high = bullish AND break-of-structure detection enabled.
Long: Confirmed main pivot high > preceding main pivot high AND structure direction before processing the high = bearish AND change-of-character detection enabled.
Long: Confirmed main pivot low > preceding main pivot low AND structure direction after processing any main pivot high = bullish AND break-of-structure detection enabled.
Short: Confirmed main pivot high <= preceding main pivot high AND structure direction before processing the high = bearish AND break-of-structure detection enabled.
Short: Confirmed main pivot low <= preceding main pivot low AND structure direction after processing any main pivot high = bearish AND break-of-structure detection enabled.
Short: Confirmed main pivot low <= preceding main pivot low AND structure direction after processing any main pivot high = bullish AND change-of-character detection enabled.
Long: Confirmed internal pivot high > preceding internal pivot high AND structure direction after processing main pivots = bullish.
Short: Confirmed internal pivot low < preceding internal pivot low AND structure direction after processing main pivots = bearish.
Long: RSI crosses above its midpoint AND MACD histogram > 0.
Short: RSI crosses below its midpoint AND MACD histogram < 0.
Long: Close > open.
Short: Close <= open.
Long: Structure direction = bullish.
Short: Structure direction = bearish.
Long: Higher-timeframe structure direction = bullish AND higher-timeframe analysis enabled.
Short: Higher-timeframe structure direction = bearish AND higher-timeframe analysis enabled.
Long: RSI > upper momentum threshold.
Short: RSI <= lower momentum threshold.
Long: MACD histogram > 0.
Short: MACD histogram <= 0.