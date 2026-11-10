Calculation: Signed body strength = (close - open) / (high - low), or zero when high equals low.
Calculation: Volume ratio = volume / SMA(volume), or one when the volume SMA is not positive.
Calculation: Turn score = clamp to a symmetric range around zero: (sign(close - previous close) + sign(CMF - previous CMF)) / 2, multiplied by a larger positive weight if both nonzero directions differ from their respective previous directions, or a smaller positive weight if only one does; use zero unless volume ratio exceeds a threshold and absolute signed body strength exceeds a threshold.
Calculation: Candle momentum = clamp to a symmetric range around zero the SMA of signed body strength multiplied by volume ratio clamped between positive lower and upper bounds.
Calculation: Behavior score = clamp to a symmetric range around zero a weighted sum of short-lookback price momentum, longer-lookback price momentum, price acceleration, volume momentum, and CMF. Price momentum is 100 times (close - close at the lookback) / close; acceleration is short-lookback price momentum minus the same momentum measured one short lookback earlier; volume momentum is 100 times (volume SMA - volume SMA at its lookback) / current volume SMA. Each component has a positive weight.
Long: Turn score > positive threshold.
Short: Turn score < negative threshold.
Long: Candle momentum > positive threshold.
Short: Candle momentum < negative threshold.
Long: Shorter-period close EMA > longer-period close EMA.
Short: Shorter-period close EMA < longer-period close EMA.
Long: CMF > positive threshold.
Short: CMF < negative threshold.
Long: Behavior score > positive threshold.
Short: Behavior score < negative threshold.
Long: CMF > 0 AND signed body strength > 0 AND (signed body strength <= positive push threshold OR volume ratio <= push threshold OR upper wick / candle range <= wick threshold OR (shorter-period close EMA > longer-period close EMA AND close > highest high over a lookback ending at the previous bar)).
Short: CMF < 0 AND signed body strength < 0 AND (signed body strength >= negative push threshold OR volume ratio <= push threshold OR lower wick / candle range <= wick threshold OR (shorter-period close EMA < longer-period close EMA AND close < lowest low over a lookback ending at the previous bar)).