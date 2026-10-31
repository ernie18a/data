Calculation: Positive and negative trend components = For each bar, let change be the change in the selected OHLC-derived price. Set positive change to -change when change > 0, otherwise 0; set negative change to change when change < 0, otherwise 0. Positive run equals positive change plus the previous positive run when change > 0, otherwise 0; negative run equals negative change plus the previous negative run when change < 0, otherwise 0. Over the same lookback, positive component is the sum of positive change minus the sum of negative run; negative component is the sum of negative change minus the sum of positive run. Apply the same T3 smoothing to each component. Calculate on the selected indicator timeframe, which may be higher or lower than the chart timeframe, using the last completed bar; alternatively use the still-forming bar when selected.
Long: Positive component < negative component
Short: Positive component > negative component
Long: Positive component < negative component AND previous indicator bar's positive component >= negative component
Short: Positive component > negative component AND previous indicator bar's positive component <= negative component
Exit: long, positive component > negative component
Exit: short, positive component < negative component
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance