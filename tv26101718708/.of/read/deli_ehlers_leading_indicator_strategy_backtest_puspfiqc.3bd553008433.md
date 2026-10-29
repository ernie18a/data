Calculation: Detrended synthetic price = EMA(HL2, shorter lookback) - EMA(HL2, longer lookback), with the longer lookback twice the shorter; HL2 uses a higher-timeframe bar that is still forming.
Calculation: Ehlers Leading Indicator = detrended synthetic price - EMA(detrended synthetic price, the shorter lookback).
Long: Ehlers Leading Indicator > 0 OR (Ehlers Leading Indicator = 0 AND the prior signal side is long)
Short: Ehlers Leading Indicator < 0 OR (Ehlers Leading Indicator = 0 AND the prior signal side is short)