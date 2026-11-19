Calculation: OT source = Heikin-Ashi close when enabled; otherwise close
Calculation: OT trailing stop = with previous stop defaulting to 0, if OT source > previous stop AND OT source[1] > previous stop then max(previous stop, OT source - sensitivity * ATR(ATR lookback)); else if OT source < previous stop AND OT source[1] < previous stop then min(previous stop, OT source + sensitivity * ATR(ATR lookback)); else if OT source > previous stop then OT source - sensitivity * ATR(ATR lookback)); otherwise OT source + sensitivity * ATR(ATR lookback)
Calculation: Dashboard trend(T) = Up when EMA(close, fast lookback, T) > EMA(close, slow lookback, T) AND EMA(close, fast lookback, T) > EMA(close, fast lookback, T)[slope lookback] AND abs(EMA(close, fast lookback, T) - EMA(close, slow lookback, T)) / close(T) > minimum separation AND ADX(DI lookback, ADX smoothing, T) >= ADX minimum; Down when the corresponding comparisons are reversed and ADX is at least ADX minimum; otherwise Side; evaluated on chart bars using current T bar values with lookahead off (the T bar may still be forming)
Calculation: Trend score(T) = 1 when Dashboard trend(T) is Up, -1 when it is Down, and 0 when it is Side
Calculation: Dashboard average = Up when the sum of Trend score(T1) through Trend score(T7) is at least the vote threshold, Down when the sum is at most the negative vote threshold, and Side otherwise
Long: OT source crosses above OT trailing stop AND Supertrend(factor, ATR lookback) direction is bullish AND ADX(DI lookback, ADX smoothing) >= ADX minimum AND ADX(DI lookback, ADX smoothing) <= ADX maximum AND Dashboard average is Up
Short: OT source crosses below OT trailing stop AND Supertrend(factor, ATR lookback) direction is bearish AND ADX(DI lookback, ADX smoothing) >= ADX minimum AND ADX(DI lookback, ADX smoothing) <= ADX maximum AND Dashboard average is Down
Long: Dashboard trend(T1) is Up
Long: Dashboard trend(T2) is Up
Long: Dashboard trend(T3) is Up
Long: Dashboard trend(T4) is Up
Long: Dashboard trend(T5) is Up
Long: Dashboard trend(T6) is Up
Long: Dashboard trend(T7) is Up
Short: Dashboard trend(T1) is Down
Short: Dashboard trend(T2) is Down
Short: Dashboard trend(T3) is Down
Short: Dashboard trend(T4) is Down
Short: Dashboard trend(T5) is Down
Short: Dashboard trend(T6) is Down
Short: Dashboard trend(T7) is Down
Long: Dashboard average is Up
Short: Dashboard average is Down
Exit: long, low <= Supertrend(factor, ATR lookback) line - stop offset OR low <= OT trailing stop - stop offset
Exit: short, high >= Supertrend(factor, ATR lookback) line + stop offset
Exit: long, close < SMA(close, exit lookback) - significance margin
Exit: short, close > SMA(close, exit lookback) + significance margin