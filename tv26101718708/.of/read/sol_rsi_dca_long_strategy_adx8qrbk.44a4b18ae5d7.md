Calculation: Cumulative averaging deviation(k) = sum of the first k deviation steps; the first step is d, and each next step is the previous step multiplied by a multiplier greater than 1
Calculation: Averaging-order price(k) = base entry price × (1 − cumulative averaging deviation(k) / 100)
Calculation: Take-profit price = running average entry price × (1 + take-profit percentage / 100)
Long: Position side = flat AND RSI(close, lookback) on the higher timeframe's last completed bar < entry threshold
Long: Position side = long AND averaging orders filled = k − 1 AND close ≤ averaging-order price(k), for each configured averaging order k
Exit: long, close ≥ take-profit price