Calculation: Short-term SMMA = smoothed moving average of median price with a shorter lookback, on a higher timeframe than the chart, using the still-forming bar
Calculation: Long-term SMMA = smoothed moving average of median price with a longer lookback, on a higher timeframe than the chart, using the still-forming bar
Calculation: Exit distance = the greater of a minimum distance and the average high-low range over a lookback of completed bars on a higher timeframe than the chart
Long: sum of short-term SMMAs across the tracked instruments > sum of long-term SMMAs across the tracked instruments AND the current instrument's short-term SMMA > its long-term SMMA
Short: sum of short-term SMMAs across the tracked instruments < sum of long-term SMMAs across the tracked instruments AND the current instrument's short-term SMMA < its long-term SMMA
Exit: Long, current price > entry price + exit distance
Exit: Short, current price < entry price - exit distance