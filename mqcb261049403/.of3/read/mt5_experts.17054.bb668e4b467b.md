Calculation: RSIOMA histogram = RSIOMA(applied price, smoothing method, lookback, phase, momentum lookback) on T1; use bar N and older bars, where N is the signal-bar offset. Bar N is forming when N is zero and completed otherwise; evaluate on chart ticks when N is zero and on T1 bars otherwise.
Calculation: RSIOMA trigger line = MA(RSIOMA histogram, separate smoothing method, separate lookback, separate phase) on the same T1 bars.
Long: RSIOMA histogram[N+1] <= upper level AND RSIOMA histogram[N] > upper level
Short: RSIOMA histogram[N+1] >= lower level AND RSIOMA histogram[N] < lower level
Long: RSIOMA histogram[N+2] > RSIOMA histogram[N+1] AND RSIOMA histogram[N+1] < RSIOMA histogram[N]
Short: RSIOMA histogram[N+2] < RSIOMA histogram[N+1] AND RSIOMA histogram[N+1] > RSIOMA histogram[N]
Long: RSIOMA trigger line[N+2] > RSIOMA trigger line[N+1] AND RSIOMA trigger line[N+1] < RSIOMA trigger line[N]
Short: RSIOMA trigger line[N+2] < RSIOMA trigger line[N+1] AND RSIOMA trigger line[N+1] > RSIOMA trigger line[N]
Long: RSIOMA histogram[N+1] <= RSIOMA trigger line[N+1] AND RSIOMA histogram[N] > RSIOMA trigger line[N]
Short: RSIOMA histogram[N+1] >= RSIOMA trigger line[N+1] AND RSIOMA histogram[N] < RSIOMA trigger line[N]