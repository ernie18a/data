Calculation: Weighted average entry price = lot-weighted average entry price of all open positions on the same side
Calculation: Add-on spacing = the range between the highest high and lowest low over a longer lookback of completed chart bars, divided by a parameter; clamp it between a minimum and maximum spacing
Long: No open position AND close two completed chart bars ago <= the last completed chart bar's close AND higher-timeframe RSI on its last completed bar < its upper threshold
Long: Existing long position AND trade count below its configured maximum AND current price <= last long entry price - add-on spacing
Short: No open position AND close two completed chart bars ago > the last completed chart bar's close AND higher-timeframe RSI on its last completed bar > its lower threshold
Short: Existing short position AND trade count below its configured maximum AND current price >= last short entry price + add-on spacing
Exit: Long, current price >= weighted average entry price + profit target distance
Exit: Short, current price <= weighted average entry price - profit target distance
Exit: Long, higher-timeframe CCI on the bar still forming > its upper threshold
Exit: Short, higher-timeframe CCI on the bar still forming < negative its upper threshold
Exit: Long, current price <= the trailing stop, set to current price minus the trailing distance once price reaches the trailing start distance above weighted average entry price; raise the stop only when this value exceeds the existing stop
Exit: Short, current price >= the trailing stop, set to current price plus the trailing distance once price reaches the trailing start distance below weighted average entry price; lower the stop only when this value is below the existing stop