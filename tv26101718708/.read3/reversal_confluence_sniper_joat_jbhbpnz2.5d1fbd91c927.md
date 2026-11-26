Calculation: zScore = (close - EMA(close, zLookback)) / STDEV(close, zLookback)
Calculation: bollingerLower = BollingerBandLower(close, bandLookback, bbMultiplier)
Calculation: bollingerUpper = BollingerBandUpper(close, bandLookback, bbMultiplier)
Calculation: keltnerLower = SMA(close, bandLookback) - kcMultiplier * SMA(TR, bandLookback)
Calculation: keltnerUpper = SMA(close, bandLookback) + kcMultiplier * SMA(TR, bandLookback)
Calculation: volumeRatio = volume / SMA(volume, volumeLookback)
Calculation: volatilitySpike = min(1, (high - low) / (ATR(atrLength) * spikeMultiple))
Calculation: upStreak = if close > close[1] then upStreak[1] + 1 else 0
Calculation: downStreak = if close < close[1] then downStreak[1] + 1 else 0
Calculation: upExhaustion = round(100 * (runWeight * min(1, upStreak / runLength) + zWeight * min(1, max(0, zScore) / zThreshold) + rsiWeight * min(1, max(0, RSI(close, rsiLength) - overboughtLevel) / (100 - overboughtLevel)) + spikeWeight * volatilitySpike))
Calculation: downExhaustion = round(100 * (runWeight * min(1, downStreak / runLength) + zWeight * min(1, max(0, -zScore) / zThreshold) + rsiWeight * min(1, max(0, oversoldLevel - RSI(close, rsiLength)) / oversoldLevel) + spikeWeight * volatilitySpike))
Calculation: bullConfluenceCount = (low <= bollingerLower OR low <= keltnerLower) + (RSI(close, rsiLength) <= oversoldLevel) + (close < close[1] AND RSI(close, rsiLength) > RSI(close, rsiLength)[1] AND RSI(close, rsiLength) < rsiMidline) + (volumeRatio >= volumeClimaxThreshold) + (zScore <= -zThreshold)
Calculation: bearConfluenceCount = (high >= bollingerUpper OR high >= keltnerUpper) + (RSI(close, rsiLength) >= overboughtLevel) + (close > close[1] AND RSI(close, rsiLength) < RSI(close, rsiLength)[1] AND RSI(close, rsiLength) > rsiMidline) + (volumeRatio >= volumeClimaxThreshold) + (zScore >= zThreshold)
Long: ((close > open AND close[1] < open[1] AND close >= open[1] AND open <= close[1]) OR ((low < bollingerLower OR low < keltnerLower) AND close > bollingerLower AND (min(close, open) - low) / (high - low) >= wickFraction AND close > open)) AND downExhaustion >= minExhaustion AND downExhaustion > upExhaustion AND bullConfluenceCount >= minConfluences AND (no prior long or short signal OR bars since last long or short signal >= cooldownBars)
Long: downExhaustion >= minExhaustion AND downExhaustion > upExhaustion
Long: downExhaustion >= minExhaustion AND downExhaustion[1] < minExhaustion
Short: ((close < open AND close[1] > open[1] AND close <= open[1] AND open >= close[1]) OR ((high > bollingerUpper OR high > keltnerUpper) AND close < bollingerUpper AND (high - max(close, open)) / (high - low) >= wickFraction AND close < open)) AND upExhaustion >= minExhaustion AND upExhaustion >= downExhaustion AND bearConfluenceCount >= minConfluences AND (no prior long or short signal OR bars since last long or short signal >= cooldownBars)
Short: upExhaustion >= minExhaustion AND upExhaustion >= downExhaustion
Short: upExhaustion >= minExhaustion AND upExhaustion[1] < minExhaustion