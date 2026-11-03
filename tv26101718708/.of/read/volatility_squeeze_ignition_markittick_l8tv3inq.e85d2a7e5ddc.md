Calculation: Squeeze = lower Bollinger Band > lower Keltner Channel AND upper Bollinger Band < upper Keltner Channel; use a simple moving average of close as each channel's basis, standard deviation of close for Bollinger Bands, and average true range for Keltner Channel width, with independently parameterized lookbacks and multipliers.
Calculation: Squeeze delta = cumulative volume of bars closing above open minus cumulative volume of bars closing below open during the current squeeze; reset at the first squeeze bar and retain the last value after the squeeze ends. Delta ratio = absolute squeeze delta divided by total volume of those up-closing and down-closing bars, or zero when that total is zero.
Calculation: Bullish break = the previous bar was in a squeeze lasting at least the minimum number of consecutive bars AND the current bar is outside the squeeze AND close > current upper Bollinger Band AND previous bar's squeeze delta > 0.
Calculation: Bearish break = the previous bar was in a squeeze lasting at least the minimum number of consecutive bars AND the current bar is outside the squeeze AND close < current lower Bollinger Band AND previous bar's squeeze delta < 0.
Calculation: Expansion ratio = current Bollinger Band width divided by the previous bar's Bollinger Band width, or 1 when the previous width is zero.
Calculation: Body percentage = 100 times absolute close minus open divided by high minus low, or zero when high equals low.
Calculation: Bullish ignition = bullish break AND, if enabled, previous bar's delta ratio >= minimum delta ratio AND, if enabled, last completed higher-timeframe close > its simple moving average AND, if enabled, ADX >= minimum ADX AND, if enabled, body percentage >= minimum body percentage AND, if enabled, expansion ratio >= minimum expansion ratio.
Calculation: Bearish ignition = bearish break AND, if enabled, previous bar's delta ratio >= minimum delta ratio AND, if enabled, last completed higher-timeframe close <= its simple moving average AND, if enabled, ADX >= minimum ADX AND, if enabled, body percentage >= minimum body percentage AND, if enabled, expansion ratio >= minimum expansion ratio.
Calculation: Profit target = entry price plus, for a long, or minus, for a short, the Bollinger Band width on the bar before the ignition multiplied by a target multiplier. Three independently parameterized target multipliers are used. Each ignition replaces the active direction and targets; the active direction ends when its third target is hit.
Long: Squeeze delta > 0.
Short: Squeeze delta < 0.
Long: Higher-timeframe filter enabled AND last completed higher-timeframe close > its simple moving average.
Short: Higher-timeframe filter enabled AND last completed higher-timeframe close <= its simple moving average.
Long: Bullish break.
Short: Bearish break.
Long: Bullish ignition.
Short: Bearish ignition.
Exit: long, bearish ignition.
Exit: short, bullish ignition.
Exit: long, active long AND high >= any profit target.
Exit: short, active short AND low <= any profit target.