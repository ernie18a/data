Calculation: gap elapsed = bars since the most recent earlier bar where signal event is true >= signal gap length
Calculation: signal event = (gap elapsed AND crosses above(MACD(close, fast length, slow length), 0)) OR (gap elapsed AND crosses below(MACD(close, fast length, slow length), 0)) OR (gap elapsed AND crosses above(MACD(close, fast length, slow length), MACD signal line(close, fast length, slow length, signal length)) AND MACD(close, fast length, slow length) < 0) OR (gap elapsed AND crosses below(MACD(close, fast length, slow length), MACD signal line(close, fast length, slow length, signal length)) AND MACD(close, fast length, slow length) > 0) OR bullish histogram divergence OR bearish histogram divergence OR squeeze release up OR squeeze release down
Calculation: bullish histogram divergence = a pivot low of MACD histogram(close, fast length, slow length, signal length) with divergence pivot length bars on each side, confirmed at bar t for pivot bar p = t - divergence pivot length, AND low(p) < low(q) AND MACD histogram(p) > MACD histogram(q) AND MACD histogram(p) < 0, where q is the most recent earlier pivot low bar of MACD histogram
Calculation: bearish histogram divergence = a pivot high of MACD histogram(close, fast length, slow length, signal length) with divergence pivot length bars on each side, confirmed at bar t for pivot bar p = t - divergence pivot length, AND high(p) > high(q) AND MACD histogram(p) < MACD histogram(q) AND MACD histogram(p) > 0, where q is the most recent earlier pivot high bar of MACD histogram
Calculation: compressed = count of stored abs(MACD histogram) values >= minimum history count AND abs(MACD histogram(close, fast length, slow length, signal length)) <= percentile(stored abs(MACD histogram) values, percentile level), where the stored values cover the last lookback window length bars
Calculation: compression run = number of consecutive bars up to this bar where compressed is true
Calculation: squeeze release up = NOT compressed AND compressed[1] AND compression run[1] >= minimum compression run length AND MACD histogram(close, fast length, slow length, signal length) > 0
Calculation: squeeze release down = NOT compressed AND compressed[1] AND compression run[1] >= minimum compression run length AND MACD histogram(close, fast length, slow length, signal length) < 0
Calculation: expanding timeframe count = number of Tn in T1 to T4 where MACD histogram(close, fast length, slow length, signal length, Tn, last completed bar) > 0
Calculation: matrix aligned up = MACD(close, fast length, slow length, Tn, last completed bar) > 0 for every Tn in T1 to T4 AND expanding timeframe count >= minimum expanding count
Calculation: matrix aligned down = MACD(close, fast length, slow length, Tn, last completed bar) <= 0 for every Tn in T1 to T4 AND expanding timeframe count <= maximum expanding count
Long: gap elapsed AND crosses above(MACD(close, fast length, slow length), 0)
Long: gap elapsed AND crosses above(MACD(close, fast length, slow length), MACD signal line(close, fast length, slow length, signal length)) AND MACD(close, fast length, slow length) < 0
Long: bullish histogram divergence
Long: squeeze release up
Long: matrix aligned up AND NOT matrix aligned up[1]
Long: MACD(close, fast length, slow length) >= 0
Long: MACD(close, fast length, slow length, T1, last completed bar) > 0
Long: MACD(close, fast length, slow length, T2, last completed bar) > 0
Long: MACD(close, fast length, slow length, T3, last completed bar) > 0
Long: MACD(close, fast length, slow length, T4, last completed bar) > 0
Short: gap elapsed AND crosses below(MACD(close, fast length, slow length), 0)
Short: gap elapsed AND crosses below(MACD(close, fast length, slow length), MACD signal line(close, fast length, slow length, signal length)) AND MACD(close, fast length, slow length) > 0
Short: bearish histogram divergence
Short: squeeze release down
Short: matrix aligned down AND NOT matrix aligned down[1]
Short: MACD(close, fast length, slow length) < 0
Short: MACD(close, fast length, slow length, T1, last completed bar) <= 0
Short: MACD(close, fast length, slow length, T2, last completed bar) <= 0
Short: MACD(close, fast length, slow length, T3, last completed bar) <= 0
Short: MACD(close, fast length, slow length, T4, last completed bar) <= 0