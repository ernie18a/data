Calculation: Adaptive baseline = EMA of close blended with an efficiency-adaptive average and then EMA-smoothed. Efficiency is abs(close minus close at the efficiency lookback) divided by the sum of absolute consecutive close changes over that lookback; use zero when the denominator is zero. The adaptive average starts at close and updates by adding the squared smoothing coefficient times the difference between close and its previous value. The smoothing coefficient is efficiency times the difference between the fast and slow EMA coefficients plus the slow coefficient; the fast period is shorter than the slow period. Blend as EMA plus efficiency times the difference between the adaptive average and EMA.
Calculation: Volatility score = clamp(score midpoint + score scale × tanh(ATR z-score / z-score scale), score minimum, score maximum), where ATR z-score is ATR minus its moving average divided by its standard deviation over the volatility window; use zero when the denominator is zero.
Calculation: Trend power = clamp(abs(adaptive baseline minus its previous value) / max(ATR, minimum price increment) × slope scale + ADX / ADX scale, power minimum, power maximum).
Calculation: Range regime = ADX < ADX threshold AND trend power < trend-power threshold.
Calculation: Bull trend = close > adaptive baseline AND adaptive baseline > previous adaptive baseline AND shorter-period EMA of close > longer-period EMA of close.
Calculation: Bear trend = close < adaptive baseline AND adaptive baseline < previous adaptive baseline AND shorter-period EMA of close < longer-period EMA of close.
Calculation: Session VWAP = cumulative volume-weighted average of (high + low + close) / 3 since the session start; if unavailable, use an EMA of (high + low + close) / 3.
Calculation: Channel mean = EMA of the average of adaptive baseline and session VWAP, using a smoothing period derived from the channel-memory period.
Calculation: Channel distance = ATR × base channel multiplier × (channel offset + clamp(volatility score / score maximum, lower multiplier bound, upper multiplier bound)).
Calculation: Outer channel distance = ATR × outer channel multiplier × (outer offset + clamp(volatility score / outer score scale, lower outer bound, upper outer bound)).
Calculation: Equilibrium = rolling lowest low + max(rolling highest high − rolling lowest low, minimum price increment) × equilibrium fraction; premium and discount levels use the same rolling range with higher and lower fractions respectively.
Long: Bull trend.
Short: Bear trend.
Long: Close > session VWAP.
Short: Close < session VWAP.
Long: Close < equilibrium AND close < premium level.
Short: Close > equilibrium AND close > discount level.
Long: Close < channel mean − channel distance.
Short: Close > channel mean + channel distance.
Long: Bull trend AND low <= max(adaptive baseline, channel mean − channel distance × mid-channel fraction) AND close > open AND bars since the last bullish retest zone > retest cooldown, or no bullish retest zone has been created.
Short: Bear trend AND high >= min(adaptive baseline, channel mean + channel distance × mid-channel fraction) AND close < open AND bars since the last bearish retest zone > retest cooldown, or no bearish retest zone has been created.
Long: Bull trend AND range regime is false AND previous bar had no bull trend outside the range regime.
Short: Bear trend AND range regime is false AND previous bar had no bear trend outside the range regime.
Long: Low < channel mean − outer channel distance AND close > channel mean − channel distance.
Short: High > channel mean + outer channel distance AND close < channel mean + channel distance.
Long: Close > current equilibrium AND previous close <= current equilibrium AND close < premium level.
Short: Close < current equilibrium AND previous close >= current equilibrium AND close > discount level.