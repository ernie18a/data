Calculation: Opening range = highest high and lowest low of the first configured number of chart bars beginning at the configured session start
Long: close > opening-range high AND previous close <= opening-range high AND close > open AND SuperTrend direction < 0 AND (volume filter disabled OR volume > volume SMA)
Short: close < opening-range low AND previous close >= opening-range low AND close < open AND SuperTrend direction > 0 AND (volume filter disabled OR volume > volume SMA)
Exit: long, close < opening-range low OR price <= opening-range low OR price >= entry price + (entry price - opening-range low) × risk/reward ratio
Exit: short, close > opening-range high OR price >= opening-range high OR price <= entry price - (opening-range high - entry price) × risk/reward ratio