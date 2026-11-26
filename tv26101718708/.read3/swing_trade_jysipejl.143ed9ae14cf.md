Calculation: Pivot point(T1 bar) = (high + low + close) / 3
Calculation: Rising pivot filter(T1 bar) = Pivot point(T1 bar) > (Pivot point(T1 bar) + Pivot point(previous T1 bar)) / 2 + pivot-filter threshold
Calculation: Falling pivot filter(T1 bar) = Pivot point(T1 bar) < (Pivot point(T1 bar) + Pivot point(previous T1 bar)) / 2 - pivot-filter threshold
Calculation: First resistance(T1 bar) = if filtered pivots are enabled and Falling pivot filter then Pivot point + Pivot point - low else if filtered pivots are enabled and Rising pivot filter then Pivot point + high - low else Pivot point + Pivot point - low
Calculation: First support(T1 bar) = if filtered pivots are enabled and Rising pivot filter then Pivot point - (high - Pivot point) else if filtered pivots are enabled and Falling pivot filter then Pivot point - (high - low) else Pivot point - (high - Pivot point)
Calculation: Second resistance(T1 bar) = unavailable if filtered pivots are enabled, otherwise Pivot point + high - low
Calculation: Second support(T1 bar) = unavailable if filtered pivots are enabled, otherwise Pivot point - (high - low)
Calculation: CPR lower line(T1 bar) = (high + low) / 2
Calculation: CPR upper line(T1 bar) = 2 * Pivot point - CPR lower line
Long: low < Pivot point(T1, last completed bar) OR low < First support(T1, last completed bar), AND Pivot point(T1, last completed bar) > its value on the previous chart bar, on chart bars
Short: (high > Pivot point(T1, last completed bar) OR high < First resistance(T1, last completed bar)) AND Pivot point(T1, last completed bar) < its value on the previous chart bar, on chart bars
Long: close on the previous chart bar > Second resistance(T1, last completed bar value on the previous chart bar) AND (low < CPR upper line(T1, last completed bar) OR low < CPR lower line(T1, last completed bar) OR low < First support(T1, last completed bar)), on chart bars
Short: close on the previous chart bar < Second support(T1, last completed bar value on the previous chart bar) AND (high > CPR lower line(T1, last completed bar) OR high > CPR upper line(T1, last completed bar) OR high > First resistance(T1, last completed bar)), on chart bars
Long: close > Second resistance(T1, last completed bar), on chart bars
Short: close < Second support(T1, last completed bar), on chart bars
Long: close > Second resistance(T1, last completed bar) AND open > Pivot point(T1, last completed bar) AND low < Pivot point(T1, last completed bar), on chart bars
Long: close > Second resistance(T1, last completed bar) AND low < First support(T1, last completed bar), on chart bars
Short: close < Second support(T1, last completed bar) AND open < Pivot point(T1, last completed bar) AND high > Pivot point(T1, last completed bar), on chart bars
Short: close < Second support(T1, last completed bar) AND high > First resistance(T1, last completed bar), on chart bars
Exit: long, low <= First support(T1, last completed bar), on chart bars
Exit: short, high >= First resistance(T1, last completed bar), on chart bars
Exit: long, close < First support(T1, last completed bar), on T2 bars
Exit: short, close > First resistance(T1, last completed bar), on T2 bars