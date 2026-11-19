Calculation: Spot gap = close(T1, forming bar, sampled on chart bars, chart symbol) - Heikin Ashi close(T1, forming bar, sampled on chart bars, chart symbol)
Calculation: Futures gap = close(T1, forming bar, sampled on chart bars, corresponding continuous futures symbol) - Heikin Ashi close(T1, forming bar, sampled on chart bars, corresponding continuous futures symbol)
Calculation: Gap difference = Futures gap - Spot gap when both are available, otherwise Spot gap
Long: Spot gap > 0
Short: Spot gap < 0
Long: Futures gap > 0
Short: Futures gap < 0
Long: Gap difference > 0
Short: Gap difference < 0