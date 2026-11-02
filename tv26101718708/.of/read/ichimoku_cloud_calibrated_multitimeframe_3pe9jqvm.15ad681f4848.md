Calculation: Price source = a selected series derived from the chart bar's open, high, low and close.
Calculation: Ichimoku lines = use either fixed lookbacks or lookbacks derived from the Ehlers homodyne dominant cycle of chart-bar midpoint price: the base lookback is the rounded, bounded cycle times a multiplier; the conversion lookback is the rounded, bounded base lookback divided by a factor; the span B lookback is the rounded, bounded base lookback times a factor. The conversion lookback is shorter than the base lookback, which is shorter than the span B lookback. Bound every rolling high/low lookback. Conversion and base lines are the midpoints of their respective rolling high-low ranges; span A is their average; span B is the midpoint of its rolling high-low range. The current cloud consists of spans A and B from the displacement lookback.
Calculation: Structure state = initially neutral. Confirm swing highs and lows using equal numbers of bars on each side. Track the latest confirmed high and low, each breakable once; a new confirmed pivot resets its corresponding break flag. A close above the latest unbroken high sets the state bullish; a close below the latest unbroken low sets it bearish. Process the high break before the low break if both occur on the same bar.
Long: Price source > both current cloud spans.
Short: Price source < both current cloud spans.
Long: Conversion line > base line.
Short: Conversion line <= base line.
Long: Price source > price source at the displacement lookback, substituting current price source if unavailable.
Short: Price source <= price source at the displacement lookback, substituting current price source if unavailable.
Long: Current cloud span A >= current cloud span B.
Short: Current cloud span A < current cloud span B.
Long: Undisplaced span A >= undisplaced span B.
Short: Undisplaced span A < undisplaced span B.
Long: Structure state = bullish.
Short: Structure state = bearish.