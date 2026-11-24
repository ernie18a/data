Calculation: BullOB = range with bottom low[1] and top high[1] when use-OB AND close[1] < open[1] AND close > high[1] AND (NOT use-displacement OR close - open > ATR(atr lookback) * displacement multiple); otherwise none
Calculation: BearOB = range with bottom low[1] and top high[1] when use-OB AND close[1] > open[1] AND close < low[1] AND (NOT use-displacement OR open - close > ATR(atr lookback) * displacement multiple); otherwise none
Calculation: BullSet = newest (OB count) of: BullSet[1] ranges whose bottom <= (close if mitigate-on-close else low), together with BullOB
Calculation: BearSet = newest (OB count) of: BearSet[1] ranges whose top >= (close if mitigate-on-close else high), together with BearOB
Calculation: BullNearHigh = some range in BullSet has high[2] >= bottom - m AND high[2] <= top + m, where m = ATR(atr lookback) * OB proximity multiple
Calculation: BullNearLow = some range in BullSet has low[2] >= bottom - m AND low[2] <= top + m, where m = ATR(atr lookback) * OB proximity multiple
Calculation: BearNearHigh = some range in BearSet has high[2] >= bottom - m AND high[2] <= top + m, where m = ATR(atr lookback) * OB proximity multiple
Calculation: BearNearLow = some range in BearSet has low[2] >= bottom - m AND low[2] <= top + m, where m = ATR(atr lookback) * OB proximity multiple
Calculation: BullTouch = some range in BullSet has low <= top + m AND high >= bottom - m, where m = ATR(atr lookback) * OB proximity multiple
Calculation: BearTouch = some range in BearSet has low <= top + m AND high >= bottom - m, where m = ATR(atr lookback) * OB proximity multiple
Calculation: Armed = NOT BuySetup AND NOT SellSetup AND NOT LongConfirm AND NOT ShortConfirm
Calculation: BuySetup = Armed[1] AND low < low[1] AND high <= high[1] AND close >= low[1] AND close <= high[1]
Calculation: SellSetup = Armed[1] AND high > high[1] AND low >= low[1] AND close >= low[1] AND close <= high[1]
Calculation: LongFilter = NOT use-MA-filter OR close > SMA(close, MA lookback, T1, last completed bar) OR BullNearHigh OR (MA-bypass-on-OB-touch AND (BullTouch[1] OR BullTouch[2]))
Calculation: ShortFilter = NOT use-MA-filter OR close < SMA(close, MA lookback, T1, last completed bar) OR BearNearLow OR (MA-bypass-on-OB-touch AND (BearTouch[1] OR BearTouch[2]))
Calculation: LongConfirm = BuySetup[1] AND high >= high[2] + ATR(atr lookback) * breakout buffer AND LongFilter
Calculation: ShortConfirm = SellSetup[1] AND low <= low[2] - ATR(atr lookback) * breakout buffer AND ShortFilter
Calculation: LongSuppressed = suppress-on-warning AND BearNearHigh
Calculation: ShortSuppressed = suppress-on-warning AND BullNearLow
Calculation: LongStop = low[2] - ATR(atr lookback) * stop multiple, taken at the latest long entry bar
Calculation: ShortStop = high[2] + ATR(atr lookback) * stop multiple, taken at the latest short entry bar
Calculation: LongTarget = entry price + (entry price - LongStop) * reward-to-risk
Calculation: ShortTarget = entry price - (ShortStop - entry price) * reward-to-risk
Long: LongConfirm AND NOT LongSuppressed AND position side is not short
Short: ShortConfirm AND NOT ShortSuppressed AND position side is not long
Exit: long, low <= LongStop OR high >= LongTarget
Exit: short, high >= ShortStop OR low <= ShortTarget