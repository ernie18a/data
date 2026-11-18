Calculation: Mansfield RS = ((close / close(T1, last completed bar historically or still-forming bar in real time) * 100) / SMA(close / close(T1, last completed bar historically or still-forming bar in real time) * 100, RS lookback on chart bars) - 1) * 100, evaluated on chart bars
Calculation: RS momentum angle = atan((Mansfield RS - Mansfield RS[range lookback chart bars ago]) / range lookback), evaluated on chart bars
Long: Mansfield RS > 0
Short: Mansfield RS <= 0
Long: Mansfield RS crosses above 0
Short: Mansfield RS crosses below 0
Long: RS momentum angle > 0
Short: RS momentum angle <= 0
Long: RS momentum angle > 0 AND RS momentum angle on the previous chart bar <= 0
Short: RS momentum angle < 0 AND RS momentum angle on the previous chart bar >= 0
Long: SMA(close, price confirmation lookback) is rising over trend lookback AND close >= SMA(close, price confirmation lookback)
Short: SMA(close, price confirmation lookback) is falling over trend lookback AND close < SMA(close, price confirmation lookback)