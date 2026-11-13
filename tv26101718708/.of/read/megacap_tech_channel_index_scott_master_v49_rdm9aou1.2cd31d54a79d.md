Calculation: EMA = exponential moving average of close; ATR = average true range, both on chart timeframe
Calculation: vrsi = short simple moving average of RSI(close)
Calculation: OS = low percentile of vrsi over a long rolling lookback; OB = higher percentile of vrsi over the same lookback (OB > OS)
Calculation: stopLevel = max(initStop, trail), where initStop = signal-bar close - ATR at the signal bar * m1, and trail = running maximum since entry of (close - ATR * m2) with m2 > m1; if (close - entryPrice)/entryPrice exceeds a profit threshold then trail = max(trail, entryPrice + a small fraction of ATR)
Long: position is flat AND low <= EMA - ATR * k1 AND close > open AND vrsi <= OS AND close < EMA * (1 + small percent)
Exit: long, (vrsi >= OB OR close >= EMA + ATR * k2) AND bars since entry >= minimum hold bars
Exit: long, low <= stopLevel