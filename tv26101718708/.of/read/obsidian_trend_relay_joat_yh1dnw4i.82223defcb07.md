Calculation: Source = a selected price series derived from the available bar fields; use the same source for all EMAs.
Calculation: Zero-lag EMA = 2 × EMA(source, length) − EMA(EMA(source, length), length).
Calculation: Ribbon = four EMAs of the source with successively longer lengths, called fast, mid, slow, and base. The higher-timeframe fast and slow EMAs and zero-lag EMA use the corresponding chart-timeframe lengths.
Calculation: Local bullish state = close > SuperTrend AND zero-lag EMA > slow EMA AND fast EMA > mid EMA > slow EMA > base EMA AND zero-lag EMA > its previous value AND fast EMA > its previous value. Local bearish state reverses every inequality.
Calculation: Higher-timeframe bullish state = zero-lag EMA > slow EMA AND fast EMA > slow EMA AND zero-lag EMA > fast EMA, calculated separately on each of three higher timeframes. The bearish state reverses every inequality. With lookahead off, historical chart bars use the last completed higher-timeframe bar until the higher-timeframe bar closes; realtime chart bars use the higher-timeframe bar still forming.
Calculation: Vote total = sum of seven votes: local state; each of the three higher-timeframe states; close compared with SuperTrend; ribbon stacking; and zero-lag EMA slope combined with close compared with zero-lag EMA. Each vote is +1 for its bullish condition, −1 for its bearish condition, and otherwise 0. The final vote is bullish when zero-lag EMA > its previous value AND close > zero-lag EMA, and bearish when both inequalities reverse.
Calculation: Confluence score = clamp(50 + 8 × vote total + 5 × clamp((zero-lag EMA − slow EMA) / ATR, −1, 1), 0, 100). ATR uses the risk lookback.
Calculation: Prediction bias = clamp((predicted zero-lag EMA − zero-lag EMA) / ATR, −1, 1), where predicted zero-lag EMA = zero-lag EMA + smoothed velocity + half the change in smoothed velocity; velocity is the change in zero-lag EMA and smoothed velocity is its EMA over a separate prediction lookback. Missing previous values are replaced by the current value.
Calculation: Relay pressure = clamp(0.55 × clamp((close − zero-lag EMA) / ATR, −1, 1) + 0.45 × prediction bias, −1, 1).
Calculation: Proximity score = max(clamp(1 − abs(close − zero-lag EMA) / (ATR × proximity multiplier), 0, 1), clamp(1 − abs(close − SuperTrend) / (ATR × proximity multiplier), 0, 1)).
Calculation: Ladder levels = on each confirmed bullish or bearish relay or reclaim, reset the ladder using that bar's close as entry. The risk anchor is the average of zero-lag EMA and SuperTrend. If the vote total meets the positive regime threshold, active stop = risk anchor − ATR × stop multiplier; if it meets the negative regime threshold, active stop = risk anchor + ATR × stop multiplier; otherwise there is no active stop. For a long ladder, stop = min(active stop if present, otherwise entry-bar low − ATR × stop multiplier; entry-bar low − ATR × stop buffer). For a short ladder, stop = max(active stop if present, otherwise entry-bar high + ATR × stop multiplier; entry-bar high + ATR × stop buffer). Ladder risk = max(abs(entry − stop), ATR × minimum-risk multiplier). The final target is entry plus ladder risk × final-target multiplier for a long ladder, and entry minus that amount for a short ladder. Freeze these levels at the reset; a new relay or reclaim replaces the previous ladder before checking hits, and a stop or final-target hit makes the ladder inactive.
Long: On a confirmed chart bar, vote total ≥ minimum confluence votes AND vote total > 0.
Short: On a confirmed chart bar, vote total ≤ −minimum confluence votes AND vote total < 0.
Long: On a confirmed chart bar, vote total ≥ minimum confluence votes AND vote total > 0 AND close > zero-lag EMA AND close > SuperTrend AND fast EMA > mid EMA > slow EMA > base EMA.
Short: On a confirmed chart bar, vote total ≤ −minimum confluence votes AND vote total < 0 AND close < zero-lag EMA AND close < SuperTrend AND fast EMA < mid EMA < slow EMA < base EMA.
Long: On a confirmed chart bar, close crosses above zero-lag EMA AND vote total ≥ minimum confluence votes − 1.
Short: On a confirmed chart bar, close crosses below zero-lag EMA AND vote total ≤ −(minimum confluence votes − 1).
Long: On a confirmed chart bar, proximity score > proximity threshold AND vote total > 0 AND close ≥ zero-lag EMA.
Short: On a confirmed chart bar, proximity score > proximity threshold AND vote total < 0 AND close ≤ zero-lag EMA.
Long: Close ≥ SuperTrend.
Short: Close < SuperTrend.
Long: Fast EMA > mid EMA > slow EMA > base EMA.
Short: Fast EMA < mid EMA < slow EMA < base EMA.
Long: Any higher-timeframe bullish state holds.
Short: Any higher-timeframe bearish state holds.
Long: Relay pressure > positive relay-pressure threshold.
Short: Relay pressure < negative relay-pressure threshold.
Long: Prediction bias ≥ 0.
Short: Prediction bias < 0.
Long: Confluence score ≥ bullish confluence-score threshold.
Short: Confluence score < bearish confluence-score threshold.
Exit: long, the long ladder is active AND on a confirmed chart bar high ≥ its final target OR low ≤ its stop.
Exit: short, the short ladder is active AND on a confirmed chart bar low ≤ its final target OR high ≥ its stop.