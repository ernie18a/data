Calculation: Volume-weighted close = sum(close × volume) / sum(volume) over the last 20 bars
Calculation: Volume imbalance = (volume above volume-weighted close − volume below volume-weighted close) / (their sum + 1e-8), where each volume is summed over the last 12 bars
Calculation: Trend = short-period SMA(close) compared with longer-period SMA(close)
Calculation: Momentum = absolute difference between short-period EMA(close) and longer-period EMA(close); normalized momentum = min(momentum / its 90th percentile over the last 100 bars, 1), or 0 if the percentile is zero
Calculation: Long confidence = (trend up + volume imbalance > 0.22 + RSI > 55 + ATR > 0.8 × 60-bar SMA(ATR)) / configurable maximum score
Calculation: Short confidence = (trend down + volume imbalance < -0.22 + RSI < 45 + ATR > 0.8 × 60-bar SMA(ATR)) / configurable maximum score
Calculation: Low-volatility threshold = configurable percentile of ATR over a configurable lookback; low volatility means ATR is below this threshold
Calculation: Circuit-breaker threshold = 200-bar SMA(ATR) + 3 × 200-bar standard deviation(ATR)
Long: configured trading session AND not low volatility AND long confidence ≥ configured confidence threshold AND normalized momentum > configured momentum threshold AND short-period EMA(close) ≥ longer-period EMA(close) AND RSI ≤ configured long RSI ceiling AND position is flat AND ATR ≤ circuit-breaker threshold
Short: configured trading session AND not low volatility AND short confidence ≥ configured confidence threshold AND normalized momentum > configured momentum threshold AND short-period EMA(close) ≤ longer-period EMA(close) AND RSI ≥ configured short RSI floor AND position is flat AND ATR ≤ circuit-breaker threshold
Exit: Long, low ≤ entry price − ATR × configured stop multiplier
Exit: Short, high ≥ entry price + ATR × configured stop multiplier
Exit: Long, price falls by configured ATR multiple from the trailing high since entry
Exit: Short, price rises by configured ATR multiple from the trailing low since entry
Exit: Long, high ≥ entry price + ATR × configured scale-out multiple
Exit: Short, low ≤ entry price − ATR × configured scale-out multiple
Exit: Long, short-period EMA(close) crosses below longer-period EMA(close)
Exit: Short, short-period EMA(close) crosses above longer-period EMA(close)
Exit: Long, ATR > circuit-breaker threshold
Exit: Short, ATR > circuit-breaker threshold
Exit: Long, hour = 15 and minute ≥ 50, or hour = 16
Exit: Short, hour = 15 and minute ≥ 50, or hour = 16