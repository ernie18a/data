Calculation: Bezier curve B[t] = sum over i from 0 to smoothing period n of applied price[t-i] × binomial(n,i) × sensitivity^i × (1-sensitivity)^(n-i), with sensitivity constrained to the interval from zero to one. Applied price is a selectable OHLC-derived price: open, high, low, close, median, typical, weighted close, (open+close)/2, (open+high+low+close)/4, high if close > open otherwise low if close < open otherwise close, or (high+close)/2 if close > open otherwise (low+close)/2 if close < open otherwise close.
Calculation: Signal curve S = Bezier curve on a selectable timeframe that may be higher or lower than the chart timeframe, using a selectable signal bar that may be the last completed bar, an earlier completed bar, or the still-forming bar; S[1] and S[2] are its preceding bars.
Long: Chart-timeframe B[0] >= B[1]
Short: Chart-timeframe B[0] < B[1]
Long: S[0] > S[1] AND S[1] < S[2]
Short: S[0] < S[1] AND S[1] > S[2]
Exit: long, S[0] < S[1] OR low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, S[0] > S[1] OR high >= entry price + stop-loss distance OR low <= entry price - take-profit distance