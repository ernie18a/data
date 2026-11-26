Long: server-time hour = entry-hour parameter AND volume(T1, bar still forming) <= entry-volume limit AND, on chart bars using completed T1 bars, close(T1, trend-lookback bars before the bar still forming) > close(T1, last completed bar)
Short: server-time hour = entry-hour parameter AND volume(T1, bar still forming) <= entry-volume limit AND, on chart bars using completed T1 bars, close(T1, trend-lookback bars before the bar still forming) <= close(T1, last completed bar)
Exit: long, position age > maximum position age
Exit: short, position age > maximum position age