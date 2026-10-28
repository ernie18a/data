Calculation: Anchored VWAP = cumulative (hlc3 × volume) / cumulative volume, reset at the start of each selected session, week, or month; includes the current bar.
Calculation: VWAP-based MACD line = EMA of Anchored VWAP with a shorter lookback minus EMA of Anchored VWAP with a longer lookback.
Calculation: Signal line = EMA of the VWAP-based MACD line.
Calculation: Histogram = VWAP-based MACD line − Signal line.
Calculation: Relative volume = current volume / SMA of volume.
Calculation: Confirmed low/high pivot = a low/high that is the lowest/highest over the configured bars to its left and right; it is known after the right-side bars form. Compare its price and Histogram value at the pivot bar with those at the preceding confirmed pivot of the same kind.
Long: VWAP-based MACD line crosses above Signal line AND Relative volume ≥ 1.
Long: Confirmed low pivot price < preceding confirmed low pivot price AND Histogram at the confirmed low pivot > Histogram at the preceding confirmed low pivot.
Short: VWAP-based MACD line crosses below Signal line AND Relative volume ≥ 1.
Short: Confirmed high pivot price > preceding confirmed high pivot price AND Histogram at the confirmed high pivot < Histogram at the preceding confirmed high pivot.