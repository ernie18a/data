Calculation: weighted score = (ROC vote + RSI vote + EMA vote + SMA vote) / 4 × clamp(weighted mean of Correlation(chart close, BTC close from T1, L1 through L5) calculated on chart bars using five increasing lookbacks and separate nonnegative weights W1 through W5, omitting zero-weight terms, or zero if their total is zero, to [-1, +1]); each vote is +1 when its corresponding long condition holds and -1 otherwise; BTC close uses the T1 bar still forming in realtime and the last completed T1 bar historically, sampled on chart bars
Long: ROC(close, ROC lookback) > ROC threshold parameter
Short: ROC(close, ROC lookback) <= ROC threshold parameter
Long: RSI(close, RSI lookback) > RSI threshold parameter
Short: RSI(close, RSI lookback) <= RSI threshold parameter
Long: EMA(close, shorter lookback) > EMA(close, longer lookback)
Short: EMA(close, shorter lookback) <= EMA(close, longer lookback)
Long: close > SMA(close, SMA lookback)
Short: close <= SMA(close, SMA lookback)
Long: weighted score >= 0 AND (weighted score < neutral low parameter OR weighted score > neutral high parameter)
Short: weighted score < 0 AND (weighted score < neutral low parameter OR weighted score > neutral high parameter)