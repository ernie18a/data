Calculation: body top = max(open, close)
Calculation: body bottom = min(open, close)
Calculation: T1 ATR = ATR(atr length, T1, last completed bar)[1]
Calculation: size threshold = fixed points mode ? fixed size : max(size fraction * T1 ATR, minimum threshold ticks * tick size)
Calculation: trading halt = time - time[1] > halt gap OR time[1] - time[2] > halt gap
Calculation: room overlaps(a) = count of j from 3 to room lookback + 2 where body top[j] >= a - band AND body bottom[j] <= a + band, with band = anchor band fraction * T1 ATR, or 0 if T1 ATR is undefined
Long: low > high[2] AND NOT trading halt AND low - high[2] >= size threshold AND (NOT room filter enabled OR room overlaps(low[2]) <= max overlapping bodies OR (breakout enabled AND Highest(body top, breakout lookback)[3] < low)) AND (min leg fraction <= 0 OR low - low[2] >= min leg fraction * T1 ATR) AND long alerts enabled
Short: high < low[2] AND NOT trading halt AND low[2] - high >= size threshold AND (NOT room filter enabled OR room overlaps(high[2]) <= max overlapping bodies OR (breakout enabled AND Lowest(body bottom, breakout lookback)[3] > high)) AND (min leg fraction <= 0 OR high[2] - high >= min leg fraction * T1 ATR) AND short alerts enabled