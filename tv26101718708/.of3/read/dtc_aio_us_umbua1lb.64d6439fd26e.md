Calculation: relative strength = close / index close, computed on T1 bars and taken by chart bars using the T1 bar still forming
Long: relative strength > HIGHEST(relative strength[1], RS lookback)
Long: chart timeframe is T1 AND index close < EMA(index close, panic EMA length) AND close > EMA(close, panic EMA length)
Long: chart timeframe is T1 AND (close / close[1] - 1) * 100 >= up-move threshold AND volume >= minimum volume