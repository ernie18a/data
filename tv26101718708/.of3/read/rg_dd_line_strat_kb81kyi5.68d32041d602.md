Calculation: UpperBreak = high > close[1] + TrueRange[1] AND close > open
Calculation: LowerBreak = low < close[1] - TrueRange[1] AND close < open
Long: rising(EMA(close, shorter EMA lookback), direction lookback)
Short: falling(EMA(close, shorter EMA lookback), direction lookback)
Long: rising(EMA(close, longer EMA lookback), direction lookback)
Short: falling(EMA(close, longer EMA lookback), direction lookback)
Long: UpperBreak AND datetime >= entry start datetime AND datetime < entry end datetime
Short: LowerBreak AND datetime >= entry start datetime AND datetime < entry end datetime
Exit: Long, (LowerBreak AND (datetime < entry start datetime OR datetime >= entry end datetime)) OR chart-bar crossunder(close of the still-forming T1 bar, open of the still-forming T1 bar) OR low <= entry price - stop-loss distance
Exit: Short, (UpperBreak AND (datetime < entry start datetime OR datetime >= entry end datetime)) OR chart-bar crossover(close of the still-forming T1 bar, open of the still-forming T1 bar) OR high >= entry price + stop-loss distance