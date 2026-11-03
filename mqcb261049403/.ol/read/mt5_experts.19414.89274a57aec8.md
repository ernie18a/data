Long: RSI on another timeframe, using its last completed bar, is greater than 50 AND the prior completed daily low minus a fixed buffer is at or above entry price minus the stop-loss distance AND there is no same-side entry whose day-of-month is greater than or equal to the current day-of-month
Short: RSI on another timeframe, using its last completed bar, is nonzero and at most 50 AND the prior completed daily high plus a fixed buffer is at or below entry price plus the stop-loss distance AND there is no same-side entry whose day-of-month is greater than or equal to the current day-of-month
Calculation: Long stop = entry price minus stop-loss distance; move it to entry price when current price minus entry price is greater than the stop-loss distance
Calculation: Short stop = entry price plus stop-loss distance; move it to entry price when entry price minus current price is greater than the stop-loss distance
Calculation: Long take-profit = entry price plus three times the stop-loss distance
Calculation: Short take-profit = entry price minus three times the stop-loss distance
Exit: Long, current price is at or below the current long stop OR at or above the long take-profit
Exit: Short, current price is at or above the current short stop OR at or below the short take-profit