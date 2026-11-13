Calculation: pivot high(N) = a bar whose high is the highest among the N bars before and N bars after it; it is confirmed N bars after the bar. Pivot low(N) is the mirror, using lows.
Calculation: structure high = price of the most recent pivot high using the structure lookback, reset to none once close breaks above it, until a new pivot high is confirmed. Structure low is the mirror, using pivot lows and breaks below.
Calculation: lookbacks satisfy structure lookback < zone lookback < major-swing lookback.
Long: close crosses above structure high
Long: a pivot low using the major-swing lookback is confirmed
Long: a pivot low using the zone lookback is confirmed
Long: the most recent confirmed major-swing pivot is a pivot low (the latest one is a low, not a high)
Long: EMA(close) of the wave period > its value one bar earlier
Short: close crosses below structure low
Short: a pivot high using the major-swing lookback is confirmed
Short: a pivot high using the zone lookback is confirmed
Short: the most recent confirmed major-swing pivot is a pivot high (the latest one is a high, not a low)
Short: EMA(close) of the wave period <= its value one bar earlier