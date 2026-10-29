Calculation: Fair value basis = a selected OHLC-derived price source smoothed by a selected method over a lookback.
Calculation: Threshold bands = the fair value basis offset by the median historical high and low deviations recorded on bars whose range crosses the basis.
Calculation: Deviation bands = the fair value basis offset by multiples of the median pivot deviations of OHLC4 relative to the basis; use five bars on each side to confirm pivots, recording upper pivots only when the bar low is above the upper threshold band and lower pivots only when the bar high is below the lower threshold band.
Long: A selected source crosses below a selected deviation band
Short: A selected source crosses above a selected deviation band
Long: The trend state changes from down to up; in cross mode, the selected uptrend source is above the upper threshold band, and in direction mode, the fair value basis rises
Short: The trend state changes from up to down; in cross mode, the selected downtrend source is below the lower threshold band, and in direction mode, the fair value basis falls
Long: Trend state is up AND low <= upper threshold band
Short: Trend state is down AND high >= lower threshold band