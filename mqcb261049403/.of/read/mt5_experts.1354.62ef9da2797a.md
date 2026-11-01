Calculation: Bull measure = EMA of (3 × current high minus the sum of the highest highs over three lookbacks of increasing length, each excluding the current bar).
Calculation: Bear measure = EMA, with the same smoothing period as the bull measure, of (the sum of the lowest lows over the same three lookbacks, each excluding the current bar, minus 3 × current low).
Calculation: Signal measures = bull and bear measures on a configurable indicator timeframe, which may be higher or lower than the chart timeframe or equal to it; use a selected completed bar, or the still-forming bar if selected, and its immediately preceding bar.
Long: Chart-timeframe bull measure > chart-timeframe bear measure.
Short: Chart-timeframe bull measure < chart-timeframe bear measure.
Long: Signal bull measure > signal bear measure AND preceding signal bull measure <= preceding signal bear measure.
Short: Signal bull measure < signal bear measure AND preceding signal bull measure >= preceding signal bear measure.
Exit: short, signal bull measure > signal bear measure.
Exit: long, signal bull measure < signal bear measure.
Exit: long, low <= entry price − stop-loss distance OR high >= entry price + take-profit distance.
Exit: short, high >= entry price + stop-loss distance OR low <= entry price − take-profit distance.