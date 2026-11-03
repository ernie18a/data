Calculation: EMA slope = (EMA of chart-timeframe Open through the current forming bar − EMA of Open through the prior completed bar) / price point; both EMAs use the same lookback.
Calculation: Largest one-bar open change = maximum absolute Open difference across the current and previous five adjacent bar pairs, in price points.
Calculation: Largest two-bar open change = maximum absolute Open difference between bars two apart, ending at the current bar and the three preceding bars, in price points.
Long: position side is not long AND EMA slope ≥ lower slope threshold AND EMA slope ≤ upper slope threshold AND current bar minute > entry wait threshold AND current Close ≤ current Open AND current Close ≤ current Low + entry low allowance AND largest one-bar open change < one-bar jump threshold AND largest two-bar open change < two-bar jump threshold
Short: position side is not short AND EMA slope ≤ −lower slope threshold AND EMA slope ≥ −upper slope threshold AND current bar minute > entry wait threshold AND current Close ≥ current Open AND current Close ≥ current High − entry high allowance AND largest one-bar open change < one-bar jump threshold AND largest two-bar open change < two-bar jump threshold
Exit: Long, current Close ≤ long entry reference price − smart stop distance AND current bar minute > exit wait threshold AND current Close ≥ current Open AND current Close ≥ current High − exit high allowance
Exit: Short, current Close ≥ short entry reference price + smart stop distance AND current bar minute > exit wait threshold AND current Close ≤ current Open AND current Close ≤ current Low + exit low allowance
Exit: Long, prior bar Volume ≤ minimum volume
Exit: Short, prior bar Volume ≤ minimum volume
Exit: Long, current Low ≤ long entry price − emergency loss distance OR current High ≥ long entry price + take-profit distance
Exit: Short, current High ≥ short entry price + emergency loss distance OR current Low ≤ short entry price − take-profit distance