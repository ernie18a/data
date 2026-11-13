Calculation: trendUp = EMA(close, fast) > EMA(close, slow) AND close > EMA(close, macro); trendDown = EMA(close, fast) < EMA(close, slow) AND close < EMA(close, macro) (fast < slow < macro lengths)
Calculation: htfBull = on a higher timeframe than the chart, using the still-forming HTF bar (aggregated up to the current chart bar), EMA(close, fast) > EMA(close, slow) with the same lengths as on the chart; htfBear = the same with <
Calculation: z = (close - SMA(close, N)) / stdev(close, N), 0 if stdev is 0
Calculation: volRatio = volume / SMA(volume, M)
Calculation: bullDiv / bearDiv = state updated only when a confirmed pivot appears (pivot low = low is the lowest, pivot high = high is the highest, over L bars before and R bars after, L = R, confirmed R bars late). bullDiv = latest pivot low < previous pivot low AND RSI at latest pivot low bar > RSI at previous pivot low bar. bearDiv = latest pivot high > previous pivot high AND RSI at latest pivot high bar < RSI at previous pivot high bar. The state persists until the next pivot of that kind.
Calculation: contScore and revScore start at 0 on each bar; add positive weights w1..w17 (any values) as follows. ADX = Wilder ADX; hist = MACD histogram; thresholds aHi > aMid, rsiMid between rsiOS and rsiOB, v2 > v1, z2 > z1.
 (1) cont += w1 if ADX > aHi, else cont += w2 if ADX > aMid
 (2) rev += w3 if ADX < aMid
 (3) rev += w4 if ADX < ADX 3 bars ago AND ADX > aHi
 (4) cont += w5 if (trendUp AND close > EMA fast) OR (trendDown AND close < EMA fast)
 (5) rev += w6 if (trendUp AND close < EMA fast) OR (trendDown AND close > EMA fast)
 (6) cont += w7 if (trendUp AND hist > hist[1] AND hist > 0) OR (trendDown AND hist < hist[1] AND hist < 0)
 (7) rev += w8 if (trendUp AND hist < hist[1] AND hist[1] < hist[2]) OR (trendDown AND hist > hist[1] AND hist[1] > hist[2])
 (8) rev += w9 if (trendUp AND RSI > rsiOB) OR (trendDown AND RSI < rsiOS)
 (9) cont += w10 if (trendUp AND rsiMid < RSI < rsiOB) OR (trendDown AND rsiOS < RSI < rsiMid)
 (10) cont += w11 if volRatio > v1
 (11) rev += w12 if volRatio > v2 AND ((trendUp AND close < open) OR (trendDown AND close > open))
 (12) rev += w13 if |z| > z2, else rev += w14 if |z| > z1
 (13) cont += w15 if (trendUp AND htfBull) OR (trendDown AND htfBear)
 (14) rev += w16 if (trendUp AND htfBear) OR (trendDown AND htfBull)
 (15) rev += w17 if (trendUp AND bearDiv) OR (trendDown AND bullDiv)
Calculation: contPct = 100 * contScore / (contScore + revScore), 50 if the sum is 0; revPct = 100 - contPct
Long: EMA(close, fast) crosses above EMA(close, slow) on this bar AND close > EMA(close, macro) AND contPct >= T AND htfBull
Short: EMA(close, fast) crosses below EMA(close, slow) on this bar AND close < EMA(close, macro) AND contPct >= T AND htfBear
Exit: long, trendUp AND revPct >= T AND (bearDiv OR RSI > rsiExtremeHigh OR |z| > z2) (rsiExtremeHigh > rsiOB)
Exit: short, trendDown AND revPct >= T AND (bullDiv OR RSI < rsiExtremeLow OR |z| > z2) (rsiExtremeLow < rsiOS)
Exit: long, close <= entry price - kSL * ATR at entry bar OR close >= entry price + kTP * ATR at entry bar (kTP > kSL; ATR = Wilder average true range)
Exit: short, close >= entry price + kSL * ATR at entry bar OR close <= entry price - kTP * ATR at entry bar