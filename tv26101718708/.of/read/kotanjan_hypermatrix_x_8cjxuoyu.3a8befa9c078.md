Calculation: norm(x) = x / SMA(|x|, n); 0 if the SMA is 0
Calculation: flowUp = close change over the last two bars are both positive (close[1]>close[2] AND close>close[1]); flowDown = both negative
Calculation: volSpike = volume > SMA(volume, n) * factor, with factor > 1
Calculation: compression = |close[1]-close[2]| < k*avgMove AND |close-close[1]| < k*avgMove, where avgMove = SMA(|close-close[1]|, n) and k < 1
Calculation: matrixScore = norm(ATR) + norm(close-close[1]) + norm(OBV - EMA(OBV)) + norm(ROC(close)) + norm(ATR / max(SMA(ATR), 1)) + norm(EMA(close, shorter) - EMA(close, longer)), all with the same n; OBV is cumulative volume, added when close>previous close, subtracted when close<previous close
Calculation: flowScore = (+1 if flowUp, -1 if flowDown, else 0) + (+1 if volSpike else 0) + (-1 if compression else +1)
Calculation: adxBoost = positive constant if Wilder ADX > SMA(ADX) else negative constant (positive magnitude larger than negative magnitude)
Calculation: macdBoost = MACD histogram * scale, clipped to [-cap, +cap]
Calculation: rsiPenalty = negative when RSI is overbought (more negative when RSI is more extremely overbought), positive when RSI is oversold (more positive when more extremely oversold), 0 otherwise
Calculation: finalScore = matrixScore + flowScore + adxBoost + macdBoost + rsiPenalty
Long: flowUp AND volSpike AND NOT compression AND finalScore > T AND the last signal was not Long (fires only on a change of signal state)
Short: flowDown AND volSpike AND NOT compression AND finalScore < -T AND the last signal was not Short (fires only on a change of signal state)