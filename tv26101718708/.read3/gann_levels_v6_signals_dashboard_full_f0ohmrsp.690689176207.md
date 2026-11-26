Calculation: PivotPoint(T1, last completed bar) = (high + low + close) / 3
Calculation: PivotR1(T1, last completed bar) = 2 * PivotPoint(T1, last completed bar) - low
Calculation: PivotS1(T1, last completed bar) = 2 * PivotPoint(T1, last completed bar) - high
Calculation: SquareOfNine(x, step) = (sqrt(x) + step)^2
Long: close crosses above close(T1, last completed bar)
Long: close crosses above PivotPoint(T1, last completed bar)
Short: close crosses below close(T1, last completed bar)
Short: close crosses below PivotPoint(T1, last completed bar)
Exit: long, low <= SquareOfNine(close(T1, last completed bar), -step)
Exit: long, high >= SquareOfNine(close(T1, last completed bar), step)
Exit: short, high >= SquareOfNine(close(T1, last completed bar), step)
Exit: short, low <= SquareOfNine(close(T1, last completed bar), -step)
Exit: long, low <= PivotS1(T1, last completed bar)
Exit: long, high >= PivotR1(T1, last completed bar)
Exit: short, high >= PivotR1(T1, last completed bar)
Exit: short, low <= PivotS1(T1, last completed bar)