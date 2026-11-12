Calculation: delta = sum over the lower-timeframe bars inside the chart bar of volume * sign(lower-timeframe bar close - previous lower-timeframe bar close), using the completed chart bar
Calculation: moveTicks = (close - open) / minimum tick size
Calculation: expectedTicks = alpha + beta * delta, where beta = correlation(delta, moveTicks over lookback L, excluding current bar) * stdev(moveTicks over L, excluding current bar) / stdev(delta over L, excluding current bar), and alpha = mean(moveTicks over L, excluding current bar) - beta * mean(delta over L, excluding current bar)
Calculation: failTicks = sign(expectedTicks) * (expectedTicks - moveTicks)
Calculation: z = (failTicks - mean(failTicks over L, including current bar)) / stdev(failTicks over L, including current bar)
Long: z >= positive threshold AND expectedTicks < 0 (sell delta absorbed, price fell less than expected)
Short: z >= positive threshold AND expectedTicks > 0 (buy delta absorbed, price rose less than expected)