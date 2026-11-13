Calculation: SmoothHA = Heikin Ashi bars of the chart bars: haC=(open+high+low+close)/4; haO=(open+close)/2 on the first bar, else (previous haO + previous haC)/2; haH=max(high,haO,haC); haL=min(low,haO,haC)
Calculation: span = max(haH-haL, |haH-previous haC|, |haL-previous haC|) (haH-haL on the first bar)
Calculation: meanSpan = SMA(span, short lookback)
Calculation: ER = |haC - haC[q]| / sum over the last q bars of |haC change| (0 if the denominator is 0), q bars lookback
Calculation: flowBias = clamp(EMA(rawFlow,n)/EMA(volume,n), -1, 1) (0 if the denominator is 0), where rawFlow = (haC-haO)/(haH-haL)*volume (0 if haH=haL)
Calculation: liveSpread = baseSpread*(1 + kickW*|(haC-previous haC)/meanSpan|) (kick term 0 if meanSpan=0)
Calculation: spreadUp = liveSpread*max(0.2, 1 - flowW*flowBias); spreadDn = liveSpread*max(0.2, 1 + flowW*flowBias)
Calculation: topRef = haC + meanSpan*spreadUp; botRef = haC - meanSpan*spreadDn
Calculation: damp = max(0.01, D*(1 - biasW*(2*ER-1))) with D>0 a constant (smaller D = rail chases price harder); slowDamp = a*damp, fastDamp = (1-a)*damp, with a>0.5
Calculation: ShadowRail = state machine, side in {up, down}. Start: on the first bar with valid topRef/botRef, side=up, lo=botRef, peak=botRef. While side=up on each bar: oldPeak=peak; peak=max(peak,botRef); if peak>oldPeak then lo += peak-oldPeak; else if botRef<previous botRef then lo -= (previous botRef-botRef)/slowDamp; else if botRef>previous botRef then lo += (botRef-previous botRef)/fastDamp. Then if haC<lo: side=down, hi=topRef, trough=topRef. While side=down on each bar: oldTrough=trough; trough=min(trough,topRef); if trough<oldTrough then hi -= oldTrough-trough; else if topRef>previous topRef then hi += (topRef-previous topRef)/slowDamp; else if topRef<previous topRef then hi -= (previous topRef-topRef)/fastDamp. Then if haC>hi: side=up, lo=botRef, peak=botRef
Calculation: RailFlipUp = ShadowRail side is up on this bar and was down on the previous bar; RailFlipDown = side is down on this bar and was up on the previous bar
Calculation: HTFbull = on a higher timeframe than the chart (else the chart timeframe), the last completed bar's close > EMA(close, length) of that bar
Calculation: ATR = Wilder ATR of the chart bars
Long: RailFlipUp AND ER >= minQuality AND (if HTF filter is enabled: HTFbull)
Short: RailFlipDown AND ER >= minQuality AND (if HTF filter is enabled: NOT HTFbull)
Exit: long, low <= entry price - stopMult*ATR (ATR at entry bar) OR high >= entry price + targetMult*ATR (stopMult < targetMult) OR RailFlipDown
Exit: short, high >= entry price + stopMult*ATR (ATR at entry bar) OR low <= entry price - targetMult*ATR (stopMult < targetMult) OR RailFlipUp