Calculation: Panic ratio = max(0, 50 − RSI) / 10 × volume / average volume over the volume lookback; use 0 when volume is unavailable or zero
Calculation: FOMO ratio = max(0, RSI − 50) / 10 × volume / average volume over the volume lookback; use 0 when volume is unavailable or zero
Calculation: Momentum reading = 100 + ((close − lowest low over 5 bars) / (highest high over 5 bars − lowest low over 5 bars) − 0.5) × 4; use 100 when the range is zero
Long: close > EMA(slow) AND EMA(mid) > EMA(slow)
Long: close > SMA(macro) AND SMA(macro) > SMA(macro, 5 bars ago)
Long: EMA(fast) > EMA(mid) AND EMA(mid) > EMA(slow) AND (EMA(fast, prior bar) ≤ EMA(mid, prior bar) OR EMA(mid, prior bar) ≤ EMA(slow, prior bar))
Long: RSI crosses above the oversold level AND EMA(mid) > EMA(slow) AND NOT (Panic ratio > threshold AND close < open)
Long: FOMO ratio > threshold AND close > open AND |close − EMA(fast)| > ATR
Long: Momentum reading < oversold level
Short: close < EMA(slow) AND EMA(mid) < EMA(slow)
Short: close < SMA(macro) AND SMA(macro) < SMA(macro, 5 bars ago)
Short: EMA(fast) < EMA(mid) AND EMA(mid) < EMA(slow) AND (EMA(fast, prior bar) ≥ EMA(mid, prior bar) OR EMA(mid, prior bar) ≥ EMA(slow, prior bar))
Short: Panic ratio > threshold AND close < open
Short: Momentum reading > overbought level