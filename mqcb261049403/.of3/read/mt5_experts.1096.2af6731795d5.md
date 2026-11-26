Calculation: H = MACD histogram(close, shorter lookback, longer lookback, signal lookback)
Calculation: M = MACD(close, shorter lookback, longer lookback)
Calculation: S = MACD signal line(close, shorter lookback, longer lookback, signal lookback)
Long: H(current chart bar) > 0
Short: H(current chart bar) < 0
Long: H(current chart bar) > S(previous chart bar)
Short: H(current chart bar) < S(previous chart bar)
Long: on chart bars using T1 values, H(T1, last completed bar) > 0 AND H(T1, bar still forming) <= 0
Short: on chart bars using T1 values, H(T1, last completed bar) < 0 AND H(T1, bar still forming) >= 0
Long: on chart bars using T1 values, H(T1, last completed bar) < H(T1, two completed bars ago) AND H(T1, bar still forming) > H(T1, last completed bar)
Short: on chart bars using T1 values, H(T1, last completed bar) > H(T1, two completed bars ago) AND H(T1, bar still forming) < H(T1, last completed bar)
Long: on chart bars using T1 values, S(T1, last completed bar) < S(T1, two completed bars ago) AND S(T1, bar still forming) > S(T1, last completed bar)
Short: on chart bars using T1 values, S(T1, last completed bar) > S(T1, two completed bars ago) AND S(T1, bar still forming) < S(T1, last completed bar)
Long: on chart bars using T1 values, M(T1, last completed bar) > S(T1, last completed bar) AND M(T1, bar still forming) <= S(T1, bar still forming)
Short: on chart bars using T1 values, M(T1, last completed bar) < S(T1, last completed bar) AND M(T1, bar still forming) >= S(T1, bar still forming)
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance