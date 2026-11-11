Calculation: Selected open and close moving averages = apply the same selected moving-average type and length to open and close, each delayed by the same number of bars. The triangular moving average is an SMA of an SMA using the same length. The super smoother is y = c1*(source + nz(previous source))/2 + c2*nz(previous y) + c3*nz(y two bars ago), where a = exp(-1.414*3.14159/length), c2 = 2*a*cos(1.414*3.14159/length), c3 = -a*a, c1 = 1-c2-c3, and nz replaces unavailable values with zero.
Calculation: Alternate open and close averages = selected averages on the chart timeframe, or on a selected higher or lower timeframe. With the higher timeframe, historical bars use the final value of the higher-timeframe bar from its beginning; a realtime bar uses the still-forming bar. With the lower timeframe, historical bars use the first lower-timeframe bar within each chart bar; a realtime bar uses the latest available lower-timeframe bar.
Calculation: ADX threshold = a selected constant or the rolling median of chart-timeframe ADX, using a separate lookback.
Calculation: Long stop = entry price minus a fixed percentage until a chart-bar high exceeds entry price plus an activation percentage; from activation onward, the maximum of the fixed stop and each chart-bar high since activation minus a trailing percentage of that high.
Calculation: Short stop = entry price plus a fixed percentage until a chart-bar low falls below entry price minus an activation percentage; from activation onward, the minimum of the fixed stop and each chart-bar low since activation plus a trailing percentage of that low.
Long: Alternate close average crosses above alternate open average AND long trading is enabled AND (ADX filtering is disabled OR chart-timeframe ADX exceeds the ADX threshold).
Short: Alternate close average crosses below alternate open average AND short trading is enabled AND (ADX filtering is disabled OR chart-timeframe ADX exceeds the ADX threshold).
Long: Alternate close average > alternate open average.
Short: Alternate close average <= alternate open average.
Long: Chart-timeframe close average > alternate open average AND bar coloring is enabled.
Short: Chart-timeframe close average <= alternate open average AND bar coloring is enabled.
Exit: long, alternate close average crosses below alternate open average AND trading is long-only.
Exit: short, alternate close average crosses above alternate open average AND trading is short-only.
Exit: long, stop-loss option is enabled AND price reaches the long stop submitted after the preceding chart bar.
Exit: short, stop-loss option is enabled AND price reaches the short stop submitted after the preceding chart bar.
Exit: long, take-profit option is enabled AND price reaches entry price plus a take-profit percentage.
Exit: short, take-profit option is enabled AND price reaches entry price minus a take-profit percentage.