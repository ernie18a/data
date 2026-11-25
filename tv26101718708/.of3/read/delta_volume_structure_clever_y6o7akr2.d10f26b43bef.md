Calculation: Bar delta = EMA of the selected estimate over the delta-smoothing lookback: OHLC estimate is volume * ((close - low) - (high - close)) / (high - low), or positive volume when high = low and close >= open, otherwise negative volume; close-versus-open estimate is positive volume when close >= open, otherwise negative volume; wick estimate is volume * (buy pressure - sell pressure) / (buy pressure + sell pressure), where buy pressure is lower wick plus the candle body when close >= open, and sell pressure is upper wick plus the candle body when close < open; when high = low, use the OHLC zero-range estimate.
Calculation: Cumulative delta = cumulative sum of bar delta since the configured reset.
Calculation: Session delta = cumulative sum of bar delta since the current session began.
Calculation: Delta percentage = bar delta as a percentage of volume, or zero when volume is zero.
Calculation: Volume rank = volume / SMA(volume, volume lookback), or the neutral-rank fallback when the average is zero.
Calculation: Buy volume = for the OHLC estimate, volume * (close - low) / (high - low), or volume when high = low and close >= open, otherwise zero; for the close-versus-open estimate, volume when close >= open, otherwise zero; for the wick estimate, half of volume.
Calculation: Sell volume = volume - buy volume.
Calculation: Imbalance ratio = buy volume / sell volume, or the zero-sell fallback when sell volume is zero.
Calculation: Close position = the close's percentage position between low and high, or the neutral midpoint when high = low.
Calculation: Weighted delta score = delta percentage * delta-percent weight + (volume rank - neutral rank) * volume-rank scale * volume-rank weight + (close position - midpoint percentage) * close-position weight.
Calculation: Aggression index = delta percentage * volume rank.
Calculation: Directional bias score = sign(cumulative delta - cumulative delta[short CVD change lookback]) + sign(cumulative delta - cumulative delta[short CVD change lookback]) + confirmation term + imbalance term + sign(session delta), where confirmation term is +1 when close > open and bar delta > 0, -1 when close < open and bar delta < 0, otherwise zero; imbalance term is +1 when imbalance ratio > buy threshold, -1 when imbalance ratio < sell threshold, otherwise zero.
Calculation: Scaled cumulative delta = price midpoint + cumulative delta * scale, where price midpoint is the midpoint of the highest high and lowest low over the normalization lookback, and scale is price range * normalization scale factor / highest absolute cumulative delta over that lookback, or 1 when that highest absolute value is zero.
Calculation: Scaled cumulative-delta average = price midpoint + EMA(cumulative delta, CVD average lookback) * scale.
Long: bar delta >= 0
Short: bar delta < 0
Long: cumulative delta >= 0
Short: cumulative delta < 0
Long: session delta >= 0
Short: session delta < 0
Long: scaled cumulative delta >= scaled cumulative-delta average
Short: scaled cumulative delta <= scaled cumulative-delta average
Long: cumulative delta > EMA(cumulative delta, CVD average lookback)
Short: cumulative delta <= EMA(cumulative delta, CVD average lookback)
Long: cumulative delta crosses above EMA(cumulative delta, CVD average lookback)
Short: cumulative delta crosses below EMA(cumulative delta, CVD average lookback)
Long: cumulative delta - cumulative delta[short CVD change lookback] > 0
Short: cumulative delta - cumulative delta[short CVD change lookback] < 0
Long: bar delta crosses above zero
Short: bar delta crosses below zero
Long: volume >= SMA(volume, volume lookback) * high-volume multiplier AND bar delta > 0
Short: volume >= SMA(volume, volume lookback) * high-volume multiplier AND bar delta < 0
Long: close > EMA(close, shorter EMA lookback) AND EMA(close, shorter EMA lookback) > EMA(close, intermediate EMA lookback)
Short: close < EMA(close, shorter EMA lookback) AND EMA(close, shorter EMA lookback) < EMA(close, intermediate EMA lookback)
Long: sum(bar delta, rolling-delta lookback) >= 0
Short: sum(bar delta, rolling-delta lookback) < 0
Long: bar delta > 0 for at least the streak-length number of consecutive bars
Short: bar delta < 0 for at least the streak-length number of consecutive bars
Long: the latest confirmed pivot low of low is below its preceding pivot low AND the latest confirmed pivot low of cumulative delta is above its preceding pivot low, using the same pivot lookback on both
Short: the latest confirmed pivot high of high is above its preceding pivot high AND the latest confirmed pivot high of cumulative delta is below its preceding pivot high, using the same pivot lookback on both
Long: volume >= SMA(volume, volume lookback) * high-volume multiplier AND abs(delta percentage) < absorption threshold AND close > open
Short: volume >= SMA(volume, volume lookback) * high-volume multiplier AND abs(delta percentage) < absorption threshold AND close > open
Long: volume >= SMA(volume, volume lookback) * high-volume multiplier AND abs(delta percentage) < absorption threshold AND close < open
Short: volume >= SMA(volume, volume lookback) * high-volume multiplier AND abs(delta percentage) < absorption threshold AND close < open
Long: volume >= SMA(volume, volume lookback) * climax-volume multiplier AND abs(delta percentage) > climax delta threshold AND bar delta > 0
Short: volume >= SMA(volume, volume lookback) * climax-volume multiplier AND abs(delta percentage) > climax delta threshold AND bar delta < 0
Long: buy volume / volume > buyer-share threshold
Short: buy volume / volume < seller-share threshold
Long: imbalance ratio > buy threshold
Short: imbalance ratio < sell threshold
Long: aggression index > aggression threshold
Short: aggression index < -aggression threshold
Long: close position > upper-position threshold
Short: close position < lower-position threshold
Long: weighted delta score > buy-score threshold
Short: weighted delta score < -sell-score threshold
Long: directional bias score >= bias threshold
Short: directional bias score <= -bias threshold