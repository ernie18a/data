Calculation: Band center = EMA(average(VWMA(highest(high, trend lookback), trend lookback), VWMA(lowest(low, trend lookback), trend lookback)), trend lookback)
Calculation: Smoothed range = SMA(VWMA(highest(high, trend lookback), trend lookback) - VWMA(lowest(low, trend lookback), trend lookback), trend lookback)
Calculation: Volume-adjusted center = VWMA(Band center * (volume / VWMA(volume, trend lookback)), volume smoothing lookback)
Calculation: Inner upper band = Band center + RSI(Volume-adjusted center, trend lookback) * 0.01 * Smoothed range
Calculation: Inner lower band = Band center - RSI(Volume-adjusted center, trend lookback) * 0.01 * Smoothed range
Calculation: Basis = average(Inner upper band, Inner lower band)
Calculation: Outer upper band = Inner upper band * (1 + stop-loss percentage / 100)
Calculation: Outer lower band = Inner lower band * (1 - stop-loss percentage / 100)
Calculation: Long availability = true when purchase source crosses below Inner upper band, or when reset mode is Entry and purchase source crosses below Inner lower band, or when reset mode is Stop Loss and exit source crosses below Outer lower band; otherwise false when purchase source crosses above Inner lower band and prior long availability is true; otherwise the prior value; initially false
Calculation: Short availability = true when purchase source crosses above Inner lower band, or when reset mode is Entry and purchase source crosses above Inner upper band, or when reset mode is Stop Loss and exit source crosses above Outer upper band; otherwise false when purchase source crosses below Inner upper band and prior short availability is true; otherwise the prior value; initially false
Calculation: Long take-profit availability = true when exit source crosses above Basis; otherwise false when exit source crosses above Inner upper band; otherwise the prior value; initially false
Calculation: Short take-profit availability = true when exit source crosses below Basis; otherwise false when exit source crosses below Inner lower band; otherwise the prior value; initially false
Long: purchase source crosses above Inner lower band AND prior long availability is true
Short: purchase source crosses below Inner upper band AND prior short availability is true
Exit: Long, exit source crosses above Inner upper band OR (stop-loss enabled AND exit source crosses below Outer lower band) OR (take-profit enabled AND exit source crosses below Basis AND long take-profit availability is true)
Exit: Short, exit source crosses below Inner lower band OR (stop-loss enabled AND exit source crosses above Outer upper band) OR (take-profit enabled AND exit source crosses above Basis AND short take-profit availability is true)