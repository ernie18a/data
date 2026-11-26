Calculation: choppiness release = Choppiness Index(high, low, close, choppiness lookback) < choppiness release threshold AND (Choppiness Index(high, low, close, choppiness lookback)[1] >= choppiness release threshold OR Choppiness Index(high, low, close, choppiness lookback) < Choppiness Index(high, low, close, choppiness lookback)[1])
Calculation: bullish Keltner trigger = crosses above EMA(close, Keltner lookback) OR close > EMA(close, Keltner lookback) + ATR(high, low, close, Keltner lookback) × Keltner multiplier
Calculation: bearish Keltner trigger = crosses below EMA(close, Keltner lookback) OR close < EMA(close, Keltner lookback) − ATR(high, low, close, Keltner lookback) × Keltner multiplier
Calculation: bullish OBV pressure = OBV(close, volume) > SMA(OBV(close, volume), OBV smoothing lookback) AND OBV(close, volume) > OBV(close, volume)[1]
Calculation: bearish OBV pressure = OBV(close, volume) < SMA(OBV(close, volume), OBV smoothing lookback) AND OBV(close, volume) < OBV(close, volume)[1]
Calculation: bullish score = count of true conditions among choppiness release, bullish Keltner trigger, bullish OBV pressure, and close > open AND abs(close − open) > ATR(high, low, close, thrust lookback) × thrust multiplier
Calculation: bearish score = count of true conditions among choppiness release, bearish Keltner trigger, bearish OBV pressure, and close < open AND abs(close − open) > ATR(high, low, close, thrust lookback) × thrust multiplier
Long: bullish OBV pressure
Short: bearish OBV pressure
Long: bullish Keltner trigger
Short: bearish Keltner trigger
Long: bullish score > bearish score
Short: bearish score > bullish score
Long: bullish score = signal score threshold − 1 AND bullish Keltner trigger
Short: bearish score = signal score threshold − 1 AND bearish Keltner trigger
Long: bullish score >= signal score threshold AND bullish Keltner trigger AND current chart bar index − most recent earlier bar index satisfying bullish score >= signal score threshold AND bullish Keltner trigger (or zero if none) > signal cooldown
Short: bearish score >= signal score threshold AND bearish Keltner trigger AND current chart bar index − most recent earlier bar index satisfying bearish score >= signal score threshold AND bearish Keltner trigger (or zero if none) > signal cooldown