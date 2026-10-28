Calculation: Long stop = previous bar's low
Calculation: Long target = upper Bollinger Band if current bar's high is at or above the Bollinger basis; otherwise the Bollinger basis
Calculation: Short stop = previous bar's high
Calculation: Short target = lower Bollinger Band if current bar's low is at or below the Bollinger basis; otherwise the Bollinger basis
Long: current bar is complete AND previous bar's high is below its lower Bollinger Band AND current close is above the lower Bollinger Band and below the upper Bollinger Band AND current low is above previous low AND current high is above previous high AND current close is above previous high AND RSI crosses above the oversold threshold AND short-term EMA is below long-term EMA AND (bar time is before the configured end-of-day cutoff OR the market is always on)
Short: current bar is complete AND previous bar's low is above its upper Bollinger Band AND current close is below the upper Bollinger Band and above the lower Bollinger Band AND current low is below previous low AND current high is below previous high AND current close is below previous low AND RSI crosses below the overbought threshold AND short-term EMA is above long-term EMA AND (bar time is before the configured end-of-day cutoff OR the market is always on)
Exit: long, close is at or above the long target OR close is at or below the long stop
Exit: short, close is at or below the short target OR close is at or above the short stop
Exit: long or short, market is not always on AND bar time is at or after the configured end-of-day cutoff