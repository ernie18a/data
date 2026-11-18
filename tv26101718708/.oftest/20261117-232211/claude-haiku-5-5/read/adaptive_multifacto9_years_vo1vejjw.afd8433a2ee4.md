Calculation: MACD(shorterLength, longerLength) = EMA(close, shorterLength) - EMA(close, longerLength)
Calculation: StochK(stochLength) = (close - LOWEST(low, stochLength)) / (HIGHEST(high, stochLength) - LOWEST(low, stochLength))
Calculation: TypicalPrice = (high + low + close) / 3
Calculation: PosFlow = IF(TypicalPrice > TypicalPrice[1], TypicalPrice * volume, 0)
Calculation: NegFlow = IF(TypicalPrice < TypicalPrice[1], TypicalPrice * volume, 0)
Calculation: MFI(mfiLength) = IF(SUM(NegFlow, mfiLength) == 0, 100, 100 - 100 / (1 + SUM(PosFlow, mfiLength) / SUM(NegFlow, mfiLength)))
Calculation: Position(fishLength) = IF(HIGHEST(close, fishLength) != LOWEST(close, fishLength), (close - LOWEST(close, fishLength)) / (HIGHEST(close, fishLength) - LOWEST(close, fishLength)), fishNeutral)
Calculation: Fisher(fishLength) = LN(V / (1 - V)) where V = MAX(MIN(Position(fishLength), fishHigh), fishLow)
Calculation: Chop = ADX(dmiLength) < adxLimit AND ATR(atrLength) > SMA(ATR(atrLength), atrAverageLength)
Calculation: Composite = IF(MACD(shorterLength, longerLength) > EMA(MACD(shorterLength, longerLength), signalLength), 1, -1) + IF(StochK(stochLength) > SMA(StochK(stochLength), stochSmoothing), 1, -1) + IF(close > close[momLength], 1, -1) + IF(RSI(close, rsiLength) > rsiMid, 1, -1) + IF(SUM(ABS(high - low[1]), vortexLength) > SUM(ABS(low - high[1]), vortexLength), 1, -1) + IF(PlusDI(dmiLength) > MinusDI(dmiLength), 1, -1) + IF(MFI(mfiLength) > mfiMid, 1, -1) + IF(Fisher(fishLength) > SMA(Fisher(fishLength), fishSignalLength), 1, -1)
Long: Composite >= longScoreThreshold AND PSAR(psarStart, psarIncrement, psarMax) < close AND RSI(close, rsiLength) < rsiLongLimit AND NOT Chop[n] for all n from 0 to cooldownLength
Short: Composite <= shortScoreThreshold AND PSAR(psarStart, psarIncrement, psarMax) > close AND RSI(close, rsiLength) > rsiShortLimit AND NOT Chop[n] for all n from 0 to cooldownLength
Exit: long, Composite <= longExitThreshold OR PSAR(psarStart, psarIncrement, psarMax) > close
Exit: short, Composite >= shortExitThreshold OR PSAR(psarStart, psarIncrement, psarMax) < close