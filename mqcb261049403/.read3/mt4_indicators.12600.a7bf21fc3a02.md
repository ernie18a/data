Calculation: overlaid spread = close - parameter1 × close of another instrument at the matching chart-bar datetime
Calculation: chart spread = close - parameter2 × close of another instrument at the matching chart-bar datetime
Long: overlaid spread >= close OR (chart spread != 0 AND chart spread one chart bar ago != 0 AND chart spread >= chart spread one chart bar ago)
Short: (overlaid spread < close AND overlaid spread != 0) OR (chart spread != 0 AND chart spread one chart bar ago != 0 AND chart spread < chart spread one chart bar ago)