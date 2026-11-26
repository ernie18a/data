Calculation: Failed 2D = bar closed AND low < low[1] AND high <= high[1] AND close > open
Calculation: Failed 2U = bar closed AND high > high[1] AND low >= low[1] AND close < open
Calculation: Strat up entry = high[1] + (failed-2 offset if Failed 2D[1], else trigger offset)
Calculation: Strat down entry = low[1] - (failed-2 offset if Failed 2U[1], else trigger offset)
Calculation: Long stop = low[1] - (failed-2 offset if Failed 2D[1], else trigger offset), fixed at entry
Calculation: Short stop = high[1] + (failed-2 offset if Failed 2U[1], else trigger offset), fixed at entry
Calculation: FTFC bullish = for every required timeframe Tk, close > open of the still-forming Tk bar, read on chart bars
Calculation: FTFC bearish = for every required timeframe Tk, close < open of the still-forming Tk bar, read on chart bars
Long: Failed 2D
Short: Failed 2U
Long: Strat entry mode AND high >= Strat up entry AND low > Strat down entry AND (NOT FTFC filter enabled OR FTFC bullish)
Short: Strat entry mode AND low <= Strat down entry AND high < Strat up entry AND (NOT FTFC filter enabled OR FTFC bearish)
Long: custom long mode AND low <= custom entry price AND high >= custom entry price
Short: custom short mode AND low <= custom entry price AND high >= custom entry price
Exit: long, high >= entry + target multiple * (entry - Long stop) OR low <= Long stop OR (bar closed AND bars since entry >= time limit)
Exit: short, low <= entry - target multiple * (Short stop - entry) OR high >= Short stop OR (bar closed AND bars since entry >= time limit)