Calculation: StartPrice = open of the first bar of the most recent session
Calculation: SessionSpan = highest high minus lowest low of the most recent session up to the current bar
Calculation: OpeningSpan = highest high minus lowest low over the first opening window bars of the most recent session
Calculation: LevelUnit = OpeningSpan if the most recent session's bar count up to the current bar is at least opening window, else SessionSpan
Calculation: UpLevel(step) = StartPrice + LevelUnit * step
Calculation: DnLevel(step) = StartPrice - LevelUnit * step
Calculation: RangeRatio = SessionSpan / ATR(high, low, close, ATR lookback)
Calculation: HitProb(side, step) = (Hits + 1) / (Samples + 2), where Samples counts the first sample cap completed sessions and Hits counts those sessions whose high >= StartPrice + OpeningSpan * step (side long) or whose low <= StartPrice - OpeningSpan * step (side short), each with that session's own StartPrice and OpeningSpan
Calculation: AuctionState = upside expansion if InSession(datetime, session) AND close > UpLevel(ladder step 4) AND close[1] <= UpLevel(ladder step 4) AND HitProb(long, ladder step 4) >= probability gate; else downside expansion if InSession(datetime, session) AND close < DnLevel(ladder step 4) AND close[1] >= DnLevel(ladder step 4) AND HitProb(short, ladder step 4) >= probability gate; else upper exhaustion if InSession(datetime, session) AND high >= UpLevel(ladder step 6) AND close < UpLevel(ladder step 5) AND RangeRatio > anomaly threshold; else lower exhaustion if InSession(datetime, session) AND low <= DnLevel(ladder step 6) AND close > DnLevel(ladder step 5) AND RangeRatio > anomaly threshold; else above open if close > StartPrice; else below open if close < StartPrice; else balanced
Calculation: BarColor = bull if AuctionState = upside expansion OR AuctionState = lower exhaustion; else bear if AuctionState = downside expansion OR AuctionState = upper exhaustion; else bull if close >= VWAP(high, low, close, volume, session start); else bear
Long: AuctionState = upside expansion
Short: AuctionState = downside expansion
Short: AuctionState = upper exhaustion
Long: AuctionState = lower exhaustion
Long: AuctionState = above open
Short: AuctionState = below open
Long: BarColor = bull
Short: BarColor = bear
Long: InSession(datetime, session) AND close < DnLevel(ladder step 4)
Short: InSession(datetime, session) AND close > UpLevel(ladder step 4)