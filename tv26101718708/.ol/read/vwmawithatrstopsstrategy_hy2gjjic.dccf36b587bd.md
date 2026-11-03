Calculation: VWMA = volume-weighted average of close over a lookback
Calculation: RSI of VWMA = RSI of VWMA, using a separate lookback
Calculation: ATR trailing stop = ATR multiplied by a multiplier defines the stop distance. If current and previous closes are above the previous stop, set the stop to the greater of the previous stop and current close minus the stop distance. If both closes are below the previous stop, set it to the lesser of the previous stop and current close plus the stop distance. Otherwise, set it to current close minus the stop distance if current close is above the previous stop, or current close plus the stop distance if below. Initialize the previous stop as zero.
Long: RSI of VWMA >= 30 AND close > open AND close > VWMA AND the close crossed above the ATR trailing stop at the most recent direction change and has not since crossed below it
Short: close crossed below the ATR trailing stop
Exit: long, close crossed below the ATR trailing stop