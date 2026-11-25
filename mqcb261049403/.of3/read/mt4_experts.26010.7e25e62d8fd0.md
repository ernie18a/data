Calculation: shorter-lookback LWMA = LWMA(typical price, shorter of the two lookbacks, T1, still-forming bar), sampled on chart bars from T1
Calculation: longer-lookback LWMA = LWMA(typical price, longer of the two lookbacks, T1, still-forming bar), sampled on chart bars from T1
Calculation: forming-bar RSI = RSI(close, RSI lookback, T2, still-forming bar), sampled on chart bars from T2
Calculation: last-completed-bar RSI = RSI(close, same RSI lookback, T2, last completed bar), sampled on chart bars from T2
Calculation: upper-fractal line slope = slope through the most recent and third-most-recent confirmed upper Fractals values on chart bars
Calculation: lower-fractal line slope = slope through the most recent and third-most-recent confirmed lower Fractals values on chart bars
Calculation: short-group EMA values = EMA(typical price, each of six separately parameterized successively longer short-group lookbacks, T3, still-forming bar), sampled on chart bars from T3
Calculation: long-group EMA values = EMA(typical price, each of six separately parameterized successively longer long-group lookbacks, T3, still-forming bar), sampled on chart bars from T3; each long-group lookback is longer than every short-group lookback
Calculation: lower Bollinger Band = Bollinger lower band(close, lookback, deviation, chart timeframe, last completed bar)
Long: abs(close - close[2]) > entry-distance parameter × point size AND shorter-lookback LWMA > longer-lookback LWMA AND low[2] < high[1] AND forming-bar RSI > last-completed-bar RSI AND upper-fractal line slope > 0 AND lower-fractal line slope < 0 OR upper-fractal line slope < 0 AND lower-fractal line slope > 0
Short: abs(close - close[1]) > entry-distance parameter × point size AND shorter-lookback LWMA < longer-lookback LWMA AND low[1] < high[2] AND forming-bar RSI < last-completed-bar RSI AND upper-fractal line slope > 0 AND lower-fractal line slope < 0 OR upper-fractal line slope < 0 AND lower-fractal line slope > 0
Exit: long, all short-group EMA values are equal OR all long-group EMA values are equal OR close[1] <= lower Bollinger Band
Exit: short, all short-group EMA values are equal OR all long-group EMA values are equal OR close[1] <= lower Bollinger Band