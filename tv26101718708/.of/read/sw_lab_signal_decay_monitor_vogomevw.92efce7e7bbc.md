Calculation: Warmup length = maximum of the regime slow ATR lookback and a fixed multiple of the regime trend SMA lookback.
Calculation: Price z-score = (close − SMA of close) / standard deviation of close over the same lookback; use zero when the standard deviation is zero.
Long: Elapsed bars >= warmup length AND short-lookback SMA of close crosses above long-lookback SMA of close.
Short: Elapsed bars >= warmup length AND short-lookback SMA of close crosses below long-lookback SMA of close.
Long: Elapsed bars >= warmup length AND RSI of close crosses above its lower threshold.
Short: Elapsed bars >= warmup length AND RSI of close crosses below its upper threshold.
Long: Elapsed bars >= warmup length AND MACD line crosses above its signal line; the fast and slow MACD lengths are independently capped, and the signal length is a fixed proportion of the uncapped fast length, rounded and subject to a minimum.
Short: Elapsed bars >= warmup length AND MACD line crosses below its signal line; the fast and slow MACD lengths are independently capped, and the signal length is a fixed proportion of the uncapped fast length, rounded and subject to a minimum.
Long: Elapsed bars >= warmup length AND close <= lower Bollinger Band AND RSI of close < lower RSI threshold.
Short: Elapsed bars >= warmup length AND close >= upper Bollinger Band AND RSI of close > upper RSI threshold.
Long: Elapsed bars >= warmup length AND close > highest high over the lookback ending on the previous bar AND volume > a multiple of its current SMA.
Short: Elapsed bars >= warmup length AND close < lowest low over the lookback ending on the previous bar AND volume > a multiple of its current SMA.
Long: Elapsed bars >= warmup length AND price z-score < lower threshold.
Short: Elapsed bars >= warmup length AND price z-score > upper threshold.