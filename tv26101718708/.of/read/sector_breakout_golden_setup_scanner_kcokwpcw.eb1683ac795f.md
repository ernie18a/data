Calculation: Relative strength = chart close divided by benchmark close on the same chart timeframe.
Calculation: Relative-strength new high = relative strength is at least 99.8% of its highest value over the lookback.
Calculation: Relative-strength slope = percentage change in relative strength over its lookback.
Calculation: Mansfield relative strength = (relative strength / its simple moving average − 1) × 100.
Calculation: Relative performance = percentage change in relative strength over the lookback; the 3-month lookback is longer than the 1-month lookback.
Calculation: Base pivot = highest high over the base lookback, excluding the current bar.
Calculation: Base support = lowest low over the base lookback, excluding the current bar.
Calculation: Base range = (base pivot − base support) / base support × 100.
Calculation: Contracting ATR = short-lookback ATR is less than long-lookback ATR multiplied by a contraction parameter; both use chart-timeframe bars.
Calculation: Valid base = contracting ATR AND base range is below a maximum AND close is below 1.005 × base pivot AND close is above 0.98 × base support.
Calculation: Stage-2 trend = close > short-term simple moving average AND short-term simple moving average > long-term simple moving average AND long-term simple moving average has risen over its lookback.
Calculation: Volume ratio = volume / its simple moving average.
Calculation: Pivot breakout = close crosses above base pivot adjusted by a configurable buffer; current close is above the adjusted pivot and prior close is at or below it.
Calculation: Golden score = 20 for relative-strength new high + 15 for relative-strength slope meeting its threshold + 10 for Mansfield relative strength meeting its threshold + 10 for relative performance over the shorter lookback being positive and greater than one third of positive relative performance over the longer lookback + 15 for valid base + 5 for contracting ATR + 10 for base range within its bounds + 10 for close-to-pivot distance within its bounds + 5 for Stage-2 trend when the trend filter is enabled; otherwise zero for each failed check.
Calculation: Golden pass count = count of these ten checks that pass: relative-strength new high; relative-strength slope threshold; Mansfield relative-strength threshold; accelerating relative performance; valid base; contracting ATR; base-range bounds; close-to-pivot distance bounds; volume check (passes automatically if the volume filter is disabled); Stage-2 trend (passes automatically if the trend filter is disabled).
Long: Relative-strength new high AND valid base AND close < base pivot AND relative-strength slope > 0 AND Mansfield relative strength > 0
Long: Pivot breakout AND relative-strength new high AND volume > its simple moving average × volume multiplier
Long: Pivot breakout AND relative-strength new high AND volume > its simple moving average × volume multiplier AND relative-strength slope > 0 AND Mansfield relative strength > 0 AND (trend filter disabled OR Stage-2 trend)
Long: All ten Golden checks pass AND golden score meets its threshold AND current bar passes while the prior bar did not
Long: Golden pass count >= 8 AND not all Golden checks pass AND (prior pass count is below 8 OR unavailable)
