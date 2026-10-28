Calculation: Strong candle = absolute(close − open) / max(high − low, minimum price increment) ≥ configured minimum body fraction
Calculation: Bullish trend = previous completed daily, 4-hour, and 1-hour closes each exceed their respective preceding completed closes
Calculation: Bearish trend = previous completed daily, 4-hour, and 1-hour closes each are below their respective preceding completed closes
Calculation: Bullish structure = previous completed 1-hour and 4-hour closes each exceed the prior configured-lookback highest high, calculated through the second-most-recent bar
Calculation: Bearish structure = previous completed 1-hour and 4-hour closes each are below the prior configured-lookback lowest low, calculated through the second-most-recent bar
Calculation: Ranging = either the last three completed 4-hour highs have two consecutive differences each smaller than the configured tolerance, or their last three lows do
Calculation: Session = within an enabled NY, NY lunch, London, or Asia session
Calculation: ICC range = high and low of the configured earlier completed bar on the configured ICC timeframe; midpoint = (high + low) / 2
Calculation: Strong bullish BOS state = close crosses above the highest high of the preceding configured number of chart bars; remains active until invalidated by a close sufficiently below the broken level or replaced by bearish BOS
Calculation: Strong bearish BOS state = close crosses below the lowest low of the preceding configured number of chart bars; remains active until invalidated by a close sufficiently above the broken level or replaced by bullish BOS
Calculation: Bullish fair value gap = current low is above the high from two chart bars earlier; bearish fair value gap = current high is below the low from two chart bars earlier
Calculation: Strong bullish BOS retest = active bullish BOS level is within configured tolerance of the bar's low and close, or an active bullish fair value gap is touched and closed above its lower boundary; also requires close > open and a strong candle
Calculation: Strong bearish BOS retest = active bearish BOS level is within configured tolerance of the bar's high and close, or an active bearish fair value gap is touched and closed below its upper boundary; also requires close < open and a strong candle
Calculation: Opening range = high and low of the configured NY or Asia opening window, finalized when that window ends
Long: Entry chart timeframe is configured for entries AND session AND NOT ranging AND bullish trend AND bullish structure AND (low ≤ ICC range low + configured tolerance AND close < ICC midpoint AND close > open AND strong candle OR strong bullish BOS retest)
Short: Entry chart timeframe is configured for entries AND session AND NOT ranging AND bearish trend AND bearish structure AND (high ≥ ICC range high − configured tolerance AND close > ICC midpoint AND close < open AND strong candle OR strong bearish BOS retest)
Long: close crosses above the finalized NY or Asia opening range high
Short: close crosses below the finalized NY or Asia opening range low
Long: On the configured accumulation timeframe, after the configured initial bars of the day, a low sweeps below the accumulation low, then close > accumulation low AND close > open AND strong candle
Short: On the configured accumulation timeframe, after the configured initial bars of the day, a high sweeps above the accumulation high, then close < accumulation high AND close < open AND strong candle
Long: During London or NY, on the configured AMD timeframe, low < Asia session low − configured sweep tolerance, then close > Asia session low AND close > open AND strong candle
Short: During London or NY, on the configured AMD timeframe, high > Asia session high + configured sweep tolerance, then close < Asia session high AND close < open AND strong candle
Long: Bullish trend AND close crosses above the preceding configured-lookback chart-bar highest high
Short: Bearish trend AND close crosses below the preceding configured-lookback chart-bar lowest low
Long: A confirmed 1-hour swing high exceeds the preceding confirmed 1-hour swing high OR a confirmed 1-hour swing low exceeds the preceding confirmed 1-hour swing low
Short: A confirmed 1-hour swing high is below the preceding confirmed 1-hour swing high OR a confirmed 1-hour swing low is below the preceding confirmed 1-hour swing low