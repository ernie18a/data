Calculation: ATR filter passes = ATR(ATR period) >= SMA(ATR(ATR period), ATR period) * ATR multiplier
Calculation: volume filter passes = volume filter disabled OR volume > SMA(volume, volume lookback) * volume factor
Long: crosses above(RSI(close, RSI length), RSI oversold level) AND close > EMA(close, shorter EMA length) AND ATR filter passes AND volume filter passes
Long: RSI(close, RSI length) < long-2 RSI ceiling AND crosses above(close, EMA(close, shorter EMA length)) AND ATR filter passes
Long: crosses above(EMA(close, shorter EMA length), EMA(close, longer EMA length)) AND RSI(close, RSI length) < long-3 RSI ceiling AND ATR filter passes
Short: crosses below(RSI(close, RSI length), RSI overbought level) AND close < EMA(close, shorter EMA length) AND ATR filter passes AND volume filter passes
Short: RSI(close, RSI length) > short-2 RSI floor AND crosses below(close, EMA(close, shorter EMA length)) AND ATR filter passes
Short: crosses below(EMA(close, shorter EMA length), EMA(close, longer EMA length)) AND RSI(close, RSI length) > short-3 RSI floor AND ATR filter passes