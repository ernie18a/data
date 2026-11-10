Calculation: Upward break source = close or high, according to the break-confirmation setting; downward break source = close or low, using the same setting.
Calculation: Pivot high or low = a high or low confirmed with equal numbers of bars on each side. Maintain separate latest confirmed high and low levels for continuation, reversal, and internal pivots, with independently selectable strengths. Each new pivot resets its level's broken flag; a break sets that flag until the next pivot of the same type and side.
Calculation: External trend = initially 0. Once both a high and a low are available, initialize to 1 if close >= their midpoint, otherwise -1; use the latest reversal pivot for each side when available, otherwise the corresponding continuation pivot. On each bar after updating pivots and initializing, process these tests in order: if trend <= 0 and an unbroken reversal high exists and upward break source > that high, mark it broken and set trend to 1; if trend >= 0 and an unbroken reversal low exists and downward break source < that low, mark it broken and set trend to -1. Then, if trend = 1 and an unbroken continuation high exists and upward break source > that high and no upward reversal break occurred on this bar, mark it broken; if trend = -1 and an unbroken continuation low exists and downward break source < that low and no downward reversal break occurred on this bar, mark it broken. Evaluate each test using the state resulting from preceding tests on the same bar.
Calculation: Internal upward or downward break = upward break source > the latest unbroken internal pivot high, or downward break source < the latest unbroken internal pivot low, respectively. Mark each level broken on its first break, regardless of external trend or higher-timeframe filter.
Calculation: Higher-timeframe EMA = EMA of higher-timeframe closes, using the last completed higher-timeframe bar; on the chart bar that completes a higher-timeframe bar, use that newly completed bar.
Calculation: Master trend = external trend, except set it to 0 when the higher-timeframe veto is enabled, the higher-timeframe EMA is available, and either external trend = 1 AND close < higher-timeframe EMA, or external trend = -1 AND close > higher-timeframe EMA.
Long: External trend = 1.
Short: External trend = -1.
Long: Higher-timeframe bias display enabled AND higher-timeframe EMA available AND close > higher-timeframe EMA.
Short: Higher-timeframe bias display enabled AND higher-timeframe EMA available AND close <= higher-timeframe EMA.
Long: Master trend = 1.
Short: Master trend = -1.
Long: Upward reversal break occurred.
Short: Downward reversal break occurred.
Long: Upward continuation break occurred.
Short: Downward continuation break occurred.
Long: Internal upward break occurred AND master trend = 1.
Short: Internal downward break occurred AND master trend = -1.