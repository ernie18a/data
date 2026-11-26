Calculation: prior pivot high = most recent non-na value of PivotHigh(high, pivot period, pivot period, T1, last completed bar) before the current bar
Calculation: prior pivot low = most recent non-na value of PivotLow(low, pivot period, pivot period, T1, last completed bar) before the current bar
Long: PivotHigh(high, pivot period, pivot period, T1, last completed bar) is not na AND (prior pivot high is na OR PivotHigh(high, pivot period, pivot period, T1, last completed bar) > prior pivot high)
Long: PivotLow(low, pivot period, pivot period, T1, last completed bar) >= prior pivot low
Short: PivotHigh(high, pivot period, pivot period, T1, last completed bar) <= prior pivot high
Short: PivotLow(low, pivot period, pivot period, T1, last completed bar) is not na AND (prior pivot low is na OR PivotLow(low, pivot period, pivot period, T1, last completed bar) < prior pivot low)
Long: RSI(close, rsi length, T1, last completed bar) > RSI bullish threshold AND RSI(close, rsi length, T1, last completed bar) <= RSI overbought threshold
Short: RSI(close, rsi length, T1, last completed bar) > RSI oversold threshold AND RSI(close, rsi length, T1, last completed bar) <= RSI bearish threshold
Long: swing type of ZigZag(high, low, zigzag period, T1, last completed bar) is high
Short: swing type of ZigZag(high, low, zigzag period, T1, last completed bar) is low