Calculation: Flow line = EMA of an EMA of RSI(close), with the inner EMA using a shorter lookback than the outer EMA
Calculation: Signal line = EMA of the Flow line, using a shorter lookback than the Flow line’s EMA
Calculation: Flow pressure = Flow line minus Signal line
Long: Flow pressure > 0 AND prior-bar Flow pressure <= 0 AND Flow line > prior-bar Flow line
Short: Flow pressure < 0 AND prior-bar Flow pressure >= 0 AND Flow line < prior-bar Flow line