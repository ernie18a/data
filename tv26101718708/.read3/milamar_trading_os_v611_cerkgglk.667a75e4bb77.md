Calculation: ClosePosition = (close - low) / (high - low), or 0.5 when high = low
Calculation: VolatilityRatio = ATR(ATR length) / SMA(ATR(ATR length), average length)
Calculation: ConfirmationMinScore = if VolatilityRatio >= extreme ratio then extreme score, else min(score cap, base score + (volatile bonus if VolatilityRatio >= volatile ratio, else 0) + (stop bonus if a non-break-even stop exit occurred earlier in session, else 0))
Calculation: LongConfirmationScore = w1*(close > long entry) + w2*(close > long level) + w3*(close > open) + w4*(ClosePosition > long position threshold) + w5*(close > VWAP(hlc3)) + w6*(close > close[1])
Calculation: ShortConfirmationScore = w1*(close < short entry) + w2*(close < short level) + w3*(close < open) + w4*(ClosePosition < short position threshold) + w5*(close < VWAP(hlc3)) + w6*(close < close[1])
Calculation: LongZoneLimit = long entry - zone fraction * abs(long entry - long stop)
Calculation: ShortZoneLimit = short entry + zone fraction * abs(short entry - short stop)
Calculation: LongArmEvent = abs(close - long level) <= priority range OR close crosses above long level OR (low <= long level AND close > long level AND close crossed above long level earlier in session)
Calculation: ShortArmEvent = abs(close - short level) <= priority range OR close crosses below short level OR (high >= short level AND close < short level AND close crossed below short level earlier in session)
Calculation: SetupArmedInSession = SetupArmedInSession[1] OR LongArmNow OR ShortArmNow
Calculation: LongArmNow = LongArmEvent AND NOT SetupArmedInSession[1] AND time >= session start
Calculation: ShortArmNow = ShortArmEvent AND NOT SetupArmedInSession[1] AND NOT LongArmNow AND time >= session start
Calculation: LongTouch = (LongArmNow OR LongArmedState[1]) AND bar is closed AND low <= long entry AND close >= LongZoneLimit
Calculation: ShortTouch = (ShortArmNow OR ShortArmedState[1]) AND bar is closed AND high >= short entry AND close <= ShortZoneLimit
Calculation: HighSinceArm = high if LongArmNow or ShortArmNow; else max(HighSinceArm[1], high) if LongArmedState[1] or ShortArmedState[1]; else HighSinceArm[1]
Calculation: LowSinceArm = low if LongArmNow or ShortArmNow; else min(LowSinceArm[1], low) if LongArmedState[1] or ShortArmedState[1]; else LowSinceArm[1]
Calculation: LongConsume = LongArmedState[1] AND NOT LongTouch AND (HighSinceArm >= long TP1 OR HighSinceArm >= long TP2)
Calculation: ShortConsume = ShortArmedState[1] AND NOT ShortTouch AND (LowSinceArm <= short TP1 OR LowSinceArm <= short TP2)
Calculation: LongArmedState = (LongArmNow OR LongArmedState[1] OR LongExpire) AND NOT LongTouch AND NOT LongConsume
Calculation: ShortArmedState = (ShortArmNow OR ShortArmedState[1] OR ShortExpire) AND NOT ShortTouch AND NOT ShortConsume
Calculation: LongConfirm = bar is closed AND (LongTouch OR LongTouchedState[1]) AND LongConfirmationScore >= ConfirmationMinScore AND time not within US open window
Calculation: ShortConfirm = bar is closed AND (ShortTouch OR ShortTouchedState[1]) AND ShortConfirmationScore >= ConfirmationMinScore AND time not within US open window
Calculation: LongTouchedState = (LongTouch OR LongTouchedState[1]) AND NOT LongConfirm AND NOT LongExpire
Calculation: ShortTouchedState = (ShortTouch OR ShortTouchedState[1]) AND NOT ShortConfirm AND NOT ShortExpire
Calculation: LongExpire = bar is closed AND LongTouchedState[1] AND NOT LongConfirm AND (bars since the touch >= confirmation max bars OR close < LongZoneLimit)
Calculation: ShortExpire = bar is closed AND ShortTouchedState[1] AND NOT ShortConfirm AND (bars since the touch >= confirmation max bars OR close > ShortZoneLimit)
Long: LongArmNow
Long: LongTouch
Long: LongConfirm
Short: ShortArmNow
Short: ShortTouch
Short: ShortConfirm
Long: close crosses above B long level AND abs(close - long level) > priority range AND abs(close - short level) > priority range AND position is flat AND time >= session start
Short: close crosses below B short level AND abs(close - long level) > priority range AND abs(close - short level) > priority range AND position is flat AND time >= session start
Calculation: PositionTP1 = long TP1 if long, else short TP1
Calculation: PositionTP2 = long TP2 if long, else short TP2
Calculation: PositionStop = long stop if long, else short stop
Calculation: TP1Touch = bar after entry AND (high >= PositionTP1 if long, or low <= PositionTP1 if short)
Calculation: TP2Touch = bar after entry AND (high >= PositionTP2 if long, or low <= PositionTP2 if short)
Calculation: TP1Hit = TP1Hit[1] OR TP1Touch
Calculation: ActiveStop = entry price if BEActive[1], else PositionStop
Calculation: StopHit = bar after entry AND (low <= ActiveStop if long, or high >= ActiveStop if short)
Calculation: BEActive = BEActive[1] OR TP1Touch OR BEMove
Calculation: MFE = max(0, highest high since entry - entry price) if long, else max(0, entry price - lowest low since entry)
Calculation: MAE = max(0, entry price - lowest low since entry) if long, else max(0, highest high since entry - entry price)
Calculation: OpenPnL = close - entry price if long, else entry price - close
Calculation: Tp1Progress = min(100, MFE / abs(PositionTP1 - entry price) * 100)
Calculation: RiskUsed = min(100, MAE / abs(entry price - PositionStop) * 100)
Calculation: StallMinutes = minutes since the last bar on which MFE increased
Calculation: TradeAgeMinutes = minutes since entry time
Calculation: DayGroup = Balanced if day type is balanced, range or rotation; else With if day type trend matches position side (trend up for long, trend down for short); else Against if day type trend opposes position side; else Neutral
Calculation: ExpectedProgress = progress value of the highest age threshold of DayGroup reached by TradeAgeMinutes, or 0 below the first threshold
Calculation: ProgressScore = progress score 1 if Tp1Progress / max(ExpectedProgress, 1) >= progress ratio 1; else progress score 2 if >= progress ratio 2; else progress score 3 if >= progress ratio 3; else progress score 4 if >= progress ratio 4; else progress score 5
Calculation: EfficiencyScore = 0 if MFE <= 0; else efficiency score 1 if MFE / max(MAE, minimum tick) >= efficiency ratio 1; else efficiency score 2 if >= efficiency ratio 2; else efficiency score 3 if >= efficiency ratio 3; else efficiency score 4
Calculation: MomentumScore = momentum score 1 if StallMinutes <= momentum minutes 1; else momentum score 2 if StallMinutes <= momentum minutes 2; else momentum score 3 if StallMinutes <= StallLimit; else momentum score 4
Calculation: MaxHealthyAge = max healthy age of DayGroup
Calculation: CriticalAge = critical age of DayGroup
Calculation: StallLimit = stall limit of DayGroup
Calculation: AgeScore = age score 1 if TradeAgeMinutes <= MaxHealthyAge; else age score 2 if TradeAgeMinutes <= CriticalAge; else age score 3
Calculation: PricePositionScore = price score 1 if OpenPnL > 0; else price score 2 if OpenPnL >= 0; else price score 3
Calculation: ContextScore = context score of DayGroup
Calculation: HealthScore = min(100, max(0, ProgressScore + EfficiencyScore + MomentumScore + AgeScore + PricePositionScore + ContextScore))
Calculation: HealthHardExit = bar after entry AND NOT TP1Hit[1] AND ((TradeAgeMinutes >= age A against if DayGroup = Against, else age A) AND Tp1Progress < progress A AND RiskUsed > risk A OR TradeAgeMinutes >= age B AND Tp1Progress < progress B AND MFE <= MAE OR DayGroup = Balanced AND TradeAgeMinutes >= age C AND Tp1Progress < progress C OR DayGroup = Against AND TradeAgeMinutes >= age D AND Tp1Progress < progress D OR TradeAgeMinutes >= age E AND StallMinutes >= stall E AND Tp1Progress < progress E OR TradeAgeMinutes >= age F AND Tp1Progress < progress F AND OpenPnL <= 0 AND MFE <= MAE OR HealthScore < dead score)
Calculation: BEMove = bar after entry AND NOT TP1Hit[1] AND NOT TP1Touch AND NOT TP2Touch AND NOT StopHit AND NOT HealthHardExit AND OpenPnL > 0 AND ((Tp1Progress >= BE1 progress AND TradeAgeMinutes >= BE1 age AND StallMinutes >= BE1 stall AND abs(close - entry price) <= return zone fraction * abs(entry price - PositionStop)) OR (abs(entry price - PositionStop) > 0 AND MFE >= abs(entry price - PositionStop) AND StallMinutes >= BE2 stall) OR (DayGroup = Against AND Tp1Progress >= BE3 progress AND TradeAgeMinutes >= BE3 age AND StallMinutes >= BE3 stall))
Long: TP2Touch
Long: TP1Touch AND NOT TP1Hit[1]
Long: StopHit AND NOT TP2Touch
Long: HealthHardExit AND NOT TP1Touch AND NOT TP2Touch AND NOT StopHit
Short: TP2Touch
Short: TP1Touch AND NOT TP1Hit[1]
Short: StopHit AND NOT TP2Touch
Short: HealthHardExit AND NOT TP1Touch AND NOT TP2Touch AND NOT StopHit