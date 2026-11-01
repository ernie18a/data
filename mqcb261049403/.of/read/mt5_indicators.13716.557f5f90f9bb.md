Calculation: Hull moving average = linear weighted moving average over floor(sqrt(n)) bars of (2 × linear weighted moving average of the selected price over floor(n/2) bars − linear weighted moving average of that price over n bars); the selected price defaults to close.
Long: Current chart-timeframe Hull moving average > its previous bar value.
Short: Current chart-timeframe Hull moving average < its previous bar value.
Long: Hull moving average of the still-forming higher-timeframe bar > its value on the preceding higher-timeframe bar.
Short: Hull moving average of the still-forming higher-timeframe bar < its value on the preceding higher-timeframe bar.