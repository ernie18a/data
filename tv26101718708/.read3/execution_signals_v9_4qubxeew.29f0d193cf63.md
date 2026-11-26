Calculation: failHigh(B, P) = B.high > P.high AND B.close <= P.high AND B.high > MAX(B.open, B.close)
Calculation: failLow(B, P) = B.low < P.low AND B.close >= P.low AND B.low < MIN(B.open, B.close)
Calculation: insideBar(B, P) = B.high < P.high AND B.low > P.low
Calculation: noEntry(B) = time of day of B (exchange time) >= forceCloseTime AND time of day of B < eveningOpen
Calculation: forceClose(B) = time of day of B (exchange time) >= forceCloseTime AND time of day of B[1] < forceCloseTime
Calculation: signalBar = (lastCompletedT1.datetime - priorCompletedT1.datetime) <= gapFactor * duration(T1) AND (bar.datetime - lastCompletedT1.datetime) <= gapFactor * duration(T1) AND ((tradeFailures AND (failHigh(lastCompletedT1, priorCompletedT1) OR failLow(lastCompletedT1, priorCompletedT1))) OR (tradeInside AND insideBar(lastCompletedT1, priorCompletedT1)))
Calculation: pendingSignal = signalBar AND NOT noEntry(bar) AND no open position at bar, evaluated on the first chart bar of each T1 period
Calculation: earlierBreak = a chart bar earlier in the current T1 period closed above lastCompletedT1.high or below lastCompletedT1.low
Calculation: priorHigh = highest high of chart bars in the regular-session window of the most recent completed regular session
Calculation: priorLow = lowest low of chart bars in the regular-session window of the most recent completed regular session
Calculation: pdhlLong = NOT pdhlFilter OR (close >= priorLow AND NOT (close <= priorHigh AND blockInside))
Calculation: pdhlShort = NOT pdhlFilter OR (close <= priorHigh AND NOT (close >= priorLow AND blockInside))
Calculation: rawStopLong = stopModel selects bar[1].low, MIN(bar[1].low, bar.low), lastCompletedT1.low as of the directional-break or bias-set bar, or lastSetup.low (nested mode only; otherwise bar[1].low)
Calculation: rawStopShort = stopModel selects bar[1].high, MAX(bar[1].high, bar.high), lastCompletedT1.high as of the directional-break or bias-set bar, or lastSetup.high (nested mode only; otherwise bar[1].high)
Calculation: riskLong = riskCapOff OR MAX(close - rawStopLong, minStop) <= riskCap
Calculation: riskShort = riskCapOff OR MAX(rawStopShort - close, minStop) <= riskCap
Calculation: biasOn(B) = longBiasSet(J) or shortBiasSet(J) for some bar J < B with B - J < biasExpiry and no entry or forceClose bar in (J, B)
Calculation: earlierBiasSet(B) = longBiasSet or shortBiasSet at some bar earlier in the T1 period of B
Calculation: longBiasSet(B) = nestedMode AND pendingSignal of the T1 period of B AND NOT noEntry(B) AND no open position at B AND NOT biasOn(B) AND NOT earlierBiasSet(B) AND B.close > lastCompletedT1.high
Calculation: shortBiasSet(B) = nestedMode AND pendingSignal of the T1 period of B AND NOT noEntry(B) AND no open position at B AND NOT biasOn(B) AND NOT earlierBiasSet(B) AND B.close < lastCompletedT1.low
Calculation: biasLong(B) = longBiasSet(J) for some bar J <= B with B - J < biasExpiry and no entry or forceClose bar in (J, B)
Calculation: biasShort(B) = shortBiasSet(J) for some bar J <= B with B - J < biasExpiry and no entry or forceClose bar in (J, B)
Calculation: setupBar(B) = no open position at B AND NOT noEntry(B) AND no entry at B AND ((biasLong(B) AND ((tradeInside AND insideBar(B, B[1])) OR (tradeFailures AND (failLow(B, B[1]) OR (NOT matchBias AND failHigh(B, B[1])))))) OR (biasShort(B) AND ((tradeInside AND insideBar(B, B[1])) OR (tradeFailures AND (failHigh(B, B[1]) OR (NOT matchBias AND failLow(B, B[1])))))))
Calculation: lastSetup(B) = the most recent bar J < B with setupBar(J), provided B - J < ltfExpiry and no entry or forceClose bar in (J, B)
Long: NOT nestedMode AND pendingSignal AND close > lastCompletedT1.high AND NOT earlierBreak AND NOT noEntry(bar) AND pdhlLong AND riskLong
Short: NOT nestedMode AND pendingSignal AND close < lastCompletedT1.low AND NOT earlierBreak AND NOT noEntry(bar) AND pdhlShort AND riskShort
Long: biasLong(bar) AND NOT noEntry(bar) AND no open position AND lastSetup exists AND close > lastSetup.high AND pdhlLong AND riskLong
Short: biasShort(bar) AND NOT noEntry(bar) AND no open position AND lastSetup exists AND close < lastSetup.low AND pdhlShort AND riskShort
Calculation: stopLong = MIN(rawStopLong at the entry bar, entry price - minStop)
Calculation: stopShort = MAX(rawStopShort at the entry bar, entry price + minStop)
Exit: Long, bar after entry AND (low <= stopLong OR high >= entry price + rMultiple * (entry price - stopLong) OR forceClose(bar))
Exit: Short, bar after entry AND (high >= stopShort OR low <= entry price - rMultiple * (stopShort - entry price) OR forceClose(bar))