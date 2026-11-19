Calculation: Source high = close when the basis parameter selects close, otherwise high
Calculation: Source low = close when the basis parameter selects close, otherwise low
Calculation: Structure trend(T) = neutral initially; on T bars retain the prior state, set UP if Source high > the latest confirmed PivotHigh(Source high, left-lookback parameter, right-lookback parameter), then set DOWN if Source low < the latest confirmed PivotLow(Source low, left-lookback parameter, right-lookback parameter), with DOWN taking precedence; the current T bar may still be forming
Long: On chart bars, a newly confirmed PivotHigh(Source high, left-lookback parameter, right-lookback parameter) > the prior confirmed pivot high
Long: On chart bars, a newly confirmed PivotLow(Source low, left-lookback parameter, right-lookback parameter) >= the prior confirmed pivot low
Short: On chart bars, a newly confirmed PivotHigh(Source high, left-lookback parameter, right-lookback parameter) <= the prior confirmed pivot high
Short: On chart bars, a newly confirmed PivotLow(Source low, left-lookback parameter, right-lookback parameter) < the prior confirmed pivot low
Long: On chart bars, Structure trend(T1, still-forming bar) = UP
Short: On chart bars, Structure trend(T1, still-forming bar) = DOWN
Long: On chart bars, Structure trend(T2, still-forming bar) = UP
Short: On chart bars, Structure trend(T2, still-forming bar) = DOWN
Long: On chart bars, Structure trend(T3, still-forming bar) = UP
Short: On chart bars, Structure trend(T3, still-forming bar) = DOWN
Long: On chart bars, Structure trend(T4, still-forming bar) = UP
Short: On chart bars, Structure trend(T4, still-forming bar) = DOWN
Long: On chart bars, Structure trend(T5, still-forming bar) = UP
Short: On chart bars, Structure trend(T5, still-forming bar) = DOWN
Long: On chart bars, Structure trend(T6, still-forming bar) = UP
Short: On chart bars, Structure trend(T6, still-forming bar) = DOWN
Long: On chart bars, Structure trend(T7, still-forming bar) = UP
Short: On chart bars, Structure trend(T7, still-forming bar) = DOWN
Long: On chart bars, Structure trend(T8, still-forming bar) = UP
Short: On chart bars, Structure trend(T8, still-forming bar) = DOWN
Long: On chart bars, Structure trend(T9, still-forming bar) = UP
Short: On chart bars, Structure trend(T9, still-forming bar) = DOWN