Calculation: Power close = a second-stage moving average of (high + low) / 2 minus the first-stage moving average of close.
Calculation: Power open = the power close of the preceding bar when the absolute difference between the current open and previous close is below a gap threshold; otherwise, a second-stage moving average of (high + low) / 2 minus the first-stage moving average of open. The two stages have independently selectable methods and parameters.
Calculation: Period power open = power open from the oldest bar in a rolling lookback that includes the current bar. Compute these power calculations on either the chart timeframe or a higher timeframe using its bar still forming.
Long: Power close > period power open.
Short: Power close < period power open.