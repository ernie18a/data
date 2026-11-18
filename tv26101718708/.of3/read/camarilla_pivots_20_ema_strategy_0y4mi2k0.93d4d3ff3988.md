Calculation: H4 = Camarilla H4(high(T1, last completed bar), low(T1, last completed bar), close(T1, last completed bar)), carried onto chart bars
Calculation: H3 = Camarilla H3(high(T1, last completed bar), low(T1, last completed bar), close(T1, last completed bar)), carried onto chart bars
Calculation: L3 = Camarilla L3(high(T1, last completed bar), low(T1, last completed bar), close(T1, last completed bar)), carried onto chart bars
Calculation: L4 = Camarilla L4(high(T1, last completed bar), low(T1, last completed bar), close(T1, last completed bar)), carried onto chart bars
Long: close > H4 AND close > EMA(close, lookback) AND close[1] <= H4
Short: close < L4 AND close < EMA(close, lookback) AND close[1] >= L4
Exit: long, low <= H3 captured at entry OR high >= entry price + (entry price - H3 captured at entry) * risk/reward ratio
Exit: short, high >= L3 captured at entry OR low <= entry price - (L3 captured at entry - entry price) * risk/reward ratio