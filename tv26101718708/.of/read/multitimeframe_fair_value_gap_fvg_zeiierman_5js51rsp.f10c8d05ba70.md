Calculation: Source bars = chart-timeframe bars or bars aggregated to a selected higher or lower timeframe. With a higher timeframe, use the still-forming bar in real time and the final value of that bar on every constituent historical chart bar; with a lower timeframe, use the first lower-timeframe bar within each chart bar. Apply the same alignment to source-bar values from two source bars earlier.
Calculation: Body threshold = sensitivity parameter multiplied by the cumulative average of abs(close - open) across source bars, including the current source bar.
Calculation: Bullish gap condition = source low > source high two source bars earlier AND source close > source high two source bars earlier.
Calculation: Bearish gap condition = source high < source low two source bars earlier AND source close < source low two source bars earlier.
Calculation: Bullish gap event = bullish gap condition AND NOT bullish gap condition on the preceding chart bar AND source abs(close - open) >= body threshold.
Calculation: Bearish gap event = bearish gap condition AND NOT bearish gap condition on the preceding chart bar AND source abs(close - open) >= body threshold.
Calculation: Gap trend value = initially zero; on a bullish or bearish gap event, replace it with the average of its previous value and chart-bar OHLC4; otherwise retain its previous value.
Calculation: Active gap = a bullish gap event creates a gap from source high two source bars earlier to source low; a bearish gap event creates a gap from source high to source low two source bars earlier. On every chart bar, remove a bullish gap when chart low <= its midpoint or, under the alternative mitigation setting, <= its bottom; remove a bearish gap when chart high >= its midpoint or, under the alternative mitigation setting, >= its top.
Long: bullish gap event
Short: bearish gap event
Long: gap trend value > its preceding chart-bar value
Short: gap trend value < its preceding chart-bar value
Long: chart close >= bottom of an active gap
Short: chart close < bottom of an active gap