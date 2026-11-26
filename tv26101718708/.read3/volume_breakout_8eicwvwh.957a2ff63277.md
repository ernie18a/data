Calculation: Buffer = buffer share * ATR(ATR length)[1]
Calculation: CloseLocation = (close - low) / (high - low), or 0.5 when high = low
Calculation: NormalVolume = on intraday charts, median of volume in the same time-of-day slot over the previous volume length sessions when at least minimum session count such volumes exist, otherwise Median(volume, volume length)[1]
Calculation: RelativeVolume = volume / NormalVolume, or 0 when volume is missing or NormalVolume = 0
Calculation: MajorLevels = for each swing price p of PivotHigh(high, pivot span, pivot span) or PivotLow(low, pivot span, pivot span) whose pivot bar is within major lookback bars, the average of the swing prices within major tolerance * ATR(ATR length)[1] of p, kept when at least major touches swing prices are in that group; groups are taken from most to fewest swing prices and skipped when within that tolerance of an already taken level; first touch = earliest pivot bar of the group
Calculation: NearestMajorResistance = lowest MajorLevels value above close whose first touch is at least major minimum age bars ago
Calculation: NearestMajorSupport = highest MajorLevels value below close whose first touch is at least major minimum age bars ago
Calculation: BullishBreakout = close crosses above Highest(high, lookback)[1] + Buffer OR close > NearestMajorResistance[1] + Buffer
Calculation: BearishBreakout = close crosses below Lowest(low, lookback)[1] - Buffer OR close < NearestMajorSupport[1] - Buffer
Calculation: BullishBreakLevel = NearestMajorResistance[1] when close > NearestMajorResistance[1] + Buffer, else Highest(high, lookback)[1]
Calculation: BearishBreakLevel = NearestMajorSupport[1] when close < NearestMajorSupport[1] - Buffer, else Lowest(low, lookback)[1]
Calculation: NarrowBase = max base width is 0 OR (Highest(high, lookback)[1] - Lowest(low, lookback)[1]) / ATR(ATR length)[1] <= max base width
Calculation: UpTrend = trend filter off OR chart timeframe is T1 or longer OR close of last completed T1 bar > EMA(close, trend length, T1, last completed bar)
Calculation: DownTrend = trend filter off OR chart timeframe is T1 or longer OR close of last completed T1 bar < EMA(close, trend length, T1, last completed bar)
Calculation: BullishSetup = BullishBreakout AND HawkEye color(HawkEye length, HawkEye divisor) = green AND CloseLocation >= minimum close location AND NarrowBase AND UpTrend
Calculation: BearishSetup = BearishBreakout AND HawkEye color(HawkEye length, HawkEye divisor) = red AND CloseLocation <= 1 - minimum close location AND NarrowBase AND DownTrend
Long: BullishSetup AND RelativeVolume >= volume multiple
Long: BullishSetup[volume window] AND volume[volume window] > 0 AND RelativeVolume[volume window] < volume multiple AND Lowest(close, volume window) >= BullishBreakLevel[volume window] AND SMA(RelativeVolume, volume window + 1) >= window volume multiple
Short: BearishSetup AND RelativeVolume >= volume multiple
Short: BearishSetup[volume window] AND volume[volume window] > 0 AND RelativeVolume[volume window] < volume multiple AND Highest(close, volume window) <= BearishBreakLevel[volume window] AND SMA(RelativeVolume, volume window + 1) >= window volume multiple
Exit: long, close < BullishBreakLevel fixed at the entry's breakout bar
Exit: short, close > BearishBreakLevel fixed at the entry's breakout bar