Calculation: Histogram = moving average of (100 × DeMarker − 50) × volume, using the same bar's volume and a selectable smoothing method.
Calculation: Direction = up when Histogram > its previous-bar value, down when Histogram < its previous-bar value, and otherwise the previous bar's Direction.
Long: Chart-timeframe Direction = up.
Short: Chart-timeframe Direction = down.
Long: Indicator-timeframe Direction = up AND previous indicator-bar Direction = down; use the last completed indicator bar or the bar still forming, with the indicator timeframe selectable as higher or lower than the chart timeframe.
Short: Indicator-timeframe Direction = down AND previous indicator-bar Direction = up; use the last completed indicator bar or the bar still forming, with the indicator timeframe selectable as higher or lower than the chart timeframe.
Exit: long, indicator-timeframe Direction = down using the selected completed or forming indicator bar OR low <= entry price − stop distance OR high >= entry price + profit-target distance.
Exit: short, indicator-timeframe Direction = up using the selected completed or forming indicator bar OR high >= entry price + stop distance OR low <= entry price − profit-target distance.