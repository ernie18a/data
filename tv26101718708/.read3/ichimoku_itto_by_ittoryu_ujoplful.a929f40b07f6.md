Calculation: Kumo top = max(Senkou Span A(high, low, short length, medium length)[displacement - 1], Senkou Span B(high, low, long length)[displacement - 1])
Calculation: Kumo bottom = min(Senkou Span A(high, low, short length, medium length)[displacement - 1], Senkou Span B(high, low, long length)[displacement - 1])
Calculation: Cloud check = (close > Kumo top) - (close < Kumo bottom)
Calculation: TK check = (Tenkan(high, low, short length) > Kijun(high, low, medium length)) - (Tenkan(high, low, short length) < Kijun(high, low, medium length))
Calculation: Chikou check = (close > high[displacement - 1]) - (close < low[displacement - 1])
Calculation: Future cloud check = (Senkou Span A(high, low, short length, medium length) > Senkou Span B(high, low, long length)) - (Senkou Span A(high, low, short length, medium length) < Senkou Span B(high, low, long length))
Calculation: Tally = Cloud check + TK check + Chikou check + Future cloud check + (Kijun(high, low, medium length) > Kijun(high, low, medium length)[slope lookback]) - (Kijun(high, low, medium length) < Kijun(high, low, medium length)[slope lookback])
Calculation: Chop zone = (close >= Kumo bottom AND close <= Kumo top) OR abs(Tally) <= chop band
Calculation: Aligned state = (Cloud check + TK check + Chikou check = 3) - (Cloud check + TK check + Chikou check = -3)
Long: Tally >= strong threshold AND Tally[1] < strong threshold AND NOT Chop zone
Short: Tally <= -strong threshold AND Tally[1] > -strong threshold AND NOT Chop zone
Long: Aligned state = 1 AND Aligned state[1] != 1
Short: Aligned state = -1 AND Aligned state[1] != -1
Long: Tally > 0 AND NOT Chop zone
Short: Tally < 0 AND NOT Chop zone
Long: Future cloud check = 1
Short: Future cloud check <= 0
Long: Aligned state(T1 bars, last completed bar) = 1
Long: Aligned state(T2 bars, last completed bar) = 1
Long: Aligned state(T3 bars, last completed bar) = 1
Long: Aligned state(T4 bars, last completed bar) = 1
Short: Aligned state(T1 bars, last completed bar) = -1
Short: Aligned state(T2 bars, last completed bar) = -1
Short: Aligned state(T3 bars, last completed bar) = -1
Short: Aligned state(T4 bars, last completed bar) = -1