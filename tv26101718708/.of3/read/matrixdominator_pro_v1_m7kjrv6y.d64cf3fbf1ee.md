Calculation: Structure trend = bullish after close crosses above the latest confirmed Pivot High(high, swing length, swing length), bearish after close crosses below the latest confirmed Pivot Low(low, swing length, swing length), otherwise retain the prior trend.
Long: Structure trend is bullish.
Short: Structure trend is bearish.
Long: Close crosses above the latest confirmed Pivot High(high, swing length, swing length).
Short: Close crosses below the latest confirmed Pivot Low(low, swing length, swing length).
Calculation: Displacement = abs(close - open) > ATR(ATR length) × the selected mode's displacement multiplier.
Calculation: Strong displacement = abs(close - open) > ATR(ATR length) × the selected mode's displacement multiplier × strong-displacement factor.
Short: High exceeds the latest confirmed pivot high, close is below it, and displacement is true.
Long: Low falls below the latest confirmed pivot low, close is above it, and displacement is true.
Calculation: Smoothed signed candle delta = SMA(if high > low then ((close - low) - (high - close)) / (high - low) else zero, delta lookback).
Long: Smoothed signed candle delta exceeds the delta threshold.
Short: Smoothed signed candle delta is below the negative delta threshold.
Calculation: Range position = (close - lowest(low, range lookback)) / (highest(high, range lookback) - lowest(low, range lookback)); use the midpoint when the range is zero.
Long: Range position is below the discount boundary.
Short: Range position is above the premium boundary.
Calculation: HTF bias sum = sum across T1, T2, T3 of +1 when EMA(close, fast length, T, current bar) > EMA(close, slow length, T, current bar), -1 when lower, and zero when equal; use T4, T5, T6 on the long-range chart branch instead. Evaluate on chart bars using the current, still-forming bar of each T.
Long: HTF bias sum meets or exceeds the bullish quorum.
Short: HTF bias sum is at or below the negative bearish quorum.
Calculation: HTF alignment(side) = HTF filtering is disabled, or HTF bias is neutral, or HTF bias agrees with side.
Long: Bullish gap: low > high[gap lookback] and the gap meets the minimum ATR size, with displacement additionally required in strict mode and the size filter omitted in all-gaps mode.
Short: Bearish gap: high < low[gap lookback] and the gap meets the minimum ATR size, with displacement additionally required in strict mode and the size filter omitted in all-gaps mode.
Long: A qualifying bullish gap is drawn when gap display is enabled and a gap slot is available.
Short: A qualifying bearish gap is drawn when gap display is enabled and a gap slot is available.
Calculation: Regime ATR ratio = ATR(short regime lookback) / ATR(long regime lookback), or one when the long ATR is zero.
Calculation: HTF order-block zone(side) = a tracked, active, direction-matching zone containing close. On chart bars, use the current, still-forming bar of the selected HTF OB timeframe; use its prior opposite-colored candle's high-to-low range when its current candle body exceeds HTF ATR(HTF OB ATR length) × HTF displacement factor, capping zone height at chart ATR × HTF zone height cap. Invalidate on a close beyond the zone, and expire at the configured age limit.
Long: A new bullish HTF order block forms on the selected HTF branch while HTF OB zones are enabled and storage has capacity.
Short: A new bearish HTF order block forms on the selected HTF branch while HTF OB zones are enabled and storage has capacity.
Calculation: Order-block score(side) at formation = min(score cap, base score + sweep weight × matching valid sweep + factor weight × (matching qualifying gap + matching structure trend + (HTF filtering enabled AND HTF alignment(side)) + volume > SMA(volume, volume lookback) × volume multiplier + matching range zone + strong displacement + enabled matching candle direction on the first HTF + matching active HTF OB zone + matching signed-delta threshold)).
Calculation: Bullish order block = the prior bearish candle at impulse lookback plus one bar, when the current candle is bullish and displacement is true; zone bottom is that candle's low and zone top is capped at bottom + ATR(ATR length) × maximum OB height. Create only when OB display is enabled and OB storage has capacity.
Calculation: Bearish order block = the prior bullish candle at impulse lookback plus one bar, when the current candle is bearish and displacement is true; zone top is that candle's high and zone bottom is capped at top - ATR(ATR length) × maximum OB height. Create only when OB display is enabled and OB storage has capacity.
Long: Bullish order block forms.
Short: Bearish order block forms.
Long: An untriggered, unreclaimed bullish OB was invalidated by close below its bottom and is reclaimed by close above its top within the reclaim window while reclaim is enabled; add the reclaim score boost, capped at the score cap.
Short: An untriggered, unreclaimed bearish OB was invalidated by close above its top and is reclaimed by close below its bottom within the reclaim window while reclaim is enabled; add the reclaim score boost, capped at the score cap.
Calculation: Minimum OB score = the lesser of the configured minimum and the selected tight-mode cap in tight mode; otherwise use the configured minimum.
Long: A tracked, active, untriggered bullish OB has score at least the minimum OB score; low <= its midpoint; close > its bottom; structure trend is bullish; the session filter passes (session filtering disabled, long-range chart branch, or current New York time within an enabled session); HTF alignment(long) is true; and compression blocking is disabled or the regime ATR ratio is at least the compression threshold. An OB becomes inactive on close below its bottom or age beyond its limit, is removed when ATR is positive and abs(close - midpoint) exceeds ATR × maximum OB distance, and can be reclaimed as specified above.
Short: A tracked, active, untriggered bearish OB has score at least the minimum OB score; high >= its midpoint; close < its top; structure trend is bearish; the session filter passes (session filtering disabled, long-range chart branch, or current New York time within an enabled session); HTF alignment(short) is true; and compression blocking is disabled or the regime ATR ratio is at least the compression threshold. An OB becomes inactive on close above its top or age beyond its limit, is removed when ATR is positive and abs(close - midpoint) exceeds ATR × maximum OB distance, and can be reclaimed as specified above.
Long: Range position is below the discount boundary, structure trend is bullish, and the range is positive.
Short: Range position is above the premium boundary, structure trend is bearish, and the range is positive.
Long: Range position is between the golden-zone lower and upper boundaries, structure trend is bullish, close < previous close, and the range is positive.
Short: Range position is between the golden-zone lower and upper boundaries, structure trend is bearish, close > previous close, and the range is positive.