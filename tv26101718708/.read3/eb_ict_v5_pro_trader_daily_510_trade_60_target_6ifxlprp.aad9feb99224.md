Calculation: T1 close = close of the still-forming T1 bar, sampled on chart bars
Calculation: T1 EMA = EMA(close, T1 EMA lookback, T1, still-forming bar), computed on T1 bars and sampled on chart bars
Calculation: Bullish T1 bias = T1 close > T1 EMA
Calculation: Bearish T1 bias = T1 close < T1 EMA
Calculation: Uptrend = EMA(close, shorter EMA lookback) > EMA(close, longer EMA lookback)
Calculation: Downtrend = EMA(close, shorter EMA lookback) < EMA(close, longer EMA lookback)
Calculation: Latest confirmed swing high = most recent confirmed PivotHigh(high, swing strength, swing strength) on chart bars
Calculation: Latest confirmed swing low = most recent confirmed PivotLow(low, swing strength, swing strength) on chart bars
Calculation: Long sweep = a latest confirmed swing low exists AND low < latest confirmed swing low AND close > latest confirmed swing low
Calculation: Short sweep = a latest confirmed swing high exists AND high > latest confirmed swing high AND close < latest confirmed swing high
Calculation: Bullish MSS = a latest confirmed swing high exists AND close > latest confirmed swing high
Calculation: Bearish MSS = a latest confirmed swing low exists AND close < latest confirmed swing low
Calculation: Bullish fair value gap = low > high[gap offset]
Calculation: Bearish fair value gap = high < low[gap offset]
Calculation: Latest bullish gap zone = retain the most recent zone with top=low and bottom=high[gap offset] whenever a bullish fair value gap occurs
Calculation: Latest bearish gap zone = retain the most recent zone with top=low[gap offset] and bottom=high whenever a bearish fair value gap occurs
Calculation: Long gap retest = a latest bullish gap zone exists AND low <= its top AND close > its bottom
Calculation: Short gap retest = a latest bearish gap zone exists AND high >= its bottom AND close < its top
Calculation: Bullish displacement = close > open AND abs(close - open) > SMA(abs(close - open), body lookback) * body-size multiplier
Calculation: Bearish displacement = close < open AND abs(close - open) > SMA(abs(close - open), body lookback) * body-size multiplier
Calculation: Range position = range-scale parameter * (close - Lowest(low, range lookback)) / max(Highest(high, range lookback) - Lowest(low, range lookback), minimum tick size)
Calculation: Long discount = range position < long discount threshold
Calculation: Short premium = range position > short premium threshold
Calculation: Bullish rejection = close > open AND close > close[previous-close offset]
Calculation: Bearish rejection = close < open AND close < close[previous-close offset]
Calculation: Session allowed = session filter disabled OR the chart bar is within configured session A OR configured session B
Calculation: ATR value = ATR(high, low, close, ATR lookback)
Calculation: ATR filter passed = ATR filter disabled OR ATR value >= SMA(ATR value, longer ATR-smoothing lookback) * minimum ATR multiplier
Calculation: Long score = bias/displacement/MSS score weight for each true condition among bullish T1 bias, bullish displacement, and bullish MSS + sweep/retest score weight for long sweep + sweep/retest score weight for long gap retest, otherwise FVG/discount score weight if a bullish fair value gap occurs + FVG/discount score weight for long discount + session score weight if session allowed
Calculation: Short score = bias/displacement/MSS score weight for each true condition among bearish T1 bias, bearish displacement, and bearish MSS + sweep/retest score weight for short sweep + sweep/retest score weight for short gap retest, otherwise FVG/discount score weight if a bearish fair value gap occurs + FVG/discount score weight for short premium + session score weight if session allowed
Calculation: Long engine = (bullish T1 bias AND long discount AND long sweep AND bullish rejection) OR (bullish T1 bias AND uptrend AND long discount AND long gap retest AND bullish rejection) OR (bullish T1 bias AND uptrend AND long discount AND bullish displacement AND close > EMA(close, shorter EMA lookback))
Calculation: Short engine = (bearish T1 bias AND short premium AND short sweep AND bearish rejection) OR (bearish T1 bias AND downtrend AND short premium AND short gap retest AND bearish rejection) OR (bearish T1 bias AND downtrend AND short premium AND bearish displacement AND close < EMA(close, shorter EMA lookback))
Calculation: Cooldown passed = no prior entry order OR chart bars since the most recent entry order > cooldown-bars parameter
Calculation: Entries this T2 period = number of long and short entry orders submitted since the current T2 bar began, reset when a new T2 bar starts
Calculation: Long allowed = long score >= minimum-score parameter AND long engine AND session allowed AND ATR filter passed AND cooldown passed AND entries this T2 period < maximum-entries-per-T2-bar parameter AND no open position
Calculation: Short allowed = short score >= minimum-score parameter AND short engine AND session allowed AND ATR filter passed AND cooldown passed AND entries this T2 period < maximum-entries-per-T2-bar parameter AND no open position
Calculation: Long stop = Lowest(low, stop lookback) on the long signal bar, fixed for the trade
Calculation: Short stop = Highest(high, stop lookback) on the short signal bar, fixed for the trade
Calculation: Long risk = long signal-bar close - long stop
Calculation: Short risk = short stop - short signal-bar close
Calculation: Long target = long signal-bar close + risk/reward parameter * long risk, fixed for the trade
Calculation: Short target = short signal-bar close - risk/reward parameter * short risk, fixed for the trade
Long: Bullish T1 bias = true
Short: Bearish T1 bias = true
Long: long engine = true
Short: short engine = true
Long: long sweep = true
Short: short sweep = true
Long: bullish MSS = true
Short: bearish MSS = true
Long: long allowed = true
Long: long allowed = true AND long risk > minimum tick size
Short: short allowed = true
Short: short allowed = true AND short risk > minimum tick size
Exit: Long, low <= long stop OR high >= long target
Exit: Short, high >= short stop OR low <= short target