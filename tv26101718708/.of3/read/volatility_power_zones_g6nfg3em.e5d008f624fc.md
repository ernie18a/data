Calculation: WVF = (Highest(high, lookback) - close) / max(Highest(high, lookback), minimum price increment) * 100
Calculation: WVF line = Lowest(low, same lookback) + EMA(WVF, same lookback) * Lowest(low, same lookback) / 100
Calculation: WVF upper zone = Lowest(low, same lookback) + EMA(WVF, same lookback) * upper multiplier * Lowest(low, same lookback) / 100
Calculation: WVF lower zone = Lowest(low, same lookback) + EMA(WVF, same lookback) * lower multiplier * Lowest(low, same lookback) / 100
Calculation: Omega Score = round(100 * (4 + (EMA(close, short lookback) > EMA(close, long lookback) ? 1 : -1) + (RSI(close, RSI lookback) > upper RSI threshold ? 1 : RSI(close, RSI lookback) < lower RSI threshold ? -1 : 0) + (close > WVF line ? 1 : -1) + (volume > SMA(volume, volume lookback) ? (close > open ? 1 : -1) : 0)) / 8)
Long: close > WVF line
Long: EMA(close, short lookback) > EMA(close, long lookback)
Long: RSI(close, RSI lookback) > upper RSI threshold
Long: volume > SMA(volume, volume lookback) AND close > open
Long: WVF line > WVF line[1]
Long: Omega Score >= upper Omega threshold
Long: PivotLow(low, left lookback, right lookback)
Long: close > WVF upper zone AND close[1] <= WVF upper zone[1]
Long: Omega Score >= upper Omega threshold AND Omega Score[1] < upper Omega threshold
Long: Omega Score >= upper Omega threshold AND close > WVF line
Short: close <= WVF line
Short: EMA(close, short lookback) <= EMA(close, long lookback)
Short: RSI(close, RSI lookback) < lower RSI threshold
Short: volume > SMA(volume, volume lookback) AND close <= open
Short: WVF line <= WVF line[1]
Short: Omega Score <= lower Omega threshold
Short: PivotHigh(high, left lookback, right lookback)
Short: close < WVF lower zone AND close[1] >= WVF lower zone[1]
Short: Omega Score <= lower Omega threshold AND Omega Score[1] > lower Omega threshold
Short: Omega Score <= lower Omega threshold AND close < WVF line