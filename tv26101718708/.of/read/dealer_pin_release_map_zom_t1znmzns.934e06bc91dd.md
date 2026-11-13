Calculation: ATR = Average True Range on chart bars; atrRatio = ATR / EMA of ATR (EMA length much longer than ATR length)
Calculation: relVol = volume / SMA of volume
Calculation: bodyShare = |close - open| / max(high - low, tick)
Calculation: closeLocation = ((close - low) - (high - close)) / max(high - low, tick); deltaPressure = EMA of (closeLocation * volume / SMA of volume * 100); deltaSlope = deltaPressure - previous bar deltaPressure
Calculation: magnet = round(close / strikeStep) * strikeStep (nearest multiple of a fixed price step); priorMagnet = magnet of the previous bar; magnetRange = ATR * fixed width factor
Calculation: pinScore (0 to 100) = clamped weighted sum of pinProximity (weight largest) + compressionScore + participationScore; pinProximity = clamp(1 - |close - magnet| / magnetRange, 0, 1); compressionScore = clamp(linear decreasing function of atrRatio, 0, 1), higher when atrRatio is below about 1; participationScore = clamp(linear decreasing function of relVol, 0, 1), higher when relVol is low
Calculation: priorPin = highest pinScore over the lookback window ending at the previous bar (excludes current bar)
Calculation: pinEscape = clamp(|close - priorMagnet| / magnetRange, 0, cap)
Calculation: releaseEnergy = clamp(w1*(priorPin - base) + w2*(atrRatio - 1) + w3*(relVol - 1) + w4*|deltaPressure| + w5*pinEscape, 0, 100) with positive weights
Calculation: expansion = atrRatio > expansion ATR threshold (slightly above 1) AND relVol > expansion volume threshold (slightly above 1) AND bodyShare > body threshold
Calculation: cooldownOk = no Long or Short signal of any type (release or fade, either side) fired on the previous cooldown-N bars (true if none has ever fired)
Calculation: thresholds fadeThreshold < releaseThreshold are set by one strictness mode (stricter mode means higher values)
Long: cooldownOk AND priorPin >= fadeThreshold AND close > priorMagnet + magnetRange AND previous close <= priorMagnet + magnetRange AND expansion AND releaseEnergy >= releaseThreshold AND deltaPressure > 0
Short: cooldownOk AND priorPin >= fadeThreshold AND close < priorMagnet - magnetRange AND previous close >= priorMagnet - magnetRange AND expansion AND releaseEnergy >= releaseThreshold AND deltaPressure < 0
Long: cooldownOk AND low <= magnet - f1*magnetRange AND close > magnet - f2*magnetRange (0 < f2 < f1 < 1) AND lowerWick > k * upperWick (k > 1; lowerWick = min(open, close) - low; upperWick = high - max(open, close)) AND deltaSlope > 0 AND highest pinScore over the last few bars including the current bar >= fadeThreshold
Short: cooldownOk AND high >= magnet + f1*magnetRange AND close < magnet + f2*magnetRange (same f1, f2, k) AND upperWick > k * lowerWick AND deltaSlope < 0 AND highest pinScore over the last few bars including the current bar >= fadeThreshold