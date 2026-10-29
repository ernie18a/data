Calculation: Trend = initially neutral; on each bar set it to bearish if Williams %R is below -100 + K, then set it to bullish if Williams %R is above -K; otherwise retain the previous trend. K is a risk-dependent threshold parameter.
Calculation: Double-smoothed average = a moving average of a selected bar price, followed by a second moving average with its own method and shorter lookback.
Long: Chart-timeframe trend is bullish.
Short: Chart-timeframe trend is bearish.
Long: Chart-timeframe double-smoothed average > its previous-bar value.
Short: Chart-timeframe double-smoothed average < its previous-bar value.
Long: On a separately selected higher or lower timeframe, trend on the signal bar is bullish AND trend on the preceding bar is not bullish; the signal bar is either the last completed bar or the still-forming bar, according to the signal-bar setting.
Short: On a separately selected higher or lower timeframe, trend on the signal bar is bearish AND trend on the preceding bar is not bearish; the signal bar is either the last completed bar or the still-forming bar, according to the signal-bar setting.
Long: On a separately selected higher or lower timeframe, the double-smoothed average on the signal bar > its preceding-bar value AND its preceding-bar value <= its value two bars before the signal bar; the signal bar is either the last completed bar or the still-forming bar, according to the signal-bar setting.
Short: On a separately selected higher or lower timeframe, the double-smoothed average on the signal bar < its preceding-bar value AND its preceding-bar value >= its value two bars before the signal bar; the signal bar is either the last completed bar or the still-forming bar, according to the signal-bar setting.
Exit: long, the trend on the selected signal bar of the trend system's higher or lower timeframe is bearish.
Exit: short, the trend on the selected signal bar of the trend system's higher or lower timeframe is bullish.
Exit: long, the double-smoothed average on the selected signal bar of the average system's higher or lower timeframe < its preceding-bar value.
Exit: short, the double-smoothed average on the selected signal bar of the average system's higher or lower timeframe > its preceding-bar value.
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance.
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance.