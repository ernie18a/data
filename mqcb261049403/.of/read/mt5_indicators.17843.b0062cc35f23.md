Calculation: JurX smoothing = apply three successive stages to the input; each stage computes two cascaded EMAs with coefficient 3/(length+2) and returns 1.5 times the first EMA minus 0.5 times the second; initialize all EMAs to the first input value.
Long: close >= moving average of low, using a selectable simple, exponential, smoothed, linearly weighted, Jurik, JurX, parabolic regression, T3, VIDYA, or Kaufman adaptive method.
Short: close < moving average of low, using the same selectable methods.
Long: the still-forming higher-timeframe bar's close >= its moving average of low, using the same selectable methods.
Short: the still-forming higher-timeframe bar's close < its moving average of low, using the same selectable methods.