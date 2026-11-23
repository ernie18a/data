Calculation: RecentHighPivot = PivotHigh(high, swing lookback, swing lookback) when a pivot high is confirmed, else RecentHighPivot[1]
Calculation: PriorHighPivot = RecentHighPivot[1] when a pivot high is confirmed, else PriorHighPivot[1]
Calculation: RecentLowPivot = PivotLow(low, swing lookback, swing lookback) when a pivot low is confirmed, else RecentLowPivot[1]
Calculation: PriorLowPivot = RecentLowPivot[1] when a pivot low is confirmed, else PriorLowPivot[1]
Calculation: HigherTimeframeBullish = EMA(close, T1 shorter lookback, T1 bars, last completed bar) > EMA(close, T1 longer lookback, T1 bars, last completed bar)
Calculation: HigherTimeframeBearish = EMA(close, T1 shorter lookback, T1 bars, last completed bar) < EMA(close, T1 longer lookback, T1 bars, last completed bar)
Calculation: BullishTrend = (((EMA(close, shorter lookback) > EMA(close, longer lookback) AND EMA(close, shorter lookback) > EMA(close, shorter lookback)[1] AND EMA(close, longer lookback) > EMA(close, longer lookback)[1]) AND RecentHighPivot > PriorHighPivot AND RecentLowPivot > PriorLowPivot) OR close > RecentHighPivot + ATR(ATR lookback) * break buffer) AND (T1 bias filter disabled OR HigherTimeframeBullish)
Calculation: BearishTrend = (((EMA(close, shorter lookback) < EMA(close, longer lookback) AND EMA(close, shorter lookback) < EMA(close, shorter lookback)[1] AND EMA(close, longer lookback) < EMA(close, longer lookback)[1]) AND RecentHighPivot < PriorHighPivot AND RecentLowPivot < PriorLowPivot) OR close < RecentLowPivot - ATR(ATR lookback) * break buffer) AND (T1 bias filter disabled OR HigherTimeframeBearish)
Calculation: TrendPhase = 1 when BullTrendStart, else -1 when BearTrendStart, else 0 when NOT BullishTrend AND NOT BearishTrend, else TrendPhase[1]
Calculation: BullTrendStart = BullishTrend AND TrendPhase[1] != 1
Calculation: BearTrendStart = BearishTrend AND TrendPhase[1] != -1
Calculation: HighLevelT2 = high[1] on T2 bars, value from last completed T2 bar
Calculation: HighLevelT3 = high[1] on T3 bars, value from last completed T3 bar
Calculation: LowLevelT2 = low[1] on T2 bars, value from last completed T2 bar
Calculation: LowLevelT3 = low[1] on T3 bars, value from last completed T3 bar
Calculation: LongSetup = long entries enabled AND (BullishTrend AND low <= MAX(EMA(close, shorter lookback), EMA(close, longer lookback)) + ATR(ATR lookback) * pullback width AND close >= EMA(close, longer lookback))[1] AND close > EMA(close, shorter lookback) AND close > high[1] AND close > open AND (close - open) >= body fraction * (high - low) AND (session filter disabled OR bar time within session window) AND (level filter disabled OR (NOT (close < HighLevelT2 AND HighLevelT2 - close <= ATR(ATR lookback) * minimum room) AND NOT (close < HighLevelT3 AND HighLevelT3 - close <= ATR(ATR lookback) * minimum room)))
Calculation: ShortSetup = short entries enabled AND (BearishTrend AND high >= MIN(EMA(close, shorter lookback), EMA(close, longer lookback)) - ATR(ATR lookback) * pullback width AND close <= EMA(close, longer lookback))[1] AND close < EMA(close, shorter lookback) AND close < low[1] AND open > close AND (open - close) >= body fraction * (high - low) AND (session filter disabled OR bar time within session window) AND (level filter disabled OR (NOT (close > LowLevelT2 AND close - LowLevelT2 <= ATR(ATR lookback) * minimum room) AND NOT (close > LowLevelT3 AND close - LowLevelT3 <= ATR(ATR lookback) * minimum room)))
Calculation: LongArmState = (BullTrendStart OR (LongArmState[1] AND NOT BearTrendStart)) AND NOT LongSetup
Calculation: ShortArmState = ((BearTrendStart OR ShortArmState[1]) AND NOT BullTrendStart) AND NOT ShortSetup
Long: LongSetup AND (first entry only disabled OR BullTrendStart OR (LongArmState[1] AND NOT BearTrendStart))
Short: ShortSetup AND (first entry only disabled OR ((BearTrendStart OR ShortArmState[1]) AND NOT BullTrendStart))
Long: BullTrendStart
Short: BearTrendStart
Long: BullishTrend
Short: BearishTrend
Long: HigherTimeframeBullish
Short: HigherTimeframeBearish
Exit: long, BullishTrend AND close < EMA(close, shorter lookback)
Exit: short, BearishTrend AND close > EMA(close, shorter lookback)