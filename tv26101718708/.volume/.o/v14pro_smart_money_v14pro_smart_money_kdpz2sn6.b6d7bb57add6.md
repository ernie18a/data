Calculation: Normalized price = (close − lowest low over N bars) / (highest high over N bars − lowest low over N bars)
Calculation: Normalized volatility = standard deviation of normalized price over 14 bars
Calculation: Upper and lower measures = (highest-bars offset and lowest-bars offset, respectively, of normalized volatility over L+1 bars, plus L) / L
Calculation: Channel duration = max(1, bars since lower measure crossed above upper measure)
Calculation: Channel bounds = highest high and lowest low over the channel duration; create an active channel when upper measure crosses above lower measure and channel duration > 10, provided overlap is enabled or the new bounds do not intersect any active channel. Keep each channel active until a breakout removes it.
Calculation: Breakout price = (open + close) / 2 when strong-close mode is enabled; otherwise close
Long: An active channel exists AND breakout price > its upper bound
Short: An active channel exists AND breakout price < its lower bound