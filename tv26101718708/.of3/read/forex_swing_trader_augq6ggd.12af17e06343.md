Calculation: T1 line = selected moving average of close over the lookback on T1 bars (type parameter: SMA, EMA, WMA, HMA, VWMA, RMA, TEMA, or Tilson T3 with a T3-factor parameter), read on chart bars from the current T1 bar, which may still be forming
Calculation: T2 line = T1 line sampled on T2 bars, read on chart bars from the current T2 bar, which may still be forming
Long: date-range and session filters pass AND (reversed direction mode AND T1 line crosses below T2 line OR direct direction mode AND T1 line crosses above T2 line)
Short: date-range and session filters pass AND (reversed direction mode AND T1 line crosses above T2 line OR direct direction mode AND T1 line crosses below T2 line)
Exit: long, distance exit is enabled AND T2 line / T1 line > distance threshold
Exit: short, distance exit is enabled AND T1 line / T2 line > distance threshold