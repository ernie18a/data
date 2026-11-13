Calculation: ScanBars = chart-symbol bars aggregated to a scan timeframe (same as or higher than the chart timeframe), using the bar still forming; every calculation below uses ScanBars
Calculation: EMAshort, EMAmid, EMAlong = EMA of close with lookbacks short < mid < long; RSI = RSI of close (standard)
Calculation: volRatio = volume / SMA(volume, n), 0 if the SMA is 0; activeVol = volRatio >= activeThr; extremeVol = volRatio >= extremeThr, with extremeThr > activeThr
Calculation: bullTrend = EMAshort > EMAmid AND EMAmid > EMAlong; bearTrend = EMAshort < EMAmid AND EMAmid < EMAlong
Calculation: bullBreak = close > highest high of the previous N bars (excluding the current bar) AND activeVol; bearBreak = close < lowest low of the previous N bars (excluding the current bar) AND activeVol
Calculation: score = (bullTrend ? +2 : bearTrend ? -2 : 0) + (close > EMAlong ? +1 : -1) + (RSI > rsiHi ? +1 : RSI < rsiLo ? -1 : 0, with rsiHi > rsiLo) + (bullBreak ? +2 : bearBreak ? -2 : 0) + (activeVol ? +1 : 0) + (extremeVol AND bullTrend ? +1 : extremeVol AND bearTrend ? -1 : 0)
Long: bullBreak OR (score > 0 AND NOT bearBreak)
Long: score >= strongThr AND RSI > rsiHi
Long: bullBreak AND score >= strongThr AND RSI > rsiHi (strongest tier)
Short: bearBreak OR (score < 0 AND NOT bullBreak)
Short: score <= -strongThr AND RSI < rsiLo
Short: bearBreak AND score <= -strongThr AND RSI < rsiLo (strongest tier)