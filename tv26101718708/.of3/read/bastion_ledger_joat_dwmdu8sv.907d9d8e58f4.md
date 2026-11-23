Calculation: SwingHigh = PivotHigh(high, left bars, right bars) when not na, otherwise SwingHigh[1]
Calculation: SwingLow = PivotLow(low, left bars, right bars) when not na, otherwise SwingLow[1]
Long: close > SwingHigh AND close[1] <= SwingHigh
Short: close < SwingLow AND close[1] >= SwingLow