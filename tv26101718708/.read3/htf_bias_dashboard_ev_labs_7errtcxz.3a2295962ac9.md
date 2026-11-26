Calculation: T-series values = calculations run on each requested timeframe T1–T6 and sampled on chart bars; use the last completed T bar historically and the still-forming T bar in real time
Calculation: Trend(T) = bullish when close(T) > EMA(close, fast lookback), bearish when close(T) < EMA(close, fast lookback), otherwise flat
Calculation: Structure(T) = bullish when close(T) > EMA(close, fast lookback) > EMA(close, mid lookback) > EMA(close, slow lookback), bearish when close(T) < EMA(close, fast lookback) < EMA(close, mid lookback) < EMA(close, slow lookback), otherwise mixed; fast, mid, and slow lookbacks are ordered shortest to longest
Calculation: Bull count = number of T1–T6 where Trend(T) is bullish
Calculation: Bear count = number of T1–T6 where Trend(T) is bearish
Long: Trend(T) is bullish for any T in T1–T6
Short: Trend(T) is bearish for any T in T1–T6
Long: Structure(T) is bullish for any T in T1–T6
Short: Structure(T) is bearish for any T in T1–T6
Long: RSI(close(T), RSI lookback) < lower RSI-color threshold for any T in T1–T6
Short: RSI(close(T), RSI lookback) > upper RSI-color threshold for any T in T1–T6
Long: Bull count >= overall bias threshold
Short: Bear count >= overall bias threshold
Long: Bull count >= majority alert threshold
Short: Bear count >= majority alert threshold
Long: Trend(T) is bullish for all T in T1–T6
Short: Trend(T) is bearish for all T in T1–T6