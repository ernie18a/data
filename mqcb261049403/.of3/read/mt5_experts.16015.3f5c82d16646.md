Calculation: i-CAi line = main line of i-CAi on T1 bars, last completed bar
Calculation: i-CAi change = i-CAi line - i-CAi line one T1 bar ago
Calculation: i-CAi threshold = first threshold multiplier × standard deviation(i-CAi change, lookback)
Long: i-CAi change > i-CAi threshold OR (i-CAi line > i-CAi line one T1 bar ago AND i-CAi line one T1 bar ago < i-CAi line two T1 bars ago)
Short: i-CAi change < -i-CAi threshold OR (i-CAi line < i-CAi line one T1 bar ago AND i-CAi line one T1 bar ago > i-CAi line two T1 bars ago)
Exit: long, i-CAi change < -i-CAi threshold OR i-CAi line > i-CAi line one T1 bar ago
Exit: short, i-CAi change > i-CAi threshold OR i-CAi line < i-CAi line one T1 bar ago