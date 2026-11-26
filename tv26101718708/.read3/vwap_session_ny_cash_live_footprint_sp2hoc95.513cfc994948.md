Calculation: session VWAP = VWAP(hlc3, volume, session, T1 intrabars accumulated on chart bars through the current bar, including the T1 bar still forming)
Long: crossover(close, session VWAP)[1] AND close[1] > open[1] AND close > open
Short: crossunder(close, session VWAP)[1] AND close[1] < open[1] AND close < open