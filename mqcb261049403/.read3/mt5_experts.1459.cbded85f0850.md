Calculation: Weighted WPR on T1 = the weighted mean of 100 + Williams %R for the short-, middle-, and long-lookback parameters, using three separate weights and lookbacks.
Calculation: MBK trend state on T1 = bullish when Weighted WPR > upper base level + swing AND 100 + Williams %R(long lookback) >= center level - average swing; bearish when Weighted WPR < lower base level - swing AND 100 + Williams %R(long lookback) <= center level + average swing; otherwise neutral. Upper and lower base levels are symmetric around the center level.
Long: On the last completed T1 bar, MBK trend state is bullish AND its most recent earlier non-neutral state is bearish.
Short: On the last completed T1 bar, MBK trend state is bearish AND its most recent earlier non-neutral state is bullish.
Exit: long, the most recent earlier T1 trend reversal arrow is bearish.
Exit: short, the most recent earlier T1 trend reversal arrow is bullish.