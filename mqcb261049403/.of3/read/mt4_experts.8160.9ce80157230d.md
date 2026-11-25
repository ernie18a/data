Calculation: VQ direction = previous direction when filter > 0 and abs(Volatility Quality Index) < filter * minimum price increment or Volatility Quality Index = 0; otherwise up when Volatility Quality Index > 0 and down when Volatility Quality Index < 0, using the selected moving-average method, length, smoothing, and close or median source; on chart bars, use the still-forming T1 bar when T1 is configured, otherwise the still-forming chart bar
Long: VQ direction = up
Long: VQ direction changes from down to up
Short: VQ direction = down
Short: VQ direction changes from up to down