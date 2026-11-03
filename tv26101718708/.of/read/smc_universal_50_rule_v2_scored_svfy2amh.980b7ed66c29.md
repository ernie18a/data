Calculation: Anchor high and anchor low = the most recently reported pivot high and pivot low of the higher-timeframe bars, each confirmed using its configured number of bars on both sides. Historical higher-timeframe pivot results are mapped to the start of their confirmation bar; in realtime use the still-forming higher-timeframe bar. Retain each last reported pivot until replaced.
Calculation: Midpoint = (anchor high + anchor low) / 2.
Calculation: At a level = absolute distance from close to that level is at most a configured multiple of chart-timeframe ATR; use zero for unavailable ATR.
Calculation: Zone delta = sum of volume signed positive when close > open, negative when close < open, and zero otherwise, over consecutive chart bars whose close is within a configured percentage of close from any of anchor high, anchor low, or midpoint; reset to zero outside all three zones.
Calculation: Volume average = chart-timeframe SMA of volume, or current volume while the SMA is unavailable.
Calculation: Bullish engulfing = close > open AND previous close < previous open AND current body is larger than previous body AND either open < previous close AND close > previous open, or, in the configured loose mode, open <= previous close AND close >= previous open AND at least one of those inequalities is strict.
Calculation: Bearish engulfing = close < open AND previous close > previous open AND current body is larger than previous body AND either open > previous close AND close < previous open, or, in the configured loose mode, open >= previous close AND close <= previous open AND at least one of those inequalities is strict.
Calculation: High sweep = high > anchor high AND open < anchor high AND close < anchor high.
Calculation: Low sweep = high sweep is false AND low < anchor low AND open > anchor low AND close > anchor low.
Calculation: Midpoint high sweep = high sweep is false AND low sweep is false AND high > midpoint AND open < midpoint AND close < midpoint AND previous close < previous midpoint.
Calculation: Midpoint low sweep = high sweep is false AND low sweep is false AND midpoint high sweep is false AND low < midpoint AND open > midpoint AND close > midpoint AND previous close > previous midpoint.
Calculation: Bullish absorption = volume > volume average multiplied by an absorption threshold AND (min(open, close) - low) / (high - low) >= a configured wick fraction AND (at anchor low OR at midpoint AND previous close < previous midpoint); a zero-range bar cannot qualify.
Calculation: Bearish absorption = volume > volume average multiplied by an absorption threshold AND (high - max(open, close)) / (high - low) >= a configured wick fraction AND (at anchor high OR at midpoint AND previous close > previous midpoint); a zero-range bar cannot qualify.
Long: close < midpoint.
Short: close > midpoint.
Long: low sweep OR midpoint low sweep.
Short: high sweep OR midpoint high sweep.
Long: bullish engulfing AND at anchor high, anchor low, or midpoint.
Short: bearish engulfing AND at anchor high, anchor low, or midpoint.
Long: bullish absorption.
Short: bearish absorption.
Long: close is within a configured percentage of close from any of anchor high, anchor low, or midpoint AND zone delta > volume average multiplied by a configured significance threshold AND bullish absorption is false AND bearish absorption is false.
Short: close is within a configured percentage of close from any of anchor high, anchor low, or midpoint AND zone delta < negative volume average multiplied by a configured significance threshold AND bullish absorption is false AND bearish absorption is false.
Long: close crosses above its EMA AND volume > volume SMA multiplied by a configured threshold.
Short: close crosses below its EMA AND volume > volume SMA multiplied by a configured threshold.