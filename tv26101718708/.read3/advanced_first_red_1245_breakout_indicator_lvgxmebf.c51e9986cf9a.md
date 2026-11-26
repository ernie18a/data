Calculation: Opening T1 candle high/low = its wick high/low (on T1 bars; chart bars take the value from the current T1 bar)
Calculation: First red midpoint = midpoint of the first T1 bar each trading day with close < open (on T1 bars; chart bars take the value from the current T1 bar)
Calculation: Designated T2 candle midpoint = midpoint of the designated T2 bar (on T2 bars; chart bars take the value from the current T2 bar)
Calculation: Reference high/low = wick high/low or max(open, close)/min(open, close) of the selected reference candle, which is either the first red T1 candle of the trading day or the designated T2 candle
Calculation: Gap midpoint = prior completed T3 close + half the difference between current-day open and prior completed T3 close (chart bars use the prior completed T3 bar)
Long: close crosses above opening T1 candle high
Short: close crosses below opening T1 candle low
Long: selected reference candle exists AND close crosses above reference high AND (trend filter disabled OR close > EMA(close, lookback)) AND strategy bias since the start of the trading day is not long
Short: selected reference candle exists AND close crosses below reference low AND (trend filter disabled OR close < EMA(close, lookback)) AND strategy bias since the start of the trading day is not short
Long: first red midpoint exists AND close > first red midpoint
Short: first red midpoint exists AND close <= first red midpoint
Long: first red midpoint exists AND close crosses above first red midpoint
Short: first red midpoint exists AND close crosses below first red midpoint
Long: designated T2 candle midpoint exists AND close > designated T2 candle midpoint
Short: designated T2 candle midpoint exists AND close <= designated T2 candle midpoint
Long: designated T2 candle midpoint exists AND close crosses above designated T2 candle midpoint
Short: designated T2 candle midpoint exists AND close crosses below designated T2 candle midpoint
Long: current-day open > prior completed T3 close
Short: current-day open < prior completed T3 close
Long: close crosses above gap midpoint
Short: close crosses below gap midpoint