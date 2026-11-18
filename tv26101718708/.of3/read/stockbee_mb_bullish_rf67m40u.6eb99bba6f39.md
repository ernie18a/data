Calculation: close-to-high candle position = (close - open) / (high - open) * 100
Long: volume > volume[1] AND (close - close[1]) / close[1] * 100 > percent gain threshold AND close-to-high candle position > close-position threshold
Long: close - close[1] > price-change threshold AND close-to-high candle position > close-position threshold
Long: close / close[lookback] > gain-ratio threshold