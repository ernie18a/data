Calculation: Zero-lag EMA of a series = 2 × EMA of the series − EMA of that EMA, using the same length for both EMAs.
Calculation: Zero-lag MACD = zero-lag EMA of the selected price source with a shorter length − zero-lag EMA of the same source with a longer length.
Calculation: Signal = zero-lag EMA of zero-lag MACD, using its own length.
Calculation: Histogram = zero-lag MACD − Signal.
Calculation: Confirmed MACD pivot = a MACD high or low with the same number of bars on each side; it is detected only when the right-side bars have completed. For equal values, use the rightmost extreme.
Calculation: Divergence age = number of chart bars since the most recent confirmation of the corresponding divergence. Compare each pivot with the immediately preceding confirmed pivot of the same kind, including pivots that did not produce a divergence.
Calculation: Signal count = number of gated buy and sell signals on the current calendar day, reset at the start of each day. Bars since signal = number of chart bars since the most recent gated buy or sell signal; initialize it so the cooldown is satisfied before the first signal.
Long: A MACD pivot low is confirmed AND its distance from the preceding MACD pivot low is at most the maximum pivot separation AND the price low at the new pivot is lower than at the preceding pivot AND MACD at the new pivot is higher than at the preceding pivot.
Short: A MACD pivot high is confirmed AND its distance from the preceding MACD pivot high is at most the maximum pivot separation AND the price high at the new pivot is higher than at the preceding pivot AND MACD at the new pivot is lower than at the preceding pivot.
Long: Zero-lag MACD crosses above Signal on a completed bar.
Short: Zero-lag MACD crosses below Signal on a completed bar.
Long: Zero-lag MACD crosses above Signal on a completed bar AND bars since signal is at least the cooldown AND signal count is below the daily maximum AND (combo mode is disabled OR bullish divergence age is at most the validity window).
Short: Zero-lag MACD crosses below Signal on a completed bar AND bars since signal is at least the cooldown AND signal count is below the daily maximum AND (combo mode is disabled OR bearish divergence age is at most the validity window).
Long: Zero-lag MACD > Signal.
Short: Zero-lag MACD <= Signal.
Long: Histogram >= 0.
Short: Histogram < 0.
Long: Zero-lag MACD > 0.
Short: Zero-lag MACD <= 0.