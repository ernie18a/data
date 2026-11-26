Calculation: warmup bars = MAX(ATR slow lookback, warmup multiplier * trend lookback)
Calculation: price z-score = (close - SMA(close, fast lookback)) / STDEV(close, fast lookback)
Calculation: MACD fast length = MIN(fast lookback, MACD fast cap)
Calculation: MACD slow length = MIN(slow lookback, MACD slow cap)
Calculation: MACD signal length = MAX(ROUND(MACD signal ratio * fast lookback), minimum MACD signal length)
Long: bar index >= warmup bars AND SMA(close, fast lookback) crosses above SMA(close, slow lookback)
Short: bar index >= warmup bars AND SMA(close, fast lookback) crosses below SMA(close, slow lookback)
Long: bar index >= warmup bars AND RSI(close, fast lookback) crosses above RSI low level
Short: bar index >= warmup bars AND RSI(close, fast lookback) crosses below RSI high level
Long: bar index >= warmup bars AND MACD(close, MACD fast length, MACD slow length, MACD signal length) line crosses above its signal line
Short: bar index >= warmup bars AND MACD(close, MACD fast length, MACD slow length, MACD signal length) line crosses below its signal line
Long: bar index >= warmup bars AND close <= lower Bollinger Band(close, fast lookback, band multiplier) AND RSI(close, Bollinger RSI lookback) < Bollinger RSI low level
Short: bar index >= warmup bars AND close >= upper Bollinger Band(close, fast lookback, band multiplier) AND RSI(close, Bollinger RSI lookback) > Bollinger RSI high level
Long: bar index >= warmup bars AND close > Highest(high, fast lookback)[1] AND volume > volume multiplier * SMA(volume, volume lookback)
Short: bar index >= warmup bars AND close < Lowest(low, fast lookback)[1] AND volume > volume multiplier * SMA(volume, volume lookback)
Long: bar index >= warmup bars AND price z-score < -z threshold
Short: bar index >= warmup bars AND price z-score > z threshold