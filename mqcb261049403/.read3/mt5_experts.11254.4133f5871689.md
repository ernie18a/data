Calculation: TrendLine = Smooth(2 × Smooth(selected applied price, half the long lookback, method 1, phase 1) − Smooth(selected applied price, long lookback, method 1, phase 1), square root of the long lookback, method 2, phase 2)
Long: On chart bars, TrendLine > TrendLine[1] AND TrendLine[1] <= TrendLine[2]
Short: On chart bars, TrendLine < TrendLine[1] AND TrendLine[1] >= TrendLine[2]
Long: On chart bars using the forming and last completed T1 bars, TrendLine[1] > TrendLine[2] AND TrendLine[0] <= TrendLine[1]
Short: On chart bars using the forming and last completed T1 bars, TrendLine[1] < TrendLine[2] AND TrendLine[0] >= TrendLine[1]
Exit: long, on chart bars using the forming and last completed T1 bars, TrendLine[1] < TrendLine[2] AND TrendLine[0] < TrendLine[1]
Exit: short, on chart bars using the forming and last completed T1 bars, TrendLine[1] > TrendLine[2] AND TrendLine[0] > TrendLine[1]