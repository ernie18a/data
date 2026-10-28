Calculation: Moving average = selected source’s selected moving average over a lookback (SMA, EMA, WMA, HMA, VWMA, RMA, or TEMA)
Calculation: Upper tolerance band = moving average × (1 + tolerance percentage / 100)
Calculation: Lower tolerance band = moving average × (1 − tolerance percentage / 100)
Long: Current close > current upper tolerance band AND previous close ≤ previous upper tolerance band AND current date is at or after the configured start year and month
Short: Current close < current lower tolerance band AND previous close ≥ previous lower tolerance band AND current date is at or after the configured start year and month