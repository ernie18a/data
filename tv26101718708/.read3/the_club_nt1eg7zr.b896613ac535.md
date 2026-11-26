Calculation: BullTouch(level) = ABS(low - level) <= sweep zone AND close > open AND close > close[1]
Calculation: BearTouch(level) = ABS(high - level) <= sweep zone AND close < open AND close < close[1]
Calculation: CompletedHigh(T) = high of last completed T bar, taken on chart bars
Calculation: CompletedLow(T) = low of last completed T bar, taken on chart bars
Calculation: FreeSessionOpen(k) = open of today's bar at session open time k, or no value if an earlier entry today occurred on a bar that touched that level
Calculation: EntryGate = position is flat AND entries today < max daily entries AND (NOT use session filter OR bar time (New York) in London session window OR bar time (New York) in NY open session window)
Calculation: VolumeSurge = volume[1] >= SMA(volume, volume lookback)[1] * volume multiplier
Calculation: MorningDirection = 0 if no bar at session open time 3 has occurred today, otherwise +1 if that bar's close > open, else -1
Calculation: StopLongPrice = IF(wick-based stop mode, low of entry signal bar - wick buffer, entry price - fixed stop distance)
Calculation: StopShortPrice = IF(wick-based stop mode, high of entry signal bar + wick buffer, entry price + fixed stop distance)
Calculation: Tp1PriceLong = entry price + (entry price - StopLongPrice) * TP1 multiplier
Calculation: Tp1PriceShort = entry price - (StopShortPrice - entry price) * TP1 multiplier
Calculation: Tp1ReachedLong = an earlier bar since entry had high >= Tp1PriceLong
Calculation: Tp1ReachedShort = an earlier bar since entry had low <= Tp1PriceShort
Long: EntryGate AND VolumeSurge AND (NOT use EMA filter OR close > EMA(close, EMA length)) AND (NOT use morning bias filter OR MorningDirection >= 0) AND close > EMA(close, HTF EMA length, T1, last completed bar) AND (BullTouch(CompletedHigh(T2)) OR BullTouch(CompletedLow(T2)) OR (bar is on Monday AND (BullTouch(CompletedHigh(T3)) OR BullTouch(CompletedLow(T3)))) OR BullTouch(FreeSessionOpen(1)) OR BullTouch(FreeSessionOpen(2)) OR BullTouch(FreeSessionOpen(3)) OR BullTouch(FreeSessionOpen(4)) OR BullTouch(FreeSessionOpen(5)))
Short: EntryGate AND VolumeSurge AND (NOT use EMA filter OR close < EMA(close, EMA length)) AND (NOT use morning bias filter OR MorningDirection <= 0) AND close < EMA(close, HTF EMA length, T1, last completed bar) AND (BearTouch(CompletedHigh(T2)) OR BearTouch(CompletedLow(T2)) OR (bar is on Monday AND (BearTouch(CompletedHigh(T3)) OR BearTouch(CompletedLow(T3)))) OR BearTouch(FreeSessionOpen(1)) OR BearTouch(FreeSessionOpen(2)) OR BearTouch(FreeSessionOpen(3)) OR BearTouch(FreeSessionOpen(4)) OR BearTouch(FreeSessionOpen(5)))
Exit: long, low <= StopLongPrice AND NOT Tp1ReachedLong
Exit: long, low <= entry price AND Tp1ReachedLong
Exit: long, high >= Tp1PriceLong AND NOT Tp1ReachedLong
Exit: long, high >= entry price + (entry price - StopLongPrice) * TP2 multiplier
Exit: long, bars since entry >= max bars in trade
Exit: long, bar time (New York) = EOD close time
Exit: short, high >= StopShortPrice AND NOT Tp1ReachedShort
Exit: short, high >= entry price AND Tp1ReachedShort
Exit: short, low <= Tp1PriceShort AND NOT Tp1ReachedShort
Exit: short, low <= entry price - (StopShortPrice - entry price) * TP2 multiplier
Exit: short, bars since entry >= max bars in trade
Exit: short, bar time (New York) = EOD close time