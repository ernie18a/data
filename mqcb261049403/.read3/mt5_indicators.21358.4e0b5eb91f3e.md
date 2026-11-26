Calculation: HalfTrend direction = HalfTrend(high, low, close, MA lookback, MA type, timeframe, bar state).direction
Calculation: HalfTrend line = HalfTrend(high, low, close, MA lookback, MA type, timeframe, bar state).line
Calculation: ATR offset = ATR(high, low, close, ATR lookback, timeframe, bar state) * ATR scale
Long: HalfTrend direction(chart MA lookback, chart MA type, chart timeframe, current bar) is bullish
Short: HalfTrend direction(chart MA lookback, chart MA type, chart timeframe, current bar) is bearish
Long: close > (HalfTrend line(chart MA lookback, chart MA type, chart timeframe, current bar) + ATR offset(ATR lookback, chart timeframe, current bar))[chart channel shift]
Short: close < (HalfTrend line(chart MA lookback, chart MA type, chart timeframe, current bar) - ATR offset(ATR lookback, chart timeframe, current bar))[chart channel shift]
Long: On chart bars using T1 values, HalfTrend direction(T1 MA lookback, T1 MA type, T1, still-forming bar) is bullish
Short: On chart bars using T1 values, HalfTrend direction(T1 MA lookback, T1 MA type, T1, still-forming bar) is bearish
Long: On chart bars using T1 values, close(T1, still-forming bar) > (HalfTrend line(T1 MA lookback, T1 MA type, T1, still-forming bar) + ATR offset(ATR lookback, T1, still-forming bar))[T1 channel shift]
Short: On chart bars using T1 values, close(T1, still-forming bar) < (HalfTrend line(T1 MA lookback, T1 MA type, T1, still-forming bar) - ATR offset(ATR lookback, T1, still-forming bar))[T1 channel shift]