Calculation: MAEMA(src, L) = EMA(src + (m + 0.5*(m - m[n])) * c / p, L), where phi=(1+sqrt(5))/2, n=round(L/phi), m=src - src[n], p=L/phi^2, c=count of bars among the last round(p) bars where src > src[1]
Calculation: FastMA = MAEMA(high, L_fast); SlowMA = MAEMA(close, L_slow); L_fast < L_slow
Calculation: Basis = SMA(close, N); Dev = population stdev of close over N; InnerUpper = Basis + k1*Dev; BreakUpper = Basis + k2*Dev; BreakLower = Basis - k2*Dev; k2 > k1 > 0
Long: FastMA crosses above SlowMA AND hlc3 < InnerUpper
Long: low <= BreakLower
Short: SlowMA crosses above FastMA
Short: high >= BreakUpper
Exit: long, SlowMA crosses above FastMA (applies to a long opened by the cross entry)
Exit: long, high > FastMA (applies to a long opened by the BreakLower entry)