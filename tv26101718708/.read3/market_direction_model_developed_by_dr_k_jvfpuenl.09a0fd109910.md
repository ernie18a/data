Calculation: distribution day = ROC(close, 1) < distribution-day decline input parameter AND volume > volume[1]
Calculation: distribution-day count = SUM(distribution day ? 1 : 0, distribution lookback)
Calculation: fifth distribution-day low = low of the distribution-day-rank-th most recent distribution day in the distribution lookback
Calculation: sell signal = fifth distribution-day low exists AND close < fifth distribution-day low
Calculation: rally day = bars since low equals LOWEST(low, FTD rally lookback) + 1
Calculation: follow-through day = rally day >= rally-start parameter AND rally day <= rally-end parameter AND ROC(close, 1) >= FTD gain input parameter / 100 AND (higher-volume filter disabled OR volume > volume[1])
Calculation: confirmed-uptrend state = set true on a follow-through day, then set false on a sell signal or close < SMA(close, long-term SMA lookback); otherwise retain the prior value
Long: follow-through day
Long: confirmed-uptrend state AND NOT (sell signal OR (close < SMA(close, shorter-term SMA lookback) AND close < SMA(close, longer-term SMA lookback))) AND distribution-day count < distribution-count threshold
Short: distribution day
Short: sell signal OR (close < SMA(close, shorter-term SMA lookback) AND close < SMA(close, longer-term SMA lookback))
Exit: long, distribution-day count >= distribution-count threshold AND NOT sell signal AND NOT (close < SMA(close, shorter-term SMA lookback) AND close < SMA(close, longer-term SMA lookback))