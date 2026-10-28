Calculation: MA1 = selected type of moving average of close on the chart timeframe or selected custom timeframe, using the same lookback as the baseline; custom-timeframe value uses the bar still forming
Calculation: Baseline = simple moving average of close using the same lookback as MA1
Calculation: MA2 = separately selected type of moving average of close on the chart timeframe or selected custom timeframe, using its own lookback; custom-timeframe value uses the bar still forming
Long: MA1 >= its value smoothe chart bars ago AND close > Baseline
Short: MA1 < its value smoothe chart bars ago AND close < Baseline
Exit: long, open > MA1 AND close < MA1
Exit: short, open < MA2 AND close > MA2