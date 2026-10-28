Calculation: Candle body = absolute difference between close and open
Calculation: Average body = rolling mean of candle body over the lookback
Calculation: Stop price = signal candle low for a long position; signal candle high for a short position
Calculation: Target price = entry price plus (long) or minus (short) the stop distance multiplied by a reward-to-risk factor
Long: close > open AND close > previous candle body high AND candle body >= average body * minimum body multiple AND volume >= rolling average volume * minimum volume multiple AND previous signal was not long AND no trade is open
Short: close < open AND close < previous candle body low AND candle body >= average body * minimum body multiple AND volume >= rolling average volume * minimum volume multiple AND previous signal was not short AND no trade is open
Exit: long, low <= stop price OR high >= target price
Exit: short, high >= stop price OR low <= target price