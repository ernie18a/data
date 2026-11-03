Calculation: Raw call and put Vega = Black-Scholes Vega per 1% volatility change using close as spot, a manual strike or close rounded to the nearest strike step, a risk-free rate, separate manual call and put implied volatilities, and time from the bar's datetime to a configured expiry in years, floored at 0.0001 years.
Calculation: Call Vega momentum = EMA of the change in raw call Vega over the call lookback, with EMA length equal to the call lookback divided by 3, truncated to an integer and floored at 1.
Calculation: Put Vega momentum = EMA of the change in raw put Vega over the independently configured put lookback, with EMA length equal to the put lookback divided by 4, truncated to an integer and floored at 1.
Calculation: Latest buy index = bar index of the most recent bar where call Vega momentum crossed above put Vega momentum AND call Vega momentum > 0; initialize to -1.
Calculation: Latest sell index = bar index of the most recent bar where put Vega momentum crossed above call Vega momentum AND put Vega momentum > 0; initialize to -1.
Long: Call Vega momentum > put Vega momentum
Short: Put Vega momentum > call Vega momentum
Long: Call Vega momentum + put Vega momentum > 0
Short: Call Vega momentum + put Vega momentum < 0
Long: Latest buy index > latest sell index
Short: Latest sell index > latest buy index