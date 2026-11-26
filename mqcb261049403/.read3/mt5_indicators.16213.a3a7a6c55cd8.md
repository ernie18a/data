Calculation: Chart Smoothed BOP = 100 × XMA((close − open) / (high − low), with value 0 when high = low, chart method, chart phase, chart lookback)
Calculation: T1 Smoothed BOP = 100 × XMA((close − open) / (high − low), with value 0 when high = low, T1 method, T1 phase, T1 lookback)
Long: Chart Smoothed BOP > 0 AND Chart Smoothed BOP != Chart Smoothed BOP[1]
Short: Chart Smoothed BOP < 0 AND Chart Smoothed BOP != Chart Smoothed BOP[1]
Long: On chart bars using the still-forming T1 bar, T1 Smoothed BOP > 0 AND T1 Smoothed BOP != its value on the previous T1 bar
Short: On chart bars using the still-forming T1 bar, T1 Smoothed BOP < 0 AND T1 Smoothed BOP != its value on the previous T1 bar