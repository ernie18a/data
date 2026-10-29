Calculation: CCI = CCI of weighted price on the current chart-timeframe bar
Calculation: Stochastic main line = main line of the stochastic oscillator on the current chart-timeframe bar
Calculation: Weighted moving average = linear weighted moving average of typical price, evaluated on a completed chart-timeframe bar
Long: CCI < lower CCI threshold AND Stochastic main line < lower stochastic threshold AND previous completed bar open > weighted moving average
Short: CCI > upper CCI threshold AND Stochastic main line > upper stochastic threshold AND previous completed bar close < weighted moving average
Exit: Long, CCI > upper CCI threshold AND Stochastic main line > upper stochastic threshold AND previous completed bar close < weighted moving average OR low <= entry price minus stop-loss distance OR high >= entry price plus take-profit distance
Exit: Short, CCI < lower CCI threshold AND Stochastic main line < lower stochastic threshold AND previous completed bar open > weighted moving average OR high >= entry price plus stop-loss distance OR low <= entry price minus take-profit distance