Calculation: Filtered FFT signal = inverse discrete Fourier transform of the chart-timeframe source series, retaining only the selected frequency band in a moving window
Long: Filtered FFT signal > 0 AND prior bar's filtered FFT signal ≤ 0 AND (VMA filter disabled OR selected VMA trend color is allowed for long) AND long entries enabled
Short: Filtered FFT signal < 0 AND prior bar's filtered FFT signal ≥ 0 AND (VMA filter disabled OR selected VMA trend color is allowed for short) AND short entries enabled
Exit: Short, filtered FFT signal > 0 AND prior bar's filtered FFT signal ≤ 0 AND long entries disabled
Exit: Long, filtered FFT signal < 0 AND prior bar's filtered FFT signal ≥ 0 AND short entries disabled
Exit: Long, VMA stop enabled AND long position enabled AND VMA trend color matches the selected long cancel color
Exit: Short, VMA stop enabled AND short position enabled AND VMA trend color matches the selected short cancel color
Calculation: Aroon Up = 100 × (lookback length − bars since the highest high in the lookback) ÷ lookback length
Calculation: Aroon Down = 100 × (lookback length − bars since the lowest low in the lookback) ÷ lookback length
Exit: Long, long position enabled AND long Aroon filter enabled AND Aroon Up < long upper threshold AND Aroon Down > long lower threshold
Exit: Short, short position enabled AND short Aroon filter enabled AND Aroon Up > short upper threshold AND Aroon Down < short lower threshold
Exit: Long, stop loss enabled AND low ≤ entry price × (1 − long stop-loss fraction)
Exit: Short, stop loss enabled AND high ≥ entry price × (1 + short stop-loss fraction)
Exit: Long, take profit enabled AND high ≥ entry price × (1 + long take-profit fraction)
Exit: Short, take profit enabled AND low ≤ entry price × (1 − short take-profit fraction)
Calculation: Long trailing stop = greatest value of the current close × (1 − long trailing-stop fraction) and the prior long trailing stop while long; reset to zero when flat
Calculation: Short trailing stop = least value of the current close × (1 + short trailing-stop fraction) and the prior short trailing stop while short; reset to a value above market when flat
Exit: Long, trailing stop enabled AND close ≤ long trailing stop AND close > entry price
Exit: Short, trailing stop enabled AND close ≥ short trailing stop AND close < entry price
Calculation: Long trailing take-profit stop = greatest value of the current close × (1 − long trailing fraction) and the prior long trailing take-profit stop while long; reset to zero when flat
Calculation: Short trailing take-profit stop = least value of the current close × (1 + short trailing fraction) and the prior short trailing take-profit stop while short; reset to a value above market when flat
Exit: Long, trailing take-profit enabled AND trailing take-profit activated when close > entry price × (1 + minimum long profit fraction) AND close ≤ long trailing take-profit stop
Exit: Short, trailing take-profit enabled AND trailing take-profit activated when close < entry price × (1 − minimum short profit fraction) AND close ≥ short trailing take-profit stop