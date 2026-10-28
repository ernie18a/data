Calculation: Delta = (close - open) / max(high - low, 1) * volume, smoothed over a short-term lookback
Calculation: Demand zone = current bar's low <= latest confirmed pivot low and current bar's high >= latest confirmed pivot low
Calculation: Supply zone = current bar's low <= latest confirmed pivot high and current bar's high >= latest confirmed pivot high
Calculation: Absorption wall = volume > a long-term volume average and abs(close - open) / (high - low) <= a parameterized maximum body percentage, with high > low
Long: Delta > 0 AND volume > a long-term volume average AND close > open OR Absorption wall AND Demand zone AND Delta < 0
Short: Delta < 0 AND volume > a long-term volume average AND close < open OR Absorption wall AND Supply zone AND Delta > 0