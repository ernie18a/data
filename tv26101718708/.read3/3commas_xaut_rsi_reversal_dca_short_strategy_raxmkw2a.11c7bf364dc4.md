Calculation: averaging order deviation(k) = first averaging order deviation * sum over i from 0 to k - 1 of deviation step multiplier^i
Calculation: averaging orders filled = number of averaging orders filled since entry
Calculation: take-profit low = lowest close since entry among bars whose close is at or below average entry price * (1 - take-profit percent / 100); undefined if no such bar
Short: crosses below(RSI(close, lookback), upper level) on T1 bars, last completed bar, AND position side is flat AND datetime in window
Short: close >= base entry price * (1 + averaging order deviation(averaging orders filled + 1) / 100) AND averaging orders filled < averaging order count AND position side is short AND datetime in window
Exit: short, close >= average entry price * (1 + stop-loss percent / 100)
Exit: short, close >= take-profit low * (1 + trailing percent / 100)