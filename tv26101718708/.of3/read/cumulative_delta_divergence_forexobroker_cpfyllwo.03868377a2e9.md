Calculation: signed volume = volume if close > close[1], -volume if close < close[1], otherwise 0
Calculation: cumulative delta z-score = sum(signed volume, divergence lookback) / (stdev(signed volume, divergence lookback) * sqrt(divergence lookback)) when the denominator > 0, otherwise 0
Calculation: price z-score = (close - SMA(close, divergence lookback)) / stdev(close, divergence lookback) when stdev > 0, otherwise 0
Calculation: divergence = price z-score - cumulative delta z-score
Long: divergence <= -divergence threshold
Short: divergence >= divergence threshold
Long: divergence <= -divergence threshold AND divergence[1] > -divergence threshold
Short: divergence >= divergence threshold AND divergence[1] < divergence threshold
Long: divergence <= -strong divergence threshold
Short: divergence >= strong divergence threshold
Long: close crosses above EMA(close, EMA lookback)
Long: divergence <= -divergence threshold AND close crosses above EMA(close, EMA lookback) AND current position is flat or short AND at least cooldown bars have elapsed since the previous buy or sell signal AND bar is confirmed
Short: divergence >= divergence threshold AND close crosses below EMA(close, EMA lookback) AND current position is flat or long AND at least cooldown bars have elapsed since the previous buy or sell signal AND bar is confirmed