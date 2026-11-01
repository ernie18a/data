Calculation: Adaptive center-of-gravity oscillator = For each bar, let n be the floor of half the Ehlers cycle period, limited to the number of preceding bars available. For i from 0 to n-1, let p[i] = (high[i] + low[i]) / 2, where i is the number of bars ago. The oscillator is (n + 1) / 2 - sum((i + 1) * p[i]) / sum(p[i]); it is undefined when the denominator is zero. Its trigger is the oscillator on the preceding bar. The cycle-period estimator is an external dependency whose implementation is not provided.
Calculation: Slow oscillator = Adaptive center-of-gravity oscillator on a higher timeframe, using its last completed bar.
Calculation: Fast oscillator = Adaptive center-of-gravity oscillator on the entry timeframe, using its last completed bar; the entry timeframe is shorter than the slow timeframe and may be the chart timeframe or a higher timeframe.
Long: Slow oscillator > its trigger AND fast oscillator > its trigger AND fast oscillator on the preceding entry-timeframe bar <= its trigger on that bar.
Short: Slow oscillator < its trigger AND fast oscillator < its trigger AND fast oscillator on the preceding entry-timeframe bar >= its trigger on that bar.
Exit: long, slow oscillator < its trigger OR fast oscillator < its trigger.
Exit: short, slow oscillator > its trigger OR fast oscillator > its trigger.
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance.
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance.