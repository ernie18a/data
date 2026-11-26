Calculation: bandPosition = (close - (EMA(close, band lookback) - band width * ATR(atr lookback))) / (2 * band width * ATR(atr lookback)), on T1 bars, value at the second-to-last completed T1 bar
Calculation: t1VolumeRatio = volume / SMA(volume, T1 volume lookback), on T1 bars, value at the second-to-last completed T1 bar
Calculation: chartVolumeRatio = volume / SMA(volume, chart volume lookback), on chart bars
Calculation: t1High = Highest(high, window bars), on T1 bars, value at the second-to-last completed T1 bar
Calculation: t1Low = Lowest(low, window bars), on T1 bars, value at the second-to-last completed T1 bar
Calculation: targetAtr = IF(use T1 ATR for target, ATR(atr lookback) on T1 bars at the second-to-last completed T1 bar, ATR(atr lookback) on chart bars)
Calculation: targetMultiple = IF(auto target, MAX(min multiple, MIN(max multiple, base multiple + (chartVolumeRatio - 1) * slope)), fixed multiple)
Calculation: newT1 = a T1 bar starts on this chart bar
Calculation: roll = newT1 AND boxState[1] is forming or armed
Calculation: armedNow = (roll AND (bandPosition >= top threshold OR bandPosition <= bottom threshold) AND t1VolumeRatio >= T1 volume multiple) OR (boxState[1] is armed AND NOT newT1)
Calculation: breakUp = (armedNow OR boxState[1] is consolidating) AND close > boxHigh AND chartVolumeRatio >= breakout volume multiple
Calculation: breakDown = (armedNow OR boxState[1] is consolidating) AND close < boxLow AND chartVolumeRatio >= breakout volume multiple
Calculation: targetHit = IF(position side is long, high >= target[1], low <= target[1])
Calculation: flipUp = boxState[1] is locked AND position side is short AND close > boxHigh[1] AND NOT targetHit
Calculation: flipDown = boxState[1] is locked AND position side is long AND close < boxLow[1] AND NOT targetHit
Calculation: barsSinceLock = IF(boxState[1] is locked AND NOT flipUp AND NOT flipDown, barsSinceLock[1] + 1, 0)
Calculation: boxReset = boxState[1] is locked AND (targetHit OR (barsSinceLock >= timeout AND NOT flipUp AND NOT flipDown AND (close > boxHigh[1] OR close < boxLow[1])))
Calculation: boxHigh = IF(roll OR boxReset, t1High, boxHigh[1])
Calculation: boxLow = IF(roll OR boxReset, t1Low, boxLow[1])
Calculation: boxState = locked IF breakUp OR breakDown; ELSE locked IF boxState[1] is locked AND NOT boxReset AND NOT (barsSinceLock >= timeout AND close >= boxLow[1] AND close <= boxHigh[1]); ELSE consolidating IF boxState[1] is consolidating OR (boxState[1] is locked AND NOT boxReset AND barsSinceLock >= timeout AND close >= boxLow[1] AND close <= boxHigh[1]); ELSE armed IF armedNow; ELSE forming
Calculation: target = IF(breakUp OR flipUp, boxHigh + targetMultiple * targetAtr, IF(breakDown OR flipDown, boxLow - targetMultiple * targetAtr, target[1]))
Short: roll AND bandPosition >= top threshold AND t1VolumeRatio >= T1 volume multiple
Long: roll AND bandPosition <= bottom threshold AND t1VolumeRatio >= T1 volume multiple
Long: breakUp
Short: breakDown
Long: flipUp
Short: flipDown
Exit: Long, high >= target[1]
Exit: Long, barsSinceLock >= timeout AND high < target[1] AND close >= boxLow[1]
Exit: Short, low <= target[1]
Exit: Short, barsSinceLock >= timeout AND low > target[1] AND close <= boxHigh[1]