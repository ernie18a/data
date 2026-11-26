Calculation: CurrentSession = the session (Asian, London, or NY) whose hour window in the session timezone contains the bar's hour, else OFF
Calculation: SessionVWAP = VWAP(hlc3, volume) anchored at the first bar of CurrentSession
Calculation: SessionMeridian = (highest high + lowest low) / 2, over the bars from the first bar of CurrentSession through the current bar
Calculation: PriorSessionHigh = highest high over the bars of the session before CurrentSession
Calculation: PriorSessionLow = lowest low over the bars of the session before CurrentSession
Calculation: OpeningRangeHigh = highest high over the bars of CurrentSession within its first opening range minutes
Calculation: OpeningRangeLow = lowest low over the bars of CurrentSession within its first opening range minutes
Calculation: OpeningRangeLocked = CurrentSession is London or NY AND at least opening range minutes have elapsed since the first bar of CurrentSession
Calculation: RetestTolerance = ATR(ATR length) * retest tolerance multiplier
Calculation: BullRejection = close > open AND close - low > rejection fraction * (high - low)
Calculation: BearRejection = close < open AND high - close > rejection fraction * (high - low)
Calculation: SessionBullBias = close > SessionVWAP AND close > SessionMeridian
Calculation: SessionBearBias = close < SessionVWAP AND close < SessionMeridian
Calculation: HtfBullBias = EMA(close, shorter lookback, T1, last completed bar) > EMA(close, longer lookback, T1, last completed bar) AND close(T1, last completed bar) > EMA(close, shorter lookback, T1, last completed bar)
Calculation: HtfBearBias = EMA(close, shorter lookback, T1, last completed bar) < EMA(close, longer lookback, T1, last completed bar) AND close(T1, last completed bar) < EMA(close, shorter lookback, T1, last completed bar)
Calculation: VolumeOK = volume >= SMA(volume, volume average length) * volume multiplier
Calculation: TradeSessionOk = CurrentSession is one of the sessions enabled for trading
Calculation: LongRetestCandidate = low <= PriorSessionHigh + RetestTolerance AND close > PriorSessionHigh AND BullRejection
Calculation: LongRetest = LongRetestCandidate AND the most recent bar where close crosses above PriorSessionHigh is at most retest window bars ago AND LongRetestCandidate is false on every bar from that bar through the previous bar
Calculation: ShortRetestCandidate = high >= PriorSessionLow - RetestTolerance AND close < PriorSessionLow AND BearRejection
Calculation: ShortRetest = ShortRetestCandidate AND the most recent bar where close crosses below PriorSessionLow is at most retest window bars ago AND ShortRetestCandidate is false on every bar from that bar through the previous bar
Calculation: LongOrbBreak = OpeningRangeLocked AND close crosses above OpeningRangeHigh AND BullRejection
Calculation: ShortOrbBreak = OpeningRangeLocked AND close crosses below OpeningRangeLow AND BearRejection
Calculation: LongMeridianBounce = SessionBullBias AND low <= SessionMeridian + RetestTolerance AND close > SessionMeridian AND BullRejection
Calculation: ShortMeridianBounce = SessionBearBias AND high >= SessionMeridian - RetestTolerance AND close < SessionMeridian AND BearRejection
Calculation: LongSetup = LongRetest OR LongOrbBreak OR LongMeridianBounce
Calculation: ShortSetup = ShortRetest OR ShortOrbBreak OR ShortMeridianBounce
Calculation: LongConfluence = number of true among SessionBullBias, close > SessionVWAP, HtfBullBias, TradeSessionOk, VolumeOK, BullRejection, LongSetup
Calculation: ShortConfluence = number of true among SessionBearBias, close < SessionVWAP, HtfBearBias, TradeSessionOk, VolumeOK, BearRejection, ShortSetup
Calculation: BarsSinceEntry = bars since the most recent bar on which a Long or Short entry was taken, infinite if none
Long: LongRetest AND LongConfluence >= minimum confluence layers AND VolumeOK AND BarsSinceEntry >= cooldown bars
Long: LongOrbBreak AND LongConfluence >= minimum confluence layers AND VolumeOK AND BarsSinceEntry >= cooldown bars
Long: LongMeridianBounce AND LongConfluence >= minimum confluence layers AND VolumeOK AND BarsSinceEntry >= cooldown bars
Short: ShortRetest AND ShortConfluence >= minimum confluence layers AND VolumeOK AND BarsSinceEntry >= cooldown bars
Short: ShortOrbBreak AND ShortConfluence >= minimum confluence layers AND VolumeOK AND BarsSinceEntry >= cooldown bars
Short: ShortMeridianBounce AND ShortConfluence >= minimum confluence layers AND VolumeOK AND BarsSinceEntry >= cooldown bars
Long: close crosses above PriorSessionHigh
Short: close crosses below PriorSessionLow
Long: LongOrbBreak
Short: ShortOrbBreak