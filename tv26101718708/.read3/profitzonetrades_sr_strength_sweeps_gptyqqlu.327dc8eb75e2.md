Calculation: body size = abs(close - open)
Calculation: upper wick = high - max(open, close)
Calculation: lower wick = min(open, close) - low
Short: high > Highest(high, sweep lookback)[1] AND close < Highest(high, sweep lookback)[1] AND upper wick > body size * wick-strength multiplier AND (volume filter is off OR volume > SMA(volume, volume-average lookback)) AND (EMA filter is off OR close < EMA(close, EMA-filter lookback))
Long: low < Lowest(low, sweep lookback)[1] AND close > Lowest(low, sweep lookback)[1] AND lower wick > body size * wick-strength multiplier AND (volume filter is off OR volume > SMA(volume, volume-average lookback)) AND (EMA filter is off OR close > EMA(close, EMA-filter lookback))