Calculation: Chart amplified difference = cube(amplifier parameter × (moving average(fast applied-price parameter, fast method parameter, shorter lookback, chart timeframe, current forming bar) minus moving average(slow applied-price parameter, slow method parameter, longer lookback, chart timeframe, current forming bar))).
Calculation: T1 amplified difference = cube(amplifier parameter × (moving average(fast applied-price parameter, fast method parameter, shorter lookback, T1, current forming bar) minus moving average(slow applied-price parameter, slow method parameter, longer lookback, T1, current forming bar))), sampled on chart bars.
Calculation: Chart upper threshold = 0 initially; after a long signal, chart amplified difference at that signal; after a short signal, chart amplified difference at that signal plus threshold-width parameter.
Calculation: Chart lower threshold = 0 initially; after a long signal, chart amplified difference at that signal minus threshold-width parameter; after a short signal, chart amplified difference at that signal.
Calculation: T1 upper threshold = 0 initially; after a long signal, T1 amplified difference at that signal; after a short signal, T1 amplified difference at that signal plus threshold-width parameter.
Calculation: T1 lower threshold = 0 initially; after a long signal, T1 amplified difference at that signal minus threshold-width parameter; after a short signal, T1 amplified difference at that signal.
Long: Chart amplified difference > chart upper threshold.
Short: Chart amplified difference < chart lower threshold.
Long: T1 amplified difference > T1 upper threshold.
Short: T1 amplified difference < T1 lower threshold.