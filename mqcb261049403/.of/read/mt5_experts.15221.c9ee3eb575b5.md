Calculation: NonLagDot direction = up when its nonlag weighted moving average rises by more than the filter threshold from the preceding bar; down when it falls by more than the threshold; otherwise retain the prior direction. Evaluate on the indicator timeframe, which may be higher or lower than the chart timeframe, using completed bars.
Long: NonLagDot direction changes from down to up.
Short: NonLagDot direction changes from up to down.
Exit: long, NonLagDot direction is down.
Exit: short, NonLagDot direction is up.