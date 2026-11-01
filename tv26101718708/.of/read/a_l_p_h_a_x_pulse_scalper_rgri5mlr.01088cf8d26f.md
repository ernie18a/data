Calculation: Momentum = linear regression, evaluated at the current bar, of close minus the average of (the midpoint of the highest high and lowest low over the momentum lookback) and (the SMA of close over the same lookback).
Calculation: Volume delta = EMA of estimated bull volume minus EMA of estimated bear volume, using the same smoothing period. Estimated bull volume = volume × (close − low) / (high − low), or half of volume when high = low; estimated bear volume = volume − estimated bull volume. Smoothed volume delta = EMA of volume delta with a separate smoothing period. OBV change = current OBV minus OBV at the volume-slope lookback.
Calculation: Squeeze = Bollinger upper band < Keltner upper band AND Bollinger lower band > Keltner lower band, where Bollinger bands use SMA and standard deviation of close, and Keltner bands use EMA of close and ATR.
Calculation: Session VWAP = volume-weighted average of (high + low + close) / 3, anchored at the first bar of the exchange session. VWAP deviation = its session-anchored volume-weighted standard deviation.
Calculation: Bull score = count of satisfied conditions among: shortest-period close EMA > intermediate-period close EMA > longest-period close EMA AND close > shortest-period EMA; momentum > 0 AND momentum > previous momentum; volume delta > 0 AND smoothed volume delta > 0 AND OBV change > 0; VWAP filter disabled OR close > session VWAP AND close < session VWAP + outer-band multiplier × VWAP deviation. Bear score = count of satisfied conditions among the corresponding inverse comparisons, with close > lower VWAP band. When the VWAP filter is disabled, it contributes a point to both scores.
Calculation: Bull entry gate = bull score >= confluence threshold AND (ADX filter disabled OR ADX >= threshold) AND (session filter disabled OR bar time is within the configured exchange-time session). Bear entry gate = the same gate using bear score. Each new entry signal resets the tracked position and its entry-bar levels, even if a position is already open; if both signals occur on the same bar, the short position takes precedence.
Calculation: Long fixed stop = entry-bar low − entry-bar ATR × stop multiplier; short fixed stop = entry-bar high + entry-bar ATR × stop multiplier. Long targets = entry price + entry-bar ATR × target multiplier; short targets = entry price − entry-bar ATR × target multiplier. The full-target multiplier is greater than the partial-target multiplier.
Calculation: Long trailing stop = maximum of entry-bar low − entry-bar ATR × trailing multiplier and each subsequent bar's low − current ATR × trailing multiplier. Short trailing stop = minimum of entry-bar high + entry-bar ATR × trailing multiplier and each subsequent bar's high + current ATR × trailing multiplier. Update the trailing stop before evaluating exits.
Long: Shortest-period close EMA > intermediate-period close EMA AND intermediate-period close EMA > longest-period close EMA AND close > shortest-period close EMA.
Short: Shortest-period close EMA < intermediate-period close EMA AND intermediate-period close EMA < longest-period close EMA AND close < shortest-period close EMA.
Long: Squeeze is false AND momentum > 0 AND momentum > previous momentum.
Short: Squeeze is false AND momentum < 0 AND momentum < previous momentum.
Long: Volume delta > 0 AND smoothed volume delta > 0 AND OBV change > 0.
Short: Volume delta < 0 AND smoothed volume delta < 0 AND OBV change < 0.
Long: VWAP filter disabled OR (close > session VWAP AND close < session VWAP + outer-band multiplier × VWAP deviation).
Short: VWAP filter enabled AND close < session VWAP AND close > session VWAP − outer-band multiplier × VWAP deviation.
Long: Bull score >= confluence threshold.
Short: Bear score >= confluence threshold.
Long: Bull entry gate is true AND previous bar's bull entry gate is false.
Short: Bear entry gate is true AND previous bar's bear entry gate is false.
Exit: long, bars since entry > 0 AND high >= long partial target AND high < long full target; exit half the position.
Exit: short, bars since entry > 0 AND low <= short partial target AND low > short full target; exit half the position.
Exit: long, bars since entry > 0 AND (low <= long fixed stop OR high >= long full target OR (trailing stop enabled AND bars since entry > 1 AND low <= long trailing stop)).
Exit: short, bars since entry > 0 AND (high >= short fixed stop OR low <= short full target OR (trailing stop enabled AND bars since entry > 1 AND high >= short trailing stop)).