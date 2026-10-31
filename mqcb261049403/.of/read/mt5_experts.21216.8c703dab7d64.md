Calculation: Trend state = initially 0; set to -1 when Williams %R < -100 + threshold, then set to +1 when Williams %R > -threshold; otherwise retain the preceding state. Calculate on the chart timeframe for indicator markings or on a higher timeframe using the last completed bar for trading decisions.
Calculation: Double-smoothed average = apply a moving average to the selected OHLC-derived price, then apply a second moving average to the result; the two smoothing methods and lookbacks are independently configurable. Calculate on the chart timeframe for indicator markings or on a higher timeframe using the last completed bar for trading decisions.
Long: Trend state > 0
Short: Trend state < 0
Long: Double-smoothed average > its previous-bar value
Short: Double-smoothed average < its previous-bar value
Long: Last completed higher-timeframe trend state > 0 AND previous higher-timeframe trend state <= 0
Short: Last completed higher-timeframe trend state < 0 AND previous higher-timeframe trend state >= 0
Long: Last completed higher-timeframe double-smoothed average > its previous-bar value AND its previous-bar value <= its value two bars earlier
Short: Last completed higher-timeframe double-smoothed average < its previous-bar value AND its previous-bar value >= its value two bars earlier
Exit: long, last completed higher-timeframe trend state < 0
Exit: short, last completed higher-timeframe trend state > 0
Exit: long, last completed higher-timeframe double-smoothed average < its previous-bar value
Exit: short, last completed higher-timeframe double-smoothed average > its previous-bar value
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance