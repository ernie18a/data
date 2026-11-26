Calculation: Raw return(c) = s(c) * LN(Q(c) / Q(c)[L]), where L = strength lookback, Q(c) = close of the exchange rate between currency c and USD, s(c) = +1 for EUR, GBP, AUD, NZD and -1 for JPY, CHF, CAD, and Raw return(USD) = 0
Calculation: Centered return(c) = Raw return(c) - [sum over all eight currencies k of trade weight(k) * Raw return(k)] / [sum over all eight currencies k of trade weight(k)]
Calculation: Strength(c) = EMA((Zs(A) + Zs(B) + Zs(C)) / 3, S), where X = Centered return(c), S = smoothing lookback, Z = z-score lookback, A = SMA(X, S), B = A / STDEV(X, Z), C = (X - SMA(X, Z)) / STDEV(X, Z), Zs(Y) = (Y - SMA(Y, Z)) / STDEV(Y, Z), and any quotient with a zero divisor is 0
Calculation: Haven risk-on = Strength(JPY) < -haven threshold AND Strength(CHF) < -haven threshold
Calculation: Haven risk-off = Strength(JPY) > haven threshold AND Strength(CHF) > haven threshold
Long: Haven risk-on AND the traded instrument includes no JPY
Long: Haven risk-on AND not Haven risk-on[1] AND the traded instrument includes no JPY
Short: Haven risk-off AND the traded instrument's quote currency is JPY
Short: Haven risk-off AND not Haven risk-off[1] AND the traded instrument's quote currency is JPY