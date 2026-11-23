Calculation: SignedVolume = sum over the T1 bars inside the chart bar of sign(close - open) * volume, evaluated on the closed chart bar
Calculation: SignalMA = MA(close, signal length)
Calculation: Bias(T) = 1 if close > EMA(close, bias length) AND EMA(close, bias length) > EMA(close, bias length)[1]; -1 if close < EMA(close, bias length) AND EMA(close, bias length) < EMA(close, bias length)[1]; 0 otherwise; computed on T bars, value of the last completed T bar
Calculation: BullAlignment = Bias(T2) = 1 AND Bias(T3) = 1
Calculation: BearAlignment = Bias(T2) = -1 AND Bias(T3) = -1
Calculation: BullAbsorption = volume > SMA(volume, volume average length) * volume multiple AND SignedVolume / volume * 100 <= -minimum delta percent AND close >= MEDPRICE(high, low)
Calculation: BearAbsorption = volume > SMA(volume, volume average length) * volume multiple AND SignedVolume / volume * 100 >= minimum delta percent AND close <= MEDPRICE(high, low)
Calculation: BullGap(S) = low > high[2] AND low - high[2] >= minimum gap(S), with top = low and bottom = high[2]; S is chart bars, or T4, T5 or T6 bars whose newest bar is the last completed one, tested on the first chart bar of each new bar and only when that timeframe is above the chart timeframe
Calculation: BearGap(S) = high < low[2] AND low[2] - high >= minimum gap(S), with top = low[2] and bottom = high; same S, timing and timeframe condition as BullGap(S)
Calculation: BullGapRetest(S) = low <= top AND close >= bottom on chart bars, for a BullGap(S) formed at an earlier bar, where no bar since its formation before now had low <= top, and which is among the newest max active gaps(S) bull gaps of S not yet closed through
Calculation: BearGapRetest(S) = high >= bottom AND close <= top on chart bars, for a BearGap(S) formed at an earlier bar, where no bar since its formation before now had high >= bottom, and which is among the newest max active gaps(S) bear gaps of S not yet closed through
Calculation: LongTriggers = count of true among: (low <= SignalMA AND close > SignalMA AND SignalMA > SignalMA[slope lookback]), BullGapRetest(chart), BullGapRetest(T4), BullGapRetest(T5), BullGapRetest(T6), BullAbsorption
Calculation: ShortTriggers = count of true among: (high >= SignalMA AND close < SignalMA AND SignalMA < SignalMA[slope lookback]), BearGapRetest(chart), BearGapRetest(T4), BearGapRetest(T5), BearGapRetest(T6), BearAbsorption
Calculation: StopDistance = stop multiple * ATR(ATR length) at the entry bar
Long: BullGap(chart) OR BullGap(T4) OR BullGap(T5) OR BullGap(T6)
Long: BullAbsorption
Short: BearGap(chart) OR BearGap(T4) OR BearGap(T5) OR BearGap(T6)
Short: BearAbsorption
Long: LongTriggers >= minimum trigger count AND LongTriggers > ShortTriggers AND LongTriggers + (close > VWAP(HLC3, anchor)) + BullAlignment >= minimum grade score AND close > VWAP(HLC3, anchor) AND BullAlignment AND bar time within signal window AND bars since last Long or Short signal > cooldown
Short: ShortTriggers >= minimum trigger count AND ShortTriggers > LongTriggers AND ShortTriggers + (close < VWAP(HLC3, anchor)) + BearAlignment >= minimum grade score AND close < VWAP(HLC3, anchor) AND BearAlignment AND bar time within signal window AND bars since last Long or Short signal > cooldown
Exit: long, low <= entry price - StopDistance OR high >= entry price + target multiple * StopDistance
Exit: short, high >= entry price + StopDistance OR low <= entry price - target multiple * StopDistance