Calculation: FirstAverage = selected moving average of selected applied price(open, high, low, close) using the first method, first lookback (longer than the second lookback), and first phase on chart bars
Calculation: SecondAverage = selected moving average of FirstAverage using the second method, second lookback, and second phase on chart bars
Calculation: FirstAverageT1 = selected moving average of selected applied price(open, high, low, close) using the first method, first lookback, and first phase on T1 bars including the still-forming bar
Calculation: SecondAverageT1 = selected moving average of FirstAverageT1 using the second method, second lookback, and second phase on T1 bars including the still-forming bar
Long: FirstAverage > SecondAverage
Short: FirstAverage < SecondAverage
Long: On chart bars using values from the still-forming T1 bar, FirstAverageT1 > SecondAverageT1
Short: On chart bars using values from the still-forming T1 bar, FirstAverageT1 < SecondAverageT1