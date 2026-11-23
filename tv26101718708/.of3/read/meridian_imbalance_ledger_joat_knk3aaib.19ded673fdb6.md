Calculation: chart bull gap = chart imbalances on AND bar is confirmed AND low > high[2] AND close[1] > high[2] AND low - high[2] >= ATR(ATR length) * min width factor AND abs(close[1] - open[1]) >= ATR(ATR length) * impulse factor
Calculation: chart bear gap = chart imbalances on AND bar is confirmed AND high < low[2] AND close[1] < low[2] AND low[2] - high >= ATR(ATR length) * min width factor AND abs(close[1] - open[1]) >= ATR(ATR length) * impulse factor
Calculation: T1 bull gap = T1 imbalances on AND T1 is not shorter than chart AND new T1 bar opens AND low(T1, last completed bar) > high(T1, 3rd last completed bar) AND close(T1, 2nd last completed bar) > high(T1, 3rd last completed bar) AND low(T1, last completed bar) - high(T1, 3rd last completed bar) >= ATR(ATR length, T1, last completed bar) * min width factor
Calculation: T1 bear gap = T1 imbalances on AND T1 is not shorter than chart AND new T1 bar opens AND high(T1, last completed bar) < low(T1, 3rd last completed bar) AND close(T1, 2nd last completed bar) < low(T1, 3rd last completed bar) AND low(T1, 3rd last completed bar) - high(T1, last completed bar) >= ATR(ATR length, T1, last completed bar) * min width factor
Calculation: T2 bull cluster = T2 imbalances on AND bar is confirmed AND count of T2 bars i >= 2 within this chart bar where low(T2, bar i) > high(T2, bar i-2) AND close(T2, bar i-1) > high(T2, bar i-2) AND low(T2, bar i) - high(T2, bar i-2) >= ATR(ATR length, T2, bar i) * micro width factor is at least micro threshold
Calculation: T2 bear cluster = T2 imbalances on AND bar is confirmed AND count of T2 bars i >= 2 within this chart bar where high(T2, bar i) < low(T2, bar i-2) AND close(T2, bar i-1) < low(T2, bar i-2) AND low(T2, bar i-2) - high(T2, bar i) >= ATR(ATR length, T2, bar i) * micro width factor is at least micro threshold
Calculation: new bull zone = (chart bull gap OR T1 bull gap OR T2 bull cluster) AND (overlap rejection off OR no live bull zone[1] overlaps it), where top = max low of the newest bars and bottom = min high of the oldest bars of its gaps, and overlap = bottom <= other top AND top >= other bottom
Calculation: new bear zone = (chart bear gap OR T1 bear gap OR T2 bear cluster) AND (overlap rejection off OR no live bear zone[1] overlaps it), where top = max low of the oldest bars and bottom = min high of the newest bars of its gaps, and overlap = bottom <= other top AND top >= other bottom
Calculation: live bull zone = new bull zone formed at or before this bar, such that no bar from its formation through this bar satisfies (fill rule mode 1 AND low <= top) OR (fill rule mode 2 AND low <= (top + bottom) / 2) OR (fill rule mode 3 AND close <= bottom), and bars since formation <= max lifetime
Calculation: live bear zone = new bear zone formed at or before this bar, such that no bar from its formation through this bar satisfies (fill rule mode 1 AND high >= bottom) OR (fill rule mode 2 AND high >= (top + bottom) / 2) OR (fill rule mode 3 AND close >= top), and bars since formation <= max lifetime
Long: chart bull gap
Short: chart bear gap
Long: T1 bull gap
Short: T1 bear gap
Long: T2 bull cluster
Short: T2 bear cluster
Long: new bull zone
Short: new bear zone
Short: inversion tracking on AND bar is confirmed AND (close < bottom of a live bull zone[1] OR close < bottom of a new bull zone)
Long: inversion tracking on AND bar is confirmed AND (close > top of a live bear zone[1] OR close > top of a new bear zone)
Long: count of live bull zones > count of live bear zones
Short: count of live bear zones > count of live bull zones