Calculation: Direction = IF(EMA(close, lookback, T1, bar still forming) > EMA(close, lookback, T1, last completed bar), 1, IF(EMA(close, lookback, T1, bar still forming) < EMA(close, lookback, T1, last completed bar), -1, Direction[1]))
Long: Direction(T1, bar still forming) = 1
Short: Direction(T1, bar still forming) = -1