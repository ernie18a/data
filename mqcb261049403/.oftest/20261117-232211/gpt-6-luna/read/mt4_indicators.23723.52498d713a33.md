Calculation: Pivot = (high(T1, last completed bar) + low(T1, last completed bar) + close(T1, last completed bar)) / 3
Calculation: Resistance1 = 2 * Pivot - low(T1, last completed bar)
Calculation: Resistance2 = Pivot + high(T1, last completed bar) - low(T1, last completed bar)
Calculation: Resistance3 = high(T1, last completed bar) + 2 * (Pivot - low(T1, last completed bar))
Calculation: Support1 = 2 * Pivot - high(T1, last completed bar)
Long: (close(current chart bar) < Resistance1 AND close(current chart bar) > Pivot) OR (close(current chart bar) >= Resistance1 AND close(current chart bar) < Resistance2) OR (close(current chart bar) >= Resistance2 AND close(current chart bar) < Resistance3) OR close(current chart bar) >= Resistance3
Short: (close(current chart bar) > Support1 AND close(current chart bar) < Pivot) OR (close(current chart bar) <= Resistance1 AND close(current chart bar) > Resistance2) OR (close(current chart bar) <= Resistance2 AND close(current chart bar) > Resistance3)