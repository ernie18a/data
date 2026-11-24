Calculation: LongTrend = trend filter disabled OR (close > EMA(close, shorter lookback) AND EMA(close, shorter lookback) >= EMA(close, longer lookback) AND close >= VWAP(hlc3))
Calculation: ShortTrend = trend filter disabled OR (close < EMA(close, shorter lookback) AND EMA(close, shorter lookback) <= EMA(close, longer lookback) AND close <= VWAP(hlc3))
Calculation: SignalGate = inside regular session AND bars since session open >= minimum-after-open parameter AND (date filter disabled OR datetime date = event date parameter) AND (confirmed-close filter disabled OR chart bar is confirmed)
Calculation: OpeningRangeHigh = highest high from session open through opening-range end, calculated on chart bars
Calculation: OpeningRangeLow = lowest low from session open through opening-range end, calculated on chart bars
Calculation: BearVIXConfirm = VIX close on chart-timeframe bars, using the bar still forming, >= bearish VIX threshold OR (VIX unavailable AND missing-VIX allowance enabled)
Calculation: BullEntry = SignalGate AND ((crosses above pin-reclaim level AND LongTrend AND VIX close < bearish VIX threshold) OR (crosses above risk-on reclaim level AND LongTrend AND VIX close < risk-on VIX threshold) OR (crosses above upper-breakout level AND LongTrend AND VIX close < bearish VIX threshold) OR (crosses above risk-on upper-confirmation level AND LongTrend AND VIX close < risk-on VIX threshold) OR (low <= bounce-hold level AND close > bounce-hold level AND close > EMA(close, shorter lookback) AND VIX close < bearish VIX threshold) OR (crosses above bull-confirmation level AND LongTrend AND VIX close < bearish VIX threshold AND (opening-range filter disabled OR opening range incomplete OR close >= OpeningRangeLow)) OR (opening range complete AND close crosses above OpeningRangeHigh AND close > pivot level AND LongTrend AND VIX close < bearish VIX threshold))
Long: BullEntry
Calculation: PutEntry = SignalGate AND BearVIXConfirm AND ((close crosses below bear-break level AND ShortTrend) OR (high > bull-confirmation level AND close < pivot level) OR (opening range complete AND close crosses below OpeningRangeLow AND close < pivot level AND ShortTrend))
Calculation: BearEntry = PutEntry OR (SignalGate AND BearVIXConfirm AND close crosses below bear-warning level) OR (SignalGate AND BearVIXConfirm AND high > pivot level AND close < pivot level)
Short: BearEntry
Option: buy call, BullEntry
Option: buy put, PutEntry
Exit: Long, close < reclaim-invalidation level
Exit: Long, close < bounce-invalidation level
Exit: Long, VIX close > long-volatility invalidation level
Exit: Short, close > short-reclaim invalidation level