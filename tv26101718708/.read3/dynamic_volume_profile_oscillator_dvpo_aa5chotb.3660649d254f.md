Calculation: DVPO = EMA(mode is Mean Reversion ? (if sensitivity × weighted mean absolute deviation(close, volume, lookback) > 0, 50 + 25 × (close − VWMA(close, volume, lookback)) / (sensitivity × weighted mean absolute deviation(close, volume, lookback)); otherwise 50) : (if highest(SMA(volume, smoothing), lookback) > lowest(SMA(volume, smoothing), lookback), clamp(100 × (SMA(volume, smoothing) − lowest(SMA(volume, smoothing), lookback)) / (highest(SMA(volume, smoothing), lookback) − lowest(SMA(volume, smoothing), lookback)), 0, 100); otherwise 50), smoothing)
Calculation: midline = adaptive ? SMA(DVPO, midline period) : 50
Calculation: fast signal = EMA(DVPO, shorter signal lookback)
Calculation: slow signal = EMA(DVPO, longer signal lookback), with longer signal lookback > shorter signal lookback
Long: DVPO > midline OR fast signal > slow signal
Short: DVPO <= midline AND fast signal <= slow signal
Long: DVPO crosses above (midline + stdev(DVPO, midline period) × zone width)
Short: DVPO crosses below (midline − stdev(DVPO, midline period) × zone width)
Long: fast signal crosses above slow signal
Short: fast signal crosses below slow signal