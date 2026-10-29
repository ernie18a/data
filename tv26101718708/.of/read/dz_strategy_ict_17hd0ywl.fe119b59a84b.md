Calculation: Upper/lower channel band = SMA(close, lookback) ± deviations × multiplier × standard deviation(close, lookback)
Calculation: Stop level = average entry price × (1 − stop-loss ratio / (stop-loss ratio + profit ratio))
Long: Close shifted back by the displacement crosses above the lower channel band AND volume > volume threshold × SMA(volume, lookback), for any parameter set
Short: Close shifted back by the displacement crosses below the upper channel band AND volume > volume threshold × SMA(volume, lookback), for any parameter set
Exit: Long, low ≤ stop level
Exit: Short, high ≥ stop level