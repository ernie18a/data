Calculation: Volume ratio = min(volume / SMA(volume), volume cap) when SMA(volume) > 0; otherwise 1.
Calculation: Raw flow = abs(close - open) / (high - low) × volume ratio; use 0 when high = low.
Calculation: Flow score = (raw flow - rolling minimum raw flow) / (rolling maximum raw flow - rolling minimum raw flow), using the same lookback for both extrema; use 0 when the extrema are equal.
Calculation: Close position = (close - low) / (high - low); use 0 when high = low.
Long: close > WMA(close).
Short: close <= WMA(close).
Long: close <= WMA(close) AND close position > upper close-position threshold AND close > open AND volume ratio > volume threshold AND flow score > flow threshold.
Short: close > WMA(close) AND close position < lower close-position threshold AND close < open AND volume ratio > volume threshold AND flow score > flow threshold.