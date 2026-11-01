Calculation: Estimated volume delta = volume × (2 × close − high − low) / (high − low + positive price-increment parameter); cumulative volume delta is its running sum.
Calculation: Flow momentum = (cumulative volume delta − cumulative volume delta at the momentum lookback) / (absolute cumulative volume delta at the momentum lookback + positive price-increment parameter).
Calculation: Flow score = (flow momentum − its simple moving average) / its population standard deviation over the same normalization lookback; use zero when the standard deviation is unavailable or nonpositive.
Long: Flow score > 0.
Short: Flow score <= 0.