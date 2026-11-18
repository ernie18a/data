Calculation: Upper level = highest(high, shared lookback, T1, ending at the last completed bar)
Calculation: Upper inner level = second-highest(high, shared lookback, T1, ending at the last completed bar)
Calculation: Lower level = lowest(low, shared lookback, T1, ending at the last completed bar)
Calculation: Lower inner level = second-lowest(low, shared lookback, T1, ending at the last completed bar)
Long: close >= Upper level * (1 + entry offset / 100) AND flat AND chart-bar hour(datetime) <= entry cutoff hour
Short: close <= Lower level * (1 - entry offset / 100) AND flat AND chart-bar hour(datetime) <= entry cutoff hour
Exit: long, close < Upper inner level OR close > Upper level * (1 + (entry offset + profit target) / 100) OR chart-bar hour(datetime) = forced exit hour
Exit: short, close > Lower inner level OR close < Lower level * (1 - (entry offset + profit target) / 100) OR chart-bar hour(datetime) = forced exit hour