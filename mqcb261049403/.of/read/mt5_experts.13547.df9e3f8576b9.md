Calculation: DiNapoli stochastic main line = recursively smooth 100 × (close − lowest low over the lookback) ÷ max(highest high − lowest low over the same lookback, one price point), with smoothing factor 1 ÷ the main-line smoothing period and initial value 50
Calculation: DiNapoli stochastic signal line = recursively smooth the main line with smoothing factor 1 ÷ the signal-line smoothing period and initial value 50
Long: On the configured indicator timeframe, the completed bar's main line > signal line AND the preceding completed bar's main line ≤ signal line
Short: On the configured indicator timeframe, the completed bar's main line < signal line AND the preceding completed bar's main line ≥ signal line
Exit: Short, On the configured indicator timeframe, the completed bar's main line > signal line
Exit: Long, On the configured indicator timeframe, the completed bar's main line < signal line