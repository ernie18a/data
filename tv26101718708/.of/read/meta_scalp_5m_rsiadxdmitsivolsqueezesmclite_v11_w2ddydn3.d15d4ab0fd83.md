Calculation: Tol = ATR(current chart timeframe) * small fraction
Calculation: EQH = when a confirmed pivot high (high is the highest over a left window and a right window of bars, known only after the right window completes) lies within Tol of the previous confirmed pivot high and within a bar lookback of it, EQH = mean of the two; the latest EQH persists until replaced
Calculation: EQL = same as EQH using confirmed pivot lows
Calculation: LastSwingHigh / LastSwingLow = latest confirmed pivot high / pivot low
Calculation: SweepHigh = EQH exists AND high > EQH + 0.25*Tol AND close < EQH
Calculation: SweepLow = EQL exists AND low < EQL - 0.25*Tol AND close > EQL
Calculation: BosUp = close > LastSwingHigh; BosDn = close < LastSwingLow
Calculation: Squeeze = Bollinger Bands (SMA(close) +/- mult*stdev(close)) lie entirely inside Keltner Channel (EMA(close) +/- mult*EMA(true range), same length for center and range)
Calculation: Mom = linear regression value at the current bar, over the Keltner length, of (close - SMA(close, Keltner length))
Calculation: TSI = 100 * double-EMA(close change; long then short smoothing) / double-EMA(abs(close change); same smoothing); TSISignal = EMA(TSI)
Calculation: Score = sum of the components below (each is +/- its own weight; weights are parameters); then if the higher-timeframe (still-forming bar) fast EMA(close) > slow EMA(close) and the sum < 0, or fast < slow and the sum > 0, multiply the sum by a factor in (0,1) and round; then clip to [-100, 100]
Calculation: Score component Trend = +w if fast EMA(close) > slow EMA(close) (fast has the shorter lookback) AND fast EMA rising for 3 consecutive bars; -w if fast < slow AND fast falling for 3 consecutive bars; else 0
Calculation: Score component RSI = sign(RSI - midpoint) * w * min(1, abs(RSI - midpoint)/scale), rounded
Calculation: Score component DMI = +w if +DI > -DI AND ADX >= minimum; -w if -DI > +DI AND ADX >= minimum; else 0
Calculation: Score component TSI = +w if TSI > TSISignal; -w if TSI < TSISignal
Calculation: Score component Volume = if volume > SMA(volume) * multiplier(>1): +w if close >= open else -w; else 0
Calculation: Score component Squeeze = +w if Squeeze is off AND Mom > 0 AND Mom rising for 2 bars; -w if Squeeze is off AND Mom < 0 AND Mom falling for 2 bars; else 0
Calculation: Score component SMC = (-w if SweepHigh) + (+w if SweepLow) + (+0.6w if BosUp) + (-0.6w if BosDn)
Long: Score >= entry threshold AND ADX >= minimum
Long: SweepLow
Short: Score <= -entry threshold AND ADX >= minimum
Short: SweepHigh
Exit: long, Score <= exit threshold (positive, smaller than entry threshold) OR low <= entry price - ATR*SL multiplier OR high >= entry price + ATR*TP multiplier (ATR of the current bar)
Exit: short, Score >= -exit threshold OR high >= entry price + ATR*SL multiplier OR low <= entry price - ATR*TP multiplier (ATR of the current bar)