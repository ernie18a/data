Calculation: higher-timeframe range unit = cumulative true range divided by the number of elapsed bars plus one; use the higher-timeframe bar still forming
Calculation: higher-timeframe open level = round(source price / higher-timeframe range unit) × higher-timeframe range unit
Calculation: higher-timeframe high level = round(1 + source price / higher-timeframe range unit) × higher-timeframe range unit
Calculation: higher-timeframe low level = round(source price / higher-timeframe range unit − 1) × higher-timeframe range unit
Calculation: adjusted open, high, and low levels = their respective higher-timeframe levels plus or minus the chart-timeframe range unit multiplied by the range multiplier
Calculation: upper and lower trend bands = HL2 minus or plus the ATR multiplied by its factor; update each band using the prior band and prior trend state to trail in the current trend direction
Calculation: trend state = 1 when the adjusted low level is above the prior lower trend band; −1 when it is below the prior upper trend band; otherwise retain the prior trend state, initially 1
Calculation: trailing stop = upper trend band when trend state is 1; lower trend band otherwise
Long: crossover(low, adjusted low level minus range offset) AND trend state = 1
Long: adjusted open level plus range offset < trailing stop OR adjusted low level plus range offset < trailing stop OR adjusted high level plus range offset < trailing stop
Short: crossunder(high, higher-timeframe high level) AND trend state = −1
Short: adjusted high level minus range offset < trailing stop OR adjusted open level minus range offset < trailing stop OR adjusted low level minus range offset < trailing stop
Exit: long, crossover(close, adjusted open level plus range offset) AND (trend state ≠ 1 OR upper trend band = 0)
Exit: short, crossover(low, higher-timeframe open level) AND (trend state ≠ −1 OR lower trend band = 0)