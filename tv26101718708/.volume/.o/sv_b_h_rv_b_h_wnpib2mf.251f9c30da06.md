Calculation: Z-score(x) = (x − lookback mean(x)) / lookback standard deviation(x); use 0 when standard deviation is 0
Calculation: Session VWAP distance Z-score = Z-score(close − session VWAP)
Calculation: Rolling VWAP = rolling sum(close × volume) / rolling sum(volume)
Calculation: Rolling VWAP distance Z-score = Z-score(close − rolling VWAP)
Calculation: Session composite = EMA of the weighted average of price Z-score, volume Z-score, and session VWAP distance Z-score
Calculation: Rolling composite = EMA of the weighted average of price Z-score, volume Z-score, and rolling VWAP distance Z-score
Calculation: Opening-range high = highest high during the current day's opening range
Calculation: Premarket high = highest high during the current day's premarket; undefined if there are no premarket bars
Long: close > opening-range high AND (premarket high is undefined OR close > premarket high) AND ((at least two of price Z-score, volume Z-score, and session VWAP distance Z-score are above the alignment threshold AND session composite crosses above the composite threshold) OR (at least two of price Z-score, volume Z-score, and rolling VWAP distance Z-score are above the alignment threshold AND rolling composite crosses above the composite threshold))