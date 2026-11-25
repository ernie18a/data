Calculation: MacdRising(series) = MACD histogram(series, MACD fast length, MACD slow length, MACD signal length) > MACD histogram(series, MACD fast length, MACD slow length, MACD signal length)[1]
Calculation: MacdFalling(series) = MACD histogram(series, MACD fast length, MACD slow length, MACD signal length) < MACD histogram(series, MACD fast length, MACD slow length, MACD signal length)[1]
Calculation: SniperLongBreak = open < EMA(close, EMA length) AND close > EMA(close, EMA length) AND BARSSINCE(RSI(close, RSI length) < RSI oversold level) < memory AND BARSSINCE(MacdRising(close)) < memory
Calculation: SniperShortBreak = open > EMA(close, EMA length) AND close < EMA(close, EMA length) AND BARSSINCE(RSI(close, RSI length) > RSI overbought level) < memory AND BARSSINCE(MacdFalling(close)) < memory
Calculation: SniperEntry = (SniperLongBreak OR SniperShortBreak) AND BARSSINCE(SniperEntry)[1] >= cooldown
Long: SniperEntry AND SniperLongBreak
Short: SniperEntry AND SniperShortBreak
Exit: long, bars since entry >= max trade bars
Exit: long, low <= LOWEST(low, phase length)[bars since entry]
Exit: long, high >= entry price + (entry price - LOWEST(low, phase length)[bars since entry]) * reward-to-risk ratio
Exit: short, bars since entry >= max trade bars
Exit: short, high >= HIGHEST(high, phase length)[bars since entry]
Exit: short, low <= entry price - (HIGHEST(high, phase length)[bars since entry] - entry price) * reward-to-risk ratio
Calculation: SuperTrendLevel = SUPERTREND(ROUND(AVG(supertrend base factor, smooth trail multiplier)), supertrend ATR factor * smooth trail length)
Calculation: SmoothTrailLevel = IF close > SuperTrendLevel THEN AVG(SuperTrendLevel, SuperTrendLevel, SuperTrendLevel, HMA(low, ROUND(AVG(hull base length, smooth trail length))) - ATR(smooth trail ATR length) * ROUND(smooth trail multiplier / hull divisor), LOWEST(close, smooth trail length) + ATR(smooth trail ATR length)) ELSE AVG(SuperTrendLevel, SuperTrendLevel, SuperTrendLevel, HMA(high, ROUND(AVG(hull base length, smooth trail length))) + ATR(smooth trail ATR length) * ROUND(smooth trail multiplier / hull divisor), HIGHEST(close, smooth trail length) + ATR(smooth trail ATR length))
Long: close > SmoothTrailLevel
Short: close <= SmoothTrailLevel
Long: T1 close > SmoothTrailLevel, where SmoothTrailLevel is computed on T1 bars and uses the T1 bar still forming
Short: T1 close <= SmoothTrailLevel, where SmoothTrailLevel is computed on T1 bars and uses the T1 bar still forming
Calculation: ExtBreakLong = external close[1] > EMA(external close, external EMA length)[1] AND external close[2] < EMA(external close, external EMA length)[2]
Calculation: ExtBreakShort = external close[1] < EMA(external close, external EMA length)[1] AND external close[2] > EMA(external close, external EMA length)[2]
Calculation: ExtSetupLong = RSI(external close, external RSI length) < external RSI oversold level AND MacdRising(external close)
Calculation: ExtSetupShort = RSI(external close, external RSI length) > external RSI overbought level AND MacdFalling(external close)
Calculation: ExtBiasLong = COUNT(external close > EMA(external close, external EMA length), bias lookback) >= COUNT(external close <= EMA(external close, external EMA length), bias lookback)
Long: external close > EMA(external close, external EMA length)
Short: external close <= EMA(external close, external EMA length)
Long: ExtBreakLong
Short: ExtBreakShort
Long: ExtSetupLong AND NOT ExtBreakLong AND NOT ExtBreakShort
Short: ExtSetupShort AND NOT ExtBreakLong AND NOT ExtBreakShort
Long: ExtBiasLong
Short: NOT ExtBiasLong
Calculation: LastPivotHigh = latest non-NA PIVOTHIGH(high, liquidity pivot length, liquidity pivot length)
Calculation: UpGrabArmed = (NOT NA(PIVOTHIGH(high, liquidity pivot length, liquidity pivot length))) OR (UpGrabArmed[1] AND NOT BearishGrab)
Calculation: BearishGrab = high > LastPivotHigh AND close < LastPivotHigh AND high > high[1] AND UpGrabArmed[1]
Calculation: LastPivotLow = latest non-NA PIVOTLOW(low, liquidity pivot length, liquidity pivot length)
Calculation: DnGrabArmed = (NOT NA(PIVOTLOW(low, liquidity pivot length, liquidity pivot length))) OR (DnGrabArmed[1] AND NOT BullishGrab)
Calculation: BullishGrab = low < LastPivotLow AND close > LastPivotLow AND low < low[1] AND DnGrabArmed[1]
Long: BullishGrab
Short: BearishGrab