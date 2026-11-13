Calculation: Src = (high+low+close)/3
Calculation: ATR = Wilder ATR (average true range) on the chart timeframe
Calculation: VWAP = volume-weighted average of Src, reset each session (if undefined, use EMA of Src with the long length)
Calculation: ArcCore = EMA(slowEMA + (fastEMA - slowEMA) * w, short smoothing), where fastEMA = EMA(Src, short length) and slowEMA = EMA(Src, long length). w = clamp(base + a*speedNorm + b*volSpeed, wmin, wmax). speedNorm = clamp(|EMA(change(Src))| / ATR, 0, cap1). volSpeed = clamp((EMA(ATR, shorter length) / EMA(ATR, longer length) - 1) * boost, 0, cap2)
Calculation: LongBand = ArcCore - ATR*bandMult + max(slope,0)*(c + volSpeed). ShortBand = ArcCore + ATR*bandMult + min(slope,0)*(c + volSpeed). slope = EMA(change(ArcCore)). bandMult = clamp(baseMult*(1 - d*volSpeed), lo*baseMult, hi*baseMult)
Calculation: Regime/Trail (state per closed bar) = initial regime is +1 if close >= ArcCore else -1, and initial Trail is LongBand if +1 else ShortBand. If previous regime is +1: if Short is true then regime = -1 and Trail = ShortBand, else Trail = max(LongBand, previous Trail). If previous regime is -1: if Long is true then regime = +1 and Trail = LongBand, else Trail = min(ShortBand, previous Trail)
Long: previous regime = -1 AND close > previous Trail AND close >= VWAP AND ArcCore >= previous ArcCore
Short: previous regime = +1 AND close < previous Trail AND close <= VWAP AND ArcCore <= previous ArcCore
Exit: long, Short is true OR close < low of entry bar - k*ATR of entry bar
Exit: short, Long is true OR close > high of entry bar + k*ATR of entry bar