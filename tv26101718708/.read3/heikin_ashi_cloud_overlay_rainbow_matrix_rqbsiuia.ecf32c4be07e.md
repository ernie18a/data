Calculation: Heikin Ashi body percentage = if Heikin Ashi open > 0 then abs(Heikin Ashi close - Heikin Ashi open) / Heikin Ashi open * 100, else 0
Long: Heikin Ashi close >= Heikin Ashi open
Short: Heikin Ashi close < Heikin Ashi open
Long: on chart bars, Heikin Ashi close(T1, bar still forming) >= Heikin Ashi open(T1, bar still forming)
Short: on chart bars, Heikin Ashi close(T1, bar still forming) < Heikin Ashi open(T1, bar still forming)
Long: on a confirmed bar, Heikin Ashi close >= Heikin Ashi open AND Heikin Ashi close[1] < Heikin Ashi open[1]
Short: on a confirmed bar, Heikin Ashi close < Heikin Ashi open AND Heikin Ashi close[1] >= Heikin Ashi open[1]
Long: Heikin Ashi close >= Heikin Ashi open AND SMA(Heikin Ashi body percentage, body lookback) > 0 AND Heikin Ashi body percentage > anomaly multiplier * SMA(Heikin Ashi body percentage, body lookback)
Short: Heikin Ashi close < Heikin Ashi open AND SMA(Heikin Ashi body percentage, body lookback) > 0 AND Heikin Ashi body percentage > anomaly multiplier * SMA(Heikin Ashi body percentage, body lookback)