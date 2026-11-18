Calculation: T1 DEMA = DEMA(close, DEMA lookback) evaluated on T1 bars at the current (still-forming) bar and sampled on chart bars
Calculation: MACD line = MACD(close, shorter fast lookback, longer slow lookback, signal lookback).line on chart bars
Calculation: MACD signal = MACD(close, shorter fast lookback, longer slow lookback, signal lookback).signal on chart bars
Calculation: T2 ATR = ATR(high, low, close, ATR lookback) evaluated on T2 bars at the current (still-forming) bar and sampled on chart bars
Calculation: T2 ATR average = SMA(ATR(high, low, close, ATR lookback), ATR average lookback) evaluated on T2 bars at the current (still-forming) bar and sampled on chart bars
Calculation: T2 ADX = ADX(high, low, close, ADX lookback) evaluated on T2 bars at the current (still-forming) bar and sampled on chart bars
Long: close(T1, current (still-forming) bar), sampled on chart bars > T1 DEMA
Short: close(T1, current (still-forming) bar), sampled on chart bars <= T1 DEMA
Long: MACD line > MACD signal
Short: MACD line <= MACD signal
Long: close(T1, current (still-forming) bar), sampled on chart bars > T1 DEMA AND MACD line > MACD signal AND T2 ADX > ADX threshold AND T2 ATR > T2 ATR average
Short: close(T1, current (still-forming) bar), sampled on chart bars < T1 DEMA AND MACD line < MACD signal AND T2 ADX > ADX threshold AND T2 ATR > T2 ATR average