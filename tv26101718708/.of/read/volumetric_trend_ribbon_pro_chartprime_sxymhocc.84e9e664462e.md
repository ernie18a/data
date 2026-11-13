Calculation: VWMA(x) = sum(x*volume over lookback N) / sum(volume over lookback N)
Calculation: base = EMA(VWMA(close), smoothing length), where the EMA length is shorter than N
Calculation: vwsd = sqrt(VWMA((close - base)^2)) using the same N as the VWMA above
Calculation: upper = base + m*vwsd; lower = base - m*vwsd; width = upper - lower (m is a positive multiplier)
Calculation: uptrend = base > previous bar's base AND close > base; downtrend = base < previous bar's base AND close < base
Calculation: longTarget = upper + t*width, taken on the bar of the latest Long breakout and held fixed afterwards; shortTarget = lower - t*width, taken on the bar of the latest Short breakout and held fixed afterwards (t is a positive multiplier). A target is discarded once it is hit or when neither uptrend nor downtrend holds (neutral).
Long: uptrend
Long: close crosses above upper (previous close <= previous upper AND close > upper) AND uptrend
Short: downtrend
Short: close crosses below lower (previous close >= previous lower AND close < lower) AND downtrend
Exit: long, a longTarget is active AND high > longTarget
Exit: short, a shortTarget is active AND low < shortTarget