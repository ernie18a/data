Calculation: Ergodic Ticks Volume OSMA = on the configured signal timeframe (higher or lower than the chart timeframe if different), using completed bars, let V be tick_volume or volume; U=(V+(close-open)/point_size)/2 and D=V-U; smooth U and D with the same configurable smoothing method using the first lookback, then smooth each again using the second lookback; form 100*(U-D)/(U+D), or 0 when U+D=0; smooth this value successively with the third, fourth, and fifth lookbacks to form the line; smooth the line with the sixth lookback to form its signal; smooth line minus signal with the seventh lookback to form the histogram. All lookbacks are independently configurable.
Long: histogram[t-2] >= histogram[t-1] AND histogram[t] > histogram[t-1]
Short: histogram[t-2] <= histogram[t-1] AND histogram[t] < histogram[t-1]
Exit: Long, histogram[t-2] <= histogram[t-1] AND histogram[t] < histogram[t-1]
Exit: Short, histogram[t-2] >= histogram[t-1] AND histogram[t] > histogram[t-1]
Exit: Long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: Short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance