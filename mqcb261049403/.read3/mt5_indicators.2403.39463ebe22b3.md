Calculation: chart fast = MA(Accelerator Oscillator(), shorter lookback, smoothing-method parameter, phase parameter)
Calculation: chart slow = MA(chart fast, longer lookback, smoothing-method parameter, phase parameter)
Long: chart fast > chart slow
Short: chart fast < chart slow
Calculation: T1 fast = MA(Accelerator Oscillator(), T1 shorter lookback, T1 smoothing-method parameter, T1 phase parameter), calculated on T1 bars using the still-forming bar and sampled onto chart bars at the first chart bar of each T1 bar; hold the sampled value until the next T1 bar
Calculation: T1 slow = MA(T1 fast, T1 longer lookback, T1 smoothing-method parameter, T1 phase parameter), calculated on T1 bars using the still-forming bar and sampled onto chart bars at the first chart bar of each T1 bar; hold the sampled value until the next T1 bar
Long: T1 fast > T1 slow
Short: T1 fast < T1 slow