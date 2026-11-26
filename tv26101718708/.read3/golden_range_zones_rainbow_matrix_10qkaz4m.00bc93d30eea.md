Calculation: RecentHigh = high(T1, last completed bar)
Calculation: RecentLow = low(T1, last completed bar)
Calculation: OuterHigh = high of the most recent completed T1 bar before the last completed T1 bar whose high is above RecentHigh, otherwise RecentHigh + k * (RecentHigh - RecentLow) if RecentHigh > RecentLow
Calculation: OuterLow = low of the most recent completed T1 bar before the last completed T1 bar whose low is below RecentLow, otherwise RecentLow - k * (RecentHigh - RecentLow) if RecentHigh > RecentLow
Long: timeframe of chart bars < T1 AND close >= OuterLow AND close <= RecentLow
Short: timeframe of chart bars < T1 AND close >= RecentHigh AND close <= OuterHigh