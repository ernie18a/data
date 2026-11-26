Calculation: Leading Span A = (Conversion Line(conversion lookback) + Base Line(base lookback)) / 2
Calculation: Leading Span B = (highest(high, span B lookback) + lowest(low, span B lookback)) / 2
Long: longs are enabled AND position is flat AND close > max(Leading Span A, Leading Span B) AND Leading Span A > Leading Span B AND close > SMA(close, HTF lookback, T1 current bar, sampled on chart bars) AND volume > SMA(volume, lookback) * volume multiplier; T1 is higher than the chart timeframe
Exit: long, close < min(Leading Span A, Leading Span B)