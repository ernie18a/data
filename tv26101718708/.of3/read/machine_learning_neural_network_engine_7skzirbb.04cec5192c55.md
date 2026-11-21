Calculation: Run(c) = number of consecutive bars ending at the current bar on which c is true
Calculation: FeaturesDefined = all six features below are defined on the current bar
Calculation: LevelFeature = clamp((EMA(close, shortFeatureLength) - EMA(close, longFeatureLength)) / ATR(atrLength) / levelScale, -1, 1)
Calculation: SlopeFeature = clamp((RSI(close, rsiLength) - 50) / 50, -1, 1)
Calculation: CurveFeature = clamp((close - LinReg(close, regLength)) / ATR(atrLength) / curveScale, -1, 1)
Calculation: TrendFeature = clamp((close - close[trendLength]) / SUM(ABS(close - close[1]), trendLength), -1, 1)
Calculation: VolatilityFeature = clamp(ATR(atrLength) / SMA(ATR(atrLength), normLength) - 1, -1, 1)
Calculation: PressureFeature = clamp((close - open) / (high - low) * clamp(volume / SMA(volume, volumeLength), 0, relVolCap) / pressureScale, -1, 1)
Calculation: TrainingEnabled = FeaturesDefined AND bar index > normLength + horizon + resolveMargin
Calculation: Target = clamp((close - close[horizon]) / MAX(ATR(atrLength)[horizon], targetFloor), -1, 1)
Calculation: Predict(x) = tanh(c + SUM over j of v_j * tanh(b_j + SUM over i of W_ji * x_i)), where x = (LevelFeature, SlopeFeature, CurveFeature, TrendFeature, VolatilityFeature, PressureFeature) of the bar, j runs over hiddenUnits, i runs over the six features, and W, b, v, c are the current network weights and biases (c is the output bias)
Calculation: Train(x, y) = with out = Predict(x), h_j = tanh(b_j + SUM over i of W_ji * x_i), e = clamp(y - out, -clipError, clipError), g_o = e * (1 - out^2) and g_j = g_o * v_j * (1 - h_j^2), all from pre-update values; each weight or bias p is updated by M_p = gradientDecay * M_p + (1 - gradientDecay) * g^2 and then p = p + learnRate * g / sqrt(M_p + smallConstant) - learnRate * q * p (p on the right is pre-update), where for v_j: g = g_o * h_j and q = l2Penalty; for c: g = g_o and q = 0; for W_ji: g = g_j * x_i and q = l2Penalty; for b_j: g = g_j and q = 0
Calculation: NetOutput = 0 if not FeaturesDefined, else Predict(x) after Train(x[horizon], Target) if TrainingEnabled; initially W_ji = initInputScale * sin(initInputFreq * (6j + i + 1)), v_j = initOutputScale * sin(initOutputFreq * (j + 1)), and b, c and all M_p = 0 (j and i zero-based)
Calculation: LinearScore = clamp(wLevel * LevelFeature + wSlope * SlopeFeature + wCurve * CurveFeature + wTrend * TrendFeature - wVolatility * VolatilityFeature, -1, 1)
Calculation: NetError = EMA of ABS(Target - NetOutput[horizon]) with smoothing factor errAlpha, seeded by its first value and updated only on bars where TrainingEnabled
Calculation: LinearError = EMA of ABS(Target - LinearScore[horizon]) with smoothing factor errAlpha, seeded by its first value and updated only on bars where TrainingEnabled
Calculation: ResolvedCount = number of bars up to the current bar on which TrainingEnabled is true
Calculation: BlendWeight = warmInfluence * ResolvedCount / warmupCount if ResolvedCount < warmupCount; otherwise clamp(skillOffset + 1 - NetError / LinearError, minInfluence, maxInfluence) if LinearError > smallConstant AND NetError < LinearError; otherwise fallbackInfluence
Calculation: UpProbability = 1 / (1 + exp(-probScale * clamp(BlendWeight * NetOutput + (1 - BlendWeight) * LinearScore, -1, 1)))
Calculation: AtrRatio = ATR(atrLength) / SMA(ATR(atrLength), volBaseLength)
Calculation: CrisisFlag = (close / close[crashLength] - 1 <= -MAX(dropFloor, dropMultiple * ATR(atrLength) / close) AND AtrRatio >= volRatioCrashMin) OR (close / HIGHEST(close, drawdownLength) - 1 <= -drawdownThreshold AND close < EMA(close, midLength) AND AtrRatio >= volRatioDrawdownMin)
Long: FeaturesDefined AND Run(UpProbability >= upperThreshold AND close > EMA(close, shortLength) AND (close > close[entryLookback] OR close > EMA(close, midLength)) AND NOT CrisisFlag) >= entryRunLength
Exit: long, FeaturesDefined AND (CrisisFlag OR (Run(UpProbability <= lowerThreshold AND close < EMA(close, midLength) AND close < EMA(close, longLength)) >= exitRunLength))