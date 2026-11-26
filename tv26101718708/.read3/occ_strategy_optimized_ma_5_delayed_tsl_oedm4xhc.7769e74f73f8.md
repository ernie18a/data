Calculation: T1 close MA = selected MA type(close[delay parameter], lookback parameter, applicable MA offset parameters), calculated on T1’s current, possibly still-forming bar and carried to chart bars
Calculation: T1 open MA = selected MA type(open[delay parameter], same lookback, MA type, and applicable offset parameters as T1 close MA), calculated on T1’s current, possibly still-forming bar and carried to chart bars
Calculation: Chart close MA = selected MA type(close[delay parameter], same lookback, MA type, and applicable offset parameters), calculated on chart bars
Calculation: Chart ADX = ADX(high, low, close, ADX length parameter for both directional-movement and smoothing lengths), calculated on chart bars
Calculation: Long stop = entry price × (1 − fixed-stop parameter) until any high since entry exceeds entry price × (1 + activation parameter); after activation, max(previous long stop, high × (1 − trail parameter))
Calculation: Short stop = entry price × (1 + fixed-stop parameter) until any low since entry falls below entry price × (1 − activation parameter); after activation, min(previous short stop, low × (1 + trail parameter))
Long: T1 close MA > T1 open MA
Short: T1 close MA ≤ T1 open MA
Long: Bar coloring is enabled AND Chart close MA > T1 open MA
Short: Bar coloring is enabled AND Chart close MA ≤ T1 open MA
Long: T1 close MA crosses above T1 open MA AND long trading is enabled AND (ADX filter is disabled OR Chart ADX > selected ADX threshold)
Short: T1 close MA crosses below T1 open MA AND short trading is enabled AND (ADX filter is disabled OR Chart ADX > selected ADX threshold)
Exit: long, TSL is enabled AND low ≤ Long stop OR take profit is enabled AND high ≥ entry price × (1 + take-profit parameter)
Exit: short, TSL is enabled AND high ≥ Short stop OR take profit is enabled AND low ≤ entry price × (1 − take-profit parameter)
Exit: long, trade mode permits long and disables short AND T1 close MA crosses below T1 open MA
Exit: short, trade mode permits short and disables long AND T1 close MA crosses above T1 open MA