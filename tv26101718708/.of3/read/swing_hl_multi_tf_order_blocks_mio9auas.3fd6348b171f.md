Calculation: open ROC on T = ROC(open, ROC length, T, last completed bar)
Calculation: bullish crossing accepted on T = open ROC on T crosses above sensitivity AND no bullish crossing accepted on T within the previous spacing bars
Calculation: bearish crossing accepted on T = open ROC on T crosses below minus sensitivity AND no bearish crossing accepted on T within the previous spacing bars
Calculation: bullish OB candle offset on T = smallest offset k in [search start, search end] with close[k] < open[k] on T bars, or none
Calculation: bearish OB candle offset on T = smallest offset k in [search start, search end] with close[k] > open[k] on T bars, or none
Calculation: bullish OB formed on T = bullish crossing accepted on T AND bullish OB candle offset on T exists AND bullish OB candle offset on T is not the same candle as the previous bullish OB formed on T AND lowest of (close if mitigation type is close else low) over the last k T bars >= low[k], where k = bullish OB candle offset on T
Calculation: bearish OB formed on T = bearish crossing accepted on T AND bearish OB candle offset on T exists AND bearish OB candle offset on T is not the same candle as the previous bearish OB formed on T AND highest of (close if mitigation type is close else high) over the last k T bars <= high[k], where k = bearish OB candle offset on T
Calculation: held bullish OBs on T = on each chart bar: when bullish OB formed on T becomes true, add it with top = high[k] and bottom = low[k] (k its candle offset at formation); then drop the oldest while more than max active OBs are held; then remove each held bullish OB where (close[1] if mitigation type is close else low) < top - mitigation threshold/100 * (top - bottom)
Calculation: held bearish OBs on T = on each chart bar: when bearish OB formed on T becomes true, add it with top = high[k] and bottom = low[k] (k its candle offset at formation); then drop the oldest while more than max active OBs are held; then remove each held bearish OB where (close[1] if mitigation type is close else high) > bottom + mitigation threshold/100 * (top - bottom)
Calculation: swing high on T5 = PivotHigh(high, swing length, T5, last completed bar)
Calculation: swing low on T5 = PivotLow(low, swing length, T5, last completed bar)
Long: swing high on T5 is newly confirmed AND swing high on T5 > previous confirmed swing high on T5
Long: swing low on T5 is newly confirmed AND no swing high on T5 is newly confirmed on this chart bar AND swing low on T5 is not below previous confirmed swing low on T5
Short: swing high on T5 is newly confirmed AND swing high on T5 is not above previous confirmed swing high on T5
Short: swing low on T5 is newly confirmed AND no swing high on T5 is newly confirmed on this chart bar AND swing low on T5 < previous confirmed swing low on T5
Long: bullish OB formed on T1 becomes true
Long: low < top of any held bullish OB on T1
Short: bearish OB formed on T1 becomes true
Short: high > bottom of any held bearish OB on T1
Long: bullish OB formed on T2 becomes true
Long: low < top of any held bullish OB on T2
Short: bearish OB formed on T2 becomes true
Short: high > bottom of any held bearish OB on T2
Long: bullish OB formed on T3 becomes true
Long: low < top of any held bullish OB on T3
Short: bearish OB formed on T3 becomes true
Short: high > bottom of any held bearish OB on T3
Long: bullish OB formed on T4 becomes true
Long: low < top of any held bullish OB on T4
Short: bearish OB formed on T4 becomes true
Short: high > bottom of any held bearish OB on T4