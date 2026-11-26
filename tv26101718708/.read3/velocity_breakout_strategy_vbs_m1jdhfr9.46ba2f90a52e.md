Calculation: ATR compression = ATR(shorter ATR lookback) < ATR(longer ATR lookback)
Calculation: Golden cross = EMA(close, shorter EMA lookback) crosses above EMA(close, longer EMA lookback)
Calculation: Death cross = EMA(close, shorter EMA lookback) crosses below EMA(close, longer EMA lookback)
Calculation: Bear-phase low = IF Death cross THEN low ELSE IF EMA(close, shorter EMA lookback) <= EMA(close, longer EMA lookback) THEN MIN(Bear-phase low[1], low) ELSE Bear-phase low[1]
Calculation: Discount level = LOWEST(low, dealing range lookback) + equilibrium fraction * (HIGHEST(high, dealing range lookback) - LOWEST(low, dealing range lookback))
Calculation: Master reset = close > Master top[1] OR close < Master bottom[1]
Calculation: Master top = IF Master reset THEN (IF wick-bounds switch THEN high ELSE MAX(open, close)) ELSE Master top[1]
Calculation: Master bottom = IF Master reset THEN (IF wick-bounds switch THEN low ELSE MIN(open, close)) ELSE Master bottom[1]
Calculation: Bars since master = IF Master reset THEN 0 ELSE Bars since master[1] + 1
Calculation: Stop distance = (IF ADX(ADX length) < ADX squeeze threshold AND long position AND close > entry price THEN tight ATR multiplier ELSE base ATR multiplier) * ATR(ATR period)
Calculation: Trail stop = IF close > Trail stop[1] AND close[1] > Trail stop[1] THEN MAX(Trail stop[1], close - Stop distance) ELSE IF close < Trail stop[1] AND close[1] < Trail stop[1] THEN MIN(Trail stop[1], close + Stop distance) ELSE IF close > Trail stop[1] THEN close - Stop distance ELSE close + Stop distance
Calculation: Trail state = IF close[1] < Trail stop[1] AND close > Trail stop[1] THEN 1 ELSE IF close[1] > Trail stop[1] AND close < Trail stop[1] THEN -1 ELSE Trail state[1]
Calculation: Volume spike = volume > SMA(volume, volume lookback) + volume deviation multiplier * STDEV(volume, volume lookback)
Calculation: Pullback setup = EMA(close, shorter EMA lookback) > EMA(close, longer EMA lookback) AND LOWEST(low, touch lookback) <= EMA(close, shorter EMA lookback) AND (SMC filter is off OR close <= Discount level) AND close >= open AND (close > EMA(close, shorter EMA lookback) OR MIN(open, close) - low > wick ratio * ABS(close - open)) AND Trail state = 1 AND NOT Golden cross AND (chop filter is off OR NOT ATR compression)
Calculation: Reload armed = close > HIGHEST(high, reset lookback)[1] OR (Reload armed[1] AND NOT Pullback setup[1])
Long: Golden cross
Long: Golden cross AND (higher-low filter is off OR LOWEST(low, structure lookback) > Bear-phase low) AND (close - LOWEST(low, structure lookback)) / LOWEST(low, structure lookback) * 100 <= max run-up percent AND (chop filter is off OR NOT ATR compression)
Long: Golden cross AND NOT (higher-low filter is off OR LOWEST(low, structure lookback) > Bear-phase low) AND higher-low filter is off AND (close - LOWEST(low, structure lookback)) / LOWEST(low, structure lookback) * 100 <= max run-up percent AND (chop filter is off OR NOT ATR compression)
Long: Pullback setup AND Reload armed
Long: Bars since master[1] >= required follow-up bars AND close > Master top[1] AND close >= open AND (breakout trend filter is off OR (EMA(close, shorter EMA lookback) > EMA(close, longer EMA lookback) AND Trail state = 1)) AND (chop filter is off OR NOT ATR compression)
Long: Volume spike AND EMA(close, shorter EMA lookback) < EMA(close, longer EMA lookback)
Short: Volume spike AND EMA(close, shorter EMA lookback) > EMA(close, longer EMA lookback)
Exit: long, Trail state = -1 AND Trail state[1] = 1
Exit: long, Death cross