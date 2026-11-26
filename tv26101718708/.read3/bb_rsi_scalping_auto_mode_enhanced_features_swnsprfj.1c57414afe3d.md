Calculation: BBMid = SMA(close, BB length)
Calculation: BBUpper = BBMid + BB multiplier * STDEV(close, BB length)
Calculation: BBLower = BBMid - BB multiplier * STDEV(close, BB length)
Calculation: BandRange = BBUpper - BBLower
Calculation: RsiValue = RSI(close, RSI length)
Calculation: OversoldLevel = Lowest(RsiValue, dynamic RSI lookback) + dynamic RSI buffer
Calculation: OverboughtLevel = Highest(RsiValue, dynamic RSI lookback) - dynamic RSI buffer
Calculation: MacdMain = MACD line(close, MACD fast length, MACD slow length)
Calculation: MacdSignal = EMA(MacdMain, MACD signal length)
Calculation: MacdHist = MacdMain - MacdSignal
Calculation: VolumeSpike = Volume > SMA(Volume, volume length) * volume multiplier AND (volume increase not required OR Volume > Volume[1])
Calculation: RecentVolumeSpike = VolumeSpike is true on the current bar or any of the previous confirmation window bars
Calculation: RecentBullInflection = MacdHist > MacdHist[1] AND MacdHist[1] < MacdHist[2] is true on the current bar or any of the previous confirmation window bars
Calculation: RecentBearInflection = MacdHist < MacdHist[1] AND MacdHist[1] > MacdHist[2] is true on the current bar or any of the previous confirmation window bars
Calculation: Mode = entry mode if not automatic; otherwise Aggressive if BandRange > SMA(BandRange, auto band width lookback) AND ATR(ATR length) > SMA(ATR(ATR length), auto ATR lookback) AND Volume > SMA(Volume, volume length) * auto volume multiplier; otherwise Conservative if BandRange <= SMA(BandRange, auto band width lookback) AND Volume <= SMA(Volume, volume length) * auto volume multiplier; otherwise Balanced
Calculation: LongZone = low <= BBLower + BandRange * near band percent / 100 AND RsiValue <= OversoldLevel + near RSI buffer
Calculation: ShortZone = high >= BBUpper - BandRange * near band percent / 100 AND RsiValue >= OverboughtLevel - near RSI buffer
Calculation: LongContScore = count of true among (low <= BBMid), (close > BBMid), (close > open), (RsiValue > RSI midline), (MacdHist > MacdHist[1]), (MacdMain >= MacdSignal), RecentVolumeSpike
Calculation: ShortContScore = count of true among (high >= BBMid), (close < BBMid), (close < open), (RsiValue < RSI midline), (MacdHist < MacdHist[1]), (MacdMain <= MacdSignal), RecentVolumeSpike
Calculation: MidlineLong = continuation mode enabled AND LongContScore = 7
Calculation: MidlineShort = continuation mode enabled AND ShortContScore = 7
Calculation: BullDivergence = a pivot low of low (pivot length bars each side) is confirmed on the current bar AND a previous pivot low exists AND low[pivot length] < low at previous pivot low AND RsiValue[pivot length] > RsiValue at previous pivot low AND bars between the two pivots <= max divergence bars
Calculation: BearDivergence = a pivot high of high (pivot length bars each side) is confirmed on the current bar AND a previous pivot high exists AND high[pivot length] > high at previous pivot high AND RsiValue[pivot length] < RsiValue at previous pivot high AND bars between the two pivots <= max divergence bars
Calculation: SessionOK = session filter disabled OR datetime in trading session
Calculation: MomentumReversalLong = (inflection exit enabled AND MacdHist < MacdHist[1] AND MacdHist[1] > MacdHist[2]) OR (MACD cross exit enabled AND MacdMain crosses below MacdSignal) OR (RSI midline exit enabled AND RsiValue crosses under RSI midline)
Calculation: MomentumReversalShort = (inflection exit enabled AND MacdHist > MacdHist[1] AND MacdHist[1] < MacdHist[2]) OR (MACD cross exit enabled AND MacdMain crosses above MacdSignal) OR (RSI midline exit enabled AND RsiValue crosses over RSI midline)
Calculation: LongExitSignal = (reversal trade AND reversal exit mode is momentum AND MomentumReversalLong) OR (continuation trade AND continuation exit mode is momentum AND MomentumReversalLong) OR (reversal trade AND reversal exit mode is first retrace AND close < open) OR (reversal trade AND reversal exit mode is retrace with MACD weakness AND close < open AND MacdHist < MacdHist[1]) OR (continuation trade AND continuation exit mode is basis break with MACD weakness AND close < BBMid AND MacdHist < MacdHist[1]) OR (continuation trade AND continuation exit mode is MACD cross only AND MacdMain crosses below MacdSignal)
Calculation: ShortExitSignal = (reversal trade AND reversal exit mode is momentum AND MomentumReversalShort) OR (continuation trade AND continuation exit mode is momentum AND MomentumReversalShort) OR (reversal trade AND reversal exit mode is first retrace AND close > open) OR (reversal trade AND reversal exit mode is retrace with MACD weakness AND close > open AND MacdHist > MacdHist[1]) OR (continuation trade AND continuation exit mode is basis break with MACD weakness AND close > BBMid AND MacdHist > MacdHist[1]) OR (continuation trade AND continuation exit mode is MACD cross only AND MacdMain crosses above MacdSignal)
Long: flat AND SessionOK AND Mode = Conservative AND low < BBLower AND RsiValue <= OversoldLevel AND RecentBullInflection AND RecentVolumeSpike AND close > BBLower AND close > close[1]
Long: flat AND SessionOK AND Mode = Conservative AND BullDivergence AND low[pivot length] < BBLower[pivot length] AND RsiValue[pivot length] <= OversoldLevel[pivot length] AND RecentBullInflection AND RecentVolumeSpike
Long: flat AND SessionOK AND Mode = Balanced AND LongZone AND close > open
Long: flat AND SessionOK AND Mode = Aggressive AND LongZone
Long: flat AND SessionOK AND MidlineLong
Long: flat AND limit heads-up display enabled AND LongZone AND no long heads-up marking in previous (heads-up cooldown - 1) bars
Long: flat AND continuation warnings enabled AND continuation mode enabled AND NOT MidlineLong AND LongContScore >= warning score AND no long continuation warning marking in previous (warning cooldown - 1) bars
Short: flat AND SessionOK AND Mode = Conservative AND high > BBUpper AND RsiValue >= OverboughtLevel AND RecentBearInflection AND RecentVolumeSpike AND close < BBUpper AND close < close[1]
Short: flat AND SessionOK AND Mode = Conservative AND BearDivergence AND high[pivot length] > BBUpper[pivot length] AND RsiValue[pivot length] >= OverboughtLevel[pivot length] AND RecentBearInflection AND RecentVolumeSpike
Short: flat AND SessionOK AND Mode = Balanced AND ShortZone AND close < open
Short: flat AND SessionOK AND Mode = Aggressive AND ShortZone
Short: flat AND SessionOK AND MidlineShort
Short: flat AND limit heads-up display enabled AND ShortZone AND no short heads-up marking in previous (heads-up cooldown - 1) bars
Short: flat AND continuation warnings enabled AND continuation mode enabled AND NOT MidlineShort AND ShortContScore >= warning score AND no short continuation warning marking in previous (warning cooldown - 1) bars
Exit: long, LongExitSignal
Exit: long, exit-soon display enabled AND NOT LongExitSignal AND MacdHist < MacdHist[1]
Exit: short, ShortExitSignal
Exit: short, exit-soon display enabled AND NOT ShortExitSignal AND MacdHist > MacdHist[1]