Calculation: Baseline = selected moving average of close
Calculation: ATR = selected moving average of true range
Long: close crosses above Baseline AND abs(close - Baseline) <= ATR
Short: close crosses below Baseline AND abs(close - Baseline) <= ATR
Exit: long, close crosses below Baseline OR low <= entry price - ATR at entry x stop multiplier OR high >= entry price + ATR at entry x target multiplier
Exit: short, close crosses above Baseline OR high >= entry price + ATR at entry x stop multiplier OR low <= entry price - ATR at entry x target multiplier