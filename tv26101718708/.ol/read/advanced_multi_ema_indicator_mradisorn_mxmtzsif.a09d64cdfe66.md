Calculation: MA1 = selected SMA, EMA, or VWMA of close with the shortest lookback
Calculation: MA2 = selected SMA, EMA, or VWMA of close with the second-shortest lookback
Calculation: MA3 = selected SMA, EMA, or VWMA of close with the second-longest lookback
Calculation: MA4 = selected SMA, EMA, or VWMA of close with the longest lookback
Long: (MA1 > MA2 AND previous-bar MA1 <= previous-bar MA2) OR (MA2 > MA3 AND previous-bar MA2 <= previous-bar MA3) OR (MA3 > MA4 AND previous-bar MA3 <= previous-bar MA4)
Short: (MA1 < MA2 AND previous-bar MA1 >= previous-bar MA2) OR (MA2 < MA3 AND previous-bar MA2 >= previous-bar MA3) OR (MA3 < MA4 AND previous-bar MA3 >= previous-bar MA4)