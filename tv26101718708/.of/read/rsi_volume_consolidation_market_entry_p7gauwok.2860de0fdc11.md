Calculation: RsiZone = (lo <= RSI(close) <= hi, inclusive) OR (50 < RSI(close) <= hi), where lo is below 50 and hi is above 50
Calculation: RsiRecovery = RSI(close) >= recovery floor (at or below lo) AND RSI(close) < a ceiling slightly above 50
Calculation: RsiRising = RSI > RSI 1 bar ago AND RSI 1 bar ago > RSI 2 bars ago
Calculation: VolumeOK = (for any of the last K bars including the current one: volume > SMA(volume, long lookback) at that bar * multiplier above 1) OR (volume > SMA(volume, long lookback) AND SMA(volume, short lookback) > SMA(volume, medium lookback)), where short < medium < long lookback
Calculation: Consolidating = the count of consecutive bars up to and including the current one with RangePct <= max percent is >= min bars, where RangePct = (highest high over N bars - lowest low over N bars) / lowest low over N bars * 100
Calculation: NearBreakout = close > (highest high over N bars + lowest low over N bars) / 2 AND close <= highest high over N bars * a factor slightly above 1, with the same N as in Consolidating
Calculation: ShortTrendUp = close > fast EMA(close) AND fast EMA(close) > slow EMA(close), where the fast EMA has a shorter lookback than the slow EMA
Calculation: LongTrendUp = fast EMA(close) > slow EMA(close) AND close > longest-lookback EMA(close)
Long: RsiZone AND RsiRising AND VolumeOK AND Consolidating AND NearBreakout AND ShortTrendUp
Long: (RsiZone OR RsiRecovery) AND VolumeOK AND Consolidating AND (LongTrendUp OR ShortTrendUp)
Long: Consolidating AND RsiZone AND RsiRising AND ShortTrendUp