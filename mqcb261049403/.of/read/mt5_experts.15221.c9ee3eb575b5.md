Calculation: Weighted dot = on the selected indicator timeframe, apply a configurable moving average to a configurable OHLC-derived price. Let its length be N, L = 5N − 1, t = 0, and for i = 0 through L − 1 set w[i] = cos(πt) times 1 if t ≤ 0.5, otherwise 1/(3πt + 1); after each weight, increase t by 1/(N − 2) if t < 1, otherwise by 7/(4N − 1) if t < L − 1. The dot is (1 + deviation/100) × sum(w[i] × moving average[i bars ago])/sum(w[i]). If the configurable filter distance is positive and the absolute difference between this dot and the cached dot of the next newer bar is less than that distance, replace this dot with that cached value. Use the cached value as it exists when the indicator is recalculated; uninitialized buffer values are zero.
Calculation: Dot direction = +1 when the dot exceeds the preceding bar's dot by more than the filter distance, −1 when the preceding bar's dot exceeds the dot by more than the filter distance, and otherwise the preceding direction; initialize to 0. Recalculate from older to newer bars, preserving the most recently calculated non-forming bar direction between updates. The indicator timeframe can be higher or lower than the chart timeframe; use the last completed indicator bar by default, or its still-forming bar when the signal-bar setting selects it. Earlier signal-bar settings use the corresponding older completed indicator bar.
Long: Dot direction = +1.
Short: Dot direction = −1.
Long: Dot direction = +1 AND preceding indicator bar's dot direction = −1 AND position side = flat.
Short: Dot direction = −1 AND preceding indicator bar's dot direction = +1 AND position side = flat.
Exit: long, dot direction = −1.
Exit: short, dot direction = +1.
Exit: long, stop-loss distance > 0 AND low ≤ entry price − stop-loss distance.
Exit: long, take-profit distance > 0 AND high ≥ entry price + take-profit distance.
Exit: short, stop-loss distance > 0 AND high ≥ entry price + stop-loss distance.
Exit: short, take-profit distance > 0 AND low ≤ entry price − take-profit distance.