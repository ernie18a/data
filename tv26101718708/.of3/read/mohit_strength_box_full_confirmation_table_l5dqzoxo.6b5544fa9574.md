Calculation: Relative strength deviation = 100 * ((close / benchmark close) / SMA(close / benchmark close, relative strength smoothing lookback) - 1)
Calculation: Volatility contraction = ATR(volatility ATR lookback) < SMA(ATR(volatility ATR lookback), ATR contraction smoothing lookback) * ATR contraction ratio AND Bollinger Band Width(close, band lookback, band multiplier) < SMA(Bollinger Band Width(close, band lookback, band multiplier), band lookback)
Calculation: Bullish signal count = number of true conditions among (relative strength deviation > relative strength threshold; Supertrend(factor, Supertrend ATR lookback).direction < 0; MACD(close, fast lookback, slow lookback, signal lookback).line > MACD(close, fast lookback, slow lookback, signal lookback).signal; RSI(close, RSI lookback) > RSI threshold; close > EMA(close, fast EMA lookback) AND EMA(close, fast EMA lookback) > EMA(close, slow EMA lookback); DMI(DI lookback, ADX smoothing lookback).+DI > DMI(DI lookback, ADX smoothing lookback).-DI)
Long: Relative strength deviation > relative strength threshold
Short: Relative strength deviation <= relative strength threshold
Long: Supertrend(factor, Supertrend ATR lookback).direction < 0
Short: Supertrend(factor, Supertrend ATR lookback).direction >= 0
Long: MACD(close, fast lookback, slow lookback, signal lookback).line > MACD(close, fast lookback, slow lookback, signal lookback).signal
Short: MACD(close, fast lookback, slow lookback, signal lookback).line <= MACD(close, fast lookback, slow lookback, signal lookback).signal
Long: RSI(close, RSI lookback) > RSI threshold
Short: RSI(close, RSI lookback) <= RSI threshold
Long: close > EMA(close, fast EMA lookback) AND EMA(close, fast EMA lookback) > EMA(close, slow EMA lookback)
Short: close <= EMA(close, fast EMA lookback) OR EMA(close, fast EMA lookback) <= EMA(close, slow EMA lookback)
Long: DMI(DI lookback, ADX smoothing lookback).+DI > DMI(DI lookback, ADX smoothing lookback).-DI
Short: DMI(DI lookback, ADX smoothing lookback).+DI <= DMI(DI lookback, ADX smoothing lookback).-DI
Long: Bullish signal count > half of the six directional conditions
Short: Bullish signal count <= half of the six directional conditions
Long: Bullish signal count = 6
Short: Bullish signal count = 0
Long: Relative strength deviation > relative strength threshold AND volume / SMA(volume, volume average lookback) >= volume expansion threshold
Long: Volatility contraction AND volume / SMA(volume, volume average lookback) >= volume expansion threshold AND relative strength deviation > relative strength threshold
Long: Supertrend(factor, Supertrend ATR lookback).direction < 0 AND MACD(close, fast lookback, slow lookback, signal lookback).line > MACD(close, fast lookback, slow lookback, signal lookback).signal AND RSI(close, RSI lookback) > RSI threshold
Long: Volatility contraction AND Bullish signal count > half of the six directional conditions