Long: RSI(close, cross lookback) crosses above cross level
Short: RSI(close, cross lookback) crosses below cross level
Long: MACD(close, shorter MACD lookback, longer MACD lookback, MACD signal lookback) line crosses above signal line
Short: MACD(close, shorter MACD lookback, longer MACD lookback, MACD signal lookback) line crosses below signal line
Long: SMA(close, shorter SMA lookback) crosses above SMA(close, longer SMA lookback)
Short: SMA(close, shorter SMA lookback) crosses below SMA(close, longer SMA lookback)
Long: EMA(close, shorter EMA lookback) > EMA(close, longer EMA lookback)
Short: EMA(close, shorter EMA lookback) < EMA(close, longer EMA lookback)
Long: RSI(close, price-line lookback) >= price-line level
Short: RSI(close, price-line lookback) < price-line level
Long: RSI(close, multi-timeframe lookback, T1, bar still forming) >= multi-timeframe level
Short: RSI(close, multi-timeframe lookback, T1, bar still forming) < multi-timeframe level
Long: change(RSI(close, multi-timeframe lookback, T1, bar still forming)) > 0
Short: change(RSI(close, multi-timeframe lookback, T1, bar still forming)) < 0
Long: RSI(close, multi-timeframe lookback, T2, bar still forming) >= multi-timeframe level
Short: RSI(close, multi-timeframe lookback, T2, bar still forming) < multi-timeframe level
Long: change(RSI(close, multi-timeframe lookback, T2, bar still forming)) > 0
Short: change(RSI(close, multi-timeframe lookback, T2, bar still forming)) < 0
Long: RSI(close, multi-timeframe lookback, T3, bar still forming) >= multi-timeframe level
Short: RSI(close, multi-timeframe lookback, T3, bar still forming) < multi-timeframe level
Long: change(RSI(close, multi-timeframe lookback, T3, bar still forming)) > 0
Short: change(RSI(close, multi-timeframe lookback, T3, bar still forming)) < 0
Long: RSI(close, multi-timeframe lookback, T4, bar still forming) >= multi-timeframe level
Short: RSI(close, multi-timeframe lookback, T4, bar still forming) < multi-timeframe level
Long: change(RSI(close, multi-timeframe lookback, T4, bar still forming)) > 0
Short: change(RSI(close, multi-timeframe lookback, T4, bar still forming)) < 0
Long: RSI(close, multi-timeframe lookback, T5, bar still forming) >= multi-timeframe level
Short: RSI(close, multi-timeframe lookback, T5, bar still forming) < multi-timeframe level
Long: change(RSI(close, multi-timeframe lookback, T5, bar still forming)) > 0
Short: change(RSI(close, multi-timeframe lookback, T5, bar still forming)) < 0
Calculation: above count = (RSI(close, multi-timeframe lookback, T3, bar still forming) >= multi-timeframe level) + (RSI(close, multi-timeframe lookback, T4, bar still forming) >= multi-timeframe level) + (RSI(close, multi-timeframe lookback, T5, bar still forming) >= multi-timeframe level)
Long: above count = 3
Short: above count <= 1