Calculation: timeframe vote(T) = +1 if close > EMA(close, trend lookback) and -1 otherwise, calculated on T and read on chart bars from the last completed T bar
Calculation: net vote = vote(T1) + vote(T2) + vote(T3)
Long: vote(T1) = +1
Short: vote(T1) = -1
Long: vote(T2) = +1
Short: vote(T2) = -1
Long: vote(T3) = +1
Short: vote(T3) = -1
Long: net vote >= confluence threshold
Short: net vote <= -confluence threshold
Long: net vote >= confluence threshold AND net vote[1] < confluence threshold
Short: net vote <= -confluence threshold AND net vote[1] > -confluence threshold
Long: net vote = 3 AND net vote[1] != 3
Short: net vote = -3 AND net vote[1] != -3
Long: close crosses above EMA(close, local reclaim lookback)
Short: close crosses below EMA(close, local reclaim lookback)
Long: net vote >= confluence threshold AND close crosses above EMA(close, local reclaim lookback) AND session filter passes AND position side is not long AND cooldown bars have elapsed since the last signal AND chart bar is confirmed
Short: net vote <= -confluence threshold AND close crosses below EMA(close, local reclaim lookback) AND session filter passes AND position side is not short AND cooldown bars have elapsed since the last signal AND chart bar is confirmed