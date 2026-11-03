Calculation: Confirmed pivot high/low = a high/low at the center of a symmetric lookback window that qualifies as a pivot after the same number of bars to its right have completed. Each newly confirmed pivot replaces the previous unbroken pivot level of the same type.
Calculation: Upward break = close above the latest unbroken confirmed pivot high, or high above it when wick breaks are selected. Mark that level broken after the first break.
Calculation: Downward break = close below the latest unbroken confirmed pivot low, or low below it when wick breaks are selected. Mark that level broken after the first break.
Calculation: Fresh bullish gap = current low > high two bars ago AND previous close > previous low + previous ATR multiplied by a threshold. Its top is the current low and its bottom is the high two bars ago.
Calculation: Fresh bearish gap = current high < low two bars ago AND previous close < previous high - previous ATR multiplied by a threshold. Its top is the low two bars ago and its bottom is the current high.
Calculation: Gap state = add each fresh gap to its directional collection on the next bar, then apply mitigation on that bar and subsequent bars. A bullish gap is mitigated when min(open, close) < bottom, low < bottom, or low < midpoint, according to the selected mitigation method. A bearish gap is mitigated when max(open, close) > top, high > top, or high > midpoint, respectively. In gap mode remove it; in breaker mode retain it as an opposite-direction breaker. Remove a bullish-origin breaker when max(open, close) > top, high > top, or high > midpoint, respectively; remove a bearish-origin breaker when min(open, close) < bottom, low < bottom, or low < midpoint, respectively. If overlap hiding is selected, remove older same-direction gaps whose interior overlaps or strictly contains or is strictly contained by the newest gap, then apply the same test between each bullish gap and the newest bearish gap and between each remaining bearish gap and the newest bullish gap; touching boundaries and identical intervals do not qualify. Apply these operations in that order.
Long: A pivot high is confirmed.
Short: A pivot low is confirmed.
Long: An upward break occurs.
Short: A downward break occurs.
Long: A fresh bullish gap occurs AND an upward break occurred on the previous bar.
Short: A fresh bearish gap occurs AND a downward break occurred on the previous bar.
Long: A newly added bullish gap remains unmitigated and survives overlap removal.
Short: A newly added bearish gap remains unmitigated and survives overlap removal.
Long: A bearish gap becomes a breaker AND the breaker survives overlap removal.
Short: A bullish gap becomes a breaker AND the breaker survives overlap removal.
Long: An unmitigated bullish gap that survives overlap removal has not previously been raided AND low < its top AND close > its top.
Short: An unmitigated bearish gap that survives overlap removal has not previously been raided AND high > its bottom AND close < its bottom.