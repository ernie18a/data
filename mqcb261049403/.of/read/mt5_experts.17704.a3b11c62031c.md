Calculation: Bullish pattern = for three consecutive bars A, B, C in chronological order, open[A] > close[A] AND open[B] > close[B] AND close[B] > low[A] AND open[C] < close[C] AND close[C] > open[B].
Calculation: Bearish pattern = for three consecutive bars A, B, C in chronological order, open[A] < close[A] AND open[B] < close[B] AND close[B] < high[A] AND open[C] > close[C] AND close[C] < open[B].
Calculation: Volume test = volume[A] < volume[B] OR volume[C] > volume[B] OR volume[C] > volume[A].
Calculation: Qualified pattern = a bullish or bearish pattern AND (high[A] - low[A] > configured range threshold OR volume filtering is disabled OR volume test). The pattern uses the three bars immediately preceding the signal bar.
Calculation: Trading signal = direction of the qualified pattern on the selected indicator-timeframe signal bar. The indicator timeframe may be higher or lower than the chart timeframe; the selected signal bar may be the last completed bar, a bar still forming, or an earlier bar.
Calculation: Latest trading signal = the most recent nonempty trading signal at or before the selected indicator-timeframe signal bar.
Long: Trading signal = bullish.
Long: On the selected chart-timeframe signal bar, qualified pattern = absent.
Short: Trading signal = bearish.
Exit: long, latest trading signal = bearish.
Exit: short, latest trading signal = bullish.
Exit: long, low <= entry price - configured stop distance OR high >= entry price + configured profit distance.
Exit: short, high >= entry price + configured stop distance OR low <= entry price - configured profit distance.