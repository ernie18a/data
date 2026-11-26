Calculation: Classified buy and sell volume per parent bar = sum each lower-timeframe bar’s volume as all buy when close >= open and all sell otherwise in binary mode, or split it by clamp((close - low) / (high - low), 0, 1) in range-weighted mode, using the close/open rule when high = low; use native aggressor buy and sell volume for chart bars when available.
Calculation: Panel delta bias = (sum classified buy volume - sum classified sell volume) / sum classified buy and sell volume across stored panel bars, including the current forming bar; calculate T1 panel values on T1 bars and evaluate them on chart bars using the last completed T1 bars plus the current forming T1 bar.
Calculation: Panel toxicity = SMA(abs(buy volume - sell volume), toxicity lookback) / SMA(buy volume + sell volume, toxicity lookback), calculated on each panel’s bars and on chart bars for the chart panel.
Calculation: Structure bias = the latest direction of a close break above the latest confirmed PivotHigh(high, structure pivot lookback, structure pivot lookback) or below the latest confirmed PivotLow(low, structure pivot lookback, structure pivot lookback); retain that direction until another pivot break and discard each broken pivot. Calculate on chart bars and on T1 bars for each T1 panel, using the current forming bar.
Calculation: Panel probability = logistic(fusion gain * ((1 - structure weight) * panel delta bias + structure weight * structure bias) * agreement factor * toxicity factor), where agreement factor is one when structure bias is zero or agrees with delta bias and otherwise is the divergence discount; toxicity factor is one when toxicity scaling is disabled and otherwise is the toxicity conviction baseline plus the lesser of panel toxicity and its cap; use a neutral probability when delta is unavailable.
Calculation: Volatility vote = negative clamp(((volatility-index close - volatility-index close at the volatility lookback) / volatility-index close at the volatility lookback) * volatility sensitivity, negative vote limit, positive vote limit), using volatility-index bars at the chart timeframe, including the current forming bar.
Calculation: Combined probability = logistic(correlation discount * weighted mean of enabled panel log odds and, when enabled and available, volatility weight times fusion gain times volatility vote); use square-root timeframe duration as panel weights when timeframe weighting is enabled, otherwise equal panel weights.
Calculation: Reversion delta z-score = (cumulative sum of chart-bar classified buy volume minus sell volume over the reversion lookback - its SMA over three times that lookback) / its STDEV over three times that lookback, or zero when STDEV is zero.
Calculation: Reversion price position = (close - lowest low over the reversion lookback) / (highest high over the reversion lookback - lowest low over the reversion lookback), or the range midpoint when the range is zero.
Long: An enabled chart panel or T1 panel has panel probability above the probability midpoint.
Short: An enabled chart panel or T1 panel has panel probability below the probability midpoint.
Long: An enabled chart panel or T1 panel has panel probability above its bullish color threshold.
Short: An enabled chart panel or T1 panel has panel probability below its bearish color threshold.
Long: Combined probability is above the probability midpoint.
Short: Combined probability is below the probability midpoint.
Long: Combined probability exceeds the combined bullish bias threshold.
Short: Combined probability is below the combined bearish bias threshold.
Long: Combined probability exceeds the net bullish threshold.
Short: Combined probability is below the net bearish threshold.
Long: Structure bias is positive on the chart panel or an enabled T1 panel.
Short: Structure bias is negative on the chart panel or an enabled T1 panel.
Long: The volatility vote is positive.
Short: The volatility vote is negative.
Long: Reversion price position >= reversion extreme threshold AND reversion delta z-score > negative delta-confirm threshold AND (toxicity is not required OR chart-panel toxicity > SMA(chart-panel toxicity, twice the reversion lookback) * toxicity-spike multiplier).
Short: Reversion price position >= reversion extreme threshold from the range high AND reversion delta z-score < delta-confirm threshold AND (toxicity is not required OR chart-panel toxicity > SMA(chart-panel toxicity, twice the reversion lookback) * toxicity-spike multiplier).
Long: Reversion mode is selected AND the reversion long condition is true.
Short: Reversion mode is selected AND the reversion short condition is true.
Long: Reversion price position <= one minus the reversion extreme threshold AND reversion delta z-score > negative delta-confirm threshold AND NOT the prior bar’s corresponding bullish divergence condition.
Short: Reversion price position >= the reversion extreme threshold AND reversion delta z-score < delta-confirm threshold AND NOT the prior bar’s corresponding bearish divergence condition.
Long: A chart-panel structure shift changes structure bias to positive.
Short: A chart-panel structure shift changes structure bias to negative.
Long: The selected continuation signal changes to positive, with combined probability above the net bullish threshold.
Short: The selected continuation signal changes to negative, with combined probability below the net bearish threshold.