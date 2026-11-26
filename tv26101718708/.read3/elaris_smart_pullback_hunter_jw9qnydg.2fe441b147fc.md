Calculation: Fast EMA slope % = if EMA(close, short-term lookback)[slope lookback] is nonzero, (EMA(close, short-term lookback) - EMA(close, short-term lookback)[slope lookback]) / EMA(close, short-term lookback)[slope lookback] * 100; otherwise 0
Calculation: Bullish EMA stack = EMA(close, short-term lookback) > EMA(close, medium-term lookback) AND EMA(close, medium-term lookback) > EMA(close, long-term lookback)
Calculation: Bearish EMA stack = EMA(close, short-term lookback) < EMA(close, medium-term lookback) AND EMA(close, medium-term lookback) < EMA(close, long-term lookback)
Calculation: Bullish structure = structure filter disabled OR low > lowest(low, pullback lookback)[1]
Calculation: Bearish structure = structure filter disabled OR high < highest(high, pullback lookback)[1]
Calculation: Bullish trend = bullish EMA stack AND fast EMA slope % >= minimum slope AND bullish structure
Calculation: Bearish trend = bearish EMA stack AND fast EMA slope % <= -minimum slope AND bearish structure
Calculation: Bullish T1 EMA stack = EMA(close, short-term lookback, T1, still-forming bar) > EMA(close, medium-term lookback, T1, still-forming bar) AND EMA(close, medium-term lookback, T1, still-forming bar) > EMA(close, long-term lookback, T1, still-forming bar); values are sampled on chart bars
Calculation: Bearish T1 EMA stack = EMA(close, short-term lookback, T1, still-forming bar) < EMA(close, medium-term lookback, T1, still-forming bar) AND EMA(close, medium-term lookback, T1, still-forming bar) < EMA(close, long-term lookback, T1, still-forming bar); values are sampled on chart bars
Calculation: Long T1 filter pass = T1 filter disabled OR bullish T1 EMA stack
Calculation: Short T1 filter pass = T1 filter disabled OR bearish T1 EMA stack
Calculation: Volume confirmation = volume filter disabled OR volume > SMA(volume, volume lookback) * volume multiplier
Calculation: Body % = if high > low, abs(close - open) / (high - low) * 100; otherwise 0
Calculation: Lower wick % = if high > low, (min(open, close) - low) / (high - low) * 100; otherwise 0
Calculation: Upper wick % = if high > low, (high - max(open, close)) / (high - low) * 100; otherwise 0
Calculation: Long fast EMA touch = low <= EMA(close, short-term lookback) AND close > EMA(close, short-term lookback)
Calculation: Long medium EMA touch = low <= EMA(close, medium-term lookback) AND close > EMA(close, medium-term lookback)
Calculation: Short fast EMA touch = high >= EMA(close, short-term lookback) AND close < EMA(close, short-term lookback)
Calculation: Short medium EMA touch = high >= EMA(close, medium-term lookback) AND close < EMA(close, medium-term lookback)
Calculation: Long deep pullback = abs(low - EMA(close, medium-term lookback)) / EMA(close, medium-term lookback) * 100 <= deep-pullback distance percentage AND low < EMA(close, medium-term lookback) AND close > EMA(close, medium-term lookback)
Calculation: Short deep pullback = abs(high - EMA(close, medium-term lookback)) / EMA(close, medium-term lookback) * 100 <= deep-pullback distance percentage AND high > EMA(close, medium-term lookback) AND close < EMA(close, medium-term lookback)
Calculation: Long pullback trigger = bullish trend AND ((fast EMA pullback enabled AND long fast EMA touch) OR (medium EMA pullback enabled AND long medium EMA touch) OR long deep pullback)
Calculation: Short pullback trigger = bearish trend AND ((fast EMA pullback enabled AND short fast EMA touch) OR (medium EMA pullback enabled AND short medium EMA touch) OR short deep pullback)
Calculation: Bullish signal score = min(score cap, (bullish EMA stack ? EMA-stack points : 0) + (fast EMA slope % >= minimum slope ? slope points : 0) + (bullish structure ? structure points : 0) + (long medium EMA touch ? medium EMA touch points : long fast EMA touch ? fast EMA touch points : long deep pullback ? deep-pullback points : 0) + (volume confirmation ? volume points : 0) + (close > open AND body % >= minimum body percentage ? momentum points : 0) + (long T1 filter pass ? T1 points : 0))
Calculation: Bearish signal score = min(score cap, (bearish EMA stack ? EMA-stack points : 0) + (fast EMA slope % <= -minimum slope ? slope points : 0) + (bearish structure ? structure points : 0) + (short medium EMA touch ? medium EMA touch points : short fast EMA touch ? fast EMA touch points : short deep pullback ? deep-pullback points : 0) + (volume confirmation ? volume points : 0) + (close < open AND body % >= minimum body percentage ? momentum points : 0) + (short T1 filter pass ? T1 points : 0))
Long: bullish trend AND NOT bullish trend[1]
Long: confirmed chart bar AND barssince(long pullback trigger) <= maximum pullback age AND close > open AND (close-back-fast-EMA requirement disabled OR close > EMA(close, short-term lookback)) AND volume confirmation AND (wick filter disabled OR lower wick % >= minimum rejection wick percentage) AND body % >= minimum body percentage AND long T1 filter pass AND bullish signal score >= (A+ only ? A+ score threshold : minimum signal score)
Short: bearish trend AND NOT bearish trend[1]
Short: confirmed chart bar AND barssince(short pullback trigger) <= maximum pullback age AND close < open AND (close-back-fast-EMA requirement disabled OR close < EMA(close, short-term lookback)) AND volume confirmation AND (wick filter disabled OR upper wick % >= minimum rejection wick percentage) AND body % >= minimum body percentage AND short T1 filter pass AND bearish signal score >= (A+ only ? A+ score threshold : minimum signal score)