Calculation: Whale ratio = the moving average of large-transaction USD volume divided by total transaction USD volume, using higher-timeframe closes from the bar still forming.
Calculation: Z-score = (value − its rolling mean) / its rolling standard deviation.
Calculation: Conviction = Z-score of whale-ratio rate of change minus Z-score of price rate of change; each rate of change is (current value − value at the longer lookback) / absolute value at the longer lookback. Use higher-timeframe closes from the bar still forming for both series.
Calculation: Signal oscillator = whale-ratio Z-score in Z-Score mode, or Conviction in Conviction mode; use the corresponding mode’s upper and lower thresholds.
Long: Signal oscillator >= upper threshold
Short: Signal oscillator <= lower threshold