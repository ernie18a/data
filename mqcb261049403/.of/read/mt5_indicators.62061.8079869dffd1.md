Calculation: Bull volume = current bar volume if close > previous close; otherwise zero.
Calculation: Bear volume = current bar volume if close <= previous close; otherwise zero.
Calculation: Bull volume average = TEMA of bull volume.
Calculation: Bear volume average = TEMA of bear volume, using the same lookback as the bull volume average.
Calculation: Convergence = TEMA of (bull volume average - bear volume average), using a separate lookback.
Long: Bull volume average >= bear volume average.
Short: Bear volume average >= bull volume average.
Long: Convergence > 0 AND convergence > previous convergence.
Short: Convergence > 0 AND convergence <= previous convergence.