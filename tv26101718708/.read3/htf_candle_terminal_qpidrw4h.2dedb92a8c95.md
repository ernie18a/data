Calculation: T1CurOpen = open(T1, forming bar), sampled on chart bars
Calculation: T1LastOpen = open(T1, last completed bar), sampled on chart bars
Calculation: T1LastHigh = high(T1, last completed bar), sampled on chart bars
Calculation: T1LastLow = low(T1, last completed bar), sampled on chart bars
Calculation: T1ATR = ATR(high, low, close, P4) on T1 bars, last completed bar, sampled on chart bars
Calculation: T1StartADR = ADR(high, low, P5) on chart bars, evaluated at T1 start
Calculation: T1VWAP = VWAP on chart bars, anchored at T1 start
Calculation: BinWidth = tick size * max(1, round((T1LastHigh - T1LastLow) / (P2 * tick size)))
Calculation: BullPOC = the bin round(hlc3 / BinWidth) * BinWidth with the highest summed volume over chart bars where hlc3 >= T1CurOpen, counted from the later of T1 start and the bar after the latest BullBreakout before the current bar, through the current bar
Calculation: BearPOC = the bin round(hlc3 / BinWidth) * BinWidth with the highest summed volume over chart bars where hlc3 < T1CurOpen, counted from the later of T1 start and the bar after the latest BearBreakout before the current bar, through the current bar
Calculation: BullBreakout = low <= BearPOC AND close > BullPOC
Calculation: BearBreakout = high >= BullPOC AND close < BearPOC
Calculation: LowBelowOpen = min(low over chart bars since T1 start) < T1CurOpen
Short: high > T1LastHigh AND high[1] <= T1LastHigh
Long: low < T1LastLow AND low[1] >= T1LastLow
Long: close >= T1CurOpen
Short: close < T1CurOpen
Long: (bars since T1 start >= 1 OR minutes since T1 start >= P1) AND (NOT LowBelowOpen OR close > T1CurOpen)
Short: (bars since T1 start >= 1 OR minutes since T1 start >= P1) AND LowBelowOpen AND (max(high over chart bars since T1 start) <= T1CurOpen OR close < T1CurOpen)
Long: close > T1VWAP
Short: close < T1VWAP
Long: BullBreakout
Short: BearBreakout
Exit: long, high >= T1CurOpen * T1LastHigh / T1LastOpen OR high >= T1CurOpen + P3 * T1ATR OR high >= T1CurOpen + T1StartADR
Exit: short, low <= T1CurOpen * T1LastLow / T1LastOpen OR low <= T1CurOpen - P3 * T1ATR OR low <= T1CurOpen - T1StartADR