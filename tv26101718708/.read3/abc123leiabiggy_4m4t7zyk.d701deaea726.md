Calculation: LowSweep = for some i in [1, level count], low < low_T1[i] AND low_T1[i] <= min(low[1..freshness window]), where low_T1[i] is the low of the i-th last completed T1 bar, read on chart bars
Calculation: HighSweep = for some i in [1, level count], high > high_T1[i] AND high_T1[i] >= max(high[1..freshness window]), where high_T1[i] is the high of the i-th last completed T1 bar, read on chart bars
Calculation: NewSweep = LowSweep OR HighSweep
Calculation: Locked = BullReady[1] OR BearReady[1]
Calculation: BullCandle = most recent bar j in [1, scan depth] with close[j] > open[j]
Calculation: BearCandle = most recent bar j in [1, scan depth] with close[j] < open[j]
Calculation: BullStart = LowSweep AND NOT HighSweep AND NOT Locked AND BullCandle is defined
Calculation: BearStart = HighSweep AND NOT Locked AND BearCandle is defined
Calculation: BullBase = if BullStart then max(high[j], high[j-1]) with j = BullCandle, else BullBase[1]
Calculation: BearBase = if BearStart then min(low[j], low[j-1]) with j = BearCandle, else BearBase[1]
Calculation: BullExtreme = if BullStart then min(low[0..j]) with j = BullCandle, else if BullArm[1] then min(BullExtreme[1], low), else BullExtreme[1]
Calculation: BearExtreme = if BearStart then max(high[0..j]) with j = BearCandle, else if BearArm[1] then max(BearExtreme[1], high), else BearExtreme[1]
Calculation: BullArm = BullStart OR (BullArm[1] AND NOT NewSweep AND high <= BullBase)
Calculation: BearArm = BearStart OR (BearArm[1] AND NOT NewSweep AND low >= BearBase)
Calculation: BullInv = BullBase + invalidation multiple * (BullBase - BullExtreme)
Calculation: BearInv = BearBase - invalidation multiple * (BearExtreme - BearBase)
Calculation: BullFib = BullBase + fib ratio * (BullExtreme - BullBase)
Calculation: BearFib = BearBase + fib ratio * (BearExtreme - BearBase)
Calculation: BullReady = (BullArm[1] AND NOT NewSweep AND high > BullBase) OR (BullReady[1] AND high <= BullInv AND NOT (low <= BullFib AND high >= BullFib))
Calculation: BearReady = (BearArm[1] AND NOT NewSweep AND low < BearBase) OR (BearReady[1] AND low >= BearInv AND NOT (low <= BearFib AND high >= BearFib))
Calculation: LongEntry = BullReady[1] AND high <= BullInv AND low <= BullFib AND high >= BullFib
Calculation: ShortEntry = BearReady[1] AND low >= BearInv AND low <= BearFib AND high >= BearFib
Calculation: LongStop = if LongEntry then BullExtreme, else LongStop[1]
Calculation: ShortStop = if ShortEntry then BearExtreme, else ShortStop[1]
Long: LongEntry
Short: ShortEntry
Exit: long, low <= LongStop OR high >= entry price + target multiple * (entry price - LongStop)
Exit: short, high >= ShortStop OR low <= entry price - target multiple * (ShortStop - entry price)