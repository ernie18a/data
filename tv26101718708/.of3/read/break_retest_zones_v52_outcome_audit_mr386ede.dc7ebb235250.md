Calculation: ATR = ATR(high, low, close, ATR length)
Calculation: VolAvg = SMA(volume, volume average length)
Calculation: Zone = band formed when its pivot is confirmed (pivot right lookback bars after the pivot bar): for Pivot Low(low, pivot left lookback, pivot right lookback), bottom = low at the pivot bar and top = min(high at the pivot bar, bottom + max zone height multiple * ATR); for Pivot High(high, pivot left lookback, pivot right lookback), top = high at the pivot bar and bottom = max(low at the pivot bar, top - max zone height multiple * ATR); the band is added only if it touches or overlaps no existing zone, and if its side already holds max zones per side, that side's oldest live zone is removed first (or its oldest zone if none is live); live = neither armed nor flip-failed; a zone becomes armed on its break bar (Long and Short break lines); an armed zone becomes flip-failed when a close after the break bar goes beyond its opposite edge (below bottom for long, above top for short); a flip-failed zone becomes live again once flip cooldown bars have passed since the flip; an armed zone becomes live again when bars since break exceed retest window or the runaway check fails; a zone is removed when it produces an entry
Calculation: Touches = 1 + number of bars on which the zone is live, the bar's range overlaps the zone, the bar closes outside the zone, and at least touch spacing bars have passed since the previous counted touch (since zone creation for the first)
Calculation: Session = session filter disabled OR the bar's New York time lies within an enabled session window (London, New York, Asia)
Calculation: HTFOverlap = any of High(high, T1, last completed bar), Low(low, T1, last completed bar), High(high, T2, last completed bar), Low(low, T2, last completed bar) lies between zone bottom - HTF tolerance multiple * ATR and zone top + HTF tolerance multiple * ATR
Calculation: BreakRatio = volume / VolAvg, both on the zone's break bar
Calculation: PullbackRatio(side) = average volume over bars after the break bar and before the current bar on which Retest(side) is false, divided by VolAvg on the current bar; equals BreakRatio when there are no such bars
Calculation: Sweep(side) = some bar within sweep max age bars up to and including the break bar whose low is below the lowest low of the prior sweep lookback bars while its close is above that lowest low (short: high above the highest high of the prior sweep lookback bars while its close is below that highest high)
Calculation: FVG(side) = on the break bar or on any pullback bar (as in PullbackRatio), low > high[2] (short: high < low[2])
Calculation: Score(side) = 2 if HTFOverlap, plus 1 each for: BreakRatio >= volume multiple; PullbackRatio(side) < BreakRatio; sweep enabled AND Sweep(side); displacement enabled AND abs(close - open) on the break bar >= displacement multiple * ATR on the break bar; FVG enabled AND FVG(side)
Calculation: Retest(side) = bars since most recent break > gap AND (long: low <= zone top AND close > zone top; short: high >= zone bottom AND close < zone bottom) AND Touches >= min touches AND Session
Calculation: RunawayPass(side) = runaway check disabled OR every close after the break bar is <= zone top + runaway multiple * ATR (short: >= zone bottom - runaway multiple * ATR)
Calculation: Armed(side) = the zone's most recent break is upward (downward for short) AND bars since that break <= retest window AND every close after that break bar is >= zone bottom (short: <= zone top) AND RunawayPass(side)
Calculation: Stop(side) = zone bottom - stop buffer (long) or zone top + stop buffer (short), evaluated on the entry bar and held for the trade; stop buffer = stop buffer parameter * tick size
Calculation: RoomPass(side) = room filter disabled OR (long: High(high, T1, last completed bar) <= close OR High(high, T1, last completed bar) - close >= room multiple * abs(close - Stop(long)); short: Low(low, T1, last completed bar) >= close OR close - Low(low, T1, last completed bar) >= room multiple * abs(Stop(short) - close))
Long: close > zone top AND ((zone live AND close[1] <= zone top) OR zone created on this bar)
Long: Armed(long)
Long: Armed(long) AND Retest(long) AND Score(long) >= minimum score AND RoomPass(long)
Short: close < zone bottom AND ((zone live AND close[1] >= zone bottom) OR zone created on this bar)
Short: Armed(short)
Short: Armed(short) AND Retest(short) AND Score(short) >= minimum score AND RoomPass(short)
Exit: long, low <= Stop(long)
Exit: long, high >= entry price + target-1 R multiple * (entry price - Stop(long)) AND low > Stop(long)
Exit: short, high >= Stop(short)
Exit: short, low <= entry price - target-1 R multiple * (Stop(short) - entry price) AND high < Stop(short)