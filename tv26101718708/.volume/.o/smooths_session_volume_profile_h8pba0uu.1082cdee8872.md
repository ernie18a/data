Calculation: Buy/sell volume by price = split each bar’s volume using the selected source: geometric split by close position within the bar (50/50 if flat), lower-timeframe up/down volume, or native footprint buy/sell volume. For profile levels, distribute each side’s volume within each bar’s high-low range as a truncated normal: buy center halfway from low to close, sell center halfway from close to high, and standard deviation equal to bar range divided by a concentration parameter; sum across included bars.
Long: At a price level, buy volume > sell volume at the immediately lower level × imbalance threshold; for profile or recent-window aggregate markings, only the first such imbalanced level above or below that aggregate’s point of control is marked.
Short: At a price level, sell volume > buy volume at the immediately higher level × imbalance threshold; for profile or recent-window aggregate markings, only the first such imbalanced level above or below that aggregate’s point of control is marked.
Long: Profile overlap < 0.75 AND buy volume share exceeds sell volume share by at least a tilt threshold.
Short: Profile overlap < 0.75 AND sell volume share exceeds buy volume share by at least a tilt threshold.
Long: Buy volume at the profile point of control > sell volume there.
Short: Sell volume at the profile point of control > buy volume there.
Long: Close >= open.
Short: Close < open.
Long: Close > previous bar close.
Short: Close < previous bar close.