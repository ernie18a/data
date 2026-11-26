Calculation: Opening-range high = highest high from session open through the opening-range duration
Calculation: Opening-range low = lowest low from session open through the opening-range duration
Long: crossover(close, opening-range high) after the opening-range duration ends
Short: crossunder(close, opening-range low) after the opening-range duration ends
Long: On chart bars, (crossover(close, VWAP(hlc3, T1, still-forming T1 bar)) AND RSI(close, P1, T1, still-forming T1 bar) > 50) OR (crossover(RSI(close, P1, T1, still-forming T1 bar), 50) AND close > VWAP(hlc3, T1, still-forming T1 bar))
Short: On chart bars, crossunder(close, VWAP(hlc3, T1, still-forming T1 bar)) AND RSI(close, P1, T1, still-forming T1 bar) < 50