Calculation: EMABuySetup = close > EMA(close, short lookback) AND close[1] > EMA(close, short lookback)[1] AND EMA(close, short lookback) > EMA(close, medium lookback) AND EMA(close, medium lookback) > EMA(close, long lookback) AND EMA(close, medium lookback) > EMA(close, medium lookback)[1] AND EMA(close, long lookback) > EMA(close, long lookback)[1] AND RSI(close, RSI lookback) > bull RSI level
Calculation: EMASellSetup = close < EMA(close, short lookback) AND close[1] < EMA(close, short lookback)[1] AND EMA(close, short lookback) < EMA(close, medium lookback) AND EMA(close, medium lookback) < EMA(close, long lookback) AND EMA(close, medium lookback) < EMA(close, medium lookback)[1] AND EMA(close, long lookback) < EMA(close, long lookback)[1] AND RSI(close, RSI lookback) < bear RSI level
Calculation: ZoneUpper = (EMA(close, zone lookback) + HMA(close, zone lookback - zone offset)) / 2 + SMA(high - low, zone distance lookback)
Calculation: ZoneLower = (EMA(close, zone lookback) + HMA(close, zone lookback - zone offset)) / 2 - SMA(high - low, zone distance lookback)
Calculation: ZoneTrend = true if (low > ZoneUpper AND low[1] < ZoneUpper[1] AND NOT ZoneTrend[1]); false if (high < ZoneLower AND high[1] > ZoneLower[1] AND ZoneTrend[1]); otherwise ZoneTrend[1]
Calculation: ZoneStart = low if (ZoneTrend AND NOT ZoneTrend[1]); high if (NOT ZoneTrend AND ZoneTrend[1]); otherwise ZoneStart[1]
Calculation: ZoneRetestGap = bars since the most recent earlier bar at which ZoneBullRetest or ZoneBearRetest was true
Calculation: ZoneBullRetest = ZoneTrend AND ((close > ZoneStart AND close[1] < ZoneStart[1]) OR (low > ZoneStart AND low[1] < ZoneStart[1])) AND ZoneRetestGap > zone retest cooldown
Calculation: ZoneBearRetest = NOT ZoneTrend AND ((close[1] > ZoneStart AND close < ZoneStart[1]) OR (high[1] > ZoneStart AND high < ZoneStart[1])) AND ZoneRetestGap > zone retest cooldown
Calculation: TLSlope = trendline slope multiplier * (ATR(trendline lookback) / trendline lookback if trendline slope method is ATR; STDEV(close, trendline lookback) / trendline lookback if trendline slope method is StDev; ABS(SMA(bar index * close, trendline lookback) - SMA(close, trendline lookback) * SMA(bar index, trendline lookback)) / VAR(bar index, trendline lookback) / 2 if trendline slope method is Linreg)
Calculation: UpperSlope = TLSlope if PivotHigh(high, trendline lookback, trendline lookback) is not NA; otherwise UpperSlope[1]
Calculation: UpperLine = PivotHigh(high, trendline lookback, trendline lookback) if it is not NA; otherwise UpperLine[1] - UpperSlope
Calculation: UpBreakState = 0 if PivotHigh(high, trendline lookback, trendline lookback) is not NA; 1 if close > UpperLine - UpperSlope * trendline lookback; otherwise UpBreakState[1]
Calculation: LowerSlope = TLSlope if PivotLow(low, trendline lookback, trendline lookback) is not NA; otherwise LowerSlope[1]
Calculation: LowerLine = PivotLow(low, trendline lookback, trendline lookback) if it is not NA; otherwise LowerLine[1] + LowerSlope
Calculation: DnBreakState = 0 if PivotLow(low, trendline lookback, trendline lookback) is not NA; 1 if close < LowerLine + LowerSlope * trendline lookback; otherwise DnBreakState[1]
Calculation: BuySide = true if close > open; false if close < open; otherwise BuySide[1]
Calculation: Delta = volume if BuySide, otherwise -volume
Calculation: SupportLevel = PivotLow(close, level lookback, level lookback) if (PivotLow(close, level lookback, level lookback) is not NA AND Delta > highest(Delta / delta divisor, delta length)); otherwise SupportLevel[1]
Calculation: ResistanceSet = PivotHigh(close, level lookback, level lookback) is not NA AND Delta < lowest(Delta / delta divisor, delta length)
Calculation: ResistanceLevel = PivotHigh(close, level lookback, level lookback) if ResistanceSet; otherwise ResistanceLevel[1]
Calculation: ResistanceTop = ResistanceLevel + ATR(level width lookback) * level width multiplier if ResistanceSet; otherwise ResistanceTop[1]
Calculation: HAClose = (MA(open, HA pre lookback, HA pre type) + MA(high, HA pre lookback, HA pre type) + MA(low, HA pre lookback, HA pre type) + MA(close, HA pre lookback, HA pre type)) / 4
Calculation: HAOpen = (HAOpen[1] + HAClose[1]) / 2, or on the first bar (MA(open, HA pre lookback, HA pre type) + MA(close, HA pre lookback, HA pre type)) / 2
Calculation: SmoothedHABull = MA(HAClose, HA post lookback, HA post type) >= MA(HAOpen, HA post lookback, HA post type)
Calculation: ImpulseMACDLine = ImpulseMACD(high, low, hlc3, impulse lookback)
Calculation: MasterBuySetup = (EMA filter off OR (close > EMA(close, short lookback) AND EMA(close, short lookback) > EMA(close, medium lookback) AND EMA(close, medium lookback) > EMA(close, long lookback))) AND (zone filter off OR ZoneTrend) AND (smoothed HA filter off OR SmoothedHABull) AND (impulse filter off OR (ImpulseMACDLine > SMA(ImpulseMACDLine, impulse signal lookback) AND ImpulseMACDLine > 0)) AND (TL filter off OR UpBreakState > UpBreakState[1]) AND (SR filter off OR low crosses above ResistanceTop OR low crosses above SupportLevel)
Calculation: MasterSellSetup = (EMA filter off OR (close < EMA(close, short lookback) AND EMA(close, short lookback) < EMA(close, medium lookback) AND EMA(close, medium lookback) < EMA(close, long lookback))) AND (zone filter off OR NOT ZoneTrend) AND (smoothed HA filter off OR NOT SmoothedHABull) AND (impulse filter off OR (ImpulseMACDLine < SMA(ImpulseMACDLine, impulse signal lookback) AND ImpulseMACDLine < 0)) AND (TL filter off OR DnBreakState > DnBreakState[1]) AND (SR filter off OR high crosses below SupportLevel OR high crosses below ResistanceLevel)
Long: EMABuySetup AND NOT EMABuySetup[1]
Short: EMASellSetup AND NOT EMASellSetup[1]
Long: ZoneBullRetest
Short: ZoneBearRetest
Long: UpBreakState > UpBreakState[1]
Short: DnBreakState > DnBreakState[1]
Long: low crosses above ResistanceTop
Short: high crosses below SupportLevel
Long: low crosses above SupportLevel
Short: high crosses below ResistanceLevel
Long: EMA(close, medium lookback) > EMA(close, long lookback)
Short: EMA(close, medium lookback) < EMA(close, long lookback)
Long: SmoothedHABull
Short: NOT SmoothedHABull
Long: MasterBuySetup AND NOT MasterBuySetup[1]
Short: MasterSellSetup AND NOT MasterSellSetup[1]