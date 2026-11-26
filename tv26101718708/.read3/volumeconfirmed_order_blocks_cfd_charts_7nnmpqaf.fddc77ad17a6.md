Calculation: Impulse = high - low > range multiplier * ATR(ATR lookback) AND high - low > 0 AND abs(close - open) / (high - low) >= minimum body ratio
Calculation: Volume confirmation = volume multiplier <= 0 OR (volume >= volume multiplier * SMA(volume, volume lookback) AND SMA(volume, volume lookback) > 0)
Long: on a completed chart bar, Impulse AND close > open AND Volume confirmation
Short: on a completed chart bar, Impulse AND close < open AND Volume confirmation
Calculation: Candle range = candle high − candle low
Long: bar is confirmed AND Candle range > P1 × ATR(P2) AND Candle range > 0 AND abs(close − open) / Candle range ≥ P3 AND close > open AND (P4 ≤ 0 OR (zero-filled corresponding futures-contract volume ≥ P4 × SMA(zero-filled corresponding futures-contract volume, P5) AND SMA(zero-filled corresponding futures-contract volume, P5) > 0))
Short: bar is confirmed AND Candle range > P1 × ATR(P2) AND Candle range > 0 AND abs(close − open) / Candle range ≥ P3 AND close < open AND (P4 ≤ 0 OR (zero-filled corresponding futures-contract volume ≥ P4 × SMA(zero-filled corresponding futures-contract volume, P5) AND SMA(zero-filled corresponding futures-contract volume, P5) > 0))