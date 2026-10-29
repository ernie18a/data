Calculation: Dynamic POC = HL2 of the most recent bar with the highest volume in the rolling lookback
Calculation: Stochastic RSI %K = the stochastic value of RSI(close), smoothed with a simple moving average
Calculation: Long stop at entry signal = prior bar low − ATR × multiplier, fixed from the signal bar
Calculation: Short stop at entry signal = prior bar high + ATR × multiplier, fixed from the signal bar
Long: shorter-lookback EMA > longer-lookback EMA AND close > Dynamic POC AND Stochastic RSI %K > oversold level AND prior bar's %K <= oversold level
Short: shorter-lookback EMA < longer-lookback EMA AND close < Dynamic POC AND Stochastic RSI %K < overbought level AND prior bar's %K >= overbought level
Exit: Long, low <= long stop
Exit: Short, high >= short stop