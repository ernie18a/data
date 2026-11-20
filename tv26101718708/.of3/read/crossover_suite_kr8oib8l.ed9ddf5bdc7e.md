Calculation: Selected MA = JMA(source, lookback, phase parameter), ALMA(source, lookback, offset parameter, sigma parameter), KAMA(source, lookback, fast smoothing parameter, slow smoothing parameter), FRAMA(source, lookback), MAMA(source), or FAMA(source), selected by an MA type parameter
Calculation: Entry fast MA = Selected MA(selected source, separate entry fast type and lookback parameters) on chart bars, with a shorter lookback than entry slow MA
Calculation: Entry slow MA = Selected MA(selected source, separate entry slow type and lookback parameters) on chart bars, with a longer lookback than entry fast MA
Calculation: Exit fast MA = Selected MA(selected source, separate exit fast type and lookback parameters) on chart bars, with a shorter lookback than exit slow MA
Calculation: Exit slow MA = Selected MA(selected source, separate exit slow type and lookback parameters) on chart bars, with a longer lookback than exit fast MA
Calculation: T1 entry fast MA = Selected MA(close, entry fast type and lookback parameters), computed on the still-forming T1 bar and sampled on chart bars
Calculation: T1 entry slow MA = Selected MA(close, entry slow type and lookback parameters), computed on the still-forming T1 bar and sampled on chart bars
Long: (crossover(Entry fast MA, Entry slow MA) AND T1 entry fast MA > T1 entry slow MA) OR crossover(Entry fast MA, Exit fast MA) OR crossover(Entry fast MA, Exit slow MA) OR crossover(Entry slow MA, Exit fast MA)
Short: (crossunder(Entry fast MA, Entry slow MA) AND T1 entry fast MA <= T1 entry slow MA) OR crossunder(Entry fast MA, Exit fast MA) OR crossunder(Entry fast MA, Exit slow MA) OR crossunder(Entry slow MA, Exit fast MA)
Exit: long, crossunder(Exit fast MA, Exit slow MA)
Exit: short, crossover(Exit fast MA, Exit slow MA)