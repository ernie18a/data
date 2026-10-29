Calculation: Center = configured moving average of the configured OHLC-derived price on the configured indicator timeframe (higher, lower, or equal to the chart timeframe), using completed bars; its lookback is longer than the range-width lookback
Calculation: Range width = configured moving average of each bar's high minus low on the configured indicator timeframe, using completed bars
Calculation: Upper and lower bands = center plus and minus range width, respectively
Long: Close on the bar before the latest completed bar > upper band on that bar AND latest completed close <= upper band on the latest completed bar
Short: Close on the bar before the latest completed bar < lower band on that bar AND latest completed close >= lower band on the latest completed bar
Exit: short, close on the bar before the latest completed bar > upper band on that bar
Exit: long, close on the bar before the latest completed bar < lower band on that bar