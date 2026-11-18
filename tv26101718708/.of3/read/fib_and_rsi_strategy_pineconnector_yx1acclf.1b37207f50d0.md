Calculation: Fibonacci deviation = Fibonacci multiplier × STDEV(hlc3, Fibonacci lookback)
Calculation: Lower fractional band = VWMA(hlc3, Fibonacci lookback) − 0.001 × Fibonacci level × Fibonacci deviation
Calculation: Upper fractional band = VWMA(hlc3, Fibonacci lookback) + 0.001 × Fibonacci level × Fibonacci deviation
Long: low < VWMA(hlc3, Fibonacci lookback) − Fibonacci deviation AND RSI(close, RSI lookback)[1] crosses above oversold threshold AND high < Lower fractional band
Short: high > VWMA(hlc3, Fibonacci lookback) + Fibonacci deviation AND RSI(close, RSI lookback)[1] crosses below overbought threshold AND low > Upper fractional band
Exit: Long, high > Lower fractional band recorded on the most recent long-entry bar OR low ≤ close × (1 − stop-loss percentage / 100)
Exit: Short, low < Upper fractional band recorded on the most recent short-entry bar OR high ≥ close × (1 + stop-loss percentage / 100)