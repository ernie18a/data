Calculation: Opening-range high = highest high among the current day's bars in the configured opening-range session, updated as those bars form
Calculation: Opening-range low = lowest low among the current day's bars in the configured opening-range session, updated as those bars form
Long: close > opening-range high AND previous close <= previous opening-range high AND volume > simple moving average of volume multiplied by a threshold
Short: close < opening-range low AND previous close >= previous opening-range low AND volume > simple moving average of volume multiplied by a threshold