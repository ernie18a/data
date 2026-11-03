Calculation: EMA spread = longer-lookback EMA of close minus shorter-lookback EMA of close, evaluated on lower-timeframe bars at the bar still forming and the last completed bar.
Calculation: Adjacent-period EMA spread = shorter-lookback EMA of close minus the EMA with the next longer lookback, evaluated on lower-timeframe bars at the bar still forming and the last completed bar.
Long: EMA spread crosses from below zero to above zero.
Short: EMA spread crosses from above zero to below zero.
Exit: Long, EMA spread crosses from above zero to below zero AND close is above entry price by a positive buffer.
Exit: Short, EMA spread crosses from below zero to above zero AND close is below entry price by a positive buffer.
Exit: Long, close is above entry price by a positive buffer AND adjacent-period EMA spread falls from the last completed bar to the bar still forming.
Exit: Short, close is below entry price by a positive buffer AND adjacent-period EMA spread rises from the last completed bar to the bar still forming.
Exit: Long, close falls to or below the highest high since entry minus the trailing distance, after price has risen from entry by more than that distance.
Exit: Short, close rises to or above the lowest low since entry plus the trailing distance, after price has fallen from entry by more than that distance.