Calculation: yVah = prior-day high - f1*(prior-day high - prior-day low); prior-day high/low come from the last completed bar of a higher (daily) timeframe, f1 is a fixed fraction well below 0.5
Calculation: yVal = prior-day low + f1*(prior-day high - prior-day low), using the same f1 and the same prior-day high/low
Calculation: macroVah = mx - f2*(mx - mn); mx and mn are the highest and lowest close over a long rolling lookback on chart-timeframe bars, including the current bar, and f2 is a fixed fraction well below 0.5
Calculation: macroVal = mn + f2*(mx - mn), using the same mx, mn and f2
Long: close > macroVah AND close > yVah
Short: close < macroVal AND close < yVal