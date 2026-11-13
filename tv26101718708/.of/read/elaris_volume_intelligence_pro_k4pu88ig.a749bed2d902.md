Calculation: closePos = (close - low) / max(high - low, tick size), clamped to [0,1]
Calculation: rvol = volume / SMA(volume, N_base)
Calculation: volZ = (volume - SMA(volume, N_base)) / stdev(volume, N_z), where N_z is longer than N_base
Calculation: rangeAtr = max(high - low, tick size) / ATR
Calculation: delta = volume*closePos - volume*(1 - closePos)
Calculation: deltaNorm = clamp(delta / SMA(volume, N_base) * 100, -100, 100)
Calculation: flow = EMA(EMA(deltaNorm, n), n), both EMAs use the same length n
Calculation: cvd = cumulative sum of delta from the first bar
Calculation: smartScore = clamp(wF*flow + wD*deltaNorm + wC*(closePos - 0.5)*100, -100, 100), with all weights positive and wF > wD > wC
Calculation: climax = rvol >= climaxRvol AND volZ >= zExtreme, where climaxRvol > highRvol
Long: climax AND close > open AND closePos >= U (U above 0.5)
Long: rvol >= highRvol AND rangeAtr <= absorbMax AND closePos >= U2 (U2 above 0.5) AND close <= open
Long: low < lowest(low, L) over the L bars before the current bar AND cvd >= lowest(cvd, L) over the L bars before the current bar AND rvol > 1
Long: flow > flowThr AND deltaNorm > 0 AND rvol > 1
Long: smartScore >= scoreThr (scoreThr > 0)
Long: flow >= scoreThr
Long: deltaNorm >= 0
Short: climax AND close < open AND closePos <= 1 - U
Short: rvol >= highRvol AND rangeAtr <= absorbMax AND closePos <= 1 - U2 AND close >= open
Short: high > highest(high, L) over the L bars before the current bar AND cvd <= highest(cvd, L) over the L bars before the current bar AND rvol > 1
Short: flow < -flowThr AND deltaNorm < 0 AND rvol > 1
Short: smartScore <= -scoreThr
Short: flow <= -scoreThr
Short: deltaNorm < 0