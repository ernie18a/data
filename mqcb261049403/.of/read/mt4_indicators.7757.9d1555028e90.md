Calculation: PrevH, PrevL, PrevC = high, low, close of the last completed bar of a higher timeframe (previous day), held constant for the whole current day
Calculation: Range = PrevH - PrevL
Calculation: H3 = PrevC + a*Range; L3 = PrevC - a*Range; H4 = PrevC + b*Range; L4 = PrevC - b*Range (a, b are fixed fractions, with b > a, so H4/L4 lie farther from PrevC than H3/L3)
Calculation: H5 = PrevC * PrevH / PrevL; L5 = 2*PrevC - H5
Calculation: Near(level) = abs(close - level) <= fixed price distance d, and the signal fires only once per approach (re-armed after close has been farther than d from the level on both sides)
Long: Near(L3) AND close >= L3 (touch of the lower level, mean-reversion long) OR close > H4 (upside breakout)
Short: Near(H3) AND close <= H3 (touch of the upper level, mean-reversion short) OR close < L4 (downside breakout)
Exit: long, high >= H5
Exit: short, low <= L5