Calculation: RSI = 100 − 100 / (1 + average upward close change / average downward close change), using a longer smoothing lookback for upward changes than for downward changes; each average uses Wilder’s moving average.
Calculation: Mapped RSI = midpoint of the rolling highest high and lowest low + (RSI − 50) / 50 × half the rolling high-low range / adaptive scaling factor.
Calculation: RSI moving average = selected moving average of Mapped RSI, using the same lookback as the upward-change smoothing.
Long: Mapped RSI crosses above RSI moving average
Short: Mapped RSI crosses below RSI moving average
Exit: Long, low <= trailing stop OR high >= close × (1 + take-profit percentage)
Exit: Short, high >= trailing stop OR low <= close × (1 − take-profit percentage)