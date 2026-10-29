Calculation: Slow EMA slope per bar = ((current slow EMA - slow EMA N bars ago) / slow EMA N bars ago) / N × 100
Calculation: Volume ratio = current volume / simple moving average of volume over N bars
Calculation: Bull targets = Over the prior L bars, average the open at each fast-EMA cross above slow EMA (prior fast EMA ≤ prior slow EMA); find the highest high where fast EMA > slow EMA. If that high exceeds the average, set EMA T1 to average + half the difference and EMA T2 to average + the difference; otherwise targets are unavailable. If VPoC is enabled and exceeds 1.08 × the average, use VPoC for T1 and average + 2 × (VPoC − average) for T2. VPoC is the midpoint of the price bin with the greatest volume, where bar volume is apportioned across overlapping bins in proportion to range overlap over the last V bars.
Long: Not long AND Bull targets available AND (fast EMA crosses above slow EMA OR (anticipation percentage > 0 AND fast EMA < slow EMA AND (slow EMA − fast EMA) / slow EMA ≤ anticipation percentage AND fast EMA > prior fast EMA))
Long: Not long AND fast EMA > slow EMA AND close ≥ 0.95 × T1 AND close ≤ 1.15 × T1 AND slow EMA slope per bar > 0 AND slow EMA slope per bar > prior slope per bar AND prior slope per bar ≤ 0.02 AND volume ratio ≥ 0.7 AND volume ratio ≥ prior volume ratio AND (slow EMA slope per bar ≥ 0.05 OR volume ratio ≥ 1)
Long: Bullish engulfing OR hammer OR morning star OR piercing line OR bullish harami
Short: Fast EMA crosses below slow EMA OR bearish engulfing OR shooting star OR evening star OR dark cloud cover OR bearish harami
Exit: Long, high ≥ T2
Exit: Long, low ≤ stop price AND high < T2
Exit: Long, fast EMA crosses below slow EMA AND high < T2 AND low > stop price
Exit: Long, slow EMA slope per bar < 0 AND volume ratio < 0.7 for two consecutive bars