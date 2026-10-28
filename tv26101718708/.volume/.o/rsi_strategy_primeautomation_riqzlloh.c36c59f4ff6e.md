Calculation: RSI = relative strength index of close
Calculation: ATR = average true range over a longer lookback
Calculation: Long trailing stop = at entry, close − ATR × stop multiplier; thereafter, the maximum of the prior stop and low − ATR × stop multiplier
Calculation: Short trailing stop = at entry, close + ATR × stop multiplier; thereafter, the minimum of the prior stop and high + ATR × stop multiplier
Calculation: Long profit target = entry price + ATR × target multiplier, using ATR at entry
Calculation: Short profit target = entry price − ATR × target multiplier, using ATR at entry
Long: RSI crosses above the upper threshold AND no trade is open AND datetime is on or after the strategy start date AND bar index > 200
Short: RSI crosses below the lower threshold AND no trade is open AND datetime is on or after the strategy start date AND bar index > 200
Exit: long, low < long trailing stop OR (take profit is enabled AND high crosses above long profit target)
Exit: short, high > short trailing stop OR (take profit is enabled AND low crosses below short profit target)