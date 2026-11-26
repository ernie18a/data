Calculation: atrValue = ATR(atrLength)
Calculation: upTrend(T) = close > EMA(close, trendLength) on T bars, evaluated at the last completed bar
Calculation: downTrend(T) = close <= EMA(close, trendLength) on T bars, evaluated at the last completed bar
Calculation: longTrend = close > EMA(close, trendLength) AND upTrend(T1)
Calculation: shortTrend = close < EMA(close, trendLength) AND downTrend(T1)
Calculation: longTrendStrong = longTrend AND (upTrend(T2) OR upTrend(T3))
Calculation: shortTrendStrong = shortTrend AND (downTrend(T2) OR downTrend(T3))
Calculation: prevDayHigh = high[1] on T4 bars, evaluated at the last completed bar
Calculation: prevDayLow = low[1] on T4 bars, evaluated at the last completed bar
Calculation: asianHigh = highest high of chart bars inside asiaWindow since the current T4 bar began, including the current bar; undefined if none
Calculation: asianLow = lowest low of chart bars inside asiaWindow since the current T4 bar began, including the current bar; undefined if none
Calculation: longSweep = (low < prevDayLow AND close > prevDayLow) OR (asianLow defined AND low < asianLow AND close > asianLow) OR (low < Lowest(low[1], eqLookback) AND close > Lowest(low[1], eqLookback))
Calculation: shortSweep = (high > prevDayHigh AND close < prevDayHigh) OR (asianHigh defined AND high > asianHigh AND close < asianHigh) OR (high > Highest(high[1], eqLookback) AND close < Highest(high[1], eqLookback))
Calculation: recentLongSweep = BarsSince(longSweep) <= sweepRecency
Calculation: recentShortSweep = BarsSince(shortSweep) <= sweepRecency
Calculation: dispUp = close > open AND close - open > atrValue * dispMult
Calculation: dispDown = close < open AND open - close > atrValue * dispMult
Calculation: mssUp = close > Highest(high[1], structLookback)
Calculation: mssDown = close < Lowest(low[1], structLookback)
Calculation: fvgUp = low > high[2]
Calculation: fvgDown = high < low[2]
Calculation: obUp = close[1] < open[1] AND close > high[1]
Calculation: obDown = close[1] > open[1] AND close < low[1]
Calculation: zoneUpTop = (obUp ? high[1] : low), taken at the most recent bar where fvgUp OR obUp
Calculation: zoneUpBottom = (obUp ? low[1] : high[2]), taken at the most recent bar where fvgUp OR obUp
Calculation: zoneDownTop = (obDown ? high[1] : low[2]), taken at the most recent bar where fvgDown OR obDown
Calculation: zoneDownBottom = (obDown ? low[1] : high), taken at the most recent bar where fvgDown OR obDown
Calculation: retestUp = close >= zoneUpBottom AND close <= zoneUpTop
Calculation: shallowUp = low <= zoneUpTop AND close > zoneUpBottom
Calculation: retestDown = close >= zoneDownBottom AND close <= zoneDownTop
Calculation: shallowDown = high >= zoneDownBottom AND close < zoneDownTop
Calculation: extendedUp = close > (zoneUpTop + zoneUpBottom) / 2 + atrValue * farMult
Calculation: extendedDown = close < (zoneDownTop + zoneDownBottom) / 2 - atrValue * farMult
Calculation: longSetup = recentLongSweep AND NOT extendedUp AND mssUp AND ((dispUp AND (retestUp OR shallowUp OR fvgUp OR obUp)) OR (fvgUp AND obUp AND (retestUp OR shallowUp)))
Calculation: shortSetup = recentShortSweep AND NOT extendedDown AND mssDown AND ((dispDown AND (retestDown OR shallowDown OR fvgDown OR obDown)) OR (fvgDown AND obDown AND (retestDown OR shallowDown)))
Calculation: inSessionWindow = bar time inside sessionWindow
Calculation: rangeMid = (Highest(high, midLookback) + Lowest(low, midLookback)) / 2
Calculation: volumeSpike = volume > SMA(volume, volLength) * volMult
Calculation: footprintBear = footprintMode is forced bearish OR (footprintMode is auto AND volumeSpike AND close < open)
Calculation: footprintBull = footprintMode is forced bullish OR (footprintMode is auto AND volumeSpike AND close > open)
Calculation: longScore = (longTrendStrong ? wTrendStrong : longTrend ? wTrend : 0) + (recentLongSweep ? wSweep : 0) + (mssUp ? wStructure : 0) + ((fvgUp OR obUp) ? wPOI : 0) + ((retestUp OR shallowUp) ? wRetest : 0) + (inSessionWindow ? wSession : 0) + ((close <= rangeMid) ? wRange : 0) + (footprintBear ? 0 : wFootprint) + (SMT input does not oppose long ? wSMT : 0)
Calculation: shortScore = (shortTrendStrong ? wTrendStrong : shortTrend ? wTrend : 0) + (recentShortSweep ? wSweep : 0) + (mssDown ? wStructure : 0) + ((fvgDown OR obDown) ? wPOI : 0) + ((retestDown OR shallowDown) ? wRetest : 0) + (inSessionWindow ? wSession : 0) + ((close > rangeMid) ? wRange : 0) + (footprintBull ? 0 : wFootprint) + (SMT input does not oppose short ? wSMT : 0)
Calculation: newTradingDay = a new T4 bar starts on this chart bar
Calculation: canEnter = position side is flat AND (no prior entry OR bars since last entry > entryCooldown) AND entries on current day < maxEntriesPerDay AND newsFilter is not active
Calculation: longStop = min(Lowest(low[1], stopLookback), low) - atrValue * stopAtrMult, fixed on the entry bar
Calculation: shortStop = max(Highest(high[1], stopLookback), high) + atrValue * stopAtrMult, fixed on the entry bar
Long: canEnter AND longSetup AND longScore >= scoreThreshold AND longScore >= shortScore
Short: canEnter AND shortSetup AND shortScore >= scoreThreshold AND shortScore > longScore
Long: longSweep
Short: shortSweep
Long: fvgUp OR obUp
Short: fvgDown OR obDown
Exit: long, high >= entry price + tp3Multiple * (entry price - longStop)
Exit: long, low <= longStop
Exit: long, bars since entry > expiryBars
Exit: long, newTradingDay
Exit: short, low <= entry price - tp3Multiple * (shortStop - entry price)
Exit: short, high >= shortStop
Exit: short, bars since entry > expiryBars
Exit: short, newTradingDay