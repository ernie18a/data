Calculation: Squeeze = PercentRank(BandWidth(close, BB length, BB multiplier), percent rank lookback) < squeeze percentile
Calculation: VWAPSlope = (VWAP(hlc3) - VWAP(hlc3)[slope lookback]) / (ATR(ATR length) * SQRT(slope lookback))
Calculation: BullRegime = NOT Squeeze AND (VWAPSlope > slope threshold OR (SMA(close, shortest lookback) > SMA(close, intermediate lookback) AND SMA(close, intermediate lookback) > SMA(close, longest lookback)))
Calculation: BearRegime = NOT Squeeze AND NOT BullRegime AND (VWAPSlope < -slope threshold OR (SMA(close, shortest lookback) < SMA(close, intermediate lookback) AND SMA(close, intermediate lookback) < SMA(close, longest lookback)))
Calculation: StructureState = 1 if bar is closed AND close > last PivotHigh(high, swing lookback, swing lookback) AND StructureState[1] <= 0; -1 if bar is closed AND close < last PivotLow(low, swing lookback, swing lookback) AND StructureState[1] >= 0; otherwise StructureState[1]
Calculation: BullDisplacement = bar is closed AND close > open AND high > low AND ABS(close - open) / (high - low) >= displacement min body ratio AND ABS(close - open) >= SMA(ABS(close - open), body average lookback) * displacement body multiplier
Calculation: BearDisplacement = bar is closed AND close < open AND high > low AND ABS(close - open) / (high - low) >= displacement min body ratio AND ABS(close - open) >= SMA(ABS(close - open), body average lookback) * displacement body multiplier
Calculation: BullPatternBar = bar is closed AND ((close > open AND close[1] < open[1] AND close > open[1] AND open < close[1] AND ABS(close - open) > ABS(close[1] - open[1]) AND volume > SMA(volume, volume average lookback) * pattern volume multiplier) OR (MIN(open, close) - low > ABS(close - open) * rejection wick ratio AND high - MAX(open, close) < ABS(close - open) * opposite wick ratio AND high > low))
Calculation: BearPatternBar = bar is closed AND ((close < open AND close[1] > open[1] AND close < open[1] AND open > close[1] AND ABS(close - open) > ABS(close[1] - open[1]) AND volume > SMA(volume, volume average lookback) * pattern volume multiplier) OR (high - MAX(open, close) > ABS(close - open) * rejection wick ratio AND MIN(open, close) - low < ABS(close - open) * opposite wick ratio AND high > low))
Calculation: CumulativeDelta = CumulativeDelta[1] + 2 * BuyVolume - volume, where BuyVolume = volume if close >= open, else volume * (close - low) / MAX(high - low, tick size)
Calculation: EntryPermitted = entries since the start of the T1 bar containing the current bar < max entries per T1 bar AND (bar time is in NY kill zone window OR bar time is in London kill zone window OR bar time is in NY session window OR bar time is in London session window) AND day of week is an allowed day AND NOT Squeeze AND (BullRegime OR BearRegime)
Calculation: LongSetup = BullRegime AND StructureState == 1 AND RSI(close, RSI length) > RSI bull threshold AND SMI(close, SMI lookback, first SMI smoothing lookback, second SMI smoothing lookback) > 0 AND CumulativeDelta > SMA(CumulativeDelta, delta lookback) AND bar is closed AND EntryPermitted
Calculation: ShortSetup = BearRegime AND StructureState == -1 AND RSI(close, RSI length) < RSI bear threshold AND SMI(close, SMI lookback, first SMI smoothing lookback, second SMI smoothing lookback) < 0 AND CumulativeDelta < SMA(CumulativeDelta, delta lookback) AND bar is closed AND EntryPermitted
Calculation: EndOfDay = bar is on a weekday AND hour(bar time) = EOD close hour AND minute(bar time) >= EOD close minute
Calculation: StopDistance = ATR(ATR length) * stop-loss ATR multiplier
Calculation: LongStop = entry price - StopDistance on the entry bar; otherwise MAX(LongStop[1], close - ATR(ATR length) * trailing ATR multiplier) if close - entry price >= trail activation multiple * StopDistance, else LongStop[1]
Calculation: ShortStop = entry price + StopDistance on the entry bar; otherwise MIN(ShortStop[1], close + ATR(ATR length) * trailing ATR multiplier) if entry price - close >= trail activation multiple * StopDistance, else ShortStop[1]
Long: LongSetup AND position side is flat AND (BullDisplacement OR BullPatternBar OR (close > SMA(close, shortest lookback) AND close > VWAP(hlc3)))
Short: ShortSetup AND position side is flat AND (BearDisplacement OR BearPatternBar OR (close < SMA(close, shortest lookback) AND close < VWAP(hlc3)))
Exit: Long, low <= LongStop OR high >= entry price + StopDistance on the entry bar * reward-to-risk ratio
Exit: Long, EndOfDay
Exit: Short, high >= ShortStop OR low <= entry price - StopDistance on the entry bar * reward-to-risk ratio
Exit: Short, EndOfDay
Long: BullDisplacement AND NOT LongSetup
Long: BullPatternBar
Long: BullPatternBar AND NOT LongSetup
Short: BearDisplacement AND NOT ShortSetup
Short: BearPatternBar
Short: BearPatternBar AND NOT ShortSetup