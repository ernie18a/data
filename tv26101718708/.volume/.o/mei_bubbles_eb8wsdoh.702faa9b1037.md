Calculation: Normalized volume = current bar volume divided by the rolling standard deviation of volume over the lookback, including the current bar
Long: Normalized volume >= absorption threshold AND (high + low) / 2 <= min(open, close) AND (high + low) / 2 >= low
Short: Normalized volume >= absorption threshold AND (high + low) / 2 >= max(open, close) AND (high + low) / 2 <= high