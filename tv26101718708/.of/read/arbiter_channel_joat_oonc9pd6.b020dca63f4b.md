Calculation: Composite baseline = EMA of the weighted average of enabled components: short-lookback Donchian midpoint, longer-lookback Donchian midpoint, their average, longest-lookback Donchian midpoint, and close; use close if the total enabled weight is zero.
Calculation: Channel width = maximum of a configurable minimum price width and the EMA of (ATR multiplied by a coefficient + EMA of absolute candle body multiplied by another coefficient). Outer bands are the composite baseline plus or minus channel width; inner bands are the baseline plus or minus channel width multiplied by a configurable ratio.
Calculation: Compression = absolute candle body <= its EMA multiplied by a coefficient AND high minus low <= its EMA multiplied by a coefficient AND ATR <= its EMA multiplied by a coefficient.
Calculation: Trend state = initially neutral; on each completed bar, set bullish if close > upper outer band AND either slope agreement is disabled or the baseline > its value a configurable number of bars ago; otherwise set bearish if close < lower outer band AND either slope agreement is disabled or the baseline < its value that many bars ago; otherwise set neutral if compression neutralization is enabled AND compression is true AND close is strictly between the inner bands; otherwise retain the previous state.
Long: Trend state = bullish
Long: Close > upper outer band
Long: Composite baseline > its value a configurable number of bars ago
Short: Trend state = bearish
Short: Close < lower outer band
Short: Composite baseline < its value a configurable number of bars ago