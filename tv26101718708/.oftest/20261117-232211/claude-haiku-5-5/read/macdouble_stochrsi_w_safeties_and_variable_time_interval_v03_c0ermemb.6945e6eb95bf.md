Calculation: ShortMacd = EMA(close, ShortFast) - EMA(close, ShortSlow), on chart bars
Calculation: ShortHist = ShortMacd - SMA(ShortMacd, ShortSig), on chart bars
Calculation: LongMacd = EMA(close, LongFast) - EMA(close, LongSlow), on T1 bars, with lookbacks longer than ShortMacd's
Calculation: LongHist = LongMacd - SMA(LongMacd, LongSig), on T1 bars; chart bars take the value of the still-forming T1 bar
Calculation: UpStep = (close + high) / (close[1] + high[2])
Calculation: DownStep = (close + low) / (close[1] + low[2])
Calculation: RsiStoch = 100 * (RSI(close, RsiLen) - Lowest(RSI(close, RsiLen), StochLen)) / (Highest(RSI(close, RsiLen), StochLen) - Lowest(RSI(close, RsiLen), StochLen)), on T2 bars
Calculation: StochK = SMA(RsiStoch, SmoothK), on T2 bars; chart bars take the value of the still-forming T2 bar
Calculation: StochD = SMA(StochK, SmoothD), on T2 bars; chart bars take the value of the still-forming T2 bar
Long: ShortHist > 0 AND year(datetime) > StartYear AND LongHist > 0 AND UpStep > 1 AND StochK <> 0 AND StochD < BuyLevel AND StochK > StochD
Short: ShortHist < 0 AND year(datetime) > StartYear AND LongHist < 0 AND DownStep < 1 AND StochK <> 0 AND StochD > SellLevel AND StochK < StochD
Exit: Short, High - EntryPrice >= StopShort