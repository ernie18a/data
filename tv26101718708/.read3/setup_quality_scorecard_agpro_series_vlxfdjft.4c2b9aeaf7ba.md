Calculation: Rise(x, weak, strong) = clamp((x - weak) / (strong - weak) * 100, 0, 100)
Calculation: ATR = ATR(ATR length)
Calculation: Fast EMA = EMA(close, fast length)
Calculation: Mid EMA = EMA(close, mid length)
Calculation: Slow EMA = EMA(close, slow length)
Calculation: RSI = RSI(close, RSI length)
Calculation: T1 Close = close(T1, last completed bar)
Calculation: T1 Fast EMA = EMA(close, fast length, T1, last completed bar)
Calculation: T1 Slow EMA = EMA(close, slow length, T1, last completed bar)
Calculation: Confirmed Bar = live-updating flag OR bar is closed
Calculation: Trend Long = Fast EMA > Mid EMA AND Mid EMA > Slow EMA
Calculation: Trend Short = Fast EMA < Mid EMA AND Mid EMA < Slow EMA
Calculation: HTF Long = T1 Close > T1 Fast EMA AND T1 Fast EMA > T1 Slow EMA
Calculation: HTF Short = T1 Close < T1 Fast EMA AND T1 Fast EMA < T1 Slow EMA
Calculation: Slope Long = Fast EMA > Fast EMA[slope lag]
Calculation: Slope Short = Fast EMA < Fast EMA[slope lag]
Calculation: Candle Long = close > open
Calculation: Candle Short = close < open
Calculation: Long Votes = number of true among Trend Long, HTF Long, Slope Long, close > Fast EMA, Candle Long
Calculation: Short Votes = number of true among Trend Short, HTF Short, Slope Short, close < Fast EMA, Candle Short
Calculation: Long Side = Long Votes > Short Votes
Calculation: Short Side = Short Votes > Long Votes
Calculation: Directional Side = Long Side OR Short Side
Calculation: Active Pivot High = price of the latest PivotHigh(high, pivot length, pivot length) whose bar is at most lookback bars before the current bar, else NA
Calculation: Active Pivot Low = price of the latest PivotLow(low, pivot length, pivot length) whose bar is at most lookback bars before the current bar, else NA
Calculation: Max Risk = max risk ATR * sensitivity factor
Calculation: Ideal Risk = ideal risk ATR * sensitivity factor
Calculation: Min Room = min room ATR / sensitivity factor
Calculation: Reference Level = if Long Side then (Active Pivot Low if it is not NA, else Fast EMA) else (Active Pivot High if it is not NA, else Fast EMA)
Calculation: Location Score = Rise(abs(close - Reference Level) / ATR, location bad distance * sensitivity factor, location good distance), capped at wrong-side cap if (Long Side AND close < Reference Level) OR (Short Side AND close > Reference Level)
Calculation: Trend Score = clamp(Stack * stack weight + HTF * htf weight + Slope * slope weight, 0, 100), where Stack = if Long Side then (100 if Trend Long, else stack-mid score if close > Mid EMA, else stack-slow score if close > Slow EMA, else stack-low score) else (100 if Trend Short, else stack-mid score if close < Mid EMA, else stack-slow score if close < Slow EMA, else stack-low score), HTF = if Long Side then (100 if HTF Long, else htf-fast score if T1 Close > T1 Fast EMA, else htf-low score) else (100 if HTF Short, else htf-fast score if T1 Close < T1 Fast EMA, else htf-low score), Slope = if Long Side then (100 if Slope Long, else neutral score) else (100 if Slope Short, else neutral score)
Calculation: Momentum Score = clamp(RSI Part * RSI weight + Delta Part * delta weight + Candle Part * candle weight + Volume Part * volume weight, 0, 100), where RSI Part = if Long Side then Rise(RSI, long RSI weak, long RSI strong) else Rise(RSI mirror level - RSI, short RSI weak, short RSI strong), Delta Part = if Long Side then Rise(RSI - RSI[delta lag], delta weak, delta strong) else Rise(RSI[delta lag] - RSI, delta weak, delta strong), Candle Part = if (Long Side AND Candle Long) OR (Short Side AND Candle Short) then Rise(abs(close - open) / (high - low), aligned body weak, aligned body strong) else Rise(abs(close - open) / (high - low), opposed body bad, opposed body good), Volume Part = if volume context flag then Rise(volume / SMA(volume, volume average length), volume weak, volume strong) else neutral volume score
Calculation: Invalidation Edge = if Long Side then (Active Pivot Low - ATR * edge buffer if Active Pivot Low is not NA, else low - ATR * Ideal Risk) else (Active Pivot High + ATR * edge buffer if Active Pivot High is not NA, else high + ATR * Ideal Risk)
Calculation: Setup Invalidated = (Long Side AND close <= Invalidation Edge) OR (Short Side AND close >= Invalidation Edge)
Calculation: Risk ATR = abs(close - Invalidation Edge) / ATR
Calculation: Risk Fit Score = if Setup Invalidated then 0 else if Risk ATR <= Ideal Risk then Rise(Risk ATR, risk fit floor, Ideal Risk) else Rise(Risk ATR, Max Risk, Ideal Risk)
Calculation: Target Level = if Long Side then (Active Pivot High if it is not NA and is above close, else close + abs(close - Invalidation Edge) * target R multiple) else (Active Pivot Low if it is not NA and is below close, else close - abs(close - Invalidation Edge) * target R multiple)
Calculation: Target Room ATR = abs(Target Level - close) / ATR
Calculation: Room Score = Rise(Target Room ATR, Min Room * room weak fraction, Min Room * room strong fraction)
Calculation: Readiness Score = clamp(Location Score * location weight + Trend Score * trend weight + Momentum Score * momentum weight + Risk Fit Score * risk weight + Room Score * room weight, 0, 100)
Calculation: Checklist Count = number of true among (Trend Score >= bias threshold), (Location Score >= component threshold), (Momentum Score >= component threshold), (Risk Fit Score >= component threshold), (Room Score >= component threshold AND Target Room ATR >= Min Room)
Calculation: Risk Blocked = Risk ATR > Max Risk OR Target Room ATR < Min Room
Calculation: Ready State = Directional Side AND NOT Setup Invalidated AND NOT Risk Blocked AND Readiness Score >= ready threshold AND Checklist Count >= ready checklist minimum
Calculation: Monitor State = Directional Side AND NOT Setup Invalidated AND NOT Ready State AND Readiness Score >= monitor threshold AND Checklist Count >= monitor checklist minimum
Calculation: Blocked State = Directional Side AND NOT Setup Invalidated AND NOT Ready State AND NOT Monitor State AND (Risk Blocked OR Checklist Count <= blocked checklist maximum)
Calculation: Ready Event = Confirmed Bar AND Ready State AND NOT Ready State[1]
Calculation: Monitor Event = Confirmed Bar AND Monitor State AND NOT Monitor State[1]
Calculation: Blocked Event = Confirmed Bar AND Blocked State AND NOT Blocked State[1]
Calculation: Invalidation Event = Confirmed Bar AND Setup Invalidated AND NOT Setup Invalidated[1]
Calculation: Follow-Through Event = Confirmed Bar AND Directional Side AND (Ready State[1] OR Monitor State[1]) AND Readiness Score[1] >= monitor threshold AND ((Long Side AND high >= Target Level) OR (Short Side AND low <= Target Level))
Calculation: Context Condition = Confirmed Bar AND Directional Side AND NOT Setup Invalidated AND Checklist Count >= context checklist minimum AND (Ready State OR Monitor State OR Readiness Score >= monitor threshold - context margin)
Long: Ready Event AND Long Side
Short: Ready Event AND Short Side
Long: Monitor Event AND Long Side
Short: Monitor Event AND Short Side
Long: Blocked Event AND Long Side
Short: Blocked Event AND Short Side
Long: Follow-Through Event AND Long Side
Short: Follow-Through Event AND Short Side
Long: Context Condition AND Long Side
Short: Context Condition AND Short Side
Long: Long Side
Short: Short Side
Exit: Long, Invalidation Event AND Long Side
Exit: Short, Invalidation Event AND Short Side