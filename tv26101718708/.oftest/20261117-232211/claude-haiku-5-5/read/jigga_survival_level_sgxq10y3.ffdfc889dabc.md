Calculation: trueRange = max(high - low, abs(high - close[1]), abs(low - close[1]))
Calculation: plusDM = high - high[1] if high - high[1] > low[1] - low and high - high[1] > 0, else 0
Calculation: minusDM = low[1] - low if low[1] - low > high - high[1] and low[1] - low > 0, else 0
Calculation: plusDI = 100 * RMA(plusDM, diLen) / RMA(trueRange, diLen)
Calculation: minusDI = 100 * RMA(minusDM, diLen) / RMA(trueRange, diLen)
Calculation: adx = 100 * RMA(abs(plusDI - minusDI) / (plusDI + minusDI if plusDI + minusDI != 0 else 1), adxLen)
Calculation: osc = EMA(close, fastLen) - EMA(close, slowLen)
Calculation: oscSignal = EMA(osc, signalLen)
Calculation: oscHist = osc - oscSignal
Calculation: oscPoints = osc > 0 ? (osc > oscSignal ? 1 : 0) : (osc > oscSignal ? 0 : -1)
Calculation: histPoints = oscHist >= 0 ? (oscHist > oscHist[1] ? 1 : 0) : (oscHist > oscHist[1] ? 0 : -1)
Calculation: rsiSmooth = EMA(RSI(close, rsiLen), rsiSmoothLen)
Calculation: rsiPoints = rsiSmooth > upperThr ? 1 : (rsiSmooth < lowerThr ? -1 : 0)
Calculation: maPoints = EMA(close, shortLen) > EMA(close, longLen) ? 1 : -1
Calculation: adxPoints = adx > EMA(adx, adxEmaLen) ? (close > EMA(close, trialCloseEmaLen) ? 1 : -1) : 0
Calculation: williamsR = 100 * (close - highest(high, wrLen)) / (highest(high, wrLen) - lowest(low, wrLen))
Calculation: williamsRSmooth = EMA(williamsR, wrSmoothLen)
Calculation: williamsPoints = williamsRSmooth > -lowerThr ? 1 : (williamsRSmooth < -upperThr ? -1 : 0)
Calculation: moneyFlowVolume = 0 if high = low, else (2 * close - low - high) / (high - low) * volume
Calculation: moneyFlowRatio = SUM(moneyFlowVolume, mfLen) / SUM(volume, mfLen)
Calculation: moneyFlowPoints = moneyFlowRatio > mfThr ? 1 : (moneyFlowRatio < -mfThr ? -1 : 0)
Calculation: atr = ATR(atrLen)
Calculation: lowerBand = close[1] > lowerBand[1] ? max((high + low) / 2 - stMult * atr, lowerBand[1]) : (high + low) / 2 - stMult * atr
Calculation: upperBand = close[1] < upperBand[1] ? min((high + low) / 2 + stMult * atr, upperBand[1]) : (high + low) / 2 + stMult * atr
Calculation: superDirection = superDirection[1] == -1 and close > upperBand[1] ? 1 : (superDirection[1] == 1 and close < lowerBand[1] ? -1 : superDirection[1]), first value 1
Calculation: score = oscPoints + histPoints + rsiPoints + maPoints + adxPoints + williamsPoints + moneyFlowPoints + superDirection
Calculation: filteredScore = 0 if (score >= 0 and score[1] <= 0) or (score <= 0 and score[1] >= 0), else score
Calculation: upState = true if filteredScore[1] < 0 and filteredScore >= 0; false if filteredScore[1] > 0 and filteredScore <= 0; otherwise upState[1]; first value true
Calculation: level = 0 if level[1] != 0, else high * levelUpFactor if filteredScore[1] < 0 and filteredScore >= 0, else low * levelDownFactor if filteredScore[1] > 0 and filteredScore <= 0, else 0
Long: (high > level AND upState) OR (filteredScore[1] > 0 AND filteredScore > 0)
Exit: long, (low < level AND NOT upState) OR (filteredScore[1] < 0 AND filteredScore < 0)