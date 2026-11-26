Calculation: FastEMA(T) = EMA(close, fast lookback, on T bars, current/forming bar, mapped to chart bars)
Calculation: TrendEMA(T) = EMA(close, trend lookback, on T bars, current/forming bar, mapped to chart bars)
Calculation: PriorFastEMA(T,n) = EMA(close, fast lookback, on T bars, n completed bars ago, mapped to chart bars)
Calculation: PriorTrendEMA(T,n) = EMA(close, trend lookback, on T bars, n completed bars ago, mapped to chart bars)
Calculation: MediumEMA = EMA(close, medium lookback, on T3 bars, current/forming bar, mapped to chart bars)
Calculation: LongEMA = EMA(close, long lookback, on T3 bars, current/forming bar, mapped to chart bars)
Calculation: LongHighEMA = EMA(high, long lookback, on T3 bars, current/forming bar, mapped to chart bars)
Calculation: Take-profit distance = chart close on the entry-signal bar × take-profit percentage ÷ 100
Calculation: Stop-loss distance = chart close on the entry-signal bar × stop-loss percentage ÷ 100
Long: FastEMA(T1) > TrendEMA(T1) AND chart close > FastEMA(T1) AND close(T1, current/forming bar) > open(T1, current/forming bar) AND FastEMA(T2) > TrendEMA(T2) AND chart close > FastEMA(T2) AND close(T2, current/forming bar) > open(T2, current/forming bar) AND MediumEMA > LongEMA AND FastEMA(T3) > TrendEMA(T3) AND chart close > FastEMA(T3) AND close(T3, current/forming bar) > open(T3, current/forming bar) AND close(T3, current/forming bar) > LongHighEMA AND MediumEMA > LongHighEMA AND low(T3, 1 completed bar ago) <= PriorFastEMA(T3,1) AND (close(T3, current/forming bar) > high(T3, 1 completed bar ago) AND high(T3, 1 completed bar ago) < high(T3, 2 completed bars ago) OR enhanced-entry switch is on AND high(T3, 2 completed bars ago) < high(T3, 3 completed bars ago)) AND PriorFastEMA(T3,1) > PriorTrendEMA(T3,1) AND PriorFastEMA(T3,2) > PriorTrendEMA(T3,2) AND PriorFastEMA(T3,3) > PriorTrendEMA(T3,3)
Exit: Long, chart high >= entry price + take-profit distance OR chart low <= entry price - stop-loss distance