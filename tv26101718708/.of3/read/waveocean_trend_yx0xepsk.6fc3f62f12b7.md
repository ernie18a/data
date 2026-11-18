Calculation: Wave = WaveTrend(hlc3, channel lookback, average lookback, scaling factor), using the same parameters on chart bars and T1, T2, and T3 bars
Calculation: Signal = SMA(Wave, signal lookback)
Calculation: Wave(T) and Signal(T) are calculated on T bars and mapped to chart bars with lookahead off; they use the still-forming T bar in realtime and the completed T bar on historical bars
Long: Wave crosses above Signal
Short: Wave crosses below Signal
Long: Wave > Signal AND Wave(T1) > Signal(T1) AND Wave(T2) > Signal(T2) AND, when the mode parameter selects three-timeframe alignment, Wave(T3) > Signal(T3), and this alignment was false on the previous chart bar
Short: Wave < Signal AND Wave(T1) < Signal(T1) AND Wave(T2) < Signal(T2) AND, when the mode parameter selects three-timeframe alignment, Wave(T3) < Signal(T3), and this alignment was false on the previous chart bar