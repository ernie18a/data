Calculation: StackUp = EMA(close, shortest lookback) > EMA(close, shorter lookback) AND EMA(close, shorter lookback) > EMA(close, longer lookback) AND EMA(close, longer lookback) > EMA(close, longest lookback)
Calculation: StackDown = EMA(close, shortest lookback) < EMA(close, shorter lookback) AND EMA(close, shorter lookback) < EMA(close, longer lookback) AND EMA(close, longer lookback) < EMA(close, longest lookback)
Calculation: Sideways = NOT StackUp AND NOT StackDown
Calculation: StackUpAt(T) = EMA(close, shortest lookback, T, last completed bar) > EMA(close, shorter lookback, T, last completed bar) AND EMA(close, shorter lookback, T, last completed bar) > EMA(close, longer lookback, T, last completed bar) AND EMA(close, longer lookback, T, last completed bar) > EMA(close, longest lookback, T, last completed bar)
Calculation: StackDownAt(T) = EMA(close, shortest lookback, T, last completed bar) < EMA(close, shorter lookback, T, last completed bar) AND EMA(close, shorter lookback, T, last completed bar) < EMA(close, longer lookback, T, last completed bar) AND EMA(close, longer lookback, T, last completed bar) < EMA(close, longest lookback, T, last completed bar)
Long: StackUp AND NOT StackUp[1]
Long: StackUp
Long: close > close[1]
Long: StackUpAt(T1)
Long: StackUpAt(T2)
Long: StackUpAt(T3)
Long: StackUpAt(T4)
Long: StackUpAt(T5)
Long: StackUpAt(T6)
Long: EMA(close, shortest lookback) > EMA(close, shortest lookback)[1]
Long: EMA(close, shorter lookback) > EMA(close, shorter lookback)[1]
Long: EMA(close, longer lookback) > EMA(close, longer lookback)[1]
Long: EMA(close, longest lookback) > EMA(close, longest lookback)[1]
Short: StackDown AND NOT StackDown[1]
Short: StackDown
Short: close <= close[1]
Short: StackDownAt(T1)
Short: StackDownAt(T2)
Short: StackDownAt(T3)
Short: StackDownAt(T4)
Short: StackDownAt(T5)
Short: StackDownAt(T6)
Short: EMA(close, shortest lookback) < EMA(close, shortest lookback)[1]
Short: EMA(close, shorter lookback) < EMA(close, shorter lookback)[1]
Short: EMA(close, longer lookback) < EMA(close, longer lookback)[1]
Short: EMA(close, longest lookback) < EMA(close, longest lookback)[1]
Exit: Long, StackUp[1] AND Sideways
Exit: Short, StackDown[1] AND Sideways