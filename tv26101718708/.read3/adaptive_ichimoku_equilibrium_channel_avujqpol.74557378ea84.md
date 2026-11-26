Calculation: Tenkan = (highest(high, shorter lookback) + lowest(low, shorter lookback)) / 2
Calculation: Kijun = (highest(high, longer lookback) + lowest(low, longer lookback)) / 2
Calculation: Senkou B = (highest(high, longest lookback) + lowest(low, longest lookback)) / 2
Calculation: Senkou A = (Tenkan + Kijun) / 2
Calculation: cloud top = max(Senkou A, Senkou B)
Calculation: cloud bottom = min(Senkou A, Senkou B)
Calculation: ATR = ATR(high, low, close, ATR lookback)
Calculation: efficiency ratio = Kaufman efficiency ratio(close, efficiency lookback)
Calculation: equilibrium = efficiency ratio * Tenkan + (1 - efficiency ratio) * Kijun
Calculation: equilibrium slope = equilibrium - equilibrium[slope lookback]
Calculation: channel half-width = ATR * width multiplier * clamp(ATR / SMA(ATR, ATR average lookback), volatility-ratio floor, volatility-ratio ceiling)
Calculation: channel high = equilibrium + channel half-width
Calculation: channel low = equilibrium - channel half-width
Calculation: channel position = (close - channel low) / (channel high - channel low)
Calculation: uptrend = close > cloud top AND (Senkou A > Senkou B OR equilibrium slope > 0)
Calculation: downtrend = close < cloud bottom AND (Senkou A <= Senkou B OR equilibrium slope < 0)
Calculation: higher-timeframe uptrend = at the last completed T1 bar, with cloud top, Senkou A, Senkou B and Kijun computed on T1 bars: close > cloud top AND (Senkou A > Senkou B OR Kijun - Kijun[slope lookback] > 0)
Calculation: higher-timeframe downtrend = at the last completed T1 bar, with cloud bottom, Senkou A, Senkou B and Kijun computed on T1 bars: close < cloud bottom AND (Senkou A <= Senkou B OR Kijun - Kijun[slope lookback] < 0)
Calculation: lower-timeframe bullish = at the last completed T2 bar, close > EMA(close, lower-timeframe EMA lookback), with the EMA computed on T2 bars
Calculation: lower-timeframe bearish = at the last completed T2 bar, close < EMA(close, lower-timeframe EMA lookback), with the EMA computed on T2 bars
Calculation: long stop = cloud bottom - stop buffer * ATR
Calculation: short stop = cloud top + stop buffer * ATR
Calculation: nearest equal-high level = lowest equal-high level above close, where each newly confirmed pivot high (liquidity pivot length on each side) registers, for each of the last pivot memory pivot highs within equal-level tolerance * ATR of it, the higher of the two as an equal-high level; a level is dropped once high exceeds it; only the newest level cap levels are kept
Calculation: nearest equal-low level = highest equal-low level below close, where each newly confirmed pivot low (liquidity pivot length on each side) registers, for each of the last pivot memory pivot lows within equal-level tolerance * ATR of it, the lower of the two as an equal-low level; a level is dropped once low falls below it; only the newest level cap levels are kept
Calculation: long target = nearest equal-high level if it exists, else channel high
Calculation: short target = nearest equal-low level if it exists, else channel low
Calculation: body share = |close - open| / (high - low)
Calculation: volume ratio = volume / SMA(volume, volume average lookback)
Long: position side is not long AND uptrend AND channel position < discount threshold AND close > open AND higher-timeframe uptrend AND lower-timeframe bullish AND efficiency ratio > clear efficiency threshold AND (long target - close) >= minimum reward-to-risk * (close - long stop)
Long: uptrend AND channel position < discount threshold AND channel position[1] >= discount threshold
Long: uptrend AND NOT uptrend[1]
Long: Senkou A > Senkou B AND Senkou A[1] <= Senkou B[1]
Long: close crosses above channel high AND (close - channel high) / ATR >= breakout displacement AND body share >= body share threshold AND volume ratio >= volume ratio threshold AND (close - low) / (high - low) >= close-hold threshold
Long: a pivot low with divergence pivot length bars on each side is confirmed on this bar AND low[divergence pivot length] < the previous confirmed pivot low AND (equilibrium - low)[divergence pivot length] < (equilibrium - low) at the bar of the previous confirmed pivot low
Short: position side is not short AND downtrend AND channel position > premium threshold AND close < open AND higher-timeframe downtrend AND lower-timeframe bearish AND efficiency ratio > clear efficiency threshold AND (close - short target) >= minimum reward-to-risk * (short stop - close)
Short: downtrend AND channel position > premium threshold AND channel position[1] <= premium threshold
Short: downtrend AND NOT downtrend[1]
Short: Senkou A <= Senkou B AND Senkou A[1] > Senkou B[1]
Short: close crosses below channel low AND (channel low - close) / ATR >= breakout displacement AND body share >= body share threshold AND volume ratio >= volume ratio threshold AND (high - close) / (high - low) >= close-hold threshold
Short: a pivot high with divergence pivot length bars on each side is confirmed on this bar AND high[divergence pivot length] > the previous confirmed pivot high AND (high - equilibrium)[divergence pivot length] < (high - equilibrium) at the bar of the previous confirmed pivot high
Exit: long, low <= long stop at entry bar OR high >= long target at entry bar OR downtrend
Exit: short, high >= short stop at entry bar OR low <= short target at entry bar OR uptrend