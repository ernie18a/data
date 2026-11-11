Calculation: Range = max(high - low, minimum price increment).
Calculation: Relative volume = volume / SMA(volume) when SMA(volume) > 0, otherwise 0.
Calculation: Lower wick share = (min(open, close) - low) / Range; upper wick share = (high - max(open, close)) / Range.
Calculation: VWAP deviation = standard deviation of close - session VWAP of (high + low + close) / 3. Lower band = VWAP - VWAP deviation multiplier × VWAP deviation; upper band = VWAP + VWAP deviation multiplier × VWAP deviation.
Calculation: Delta pressure = 100 × EMA(volume × (2 × close - low - high) / Range / max(SMA(volume), 1)); its volume SMA uses the relative-volume lookback.
Calculation: Confirmed pivot low/high = most recent low/high confirmed as a pivot using equal numbers of bars before and after the pivot; update it on the confirmation bar before testing for a sweep.
Calculation: Opening-range low/high = minimum low / maximum high within the configured opening session, available from the first bar after that session until the next opening session starts. Opening-range sweeps are available only when opening-range tracking is enabled.
Calculation: Bullish sweep = low < confirmed pivot low AND close > confirmed pivot low, OR low < available opening-range low AND close > opening-range low. Bearish sweep = high > confirmed pivot high AND close < confirmed pivot high, OR high > available opening-range high AND close < opening-range high.
Calculation: Bullish sweep level = opening-range low if its sweep condition is true, otherwise confirmed pivot low. Bearish sweep level = opening-range high if its sweep condition is true, otherwise confirmed pivot high.
Calculation: Clamp(x, a, b) = max(a, min(b, x)). Bullish depth = clamp((bullish sweep level - low) / max(ATR, minimum price increment), 0, 1.5) / 1.5; bearish depth = clamp((high - bearish sweep level) / max(ATR, minimum price increment), 0, 1.5) / 1.5. Missing sweep levels give depth 0.
Calculation: Volume score = clamp((relative volume - 1) / 1.75, 0, 1). Bullish VWAP score = clamp((VWAP - low) / max(VWAP deviation, minimum price increment), 0, 1) if close < VWAP, otherwise 0.35. Bearish VWAP score = clamp((high - VWAP) / max(VWAP deviation, minimum price increment), 0, 1) if close > VWAP, otherwise 0.35.
Calculation: Bullish trend score = 0.75 if shorter EMA(close) > longer EMA(close), 0.35 if shorter EMA(close) < longer EMA(close), otherwise 0.55. Bearish trend score = 0.75 if shorter EMA(close) < longer EMA(close), 0.35 if shorter EMA(close) > longer EMA(close), otherwise 0.55.
Calculation: Bullish score = 22 × bullish depth + 24 × lower wick share + 18 × volume score + 16 × bullish VWAP score + 12 if delta pressure > previous delta pressure AND delta pressure > -15, otherwise 0, + 8 × bullish trend score. Bearish score = 22 × bearish depth + 24 × upper wick share + 18 × volume score + 16 × bearish VWAP score + 12 if delta pressure < previous delta pressure AND delta pressure < 15, otherwise 0, + 8 × bearish trend score. The conditional 12-or-0 term is added to the other terms.
Calculation: Cooldown passes if no prior bullish or bearish trap has occurred, or the number of bars since the most recent trap of either direction is greater than the cooldown parameter. Evaluate both directions before updating the most recent trap bar.
Calculation: Bullish trap = bullish sweep AND lower wick share >= minimum wick share AND relative volume >= minimum relative volume AND (VWAP context disabled OR low <= lower band OR close > lower band OR close < VWAP) AND bullish score >= score threshold AND cooldown passes. Bearish trap = bearish sweep AND upper wick share >= minimum wick share AND relative volume >= minimum relative volume AND (VWAP context disabled OR high >= upper band OR close < upper band OR close > VWAP) AND bearish score >= score threshold AND cooldown passes.
Long: Bullish trap.
Short: Bearish trap.
Long: Shorter EMA(close) > longer EMA(close).
Short: Shorter EMA(close) < longer EMA(close).
Long: Delta pressure >= 0.
Short: Delta pressure < 0.
Long: Bullish trap is false AND bearish trap is false AND delta pressure > bullish pressure threshold.
Short: Bullish trap is false AND bearish trap is false AND delta pressure < bearish pressure threshold.