Calculation: VAH = volume-profile value-area high(lookback chart bars including the forming bar, bin sizing mode, target bin count, price-bin percentage, fixed-bin tick count, value-area percentage)
Calculation: VAL = volume-profile value-area low(lookback chart bars including the forming bar, bin sizing mode, target bin count, price-bin percentage, fixed-bin tick count, value-area percentage)
Calculation: T1Bin = fixed-bin tick count × tick size in fixed-tick mode; otherwise ATR(ATR lookback, T1, last completed bar) / ATR divisor, falling back to chart close × fallback fraction when ATR is unavailable; rounded to tick size and held for the T1 session
Calculation: POC[k] = volume-profile point of control of the kth most recently completed T1 session, built from chart bars using that session’s bin size
Long: close > VAH
Short: close < VAL
Long: max(abs(POC[0] - POC[1]), abs(POC[1] - POC[2])) > T1Bin × flatness-threshold multiplier AND POC[0] > POC[2]
Short: max(abs(POC[0] - POC[1]), abs(POC[1] - POC[2])) > T1Bin × flatness-threshold multiplier AND POC[0] <= POC[2]