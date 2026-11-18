Calculation: Reference high = highest high of chart bars in the reference session
Calculation: Reference low = lowest low of chart bars in the reference session
Calculation: Stop distance = max(reference high - reference low, applicable minimum stop-distance parameter)
Long: During the entry window, if no entry has occurred that day, close > reference high
Short: During the entry window, if no entry has occurred that day, close < reference low
Exit: long, low <= reference high - stop distance OR high >= reference high + (stop distance × take-profit ratio)
Exit: short, high >= reference low + stop distance OR low <= reference low - (stop distance × take-profit ratio)