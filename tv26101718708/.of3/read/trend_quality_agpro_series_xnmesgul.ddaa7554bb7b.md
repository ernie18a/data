Calculation: AdxNorm = min(ADX(ADX length) / ADX scale, 1)
Calculation: SlopeNorm = min(abs(EMA(close, slope length) - EMA(close, slope length)[1]) / ATR(ATR length) * slope scale, 1)
Calculation: Quality = ADX weight * AdxNorm + efficiency weight * KaufmanER(close, efficiency length) + slope weight * SlopeNorm
Calculation: DirSpread = DI+(ADX length) - DI-(ADX length)
Calculation: HtfBlock = Quality >= trend threshold + hysteresis AND Quality(T1, last completed bar) < trend threshold
Calculation: Trend = 1 if Trend[1] = 0 AND Quality >= trend threshold + hysteresis on each of the last confirm bars AND Quality(T1, last completed bar) >= trend threshold; 0 if Trend[1] = 1 AND Quality <= trend threshold - hysteresis on each of the last confirm bars; otherwise Trend[1]
Calculation: Stage = Chop if Trend = 0; Emerging if Trend[k] = 0 for some k from 1 to emerging bars; Exhausting if Quality - Quality[velocity lookback] <= exhaustion velocity; Confirmed if Quality >= trend threshold + strong offset; otherwise Trending
Long: Trend[1] = 0 AND Trend = 1 AND DirSpread >= 0
Long: Stage = Confirmed AND Stage[1] != Confirmed AND DirSpread >= 0
Long: (Stage = Trending OR Stage = Confirmed) AND DirSpread >= 0 AND HtfBlock = false
Short: Trend[1] = 0 AND Trend = 1 AND DirSpread < 0
Short: Stage = Confirmed AND Stage[1] != Confirmed AND DirSpread < 0
Short: (Stage = Trending OR Stage = Confirmed) AND DirSpread < 0 AND HtfBlock = false
Exit: long, Stage = Exhausting AND Stage[1] != Exhausting AND DirSpread >= 0
Exit: long, Trend[1] = 1 AND Trend = 0 AND DirSpread >= 0
Exit: short, Stage = Exhausting AND Stage[1] != Exhausting AND DirSpread < 0
Exit: short, Trend[1] = 1 AND Trend = 0 AND DirSpread < 0