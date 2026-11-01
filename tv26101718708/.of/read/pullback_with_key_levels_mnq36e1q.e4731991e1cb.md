Calculation: Requested-bar OHLC = OHLC of the previous completed bar of a selected higher or lower timeframe, sampled onto each chart bar; when the timeframe is lower, use the last available lower-timeframe bar. The preceding sample is the value on the preceding chart bar.
Calculation: Bullish reversal level = the open of the first bearish bar in the latest bearish run; doji bars continue the preceding run. Replace any unbroken level when a new bearish run starts, and remove it when close exceeds it.
Calculation: Bearish reversal level = the open of the first bullish bar in the latest bullish run; doji bars continue the preceding run. Replace any unbroken level when a new bullish run starts, and remove it when close falls below it.
Calculation: Active bullish gap = a chart-bar range from high two bars ago to the current low when low exceeds high two bars ago. Remove it when close falls below its lower boundary; retain at most a configurable number of the most recently created active bullish and bearish gaps combined.
Calculation: Active bearish gap = a chart-bar range from the current high to low two bars ago when high is below low two bars ago. Remove it when close exceeds its upper boundary; retain at most a configurable number of the most recently created active bullish and bearish gaps combined.
Calculation: Swept previous-day low = the current or an earlier chart bar in the current day has low below the previous completed day's low; reset at the start of each day and after each long sweep decision. The day timeframe may be higher or lower than the chart timeframe.
Calculation: Swept previous-day high = the current or an earlier chart bar in the current day has high above the previous completed day's high; reset at the start of each day and after each short sweep decision. The day timeframe may be higher or lower than the chart timeframe.
Long: Shorter-period EMA of close > longer-period EMA of close on the chart timeframe or on a selected higher or lower timeframe; for historical higher-timeframe bars use the last completed bar, and for lower-timeframe bars use the last available completed bar.
Short: Shorter-period EMA of close <= longer-period EMA of close on the chart timeframe or on a selected higher or lower timeframe; for historical higher-timeframe bars use the last completed bar, and for lower-timeframe bars use the last available completed bar.
Long: Close crosses above the shorter-period EMA of close.
Short: Close crosses below the shorter-period EMA of close.
Long: Shorter-period EMA of close crosses above longer-period EMA of close.
Short: Shorter-period EMA of close crosses below longer-period EMA of close.
Long: Swept previous-day low = true AND close > previous completed day's low.
Short: Swept previous-day high = true AND close < previous completed day's high.
Long: Close > bullish reversal level.
Short: Close < bearish reversal level.
Long: Low > high two chart bars ago.
Short: High < low two chart bars ago.
Long: Close > upper boundary of an active bearish gap.
Short: Close < lower boundary of an active bullish gap.
Long: Requested-bar close > requested-bar open AND preceding sampled close <= preceding sampled open AND absolute requested-bar body / absolute preceding sampled body >= a configurable threshold AND preceding sampled close <= requested-bar close AND preceding sampled open >= requested-bar open.
Short: Requested-bar close < requested-bar open AND preceding sampled close >= preceding sampled open AND absolute requested-bar body / absolute preceding sampled body >= a configurable threshold AND preceding sampled close >= requested-bar close AND preceding sampled open <= requested-bar open.