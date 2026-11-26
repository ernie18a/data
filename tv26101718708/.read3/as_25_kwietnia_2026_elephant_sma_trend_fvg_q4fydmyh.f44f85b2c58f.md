Calculation: Body ratio = if high - low > 0 then abs(close - open)/(high - low) else 0
Long: high - low > ATR(ATR lookback) * range multiplier AND Body ratio > minimum body fraction AND close > open
Short: high - low > ATR(ATR lookback) * range multiplier AND Body ratio > minimum body fraction AND close < open
Long: low > high[2]
Short: high < low[2]
Long: close > SMA(close, shorter SMA lookback)
Short: close <= SMA(close, shorter SMA lookback)
Long: SMA(close, intermediate SMA lookback) > SMA(close, intermediate SMA lookback)[1]
Short: SMA(close, intermediate SMA lookback) <= SMA(close, intermediate SMA lookback)[1]
Long: SMA(close, intermediate SMA lookback) > SMA(close, longer SMA lookback) AND abs(close - SMA(close, longer SMA lookback))/SMA(close, longer SMA lookback) >= distance threshold
Short: SMA(close, intermediate SMA lookback) < SMA(close, longer SMA lookback) AND abs(close - SMA(close, longer SMA lookback))/SMA(close, longer SMA lookback) >= distance threshold
Long: On chart bars, close crosses above EMA(source, EMA lookback) calculated on T1 bars and sampled from the current T1 bar (forming in realtime; completed on historical bars)
Short: On chart bars, close crosses below EMA(source, EMA lookback) calculated on T1 bars and sampled from the current T1 bar (forming in realtime; completed on historical bars)