Calculation: Applied price = a configurable choice of close, open, high, low, (high + low) / 2, (high + low + close) / 3, (high + low + 2 × close) / 4, (open + close) / 2, (open + high + low + close) / 4, high if close > open else low if close < open else close, (high + close) / 2 if close > open else (low + close) / 2 if close < open else close, or DeMark price. DeMark price = (x - low + x - high) / 2, where x = (high + low + close + low) / 2 if close < open, (high + low + close + high) / 2 if close > open, and (high + low + 2 × close) / 2 otherwise.
Calculation: Rounded line = round the sum of a configurable price offset and a linearly weighted moving average of a linearly weighted moving average of applied price, both with the same lookback, to a configurable price increment.
Calculation: Line direction = the sign of the most recent nonzero change in the rounded line; retain the previous direction when the line is unchanged.
Calculation: Evaluate the line and applied price either on the chart timeframe or on the still-forming bar of a higher timeframe, using the same timeframe for both.
Long: Line direction > 0
Short: Line direction < 0
Long: Applied price > rounded line normalized to the instrument's price precision
Short: Applied price < rounded line normalized to the instrument's price precision