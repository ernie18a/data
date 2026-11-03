Calculation: Standardized net-delta z-score = robust median/MAD z-score of chart-timeframe buy volume minus sell volume, reconstructed from lower-timeframe intrabars; cap at −4 and +4.
Calculation: Higher-timeframe flow z-score = robust median/MAD z-score of volume-weighted candle-geometry buying pressure; use the current chart bar’s available value from each higher timeframe, based on its last completed bar historically and its forming bar live. Use the same lookback for each rung.
Calculation: Session cumulative delta = running sum of net delta, reset at each new session.
Calculation: CVD channel = linear regression of session cumulative delta plus/minus a multiple of the residual standard deviation.
Calculation: Absorption consensus = at least the configured number of these four tests: absolute price-change regression-residual z exceeds its threshold; net-delta-per-price-tick percentile exceeds its threshold; flow dominance exceeds price-result strength by its threshold; volume percentile is high while range percentile is low. Its side is the larger of buying dominance minus buying result and selling dominance minus selling result.
Calculation: ATR trailing stop = a volatility stop that trails the selected price source by a multiple of ATR, ratchets with the current trend, and flips trend when price crosses it.
Calculation: Trade stop and target 2 = at signal close, use the onside ATR trailing stop as stop when enabled; otherwise use the configured ATR stop distance. Target 2 is the configured multiple of the ATR target distance from entry.
Long: Standardized net-delta z-score crosses above the positive signal threshold AND the configured regime gate passes AND (the chart-timeframe pressure signal is not MTF-gated OR MTF alignment is positive).
Long: MTF alignment reaches the positive alignment threshold AND the highest two active higher-timeframe flow z-scores are nonnegative when that filter is enabled AND the optional flow-velocity filter passes AND fused conviction reaches its threshold AND this is a newly armed alignment episode AND cooldown has elapsed AND (CVD-channel gating is off OR a same-direction channel breakout occurred within its window) AND flow-toxicity suppression passes AND the side is not muted by the optional edge gate.
Long: On an active timeframe in the optional MTF stack, its flow z-score is above the positive neutral threshold and its prior value was not above that threshold.
Long: The fast EMA of standardized net delta crosses above its slower EMA.
Long: Session cumulative delta remains above the upper CVD channel for the configured confirmation bars and the breakout is not already active and breakout cooldown has elapsed.
Long: Price forms a lower pivot low than the prior pivot low while session cumulative delta at the pivot forms a higher low.
Long: A VSA shakeout occurs: low is at or below the prior lookback low, close is in the top 35% of the bar range, and volume percentile is at least 60.
Long: A VSA stopping-volume bar occurs: close is below the prior close, range percentile is at least 60, volume percentile is at least 80, and close is in the upper 55% of the bar range.
Long: Absorption consensus is confirmed and buying dominance minus buying result exceeds selling dominance minus selling result.
Long: The ATR trailing stop flips from downtrend to uptrend.
Short: Standardized net-delta z-score crosses below the negative signal threshold AND the configured regime gate passes AND (the chart-timeframe pressure signal is not MTF-gated OR MTF alignment is negative).
Short: MTF alignment reaches the negative alignment threshold AND the highest two active higher-timeframe flow z-scores are nonpositive when that filter is enabled AND the optional flow-velocity filter passes AND fused conviction reaches its threshold AND this is a newly armed alignment episode AND cooldown has elapsed AND (CVD-channel gating is off OR a same-direction channel breakout occurred within its window) AND flow-toxicity suppression passes AND the side is not muted by the optional edge gate.
Short: On an active timeframe in the optional MTF stack, its flow z-score is below the negative neutral threshold and its prior value was not below that threshold.
Short: The fast EMA of standardized net delta crosses below its slower EMA.
Short: Session cumulative delta remains below the lower CVD channel for the configured confirmation bars and the breakout is not already active and breakout cooldown has elapsed.
Short: Price forms a higher pivot high than the prior pivot high while session cumulative delta at the pivot forms a lower high.
Short: A VSA upthrust occurs: high is at or above the prior lookback high, close is in the bottom 35% of the bar range, and volume percentile is at least 60.
Short: Standardized net-delta z-score is at or above its configured upper exhaustion percentile.
Short: Absorption consensus is confirmed and selling dominance minus selling result exceeds buying dominance minus buying result.
Short: The ATR trailing stop flips from uptrend to downtrend.
Exit: Long, low <= active trade stop OR high >= active trade target 2.
Exit: Short, high >= active trade stop OR low <= active trade target 2.