Calculation: Delta ratio = EMA(volume × 1 when close > open, otherwise volume × 0.5) / EMA(volume × 1 when close < open, otherwise volume × 0.5)
Calculation: Gamma width = standard deviation of close over a lookback × a width multiplier
Calculation: Put wall high = VWAP − Gamma width
Calculation: Call wall low = VWAP + Gamma width
Long: Delta ratio > 1 AND VIX < EMA(VIX)
Long: Delta ratio > 1 AND VIX < EMA(VIX) AND close crosses above Put wall high
Short: Delta ratio < 1 AND VIX > EMA(VIX)
Short: Delta ratio < 1 AND VIX > EMA(VIX) AND close crosses below Call wall low
Exit: long, Delta ratio > 1 AND VIX < EMA(VIX) AND close crosses above Call wall low
Exit: short, Delta ratio < 1 AND VIX > EMA(VIX) AND close crosses below Put wall high