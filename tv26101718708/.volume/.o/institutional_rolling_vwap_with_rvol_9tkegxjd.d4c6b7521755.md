Calculation: RVOL = shorter-lookback SMA(volume) / longer-lookback SMA(volume)
Calculation: Rolling VWAP = volume-weighted average price over a rolling time window
Calculation: Upper/lower σ bands = rolling VWAP plus/minus the corresponding multiple of volume-weighted price standard deviation, adjusted by RVOL when adaptive bands are enabled
Long: close > upper 2σ band AND RVOL > 1.3 OR close > upper 3σ band AND RVOL > 1.5 OR close < lower 2σ band AND RVOL < 0.8
Short: close > upper 2σ band AND RVOL < 0.8 OR close < lower 2σ band AND RVOL > 1.3 OR close < lower 3σ band AND RVOL > 1.5