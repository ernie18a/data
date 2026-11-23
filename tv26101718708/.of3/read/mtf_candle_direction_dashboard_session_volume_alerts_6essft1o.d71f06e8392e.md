Calculation: FilteredCandleDirection(T, bar) = sign(close - open) if abs(close - open) >= body multiplier * ATR(ATR lookback) else 0, computed on bars of T
Calculation: CandleDirection(T, bar) = sign(close - open), computed on bars of T
Long: new T4 bar opens AND FilteredCandleDirection(T4, last completed bar) = 1 AND FilteredCandleDirection(T4, last completed bar)[1] = -1
Short: new T4 bar opens AND FilteredCandleDirection(T4, last completed bar) = -1 AND FilteredCandleDirection(T4, last completed bar)[1] = 1
Long: new T5 bar opens AND FilteredCandleDirection(T5, last completed bar) = 1 AND FilteredCandleDirection(T5, last completed bar)[1] = -1
Short: new T5 bar opens AND FilteredCandleDirection(T5, last completed bar) = -1 AND FilteredCandleDirection(T5, last completed bar)[1] = 1
Long: new T6 bar opens AND FilteredCandleDirection(T6, last completed bar) = 1 AND FilteredCandleDirection(T6, last completed bar)[1] = -1
Short: new T6 bar opens AND FilteredCandleDirection(T6, last completed bar) = -1 AND FilteredCandleDirection(T6, last completed bar)[1] = 1
Long: ROC(close, ROC lookback, T8, forming bar) > upper ROC threshold AND ROC(close, ROC lookback, T8, last completed bar) <= upper ROC threshold
Short: ROC(close, ROC lookback, T8, forming bar) < lower ROC threshold AND ROC(close, ROC lookback, T8, last completed bar) >= lower ROC threshold
Exit: long, ROC(close, ROC lookback, T8, forming bar) > 0 AND ROC(close, ROC lookback, T8, forming bar) < ROC(close, ROC lookback, T8, last completed bar) AND ROC(close, ROC lookback, T8, forming bar) < stretched level
Exit: short, ROC(close, ROC lookback, T8, forming bar) < 0 AND ROC(close, ROC lookback, T8, forming bar) > ROC(close, ROC lookback, T8, last completed bar) AND ROC(close, ROC lookback, T8, forming bar) > -stretched level
Long: ROC(close, ROC lookback, T8, forming bar) > 0 OR ROC(close, ROC lookback, T8, last completed bar) > 0
Short: ROC(close, ROC lookback, T8, forming bar) < 0 OR ROC(close, ROC lookback, T8, last completed bar) < 0
Long: CandleDirection(T1, forming bar) = 1 OR CandleDirection(T1, last completed bar) = 1
Short: CandleDirection(T1, forming bar) = -1 OR CandleDirection(T1, last completed bar) = -1
Long: CandleDirection(T2, forming bar) = 1 OR CandleDirection(T2, last completed bar) = 1
Short: CandleDirection(T2, forming bar) = -1 OR CandleDirection(T2, last completed bar) = -1
Long: CandleDirection(T3, forming bar) = 1 OR CandleDirection(T3, last completed bar) = 1
Short: CandleDirection(T3, forming bar) = -1 OR CandleDirection(T3, last completed bar) = -1
Long: CandleDirection(T4, forming bar) = 1 OR CandleDirection(T4, last completed bar) = 1
Short: CandleDirection(T4, forming bar) = -1 OR CandleDirection(T4, last completed bar) = -1
Long: CandleDirection(T5, forming bar) = 1 OR CandleDirection(T5, last completed bar) = 1
Short: CandleDirection(T5, forming bar) = -1 OR CandleDirection(T5, last completed bar) = -1
Long: CandleDirection(T6, forming bar) = 1 OR CandleDirection(T6, last completed bar) = 1
Short: CandleDirection(T6, forming bar) = -1 OR CandleDirection(T6, last completed bar) = -1
Long: CandleDirection(T7, forming bar) = 1 OR CandleDirection(T7, last completed bar) = 1
Short: CandleDirection(T7, forming bar) = -1 OR CandleDirection(T7, last completed bar) = -1