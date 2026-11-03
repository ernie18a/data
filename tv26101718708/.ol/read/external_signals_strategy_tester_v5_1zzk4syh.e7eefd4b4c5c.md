Calculation: Fibonacci Bollinger basis = selected moving average of selected price source over a lookback, optionally smoothed by a second selected moving average
Calculation: Fibonacci Bollinger bands = basis ± level × ATR × multiplier × max(current ATR / max(ATR from one lookback ago, 0.001), 0.5); levels are 0.236, 0.382, 0.5, 0.618, 0.764, and 1.0
Long: Buy signal crosses above 0 OR (long line-cross is enabled AND close crosses the selected line in the configured direction); datetime is within the configured date range
Short: Sell signal crosses above 0 OR (short line-cross is enabled AND close crosses the selected line in the configured direction); datetime is within the configured date range
Exit: Long, close-based profit percentage ≥ configured take-profit percentage OR close-based profit percentage ≤ negative configured stop-loss percentage
Exit: Short, close-based profit percentage ≥ configured take-profit percentage OR close-based profit percentage ≤ negative configured stop-loss percentage
Exit: Long, after close-based profit percentage reaches the configured break-even threshold, low reaches or falls below entry price
Exit: Short, after close-based profit percentage reaches the configured break-even threshold, high reaches or exceeds entry price
Exit: Long, if enabled, low reaches or falls below the selected Fibonacci Bollinger stop band; if enabled, high reaches or exceeds a selected take-profit band (the target is fixed at entry unless trailing is enabled, in which case it updates each bar)
Exit: Short, if enabled, high reaches or exceeds the selected Fibonacci Bollinger stop band; if enabled, low reaches or falls below a selected take-profit band (the target is fixed at entry unless trailing is enabled, in which case it updates each bar)