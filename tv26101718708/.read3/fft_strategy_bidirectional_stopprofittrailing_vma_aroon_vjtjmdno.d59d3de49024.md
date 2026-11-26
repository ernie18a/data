Calculation: Filtered FFT signal = the first real value of the inverse FFT after transforming the latest power-of-two window, up to the selected length, of chart-bar source; optionally standardize the source and retain the selected inclusive frequency band and its mirrored components. The signal is undefined unless moving-window mode is enabled and the current bar is within the enabled inclusive date bounds.
Calculation: VMA trend color = green when VMA(source, lookback) on T1 bars is above its prior T1-bar value, red when below, and blue when equal; each chart bar uses the color of the last completed T1 bar.
Long: long entry enabled AND filtered FFT signal crosses above 0 AND (VMA entry filter disabled OR VMA trend color is in the allowed long color set)
Short: short entry enabled AND filtered FFT signal crosses below 0 AND (VMA entry filter disabled OR VMA trend color is in the allowed short color set)
Exit: short, filtered FFT signal crosses above 0 AND long entry disabled AND (VMA entry filter disabled OR VMA trend color is in the allowed long color set)
Exit: long, filtered FFT signal crosses below 0 AND short entry disabled AND (VMA entry filter disabled OR VMA trend color is in the allowed short color set)
Exit: long, VMA stop-loss enabled AND long entry enabled AND VMA trend color is in the allowed long cancellation color set
Exit: short, VMA stop-loss enabled AND short entry enabled AND VMA trend color is in the allowed short cancellation color set
Exit: long, Aroon stop enabled AND long entry enabled AND Aroon Up(long lookback) < long upper threshold AND Aroon Down(long lookback) > long lower threshold
Exit: short, Aroon stop enabled AND short entry enabled AND Aroon Up(short lookback) > short upper threshold AND Aroon Down(short lookback) < short lower threshold
Exit: long, (long stop-loss enabled AND low <= entry price * (1 - long stop-loss fraction)) OR (long take-profit enabled AND high >= entry price * (1 + long take-profit fraction))
Exit: short, (short stop-loss enabled AND high >= entry price * (1 + short stop-loss fraction)) OR (short take-profit enabled AND low <= entry price * (1 - short take-profit fraction))
Calculation: Long trailing stop price = running maximum of close * (1 - long trailing-stop fraction) during the current long position; reset when flat.
Calculation: Short trailing stop price = running minimum of close * (1 + short trailing-stop fraction) during the current short position; reset when flat.
Exit: long, long trailing stop-loss enabled AND close <= long trailing stop price AND close > entry price
Exit: short, short trailing stop-loss enabled AND close >= short trailing stop price AND close < entry price
Calculation: Long trailing take-profit activation = remains active after close > entry price * (1 + long activation fraction) until the position closes or changes size.
Calculation: Short trailing take-profit activation = remains active after close < entry price * (1 - short activation fraction) until the position closes or changes size.
Calculation: Long trailing take-profit stop price = running maximum of close * (1 - long trailing take-profit fraction) during the current long position; reset when flat.
Calculation: Short trailing take-profit stop price = running minimum of close * (1 + short trailing take-profit fraction) during the current short position; reset when flat.
Exit: long, long trailing take-profit enabled AND long trailing take-profit activation is active AND close <= long trailing take-profit stop price
Exit: short, short trailing take-profit enabled AND short trailing take-profit activation is active AND close >= short trailing take-profit stop price