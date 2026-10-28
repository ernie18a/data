Calculation: volume-weighted displacement = (close - open) * volume / (high - low)
Calculation: cumulative displacement = cumulative sum of volume-weighted displacement
Calculation: shadow = (cumulative displacement - SMA(cumulative displacement, shorter lookback)) / stdev(cumulative displacement - SMA(cumulative displacement, shorter lookback), longer lookback) * stdev(high - low, longer lookback)
Calculation: out = high + shadow when shadow > 0, otherwise low + shadow
Calculation: SuperTrend line = EMA(out, shared EMA lookback) ± SuperTrend multiplier * ATR(SuperTrend lookback), using the recursive SuperTrend bands and trend: upper band is max(EMA(out) - multiplier * ATR, prior upper band) when prior close > prior upper band, otherwise EMA(out) - multiplier * ATR; lower band is min(EMA(out) + multiplier * ATR, prior lower band) when prior close < prior lower band, otherwise EMA(out) + multiplier * ATR; trend is 1 when close > prior lower band, -1 when close < prior upper band, otherwise prior trend (initially 1); use upper band for trend 1 and lower band for trend -1
Calculation: regression endpoint = least-squares linear regression endpoint of close over its lookback
Calculation: regression bands = regression endpoint ± band multiplier * stdev(close, regression lookback)
Long: crossover(close, SuperTrend line) AND close > EMA(open, shared EMA lookback)
Long: crossunder(close, upper regression band)
Short: crossunder(close, SuperTrend line) AND close < EMA(open, shared EMA lookback)
Short: crossover(close, lower regression band)