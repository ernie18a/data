Calculation: Range filter = a recursively updated close-price centerline that moves only when close clears an adaptive range; the adaptive range is an EMA of absolute close changes, smoothed by a second EMA and multiplied by a scale factor.
Calculation: Rational-quadratic kernel estimate = weighted average of current and prior closes, with weights decreasing by a rational-quadratic function of bar distance.
Long: close > range filter AND range filter is rising AND rational-quadratic kernel estimate is rising AND consecutive bars since the leading long condition began <= expiry limit AND (alternation is disabled OR the prior confirmed signal was short)
Short: close < range filter AND range filter is falling AND rational-quadratic kernel estimate is falling AND consecutive bars since the leading short condition began <= expiry limit AND (alternation is disabled OR the prior confirmed signal was long)
Exit: long, short condition
Exit: short, long condition