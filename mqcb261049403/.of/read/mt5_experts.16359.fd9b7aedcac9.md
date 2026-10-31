Calculation: Volume-weighted price = sum(volume × weighted close) / max(sum(volume), 1) over a configurable lookback, including the current bar; weighted close = (high + low + 2 × close) / 4.
Calculation: Normalized price = 100 × (volume-weighted price − rolling minimum of volume-weighted price) / max(rolling maximum − rolling minimum, minimum price increment) − 50; extrema use a configurable lookback including the current bar.
Calculation: First line = SMA of normalized price; second line = SMA of the first line using the same smoothing lookback.
Calculation: Strong bullish state = first line > second line AND (first line > upper threshold OR (first line > lower threshold AND second line <= lower threshold)).
Calculation: Strong bearish state = first line <= second line AND (first line < lower threshold OR (second line > upper threshold AND first line <= upper threshold)).
Long: First line > second line on the chart bar.
Short: First line <= second line on the chart bar.
Long: Strong bullish state on the last completed bar of a configurable higher or lower timeframe AND strong bullish state is false on its preceding bar.
Short: Strong bearish state on the last completed bar of a configurable higher or lower timeframe AND strong bearish state is false on its preceding bar.
Exit: long, first line <= second line on the last completed bar of a configurable higher or lower timeframe.
Exit: short, first line > second line on the last completed bar of a configurable higher or lower timeframe.
Exit: long, low <= entry price − stop distance OR high >= entry price + profit distance.
Exit: short, high >= entry price + stop distance OR low <= entry price − profit distance.