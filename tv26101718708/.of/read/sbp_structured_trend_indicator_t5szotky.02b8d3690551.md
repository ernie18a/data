Calculation: Fast EMA = exponential moving average of close with a shorter lookback than the slow EMA
Calculation: Phase line = Hull moving average of (high + low + close) / 3
Calculation: Phase slope = phase line minus its value two bars earlier
Calculation: Phase distance = (close − phase line) / ATR
Calculation: Momentum delta = current minus prior value of the EMA of close-to-close change
Calculation: Directional pressure delta = current minus prior value of (positive DI − negative DI) / max(positive DI + negative DI, 1), using DMI
Calculation: Pressure index = clamp to [−1, 1] the smoothed difference between bullish and bearish candle pressure, divided by the highest absolute value of that difference over the normalization lookback
Calculation: Bullish candle pressure = smoothed bullish candle score; bearish candle pressure = smoothed bearish candle score. Each candle score combines body/range, close position within the range, wick imbalance in its direction, and range expansion over average range; only a candle in that direction contributes body/range, and only expansion above average contributes expansion
Calculation: Pressure delta = current minus prior pressure index
Calculation: Close position = (close − low) / max(high − low, minimum price increment), clamped to [0, 1]
Calculation: Body ratio = abs(close − open) / max(high − low, minimum price increment), clamped to [0, 1]
Calculation: Upper wick ratio = (high − max(open, close)) / max(high − low, minimum price increment); lower wick ratio = (min(open, close) − low) / max(high − low, minimum price increment)
Calculation: Relative volume = volume / its average over the volume reference lookback; if volume is unavailable or zero, use neutral volume confirmation
Calculation: Volume flow = EMA of (volume × (2 × close position − 1)) divided by the average absolute value of that quantity over the volume reference lookback, clamped to [−2, 2]; if volume is unavailable or its baseline is zero, use zero
Calculation: Volume confirmation = true when volume filtering is disabled, volume is unavailable, or relative volume meets its minimum and volume flow has the decision's direction
Calculation: Effort result = relative volume / max(abs(close − prior close) / ATR, minimum price progress)
Calculation: Directional effort confirmation = for the decision's direction, the bar closes in that direction, volume flow has that direction, and effort result is at most its maximum or body ratio meets its minimum; true when volume filtering is disabled or volume is unavailable
Calculation: Structure = bullish when fast EMA > slow EMA, close > phase line, and phase slope > 0; bearish when fast EMA < slow EMA, close < phase line, and phase slope < 0; otherwise neutral
Calculation: Directional evidence = sum of weighted confirmations: close on the decision's side of fast EMA and phase line, phase slope, momentum delta, directional pressure delta, pressure index, pressure delta, volume confirmation, directional effort confirmation, and a directional candle closing in the corresponding outer portion of its range
Calculation: Exhaustion score = count of: body smaller than its prior average body; phase slope magnitude below its minimum or declining; momentum delta weakening in the trend direction; directional pressure delta weakening in the trend direction; trend-side wick ratio meeting its minimum; and ADX meeting its minimum while not increasing
Calculation: Top setup = on a completed bar with bullish structure and a high at least as high as the highest prior high over the extreme lookback, store a top setup and its exhaustion score; while active, retain the maximum score, and expire after the setup lifetime
Calculation: Bottom setup = on a completed bar with bearish structure and a low at most as low as the lowest prior low over the extreme lookback, store a bottom setup and its exhaustion score; while active, retain the maximum score, and expire after the setup lifetime
Calculation: Armed top/bottom = corresponding active setup whose retained exhaustion score meets the required score
Calculation: Trend-long condition = bullish structure, phase distance meets its positive minimum, bullish evidence meets the entry threshold, and bullish evidence exceeds bearish evidence by the required margin
Calculation: Trend-short condition = bearish structure, phase distance meets its negative minimum, bearish evidence meets the entry threshold, and bearish evidence exceeds bullish evidence by the required margin
Calculation: Reversal-long condition = armed bottom, bullish candle, close > fast EMA, momentum delta > 0, and bullish evidence meets the reversal threshold
Calculation: Reversal-short condition = armed top, bearish candle, close < fast EMA, momentum delta < 0, and bearish evidence meets the reversal threshold
Long: bar is completed AND (trend-long condition OR reversal-long condition) AND neither trend-short nor reversal-short condition AND signal state is not long AND bullish evidence exceeds bearish evidence by the required switching margin
Short: bar is completed AND (trend-short condition OR reversal-short condition) AND neither trend-long nor reversal-long condition AND signal state is not short AND bearish evidence exceeds bullish evidence by the required switching margin