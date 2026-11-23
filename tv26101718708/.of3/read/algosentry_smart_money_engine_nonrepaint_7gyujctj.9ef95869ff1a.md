Calculation: SwingHigh = most recent non-NA PivotHigh(high, P, P)
Calculation: SwingLow = most recent non-NA PivotLow(low, P, P)
Calculation: BullFilter = NOT R OR close > EMA(close, E)
Calculation: BearFilter = NOT R OR close < EMA(close, E)
Calculation: BullBreak = close > SwingHigh AND BullFilter
Calculation: NewBullBreak = BullBreak AND no BullBreak on any bar from the most recent PivotHigh(high, P, P) confirmation through the previous bar
Calculation: BearBreak = close < SwingLow AND BearFilter
Calculation: NewBearBreak = BearBreak AND no BearBreak on any bar from the most recent PivotLow(low, P, P) confirmation through the previous bar
Calculation: BullSweep = low < SwingLow AND close > SwingLow AND BullFilter
Calculation: NewBullSweep = BullSweep AND no BullSweep on any bar from the most recent PivotLow(low, P, P) confirmation through the previous bar
Calculation: BearSweep = high > SwingHigh AND close < SwingHigh AND BearFilter
Calculation: NewBearSweep = BearSweep AND no BearSweep on any bar from the most recent PivotHigh(high, P, P) confirmation through the previous bar
Long: NewBullBreak
Long: NewBullBreak AND close[k] < open[k] for some k from 1 to O
Long: NewBullSweep
Long: low > high[2]
Long: PivotHigh(high, P, P) is not NA AND PivotHigh(high, P, P) > SwingHigh[1]
Long: PivotLow(low, P, P) is not NA AND PivotLow(low, P, P) > SwingLow[1]
Short: NewBearBreak
Short: NewBearBreak AND close[k] > open[k] for some k from 1 to O
Short: NewBearSweep
Short: high < low[2]
Short: PivotHigh(high, P, P) is not NA AND NOT PivotHigh(high, P, P) > SwingHigh[1]
Short: PivotLow(low, P, P) is not NA AND NOT PivotLow(low, P, P) > SwingLow[1]