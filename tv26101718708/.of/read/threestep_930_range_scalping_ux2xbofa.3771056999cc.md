Calculation: RangeHigh, RangeLow = high and low of the first bar of the session, taken from a timeframe higher than the chart timeframe, using the last completed bar (available only after it closes)
Calculation: Allowed = RangeHigh/RangeLow available AND no open position AND current chart bar is inside a fixed-length trading window starting at the session open AND date is not inside the year-end holiday blackout period
Calculation: BullFVG = low[1] > high[2] AND low > high[2] (index 0 = current chart bar)
Calculation: BearFVG = high[1] < low[2] AND high < low[2]
Calculation: BreakUp = since the range became available, some chart bar inside the window has closed above RangeHigh; BreakUpLow = low of the first such bar
Calculation: BreakDown = since the range became available, some chart bar inside the window has closed below RangeLow; BreakDownHigh = high of the first such bar
Calculation: RetestUp = BreakUp was already true and a later bar closed inside the range (RangeLow <= close <= RangeHigh); RetestDown = same with BreakDown
Calculation: StopL = Break entry: low of the earliest bar among the current bar and the previous two whose close > RangeHigh; Trap entry: BreakUpLow; Reversal entry: low[2]
Calculation: StopS = Break entry: high of the earliest bar among the current bar and the previous two whose close < RangeLow; Trap entry: BreakDownHigh; Reversal entry: high[2]
Long: Allowed AND BullFVG AND (close > RangeHigh OR close[1] > RangeHigh OR close[2] > RangeHigh) AND close > StopL (Break); entry price = close
Long: Allowed AND BreakUp AND RetestUp AND close > RangeHigh AND close > StopL (Trap); entry price = close
Long: Allowed AND BreakDown AND BullFVG AND RangeLow <= close <= RangeHigh AND close > StopL (Reversal); entry price = close
Short: Allowed AND BearFVG AND (close < RangeLow OR close[1] < RangeLow OR close[2] < RangeLow) AND close < StopS (Break); entry price = close
Short: Allowed AND BreakDown AND RetestDown AND close < RangeLow AND close < StopS (Trap); entry price = close
Short: Allowed AND BreakUp AND BearFVG AND RangeLow <= close <= RangeHigh AND close < StopS (Reversal); entry price = close
Exit: long, low <= StopL OR high >= entry + K * (entry - StopL), where K is a fixed reward-to-risk multiple
Exit: short, high >= StopS OR low <= entry - K * (StopS - entry), where K is a fixed reward-to-risk multiple