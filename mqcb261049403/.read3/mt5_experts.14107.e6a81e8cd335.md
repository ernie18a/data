Calculation: TriXCandle color = 2 when its calculated candle close > its calculated candle open, 0 when its calculated candle close < its calculated candle open, 1 when equal
Long: TriXCandle color(T1, last completed bar) = 2 AND TriXCandle color(T1, bar still forming) < 2
Short: TriXCandle color(T1, last completed bar) = 0 AND TriXCandle color(T1, bar still forming) > 0
Exit: long, TriXCandle color(T1, last completed bar) = 0
Exit: short, TriXCandle color(T1, last completed bar) = 2