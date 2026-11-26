Calculation: delta = (close > open ? volume : volume * neutral-volume fraction) - (close < open ? volume : volume * neutral-volume fraction)
Long: delta crosses above 0 AND CVD(delta) > SMA(CVD(delta), lookback)
Short: delta crosses below 0 AND CVD(delta) < SMA(CVD(delta), lookback)