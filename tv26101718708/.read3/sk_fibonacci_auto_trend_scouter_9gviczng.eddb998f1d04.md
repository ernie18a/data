Calculation: Pivot(k, N) = value of the k-th most recent direction change (k = 1 is the most recent), where direction becomes up on a bar whose high is the highest of the last N bars including itself and whose low is not the lowest of the last N bars, direction becomes down on a bar whose low is the lowest of the last N bars and whose high is not the highest of the last N bars, and the value is that bar's high for a change to up and its low for a change to down
Calculation: Mid(N) = (Pivot(3, N) + Pivot(4, N)) / 2
Calculation: Back(N) = (Pivot(5, N) + Pivot(6, N)) / 2
Calculation: Top(N) = max(Pivot(3, N), Pivot(4, N))
Calculation: Bottom(N) = min(Pivot(3, N), Pivot(4, N))
Long: Mid(shorter lookback) > Back(shorter lookback)
Short: Mid(shorter lookback) <= Back(shorter lookback)
Long: Mid(longer lookback) > Back(longer lookback)
Short: Mid(longer lookback) <= Back(longer lookback)
Long: Mid(shorter lookback) < close
Short: Mid(shorter lookback) >= close
Long: Back(longer lookback) < close
Short: Back(longer lookback) >= close
Long: Top(shorter lookback) > Top(longer lookback)
Short: Top(shorter lookback) <= Top(longer lookback)
Long: Bottom(shorter lookback) > Bottom(longer lookback)
Short: Bottom(shorter lookback) <= Bottom(longer lookback)