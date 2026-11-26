Calculation: BandBasis = SMA(EMA(close, trend length), trend length)
Calculation: BandDev = EMA(Abs(close - BandBasis), deviation length multiplier * trend length) * band multiplier
Calculation: UpperBand = BandBasis + BandDev
Calculation: LowerBand = BandBasis - BandDev
Calculation: TrendState = 1 if close > UpperBand; -1 if close < LowerBand; otherwise TrendState[1]
Calculation: SwingLow = Lowest(low, 2 * swing lookback)[1]
Calculation: SwingHigh = Highest(high, 2 * swing lookback)[1]
Calculation: LowerRejection = (min(open, close) - low) / (high - low) * 100
Calculation: UpperRejection = (high - max(open, close)) / (high - low) * 100
Calculation: LowPivot = PivotLow(low, swing lookback, swing lookback)
Calculation: HighPivot = PivotHigh(high, swing lookback, swing lookback)
Calculation: BrokenLow = LowPivot if LowPivot is defined and close < LowPivot; otherwise BrokenLow[1]
Calculation: BrokenHigh = HighPivot if HighPivot is defined and close > HighPivot; otherwise BrokenHigh[1]
Calculation: LowBreakArmed = true if LowPivot is defined and close < LowPivot; false if LowBreakArmed[1] and close > BrokenLow and low < BrokenLow; otherwise LowBreakArmed[1]
Calculation: HighBreakArmed = true if HighPivot is defined and close > HighPivot; false if HighBreakArmed[1] and close < BrokenHigh and high > BrokenHigh; otherwise HighBreakArmed[1]
Calculation: DemandZoneLevel = PivotLow(low, pivot left bars, pivot right bars) if volume[pivot right bars] > SMA(volume, volume MA length) * volume threshold; otherwise NA
Calculation: SupplyZoneLevel = PivotHigh(high, pivot left bars, pivot right bars) if volume[pivot right bars] > SMA(volume, volume MA length) * volume threshold; otherwise NA
Calculation: RsiValue = RSI(close, RSI length)
Calculation: RsiHighRecord = RsiValue[divergence window] if PivotHigh(RsiValue, divergence window, divergence window) is defined; otherwise RsiHighRecord[1]
Calculation: PriceHighRecord = high[divergence window] if PivotHigh(RsiValue, divergence window, divergence window) is defined; otherwise PriceHighRecord[1]
Calculation: RsiLowRecord = RsiValue[divergence window] if PivotLow(RsiValue, divergence window, divergence window) is defined; otherwise RsiLowRecord[1]
Calculation: PriceLowRecord = low[divergence window] if PivotLow(RsiValue, divergence window, divergence window) is defined; otherwise PriceLowRecord[1]
Calculation: BullDiv = PivotLow(RsiValue, divergence window, divergence window) is defined and RsiValue[divergence window] > RsiLowRecord[1] and low[divergence window] < PriceLowRecord[1]
Calculation: BearDiv = PivotHigh(RsiValue, divergence window, divergence window) is defined and RsiValue[divergence window] < RsiHighRecord[1] and high[divergence window] > PriceHighRecord[1]
Calculation: LongPending = false if BearDiv or (LongTrail is defined and LongTrail[1] is not defined); true if BullDiv; otherwise LongPending[1]
Calculation: LongTrail = Low - ATR(trail ATR length) * trail ATR multiplier if (BullDiv or LongPending[1]) and not BearDiv and RsiValue crosses above RSI midline and LongTrail[1] is not defined; NA if LongTrail[1] is defined and (RsiValue >= RSI overbought level or RsiValue <= RSI oversold level or (RsiValue >= RSI midline and close < LongTrail[1]) or (RsiValue < RSI midline and close > LongTrail[1])); max(LongTrail[1], Low - ATR(trail ATR length) * trail ATR multiplier) if LongTrail[1] is defined and RsiValue >= RSI midline; otherwise LongTrail[1]
Calculation: ShortPending = false if BullDiv or (ShortTrail is defined and ShortTrail[1] is not defined); true if BearDiv; otherwise ShortPending[1]
Calculation: ShortTrail = High + ATR(trail ATR length) * trail ATR multiplier if (BearDiv or ShortPending[1]) and not BullDiv and RsiValue crosses below RSI midline and ShortTrail[1] is not defined; NA if ShortTrail[1] is defined and (RsiValue >= RSI overbought level or RsiValue <= RSI oversold level or (RsiValue >= RSI midline and close < ShortTrail[1]) or (RsiValue < RSI midline and close > ShortTrail[1])); min(ShortTrail[1], High + ATR(trail ATR length) * trail ATR multiplier) if ShortTrail[1] is defined and RsiValue < RSI midline; otherwise ShortTrail[1]
Calculation: SupplyStructLevel = PivotHigh(high, structure swing length, structure swing length)
Calculation: DemandStructLevel = PivotLow(low, structure swing length, structure swing length)
Calculation: FridayClose = Close(T1, last completed bar) as of the most recent Friday bar
Calculation: GapFilled = false on Friday bars; true if (close > FridayClose and low <= FridayClose) or (close < FridayClose and high >= FridayClose); otherwise GapFilled[1]
Long: (low < SwingLow and close > SwingLow and (SwingLow - low) >= ATR(sweep ATR length) * min wick ATR multiple and LowerRejection >= min wick rejection % and (volume filter off or volume > SMA(volume, volume MA length) * volume multiplier) and (EMA filter off or close < EMA(close, EMA length, T2, last completed bar)) and not (Long[1] or ... or Long[cooldown bars - 1])) or (breakout mode and LowBreakArmed[1] and close > BrokenLow and low < BrokenLow)
Short: (high > SwingHigh and close < SwingHigh and (high - SwingHigh) >= ATR(sweep ATR length) * min wick ATR multiple and UpperRejection >= min wick rejection % and (volume filter off or volume > SMA(volume, volume MA length) * volume multiplier) and (EMA filter off or close > EMA(close, EMA length, T2, last completed bar)) and not (Short[1] or ... or Short[cooldown bars - 1])) or (breakout mode and HighBreakArmed[1] and close < BrokenHigh and high > BrokenHigh)
Long: low crosses below a DemandZoneLevel not yet crossed, among the most recent max active zones of either type
Short: high crosses above a SupplyZoneLevel not yet crossed, among the most recent max active zones of either type
Long: TrendState > 0
Short: TrendState < 0
Long: RsiValue >= RSI midline and RsiValue < RSI overbought level
Short: RsiValue > RSI oversold level and RsiValue < RSI midline
Long: BullDiv = true
Short: BearDiv = true
Exit: long, LongTrail[1] is defined and LongTrail is NA
Exit: short, ShortTrail[1] is defined and ShortTrail is NA
Long: Low - High[2] > ATR(void ATR length) * void threshold and Close[1] > High[2]
Short: Low[2] - High > ATR(void ATR length) * void threshold and Close[1] < Low[2]
Long: close crosses above a SupplyStructLevel not yet crossed, among the most recent history to keep supply levels
Short: close crosses below a DemandStructLevel not yet crossed, among the most recent history to keep demand levels
Long: weekend bar and close > FridayClose and not GapFilled
Short: weekend bar and close < FridayClose and not GapFilled