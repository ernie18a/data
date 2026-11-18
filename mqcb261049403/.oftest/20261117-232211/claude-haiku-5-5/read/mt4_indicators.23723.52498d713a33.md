Calculation: Pivot = (High(T1, last completed bar) + Low(T1, last completed bar) + Close(T1, last completed bar)) / 3
Calculation: Resistance1 = 2 * Pivot - Low(T1, last completed bar)
Calculation: Resistance2 = Pivot + High(T1, last completed bar) - Low(T1, last completed bar)
Calculation: Resistance3 = High(T1, last completed bar) + 2 * (Pivot - Low(T1, last completed bar))
Calculation: Support1 = 2 * Pivot - High(T1, last completed bar)
Calculation: Support3 = Low(T1, last completed bar) - 2 * (High(T1, last completed bar) - Pivot)
Long: close > Pivot AND close < Resistance1
Long: close >= Resistance1 AND close < Resistance2
Long: close >= Resistance2 AND close < Resistance3
Long: close >= Resistance3
Short: close > Support1 AND close < Pivot
Short: close <= Support3