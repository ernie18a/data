Calculation: Smoothed bull power = a configurable moving average of high minus a separately configured moving average of a configurable OHLC-derived price.
Calculation: Bull power gap = smoothed bull power calculated with open as the price on the current bar minus smoothed bull power calculated with close as the price on the previous bar; the two calculations use identical moving-average methods and parameters.
Calculation: Expert gap = bull power gap calculated on a configurable higher or lower timeframe, using the last completed bar by default or the still-forming bar if configured.
Long: Smoothed bull power on the chart timeframe > its previous-bar value.
Short: Smoothed bull power on the chart timeframe < its previous-bar value.
Long: Bull power gap on the chart timeframe > 0.
Short: Bull power gap on the chart timeframe < 0.
Long: Expert gap > 0 AND expert gap on the preceding indicator bar <= 0.
Short: Expert gap < 0 AND expert gap on the preceding indicator bar >= 0.
Exit: long, expert gap < 0 OR low <= entry price minus the configured stop distance OR high >= entry price plus the configured profit-target distance.
Exit: short, expert gap > 0 OR high >= entry price plus the configured stop distance OR low <= entry price minus the configured profit-target distance.