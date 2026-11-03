Calculation: Chart trend = 0 initially; set it to 1 when a completed chart bar closes above its moving average after the previous bar closed at or below its moving average, and to -1 when a completed chart bar closes below its moving average after the previous bar closed at or above its moving average; otherwise retain its previous value.
Calculation: Higher-timeframe state = 1 if the close of the still-forming higher-timeframe bar is above its moving average, -1 if below, and 0 if equal. Use the same moving-average period, method, and applied price as the chart moving average for each higher timeframe.
Calculation: Advisor score = chart trend plus the higher-timeframe states for three higher timeframes.
Long: The completed chart bar closes above its moving average AND the preceding chart bar closes at or below its moving average.
Short: The completed chart bar closes below its moving average AND the preceding chart bar closes at or above its moving average.
Long: Chart trend = 1.
Short: Chart trend != 1.
Long: A still-forming higher-timeframe bar closes above its moving average.
Short: A still-forming higher-timeframe bar closes at or below its moving average.
Long: Advisor score >= 2.
Short: Advisor score <= -2.