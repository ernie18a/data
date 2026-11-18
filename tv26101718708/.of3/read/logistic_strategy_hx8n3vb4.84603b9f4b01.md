Calculation: signed volume = volume when close > open, otherwise -volume
Calculation: prediction = (close + STDEV(close, price lookback)) / (1 + (STDEV(close, price lookback) / close) * EXP(-SMA(signed volume, short lookback) / STDEV(signed volume, long lookback)))
Long: prediction > close * (1 + threshold)
Exit: long, prediction < close * (1 - threshold)