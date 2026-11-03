Calculation: Pressure = 100 × clamp((0.6 × (close − low) + 0.4 × ((lower wick − upper wick + range) / 2)) / range, 0, 1), where range = high − low (use 0.0001 when range is zero), lower wick = min(open, close) − low, and upper wick = high − max(open, close)
Calculation: Relative Volume = volume / SMA(volume, volume-average lookback)
Calculation: Relative Volume Delta = (2 × Pressure / 100 − 1) × Relative Volume
Calculation: Relative Volume Percentage = Relative Volume Delta / Relative Volume × 100
Calculation: Spike = Relative Volume Delta / SMA(abs(Relative Volume Delta), recent lookback)
Long: Pressure ≥ 0 OR Relative Volume Delta ≥ 5 OR Relative Volume Percentage ≥ 40 OR Spike > 2
Short: Pressure < 80 OR Relative Volume Delta < 7 OR Relative Volume Percentage < 50 OR Spike < 0