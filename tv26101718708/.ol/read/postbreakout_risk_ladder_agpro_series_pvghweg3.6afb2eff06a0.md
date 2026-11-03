Calculation: Prior base high/low = highest high / lowest low over the longer lookback of prior completed chart-timeframe bars
Calculation: Relative volume = current volume divided by its chart-timeframe moving average over the lookback
Calculation: Breakout body ratio = absolute(close − open) divided by high − low
Calculation: Valid base = prior base range is within configured minimum and maximum multiples of ATR
Long: Valid base AND close > prior base high + ATR break buffer AND previous close ≤ prior base high + ATR break buffer AND breakout body ratio ≥ minimum AND relative volume ≥ minimum
Short: Valid base AND close < prior base low − ATR break buffer AND previous close ≥ prior base low − ATR break buffer AND breakout body ratio ≥ minimum AND relative volume ≥ minimum
Exit: Long, close < locked breakout edge − ATR at breakout × (retest shelf multiple + invalidation buffer multiple) OR bars since breakout > maximum breakout age
Exit: Short, close > locked breakout edge + ATR at breakout × (retest shelf multiple + invalidation buffer multiple) OR bars since breakout > maximum breakout age