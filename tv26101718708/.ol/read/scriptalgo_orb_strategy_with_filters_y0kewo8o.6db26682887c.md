Calculation: Opening-range high = highest high of the configured number of chart bars beginning at the configured session start
Calculation: Opening-range low = lowest low of the configured number of chart bars beginning at the configured session start
Long: close > opening-range high AND previous bar close <= opening-range high AND close > open AND SuperTrend direction < 0 AND volume > volume moving average
Short: close < opening-range low AND previous bar close >= opening-range low AND close < open AND SuperTrend direction > 0 AND volume > volume moving average
Exit: long, close < opening-range low OR low <= opening-range low OR high >= entry price + (entry price - opening-range low) * risk/reward ratio
Exit: short, close > opening-range high OR high >= opening-range high OR low <= entry price - (opening-range high - entry price) * risk/reward ratio