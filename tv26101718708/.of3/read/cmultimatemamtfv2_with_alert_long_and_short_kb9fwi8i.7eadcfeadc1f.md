Calculation: M = selected SMA, EMA, WMA, Hull MA, VWMA, RMA, TEMA, or Tilson T3 of close using lookback L and, for Tilson T3, factor F × 0.1; calculated on T1 bars and mapped to chart bars from the T1 bar containing each chart bar (developing in real time, with its completed value mapped historically)
Calculation: B = SMA(close, L) on chart bars
Long: M >= M[S chart bars ago] AND close > B
Short: M < M[S chart bars ago] AND close < B
Exit: long, open > M AND close < M
Exit: short, open < M AND close > M