Calculation: Yesterday’s high = high of the last completed bar of a higher timeframe (daily)
Calculation: Yesterday’s low = low of the last completed bar of a higher timeframe (daily)
Calculation: 2:30 high = highest high of chart-timeframe bars from 14:25 through 14:29
Calculation: 2:35 high = highest high of chart-timeframe bars from 14:30 through 14:34
Calculation: 2:35 low = lowest low of chart-timeframe bars from 14:30 through 14:34
Long: time is after 14:35 AND (previous close <= 2:30 high AND close > 2:30 high OR previous close <= 2:35 high AND close > 2:35 high)
Short: time is after 14:35 AND previous close >= 2:35 low AND close < 2:35 low
Exit: long, close < 2:35 low
Exit: short, close > 2:35 high