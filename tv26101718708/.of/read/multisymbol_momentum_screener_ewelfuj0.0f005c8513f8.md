Calculation: Momentum score = mean of RSI and the percentile rank of rate of change; both use the last completed chart-timeframe bar.
Calculation: Trend score = mean of ADX and an EMA spread score, where the EMA spread score is 50 + 20 × 100 × (shorter-lookback EMA − longer-lookback EMA) / longer-lookback EMA, clamped to 0–100; use the last completed chart-timeframe bar.
Calculation: Volatility score = 50 × ATR / its longer-lookback simple moving average, clamped to 0–100; use the last completed chart-timeframe bar.
Calculation: Total score = the weighted average of the Momentum, Trend, and Volatility scores.
Calculation: Daily direction = 0 if the absolute percentage spread between the shorter-lookback and longer-lookback EMAs is below a threshold; otherwise +1 if the shorter-lookback EMA is above the longer-lookback EMA, and −1 otherwise. Use the last completed bar of a higher (Daily) timeframe.
Long: Total score >= 50 AND Daily direction >= 0
Short: (Total score >= 50 AND Total score < 70 AND Daily direction < 0) OR (Total score < 50 AND Daily direction <= 0)