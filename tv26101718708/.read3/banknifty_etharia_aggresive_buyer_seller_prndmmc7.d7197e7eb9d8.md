Calculation: BarsSinceEntry = number of bars after the entry bar through the current bar
Calculation: LinRegValue = LinReg(close, LinReg lookback)
Calculation: VWAPValue = VWAP(close, session anchor) if VWAP type is session, else SMA(HLC3, VWAP lookback)
Calculation: CVD = CumSum(Sign(close - open) * volume)
Calculation: SessionBars = number of bars from session start through the current bar
Calculation: LongStop = entry price - fixed stop distance if stop type is Fixed, entry price - ATR(ATR lookback) at entry * ATR multiplier if stop type is ATR, MIN(Lowest(low, swing lookback) at entry, entry price - ATR(ATR lookback) at entry * ATR multiplier) if stop type is Swing
Calculation: ShortStop = entry price + fixed stop distance if stop type is Fixed, entry price + ATR(ATR lookback) at entry * ATR multiplier if stop type is ATR, MAX(Highest(high, swing lookback) at entry, entry price + ATR(ATR lookback) at entry * ATR multiplier) if stop type is Swing
Calculation: LongT1 = entry price + first target R multiple * (entry price - LongStop)
Calculation: LongT2 = entry price + second target R multiple * (entry price - LongStop)
Calculation: ShortT1 = entry price - first target R multiple * (ShortStop - entry price)
Calculation: ShortT2 = entry price - second target R multiple * (ShortStop - entry price)
Calculation: LongActiveStop = IF Highest(close, BarsSinceEntry) >= entry price + activation R multiple * (entry price - LongStop) THEN Highest(close, BarsSinceEntry) - trail distance R multiple * (entry price - LongStop) ELSE IF Highest(high, BarsSinceEntry)[1] >= LongT1 THEN entry price ELSE LongStop
Calculation: ShortActiveStop = IF Lowest(close, BarsSinceEntry) <= entry price - activation R multiple * (ShortStop - entry price) THEN Lowest(close, BarsSinceEntry) + trail distance R multiple * (ShortStop - entry price) ELSE IF Lowest(low, BarsSinceEntry)[1] <= ShortT1 THEN entry price ELSE ShortStop
Long: LinRegValue > LinRegValue[1] AND close > LinRegValue AND close > VWAPValue AND VWAPValue > VWAPValue[1] AND CVD > SMA(CVD, CVD smoothing lookback) AND Rising(CVD, CVD run length) AND RSI(close, RSI lookback) > RSI oversold level AND RSI(close, RSI lookback) < RSI overbought level AND (volume > SMA(volume, volume lookback) * volume multiplier OR Rising(volume, volume run length)) AND close > open AND (close - open) >= body percent * (high - low) AND (high - low) >= min candle size AND close >= high - (high - low) * close zone fraction AND bar time >= session start time AND bar time <= session end time AND SessionBars > skip bars count AND position side is flat
Short: LinRegValue < LinRegValue[1] AND close < LinRegValue AND close < VWAPValue AND VWAPValue < VWAPValue[1] AND CVD < SMA(CVD, CVD smoothing lookback) AND Falling(CVD, CVD run length) AND RSI(close, RSI lookback) > RSI oversold level AND RSI(close, RSI lookback) < RSI overbought level AND (volume > SMA(volume, volume lookback) * volume multiplier OR Rising(volume, volume run length)) AND close < open AND (open - close) >= body percent * (high - low) AND (high - low) >= min candle size AND close <= low + (high - low) * close zone fraction AND bar time >= session start time AND bar time <= session end time AND SessionBars > skip bars count AND position side is flat
Exit: long, low <= LongActiveStop
Exit: long, Highest(high, BarsSinceEntry) crosses above LongT1 AND low > LongActiveStop
Exit: long, Highest(high, BarsSinceEntry)[1] >= LongT1 AND high >= LongT2 AND low > LongActiveStop
Exit: long, bar time >= session end time - exit lead minutes AND low > LongActiveStop AND (high < LongT1 OR (Highest(high, BarsSinceEntry)[1] >= LongT1 AND high < LongT2))
Exit: long, Highest(high, BarsSinceEntry) >= LongT1 AND (close < LinRegValue AND LinRegValue < LinRegValue[1] OR close < VWAPValue)
Exit: short, high >= ShortActiveStop
Exit: short, Lowest(low, BarsSinceEntry) crosses below ShortT1 AND high < ShortActiveStop
Exit: short, Lowest(low, BarsSinceEntry)[1] <= ShortT1 AND low <= ShortT2 AND high < ShortActiveStop
Exit: short, bar time >= session end time - exit lead minutes AND high < ShortActiveStop AND (low > ShortT1 OR (Lowest(low, BarsSinceEntry)[1] <= ShortT1 AND low > ShortT2))
Exit: short, Lowest(low, BarsSinceEntry) <= ShortT1 AND (close > LinRegValue AND LinRegValue > LinRegValue[1] OR close > VWAPValue)