Calculation: M = Momentum(close, momentum lookback), calculated on T1 bars and read on chart bars at the selected signal bar (forming or last completed)
Calculation: A = moving average of M using a separate lookback, calculated on T1 bars and read on chart bars at the same selected signal bar
Calculation: total strategy position profit = sum of profit, commission, and swap across open positions in the traded instrument
Long: (signal reversal off AND M[1] < A[1] AND M > A AND M[1] < 100) OR (signal reversal on AND M[1] > A[1] AND M < A AND M[1] > 100)
Short: (signal reversal off AND M[1] > A[1] AND M < A AND M[1] > 100) OR (signal reversal on AND M[1] < A[1] AND M > A AND M[1] < 100)
Exit: long, (take-profit distance > 0 AND high >= entry price + take-profit distance) OR (money stop-loss amount > 0 AND total strategy position profit <= -money stop-loss amount)
Exit: short, (take-profit distance > 0 AND low <= entry price - take-profit distance) OR (money stop-loss amount > 0 AND total strategy position profit <= -money stop-loss amount)