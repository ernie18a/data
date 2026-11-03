Calculation: Volume effort score = clamp(70 × (volume / SMA(volume, volume lookback) − 1) / (effort threshold − 1) + 10 × clamp((volume − SMA(volume, volume lookback)) / stdev(volume, same lookback), 0, 3), 0, 100)
Calculation: Spread compression score = clamp(100 × (1 − candle range / SMA(candle range, spread lookback)) / (1 − maximum spread ratio), 0, 100)
Calculation: Bullish close score = clamp(200 × ((close − low) / candle range − 0.5), 0, 100)
Calculation: Bearish close score = clamp(200 × (0.5 − (close − low) / candle range), 0, 100)
Calculation: Bullish absorption quality = 0.38 × volume effort score + 0.34 × spread compression score + 0.28 × bullish close score
Calculation: Bearish absorption quality = 0.38 × volume effort score + 0.34 × spread compression score + 0.28 × bearish close score
Calculation: Bullish invalidation level = absorption candle low − ATR × invalidation buffer
Calculation: Bearish invalidation level = absorption candle high + ATR × invalidation buffer
Long: volume / SMA(volume, volume lookback) ≥ effort threshold AND candle range / SMA(candle range, spread lookback) ≤ maximum spread ratio AND (close − low) / candle range ≥ strong close location AND (min(open, close) − low) / candle range ≥ minimum absorbed wick share AND bullish absorption quality ≥ minimum absorption quality
Short: volume / SMA(volume, volume lookback) ≥ effort threshold AND candle range / SMA(candle range, spread lookback) ≤ maximum spread ratio AND (close − low) / candle range ≤ 1 − strong close location AND (high − max(open, close)) / candle range ≥ minimum absorbed wick share AND bearish absorption quality ≥ minimum absorption quality
Exit: Long, close < bullish invalidation level of an existing zone
Exit: Short, close > bearish invalidation level of an existing zone