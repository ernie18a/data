Calculation: EMA = exponential moving average of close
Calculation: VWAP = cumulative volume-weighted average of (high + low + close) / 3, reset at the start of each day
Long: EMA > VWAP OR (EMA > VWAP AND previous EMA <= previous VWAP AND close > VWAP AND EMA > EMA at the slope lookback bar AND absolute difference between previous EMA and previous VWAP >= the minimum distance)
Short: EMA < VWAP OR (EMA < VWAP AND previous EMA >= previous VWAP AND close < VWAP AND EMA < EMA at the slope lookback bar AND absolute difference between previous EMA and previous VWAP >= the minimum distance)