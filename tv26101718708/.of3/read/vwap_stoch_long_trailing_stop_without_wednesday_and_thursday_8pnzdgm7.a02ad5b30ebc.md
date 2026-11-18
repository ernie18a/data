Calculation: trailing stop = while long, max(close * (1 - trailing percentage), trailing stop[1]); otherwise 0
Long: close < VWAP(close) AND Stochastic(close, high, low, lookback) < threshold AND day of week is Sunday, Monday, Tuesday, Friday, or Saturday AND position is flat or short
Exit: long, low <= trailing stop