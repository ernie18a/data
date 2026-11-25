Calculation: Signal value = Inverse Fisher Transform(NonLag MA(0.1 × (RSX(applied price, RSX lookback) − 50), smoothing lookback)), computed on T1 bars using each bar’s value, including the still-forming bar; chart bars take the value from their containing T1 bar
Calculation: Direction state = prior state (initially neutral); set to neutral if Signal value < upper threshold AND Signal value > lower threshold, then set to long if Signal value > upper threshold, then set to short if Signal value < lower threshold
Long: Direction state = long
Short: Direction state = short