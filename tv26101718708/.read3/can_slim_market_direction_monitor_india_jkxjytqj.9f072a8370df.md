Calculation: Distribution count = sum the full weight for each bar with ROC(close, 1) <= the distribution decline threshold and volume > volume[1], and the stalling weight for each enabled bar with 0 < ROC(close, 1) < the stalling gain threshold, volume > volume[1], and close < (high + low) / 2; remove each event when its age exceeds the distribution expiry lookback or, on a later bar, high >= its low × (1 + the reset rally percentage / 100)
Calculation: Rally day = while close < SMA(close, short lookback) OR close < Highest(high, short lookback) × (1 - correction decline threshold), update the rally low and reset the day count to zero when low makes a new low; otherwise, after the rally low, set the count to one on the first close > close[1], then increment it on each bar, resetting the low and count if low makes a new low; reset the count and clear the low when the count exceeds the maximum rally day plus the stale rally allowance
Calculation: Market phase = RED if Distribution count >= red DD-count threshold OR (close <= SMA(close, long lookback) AND SMA(close, long lookback) <= SMA(close, long lookback)[long slope lookback]); otherwise YELLOW if Distribution count >= yellow DD-count threshold OR close <= SMA(close, short lookback) OR close <= SMA(close, long lookback); otherwise GREEN
Long: Rally day >= minimum FTD day AND Rally day <= maximum FTD day AND ROC(close, 1) >= minimum FTD gain AND volume > volume[1]
Short: ROC(close, 1) <= distribution decline threshold AND volume > volume[1]
Short: stalling is enabled AND 0 < ROC(close, 1) < stalling gain threshold AND volume > volume[1] AND close < (high + low) / 2
Long: Market phase = GREEN
Short: Market phase = RED
Exit: Long, Market phase = YELLOW OR Market phase = RED
Long: Market phase = GREEN AND Market phase[1] != GREEN
Short: Market phase = RED AND Market phase[1] != RED
Exit: Long, Market phase = YELLOW AND Market phase[1] = GREEN
Long: close > SMA(close, short lookback)
Short: close <= SMA(close, short lookback)
Long: close > SMA(close, long lookback)
Short: close <= SMA(close, long lookback)
Long: SMA(close, short lookback) > SMA(close, long lookback)
Short: SMA(close, short lookback) <= SMA(close, long lookback)
Long: close > SMA(close, intermediate lookback) AND SMA(close, intermediate lookback) > SMA(close, intermediate lookback)[stage slope lookback]
Exit: Long, close > SMA(close, intermediate lookback) AND SMA(close, intermediate lookback) <= SMA(close, intermediate lookback)[stage slope lookback]
Short: close <= SMA(close, intermediate lookback) AND SMA(close, intermediate lookback) <= SMA(close, intermediate lookback)[stage slope lookback]
Long: (close - Highest(high, drawdown lookback)) / Highest(high, drawdown lookback) × 100 > -shallow drawdown threshold
Short: (close - Highest(high, drawdown lookback)) / Highest(high, drawdown lookback) × 100 <= -deep drawdown threshold