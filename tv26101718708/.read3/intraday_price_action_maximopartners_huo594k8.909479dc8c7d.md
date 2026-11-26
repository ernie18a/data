Calculation: relative volume = volume / SMA(volume, volume lookback) when SMA(volume, volume lookback) > 0, otherwise 0
Calculation: body efficiency = abs(close - open) / max(high - low, minimum tick size)
Calculation: close position = (close - low) / max(high - low, minimum tick size)
Calculation: buyer strength = close position * body efficiency
Calculation: seller strength = (1 - close position) * body efficiency
Calculation: buyer dominance = relative volume >= event volume threshold AND close != open AND buyer strength >= buyer strength threshold AND buyer strength > seller strength
Calculation: seller dominance = relative volume >= event volume threshold AND close != open AND seller strength >= seller strength threshold AND seller strength > buyer strength
Calculation: battle candle = relative volume >= event volume threshold AND NOT buyer dominance AND NOT seller dominance AND body efficiency <= battle body efficiency threshold
Long: on a confirmed bar, (relative volume >= zone volume threshold AND buyer dominance) OR (relative volume >= bubble volume threshold AND (buyer dominance OR (battle candle AND (min(open, close) - low) / max(high - low, minimum tick size) >= wick threshold))
Short: on a confirmed bar, (relative volume >= zone volume threshold AND seller dominance) OR (relative volume >= bubble volume threshold AND (seller dominance OR (battle candle AND (high - max(open, close)) / max(high - low, minimum tick size) >= wick threshold))
Long: EMA(close, shorter lookback) crosses above EMA(close, longer lookback) OR close > EMA(close, shorter lookback) AND close > EMA(close, longer lookback)
Short: EMA(close, shorter lookback) crosses below EMA(close, longer lookback) OR close < EMA(close, shorter lookback) AND close < EMA(close, longer lookback)
Long: on a confirmed bar, for each of the sequence-length bars, min(open, close) - low > lower-wick minimum AND min(open, close) - low > high - max(open, close), AND highest(low, sequence length) - lowest(low, sequence length) <= wick tolerance
Short: on a confirmed bar, for each of the sequence-length bars, high - max(open, close) > upper-wick minimum AND high - max(open, close) > min(open, close) - low, AND highest(high, sequence length) - lowest(high, sequence length) <= wick tolerance