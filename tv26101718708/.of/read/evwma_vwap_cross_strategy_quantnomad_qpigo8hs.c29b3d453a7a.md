Calculation: EVWMA = recursively update the prior EVWMA toward close, weighting the prior value by the rolling sum of volume over the lookback minus current volume, and close by current volume; initialize the prior EVWMA to close on the first bar
Calculation: Smoothed VWAP = EMA of session VWAP, where session VWAP is the cumulative volume-weighted average of (high + low + close) / 3, reset each session
Long: current Smoothed VWAP > current EVWMA AND previous Smoothed VWAP <= previous EVWMA
Short: current Smoothed VWAP < current EVWMA AND previous Smoothed VWAP >= previous EVWMA