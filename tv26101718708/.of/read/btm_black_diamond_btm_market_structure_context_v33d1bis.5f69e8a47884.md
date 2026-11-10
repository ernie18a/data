Calculation: Confirmed swing high/low = a high/low that is the highest/lowest over equal numbers of bars on each side, confirmed only after the right-side bars have closed; ties use the most recent extreme.
Calculation: Latest unbroken swing high/low = the latest confirmed swing high/low, available until a close breaks it; a newly confirmed swing replaces the previous one.
Calculation: Bullish/bearish retest zone = the latest broken swing high/low plus and minus a multiple of ATR at the break; it becomes active on the break bar, replaces any zone on the same side, and deactivates on an opposite break, its first held retest, a close below/above its lower/upper boundary, or when its age exceeds a bar-count limit. Evaluate a held retest before expiry and invalidation on each bar.
Calculation: Session high/low = the highest high/lowest low accumulated during a configurable clock-time session in a specified timezone, retained until the next session starts.
Calculation: Higher-timeframe trend = on the last completed bar of a higher or equal timeframe, bullish when the shorter EMA of close > the longer EMA of close AND close > the longer EMA, bearish when the shorter EMA < the longer EMA AND close < the longer EMA; evaluate separately for multiple ordered timeframes.
Long: A newly confirmed swing high > the preceding confirmed swing high OR a newly confirmed swing low > the preceding confirmed swing low.
Short: A newly confirmed swing high <= the preceding confirmed swing high OR a newly confirmed swing low <= the preceding confirmed swing low.
Long: Close > the latest unbroken swing high.
Short: Close < the latest unbroken swing low AND no bullish swing break occurs on the same bar.
Long: A bullish retest zone is active AND the current bar is later than its break bar AND low <= its upper boundary AND close > open AND close > its upper boundary.
Short: A bearish retest zone is active AND the current bar is later than its break bar AND high >= its lower boundary AND close < open AND close < its lower boundary.
Long: On an intraday chart, low < the last completed higher-timeframe daily low AND close > that low AND no previous sweep of that low has occurred in the current day.
Short: On an intraday chart, high > the last completed higher-timeframe daily high AND close < that high AND no previous sweep of that high has occurred in the current day.
Long: On an intraday chart no longer than a configurable timeframe, the current bar is outside the session AND low < session low AND close > session low AND no previous sweep of that low has occurred since the session began.
Short: On an intraday chart no longer than a configurable timeframe, the current bar is outside the session AND high > session high AND close < session high AND no previous sweep of that high has occurred since the session began.
Long: Low > the high two bars earlier AND low minus that high >= a multiple of ATR.
Short: High < the low two bars earlier AND that low minus high >= a multiple of ATR.
Long: The shorter EMA of close > the longer EMA of close.
Short: The shorter EMA of close < the longer EMA of close.
Long: Close > a separate, longer EMA of close.
Short: Close < a separate, longer EMA of close.
Long: Higher-timeframe trend is bullish.
Short: Higher-timeframe trend is bearish.