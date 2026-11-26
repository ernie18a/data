Calculation: basket profit = sum(open position profit + swap + commission)
Calculation: weighted entry price sum = sum(open position entry price × position size)
Long: no open position AND on each new chart bar, SMA(close, shorter lookback, chart timeframe, last completed bar) > SMA(close, longer lookback, chart timeframe, last completed bar) AND MACD(close, MACD fast lookback, MACD slow lookback, MACD signal lookback, T1, last completed bar) main line is nonzero and below its signal line, sampled on chart bars
Short: no open position AND on each new chart bar, SMA(close, shorter lookback, chart timeframe, last completed bar) < SMA(close, longer lookback, chart timeframe, last completed bar) AND MACD(close, MACD fast lookback, MACD slow lookback, MACD signal lookback, T1, last completed bar) main line is nonzero and above its signal line, sampled on chart bars
Long: an open long position AND on each new chart bar, current bid ≤ lowest long entry price − spread − step distance
Short: an open short position AND on each new chart bar, current ask ≥ highest short entry price + spread + step distance
Exit: long, current bid ≥ lowest long entry price + profit target distance
Exit: short, current ask ≤ highest short entry price − profit target distance
Exit: long, maximum-order closing is enabled AND (long position count = maximum trade count OR total open position count for the traded instrument > maximum trade count)
Exit: short, maximum-order closing is enabled AND (short position count = maximum trade count OR total open position count for the traded instrument > maximum trade count)
Exit: long, basket profit ≤ −account balance × hard-stop loss percentage / 100
Exit: short, basket profit ≤ −account balance × hard-stop loss percentage / 100
Exit: long, basket profit ≤ −account balance × basket-loss percentage / 100 AND open trade count ≥ minimum loss-close trade count
Exit: short, basket profit ≤ −account balance × basket-loss percentage / 100 AND open trade count ≥ minimum loss-close trade count
Exit: long, trailing stop is enabled AND round((current bid − weighted entry price sum) / pip size) ≥ trail-start distance AND current bid ≤ highest bid since this condition first became true − trail distance
Exit: short, trailing stop is enabled AND round((weighted entry price sum + current ask) / pip size) ≥ trail-start distance AND current ask ≥ lowest ask since this condition first became true + trail distance