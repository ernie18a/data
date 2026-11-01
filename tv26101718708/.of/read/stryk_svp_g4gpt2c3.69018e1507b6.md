Calculation: Signed volume = sum over completed lower-timeframe bars within the chart bar of volume when close > open, -volume when close < open, and 0 when close = open; if lower-timeframe data is unavailable, use the chart bar's signed volume by the same rule.
Calculation: Volume profile = aggregate volume into price bins over a selected period. Round prices to the nearest bin center; either distribute each completed lower-timeframe bar's volume equally among bins from its low through high, subject to a maximum bin count, or assign it to the bin of its close, HLC3, or OHLC4. If lower-timeframe data is unavailable, use the chart bar instead. The point of control is the lowest-priced bin with maximum volume. Starting there, expand the value area one adjacent bin at a time toward the side with more volume, choosing the upper side on a tie and counting empty bins as zero, until the selected fraction of total volume is included. The value-area boundaries are the outer edges of the selected bins.
Calculation: Reference profile = either the last completed session profile, the forming session profile through the current chart bar, the last completed higher-timeframe candle's profile, or a composite profile of a lookback of completed higher-timeframe candles. Historical chart bars use the last completed session when the forming session is selected as the reference.
Calculation: Forming higher-timeframe delta = sum of chart-bar signed volume in the still-forming higher-timeframe bar through the current chart bar.
Calculation: Session up-volume share = sum, since the start of the forming session through the current chart bar, of (lower-timeframe volume + signed volume) / 2, divided by the sum of chart-bar volume. If lower-timeframe data is unavailable for a chart bar, its up-volume is its volume when close > open and 0 otherwise.
Long: Forming higher-timeframe delta > 0
Short: Forming higher-timeframe delta < 0
Long: Signed volume > 0
Short: Signed volume < 0
Long: close > reference profile value-area high
Short: close < reference profile value-area low
Long: close > reference profile point of control
Short: close < reference profile point of control
Long: session up-volume share > 0.5
Short: session up-volume share < 0.5