Calculation: BreakUp = close > highest high of the previous N bars (current bar excluded); BreakDown = close < lowest low of the previous N bars (current bar excluded)
Calculation: BullOB = high and low of the most recent bearish bar (close<open, current bar included) at the time of the latest BreakUp, frozen at that bar; BearOB = high and low of the most recent bullish bar (close>open, current bar included) at the time of the latest BreakDown, frozen at that bar
Calculation: BullOBActive = the latest structure break is BreakUp (more recent than the latest BreakDown) AND bars since it <= M; BearOBActive = the latest structure break is BreakDown (more recent than the latest BreakUp) AND bars since it <= M
Calculation: InBullOB = BullOBActive AND low <= BullOB.high AND high >= BullOB.low; InBearOB = BearOBActive AND high >= BearOB.low AND low <= BearOB.high; BullMid = (BullOB.high+BullOB.low)/2; BearMid = (BearOB.high+BearOB.low)/2
Calculation: TrendUp = fast EMA(close) > slow EMA(close) AND close > fast EMA (fast lookback shorter than slow); TrendDown = fast EMA < slow EMA AND close < fast EMA. Looser variant: only close vs fast EMA. Stricter variant: additionally fast EMA > its previous-bar value for TrendUp, < for TrendDown
Calculation: RSIUp = RSI(close) > buy threshold; RSIDown = RSI(close) < sell threshold (buy threshold < sell threshold, both near the neutral midpoint)
Calculation: VolOK = volume > SMA(volume) * multiplier (multiplier about 1 or above)
Calculation: LongStop = BullOB.low - ATR * buffer factor; ShortStop = BearOB.high + ATR * buffer factor (BullOB, BearOB and ATR taken at the entry bar)
Long: InBullOB AND TrendUp AND RSIUp AND VolOK (early setup, any bar satisfying it)
Long: InBullOB AND (close > open OR close > BullMid) AND TrendUp AND RSIUp AND VolOK, on the first bar where this becomes true (it was false on the previous bar), AND close - LongStop > 0; entry price = close, LongTarget = entry + (entry - LongStop) * risk-reward ratio
Short: InBearOB AND TrendDown AND RSIDown AND VolOK (early setup, any bar satisfying it)
Short: InBearOB AND (close < open OR close < BearMid) AND TrendDown AND RSIDown AND VolOK, on the first bar where this becomes true (it was false on the previous bar), AND ShortStop - close > 0; entry price = close, ShortTarget = entry - (ShortStop - entry) * risk-reward ratio
Exit: long, low <= LongStop OR high >= LongTarget
Exit: short, high >= ShortStop OR low <= ShortTarget