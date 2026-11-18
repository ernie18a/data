Calculation: Upper grid = max(EMA(close, fast lookback, T1), EMA(close, slow lookback, T1))
Calculation: Lower grid = min(EMA(close, fast lookback, T1), EMA(close, slow lookback, T1))
Long: EMA(close, fast lookback, T1) > EMA(close, slow lookback, T1) AND (close > Upper grid OR (close >= Lower grid AND close <= Upper grid AND close >= open))
Short: EMA(close, fast lookback, T1) < EMA(close, slow lookback, T1) AND (close < Lower grid OR (close >= Lower grid AND close <= Upper grid AND close < open))