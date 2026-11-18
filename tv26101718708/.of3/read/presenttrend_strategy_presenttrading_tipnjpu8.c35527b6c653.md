Calculation: Adaptive trend line = if the selected RSI(source, length) or MFI(hlc3, length) is at least 50, then max(low - SMA(true range, length) * multiplier, previous adaptive trend line or 0); otherwise min(high + SMA(true range, length) * multiplier, previous adaptive trend line or 0)
Calculation: Bullish reversal signal = adaptive trend line crosses above adaptive trend line[2]
Calculation: Bearish reversal signal = adaptive trend line crosses below adaptive trend line[2]
Calculation: Trend state = 1 when bullish reversal signal and barsSince(bullish reversal signal[1]) > barsSince(bearish reversal signal); otherwise -1 when bearish reversal signal and barsSince(bearish reversal signal[1]) > barsSince(bullish reversal signal); otherwise the previous trend state, initially 0
Long: bullish reversal signal
Short: bearish reversal signal
Long: trend state = 1
Short: trend state = -1