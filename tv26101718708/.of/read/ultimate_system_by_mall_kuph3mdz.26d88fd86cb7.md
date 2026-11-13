Calculation: TFScore(tf) = on the fixed timeframe tf, using the bar containing the current chart bar (still forming, values so far), round((sum+8)/16*100) where sum is the total of eight votes, each +1 bullish, -1 bearish, 0 otherwise: (1) close>open / close<open; (2) close position in bar range (close-low)/(high-low) >= upper cutoff / <= lower cutoff; (3) EMA(close,short)>EMA(close,mid)>EMA(close,long) / reverse strict order; (4) RSI > upper level / < lower level; (5) MACD histogram >0 / <0; (6) close>open AND volume > multiple of SMA(volume) / close<open AND volume > the same multiple; (7) Stochastic %K > upper level / < lower level; (8) close > previous close > close two bars back / reverse strict order
Calculation: sA, sB, sC, sD = TFScore on four fixed timeframes ordered shortest to longest (sA shortest, sD longest)
Calculation: Total = 0.10*sA + 0.20*sB + 0.30*sC + 0.40*sD (longer timeframe gets larger weight)
Calculation: DailyRecovery = (daily close - lowest daily low over N daily bars) / max(highest daily high over N daily bars - lowest daily low over N daily bars, 1) > mid level AND daily close > daily EMA(close, fast)
Calculation: BiasPts = count of true among: weekly close>weekly open; weekly close>weekly EMA(close, weekly period); daily close>daily open; daily close>daily EMA fast; daily close>daily EMA mid; daily close>daily EMA slow; daily EMA fast>daily EMA mid; DailyRecovery (weekly and daily values taken from the weekly/daily bar containing the current chart bar, still forming)
Calculation: ShortBan = DailyRecovery AND weekly close>weekly EMA AND BiasPts >= high bias level
Long: sA, sB, sC and sD all >= bull threshold AND NOT (sA, sB, sC and sD all >= bull threshold on the previous chart bar) AND bars since last long signal (of either long line below) >= cooldown
Long: sA, sB and sC all >= bull threshold AND sD < bull threshold AND NOT (sA, sB and sC all >= bull threshold on the previous chart bar) AND bars since last long signal (of either long line) >= cooldown
Short: sA, sB, sC and sD all <= bear threshold AND NOT (sA, sB, sC and sD all <= bear threshold on the previous chart bar) AND bars since last short signal (of either short line below) >= cooldown
Short: sA, sB and sC all <= bear threshold AND sD > bear threshold AND NOT (sA, sB and sC all <= bear threshold on the previous chart bar) AND bars since last short signal (of either short line) >= cooldown
Long: BiasPts >= high bias level AND NOT ShortBan
Short: BiasPts <= low bias level
Long: Total >= bullish total level
Short: Total <= bearish total level
Long: any single sA, sB, sC or sD >= bullish per-timeframe level
Short: any single sA, sB, sC or sD <= bearish per-timeframe level