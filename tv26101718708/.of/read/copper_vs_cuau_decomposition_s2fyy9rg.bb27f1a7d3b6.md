Calculation: RatioZ = EMA(r_z, smoothing length) where r_z = (r - SMA(r, N)) / stdev(r, N) and r = close of series A / close of series B, with both closes taken from the same higher-timeframe bar (higher than chart timeframe, bar still forming); SMA and stdev run over N higher-timeframe bars of r, and the EMA smoothing length is much shorter than N
Long: RatioZ > 0
Short: RatioZ < 0