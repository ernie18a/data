Calculation: Smoothed high = selected moving average of high over a lookback on the configured indicator timeframe, which may be higher or lower than the chart timeframe
Calculation: Smoothed low = selected moving average of low over the same lookback and using the same method on the configured indicator timeframe, which may be higher or lower than the chart timeframe
Long: Current completed indicator-timeframe bar close >= Smoothed low AND previous completed indicator-timeframe bar close < Smoothed low
Short: Current completed indicator-timeframe bar close < Smoothed low AND previous completed indicator-timeframe bar close >= Smoothed low
Exit: Long, current completed indicator-timeframe bar close < Smoothed low
Exit: Short, current completed indicator-timeframe bar close >= Smoothed low