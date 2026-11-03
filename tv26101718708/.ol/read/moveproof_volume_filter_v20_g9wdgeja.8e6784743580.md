Calculation: Capped volume = min(current volume, prior bar’s EMA of raw volume × cap multiplier) when adaptive volume averaging is enabled; otherwise current volume. If the prior EMA is unavailable, use current volume as the cap base.
Calculation: Volume average = selected SMA, EMA, or RMA of capped volume.
Calculation: Relative volume = current volume / volume average.
Calculation: Bullish close strength = (close − low) / (high − low), or 0.5 when high = low.
Calculation: Bearish close strength = (high − close) / (high − low), or 0.5 when high = low.
Long: close > highest high of preceding breakout-lookback bars AND close > open AND bullish close strength ≥ required close-strength threshold AND relative volume ≥ strong-volume threshold
Short: close < lowest low of preceding breakout-lookback bars AND close < open AND bearish close strength ≥ required close-strength threshold AND relative volume ≥ strong-volume threshold