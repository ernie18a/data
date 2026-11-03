Calculation: Step size = Average True Range over a lookback × multiplier, calculated on the chart timeframe using the current bar.
Calculation: Stepped close = Start at the first close; on each bar, rise by one step if close is above the prior level plus the step, fall by one step if below the prior level minus the step, otherwise hold.
Calculation: Stepped open = Apply the same stepping rule to open.
Calculation: Base level = The previous stepped-open level, updated whenever the stepped open changes; undefined until the stepped open first changes.
Long: Base level is defined AND stepped close > base level
Short: Base level is defined AND stepped close < base level