Calculation: opening-range high = maximum high of the first range-count bars of each session
Calculation: opening-range low = minimum low of the first range-count bars of each session
Long: position is flat AND close > opening-range high AND close[1] <= opening-range high AND close > open AND SuperTrend(high, low, close, ATR lookback, factor) direction < 0 AND (volume filter is disabled OR volume > SMA(volume, volume lookback))
Short: position is flat AND close < opening-range low AND close[1] >= opening-range low AND close < open AND SuperTrend(high, low, close, ATR lookback, factor) direction > 0 AND (volume filter is disabled OR volume > SMA(volume, volume lookback))
Exit: long, low <= opening-range low OR high >= entry price + (entry price - opening-range low) * risk/reward ratio
Exit: short, high >= opening-range high OR low <= entry price - (opening-range high - entry price) * risk/reward ratio