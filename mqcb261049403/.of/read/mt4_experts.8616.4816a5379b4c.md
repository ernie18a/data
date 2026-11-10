Calculation: Price = current chart-bar close, used for both bid and ask.
Calculation: Reference high and low = high and low of independently selected completed bars on a reference timeframe, which may be higher or lower than the chart timeframe. Scan chart bars backward from the current bar until a high equals the reference high or a low equals the reference low; call the high more recent if both match on the same bar.
Calculation: Fibonacci level at fraction f = reference low + f × (reference high − reference low) if the high is more recent; otherwise reference high − f × (reference high − reference low). Use distinct fractions for the lower reversal level, upper reversal level, and the two stop levels, ordered from lower to higher along the directed Fibonacci range.
Calculation: Support and resistance = respectively the low and high of the same selected completed bar on a configurable timeframe, which may be higher or lower than the chart timeframe.
Calculation: Trend = up when price is above the close EMA of the currently forming bar on the configurable support/resistance timeframe; down when price is below it; otherwise retain the previous trend.
Calculation: Trading area = price strictly between the lower and upper reversal levels.
Calculation: Initial stop = support for a trading-area long, resistance for a trading-area short, or the corresponding Fibonacci stop level at entry for a reversal trade. As favorable price movement from entry exceeds each successively larger activation threshold, raise a long stop or lower a short stop to the associated progressively more favorable offset from entry, if that improves the stop.
Long: Reference high is more recent AND price < lower reversal level.
Long: Reference low is more recent AND price < upper reversal level AND price <= lower reversal level.
Short: Reference high is more recent AND price > upper reversal level AND price >= lower reversal level.
Short: Reference low is more recent AND price > lower reversal level.
Long: Trend = up AND trading area AND price > resistance.
Short: Trend = down AND trading area AND price < support.
Short: Trend = up AND reference low is more recent AND price > lower reversal level AND price < resistance.
Short: Trend = down AND reference high is more recent AND price > upper reversal level AND price >= lower reversal level AND price < resistance.
Long: Trend = down AND reference high is more recent AND price < lower reversal level AND price < resistance.
Exit: long, price <= current stop OR (price != entry price AND price < support).
Exit: short, price >= current stop OR (price != entry price AND price > resistance).