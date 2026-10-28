Calculation: Long entry band = VWAP adjusted by the configured long offset percentage and rounded to the nearest minimum tick
Calculation: Short entry band = VWAP adjusted by the configured short offset percentage and rounded to the nearest minimum tick
Long: low <= Long entry band AND VWAP > 0 AND datetime is within the configured date range AND position side is not long
Short: high >= Short entry band AND VWAP > 0 AND datetime is within the configured date range AND position side is not short
Exit: long, high >= VWAP OR datetime is after the configured end date
Exit: short, low <= VWAP OR datetime is after the configured end date