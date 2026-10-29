Calculation: MA1, MA2, MA3, MA4 = same selected moving average of close, with lookbacks ordered shortest to longest
Calculation: ATR filter = ATR >= its longer-lookback SMA (when enabled)
Calculation: Long stop = entry price minus configured percentage or entry ATR multiple; if trailing, update from each bar's high and retain the highest stop
Calculation: Short stop = entry price plus configured percentage or entry ATR multiple; if trailing, update from each bar's low and retain the lowest stop
Calculation: Long target = entry close plus configured percentage, entry ATR multiple, or risk multiple of the configured long stop distance
Calculation: Short target = entry close minus configured percentage, entry ATR multiple, or risk multiple of the configured long stop distance
Long: MA1 >= MA2 AND MA2 >= MA3 AND MA3 >= MA4 AND (ATR filter disabled OR ATR >= its longer-lookback SMA)
Short: MA1 <= MA2 AND MA2 <= MA3 AND MA3 <= MA4 AND (ATR filter disabled OR ATR >= its longer-lookback SMA)
Exit: long, previous bar had MA1 >= MA2 AND MA2 >= MA3 AND MA3 >= MA4 AND current bar does not; OR low <= long stop; OR high >= long target
Exit: short, previous bar had MA1 <= MA2 AND MA2 <= MA3 AND MA3 <= MA4 AND current bar does not; OR high >= short stop; OR low <= short target