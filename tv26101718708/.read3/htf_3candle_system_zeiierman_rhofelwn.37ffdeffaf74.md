Calculation: C1, C2, C3 = OHLC from T1; C1 is two completed T1 bars back, C2 is the last completed T1 bar, and C3 is the current forming T1 bar; evaluate on chart bars using T1 values
Calculation: Range(X) = max(X.high - X.low, minimum tick size)
Calculation: Body(X) = abs(X.close - X.open)
Calculation: BodyRatio(X) = Body(X) / Range(X)
Calculation: ClosePosition(X) = (X.close - X.low) / Range(X)
Calculation: Clip(x) = max(0, min(1, x))
Calculation: Near(x, level, scale) = 1 - min(abs(x - level) / max(scale, minimum tick size), 1)
Calculation: Points(condition, weight) = condition ? weight : 0
Calculation: SafeATR = max(ATR(lookback parameter, T1, current forming bar), minimum tick size)
Calculation: C1Mid = (C1.open + C1.close) / 2
Calculation: SmallC2 = Clip((K_A - BodyRatio(C2)) / K_B)
Calculation: BullishSweepScore = Points(C1.close < C1.open, W_A) + Points(C2.low < C1.low, W_B) + (C2.low >= C1.low ? W_A * Near(C2.low, C1.low, SafeATR * K_A) : 0) + Points(C2.close > C1.low, W_C) + (C2.close <= C1.low ? W_A * Near(C2.close, C1.low, SafeATR * K_A) : 0) + Points(C2.close > C2.open, W_A) + Points(C3.close > C3.open, W_A) + W_C * (C3.close > C2.high ? K_H : Near(C3.close, C2.high, SafeATR)) + W_E * BodyRatio(C1)
Calculation: BearishSweepScore = Points(C1.close > C1.open, W_A) + Points(C2.high > C1.high, W_B) + (C2.high <= C1.high ? W_A * Near(C2.high, C1.high, SafeATR * K_A) : 0) + Points(C2.close < C1.high, W_C) + (C2.close >= C1.high ? W_A * Near(C2.close, C1.high, SafeATR * K_A) : 0) + Points(C2.close < C2.open, W_A) + Points(C3.close < C3.open, W_A) + W_C * (C3.close < C2.low ? K_H : Near(C3.close, C2.low, SafeATR)) + W_E * BodyRatio(C1)
Calculation: BullishFVGScore = Points(C2.close > C2.open, W_D) + W_C * Clip(BodyRatio(C2) / K_B) + W_D * Clip(Range(C2) / SafeATR) + W_B * (C3.low > C1.high ? K_H : K_A * Near(C3.low, C1.high, SafeATR * K_A)) + Points(C3.close > C3.open, W_A) + W_D * (C3.close > C2.close ? K_H : Near(C3.close, C2.close, SafeATR))
Calculation: BearishFVGScore = Points(C2.close < C2.open, W_D) + W_C * Clip(BodyRatio(C2) / K_B) + W_D * Clip(Range(C2) / SafeATR) + W_B * (C3.high < C1.low ? K_H : K_A * Near(C3.high, C1.low, SafeATR * K_A)) + Points(C3.close < C3.open, W_A) + W_D * (C3.close < C2.close ? K_H : Near(C3.close, C2.close, SafeATR))
Calculation: BullishPO3Score = W_C * Clip((K_C - Range(C1) / SafeATR) / K_D) + Points(C2.low < C1.low, W_B) + Points(C2.close > C1.low, W_D) + W_B * (C3.close > C1.high ? K_H : Near(C3.close, C1.high, SafeATR)) + Points(C3.close > C3.open, W_D)
Calculation: BearishPO3Score = W_C * Clip((K_C - Range(C1) / SafeATR) / K_D) + Points(C2.high > C1.high, W_B) + Points(C2.close < C1.high, W_D) + W_B * (C3.close < C1.low ? K_H : Near(C3.close, C1.low, SafeATR)) + Points(C3.close < C3.open, W_D)
Calculation: BullishExpansionScore = Points(C1.close > C1.open, W_D) + Points(C2.close > C2.open, W_D) + Points(C3.close > C3.open, W_D) + Points(C2.close > C1.close, W_A) + Points(C3.close > C2.close, W_A) + Points(Body(C2) >= Body(C1), W_D) + Points(Body(C3) >= Body(C2), W_A) + Points(C3.high > C2.high, W_A)
Calculation: BearishExpansionScore = Points(C1.close < C1.open, W_D) + Points(C2.close < C2.open, W_D) + Points(C3.close < C3.open, W_D) + Points(C2.close < C1.close, W_A) + Points(C3.close < C2.close, W_A) + Points(Body(C2) >= Body(C1), W_D) + Points(Body(C3) >= Body(C2), W_A) + Points(C3.low < C2.low, W_A)
Calculation: BullishCompressionScore = Points(C2.high < C1.high AND C2.low > C1.low, W_G) + Points(C3.close > C3.open, W_D) + W_F * (C3.close > C1.high ? K_H : Near(C3.close, C1.high, SafeATR)) + W_A * Clip(BodyRatio(C3) / K_E) + W_A * Clip((ClosePosition(C3) - K_A) / K_G)
Calculation: BearishCompressionScore = Points(C2.high < C1.high AND C2.low > C1.low, W_G) + Points(C3.close < C3.open, W_D) + W_F * (C3.close < C1.low ? K_H : Near(C3.close, C1.low, SafeATR)) + W_A * Clip(BodyRatio(C3) / K_E) + W_A * Clip((K_A - ClosePosition(C3)) / K_G)
Calculation: MorningStarScore = Points(C1.close < C1.open, W_C) + W_D * Clip(BodyRatio(C1) / K_E) + W_A * SmallC2 + Points(C3.close > C3.open, W_C) + W_C * (C3.close > C1Mid ? K_H : Near(C3.close, C1Mid, SafeATR)) + Points(C3.close > C1.open, W_E)
Calculation: EveningStarScore = Points(C1.close > C1.open, W_C) + W_D * Clip(BodyRatio(C1) / K_E) + W_A * SmallC2 + Points(C3.close < C3.open, W_C) + W_C * (C3.close < C1Mid ? K_H : Near(C3.close, C1Mid, SafeATR)) + Points(C3.close < C1.open, W_E)
Long: BullishSweepScore ranks first among all twelve pattern scores AND C2.low < C1.low
Short: BearishSweepScore ranks first among all twelve pattern scores AND C2.high > C1.high
Long: BullishFVGScore ranks first among all twelve pattern scores AND C3.low > C1.high
Short: BearishFVGScore ranks first among all twelve pattern scores AND C3.high < C1.low