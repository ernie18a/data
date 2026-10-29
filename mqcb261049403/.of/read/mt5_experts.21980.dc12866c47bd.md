Calculation: Histogram = moving average of CCI of the selected price multiplied by volume; calculate on a configurable higher or lower timeframe, using the last completed bar and preceding bars.
Calculation: Histogram direction = up when the histogram is greater than its preceding value, down when it is less, and unchanged when equal.
Long: Histogram direction is up AND preceding histogram direction is down.
Short: Histogram direction is down AND preceding histogram direction is up.
Exit: long, histogram direction is down OR low <= entry price minus stop-loss distance OR high >= entry price plus take-profit distance.
Exit: short, histogram direction is up OR high >= entry price plus stop-loss distance OR low <= entry price minus take-profit distance.