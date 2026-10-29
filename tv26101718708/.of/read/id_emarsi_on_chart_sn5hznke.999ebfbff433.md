Calculation: Adaptive scaling factor = clamp the selected ATR-based, price-based, or volume-based scaling formula to its configured minimum and maximum.
Calculation: Modified RSI = 100 − 100 / (1 + up / down), where up is the longer-lookback RMA of the greater of close change and adaptive RSI base, and down is the RSI-lookback RMA of the greater of negative close change and negative adaptive RSI base; use 100 when down is zero and 0 when up is zero. Adaptive RSI base is RSI base multiplied by the adaptive scaling factor when adaptive scaling is enabled, otherwise RSI base.
Calculation: Price-mapped RSI = rolling price-range midpoint plus (modified RSI − 50) times half the rolling high-low range divided by 50 and, when adaptive scaling is enabled, by the adaptive scaling factor. When adaptive scaling is disabled, use the source's alternate mapping: midpoint minus midpoint divided by (1 + up / down).
Calculation: RSI moving average = configured moving average of price-mapped RSI using the same lookback as the longer RMA in modified RSI.
Long: price-mapped RSI crosses above its moving average.
Short: price-mapped RSI crosses below its moving average.
Exit: long, high >= current close * (1 + take-profit percentage) OR low <= the trailing stop.
Exit: short, low <= current close * (1 − take-profit percentage) OR high >= the trailing stop.