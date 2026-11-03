Calculation: Opening-range high/low = highest high/lowest low from the RTH open through the configured opening-range duration.
Calculation: Initial-balance high/low = highest high/lowest low from the RTH open through the configured initial-balance duration.
Calculation: Anchored VWAP and standard deviation = volume-weighted mean and standard deviation of hlc3 since the configured RTH, Globex, or daily anchor; use weight 1 when volume is zero or unavailable.
Long: Confirmed bar close > opening-range high AND opening range is complete AND in RTH AND no prior upward opening-range break this session
Short: Confirmed bar close < opening-range low AND opening range is complete AND in RTH AND no prior downward opening-range break this session
Long: Confirmed bar close > initial-balance high AND initial balance is complete AND in RTH AND no prior upward initial-balance break this session
Short: Confirmed bar close < initial-balance low AND initial balance is complete AND in RTH AND no prior downward initial-balance break this session
Short: Confirmed bar high >= anchored VWAP + 2 × standard deviation AND standard deviation > 0
Long: Confirmed bar low <= anchored VWAP − 2 × standard deviation AND standard deviation > 0