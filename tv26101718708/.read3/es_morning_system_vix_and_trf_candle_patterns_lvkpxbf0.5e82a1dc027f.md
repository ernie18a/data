Calculation: Green = close > open, or close = open and Green of the previous RTH bar (true for the first RTH bar of each day); a red run or green run is a maximal sequence of consecutive RTH bars with Green false or true
Calculation: LongSwingHigh = at an RTH bar where Green changes from false to true, the highest high from the first bar of the green run before the red run through the last bar of the red run
Calculation: LongSwingLow = at the same bar, the lowest low of the red run
Calculation: LongPullbackHigh = at the same bar, the highest high of the red run
Calculation: ShortSwingHigh = at an RTH bar where Green changes from true to false, the highest high from the first bar of the green run through this bar
Calculation: ShortSwingLow = at the same bar, the lowest low from the first bar of the red run before the green run through the last bar of the green run
Calculation: ShortBounceLow = at the same bar, the lowest low of the green run
Calculation: LongPattern = at an RTH bar where Green changes from false to true, LongSwingHigh > LongSwingHigh at the previous such bar of the same day AND LongSwingLow > LongSwingLow at the previous such bar of the same day (false if none)
Calculation: ShortPattern = at an RTH bar where Green changes from true to false, ShortSwingHigh < ShortSwingHigh at the previous such bar of the same day AND ShortSwingLow < ShortSwingLow at the previous such bar of the same day (false if none)
Calculation: VwapTouch = an RTH bar whose range contains the overnight VWAP or the RTH VWAP, where the previous chart bar's range contained neither (the first bar of each day has no previous contact)
Calculation: OvernightVWAP = VWAP(hlc3, volume) anchored at the overnight anchor time
Calculation: RTHVWAP = VWAP(hlc3, volume) anchored at the RTH session start
Calculation: TrendBull(series) = close of the last completed T1 bar of series > TRF(close of series on T1 bars, fast period, fast multiplier, slow period, slow multiplier)
Calculation: LongSetup = LongPullbackHigh and LongSwingLow of the most recent RTH bar where LongPattern is true, provided no long entry occurred after the most recent VwapTouch as of that bar; cleared at the first bar of each day, by a long entry, and by any RTH bar from that bar onward with high < LongPullbackHigh and low < LongSwingLow
Calculation: ShortSetup = ShortBounceLow and ShortSwingHigh of the most recent RTH bar where ShortPattern is true; cleared at the first bar of each day, by a short entry, and by any RTH bar from that bar onward with low > ShortBounceLow and high > ShortSwingHigh
Long: LongSetup is active AND high >= LongSetup's LongPullbackHigh AND a VwapTouch has occurred since the last long entry or session start AND close > OvernightVWAP AND close > RTHVWAP AND TrendBull(traded instrument) AND RTH bar at or after signal start
Short: ShortSetup is active AND low <= ShortSetup's ShortBounceLow AND close < OvernightVWAP AND TrendBull(volatility index) AND RTH bar at or after signal start