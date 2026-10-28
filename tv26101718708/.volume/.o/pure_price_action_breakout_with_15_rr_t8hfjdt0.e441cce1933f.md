Long: fast EMA of close crosses above slower EMA of close AND RSI is above its midpoint AND volume is above its moving average
Short: fast EMA of close crosses below slower EMA of close AND RSI is below its midpoint AND volume is above its moving average
Calculation: ATR-based stop distance = ATR × stop-loss factor
Calculation: Long target = close + (close − long stop) × reward-to-risk ratio
Calculation: Short target = close − (short stop − close) × reward-to-risk ratio
Exit: Long, low ≤ long stop OR high ≥ long target
Exit: Short, high ≥ short stop OR low ≤ short target