Calculation: Rising count = number of smoothed Williams %R series whose value is greater than its previous bar; the series use the same Williams %R lookback and smoothing method, with smoothing lengths increasing by a fixed step.
Calculation: Non-rising count = number of those smoothed Williams %R series whose value is less than or equal to its previous bar.
Calculation: Bull line = rising count smoothed with the selected smoothing method and length; use indicator-timeframe bars, which may be higher or lower than the chart timeframe, and evaluate the last completed bar or, if configured, the bar still forming.
Calculation: Bear line = non-rising count smoothed with the same method and length as the bull line, using the same indicator-timeframe bars.
Long: Bull line > bear line AND previous indicator-bar bull line <= previous indicator-bar bear line.
Short: Bear line > bull line AND previous indicator-bar bear line <= previous indicator-bar bull line.
Exit: long, bear line > bull line OR low <= entry price - stop-loss distance OR high >= entry price + take-profit distance.
Exit: short, bull line > bear line OR high >= entry price + stop-loss distance OR low <= entry price - take-profit distance.