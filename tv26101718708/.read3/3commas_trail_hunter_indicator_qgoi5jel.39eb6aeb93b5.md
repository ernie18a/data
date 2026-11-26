Calculation: Recent(X, K) = X[0] OR X[1] OR ... OR X[K], on chart bars
Calculation: MA cross-under = MA(close, shorter lookback, T1) crosses below MA(close, longer lookback, T1), where MA is SMA or EMA, evaluated on T1 bars and taking the value of the last completed T1 bar
Calculation: CCI cross-under = CCI(close, CCI length, T2) crosses below CCI threshold, evaluated on T2 bars and taking the value of the last completed T2 bar
Calculation: Peak = highest high from entry bar through current bar
Long: position side is flat AND combine mode is AND AND (MA cross signal not used OR Recent(MA cross-under, keep-alive bars)) AND (CCI signal not used OR Recent(CCI cross-under, keep-alive bars)) AND ((MA cross signal used AND MA cross-under[0]) OR (CCI signal used AND CCI cross-under[0]))
Long: position side is flat AND combine mode is OR AND (MA cross-under[0] OR CCI cross-under[0])
Exit: long, trailing enabled AND Peak >= entry price * (1 + take-profit %) AND low <= Peak * (1 - trailing deviation %)
Exit: long, NOT trailing enabled AND high >= entry price * (1 + take-profit %)
Exit: long, stop loss enabled AND low <= entry price * (1 - stop loss %)