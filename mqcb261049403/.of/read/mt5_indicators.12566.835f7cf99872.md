Calculation: Midpoint = (high + low) / 2.
Calculation: Leading line = 2 × current midpoint + (coefficient − 2) × previous midpoint + (1 − coefficient) × previous leading line; initialize it to the midpoint.
Calculation: Midpoint average = (current midpoint + previous midpoint average) / 2; initialize it to the midpoint.
Calculation: Higher-timeframe trend = direction of the most recent strict crossover of the leading line and midpoint average, calculated on higher-timeframe bars including the bar still forming; retain that direction until the next strict crossover.
Long: Chart-timeframe midpoint average was greater than the leading line on the previous bar AND is less than the leading line on the current bar, OR higher-timeframe trend is up.
Short: Chart-timeframe midpoint average was less than the leading line on the previous bar AND is greater than the leading line on the current bar, OR higher-timeframe trend is down.