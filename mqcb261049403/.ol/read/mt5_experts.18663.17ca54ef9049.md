Calculation: Fast EMA = EMA of close on the higher timeframe with a shorter lookback than the slow EMA; use the bar still forming.
Calculation: Slow EMA = EMA of close on the higher timeframe with a longer lookback than the fast EMA; use the bar still forming.
Calculation: Highest high = highest high across the lookback of completed chart-timeframe bars, excluding the current bar.
Calculation: Lowest low = lowest low across the lookback of completed chart-timeframe bars, excluding the current bar.
Long: Fast EMA > slow EMA AND current Williams %R on the lower timeframe > -80 AND previous completed bar's Williams %R on the lower timeframe < -80 AND CCI on the chart timeframe < buy level AND open position count < maximum open positions
Short: Fast EMA < slow EMA AND current Williams %R on the lower timeframe < -20 AND previous completed bar's Williams %R on the lower timeframe > -20 AND previous completed bar's Williams %R on the lower timeframe < 0 AND CCI on the chart timeframe > sell level AND open position count < maximum open positions
Exit: Long, low < lowest low OR low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: Short, high > highest high OR high >= entry price + stop-loss distance OR low <= entry price - take-profit distance