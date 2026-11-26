Calculation: DisplacementCross = ROC(open, displacement lookback) crosses above displacement threshold OR ROC(open, displacement lookback) crosses below negative displacement threshold
Calculation: BullOB = ROC(open, displacement lookback) crosses above displacement threshold AND no DisplacementCross in the previous spacing bars
Calculation: BearOB = ROC(open, displacement lookback) crosses below negative displacement threshold AND no DisplacementCross in the previous spacing bars
Calculation: BullOBTop = high[k] on each bar where BullOB, where k is the first offset j from order block search start through order block search end with close[j] < open[j], or order block search start if none
Calculation: BullOBBottom = low[k] on each bar where BullOB, with k as in BullOBTop
Calculation: BearOBTop = high[k] on each bar where BearOB, where k is the first offset j from order block search start through order block search end with close[j] > open[j], or order block search start if none
Calculation: BearOBBottom = low[k] on each bar where BearOB, with k as in BearOBTop
Calculation: BullMitigation = close[1] if mitigation type is close-based, else low
Calculation: BearMitigation = close[1] if mitigation type is close-based, else high
Calculation: EquilibriumLevel(T) = (high(T, last completed bar) + low(T, last completed bar)) / 2
Calculation: UpperADRBand(n) = open(T1, forming bar) + ADR(n, T1, last completed bar) / 2
Calculation: LowerADRBand(n) = open(T1, forming bar) - ADR(n, T1, last completed bar) / 2
Calculation: BullFractal = high[p] on each bar where sum(sign(high - high[1]), p) = -p AND sum(sign(high - high[1]), p)[p] = p, where p = floor(fractal length / 2)
Calculation: BearFractal = low[p] on each bar where sum(sign(low - low[1]), p) = p AND sum(sign(low - low[1]), p)[p] = -p, where p = floor(fractal length / 2)
Calculation: BullBreak = close crosses above the latest BullFractal for the first time since that BullFractal was set
Calculation: BearBreak = close crosses below the latest BearFractal for the first time since that BearFractal was set
Calculation: TrailingSupport = lowest low from the bar after the pivot bar of the latest BullFractal through the previous bar, updated on each bar where BullBreak is true
Calculation: TrailingResistance = highest high from the bar after the pivot bar of the latest BearFractal through the previous bar, updated on each bar where BearBreak is true
Long: BullOB
Long: for some bar c up to the current bar, BullOB(c) AND low < BullOBTop(c) AND BullMitigation >= BullOBBottom(c) on each bar from c through the current bar
Long: low - high[2] > minimum gap in ticks * tick size AND close[1] > high[2]
Long: close crosses above EquilibriumLevel(T2) OR close crosses above EquilibriumLevel(T3), with T2 longer than T3
Long: close crosses above UpperADRBand(longer ADR lookback) OR close crosses above UpperADRBand(shorter ADR lookback)
Long: BullBreak
Long: close > TrailingResistance for the first time since TrailingResistance was updated AND BearBreak is false on this bar
Short: BearOB
Short: for some bar c up to the current bar, BearOB(c) AND high > BearOBBottom(c) AND BearMitigation <= BearOBTop(c) on each bar from c through the current bar
Short: low[2] - high > minimum gap in ticks * tick size AND close[1] < low[2]
Short: close crosses below EquilibriumLevel(T2) OR close crosses below EquilibriumLevel(T3), with T2 longer than T3
Short: close crosses below LowerADRBand(longer ADR lookback) OR close crosses below LowerADRBand(shorter ADR lookback)
Short: BearBreak
Short: close < TrailingSupport for the first time since TrailingSupport was updated AND BullBreak is false on this bar