Calculation: Shifted Donchian upper/lower bands = the rolling highest high minus / lowest low plus the channel range multiplied by the configured margin percentage, calculated the configured number of signal-timeframe bars before the evaluated bar
Long: Last completed signal-timeframe close > shifted upper Donchian band AND preceding completed signal-timeframe close <= its shifted upper Donchian band
Short: Last completed signal-timeframe close < shifted lower Donchian band AND preceding completed signal-timeframe close >= its shifted lower Donchian band
Exit: Short, last completed signal-timeframe close > shifted upper Donchian band
Exit: Long, last completed signal-timeframe close < shifted lower Donchian band