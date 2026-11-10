Calculation: Confirmed pivot high/low = a high/low at the center of a chart-bar window with equal numbers of bars before and after it; it becomes available on the confirmation bar. Use separate lookbacks for price pivots and RSI pivots.
Calculation: Structural bias = initially neutral; set bullish when a confirmed price pivot high exceeds the preceding confirmed price pivot high, and bearish when a confirmed price pivot low is below the preceding confirmed price pivot low; otherwise retain the prior bias. If both updates occur on one bar, the low update takes precedence.
Calculation: Signal availability = initially false; set true whenever a price pivot high or low is confirmed, and set false after a continuation long or short signal.
Calculation: Higher-timeframe bias = initially neutral; on each chart bar, compare the last completed higher-timeframe high and low with their values on the preceding chart bar. Set bullish if both rise, bearish if both fall, and otherwise retain the prior bias. Calculate this independently for two higher timeframes, one longer than the other.
Long: Confirmed price pivot high > preceding confirmed price pivot high.
Short: Confirmed price pivot high <= preceding confirmed price pivot high.
Long: Confirmed price pivot low >= preceding confirmed price pivot low.
Short: Confirmed price pivot low < preceding confirmed price pivot low.
Long: Structural bias is bullish AND signal availability is true AND latest confirmed price pivot high and low exist AND low < latest confirmed price pivot high - retracement fraction * absolute difference between latest confirmed price pivot high and low AND close > open AND close > preceding chart-bar high.
Short: Structural bias is bearish AND signal availability is true AND latest confirmed price pivot high and low exist AND high > latest confirmed price pivot low + retracement fraction * absolute difference between latest confirmed price pivot high and low AND close < open AND close < preceding chart-bar low.
Long: Structural bias is bullish.
Short: Structural bias is bearish.
Long: An RSI pivot low is confirmed AND the price low at that pivot is below the price low at the preceding confirmed RSI pivot low AND RSI at that pivot is above RSI at the preceding confirmed RSI pivot low.
Short: An RSI pivot high is confirmed AND the price high at that pivot is above the price high at the preceding confirmed RSI pivot high AND RSI at that pivot is below RSI at the preceding confirmed RSI pivot high.
Long: Low < last completed higher-timeframe daily low AND close > last completed higher-timeframe daily low.
Short: High > last completed higher-timeframe daily high AND close < last completed higher-timeframe daily high.
Long: Either higher-timeframe bias is bullish.
Short: Either higher-timeframe bias is bearish or neutral.