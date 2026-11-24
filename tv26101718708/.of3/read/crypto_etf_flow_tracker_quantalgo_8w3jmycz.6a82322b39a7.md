Calculation: NetFlow = on chart bars taking last completed T1 values, the sum of the selected funds' T1 fund flow for the latest recorded trading day, ignoring missing values, where with seed exclusion on a fund's first recorded flow counts as zero if it lies within a percent tolerance of that fund's seed capital
Calculation: NewFlowDay = on chart bars taking last completed T1 values, a trading day not yet recorded is appended to the fund-flow series
Long: NewFlowDay AND NetFlow > 0
Short: NewFlowDay AND NetFlow < 0
Long: NewFlowDay AND NetFlow >= LargeFlow
Short: NewFlowDay AND NetFlow <= -LargeFlow