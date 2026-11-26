Long: at least MIN_ALIGN enabled timeframes among T1–T5 have RSI(close, RSI lookback) on the current timeframe bar, including while it is forming, sampled on chart bars, >= upper RSI threshold
Short: at least MIN_ALIGN enabled timeframes among T1–T5 have RSI(close, RSI lookback) on the current timeframe bar, including while it is forming, sampled on chart bars, <= lower RSI threshold AND the Long condition is false
Calculation: bullish RSI count = count of enabled T1–T5 where RSI(close, RSI length), or 0 if unavailable, is at least the bullish RSI threshold
Calculation: bearish RSI count = count of enabled T1–T5 where RSI(close, RSI length), or 50 if unavailable, is at most the bearish RSI threshold
Long: bullish RSI count >= minimum aligned timeframes
Short: bearish RSI count >= minimum aligned timeframes AND bullish RSI count < minimum aligned timeframes