Calculation: Detrended price oscillator = close minus the simple moving average of close, shifted back by half its lookback rounded down plus one bar.
Calculation: Long stop = lowest low over the lookback ending on the long-entry signal bar.
Calculation: Short stop = highest high over the lookback ending on the short-entry signal bar.
Long: short-term EMA crosses above long-term EMA AND the detrended price oscillator is above zero for three consecutive bars AND current position is not long
Short: short-term EMA crosses below long-term EMA AND the detrended price oscillator is below zero for three consecutive bars AND current position is not short
Exit: long, close <= long stop OR close >= entry price + (entry price - long stop) × reward-to-risk ratio
Exit: short, close >= short stop OR close <= entry price + (entry price - short stop) × reward-to-risk ratio