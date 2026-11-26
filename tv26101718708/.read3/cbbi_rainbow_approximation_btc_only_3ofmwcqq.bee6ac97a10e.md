Calculation: Requested T1 values = close, SMA(close, Mayer SMA lookback), SMA(close, shorter Pi SMA lookback), SMA(close, longer shared SMA lookback), WMA(close, WMA lookback), RSI(close, RSI lookback), and bar time, calculated on T1 bars and requested on chart bars with lookahead off (last completed T1 bar on historical chart bars; still-forming T1 bar on realtime chart bars).
Calculation: Mayer ratio score = clamp(((T1 close / T1 Mayer SMA) - Mayer lower ratio) / (Mayer upper ratio - Mayer lower ratio) * score scale, score floor, score ceiling)
Calculation: Pi ratio score = clamp(T1 shorter Pi SMA / (Pi denominator multiplier * T1 longer shared SMA) * score scale, score floor, score ceiling)
Calculation: WMA multiple score = clamp(((T1 close / T1 WMA) - WMA lower multiple) / (WMA upper multiple - WMA lower multiple) * score scale, score floor, score ceiling)
Calculation: Growth ratio score = clamp(((T1 close / T1 longer shared SMA) - growth lower multiple) / (growth upper multiple - growth lower multiple) * score scale, score floor, score ceiling)
Calculation: RSI score = clamp((T1 RSI - RSI lower bound) / (RSI upper bound - RSI lower bound) * score scale, score floor, score ceiling)
Calculation: Regression proxy score = clamp(((T1 close / 10^(regression intercept + regression exponent * log10(max(days since reference date from T1 bar time, minimum elapsed days)))) - proxy lower bound) / (proxy upper bound - proxy lower bound) * score scale, score floor, score ceiling)
Calculation: Composite score = SMA(average of the available nonmissing Mayer ratio, Pi ratio, WMA multiple, growth ratio, RSI, and regression proxy scores, smoothing lookback on chart bars)
Long: Composite score crosses below bottom threshold
Short: Composite score crosses above top threshold